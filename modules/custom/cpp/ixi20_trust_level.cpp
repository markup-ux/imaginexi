/************************************************************************
 * Imagine XI 2.0: trusts already out level up with the player.
 *
 * Spawn sets a trust's level once. A later level-up left that trust
 * at the old level until it was recast. Ixi20TrustMatchMaster, called
 * from ixi20_trusts on level-up, sets each trust to the player's level
 * and rebuilds HP, MP, attributes, skills, traits, weapon damage, and
 * the spell list. TP and gambits stay. Combat mods are replaced, not
 * stacked.
 *
 * Rebuild xi_map after adding or removing this module.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/lua.h"
#include "common/settings.h"

#include "map/entities/char_entity.h"
#include "map/entities/trust_entity.h"
#include "map/grades.h"
#include "map/items/item_weapon.h"
#include "map/lua/lua_base_entity.h"
#include "map/mob_spell_container.h"
#include "map/mob_spell_list.h"
#include "map/party.h"
#include "map/trait.h"
#include "map/utils/battleutils.h"
#include "map/utils/mobutils.h"

#include "data/enums/skill_type.h"

#include <algorithm>
#include <cmath>

namespace
{

auto clampedMultiplier(const char* key) -> float
{
    const float value = settings::get<float>(key);
    return (value >= 0.1f && value <= 2.0f) ? value : 1.0f;
}

auto rankedSkill(CTrustEntity* PTrust, uint8 rank) -> uint16
{
    if (rank < 1 || rank > 5)
    {
        return 0;
    }

    return mobutils::GetBaseSkill(PTrust, rank);
}

struct CombatMods
{
    uint16 def  = 0;
    uint16 eva  = 0;
    uint16 att  = 0;
    uint16 acc  = 0;
    uint16 meva = 0;
};

auto captureCombatMods(CTrustEntity* PTrust) -> CombatMods
{
    CombatMods mods;
    mods.def  = rankedSkill(PTrust, PTrust->defRank);
    mods.eva  = rankedSkill(PTrust, PTrust->evaRank);
    mods.att  = rankedSkill(PTrust, PTrust->attRank);
    mods.acc  = rankedSkill(PTrust, PTrust->accRank);
    mods.meva = mobutils::GetMagicEvasion(PTrust);
    return mods;
}

void replaceMod(CTrustEntity* PTrust, xi::Mod mod, uint16 oldValue, uint16 newValue)
{
    if (oldValue != 0)
    {
        PTrust->delModifier(mod, static_cast<int16>(oldValue));
    }

    if (newValue != 0)
    {
        PTrust->addModifier(mod, static_cast<int16>(newValue));
    }
}

void applyCombatMods(CTrustEntity* PTrust, const CombatMods& oldMods, const CombatMods& newMods)
{
    replaceMod(PTrust, xi::Mod::DEF, oldMods.def, newMods.def);
    replaceMod(PTrust, xi::Mod::EVA, oldMods.eva, newMods.eva);
    replaceMod(PTrust, xi::Mod::ATT, oldMods.att, newMods.att);
    replaceMod(PTrust, xi::Mod::ACC, oldMods.acc, newMods.acc);
    replaceMod(PTrust, xi::Mod::RATT, oldMods.att, newMods.att);
    replaceMod(PTrust, xi::Mod::RACC, oldMods.acc, newMods.acc);
    replaceMod(PTrust, xi::Mod::MEVA, oldMods.meva, newMods.meva);
}

void scaleWeapon(CItemWeapon* weapon, uint16 oldBase, uint16 newBase)
{
    if (weapon == nullptr || weapon->getDamage() == 0 || oldBase == 0)
    {
        return;
    }

    const auto scaled = static_cast<uint16>(std::max(
        1.0,
        std::round(static_cast<double>(weapon->getDamage()) * static_cast<double>(newBase) / static_cast<double>(oldBase))));
    weapon->setDamage(scaled);

    if (weapon->getDelay() > 0)
    {
        weapon->setDPS(static_cast<double>(scaled) / (static_cast<double>(weapon->getDelay()) / 1000.0));
    }
}

void scaleWeapons(CTrustEntity* PTrust, uint16 oldBase, uint16 newBase)
{
    scaleWeapon(dynamic_cast<CItemWeapon*>(PTrust->m_Weapons[SLOT_MAIN]), oldBase, newBase);
    scaleWeapon(dynamic_cast<CItemWeapon*>(PTrust->m_Weapons[SLOT_SUB]), oldBase, newBase);
    scaleWeapon(dynamic_cast<CItemWeapon*>(PTrust->m_Weapons[SLOT_RANGED]), oldBase, newBase);
    scaleWeapon(dynamic_cast<CItemWeapon*>(PTrust->m_Weapons[SLOT_AMMO]), oldBase, newBase);
}

// Same HP / MP / attribute / skill block as trustutils::LoadTrustStatsAndSkills.
// Called after the new level is set. Does not touch gambits, TP, or pool mods.
void rebuildTrustStats(CTrustEntity* PTrust)
{
    const xi::Job mJob = PTrust->GetMJob();
    const xi::Job sJob = PTrust->GetSJob();
    const uint8   mLvl = PTrust->GetMLevel();
    const uint8   sLvl = PTrust->GetSLevel();

    auto mapRanges = [](unsigned int inputStart, unsigned int inputEnd, unsigned int outputStart, unsigned int outputEnd, unsigned int inputVal) -> unsigned int
    {
        const unsigned int inputRange  = inputEnd - inputStart;
        const unsigned int outputRange = outputEnd - outputStart;
        const unsigned int output      = (inputVal - inputStart) * outputRange / inputRange + outputStart;
        return std::clamp(output, outputStart, outputEnd);
    };

    auto scaleToGrade = [&mapRanges](float input) -> unsigned int
    {
        const unsigned int multipliedInput    = static_cast<unsigned int>(input * 100U);
        const unsigned int reverseMappedGrade = mapRanges(70U, 140U, 1U, 7U, multipliedInput);
        return std::clamp(7U - reverseMappedGrade, 1U, 7U);
    };

    const int32 baseValueColumn   = 0;
    const int32 scaleTo60Column   = 1;
    const int32 scaleOver30Column = 2;
    const int32 scaleOver60Column = 3;
    const int32 scaleOver75Column = 4;
    const int32 scaleOver60       = 2;

    const int32 mainLevelOver30         = std::clamp(mLvl - 30, 0, 30);
    const int32 mainLevelUpTo60         = (mLvl < 60 ? mLvl - 1 : 59);
    const int32 mainLevelOver60To75     = std::clamp(mLvl - 60, 0, 15);
    const int32 mainLevelOver75         = (mLvl < 75 ? 0 : mLvl - 75);
    const int32 mainLevelOver10         = (mLvl < 10 ? 0 : mLvl - 10);
    const int32 mainLevelOver50andUnder60 = std::clamp(mLvl - 50, 0, 10);
    const int32 mainLevelOver60         = (mLvl < 60 ? 0 : mLvl - 60);
    const int32 subLevelOver10          = std::clamp(sLvl - 10, 0, 20);
    const int32 subLevelOver30          = (sLvl < 30 ? 0 : sLvl - 30);

    float raceStat  = 0;
    float jobStat   = 0;
    float sJobStat  = 0;
    int32 bonusStat = 0;

    uint8 grade = scaleToGrade(PTrust->HPscale);

    raceStat = grade::GetHPScale(grade, baseValueColumn) + (grade::GetHPScale(grade, scaleTo60Column) * mainLevelUpTo60) +
               (grade::GetHPScale(grade, scaleOver30Column) * mainLevelOver30) + (grade::GetHPScale(grade, scaleOver60Column) * mainLevelOver60To75) +
               (grade::GetHPScale(grade, scaleOver75Column) * mainLevelOver75);

    grade = grade::GetJobGrade(mJob, 0);

    jobStat = grade::GetHPScale(grade, baseValueColumn) + (grade::GetHPScale(grade, scaleTo60Column) * mainLevelUpTo60) +
              (grade::GetHPScale(grade, scaleOver30Column) * mainLevelOver30) + (grade::GetHPScale(grade, scaleOver60Column) * mainLevelOver60To75) +
              (grade::GetHPScale(grade, scaleOver75Column) * mainLevelOver75);

    bonusStat = (mainLevelOver10 + mainLevelOver50andUnder60) * 2;

    if (sLvl > 0)
    {
        grade = grade::GetJobGrade(sJob, 0);

        sJobStat = grade::GetHPScale(grade, baseValueColumn) + (grade::GetHPScale(grade, scaleTo60Column) * (sLvl - 1)) +
                   (grade::GetHPScale(grade, scaleOver30Column) * subLevelOver30) + subLevelOver30 + subLevelOver10;
    }

    PTrust->health.maxhp = static_cast<int16>((raceStat + jobStat + bonusStat + sJobStat) * clampedMultiplier("map.ALTER_EGO_HP_MULTIPLIER"));

    raceStat = 0;
    jobStat  = 0;
    sJobStat = 0;

    grade = scaleToGrade(PTrust->MPscale);

    if (grade::GetJobGrade(mJob, 1) == 0)
    {
        if (grade::GetJobGrade(sJob, 1) != 0 && sLvl > 0)
        {
            raceStat = (grade::GetMPScale(grade, 0) + grade::GetMPScale(grade, scaleTo60Column) * (sLvl - 1)) / settings::get<uint8>("map.SJ_MP_DIVISOR");
        }
    }
    else
    {
        raceStat = grade::GetMPScale(grade, 0) + grade::GetMPScale(grade, scaleTo60Column) * mainLevelUpTo60 +
                   grade::GetMPScale(grade, scaleOver60) * mainLevelOver60;
    }

    grade = grade::GetJobGrade(mJob, 1);

    if (grade > 0)
    {
        jobStat = grade::GetMPScale(grade, 0) + grade::GetMPScale(grade, scaleTo60Column) * mainLevelUpTo60 +
                  grade::GetMPScale(grade, scaleOver60) * mainLevelOver60;
    }

    if (sLvl > 0)
    {
        grade    = grade::GetJobGrade(sJob, 1);
        sJobStat = grade::GetMPScale(grade, 0) + grade::GetMPScale(grade, scaleTo60Column);
    }

    PTrust->health.maxmp = static_cast<int16>((raceStat + jobStat + sJobStat) * clampedMultiplier("map.ALTER_EGO_MP_MULTIPLIER"));

    uint16 fSTR = mobutils::GetBaseToRank(PTrust->strRank, mLvl);
    uint16 fDEX = mobutils::GetBaseToRank(PTrust->dexRank, mLvl);
    uint16 fVIT = mobutils::GetBaseToRank(PTrust->vitRank, mLvl);
    uint16 fAGI = mobutils::GetBaseToRank(PTrust->agiRank, mLvl);
    uint16 fINT = mobutils::GetBaseToRank(PTrust->intRank, mLvl);
    uint16 fMND = mobutils::GetBaseToRank(PTrust->mndRank, mLvl);
    uint16 fCHR = mobutils::GetBaseToRank(PTrust->chrRank, mLvl);

    uint16 mSTR = mobutils::GetBaseToRank(grade::GetJobGrade(mJob, 2), mLvl);
    uint16 mDEX = mobutils::GetBaseToRank(grade::GetJobGrade(mJob, 3), mLvl);
    uint16 mVIT = mobutils::GetBaseToRank(grade::GetJobGrade(mJob, 4), mLvl);
    uint16 mAGI = mobutils::GetBaseToRank(grade::GetJobGrade(mJob, 5), mLvl);
    uint16 mINT = mobutils::GetBaseToRank(grade::GetJobGrade(mJob, 6), mLvl);
    uint16 mMND = mobutils::GetBaseToRank(grade::GetJobGrade(mJob, 7), mLvl);
    uint16 mCHR = mobutils::GetBaseToRank(grade::GetJobGrade(mJob, 8), mLvl);

    uint16 sSTR = mobutils::GetBaseToRank(grade::GetJobGrade(sJob, 2), sLvl);
    uint16 sDEX = mobutils::GetBaseToRank(grade::GetJobGrade(sJob, 3), sLvl);
    uint16 sVIT = mobutils::GetBaseToRank(grade::GetJobGrade(sJob, 4), sLvl);
    uint16 sAGI = mobutils::GetBaseToRank(grade::GetJobGrade(sJob, 5), sLvl);
    uint16 sINT = mobutils::GetBaseToRank(grade::GetJobGrade(sJob, 6), sLvl);
    uint16 sMND = mobutils::GetBaseToRank(grade::GetJobGrade(sJob, 7), sLvl);
    uint16 sCHR = mobutils::GetBaseToRank(grade::GetJobGrade(sJob, 8), sLvl);

    if (sLvl > 15)
    {
        sSTR /= 2;
        sDEX /= 2;
        sAGI /= 2;
        sINT /= 2;
        sMND /= 2;
        sCHR /= 2;
        sVIT /= 2;
    }
    else
    {
        sSTR = 0;
        sDEX = 0;
        sAGI = 0;
        sINT = 0;
        sMND = 0;
        sCHR = 0;
        sVIT = 0;
    }

    const float statMultiplier = clampedMultiplier("map.ALTER_EGO_STAT_MULTIPLIER");
    PTrust->stats.STR = static_cast<uint16>((fSTR + mSTR + sSTR) * statMultiplier);
    PTrust->stats.DEX = static_cast<uint16>((fDEX + mDEX + sDEX) * statMultiplier);
    PTrust->stats.VIT = static_cast<uint16>((fVIT + mVIT + sVIT) * statMultiplier);
    PTrust->stats.AGI = static_cast<uint16>((fAGI + mAGI + sAGI) * statMultiplier);
    PTrust->stats.INT = static_cast<uint16>((fINT + mINT + sINT) * statMultiplier);
    PTrust->stats.MND = static_cast<uint16>((fMND + mMND + sMND) * statMultiplier);
    PTrust->stats.CHR = static_cast<uint16>((fCHR + mCHR + sCHR) * statMultiplier);

    const float skillMultiplier = settings::get<float>("map.ALTER_EGO_SKILL_MULTIPLIER");
    const uint8 skillLevel      = mLvl > 99 ? 99 : mLvl;

    for (int i = static_cast<int>(xi::SkillType::DivineMagic); i <= static_cast<int>(xi::SkillType::BlueMagic); i++)
    {
        uint16 maxSkill = battleutils::GetMaxSkill(static_cast<xi::SkillType>(i), mJob, skillLevel);
        if (maxSkill != 0)
        {
            PTrust->WorkingSkills.skill[i] = static_cast<uint16>(maxSkill * skillMultiplier);
        }
        else
        {
            uint16 maxSubSkill = battleutils::GetMaxSkill(static_cast<xi::SkillType>(i), sJob, skillLevel);
            if (maxSubSkill != 0)
            {
                PTrust->WorkingSkills.skill[i] = static_cast<uint16>(maxSubSkill * skillMultiplier);
            }
        }
    }

    for (int i = static_cast<int>(xi::SkillType::HandToHand); i <= static_cast<int>(xi::SkillType::Staff); i++)
    {
        uint16 maxSkill = battleutils::GetMaxSkill(static_cast<uint8>(i), skillLevel);
        if (maxSkill != 0)
        {
            PTrust->WorkingSkills.skill[i] = static_cast<uint16>(maxSkill * skillMultiplier);
        }
    }

    if (auto* traits = traits::GetTraits(mJob))
    {
        battleutils::AddTraits(PTrust, traits, mLvl);
    }

    if (auto* traits = traits::GetTraits(sJob))
    {
        battleutils::AddTraits(PTrust, traits, sLvl);
    }

    if (PTrust->m_SpellListContainer != nullptr && PTrust->SpellContainer != nullptr)
    {
        PTrust->SpellContainer->ClearSpells();
        for (const auto& spell : PTrust->m_SpellListContainer->m_spellList)
        {
            if (mLvl >= spell.min_level && mLvl <= spell.max_level)
            {
                PTrust->SpellContainer->AddSpell(spell.spellId);
            }
        }
    }

    PTrust->UpdateHealth();
    PTrust->health.hp = PTrust->GetMaxHP();
    PTrust->health.mp = PTrust->GetMaxMP();
    PTrust->updatemask |= UPDATE_HP;
}

void matchTrust(CTrustEntity* PTrust, uint8 masterLevel)
{
    if (PTrust == nullptr || masterLevel == 0 || PTrust->GetMLevel() == masterLevel)
    {
        return;
    }

    const CombatMods oldMods = captureCombatMods(PTrust);
    const uint16     oldBase = std::max<uint16>(1, mobutils::GetBaseWeaponDamage(PTrust, SLOT_MAIN));

    PTrust->SetMLevel(masterLevel);
    PTrust->SetSLevel(static_cast<uint8>(masterLevel / 2));

    const CombatMods newMods = captureCombatMods(PTrust);
    applyCombatMods(PTrust, oldMods, newMods);
    scaleWeapons(PTrust, oldBase, std::max<uint16>(1, mobutils::GetBaseWeaponDamage(PTrust, SLOT_MAIN)));
    rebuildTrustStats(PTrust);
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

auto luaIxi20TrustMatchMaster(lua_State* L) -> int
{
    auto* PChar = entityFromLua(L, 1);
    if (PChar == nullptr)
    {
        return 0;
    }

    const uint8 level = PChar->GetMLevel();
    for (auto* PTrust : PChar->PTrusts)
    {
        matchTrust(PTrust, level);
    }

    if (PChar->PParty != nullptr)
    {
        PChar->PParty->ReloadParty();
    }

    return 0;
}

} // namespace

class Ixi20TrustLevelModule : public CPPModule
{
public:
    void OnInit() override
    {
        lua_State* L = lua.lua_state();
        if (L == nullptr)
        {
            ShowError("Imagine XI 2.0: trust level match skipped (lua state missing)");
            return;
        }

        lua_register(L, "Ixi20TrustMatchMaster", luaIxi20TrustMatchMaster);
        ShowInfo("Imagine XI 2.0: trusts level up with the player");
    }
};

REGISTER_CPP_MODULE(Ixi20TrustLevelModule);
