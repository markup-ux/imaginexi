/************************************************************************
 * Imagine XI 2.0: avatar equipment summons that avatar in combat.
 *
 * Lua tracks which piece was equipped last. This module:
 *   - records equip-packet order so a gearset's last avatar piece wins
 *   - spawns the avatar at the player's level. SpawnPet leaves a
 *     non-summoner at level 1, so the stats are calculated again with
 *     the job set to SMN for that call only.
 *   - keeps that avatar beside the pet slot. A summoner's own avatar
 *     can be out at the same time. The gear one is remembered by id
 *     and is not left in PPet.
 *
 * Rebuild xi_map after adding this file.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/lua.h"

#include "map/entities/char_entity.h"
#include "map/entities/pet_entity.h"
#include "map/enums/packet_c2s.h"
#include "map/item_container.h"
#include "map/lua/lua_base_entity.h"
#include "map/modifier.h"
#include "map/packets/basic.h"
#include "map/packets/c2s/0x050_equip_set.h"
#include "map/packets/c2s/0x051_equipset_set.h"
#include "map/packets/pet_sync.h"
#include "map/packets/s2c/0x0ac_command_data.h"
#include "map/trait.h"
#include "map/utils/battleutils.h"
#include "map/utils/charutils.h"
#include "map/utils/petutils.h"
#include "map/utils/zoneutils.h"

#include <initializer_list>
#include <unordered_map>
#include <vector>

namespace
{

constexpr uint8 JobSMN = 15;

// Char id -> item ids in the order the current equip packet listed them.
std::unordered_map<uint32, std::vector<uint16>> pendingEquips;

// Char id -> gear-avatar entity id. This pet is not left in PPet, so a
// summoner can keep their own avatar in the slot at the same time.
std::unordered_map<uint32, uint32> gearAvatars;

auto isGearAvatar(uint32 petId) -> bool
{
    return (petId >= PETID_CARBUNCLE && petId <= PETID_DIABOLOS) || petId == PETID_CAIT_SITH;
}

void rememberItem(CCharEntity* PChar, uint8 slotIndex, uint8 containerId)
{
    if (PChar == nullptr || slotIndex == 0)
    {
        return;
    }

    auto* storage = PChar->getStorage(containerId);
    if (storage == nullptr)
    {
        return;
    }

    auto* item = storage->GetItem(slotIndex);
    if (item == nullptr)
    {
        return;
    }

    auto& list = pendingEquips[PChar->id];
    if (list.size() >= 64)
    {
        list.clear();
    }

    list.push_back(item->getID());
}

// SpawnPet calculates a non-summoner avatar at level 1. Recalculate once
// with the job flipped to SMN, then take off the level-1 mods that stacked.
void raiseAvatarToMasterLevel(CCharEntity* PChar, CPetEntity* PPet)
{
    if (PChar == nullptr || PPet == nullptr || static_cast<uint8>(PChar->GetMJob()) == JobSMN)
    {
        return;
    }

    const std::initializer_list<xi::Mod> stacked = {
        xi::Mod::DEF,
        xi::Mod::EVA,
        xi::Mod::ATT,
        xi::Mod::ACC,
        xi::Mod::RATT,
        xi::Mod::RACC,
        xi::Mod::MATT,
        xi::Mod::MACC,
        xi::Mod::MAGIC_DAMAGE,
        xi::Mod::BP_DAMAGE,
        xi::Mod::MDEF,
        xi::Mod::MEVA,
    };

    std::vector<int16> before;
    before.reserve(stacked.size());
    for (const auto mod : stacked)
    {
        before.push_back(PPet->getMod(mod));
    }

    const auto savedJob = static_cast<uint8>(PChar->GetMJob());
    PChar->SetMJob(JobSMN);
    petutils::CalculateAvatarStats(PChar, PPet);
    PChar->SetMJob(savedJob);

    std::size_t index = 0;
    for (const auto mod : stacked)
    {
        if (before[index] != 0)
        {
            PPet->delModifier(mod, before[index]);
        }

        index++;
    }

    PPet->TraitList.clear();
    battleutils::AddTraits(PPet, traits::GetTraits(PPet->GetMJob()), PPet->GetMLevel());
    battleutils::AddTraits(PPet, traits::GetTraits(PPet->GetSJob()), PPet->GetSLevel());
    charutils::BuildingCharPetAbilityTable(PChar, PPet, PPet->petID());
    PChar->pushPacket<GP_SERV_COMMAND_COMMAND_DATA>(PChar);
    PChar->pushPacket<CPetSyncPacket>(PChar);
}

auto findGearAvatar(CCharEntity* PChar) -> CPetEntity*
{
    if (PChar == nullptr)
    {
        return nullptr;
    }

    auto it = gearAvatars.find(PChar->id);
    if (it == gearAvatars.end())
    {
        return nullptr;
    }

    auto* entity = zoneutils::GetEntity(it->second);
    auto* pet    = entity != nullptr ? dynamic_cast<CPetEntity*>(entity) : nullptr;
    if (pet == nullptr || pet->PMaster != PChar || pet->isDead())
    {
        if (pet != nullptr && pet->PMaster == PChar)
        {
            pet->PMaster = nullptr;
        }
        gearAvatars.erase(it);
        return nullptr;
    }

    return pet;
}

void releaseGearAvatar(CCharEntity* PChar)
{
    if (PChar == nullptr)
    {
        return;
    }

    auto* PPet = findGearAvatar(PChar);
    gearAvatars.erase(PChar->id);
    if (PPet == nullptr)
    {
        return;
    }

    if (PChar->PPet == PPet)
    {
        PChar->PPet = nullptr;
    }

    if (PPet->PMaster == PChar)
    {
        PPet->PMaster = nullptr;
    }

    if (PPet->PAI != nullptr && !PPet->isDead())
    {
        PPet->Die();
    }
}

// The gear avatar already in the pet slot steps out of it without
// despawning, so a summon spell can use the slot.
void adoptGearAvatar(CCharEntity* PChar)
{
    if (PChar == nullptr || PChar->PPet == nullptr || findGearAvatar(PChar) != nullptr)
    {
        return;
    }

    auto* slot = dynamic_cast<CPetEntity*>(PChar->PPet);
    if (slot == nullptr || !isGearAvatar(slot->petID()))
    {
        return;
    }

    gearAvatars[PChar->id] = slot->id;
    PChar->PPet             = nullptr;
    PChar->pushPacket<CPetSyncPacket>(PChar);
}

void restoreSlotPet(CCharEntity* PChar, CBattleEntity* saved)
{
    PChar->PPet = saved;
    if (auto* savedPet = dynamic_cast<CPetEntity*>(saved))
    {
        charutils::BuildingCharPetAbilityTable(PChar, savedPet, savedPet->petID());
        PChar->pushPacket<GP_SERV_COMMAND_COMMAND_DATA>(PChar);
    }

    PChar->pushPacket<CPetSyncPacket>(PChar);
}

void spawnGearAvatar(CCharEntity* PChar, uint32 petId)
{
    if (PChar == nullptr || !isGearAvatar(petId))
    {
        return;
    }

    if (auto* existing = findGearAvatar(PChar))
    {
        if (existing->petID() == petId)
        {
            if (PChar->PPet == existing)
            {
                PChar->PPet = nullptr;
                PChar->pushPacket<CPetSyncPacket>(PChar);
            }

            return;
        }

        releaseGearAvatar(PChar);
    }

    // SpawnPet refuses a second pet. Hold the summoner's avatar aside,
    // create the gear one, then put the summoner's avatar back.
    CBattleEntity* saved = PChar->PPet;
    PChar->PPet          = nullptr;
    petutils::SpawnPet(PChar, petId, false);

    auto* PPet = dynamic_cast<CPetEntity*>(PChar->PPet);
    if (PPet == nullptr)
    {
        PChar->PPet = saved;
        return;
    }

    raiseAvatarToMasterLevel(PChar, PPet);
    gearAvatars[PChar->id] = PPet->id;
    restoreSlotPet(PChar, saved);

    // Gear summons should not drain MP. ixi20_no_perpetuation clears this
    // on the zone tick; zero it now so the first tick is free as well.
    PChar->setModifier(xi::Mod::AVATAR_PERPETUATION, 0);
}

auto entityFromLua(lua_State* L, int index) -> CCharEntity*
{
    if (!sol::stack::check<CLuaBaseEntity*>(L, index))
    {
        return nullptr;
    }

    auto* wrapper = sol::stack::get<CLuaBaseEntity*>(L, index);
    if (wrapper == nullptr)
    {
        return nullptr;
    }

    return dynamic_cast<CCharEntity*>(wrapper->GetBaseEntity());
}

auto luaSpawnGearAvatar(lua_State* L) -> int
{
    auto* PChar = entityFromLua(L, 1);
    if (PChar == nullptr || lua_gettop(L) < 2 || !lua_isnumber(L, 2))
    {
        return 0;
    }

    spawnGearAvatar(PChar, static_cast<uint32>(lua_tointeger(L, 2)));
    return 0;
}

auto luaGetGearAvatar(lua_State* L) -> int
{
    auto* PPet = findGearAvatar(entityFromLua(L, 1));
    if (PPet == nullptr)
    {
        lua_pushnil(L);
        return 1;
    }

    sol::stack::push(L, CLuaBaseEntity(PPet));
    return 1;
}

auto luaReleaseGearAvatar(lua_State* L) -> int
{
    releaseGearAvatar(entityFromLua(L, 1));
    return 0;
}

auto luaAdoptGearAvatar(lua_State* L) -> int
{
    adoptGearAvatar(entityFromLua(L, 1));
    return 0;
}

auto luaConsumeEquipOrder(lua_State* L) -> int
{
    lua_newtable(L);

    auto* PChar = entityFromLua(L, 1);
    if (PChar == nullptr)
    {
        return 1;
    }

    auto it = pendingEquips.find(PChar->id);
    if (it == pendingEquips.end())
    {
        return 1;
    }

    int index = 1;
    for (const uint16 itemId : it->second)
    {
        lua_pushinteger(L, itemId);
        lua_rawseti(L, -2, index);
        index++;
    }

    pendingEquips.erase(it);
    return 1;
}

} // namespace

class Ixi20AvatarEquipModule : public CPPModule
{
public:
    void OnInit() override
    {
        lua_register(lua.lua_state(), "Ixi20SpawnGearAvatar", luaSpawnGearAvatar);
        lua_register(lua.lua_state(), "Ixi20GetGearAvatar", luaGetGearAvatar);
        lua_register(lua.lua_state(), "Ixi20ReleaseGearAvatar", luaReleaseGearAvatar);
        lua_register(lua.lua_state(), "Ixi20AdoptGearAvatar", luaAdoptGearAvatar);
        lua_register(lua.lua_state(), "Ixi20ConsumeAvatarEquipOrder", luaConsumeEquipOrder);
        ShowInfo("Imagine XI 2.0: avatar equipment summons that avatar when engaged");
    }

    void OnCharZoneOut(CCharEntity* PChar) override
    {
        releaseGearAvatar(PChar);
    }

    auto OnIncomingPacket(MapSession* session, CCharEntity* PChar, CBasicPacket& packet) -> bool override
    {
        (void)session;

        if (PChar == nullptr)
        {
            return false;
        }

        const auto type = packet.getType();
        if (type == static_cast<uint16>(PacketC2S::GP_CLI_COMMAND_EQUIP_SET))
        {
            const auto* equip = packet.as<GP_CLI_COMMAND_EQUIP_SET>();
            if (equip != nullptr)
            {
                rememberItem(PChar, equip->PropertyItemIndex, equip->Category);
            }
        }
        else if (type == static_cast<uint16>(PacketC2S::GP_CLI_COMMAND_EQUIPSET_SET))
        {
            const auto* equipset = packet.as<GP_CLI_COMMAND_EQUIPSET_SET>();
            if (equipset != nullptr)
            {
                const uint8 count = equipset->Count > 16 ? 16 : equipset->Count;
                for (uint8 i = 0; i < count; i++)
                {
                    rememberItem(PChar, equipset->Equipment[i].ItemIndex, equipset->Equipment[i].Category);
                }
            }
        }

        return false;
    }
};

REGISTER_CPP_MODULE(Ixi20AvatarEquipModule);
