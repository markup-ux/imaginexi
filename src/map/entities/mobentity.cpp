/*
===========================================================================

  Copyright (c) 2010-2015 Darkstar Dev Teams

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "mobentity.h"

#include "ai/ai_container.h"
#include "ai/controllers/mob_controller.h"
#include "ai/helpers/pathfind.h"
#include "ai/helpers/targetfind.h"
#include "ai/states/attack_state.h"
#include "ai/states/mobskill_state.h"
#include "ai/states/weaponskill_state.h"
#include "battlefield.h"
#include "common/timer.h"
#include "common/utils.h"
#include "conquest_system.h"
#include "enmity_container.h"
#include "entities/charentity.h"
#include "enums/loot_recast.h"
#include "enums/weather.h"
#include "items.h"
#include "lua/lua_loot.h"
#include "lua/luautils.h"
#include "mob_modifier.h"
#include "mob_spell_container.h"
#include "mob_spell_list.h"
#include "mobskill.h"
#include "packets/entity_update.h"
#include "packets/pet_sync.h"
#include "packets/s2c/0x029_battle_message.h"
#include "recast_container.h"
#include "roe.h"
#include "spawn_slot.h"
#include "status_effect_container.h"
#include "treasure_pool.h"
#include "utils/battleutils.h"
#include "utils/blueutils.h"
#include "utils/charutils.h"
#include "utils/itemutils.h"
#include "utils/mobutils.h"
#include "utils/petutils.h"
#include "utils/zoneutils.h"
#include "weapon_skill.h"

#include "items/item_equipment.h"

#include "common/settings.h"

#include <cmath>
#include <cstring>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace
{
    struct CampHeatKey
    {
        uint16 zoneId;
        int32  cellX;
        int32  cellY;

        bool operator==(const CampHeatKey& rhs) const
        {
            return zoneId == rhs.zoneId && cellX == rhs.cellX && cellY == rhs.cellY;
        }
    };

    struct CampHeatKeyHasher
    {
        size_t operator()(const CampHeatKey& key) const noexcept
        {
            size_t h1 = std::hash<uint16>{}(key.zoneId);
            size_t h2 = std::hash<int32>{}(key.cellX);
            size_t h3 = std::hash<int32>{}(key.cellY);
            return h1 ^ (h2 << 1) ^ (h3 << 2);
        }
    };

    struct CampHeatCell
    {
        float            heat = 0.f;
        timer::time_point lastUpdate{};
    };

    std::unordered_map<CampHeatKey, CampHeatCell, CampHeatKeyHasher> g_CampHeat;

    void decayCampHeat(CampHeatCell& cell, timer::time_point now, timer::duration interval, float decayPerInterval)
    {
        if (interval <= 0s || decayPerInterval <= 0.f)
        {
            cell.lastUpdate = now;
            return;
        }

        if (cell.lastUpdate.time_since_epoch().count() == 0)
        {
            cell.lastUpdate = now;
            return;
        }

        auto elapsed = now - cell.lastUpdate;
        if (elapsed < interval)
        {
            return;
        }

        auto steps = elapsed / interval;
        cell.heat  = std::max(0.f, cell.heat - static_cast<float>(steps) * decayPerInterval);
        cell.lastUpdate += steps * interval;
    }

    bool wasKilledByPlayerSide(CMobEntity* mob)
    {
        if (mob->lastAttackerId_.id == 0)
        {
            return false;
        }

        auto* PEntity = mob->GetEntity(mob->lastAttackerId_.targid);
        if (PEntity == nullptr || PEntity->id != mob->lastAttackerId_.id)
        {
            return false;
        }

        auto* attacker = static_cast<CBattleEntity*>(PEntity);
        while (attacker->PMaster != nullptr)
        {
            attacker = attacker->PMaster;
        }

        return attacker->objtype == TYPE_PC || attacker->objtype == TYPE_TRUST || attacker->objtype == TYPE_FELLOW;
    }

    timer::duration computeCampHeatRespawn(CMobEntity* mob)
    {
        if (!settings::get<bool>("map.CAMP_HEAT_ENABLED"))
        {
            return mob->m_RespawnTime;
        }

        if (mob->m_SpawnType != SPAWNTYPE_NORMAL || mob->m_Type & (MOBTYPE_NOTORIOUS | MOBTYPE_BATTLEFIELD | MOBTYPE_EVENT | MOBTYPE_FISHED))
        {
            return mob->m_RespawnTime;
        }

        if (!wasKilledByPlayerSide(mob) || mob->loc.zone == nullptr)
        {
            return mob->m_RespawnTime;
        }

        float cellSize = settings::get<float>("map.CAMP_HEAT_CELL_SIZE");
        if (cellSize <= 0.f)
        {
            cellSize = 60.f;
        }

        const float gainPerKill    = std::max(0.f, settings::get<float>("map.CAMP_HEAT_GAIN_PER_KILL"));
        const float maxHeat        = std::max(0.f, settings::get<float>("map.CAMP_HEAT_MAX"));
        const float decayPerTick   = std::max(0.f, settings::get<float>("map.CAMP_HEAT_DECAY_PER_INTERVAL"));
        const float reductionStep  = std::max(0.f, settings::get<float>("map.CAMP_HEAT_RESPAWN_REDUCTION_PER_HEAT"));
        const float minMultiplier  = std::clamp(settings::get<float>("map.CAMP_HEAT_MIN_RESPAWN_MULTIPLIER"), 0.1f, 1.0f);
        const auto  decayInterval  = std::chrono::seconds(std::max<int32>(1, settings::get<int32>("map.CAMP_HEAT_DECAY_INTERVAL")));
        const int32 minRespawnSecs = std::max<int32>(1, settings::get<int32>("map.CAMP_HEAT_MIN_RESPAWN_SECONDS"));

        const int32 cellX = static_cast<int32>(std::floor(mob->loc.p.x / cellSize));
        const int32 cellY = static_cast<int32>(std::floor(mob->loc.p.z / cellSize));
        CampHeatKey   key{ mob->loc.zone->GetID(), cellX, cellY };

        const auto now = timer::now();
        auto&      cell = g_CampHeat[key];
        decayCampHeat(cell, now, decayInterval, decayPerTick);
        cell.heat       = std::min(maxHeat, cell.heat + gainPerKill);
        cell.lastUpdate = now;

        const uint32 baseRespawnSec = static_cast<uint32>(std::max<int64>(1, timer::count_seconds(mob->m_RespawnTime)));

        const float multiplier      = std::max(minMultiplier, 1.f - (cell.heat * reductionStep));
        int32       adjustedSeconds = static_cast<int32>(std::round(static_cast<float>(baseRespawnSec) * multiplier));
        adjustedSeconds             = std::max(minRespawnSecs, adjustedSeconds);
        return std::chrono::seconds(adjustedSeconds);
    }

// clang-format off
    std::map<uint8, uint16> geodeMap = {
        { ELEMENT_FIRE,    FLAME_GEODE   },
        { ELEMENT_ICE,     SNOW_GEODE    },
        { ELEMENT_WIND,    BREEZE_GEODE  },
        { ELEMENT_EARTH,   SOIL_GEODE    },
        { ELEMENT_THUNDER, THUNDER_GEODE },
        { ELEMENT_WATER,   AQUA_GEODE    },
        { ELEMENT_LIGHT,   LIGHT_GEODE   },
        { ELEMENT_DARK,    SHADOW_GEODE  }
    };

    std::map<uint8, uint16> avatariteMap = {
        { ELEMENT_FIRE,    IFRITITE  },
        { ELEMENT_ICE,     SHIVITE   },
        { ELEMENT_WIND,    GARUDITE  },
        { ELEMENT_EARTH,   TITANITE  },
        { ELEMENT_THUNDER, RAMUITE   },
        { ELEMENT_WATER,   LEVIATITE },
        { ELEMENT_LIGHT,   CARBITE   },
        { ELEMENT_DARK,    FENRITE   }
    };
// clang-format on

constexpr timer::duration SPECIAL_DROP_COOLDOWN = 5min; // 5 minutes between special drops
constexpr uint8           COSMETIC_DROP_CHANCE  = 10;   // Percent chance on EXP-yielding kills

// Curated cosmetic pool (see docs/COSMETIC_DROP_POOL_SORTED.md). Race + ownership weighting at roll time.
// Racial starter body/hands/legs/feet (12631-12637, 12754-12760, 12883-12889, 13005-13011) excluded — given at character creation.
const std::vector<uint16> COSMETIC_DROP_ITEM_IDS = {
    10250, 10251, 10252, 10253, 10254, 10256, 10257, 10258, 10259, 10260, 10261, 10262, 10263, 10264, 10265, 10266, 10267, 10268, 10269, 10270, 10271, 10293,
    10330, 10331, 10332, 10333, 10334, 10335, 10336, 10337, 10338, 10339, 10340, 10341, 10342, 10343, 10344, 10345, 10382, 10383, 10384, 10385, 10429, 10430,
    10431, 10432, 10433, 10446, 10447, 10593, 10594, 10595, 10596, 10875, 11265, 11266, 11267, 11268, 11269, 11270, 11271, 11272, 11273, 11274, 11275, 11276,
    11277, 11278, 11279, 11280, 11290, 11300, 11301, 11316, 11317, 11318, 11319, 11320, 11322, 11323, 11324, 11326, 11327, 11328, 11355, 11356, 11357, 11358,
    11403, 11490, 11491, 11499, 11500, 11811, 11812, 11861, 11862, 11965, 11966, 11967, 11968, 12523, 12551,
    12679, 12807, 12935, 13810, 13819, 13820, 13821, 13822, 13842, 13917, 13948, 14169, 14171, 14173, 14176, 14395, 14400, 14428, 14429, 14430, 14450, 14451, 14452,
    14453, 14454, 14455, 14456, 14457, 14458, 14459, 14460, 14461, 14462, 14463, 14471, 14472, 14519, 14520, 14532, 14533, 14534, 14535, 14584, 15008, 15043,
    15044, 15045, 15046, 15047, 15048, 15049, 15050, 15051, 15177, 15178, 15179, 15198, 15199, 15204, 15212, 15213, 15408, 15409, 15410, 15411, 15412, 15413,
    15414, 15415, 15416, 15417, 15418, 15419, 15420, 15421, 15423, 15424, 15752, 15753, 15754, 16075, 16076, 16118, 16119, 16120, 16321, 16322, 16323, 16324,
    16325, 16326, 16327, 16328, 16329, 16330, 16331, 16332, 16333, 16334, 16335, 16336, 16378, 23730, 23731, 23753, 23754, 23790, 23791, 23792, 23793, 23794,
    23795, 23796, 23800, 23803, 23804, 23805, 23807, 23808, 23809, 25585, 25586, 25587, 25604, 25606, 25607, 25608, 25632, 25633, 25637, 25638, 25639, 25645,
    25648, 25649, 25650, 25652, 25657, 25658, 25669, 25670, 25671, 25672, 25673, 25675, 25677, 25678, 25679, 25711, 25712, 25713, 25714, 25715, 25722, 25726,
    25734, 25735, 25736, 25737, 25738, 25739, 25740, 25741, 25742, 25743, 25744, 25755, 25756, 25757, 25758, 25759, 25774, 25775, 25776, 25777, 25778, 25817,
    25838, 25839, 25850, 25909, 25910, 25911, 26517, 26518, 26520, 26523, 26524, 26545, 26693, 26694, 26703, 26704, 26705, 26706, 26707, 26708, 26717, 26718,
    26719, 26720, 26728, 26729, 26730, 26738, 26739, 26788, 26789, 26798, 26799, 26889, 26890, 26946, 26954, 26955, 26956, 26957, 26964, 26965, 26966, 26967,
    26968, 26974, 26975, 27110, 27111, 27112, 27281, 27291, 27292, 27293, 27294, 27296, 27297, 27325, 27326, 27455, 27467, 27468, 27714, 27715, 27716, 27717,
    27718, 27726, 27727, 27733, 27734, 27756, 27757, 27758, 27759, 27760, 27765, 27803, 27804, 27805, 27806, 27854, 27855, 27859, 27860, 27866, 27867, 27872,
    27873, 27879, 27880, 27898, 27899, 27902, 27904, 27905, 27906, 27911, 27923, 28023, 28024, 28063, 28086, 28087, 28088, 28089, 28149, 28150, 28185, 28186,
    28187, 28302, 28303, 28324, 28325, 28326
};

std::vector<CCharEntity*> CollectPartyMembersForLoot(CCharEntity* PChar)
{
    std::vector<CCharEntity*> members;

    if (!PChar)
    {
        return members;
    }

    const auto PParty = PChar->PParty;
    if (!PParty || !PChar->PTreasurePool)
    {
        members.emplace_back(PChar);
        return members;
    }

    for (const auto& member : PChar->PTreasurePool->getMembers())
    {
        if (member && member->PParty == PParty)
        {
            members.emplace_back(member);
        }
    }

    if (members.empty())
    {
        members.emplace_back(PChar);
    }

    return members;
}

// Prefer cosmetics nobody in party owns (charutils::HasItem scans all storages).
// Skip items already in the treasure pool, or when every party member who can equip already has it.
uint16 PickPartyWeightedCosmeticItem(CCharEntity* PChar)
{
    const auto partyMembers = CollectPartyMembersForLoot(PChar);
    if (partyMembers.empty())
    {
        return 0;
    }

    std::unordered_set<uint16> pooledItemIds;
    if (PChar && PChar->PTreasurePool)
    {
        for (const auto& entry : PChar->PTreasurePool->getItems())
        {
            if (entry.ID != 0)
            {
                pooledItemIds.insert(entry.ID);
            }
        }
    }

    struct WeightedItem
    {
        uint16 itemId;
        uint16 weight;
    };

    std::vector<WeightedItem> weightedItems;
    uint32                    totalWeight = 0;

    for (const auto itemId : COSMETIC_DROP_ITEM_IDS)
    {
        if (pooledItemIds.contains(itemId))
        {
            continue;
        }

        const auto* PItem = xi::items::lookup<CItemEquipment>(itemId);
        if (!PItem)
        {
            continue;
        }

        uint16 wearers   = 0;
        uint16 nonOwners = 0;
        uint16 owners    = 0;

        for (const auto& member : partyMembers)
        {
            if (!member || !PItem->isEquippableByRace(member->look.race))
            {
                continue;
            }

            ++wearers;
            if (charutils::HasItem(member, itemId))
            {
                ++owners;
            }
            else
            {
                ++nonOwners;
            }
        }

        if (wearers == 0 || nonOwners == 0)
        {
            continue;
        }

        const uint16 weight = owners == 0 ? static_cast<uint16>(nonOwners + wearers * 2) : nonOwners;

        weightedItems.push_back({ itemId, weight });
        totalWeight += weight;
    }

    if (weightedItems.empty() || totalWeight == 0)
    {
        return 0;
    }

    auto roll = xirand::GetRandomNumber(totalWeight);
    for (const auto& entry : weightedItems)
    {
        if (roll < entry.weight)
        {
            return entry.itemId;
        }
        roll -= entry.weight;
    }

    return weightedItems.back().itemId;
}

} // namespace

CMobEntity::CMobEntity()
: m_AllowRespawn(false)
, m_CanSpawn(false)
, m_RespawnTime(5min)
, m_DropItemTime(0)
, m_DropID(0)
, m_minLevel(1)
, m_maxLevel(1)
, HPmodifier(0)
, MPmodifier(0)
, HPscale(1.0)
, MPscale(1.0)
, m_roamFlags(ROAMFLAG_NONE)
, m_specialFlags(SPECIALFLAG_NONE)
, m_StatPoppedMobs(false)
, strRank(3)
, dexRank(3)
, vitRank(3)
, agiRank(3)
, intRank(3)
, mndRank(3)
, chrRank(3)
, attRank(3)
, defRank(3)
, accRank(3)
, evaRank(3)
, m_dmgMult(100)
, m_disableScent(false)
, m_maxRoamDistance(50.0f)
, m_Type(MOBTYPE_NORMAL)
, m_Aggro(false)
, m_TrueDetection(false)
, m_Link(0)
, m_isAggroable(false)
, m_Behavior(BEHAVIOR_NONE)
, m_SpawnType(SPAWNTYPE_NORMAL)
, m_battlefieldID(0)
, m_bcnmID(0)
, m_giveExp(false)
, m_neutral(false)
, m_Element(0)
, m_HiPCLvl(0)
, m_HiPartySize(0)
, m_THLvl(0)
, m_GilfinderLevel(0)
, m_ItemStolen(false)
, m_ItemDespoiled(false)
, m_Family(0)
, m_SuperFamily(0)
, m_MobSkillList(0)
, m_Pool(0)
, m_flags(0)
, m_name_prefix(0)
, m_unk0(0)
, m_unk1(8)
, m_unk2(0)
, m_CallForHelpBlocked(false)
, m_IsPathingHome(false)
{
    TracyZoneScoped;
    objtype     = ENTITYTYPE::TYPE_MOB;
    allegiance  = ALLEGIANCE_TYPE::MOB;
    m_EcoSystem = ECOSYSTEM::UNCLASSIFIED;

    m_SpellListContainer = nullptr;
    PEnmityContainer     = new CEnmityContainer(this);
    SpellContainer       = new CMobSpellContainer(this);

    m_Weapons[SLOT_MAIN]   = std::make_unique<CItemWeapon>(0).release();
    m_Weapons[SLOT_SUB]    = std::make_unique<CItemWeapon>(0).release();
    m_Weapons[SLOT_RANGED] = std::make_unique<CItemWeapon>(0).release();
    m_Weapons[SLOT_AMMO]   = std::make_unique<CItemWeapon>(0).release();

    PAI = std::make_unique<CAIContainer>(this, std::make_unique<CPathFind>(this), std::make_unique<CMobController>(this), std::make_unique<CTargetFind>(this));
}

CMobEntity::~CMobEntity()
{
    TracyZoneScoped;
    destroy(m_Weapons[SLOT_MAIN]);
    destroy(m_Weapons[SLOT_SUB]);
    destroy(m_Weapons[SLOT_RANGED]);
    destroy(m_Weapons[SLOT_AMMO]);
    destroy(PEnmityContainer);
    destroy(SpellContainer);

    if (spawnSlot)
    {
        spawnSlot->RemoveMob(this);
    }

    if (PParty)
    {
        if (PParty->HasOnlyOneMember())
        {
            destroy(PParty);
        }
        else
        {
            PParty->DelMember(this);
        }
    }
}

uint32 CMobEntity::getEntityFlags() const
{
    return m_flags;
}

void CMobEntity::setEntityFlags(uint32 EntityFlags)
{
    m_flags = EntityFlags;
}

/************************************************************************
 *                                                                       *
 *  Monster disappear time (in seconds)                                  *
 *                                                                       *
 ************************************************************************/

