/*
===========================================================================

  Market lottery: NPC vendor sales fund a weekly gil pool; one weighted
  winner receives the pool when conquest weekly tally completes.

===========================================================================
*/

#include "market_lottery.h"

#include "common/database.h"
#include "common/logging.h"
#include "common/settings.h"
#include "entities/charentity.h"
#include "enums/chat_message_type.h"
#include "item_container.h"
#include "items/item.h"
#include "lua/luautils.h"
#include "packets/s2c/0x017_chat_std.h"
#include "utils/charutils.h"
#include "utils/serverutils.h"
#include "utils/zoneutils.h"

#include <fmt/format.h>

#include <algorithm>
#include <climits>
#include <cstdint>
#include <mutex>
#include <random>
#include <string>
#include <vector>

namespace market_lottery
{
namespace
{
    // Serializes vendor tax recording and weekly draw so period / char_vars / pool stay consistent.
    std::mutex g_lotteryMutex;

    constexpr auto SV_POOL   = "ML_POOL_GIL";
    constexpr auto SV_PERIOD = "ML_PERIOD";

    auto periodVarName(int32 period) -> std::string
    {
        return std::string("MLW") + std::to_string(period);
    }

    struct LotteryEntry
    {
        uint32      charid = 0;
        uint32      weight = 0;
        std::string name;
    };

    void restorePoolGil(uint32 poolGil)
    {
        const int32  cur       = serverutils::GetVolatileServerVar(SV_POOL);
        const uint64 restored = static_cast<uint64>(std::max(0, cur)) + poolGil;
        const int32  next     = restored > static_cast<uint64>(INT32_MAX) ? INT32_MAX : static_cast<int32>(restored);
        serverutils::SetVolatileServerVar(SV_POOL, next, 0);
    }

