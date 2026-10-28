/************************************************************************
 * Imagine XI 2.0: caster kit (module only).
 *
 * - Damaging elemental / divine / ninjutsu magic opens a level-1
 *   Immanence window when the target has none. A later nuke whose
 *   property chains (Blizzard -> Thunder = Impaction, and level 3
 *   Light / Darkness when the properties qualify) continues that
 *   window and prints the chain. Magic does not wait out the
 *   weaponskill 3s delay. A nuke that does not chain leaves the
 *   window up so other mages can still magic burst it. SCH helix
 *   opens and closes still stretch the window.
 * - Toggled-on Accession does not double MP or recast.
 * - Accession and Manifestation cost 0 charges (Lua toggles).
 *
 * Pair with ixi20_caster_kit.lua / .sql. Rebuild xi_map.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/lua.h"
#include "common/timer.h"
#include "common/xirand.h"

#include "map/ability.h"
#include "map/action/action.h"
#include "map/ai/states/magic_state.h"
#include "map/entities/battle_entity.h"
#include "map/entities/char_entity.h"
#include "map/lua/lua_action.h"
#include "map/lua/lua_base_entity.h"
#include "map/lua/lua_spell.h"
#include "map/modifier.h"
#include "map/spell.h"
#include "map/status_effect.h"
#include "map/status_effect_container.h"
#include "map/utils/battleutils.h"
#include "map/utils/zoneutils.h"

#include "data/enums/job.h"
#include "data/enums/status_effect.h"

#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <Windows.h>

#include <algorithm>
#include <cstring>
#include <list>

namespace
{

auto installJump(void* target, const void* dest) -> bool
{
    auto* bytes = static_cast<uint8*>(target);
    if (bytes == nullptr || dest == nullptr)
    {
        return false;
    }

    DWORD oldProtect = 0;
    if (VirtualProtect(bytes, 16, PAGE_EXECUTE_READWRITE, &oldProtect) == 0)
    {
        return false;
    }

    bytes[0]        = 0x48;
    bytes[1]        = 0xB8;
    const auto addr = reinterpret_cast<uint64>(dest);
    std::memcpy(bytes + 2, &addr, sizeof(addr));
    bytes[10] = 0xFF;
    bytes[11] = 0xE0;

    DWORD ignored = 0;
    VirtualProtect(bytes, 16, oldProtect, &ignored);
    FlushInstructionCache(GetCurrentProcess(), bytes, 16);
    return true;
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

auto spellFromLua(lua_State* L, int index) -> CSpell*
{
    if (!sol::stack::check<CLuaSpell*>(L, index))
    {
        return nullptr;
    }

    auto* wrapper = sol::stack::get<CLuaSpell*>(L, index);
    return wrapper != nullptr ? wrapper->GetSpell() : nullptr;
}

auto actionFromLua(lua_State* L, int index) -> action_t*
{
    if (!sol::stack::check<CLuaAction*>(L, index))
    {
        return nullptr;
    }

    auto* wrapper = sol::stack::get<CLuaAction*>(L, index);
    return wrapper != nullptr ? wrapper->GetAction() : nullptr;
}

auto isPermanentAccession(CBattleEntity* PEntity) -> bool
{
    if (PEntity == nullptr || PEntity->StatusEffectContainer == nullptr)
    {
        return false;
    }

    auto* effect = PEntity->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::Accession);
    return effect != nullptr && effect->GetDuration() == 0s;
}

auto propertyForElement(uint16 element) -> SKILLCHAIN_ELEMENT
{
    switch (element)
    {
        case ELEMENT_FIRE:
            return SC_LIQUEFACTION;
        case ELEMENT_ICE:
            return SC_INDURATION;
        case ELEMENT_WIND:
            return SC_DETONATION;
        case ELEMENT_EARTH:
            return SC_SCISSION;
        case ELEMENT_THUNDER:
            return SC_IMPACTION;
        case ELEMENT_WATER:
            return SC_REVERBERATION;
        case ELEMENT_LIGHT:
            return SC_TRANSFIXION;
        case ELEMENT_DARK:
            return SC_COMPRESSION;
        default:
            return SC_NONE;
    }
}

auto isHelixFamily(SPELLFAMILY family) -> bool
{
    switch (family)
    {
        case SPELLFAMILY_GEOHELIX:
        case SPELLFAMILY_HYDROHELIX:
        case SPELLFAMILY_ANEMOHELIX:
        case SPELLFAMILY_PYROHELIX:
        case SPELLFAMILY_CRYOHELIX:
        case SPELLFAMILY_IONOHELIX:
        case SPELLFAMILY_NOCTOHELIX:
        case SPELLFAMILY_LUMINOHELIX:
            return true;
        default:
            return false;
    }
}

auto isEnfeebleDotFamily(SPELLFAMILY family) -> bool
{
    switch (family)
    {
        case SPELLFAMILY_DIA:
        case SPELLFAMILY_DIAGA:
        case SPELLFAMILY_BIO:
        case SPELLFAMILY_ELE_DOT:
        case SPELLFAMILY_ABSORB:
        case SPELLFAMILY_DRAIN:
        case SPELLFAMILY_ASPIR:
            return true;
        default:
            return false;
    }
}

auto canCloseWithSpell(CSpell* PSpell) -> bool
{
    if (PSpell == nullptr || !PSpell->dealsDamage())
    {
        return false;
    }

    if (isEnfeebleDotFamily(PSpell->getSpellFamily()))
    {
        return false;
    }

    switch (PSpell->getSkillType())
    {
        case xi::SkillType::ElementalMagic:
        case xi::SkillType::DivineMagic:
        case xi::SkillType::Ninjutsu:
            return propertyForElement(PSpell->getElement()) != SC_NONE;
        default:
            return false;
    }
}

// Immanence's opener is stored as tier 0, and magic burst ignores tier 0.
// Rewrite that opener into the formed level-1 chain (Liquefaction, and so on)
// so the next matching spell bursts instead of waiting on skillchain damage.
auto promoteOpenerForMagicBurst(CBattleEntity* PDefender, SKILLCHAIN_ELEMENT incoming) -> void
{
    if (PDefender == nullptr || PDefender->StatusEffectContainer == nullptr || incoming == SC_NONE)
    {
        return;
    }

    auto* effect = PDefender->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::Skillchain, 0);
    if (effect == nullptr || effect->GetTier() != 0)
    {
        return;
    }

    effect->SetPower(static_cast<uint16>(incoming));
    effect->SetTier(battleutils::GetSkillchainTier(incoming));
    if (effect->GetSubPower() == 0)
    {
        effect->SetSubPower(1);
    }
}

// Open or continue a window the way Immanence does. Never adds skillchain damage.
auto applyImmanenceWindow(CBattleEntity* PDefender, SKILLCHAIN_ELEMENT incoming) -> void
{
    if (PDefender == nullptr || incoming == SC_NONE)
    {
        return;
    }

    battleutils::GetSkillChainEffect(PDefender, static_cast<uint8>(incoming), 0, 0);
    promoteOpenerForMagicBurst(PDefender, incoming);
}

// Continue an existing window. Weaponskills refuse a close for 3 seconds;
// Thunder is a 0.5s cast, so magic does not use that delay. A miss leaves
// the resonance alone instead of replacing it.
auto continueSkillchain(CBattleEntity* PDefender, SKILLCHAIN_ELEMENT incoming) -> ActionProcSkillChain
{
    if (PDefender == nullptr || PDefender->StatusEffectContainer == nullptr || incoming == SC_NONE)
    {
        return ActionProcSkillChain::None;
    }

    auto* effect = PDefender->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::Skillchain, 0);
    if (effect == nullptr)
    {
        return ActionProcSkillChain::None;
    }

    std::list<SKILLCHAIN_ELEMENT>       resonance;
    const std::list<SKILLCHAIN_ELEMENT> skill = { incoming, SC_NONE, SC_NONE };

    if (effect->GetTier() == 0)
    {
        const auto properties = effect->GetPower();
        if (properties == 0)
        {
            return ActionProcSkillChain::None;
        }

        resonance.emplace_back(static_cast<SKILLCHAIN_ELEMENT>(properties & 0xF));
        resonance.emplace_back(static_cast<SKILLCHAIN_ELEMENT>((properties >> 4) & 0xF));
        resonance.emplace_back(static_cast<SKILLCHAIN_ELEMENT>((properties >> 8) & 0xF));
    }
    else
    {
        resonance.emplace_back(static_cast<SKILLCHAIN_ELEMENT>(effect->GetPower()));
    }

    const auto formed = battleutils::FormSkillchain(resonance, skill);
    if (formed == SC_NONE)
    {
        return ActionProcSkillChain::None;
    }

    const auto remaining = effect->GetDuration() > 1s ? effect->GetDuration() - 1s : 1s;
    effect->SetStartTime(timer::now());
    effect->SetDuration(remaining);
    effect->SetTier(battleutils::GetSkillchainTier(formed));
    effect->SetPower(static_cast<uint16>(formed));
    effect->SetSubPower(static_cast<uint16>(std::min<int>(effect->GetSubPower() + 1, 5)));

    return battleutils::GetSkillchainSubeffect(formed);
}

auto luaIxi20TryMagicSkillchainClose(lua_State* L) -> int
{
    auto* PChar  = entityFromLua(L, 1);
    auto* PSpell = spellFromLua(L, 2);
    auto* action = actionFromLua(L, 3);
    int   closed = 0;

    if (PChar == nullptr || PSpell == nullptr || action == nullptr || !canCloseWithSpell(PSpell))
    {
        lua_pushinteger(L, 0);
        return 1;
    }

    const auto incoming = propertyForElement(PSpell->getElement());
    const bool helix    = isHelixFamily(PSpell->getSpellFamily());
    const bool scholar  = PChar->GetMJob() == xi::Job::SCH || PChar->GetSJob() == xi::Job::SCH;

    for (auto&& actionTarget : action->targets)
    {
        auto* PTarget = dynamic_cast<CBattleEntity*>(zoneutils::GetEntity(actionTarget.actorId));
        if (PTarget == nullptr || PTarget->health.hp <= 0)
        {
            continue;
        }

        for (auto&& result : actionTarget.results)
        {
            if (result.param <= 0)
            {
                continue;
            }

            const bool hadWindow = PTarget->StatusEffectContainer != nullptr &&
                                    PTarget->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::Skillchain, 0) != nullptr;
            auto changed = false;

            if (!hadWindow)
            {
                applyImmanenceWindow(PTarget, incoming);
                const auto opened = battleutils::GetSkillchainSubeffect(incoming);
                if (opened != ActionProcSkillChain::None)
                {
                    result.recordSkillchain(opened, battleutils::TakeSkillchainDamage(PChar, PTarget, result.param, nullptr));
                    ++closed;
                }
                changed = true;
            }
            else
            {
                const auto chain = continueSkillchain(PTarget, incoming);
                if (chain != ActionProcSkillChain::None)
                {
                    result.recordSkillchain(chain, battleutils::TakeSkillchainDamage(PChar, PTarget, result.param, nullptr));
                    ++closed;
                    changed = true;
                }
            }

            if (changed && scholar && helix)
            {
                if (auto* scEffect = PTarget->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::Skillchain, 0))
                {
                    scEffect->SetDuration(scEffect->GetDuration() + 2s);
                }
            }

            break;
        }
    }

    lua_pushinteger(L, closed);
    return 1;
}

uint16 hookedCalculateSpellCost(CBattleEntity* PEntity, CSpell* PSpell)
{
    if (PSpell == nullptr)
    {
        ShowWarning("battleutils::CalculateMPCost Spell is nullptr");
        return 0;
    }

    if (!PSpell->hasMPCost())
    {
        return 0;
    }

    bool   applyArts = true;
    uint16 base      = PSpell->getMPCost();
    if (PSpell->getID() == SpellID::Embrava || PSpell->getID() == SpellID::Kaustra)
    {
        base = static_cast<uint16>(PEntity->health.maxmp * 0.2);
    }

    int16 cost = base;

    if (PSpell->getSpellGroup() == SPELLGROUP_BLACK)
    {
        if (PSpell->getAOE() == SPELLAOE_RADIAL_MANI && PEntity->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::Manifestation))
        {
            cost *= 2;
            applyArts = false;
        }
        if (PEntity->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::Parsimony))
        {
            cost /= 2;
            applyArts = false;
        }
        else if (applyArts)
        {
            cost += static_cast<int16>(base * (PEntity->getMod(xi::Mod::BLACK_MAGIC_COST) / 100.0f));
        }
    }
    else if (PSpell->getSpellGroup() == SPELLGROUP_WHITE)
    {
        if (PSpell->getAOE() == SPELLAOE_RADIAL_ACCE &&
            PEntity->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::Accession) &&
            !isPermanentAccession(PEntity))
        {
            cost *= 2;
            applyArts = false;
        }
        if (PEntity->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::Penury))
        {
            cost /= 2;
            applyArts = false;
        }
        else if (applyArts)
        {
            cost += static_cast<int16>(base * (PEntity->getMod(xi::Mod::WHITE_MAGIC_COST) / 100.0f));
        }
    }

    const auto mpCostReduction = PEntity->getMod(xi::Mod::MP_COST_REDUCTION);
    if (mpCostReduction > 0)
    {
        cost = static_cast<int16>(cost * (1.f - static_cast<float>(mpCostReduction) / 100.f));
    }

    if (xirand::GetRandomNumber(100) < (PEntity->getMod(xi::Mod::NO_SPELL_MP_DEPLETION)))
    {
        cost = 0;
    }

    return std::clamp<int16>(cost, 0, 9999);
}

void zeroToggleChargeCost()
{
    if (auto* accession = ability::GetAbility(ABILITY_ACCESSION))
    {
        accession->setRecastTime(0s);
    }

    if (auto* manifestation = ability::GetAbility(ABILITY_MANIFESTATION))
    {
        manifestation->setRecastTime(0s);
    }
}

} // namespace

class Ixi20CasterKitModule : public CPPModule
{
public:
    void OnInit() override
    {
        lua_State* L = lua.lua_state();
        if (L != nullptr)
        {
            lua_register(L, "Ixi20TryMagicSkillchainClose", luaIxi20TryMagicSkillchainClose);
        }

        zeroToggleChargeCost();

        bool ok = true;
        if (!installJump(reinterpret_cast<void*>(&battleutils::CalculateSpellCost),
                         reinterpret_cast<const void*>(&hookedCalculateSpellCost)))
        {
            ShowError("Imagine XI 2.0: caster kit failed to patch spell cost");
            ok = false;
        }

        // Do not trampoline CMagicState::GetRecast. It returns timer::duration, so
        // MSVC x64 passes a hidden return slot in RCX; a free-function hook then
        // treats that slot as `this` and crashes in HasStatusEffect on every cast.

        if (ok)
        {
            ShowInfo("Imagine XI 2.0: caster kit loaded (magic prints the opener and the close; non-chains leave the burst window; Accession/Manifestation toggles)");
        }
    }
};

REGISTER_CPP_MODULE(Ixi20CasterKitModule);