timer::time_point CMobEntity::GetDespawnTime()
{
    return m_DespawnTimer;
}

void CMobEntity::SetDespawnTime(timer::duration _duration)
{
    if (_duration > 0s)
    {
        m_DespawnTimer = timer::now() + _duration;
    }
    else
    {
        m_DespawnTimer = timer::time_point::min();
    }
}

void CMobEntity::SetSpawnSlot(SpawnSlot* sharedSpawn)
{
    this->spawnSlot = sharedSpawn;
}

SpawnSlot* CMobEntity::GetSpawnSlot()
{
    return this->spawnSlot;
}

bool CMobEntity::TrySpawn()
{
    if (m_AllowRespawn && !PAI->IsSpawned())
    {
        if (spawnSlot)
        {
            spawnSlot->TrySpawn();
            return false;
        }

        if (m_CanSpawn)
        {
            Spawn();
            return true;
        }
    }
    return false;
}

uint32 CMobEntity::GetRandomGil()
{
    int16 min = getMobMod(MOBMOD_GIL_MIN);
    int16 max = getMobMod(MOBMOD_GIL_MAX);

    if (min && max)
    {
        // Assume we want this exact amount
        if (max <= min)
        {
            return min;
        }

        if (max - min < 2)
        {
            max = min + 2;
            ShowWarning("CMobEntity::GetRandomGil Max value is set too low, defaulting");
        }

        return xirand::GetRandomNumber(min, max);
    }

    float gil = (float)pow(GetMLevel(), 1.05f);

    if (gil < 1)
    {
        gil = 1;
    }

    uint16 highGil = (uint16)(gil / 3 + 4);

    if (max)
    {
        highGil = max;
    }

    if (highGil < 2)
    {
        highGil = 2;
    }

    // randomize it
    gil += xirand::GetRandomNumber(highGil);

    if (min && gil < min)
    {
        gil = min;
    }

    if (getMobMod(MOBMOD_GIL_BONUS) != 0)
    {
        gil *= (getMobMod(MOBMOD_GIL_BONUS) / 100.0f);
    }

    return (uint32)gil;
}

