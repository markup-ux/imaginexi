/************************************************************************
 * Imagine XI 2.0: trusts survive a zone change, and trust spells are
 * not limited to zones flagged for them.
 *
 * A trust entity cannot cross a zone line. Core clears the player's
 * trusts before the zone-out hook runs, so this remembers the spell
 * ids while the player is still in the zone and summons that same
 * roster again on zone-in. A dismiss, a death, or a party change
 * leaves the list empty, so those do not come back.
 *
 * The cast itself is refused in two places: the spell's zone mask
 * (magic state) and the Lua canCast check. This clears the mask.
 * The Lua module drops its own zone check.
 *
 * Rebuild xi_map after adding or removing this module.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/lua.h"

#include "map/ai/ai_container.h"
#include "map/entities/char_entity.h"
#include "map/entities/trust_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/lua/luautils.h"
#include "map/enums/packet_c2s.h"
#include "map/packets/basic.h"
#include "map/packets/c2s/0x016_charreq.h"
#include "map/packets/entity_set_name.h"
#include "map/spell.h"
#include "map/utils/trustutils.h"
#include "map/zone.h"

#include "data/enums/zone_misc.h"

#include <unordered_map>
#include <vector>

namespace
{

struct Roster
{
    std::vector<uint32> spellIds;
    bool                frozen  = false;
    bool                pending = false;
};

std::unordered_map<uint32, Roster> g_rosters;

void capture(CCharEntity* PChar, Roster& roster)
{
    roster.spellIds.clear();
    roster.spellIds.reserve(PChar->PTrusts.size());

    for (CTrustEntity* PTrust : PChar->PTrusts)
    {
        if (PTrust != nullptr)
        {
            roster.spellIds.push_back(PTrust->trustID());
        }
    }
}

void restore(CCharEntity* PChar, Roster& roster)
{
    roster.frozen = false;

    if (PChar->loc.zone == nullptr || !PChar->PTrusts.empty() || roster.spellIds.empty())
    {
        return;
    }

    const std::vector<uint32> spellIds = roster.spellIds;
    for (const uint32 spellId : spellIds)
    {
        trustutils::SpawnTrust(PChar, spellId);
    }

    // InsertTRUST already told this client to spawn them. That packet is
    // sent while the client is still loading, and the spawn list then
    // treats them as shown, so the model is never sent again. Drop the
    // list. The client's next entity sync sends the models for real.
    PChar->SpawnTRUSTList.clear();
}

void syncRoster(CCharEntity* PChar)
{
    if (PChar == nullptr)
    {
        return;
    }

    // Disappear is the gap between the core clear and the next zone.
    // The last Normal snapshot has to survive that gap.
    if (PChar->status == xi::Status::Disappear)
    {
        return;
    }

    auto found = g_rosters.find(PChar->id);
    if (found != g_rosters.end() && found->second.pending)
    {
        return;
    }

    auto& roster = g_rosters[PChar->id];

    if (roster.frozen)
    {
        // A zone packet froze the list, then the zone was refused and
        // the player is still here with the trusts already cleared.
        if (PChar->status == xi::Status::Normal && PChar->PTrusts.empty())
        {
            restore(PChar, roster);
        }
        else if (PChar->status == xi::Status::Normal)
        {
            roster.frozen = false;
        }
        return;
    }

    if (PChar->status != xi::Status::Normal)
    {
        return;
    }

    capture(PChar, roster);

    if (roster.spellIds.empty())
    {
        g_rosters.erase(PChar->id);
    }
}

void freezeRoster(CCharEntity* PChar)
{
    if (PChar == nullptr || PChar->status != xi::Status::Normal)
    {
        return;
    }

    auto& roster = g_rosters[PChar->id];
    capture(PChar, roster);
    roster.frozen = true;
}

auto clearTrustSpellZones() -> int
{
    int cleared = 0;

    for (uint16 id = 0; id < MAX_SPELL_ID; ++id)
    {
        CSpell* PSpell = spell::GetSpell(static_cast<SpellID>(id));
        if (PSpell == nullptr || PSpell->getSpellGroup() != SPELLGROUP_TRUST)
        {
            continue;
        }

        PSpell->setZoneMisc(xi::ZoneMisc::None);
        ++cleared;
    }

    return cleared;
}

// The client dismisses one trust by talking to it. That path is not
// exposed to Lua, and a party of 7 overflows the party packet. Remove
// the oldest member before the new trust is spawned.
auto luaDismissTrust(lua_State* L) -> int
{
    if (!sol::stack::check<CLuaBaseEntity*>(L, 1))
    {
        return 0;
    }

    auto* wrapper = sol::stack::get<CLuaBaseEntity*>(L, 1);
    if (wrapper == nullptr)
    {
        return 0;
    }

    auto* PTrust = dynamic_cast<CTrustEntity*>(wrapper->GetBaseEntity());
    if (PTrust == nullptr || PTrust->PAI == nullptr || !PTrust->PAI->IsSpawned())
    {
        return 0;
    }

    auto* PChar = dynamic_cast<CCharEntity*>(PTrust->PMaster);
    if (PChar == nullptr)
    {
        return 0;
    }

    luautils::OnMobDespawn(PTrust);
    PChar->RemoveTrust(PTrust);
    return 0;
}

} // namespace

class Ixi20TrustPersistModule : public CPPModule
{
public:
    void OnInit() override
    {
        lua_register(lua.lua_state(), "Ixi20TrustDismiss", luaDismissTrust);

        const int cleared = clearTrustSpellZones();
        ShowInfoFmt("Imagine XI 2.0: trusts persist across zones ({} trust spells can be cast anywhere)", cleared);
    }

    void OnZoneTick(CZone* PZone) override
    {
        if (PZone == nullptr)
        {
            return;
        }

        PZone->ForEachChar([](CCharEntity* PChar) { syncRoster(PChar); });
    }

    void OnCharZoneIn(CCharEntity* PChar) override
    {
        if (PChar == nullptr)
        {
            return;
        }

        const auto found = g_rosters.find(PChar->id);
        if (found == g_rosters.end())
        {
            return;
        }

        // The client is still loading. A spawn here reaches the party
        // list and then the model packet is dropped.
        found->second.pending = true;
        found->second.frozen  = false;
    }

    auto OnIncomingPacket(MapSession* session, CCharEntity* PChar, CBasicPacket& packet) -> bool override
    {
        (void)session;

        if (PChar == nullptr)
        {
            return false;
        }

        const auto packetType = packet.getType();

        if (packetType == static_cast<uint16>(PacketC2S::GP_CLI_COMMAND_MAPRECT))
        {
            // This packet clears trusts before any later hook can see them.
            freezeRoster(PChar);
            return false;
        }

        // Position packets are rejected while the character is still
        // disappearing, so the first one that arrives is the client in
        // the new zone. Spawn then, and let that same packet's entity
        // sync send the models.
        if (packetType == static_cast<uint16>(PacketC2S::GP_CLI_COMMAND_POS))
        {
            const auto found = g_rosters.find(PChar->id);
            if (found != g_rosters.end() && found->second.pending)
            {
                found->second.pending = false;
                restore(PChar, found->second);

                if (found->second.spellIds.empty())
                {
                    g_rosters.erase(found);
                }
            }

            return false;
        }

        // The client asks for a model it never received. The stock
        // lookup does not include trusts, so the request dies and the
        // party member stays invisible.
        if (packetType != static_cast<uint16>(PacketC2S::GP_CLI_COMMAND_CHARREQ))
        {
            return false;
        }

        const auto* request = packet.as<GP_CLI_COMMAND_CHARREQ>();
        if (request == nullptr)
        {
            return false;
        }

        auto* PTrust = PChar->GetEntity(request->ActIndex, TYPE_TRUST);
        if (PTrust == nullptr)
        {
            return false;
        }

        PChar->updateEntityPacket(PTrust, ENTITY_SPAWN, UPDATE_ALL_MOB);
        PChar->pushPacket<CEntitySetNamePacket>(PTrust);
        return true;
    }
};

REGISTER_CPP_MODULE(Ixi20TrustPersistModule);
