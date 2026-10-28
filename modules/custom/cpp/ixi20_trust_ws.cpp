/************************************************************************
 * Imagine XI 2.0: level 2+ trust weaponskills open at 23, not 60.
 *
 * Stock trustutils keeps player weaponskills that skillchain at
 * Gravitation or higher until level 60. The 37-cap curve puts that
 * gate at 23 (1 + round((60 - 1) * 36 / 98)). Called from ixi20_trusts
 * after a trust spawns. Skills already queued are left alone, so a
 * trust at 60+ is not given a second copy.
 *
 * Trusts whose stock skill list is empty get a job kit here as well,
 * so they can spend TP before the paired SQL is applied.
 *
 * Rebuild xi_map after adding or removing this module.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/lua.h"

#include "map/ai/ai_container.h"
#include "map/ai/controllers/trust_controller.h"
#include "map/ai/helpers/gambits_container.h"
#include "map/entities/battle_entity.h"
#include "map/entities/trust_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/mobskill.h"
#include "map/utils/battleutils.h"
#include "map/weapon_skill.h"

#include <iterator>
#include <vector>

namespace
{

constexpr uint8 kOpenLevel = 23;
constexpr uint8 kStockLevel = 60;

auto alreadyQueued(const std::vector<gambits::TrustSkill_t>& skills, uint32 skillId) -> bool
{
    for (const auto& skill : skills)
    {
        if (skill.skill_id == skillId)
        {
            return true;
        }
    }

    return false;
}

auto formsLevelTwoOrHigher(uint8 primary, uint8 secondary, uint8 tertiary) -> bool
{
    const auto gate = static_cast<uint8>(SC_GRAVITATION);
    return primary >= gate || secondary >= gate || tertiary >= gate;
}

void unlockLevelTwoWeaponskills(CTrustEntity* PTrust)
{
    if (PTrust == nullptr || PTrust->PAI == nullptr)
    {
        return;
    }

    const auto level = PTrust->GetMLevel();
    if (level < kOpenLevel || level >= kStockLevel)
    {
        return;
    }

    auto* controller = dynamic_cast<CTrustController*>(PTrust->PAI->GetController());
    if (controller == nullptr || controller->m_GambitsContainer == nullptr)
    {
        return;
    }

    auto& skills = controller->m_GambitsContainer->tp_skills;

    for (const uint16 skillId : battleutils::GetMobSkillList(PTrust->m_MobSkillList))
    {
        if (skillId > 255 || alreadyQueued(skills, skillId))
        {
            continue;
        }

        CWeaponSkill* PWeaponSkill = battleutils::GetWeaponSkill(skillId);
        if (PWeaponSkill == nullptr)
        {
            continue;
        }

        const auto primary   = PWeaponSkill->getPrimarySkillchain();
        const auto secondary = PWeaponSkill->getSecondarySkillchain();
        const auto tertiary  = PWeaponSkill->getTertiarySkillchain();
        if (!formsLevelTwoOrHigher(primary, secondary, tertiary))
        {
            continue;
        }

        skills.emplace_back(
            gambits::G_REACTION::WS,
            skillId,
            primary,
            secondary,
            tertiary,
            battleutils::isValidSelfTargetWeaponskill(skillId) ? TARGET_SELF : TARGET_ENEMY);
    }
}

void queueTrustSkill(std::vector<gambits::TrustSkill_t>& skills, uint16 skillId)
{
    if (alreadyQueued(skills, skillId))
    {
        return;
    }

    if (skillId <= 255)
    {
        CWeaponSkill* PWeaponSkill = battleutils::GetWeaponSkill(skillId);
        if (PWeaponSkill == nullptr)
        {
            return;
        }

        skills.emplace_back(
            gambits::G_REACTION::WS,
            skillId,
            PWeaponSkill->getPrimarySkillchain(),
            PWeaponSkill->getSecondarySkillchain(),
            PWeaponSkill->getTertiarySkillchain(),
            battleutils::isValidSelfTargetWeaponskill(skillId) ? TARGET_SELF : TARGET_ENEMY);
        return;
    }

    CMobSkill* PMobSkill = battleutils::GetMobSkill(skillId);
    if (PMobSkill == nullptr)
    {
        return;
    }

    skills.emplace_back(
        gambits::G_REACTION::MS,
        skillId,
        PMobSkill->getPrimarySkillchain(),
        PMobSkill->getSecondarySkillchain(),
        PMobSkill->getTertiarySkillchain(),
        static_cast<TARGETTYPE>(PMobSkill->getValidTargets()));
}

// Job kit for trusts whose stock skill list is an empty placeholder.
// Passive bubbles are not listed. Skills already on the list are skipped.
auto missingTrustKit(uint32 trustId) -> std::vector<uint16>
{
    switch (trustId)
    {
        case 896: return { 178, 180, 189 };                         // Shantotto
        case 904: return { 178, 180, 183, 184, 189, 191 };          // Ajido-Marujido
        case 906: return { 51, 56, 3195, 3196 };                    // Zeid
        case 911: return { 40, 42 };                                // Joachim
        case 914: return { 40, 42 };                                // Ulmia
        case 916: return { 166, 168 };                              // Cherukiki
        case 919: return { 178, 180, 189 };                         // Gadalar
        case 921: return { 166, 168 };                              // Ingrid
        case 924: return { 1, 7, 9 };                               // Zazarg
        case 925: return { 40, 42, 180 };                           // Ovjang
        case 928: return { 210, 212, 215 };                         // Luzaf
        case 929: return { 192, 196, 199 };                         // Najelith
        case 930: return { 1, 7, 9 };                               // Aldo
        case 934: return { 178, 180, 189 };                         // D. Shantotto
        case 937: return { 210, 212, 215 };                         // Cid
        case 938: return { 144, 150, 151, 152 };                    // Gilgamesh
        case 941: return { 192, 196, 199 };                         // Elivira
        case 942: return { 144, 150, 151, 152 };                    // Noillurie
        case 943: return { 64, 72 };                                // Lhu Mhakaracca
        case 945: return { 16, 23, 25 };                            // Lilisette
        case 948: return { 40, 42, 88 };                            // Klara
        case 949: return { 16, 23, 25 };                            // Romaa Mihgo
        case 952: return { 40, 42, 180 };                           // Koru-Moru
        case 953: return { 166, 168 };                              // Pieuje UC
        case 954: return { 40, 42, 88 };                            // Invincible Shield UC
        case 955: return { 166, 168 };                              // Apururu UC
        case 956: return { 16, 23, 25 };                            // Jakoh UC
        case 957: return { 112, 118, 120 };                         // Flaviria UC
        case 958: return { 1, 7, 9 };                               // Babban
        case 959: return { 1, 7, 9 };                               // Abenzio
        case 961: return { 178, 180, 189 };                         // Kukki-Chebukki
        case 962: return { 192, 196, 199 };                         // Margret
        case 963: return { 16, 23, 25 };                            // Chacharoon
        case 964: return { 1, 7, 9 };                               // Lhe Lhangavo
        case 965: return { 40, 42, 180 };                           // Arciela
        case 966: return { 16, 23, 25 };                            // Mayakov
        case 972: return { 33, 40, 42 };                            // Halver
        case 973: return { 40, 42, 88 };                            // Rongelouts
        case 974: return { 178, 180, 189 };                         // Leonoyne
        case 975: return { 16, 23, 25 };                            // Maximilian
        case 976: return { 178, 180, 189 };                         // Kayeel-Payeel
        case 977: return { 178, 180, 189 };                         // Robel-Akbel
        case 980: return { 166, 168 };                              // Yoran-Oran UC
        case 981: return { 178, 180, 189 };                         // Sylvie UC
        case 983: return { 96, 102, 103 };                          // Balamor
        case 985: return { 178, 180, 189 };                         // Rosulatia
        case 986: return { 178, 180, 189 };                         // Teodor
        case 987: return { 178, 180, 189 };                         // Ullegore
        case 988: return { 192, 196, 199 };                         // Makki-Chebukki
        case 989: return { 40, 42, 180 };                           // King of Hearts
        case 990: return { 64, 72 };                                // Morimar
        case 997: return { 144, 150, 151, 152 };                    // Iroha
        case 998: return { 166, 168 };                              // Ygnas
        case 999: return { 33, 40, 42 };                            // Monberaux
        case 1003: return { 128, 129, 133, 134, 138, 141 };         // Matsui-P
        case 1004: return { 40, 42, 88 };                           // Excenmille (S)
        case 1005: return { 144, 150, 151, 152 };                   // Ayame UC
        case 1007: return { 16, 23, 25 };                           // Aldo UC
        case 1008: return { 16, 23, 25 };                           // Naja UC
        case 1013: return { 16, 23, 25 };                           // Lilisette II
        case 1015: return { 178, 180, 189 };                        // Mumor II
        case 1016: return { 166, 168 };                             // Ingrid II
        case 1017: return { 40, 42, 180 };                          // Arciela II
        case 1018: return { 144, 150, 151, 152 };                   // Iroha II
        default: return {};
    }
}

void grantMissingTrustWeaponskills(CTrustEntity* PTrust)
{
    if (PTrust == nullptr || PTrust->PAI == nullptr)
    {
        return;
    }

    auto* controller = dynamic_cast<CTrustController*>(PTrust->PAI->GetController());
    if (controller == nullptr || controller->m_GambitsContainer == nullptr)
    {
        return;
    }

    auto& skills = controller->m_GambitsContainer->tp_skills;
    for (const uint16 skillId : missingTrustKit(PTrust->trustID()))
    {
        queueTrustSkill(skills, skillId);
    }
}

auto entityFromLua(lua_State* L, int index) -> CTrustEntity*
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

    return dynamic_cast<CTrustEntity*>(wrapper->GetBaseEntity());
}

auto luaIxi20TrustUnlockLv3Ws(lua_State* L) -> int
{
    auto* PTrust = entityFromLua(L, 1);
    grantMissingTrustWeaponskills(PTrust);
    unlockLevelTwoWeaponskills(PTrust);
    return 0;
}

} // namespace

class Ixi20TrustWsModule : public CPPModule
{
public:
    void OnInit() override
    {
        lua_State* L = lua.lua_state();
        if (L == nullptr)
        {
            ShowError("Imagine XI 2.0: trust weaponskill unlock skipped (lua state missing)");
            return;
        }

        lua_register(L, "Ixi20TrustUnlockLv3Ws", luaIxi20TrustUnlockLv3Ws);
        ShowInfo("Imagine XI 2.0: trust level-2 weaponskills open at 23");
    }
};

REGISTER_CPP_MODULE(Ixi20TrustWsModule);