bool CMobEntity::CanDropGil()
{
    // smaller than 0 means drop no gil
    if (getMobMod(MOBMOD_GIL_MAX) < 0)
    {
        return false;
    }

    if (getMobMod(MOBMOD_GIL_MIN) > 0 || getMobMod(MOBMOD_GIL_MAX))
    {
        return true;
    }

    return getMobMod(MOBMOD_GIL_BONUS) > 0;
}

bool CMobEntity::CanStealGil()
{
    // TODO: Some mobs cannot be mugged
    return CanDropGil();
}

void CMobEntity::ResetGilPurse()
{
    uint32 purse = GetRandomGil() / ((xirand::GetRandomNumber(4, 7)));
    if (purse == 0)
    {
        purse = GetRandomGil();
    }
    setMobMod(MOBMOD_MUG_GIL, purse);
}

bool CMobEntity::CanRoamHome()
{
    if ((speed == 0 && !(m_roamFlags & ROAMFLAG_WORM)) || getMobMod(MOBMOD_NO_MOVE) > 0)
    {
        return false;
    }

    if (getMobMod(MOBMOD_NO_DESPAWN) != 0 || settings::get<bool>("map.MOB_NO_DESPAWN"))
    {
        return true;
    }

    return distance(m_SpawnPoint, loc.p) < roam_home_distance;
}

