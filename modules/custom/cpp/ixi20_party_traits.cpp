/************************************************************************
 * Imagine XI 2.0: party members share job traits (module only).
 *
 * A Paladin in the party grants that Paladin's traits, at that Paladin's
 * current level, to everyone else in the party. Main job and subjob both
 * count. The highest rank of a trait in the party wins; lower ranks are
 * left in place when they are already better.
 *
 * Level sync and level cap use the level the character is actually
 * playing at. Merit traits and blue magic spell traits stay personal.
 * Alliance parties do not share with each other.
 *
 * Rebuild xi_map. Comment this file out of init.txt to turn it off.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"

#include "map/entities/char_entity.h"
#include "map/enums/packet_s2c.h"
#include "map/packets/basic.h"
#include "map/packets/s2c/0x061_clistatus.h"
#include "map/packets/s2c/0x0ac_command_data.h"
#include "map/party.h"
#include "map/trait.h"
#include "map/utils/charutils.h"
#include "map/zone.h"

#include "data/enums/job.h"
#include "data/enums/status.h"

#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <Windows.h>

#include <algorithm>
#include <cstring>
#include <mutex>
#include <string>
#include <unordered_map>
#include <vector>

namespace
{

constexpr size_t HookSize = 12;

using TraitsFn = void (*)(CCharEntity*);

struct Trampoline
{
    uint8* target = nullptr;
    uint8  original[HookSize]{};
    bool   installed = false;

    auto write(const uint8* bytes) -> bool
    {
        if (target == nullptr)
        {
            return false;
        }

        DWORD oldProtect = 0;
        if (VirtualProtect(target, HookSize, PAGE_EXECUTE_READWRITE, &oldProtect) == 0)
        {
            return false;
        }

        std::memcpy(target, bytes, HookSize);

        DWORD ignored = 0;
        VirtualProtect(target, HookSize, oldProtect, &ignored);
        FlushInstructionCache(GetCurrentProcess(), target, HookSize);
        return true;
    }

    auto install(void* dest) -> bool
    {
        if (target == nullptr || dest == nullptr)
        {
            return false;
        }

        if (!installed)
        {
            std::memcpy(original, target, HookSize);
        }

        uint8 jump[HookSize]{};
        jump[0] = 0x48; // mov rax, imm64
        jump[1] = 0xB8;
        const auto addr = reinterpret_cast<uint64>(dest);
        std::memcpy(jump + 2, &addr, sizeof(addr));
        jump[10] = 0xFF; // jmp rax
        jump[11] = 0xE0;

        if (!write(jump))
        {
            return false;
        }

        installed = true;
        return true;
    }

    auto remove() -> bool
    {
        if (!installed)
        {
            return true;
        }

        if (!write(original))
        {
            return false;
        }

        installed = false;
        return true;
    }
};

Trampoline                                  g_hook;
std::mutex                                   g_mutex;
TraitsFn                                     g_original = nullptr;
bool                                         g_hookInstalled = false;
bool                                         g_inSync        = false;
std::unordered_map<uint32, std::string>      g_appliedSig;

auto isExecutable(void* addr) -> bool
{
    if (addr == nullptr)
    {
        return false;
    }

    MEMORY_BASIC_INFORMATION info{};
    if (VirtualQuery(addr, &info, sizeof(info)) == 0)
    {
        return false;
    }

    constexpr DWORD exec = PAGE_EXECUTE | PAGE_EXECUTE_READ | PAGE_EXECUTE_READWRITE | PAGE_EXECUTE_WRITECOPY;
    return info.State == MEM_COMMIT && (info.Protect & exec) != 0;
}

auto traitsBytes() -> uint8*
{
    TraitsFn fn = &charutils::BuildingCharTraitsTable;
    if (!isExecutable(reinterpret_cast<void*>(fn)))
    {
        ShowError("Imagine XI 2.0: party traits could not resolve BuildingCharTraitsTable (ptr %p)", reinterpret_cast<void*>(fn));
        return nullptr;
    }

    g_original = fn;
    return reinterpret_cast<uint8*>(fn);
}

auto partyPcs(CCharEntity* PChar) -> std::vector<CCharEntity*>
{
    std::vector<CCharEntity*> pcs;
    if (PChar == nullptr || PChar->PParty == nullptr)
    {
        return pcs;
    }

    pcs.reserve(PChar->PParty->members.size());
    for (CBattleEntity* member : PChar->PParty->members)
    {
        if (member != nullptr && member->objtype == TYPE_PC)
        {
            pcs.push_back(static_cast<CCharEntity*>(member));
        }
    }

    return pcs;
}

// Empty when this character is not in a real party. Effective main/sub
// levels are part of the key so a level-up or level sync refreshes everyone.
auto partySignature(CCharEntity* PChar) -> std::string
{
    const auto members = partyPcs(PChar);
    if (members.size() < 2)
    {
        return {};
    }

    std::vector<std::string> parts;
    parts.reserve(members.size());
    for (CCharEntity* member : members)
    {
        parts.push_back(std::to_string(member->id) + ':' +
                        std::to_string(static_cast<unsigned>(member->GetMJob())) + ':' +
                        std::to_string(member->GetMLevel()) + ':' +
                        std::to_string(static_cast<unsigned>(member->GetSJob())) + ':' +
                        std::to_string(member->GetSLevel()));
    }

    std::sort(parts.begin(), parts.end());

    std::string sig;
    for (const std::string& part : parts)
    {
        sig += part;
        sig += ';';
    }

    return sig;
}

auto jobCanShare(xi::Job job, uint8 level) -> bool
{
    return job != xi::Job::NONE && job != xi::Job::MON && level > 0 && static_cast<uint8>(job) < MAX_JOBTYPE;
}

void grantSharedRank(CCharEntity* PChar, const TraitList_t& list, uint16 traitId, uint8 rank, uint8 level)
{
    uint8 haveRank = 0;
    for (CTrait* have : PChar->TraitList)
    {
        if (have == nullptr || have->getID() != traitId)
        {
            continue;
        }

        // Blue spell traits reuse these ids on their own tier scale.
        if (have->getLevel() == 0)
        {
            return;
        }

        if (have->getRank() > haveRank)
        {
            haveRank = have->getRank();
        }
    }

    if (haveRank > rank)
    {
        return;
    }

    if (haveRank > 0 && haveRank < rank)
    {
        for (std::size_t i = 0; i < PChar->TraitList.size();)
        {
            CTrait* have = PChar->TraitList[i];
            if (have != nullptr && have->getID() == traitId && have->getLevel() > 0)
            {
                PChar->delTrait(have);
            }
            else
            {
                ++i;
            }
        }
    }

    for (CTrait* trait : list)
    {
        if (trait == nullptr || trait->getID() != traitId || trait->getRank() != rank)
        {
            continue;
        }

        if (trait->getMeritID() != 0 || trait->getLevel() == 0 || level < trait->getLevel())
        {
            continue;
        }

        bool present = false;
        for (CTrait* have : PChar->TraitList)
        {
            if (have == trait || (have != nullptr && have->getID() == traitId && have->getRank() == rank && have->getMod() == trait->getMod()))
            {
                present = true;
                break;
            }
        }

        if (!present)
        {
            PChar->addTrait(trait);
        }
    }
}

void shareJob(CCharEntity* target, xi::Job job, uint8 level)
{
    if (target == nullptr || !jobCanShare(job, level))
    {
        return;
    }

    TraitList_t* list = traits::GetTraits(job);
    if (list == nullptr || list->empty())
    {
        return;
    }

    std::unordered_map<uint16, uint8> bestRank;
    for (CTrait* trait : *list)
    {
        if (trait == nullptr || trait->getMeritID() != 0 || trait->getLevel() == 0 || level < trait->getLevel())
        {
            continue;
        }

        auto [it, inserted] = bestRank.try_emplace(trait->getID(), trait->getRank());
        if (!inserted && trait->getRank() > it->second)
        {
            it->second = trait->getRank();
        }
    }

    for (const auto& [traitId, rank] : bestRank)
    {
        grantSharedRank(target, *list, traitId, rank, level);
    }
}

void sharePartyTraits(CCharEntity* PChar)
{
    const auto members = partyPcs(PChar);
    if (members.size() < 2)
    {
        return;
    }

    for (CCharEntity* member : members)
    {
        if (member == nullptr || member == PChar)
        {
            continue;
        }

        shareJob(PChar, member->GetMJob(), member->GetMLevel());
        shareJob(PChar, member->GetSJob(), member->GetSLevel());
    }
}

auto canPush(const CCharEntity* PChar) -> bool
{
    return PChar != nullptr && PChar->status != xi::Status::Disappear && PChar->status != xi::Status::Shutdown;
}

void publishTraits(CCharEntity* PChar)
{
    if (!canPush(PChar))
    {
        return;
    }

    PChar->UpdateHealth();
    PChar->pushPacket<GP_SERV_COMMAND_COMMAND_DATA>(PChar);
    PChar->pushPacket<GP_SERV_COMMAND_CLISTATUS>(PChar);
}

// Rebuild when the set of party jobs/levels changes. BuildingCharTraitsTable
// is hooked, so each rebuild picks up the current party traits.
void syncChar(CCharEntity* PChar)
{
    if (!g_hookInstalled || g_inSync || PChar == nullptr)
    {
        return;
    }

    const std::string sig = partySignature(PChar);
    const auto        applied = g_appliedSig.find(PChar->id);
    if (applied != g_appliedSig.end() && applied->second == sig)
    {
        return;
    }

    g_inSync = true;
    struct ClearSync
    {
        ~ClearSync()
        {
            g_inSync = false;
        }
    } clearSync;

    std::vector<CCharEntity*> members = partyPcs(PChar);
    if (members.size() < 2)
    {
        members.clear();
        members.push_back(PChar);
    }

    for (CCharEntity* member : members)
    {
        if (member == nullptr)
        {
            continue;
        }

        if (member != PChar && member->PParty != PChar->PParty)
        {
            continue;
        }

        const auto memberApplied = g_appliedSig.find(member->id);
        if (member != PChar && memberApplied != g_appliedSig.end() && memberApplied->second == sig)
        {
            continue;
        }

        charutils::BuildingCharTraitsTable(member);
        g_appliedSig[member->id] = sig;
        publishTraits(member);
    }
}

void hookedBuildingCharTraitsTable(CCharEntity* PChar)
{
    if (PChar == nullptr)
    {
        return;
    }

    std::lock_guard lock(g_mutex);

    if (g_original == nullptr || !g_hook.remove())
    {
        return;
    }

    struct Restore
    {
        ~Restore()
        {
            g_hook.install(reinterpret_cast<void*>(&hookedBuildingCharTraitsTable));
        }
    } restore;

    g_original(PChar);
    sharePartyTraits(PChar);
}

auto installHook() -> bool
{
    g_hook.target = traitsBytes();
    if (g_hook.target == nullptr)
    {
        return false;
    }

    if (!g_hook.install(reinterpret_cast<void*>(&hookedBuildingCharTraitsTable)))
    {
        return false;
    }

    g_hookInstalled = true;
    return true;
}

} // namespace

class Ixi20PartyTraitsModule : public CPPModule
{
public:
    void OnInit() override
    {
        if (installHook())
        {
            ShowInfo("Imagine XI 2.0: party members share each other's job traits at that member's level");
        }
        else
        {
            ShowError("Imagine XI 2.0: party traits failed to hook BuildingCharTraitsTable");
        }
    }

    void OnCharZoneOut(CCharEntity* PChar) override
    {
        // Drop the cached party key. LoadChar rebuilds personal traits before
        // the party is attached, and a matching key would skip the refresh.
        if (PChar != nullptr)
        {
            g_appliedSig.erase(PChar->id);
        }
    }

    void OnCharZoneIn(CCharEntity* PChar) override
    {
        if (PChar != nullptr)
        {
            g_appliedSig.erase(PChar->id);
        }

        syncChar(PChar);
    }

    void OnZoneTick(CZone* PZone) override
    {
        if (PZone == nullptr || !g_hookInstalled)
        {
            return;
        }

        PZone->ForEachChar([](CCharEntity* PChar) { syncChar(PChar); });
    }

    void OnPushPacket(CCharEntity* PChar, const std::unique_ptr<CBasicPacket>& packet) override
    {
        if (PChar == nullptr || packet == nullptr)
        {
            return;
        }

        const uint16 type = packet->getType();
        if (type == static_cast<uint16>(PacketS2C::GP_SERV_COMMAND_GROUP_TBL) ||
            type == static_cast<uint16>(PacketS2C::GP_SERV_COMMAND_JOB_INFO))
        {
            syncChar(PChar);
        }
    }
};

REGISTER_CPP_MODULE(Ixi20PartyTraitsModule);