    // Same channel as other server notices (e.g. fishing); Mes field is capped at 150 bytes.
    void broadcastWeeklyWinner(const std::string& winnerName, uint32 poolGil)
    {
        if (!settings::get<bool>("map.MARKET_LOTTERY_ANNOUNCE_ENABLED"))
        {
            return;
        }

        std::string msg = fmt::format("{} has won the weekly market lottery: {} gil.", winnerName, poolGil);
        if (msg.size() > 149)
        {
            msg.resize(149);
        }

        zoneutils::ForEachZone([&msg](CZone* PZone) {
            PZone->ForEachChar([&msg](CCharEntity* PChar) {
                PChar->pushPacket<GP_SERV_COMMAND_CHAT_STD>(PChar, CHAT_MESSAGE_TYPE::MESSAGE_SYSTEM_1, msg);
            });
        });
    }
} // namespace

uint32 playerVendorPayoutAfterTax(CCharEntity* PChar, uint32 grossGilFromVendor)
{
    if (PChar == nullptr || grossGilFromVendor == 0)
    {
        return grossGilFromVendor;
    }

    if (!settings::get<bool>("map.MARKET_LOTTERY_ENABLED"))
    {
        return grossGilFromVendor;
    }

    const uint32 taxBp = std::clamp(static_cast<uint32>(settings::get<double>("map.MARKET_LOTTERY_TAX_BP")), 0U, 10000U);
    if (taxBp == 0)
    {
        return grossGilFromVendor;
    }

    const uint32 tax = static_cast<uint32>((static_cast<uint64>(grossGilFromVendor) * taxBp) / 10000ULL);
    if (tax == 0)
    {
        return grossGilFromVendor;
    }

    std::lock_guard<std::mutex> lock(g_lotteryMutex);

    int32 period = static_cast<int32>(serverutils::GetServerVar(SV_PERIOD));
    if (period <= 0)
    {
        period = 1;
        serverutils::SetServerVar(SV_PERIOD, period);
    }

    const std::string cvName = periodVarName(period);
    charutils::IncrementCharVar(PChar, cvName, static_cast<int32>(tax));

    const int32  cur  = serverutils::GetVolatileServerVar(SV_POOL);
    const uint64 base = static_cast<uint64>(std::max(0, cur));
    uint64       next = base + tax;
    if (next > static_cast<uint64>(INT32_MAX))
    {
        next = INT32_MAX;
    }
    serverutils::SetVolatileServerVar(SV_POOL, static_cast<int32>(next), 0);

    return grossGilFromVendor - tax;
}

void onWeeklyConquestTallyEnd()
{
    if (!settings::get<bool>("map.MARKET_LOTTERY_ENABLED"))
    {
        return;
    }

    int32         period  = 0;
    std::string   varName;
    uint32        pool    = 0;
    const uint32  weightCapGil = std::max(1U, static_cast<uint32>(std::max(0.0, settings::get<double>("map.MARKET_LOTTERY_WEIGHT_CAP_GIL"))));
    const uint8   minLevel     = static_cast<uint8>(std::clamp(settings::get<double>("map.MARKET_LOTTERY_MIN_LEVEL"), 1.0, 75.0));

    std::vector<LotteryEntry> entries;
    entries.reserve(256);

    uint64       totalWeight = 0;
    uint32       winnerId    = 0;
    std::string  winnerName;

    {
        std::lock_guard<std::mutex> lock(g_lotteryMutex);

        period = static_cast<int32>(serverutils::GetServerVar(SV_PERIOD));
        if (period <= 0)
        {
            period = 1;
            serverutils::SetServerVar(SV_PERIOD, period);
        }

        varName = periodVarName(period);

        pool = static_cast<uint32>(std::max(0, serverutils::GetVolatileServerVar(SV_POOL)));
        serverutils::SetVolatileServerVar(SV_POOL, 0, 0);
        serverutils::PersistServerVar(SV_POOL, 0);

        if (pool == 0)
        {
            ShowInfo("Market lottery: no gil in pool; skipping draw.");
            return;
        }

        const auto rset = db::preparedStmt(
            "SELECT cv.charid, cv.value, c.charname "
            "FROM char_vars cv "
            "INNER JOIN chars c ON c.charid = cv.charid "
            "INNER JOIN char_stats cs ON cs.charid = cv.charid "
            "WHERE cv.varname = ? AND c.gmlevel = 0 AND cs.mlvl >= ?",
            varName,
            static_cast<int>(minLevel));

        if (rset && rset->rowsCount() > 0)
        {
            while (rset->next())
            {
                const uint32 charid = rset->get<uint32>("charid");
                const int32  value  = rset->get<int32>("value");
                if (value <= 0)
                {
                    continue;
                }

                LotteryEntry e{};
                e.charid = charid;
                e.weight = std::min(static_cast<uint32>(value), weightCapGil);
                if (e.weight == 0)
                {
                    continue;
                }
                e.name = rset->get<std::string>("charname");
                entries.push_back(std::move(e));
            }
        }

        if (entries.empty())
        {
            ShowWarningFmt("Market lottery: pool is {} gil but no eligible entries for period {}; restoring pool.", pool, period);
            restorePoolGil(pool);
            return;
        }

        for (const auto& e : entries)
        {
            totalWeight += e.weight;
        }

        if (totalWeight == 0)
        {
            ShowWarningFmt("Market lottery: pool is {} gil but total ticket weight is 0 for period {}; restoring pool.", pool, period);
            restorePoolGil(pool);
            return;
        }

        std::random_device rd;
        std::mt19937_64    rng(static_cast<uint64>(rd()) ^ static_cast<uint64>(pool) ^ (static_cast<uint64>(period) << 32));
        std::uniform_int_distribution<uint64> dist(0, totalWeight - 1);
        uint64                                roll = dist(rng);

        for (const auto& e : entries)
        {
            if (roll < e.weight)
            {
                winnerId   = e.charid;
                winnerName = e.name;
                break;
            }
            roll -= e.weight;
        }

        if (winnerId == 0 || winnerName.empty())
        {
            ShowErrorFmt("Market lottery: failed to select winner (period {}, pool {}).", period, pool);
            restorePoolGil(pool);
            return;
        }

        if (CCharEntity* winner = zoneutils::GetChar(winnerId))
        {
            // Slot 0 must be gil; UpdateItem on a non-currency there mis-applies the pool to the wrong item.
            charutils::EnsureInventoryGilSlot(winner);
            CItem* gilSlot = winner->getStorage(LOC_INVENTORY)->GetItem(0);
            if (gilSlot != nullptr && gilSlot->isType(ITEM_CURRENCY))
            {
                charutils::UpdateItem(winner, LOC_INVENTORY, 0, static_cast<int32>(pool));
                ShowInfoFmt("Market lottery: charid {} ({}) won {} gil (period {}, {} entrants, totalWeight {}).",
                            winnerId, winnerName, pool, period, entries.size(), totalWeight);
            }
            else
            {
                const auto rc = luautils::SendItemToDeliveryBox(winnerName, 0xFFFF, pool, "Market Lottery");
                if (rc != SendToDBoxReturnCode::SUCCESS && rc != SendToDBoxReturnCode::SUCCESS_LIMITED_TO_STACK_SIZE)
                {
                    ShowErrorFmt("Market lottery: online winner {} (charid {}) has no valid gil slot and delivery failed (return code {}); restoring pool.",
                                 winnerName, winnerId, static_cast<int>(rc));
                    restorePoolGil(pool);
                    return;
                }

                ShowInfoFmt("Market lottery: charid {} ({}) won {} gil via delivery box (no usable gil slot online; period {}, {} entrants, totalWeight {}).",
                            winnerId, winnerName, pool, period, entries.size(), totalWeight);
            }
        }
        else
        {
            const auto rc = luautils::SendItemToDeliveryBox(winnerName, 0xFFFF, pool, "Market Lottery");
            if (rc != SendToDBoxReturnCode::SUCCESS && rc != SendToDBoxReturnCode::SUCCESS_LIMITED_TO_STACK_SIZE)
            {
                ShowErrorFmt("Market lottery: could not deliver {} gil to offline winner {} (charid {}); return code {}.",
                             pool, winnerName, winnerId, static_cast<int>(rc));
                restorePoolGil(pool);
                return;
            }

            ShowInfoFmt("Market lottery: charid {} ({}) won {} gil via delivery box (period {}, {} entrants, totalWeight {}).",
                        winnerId, winnerName, pool, period, entries.size(), totalWeight);
        }

        broadcastWeeklyWinner(winnerName, pool);

        db::preparedStmt("DELETE FROM char_vars WHERE varname = ?", varName);
        serverutils::SetServerVar(SV_PERIOD, period + 1);
    }
}

} // namespace market_lottery