bool CMobEntity::CanRoam()
{
    return !(m_roamFlags & ROAMFLAG_SCRIPTED) && PMaster == nullptr && (speed > 0 || (m_roamFlags & ROAMFLAG_WORM)) && getMobMod(MOBMOD_NO_MOVE) == 0;
}

void CMobEntity::TapDeaggroTime()
{
    CMobController* mobController = dynamic_cast<CMobController*>(PAI->GetController());

    if (mobController)
    {
        mobController->TapDeaggroTime();
    }
}

bool CMobEntity::CanLink(position_t* pos, int16 superLink)
{
    TracyZoneScoped;
    // handle super linking
    if (superLink && getMobMod(MOBMOD_SUPERLINK) == superLink)
    {
        return true;
    }

    // can't link right now
    if (m_neutral)
    {
        return false;
    }

    // Don't link I'm an underground worm
    if ((m_roamFlags & ROAMFLAG_WORM) && IsNameHidden())
    {
        return false;
    }

    // Don't link I'm an underground antlion
    if ((m_roamFlags & ROAMFLAG_AMBUSH) && IsNameHidden())
    {
        return false;
    }

    // Link if can see mob
    if (getMobMod(MOBMOD_DETECTION) & DETECT_SIGHT && !facing(loc.p, *pos, 64))
    {
        return false;
    }

    if (distance(loc.p, *pos) > getMobMod(MOBMOD_LINK_RADIUS))
    {
        return false;
    }

    if (getMobMod(MOBMOD_NO_LINK) > 0)
    {
        return false;
    }

    if (!CanSeeTarget(*pos))
    {
        return false;
    }
    return true;
}

bool CMobEntity::ShouldForceLink()
{
    // There are certain cases where mobs should always be able
    // to link with other mobs, even if their families or sublinks
    // do not align
    if (loc.zone->GetTypeMask() & ZONE_TYPE::DYNAMIS)
    {
        return true;
    }

    if (m_Type & MOBTYPE_BATTLEFIELD)
    {
        return true;
    }

    if (getMobMod(MOBMOD_SUPERLINK))
    {
        return true;
    }

    return false;
}

bool CMobEntity::CanDeaggro() const
{
    return !(m_Type & MOBTYPE_NOTORIOUS || m_Type & MOBTYPE_BATTLEFIELD);
}

bool CMobEntity::IsFarFromHome()
{
    return distance(loc.p, m_SpawnPoint) > m_maxRoamDistance;
}

bool CMobEntity::CanBeNeutral() const
{
    return !(m_Type & MOBTYPE_NOTORIOUS);
}

bool CMobEntity::shouldUseTPMove(uint16 tpThreshold)
{
    const auto& MobSkillList = battleutils::GetMobSkillList(getMobMod(MOBMOD_SKILL_LIST));

    if (health.tp < 1000 || MobSkillList.empty() || !static_cast<CMobController*>(PAI->GetController())->IsWeaponSkillEnabled())
    {
        return false;
    }

    if (health.tp == 3000 || (GetHPP() < 25 && health.tp >= 1000))
    {
        return true;
    }

    // mobs use three mob skills in a row under Meikyo Shisui
    if (StatusEffectContainer->HasStatusEffect(EFFECT_MEIKYO_SHISUI) && GetLocalVar("[MeikyoShisui]MobSkillCount") > 0)
    {
        return true;
    }

    return health.tp >= tpThreshold;
}

void CMobEntity::setMobMod(uint16 type, int16 value)
{
    m_mobModStat[type] = value;
}

int16 CMobEntity::getMobMod(uint16 type)
{
    return m_mobModStat[type];
}

void CMobEntity::addMobMod(uint16 type, int16 value)
{
    m_mobModStat[type] += value;
}

void CMobEntity::defaultMobMod(uint16 type, int16 value)
{
    if (m_mobModStat[type] == 0)
    {
        m_mobModStat[type] = value;
    }
}

void CMobEntity::resetMobMod(uint16 type)
{
    m_mobModStat[type] = m_mobModStatSave[type];
}

void CMobEntity::saveMobModifiers()
{
    m_mobModStatSave = m_mobModStat;
}

void CMobEntity::restoreMobModifiers()
{
    m_mobModStat = m_mobModStatSave;
}

void CMobEntity::HideHP(bool hide)
{
    if (hide)
    {
        m_flags |= FLAG_HIDE_HP;
    }
    else
    {
        m_flags &= ~FLAG_HIDE_HP;
    }
    updatemask |= UPDATE_HP;
}

bool CMobEntity::IsHPHidden() const
{
    return m_flags & FLAG_HIDE_HP;
}

void CMobEntity::SetCallForHelpFlag(bool call)
{
    if (call)
    {
        m_flags |= FLAG_CALL_FOR_HELP;
        m_OwnerID.clean();
    }
    else
    {
        m_flags &= ~FLAG_CALL_FOR_HELP;
    }
    updatemask |= UPDATE_COMBAT;
}

bool CMobEntity::GetCallForHelpFlag() const
{
    return m_flags & FLAG_CALL_FOR_HELP;
}

void CMobEntity::SetUntargetable(bool untargetable)
{
    if (untargetable)
    {
        m_flags |= FLAG_UNTARGETABLE;
    }
    else
    {
        m_flags &= ~FLAG_UNTARGETABLE;
    }
    updatemask |= UPDATE_HP;
}

bool CMobEntity::GetUntargetable() const
{
    return m_flags & FLAG_UNTARGETABLE;
}

void CMobEntity::PostTick()
{
    TracyZoneScoped;
    CBattleEntity::PostTick();
    timer::time_point now = timer::now();
    if (loc.zone && updatemask && now > m_nextUpdateTimer)
    {
        m_nextUpdateTimer = now + 250ms;
        loc.zone->UpdateEntityPacket(this, ENTITY_UPDATE, updatemask);

        // If this mob is charmed, it should sync with its master
        if (PMaster && PMaster->objtype == TYPE_PC &&
            PMaster->PPet == this)
        {
            ((CCharEntity*)PMaster)->pushPacket<CPetSyncPacket>((CCharEntity*)PMaster);
        }

        updatemask = 0;
    }
}

float CMobEntity::GetRoamDistance()
{
    return (float)getMobMod(MOBMOD_ROAM_DISTANCE);
}

float CMobEntity::GetRoamRate()
{
    return (float)getMobMod(MOBMOD_ROAM_RATE) / 10.0f;
}

bool CMobEntity::ValidTarget(CBattleEntity* PInitiator, uint16 targetFlags)
{
    TracyZoneScoped;

    if (StatusEffectContainer->GetConfrontationEffect() != PInitiator->StatusEffectContainer->GetConfrontationEffect())
    {
        return false;
    }

    if (CBattleEntity::ValidTarget(PInitiator, targetFlags))
    {
        return true;
    }

    if (targetFlags & TARGET_PLAYER_DEAD && (m_Behavior & BEHAVIOR_RAISABLE) && isDead())
    {
        return true;
    }

    if ((targetFlags & TARGET_PLAYER) && allegiance == PInitiator->allegiance && !(m_Behavior & BEHAVIOR_NO_ASSIST) && !isCharmed)
    {
        return true;
    }

    if (targetFlags & TARGET_NPC)
    {
        if (allegiance == PInitiator->allegiance && !(m_Behavior & BEHAVIOR_NO_ASSIST) && !isCharmed)
        {
            return true;
        }
    }

    return false;
}

void CMobEntity::Spawn()
{
    TracyZoneScoped;
    CBattleEntity::Spawn();
    m_giveExp        = true;
    m_HiPCLvl        = 0;
    m_HiPartySize    = 0;
    m_THLvl          = 0;
    m_GilfinderLevel = 0;
    m_ItemStolen     = false;
    m_ItemDespoiled  = false;
    m_DropItemTime   = 1000ms;
    animationsub     = (uint8)getMobMod(MOBMOD_SPAWN_ANIMATIONSUB);
    SetCallForHelpFlag(false);

    PEnmityContainer->Clear();

    // The underlying function in GetRandomNumber doesn't accept uint8 as <T> so use uint32
    // https://stackoverflow.com/questions/31460733/why-arent-stduniform-int-distributionuint8-t-and-stduniform-int-distri
    uint8 level = static_cast<uint8>(xirand::GetRandomNumber<uint32>(m_minLevel, m_maxLevel + 1));

    TraitList.clear(); // Clear traits just in case from random levels. Traits are recalculated in mobutils::CalculateMobStat().
                       // Note: Traits are NOT stored on DB load as of writing, so mobs won't gradually get stronger on respawn from restoreModifiers()
    SetMLevel(level);
    SetSLevel(level); // subjob calculated in function as appropriate

    mobutils::CalculateMobStats(this);
    mobutils::GetAvailableSpells(this);

    // spawn somewhere around my point
    loc.p = m_SpawnPoint;

    if (m_roamFlags & ROAMFLAG_STEALTH)
    {
        HideName(true);
        SetUntargetable(true);
    }

    // add people to my posse
    if (getMobMod(MOBMOD_ASSIST))
    {
        for (int32 i = 1; i < getMobMod(MOBMOD_ASSIST) + 1; i++)
        {
            CMobEntity* PMob = (CMobEntity*)GetEntity(targid + i, TYPE_MOB);

            if (PMob != nullptr)
            {
                PMob->setMobMod(MOBMOD_SUPERLINK, targid);
            }
        }
    }

    m_DespawnTimer = timer::time_point::min();
    luautils::OnMobSpawn(this);

    // Set the despawn time if the mob has a non-zero idle despawn time modifier.
    // This is used to despawn mobs that are not engaged in combat after a certain time.
    if (getMobMod(MOBMOD_IDLE_DESPAWN) > 0)
    {
        SetDespawnTime(std::chrono::seconds(getMobMod(MOBMOD_IDLE_DESPAWN)));
    }
}

void CMobEntity::OnWeaponSkillFinished(CWeaponSkillState& state, action_t& action)
{
    TracyZoneScoped;
    CBattleEntity::OnWeaponSkillFinished(state, action);

    TapDeaggroTime();
}

void CMobEntity::OnMobSkillFinished(CMobSkillState& state, action_t& action)
{
    TracyZoneScoped;

    CBattleEntity::OnMobSkillFinished(state, action);

    TapDeaggroTime();
}

void CMobEntity::DistributeRewards()
{
    TracyZoneScoped;
    CCharEntity* PChar = (CCharEntity*)GetEntity(m_OwnerID.targid, TYPE_PC);

    if (PChar != nullptr && PChar->id == m_OwnerID.id)
    {
        StatusEffectContainer->KillAllStatusEffect();
        PChar->m_charHistory.enemiesDefeated++;

        // NOTE: this is called for all alliance / party members!
        luautils::OnMobDeath(this, PChar);

        if (!GetCallForHelpFlag())
        {
            blueutils::TryLearningSpells(PChar, this);
            m_UsedSkillIds.clear();

            // RoE Mob kill event for all party members
            // clang-format off
            PChar->ForAlliance([this, PChar](CBattleEntity* PMember)
            {
                if (PMember->getZone() == PChar->getZone())
                {
                    RoeDatagramList datagrams;
                    datagrams.emplace_back("mob", this);
                    datagrams.emplace_back("atkType", static_cast<uint8>(this->BattleHistory.lastHitTaken_atkType));
                    roeutils::event(ROE_MOBKILL, (CCharEntity*)PMember, datagrams);
                }
            });
            // clang-format on

            if (m_giveExp && !PChar->StatusEffectContainer->HasStatusEffect(EFFECT_BATTLEFIELD))
            {
                charutils::DistributeExperiencePoints(PChar, this);
                charutils::DistributeCapacityPoints(PChar, this);
            }

            // check for gil (beastmen drop gil, some NMs drop gil)
            if ((settings::get<float>("map.MOB_GIL_MULTIPLIER") > 0.0f && CanDropGil()) ||
                (settings::get<float>("map.ALL_MOBS_GIL_BONUS") > 0 &&
                 getMobMod(MOBMOD_GIL_MAX) >= 0)) // Negative value of MOBMOD_GIL_MAX is used to prevent gil drops in Dynamis/Limbus.
            {
                charutils::DistributeGil(PChar, this); // TODO: REALISATION MUST BE IN TREASUREPOOL
            }

            DropItems(PChar);
        }
    }
    else
    {
        luautils::OnMobDeath(this, nullptr);
    }
}

// Return the list of seals that can drop based on the mob's level.
// Rules:
// - Mob  < 50: Beastmen's Seal
// - Mob >= 50: Beastmen's Seal, Kindred's Seal
// - Mob >= 70: Beastmen's Seal, Kindred's Seal, Kindred's Crest
// - Mob >= 80: Beastmen's Seal, Kindred's Seal, Kindred's Crest, High Kindred's Crest
// If Abyssea is not enabled, pool is limited to Beastmen's Seal and Kindred's Seal.
auto CMobEntity::GetEligibleSeals() -> std::vector<uint16>
{
    if (GetMLevel() >= 80 && luautils::IsContentEnabled("ABYSSEA"))
    {
        return { BEASTMENS_SEAL, KINDREDS_SEAL, KINDREDS_CREST, HIGH_KINDREDS_CREST };
    }

    if (GetMLevel() >= 70 && luautils::IsContentEnabled("ABYSSEA"))
    {
        return { BEASTMENS_SEAL, KINDREDS_SEAL, KINDREDS_CREST };
    }

    if (GetMLevel() >= 50)
    {
        return { BEASTMENS_SEAL, KINDREDS_SEAL };
    }

    return { BEASTMENS_SEAL };
}

// Return the list of Geode and Avatarites that can drop based on the mob's level.
// Rules:
// - Mob >= 50: Geodes of matching weather/day can drop. Weather takes priority.
// - Mob >= 80: Avatarites of matching weather/day can also drop. Weather takes priority.
auto CMobEntity::GetEligibleGeodes() const -> std::vector<uint16>
{
    if (!luautils::IsContentEnabled("ABYSSEA"))
    {
        return {};
    }

    uint8 element = 0;

    // Set element by weather
    if (const Weather weather = loc.zone->GetWeather(); weather >= Weather::HotSpell && weather <= Weather::Darkness)
    {
        /*
        element = zoneutils::GetWeatherElement(weather);
        Can't use this because of the TODO in zoneutils about broken element order >.<
        So we have this ugly switch until then.
        */
        switch (weather)
        {
            case Weather::HotSpell:
            case Weather::HeatWave:
                element = ELEMENT_FIRE;
                break;
            case Weather::Rain:
            case Weather::Squall:
                element = ELEMENT_WATER;
                break;
            case Weather::DustStorm:
            case Weather::SandStorm:
                element = ELEMENT_EARTH;
                break;
            case Weather::Wind:
            case Weather::Gales:
                element = ELEMENT_WIND;
                break;
            case Weather::Snow:
            case Weather::Blizzards:
                element = ELEMENT_ICE;
                break;
            case Weather::Thunder:
            case Weather::Thunderstorms:
                element = ELEMENT_THUNDER;
                break;
            case Weather::Auroras:
            case Weather::StellarGlare:
                element = ELEMENT_LIGHT;
                break;
            case Weather::Gloom:
            case Weather::Darkness:
                element = ELEMENT_DARK;
                break;
            default:
                break;
        }
    }
    // Set element from day instead
    else
    {
        element = battleutils::GetDayElement();
    }

    if (GetMLevel() >= 80)
    {
        return { geodeMap[element], avatariteMap[element] };
    }

    if (GetMLevel() >= 50)
    {
        return { geodeMap[element] };
    }

    return {};
}

void CMobEntity::DropItems(CCharEntity* PChar)
{
    TracyZoneScoped;
    // Adds an item to the treasure pool. Treasure pool will automatically kick out items if the pool is full (prioritizing non rare non ex items)
    auto AddItemToPool = [this, PChar](uint16 ItemID)
    {
        PChar->PTreasurePool->addItem(ItemID, this);
        PAI->EventHandler.triggerListener("TREASUREPOOL", CLuaBaseEntity(this), CLuaBaseEntity(PChar), ItemID);
    };

    // Checks if the party is eligible for adding global drops (seals, geodes, avatarites)
    auto CanAddSpecial = [PChar](LootRecastID id)
    {
        const auto PParty = PChar->PParty;

        if (!PParty || !PChar->PTreasurePool)
        {
            return !PChar->PRecastContainer->HasLootRecast(id);
        }

        for (const auto& member : PChar->PTreasurePool->getMembers())
        {
            if (member->PParty == PParty)
            {
                if (member->PRecastContainer->HasLootRecast(id))
                {
                    return false;
                }
            }
        }

        return true;
    };

    // Seals are limited to one every 5 minutes per party.
    // Geodes and avatarites are limited to one every 5 minutes per party.
    // Cooldown is applied to members (in zone) of the party that delivered the killing blow.
    // Note that the following has been verified to be retail accurate:
    // - Other alliance parties are NOT included in that cooldown.
    // - The cooldown does reset when zoning.
    auto AddSpecialRecast = [PChar](LootRecastID id)
    {
        const auto PParty = PChar->PParty;

        if (!PParty || !PChar->PTreasurePool)
        {
            PChar->PRecastContainer->AddLootRecast(id, SPECIAL_DROP_COOLDOWN);
            return;
        }

        for (const auto& member : PChar->PTreasurePool->getMembers())
        {
            if (member->PParty == PParty)
            {
                member->PRecastContainer->AddLootRecast(id, SPECIAL_DROP_COOLDOWN);
            }
        }
    };

    DropList_t* dropList = itemutils::GetDropList(m_DropID);

    if (!getMobMod(MOBMOD_NO_DROPS) && dropList != nullptr && (!dropList->Items.empty() || !dropList->Groups.empty() || PAI->EventHandler.hasListener("ITEM_DROPS")))
    {
        // THLvl determines the drop rate.
        auto thDropRateFunction = lua["xi"]["combat"]["treasureHunter"]["getDropRate"];

        LootContainer loot(dropList);

        PAI->EventHandler.triggerListener("ITEM_DROPS", this, &loot);

        // clang-format off
        loot.ForEachGroup([&](const DropGroup_t& group)
        {
            uint16 total = 0;
            for (const DropItem_t& item : group.Items)
            {
                total += item.DropRate;
            }

            uint16 groupDropRate = group.GroupRate * 10;

            if (!group.hasFixedRate)
            {
                groupDropRate = thDropRateFunction(m_THLvl, groupDropRate);
            }

            // Determine if this group should drop an item.
            if (groupDropRate > 0 && (1 + xirand::GetRandomNumber(10000)) <= groupDropRate * settings::get<float>("map.DROP_RATE_MULTIPLIER"))
            {
                // Each item in the group is given its own weight range which is the previous value to the previous value + item.DropRate
                // Such as 2 items with drop rates of 200 and 800 would be 0-199 and 200-999 respectively
                uint16 previousRateValue = 0;
                uint16 itemRoll          = xirand::GetRandomNumber(total);
                for (const DropItem_t& item : group.Items)
                {
                    if (itemRoll < previousRateValue + item.DropRate)
                    {
                        AddItemToPool(item.ItemID);

                        break;
                    }
                    previousRateValue += item.DropRate;
                }
            }
        });

        // Ungrouped drops. This are affected by TH UNLESS they have an specified fixed rate.
        loot.ForEachItem([&](const DropItem_t& item)
        {
            uint16 itemDropRate = item.DropRate * 10;

            if (!item.hasFixedRate)
            {
                itemDropRate = thDropRateFunction(m_THLvl, itemDropRate);
            }

            if (itemDropRate > 0 && (1 + xirand::GetRandomNumber(10000)) <= itemDropRate * settings::get<float>("map.DROP_RATE_MULTIPLIER"))
            {
                AddItemToPool(item.ItemID);
            }
        });
        // clang-format on
    }

    ZONE_TYPE zoneType  = zoneutils::GetZone(PChar->getZone())->GetTypeMask();
    bool      validZone = !(this->m_Type & MOBTYPE_BATTLEFIELD) && !(zoneType & ZONE_TYPE::DYNAMIS);

    // Check if mob can drop seals -- mobmod to disable drops, zone type isnt battlefield/dynamis, mob is stronger than Too Weak, or mobmod for EXP bonus is -100 or lower (-100% exp)
    if (!getMobMod(MOBMOD_NO_DROPS) && validZone && charutils::CheckMob(m_HiPCLvl, this) > EMobDifficulty::TooWeak && getMobMod(MOBMOD_EXP_BONUS) > -100)
    {
        // Check for seal drops
        // Only one type of seal can drop per mob
        if (xirand::GetRandomNumber(100) < 20 && CanAddSpecial(LootRecastID::Seal))
        {
            const auto seals = GetEligibleSeals();
            AddItemToPool(seals[xirand::GetRandomNumber(seals.size())]);
            AddSpecialRecast(LootRecastID::Seal);
        }

        // Check for geode/avatarites drops
        // Only one type of geode can drop per mob
        if (xirand::GetRandomNumber(100) < 20 && CanAddSpecial(LootRecastID::Geode))
        {
            if (const auto geodes = GetEligibleGeodes(); !geodes.empty())
            {
                AddItemToPool(geodes[xirand::GetRandomNumber(geodes.size())]);
                AddSpecialRecast(LootRecastID::Geode);
            }
        }

        if (xirand::GetRandomNumber(100) < COSMETIC_DROP_CHANCE)
        {
            if (const auto cosmeticItemId = PickPartyWeightedCosmeticItem(PChar); cosmeticItemId != 0)
            {
                AddItemToPool(cosmeticItemId);
            }
        }

        // Begin Adding Crystals
        if (m_Element > 0)
        {
            REGION_TYPE regionID       = PChar->loc.zone->GetRegionID();
            EFFECT      requiredEffect = EFFECT_NONE;

            switch (regionID)
            {
                // Sanction Regions
                case REGION_TYPE::WEST_AHT_URHGAN:
                case REGION_TYPE::MAMOOL_JA_SAVAGE:
                case REGION_TYPE::HALVUNG:
                case REGION_TYPE::ARRAPAGO:
                case REGION_TYPE::ALZADAAL:
                    requiredEffect = EFFECT_SANCTION;
                    break;

                // Sigil Regions
                case REGION_TYPE::RONFAURE_FRONT:
                case REGION_TYPE::NORVALLEN_FRONT:
                case REGION_TYPE::GUSTABERG_FRONT:
                case REGION_TYPE::DERFLAND_FRONT:
                case REGION_TYPE::SARUTA_FRONT:
                case REGION_TYPE::ARAGONEAU_FRONT:
                case REGION_TYPE::FAUREGANDI_FRONT:
                case REGION_TYPE::VALDEAUNIA_FRONT:
                    requiredEffect = EFFECT_SIGIL;
                    break;

                // Ionis Regions
                case REGION_TYPE::ADOULIN_ISLANDS:
                case REGION_TYPE::EAST_ULBUKA:
                    requiredEffect = EFFECT_IONIS;
                    break;

                // Signet Regions
                default:
                    if (regionID < REGION_TYPE::TAVNAZIA && conquest::GetRegionOwner(regionID) <= 2)
                    {
                        requiredEffect = EFFECT_SIGNET;
                    }
                    break;
            }

            if (requiredEffect == EFFECT_NONE)
            {
                return;
            }

            uint8 playersNearby = 0;
            // clang-format off
            PChar->ForParty([this, &playersNearby, requiredEffect](CBattleEntity* PMember)
            {
                if (PMember->StatusEffectContainer->HasStatusEffect(requiredEffect) &&
                    PMember->getZone() == getZone() &&
                    distance(PMember->loc.p, loc.p) < 100)
                {
                    playersNearby++;
                }
            });
            // clang-format on

            if (playersNearby == 0)
            {
                return;
            }

            // Signet regions: 55% if solo, 45% if in a party
            // Sanction regions: 30%
            // Others leave at 20% - TODO: need more info on WOTG+
            uint8 crystalRate = 20;
            if (requiredEffect == EFFECT_SIGNET)
            {
                crystalRate = (playersNearby == 1) ? 55 : 45;
            }
            else if (requiredEffect == EFFECT_SANCTION)
            {
                crystalRate = 30;
            }

            for (uint8 i = 0; i < playersNearby; i++)
            {
                if (xirand::GetRandomNumber(100) < crystalRate)
                {
                    AddItemToPool(4095 + m_Element);
                }
            }
        }
    }
}

bool CMobEntity::CanAttack(CBattleEntity* PTarget, std::unique_ptr<CBasicPacket>& errMsg)
{
    TracyZoneScoped;
    auto skill_list_id{ getMobMod(MOBMOD_ATTACK_SKILL_LIST) };
    if (skill_list_id)
    {
        auto attack_range{ GetMeleeRange(PTarget) };
        auto skillList{ battleutils::GetMobSkillList(skill_list_id) };

        if (!skillList.empty())
        {
            auto* skill{ battleutils::GetMobSkill(skillList.front()) };
            if (skill)
            {
                attack_range = modelHitboxSize + skill->getDistance() + PTarget->modelHitboxSize;
            }
        }

        bool  autoAttackEnabled  = PAI->GetController()->IsAutoAttackEnabled();
        float distanceFromTarget = distance(loc.p, PTarget->loc.p);
        bool  tooFar             = distanceFromTarget > attack_range;

        return !tooFar && autoAttackEnabled;
    }
    else
    {
        return CBattleEntity::CanAttack(PTarget, errMsg);
    }
}

void CMobEntity::OnEngage(CAttackState& state)
{
    TracyZoneScoped;
    CBattleEntity::OnEngage(state);
    luautils::OnMobEngage(this, state.GetTarget());
    unsigned int range = this->getMobMod(MOBMOD_ALLI_HATE);
    if (range != 0)
    {
        CBaseEntity* PTarget = state.GetTarget();
        CBaseEntity* PPet    = nullptr;
        if (PTarget->objtype == TYPE_PET)
        {
            PPet    = state.GetTarget();
            PTarget = ((CPetEntity*)PTarget)->PMaster;
        }

        // TODO: Supertanking might be effected by this block when we don't want it to be.
        // Things like Ambuscade "don't have" supertanking, though.
        // This block apparently only effects rare things like NW apollyon, so might be ok for now.
        if (PTarget->objtype == TYPE_PC)
        {
            // clang-format off
            ((CCharEntity*)PTarget)->ForAlliance([this, PTarget, range](CBattleEntity* PMember)
            {
                auto currentDistance = distance(PMember->loc.p, PTarget->loc.p);
                if (currentDistance < range)
                {
                    this->PEnmityContainer->AddBaseEnmity(PMember);
                }
            });
            // clang-format on

            this->PEnmityContainer->UpdateEnmity((PPet ? (CBattleEntity*)PPet : (CBattleEntity*)PTarget), 0, 1); // Set VE so target doesn't change
        }
    }
    TapDeaggroTime();
}

void CMobEntity::FadeOut()
{
    TracyZoneScoped;
    CBaseEntity::FadeOut();
    PEnmityContainer->Clear();
}

void CMobEntity::OnDeathTimer()
{
    TracyZoneScoped;
    if (!(m_Behavior & BEHAVIOR_RAISABLE))
    {
        PAI->Despawn();
    }
}

void CMobEntity::OnDespawn(CDespawnState& /*unused*/)
{
    TracyZoneScoped;
    FadeOut();

    luautils::OnMobDespawn(this);
    PAI->EventHandler.triggerListener("DESPAWN", this);
}

timer::duration CMobEntity::GetCampHeatAdjustedRespawnTime()
{
    return computeCampHeatRespawn(this);
}

void CMobEntity::Die()
{
    TracyZoneScoped;

    if (PBattlefield != nullptr)
    {
        PBattlefield->handleDeath(this);
    }

    PEnmityContainer->Clear();
    PAI->ClearStateStack();
    if (PPet != nullptr && PPet->isAlive() && GetMJob() == JOB_SMN)
    {
        PPet->Die();
    }
    PAI->Internal_Die(15s);
    CBattleEntity::Die();

    // clang-format off
    PAI->QueueAction(queueAction_t(m_DropItemTime, false, [this](CBaseEntity* PEntity)
    {
        if (static_cast<CMobEntity*>(PEntity)->isDead())
        {
            if (auto* PLastAttacker = GetEntity(lastAttackerId_.targid); PLastAttacker && PLastAttacker->id == lastAttackerId_.id)
            {
                loc.zone->PushPacket(this, CHAR_INRANGE, std::make_unique<GP_SERV_COMMAND_BATTLE_MESSAGE>(PLastAttacker, this, 0, 0, MsgBasic::DefeatsTarget));
            }
            else
            {
                loc.zone->PushPacket(this, CHAR_INRANGE, std::make_unique<GP_SERV_COMMAND_BATTLE_MESSAGE>(this, this, 0, 0, MsgBasic::FallsToGround));
            }

            DistributeRewards();
            m_OwnerID.clean();

            m_THLvl          = 0;
            m_GilfinderLevel = 0;
        }
    }));
    // clang-format on

    if (PMaster && PMaster->PPet == this && PMaster->objtype == TYPE_PC)
    {
        petutils::DetachPet(PMaster);
    }
}

void CMobEntity::OnDisengage(CAttackState& state)
{
    TracyZoneScoped;
    PAI->PathFind->Clear();
    PEnmityContainer->Clear();

    if (getMobMod(MOBMOD_IDLE_DESPAWN))
    {
        SetDespawnTime(std::chrono::seconds(getMobMod(MOBMOD_IDLE_DESPAWN)));
    }
    // this will let me decide to walk home or despawn
    m_neutral = true;

    m_OwnerID.clean();

    CBattleEntity::OnDisengage(state);

    luautils::OnMobDisengage(this);
}

void CMobEntity::OnCastFinished(CMagicState& state, action_t& action)
{
    TracyZoneScoped;
    CBattleEntity::OnCastFinished(state, action);

    CMobController* mobController = dynamic_cast<CMobController*>(PAI->GetController());
    if (mobController)
    {
        mobController->OnCastStopped(state, action);
    }

    TapDeaggroTime();
}

void CMobEntity::OnCastInterrupted(CMagicState& state, action_t& action, MsgBasic msg, bool blockedCast)
{
    TracyZoneScoped;
    CBattleEntity::OnCastInterrupted(state, action, msg, blockedCast);

    CMobController* mobController = dynamic_cast<CMobController*>(PAI->GetController());
    if (mobController)
    {
        mobController->OnCastStopped(state, action);
    }
}

bool CMobEntity::OnAttack(CAttackState& state, action_t& action)
{
    TracyZoneScoped;
    TapDeaggroTime();

    if (getMobMod(MOBMOD_ATTACK_SKILL_LIST))
    {
        return static_cast<CMobController*>(PAI->GetController())->MobSkill(getMobMod(MOBMOD_ATTACK_SKILL_LIST));
    }
    else
    {
        return CBattleEntity::OnAttack(state, action);
    }
}

bool CMobEntity::isWideScannable()
{
    return CBaseEntity::isWideScannable() && !getMobMod(MOBMOD_NO_WIDESCAN);
}
