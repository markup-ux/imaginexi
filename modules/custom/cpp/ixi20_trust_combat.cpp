/************************************************************************
 * Imagine XI 2.0: trust combat and dancer haste (module only).
 *
 * - A trust with Chain Affinity skillchains blue magic the same way a
 *   player does. A permanent effect (duration 0) is not consumed and
 *   does not spend TP, so Darrcuiln's weaponskills still chain.
 * - A non-player bard honors MAXIMUM_SONGS_BONUS, so Joachim's extra
 *   song slots apply. Players keep the instrument check.
 * - Haste Samba Haste is its own delay bucket, capped at 25%, stacked
 *   on top of magic, ability, and gear haste, then the global delay cap.
 *
 * Rebuild xi_map. Comment this file out of init.txt to turn it off.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/settings.h"

#include "map/action/action.h"
#include "map/ai/states/magic_state.h"
#include "map/blue_spell.h"
#include "map/entities/battle_entity.h"
#include "map/entities/char_entity.h"
#include "map/entities/mob_entity.h"
#include "map/entities/trust_entity.h"
#include "map/items/item_weapon.h"
#include "map/lua/lua_base_entity.h"
#include "map/status_effect.h"
#include "map/status_effect_container.h"
#include "map/utils/battleutils.h"

#include "data/enums/mob_mod.h"
#include "data/enums/skill_type.h"
#include "data/enums/status_effect.h"

#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <Windows.h>

#include <algorithm>
#include <chrono>
#include <cstring>
#include <mutex>

namespace
{

constexpr size_t HookSize = 12;

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

// MSVC incremental builds sometimes point a member function at a 5-byte
// jmp thunk. Patching 12 bytes there would spill into the next thunk.
auto followThunk(uint8* code) -> uint8*
{
    if (code != nullptr && code[0] == 0xE9)
    {
        int32 relative = 0;
        std::memcpy(&relative, code + 1, sizeof(relative));
        auto* dest = code + 5 + relative;
        if (isExecutable(dest))
        {
            return dest;
        }
    }

    return code;
}

template <typename MemberFn>
auto memberAddress(MemberFn fn, const char* name) -> uint8*
{
    static_assert(sizeof(fn) >= sizeof(void*), "member pointer smaller than a code pointer");

    void* raw = nullptr;
    std::memcpy(&raw, &fn, sizeof(raw));
    if (!isExecutable(raw))
    {
        ShowError("Imagine XI 2.0: trust combat could not resolve %s (ptr %p)", name, raw);
        return nullptr;
    }

    auto* code = followThunk(static_cast<uint8*>(raw));
    if (!isExecutable(code))
    {
        ShowError("Imagine XI 2.0: trust combat could not resolve %s (ptr %p)", name, raw);
        return nullptr;
    }

    return code;
}

using CastFn  = void (CTrustEntity::*)(CMagicState&, action_t&);
using DelayFn = uint32 (CBattleEntity::*)(bool);

Trampoline g_castHook;
CastFn     g_originalCast = nullptr;
std::mutex g_castMutex;

Trampoline g_delayHook;
DelayFn    g_originalDelay = nullptr;
std::mutex g_delayMutex;

void trustChainAffinity(CTrustEntity* self, CMagicState& state, action_t& action)
{
    auto* PSpell = state.GetSpell();
    auto* PBlueSpell = dynamic_cast<CBlueSpell*>(PSpell);
    if (PBlueSpell == nullptr ||
        PSpell == nullptr ||
        !PSpell->dealsDamage() ||
        PBlueSpell->getPrimarySkillchain() == 0 ||
        (!self->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::ChainAffinity) &&
         !self->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::AzureLore)))
    {
        return;
    }

    auto* PChain = self->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::ChainAffinity);
    const bool permanentChain = PChain != nullptr && PChain->GetDuration().count() == 0;
    auto* PBattleTarget = state.target().resolve<CBattleEntity>();
    if (PBattleTarget == nullptr)
    {
        return;
    }

    for (auto&& actionTarget : action.targets)
    {
        if (actionTarget.actorId != PBattleTarget->id)
        {
            continue;
        }

        for (auto&& actionResult : actionTarget.results)
        {
            if (actionResult.param <= 0)
            {
                continue;
            }

            const auto effect = battleutils::GetSkillChainEffect(
                PBattleTarget,
                PBlueSpell->getPrimarySkillchain(),
                PBlueSpell->getSecondarySkillchain(),
                PBlueSpell->getTertiarySkillchain());
            if (effect != ActionProcSkillChain::None)
            {
                actionResult.recordSkillchain(effect, static_cast<int16_t>(battleutils::TakeSkillchainDamage(self, PBattleTarget, actionResult.param, nullptr)));
                if (!permanentChain)
                {
                    self->health.tp = 0;
                }
            }

            if (!permanentChain)
            {
                self->StatusEffectContainer->DelStatusEffectSilent(xi::StatusEffect::ChainAffinity);
            }
        }
    }
}

void hookedOnCastFinished(CTrustEntity* self, CMagicState& state, action_t& action)
{
    if (self == nullptr)
    {
        return;
    }

    std::lock_guard lock(g_castMutex);
    if (g_originalCast == nullptr || !g_castHook.remove())
    {
        return;
    }

    struct Restore
    {
        ~Restore()
        {
            g_castHook.install(reinterpret_cast<void*>(&hookedOnCastFinished));
        }
    } restore;

    (self->*g_originalCast)(state, action);
    trustChainAffinity(self, state, action);
}

// Replaces addBardSong. Players keep the instrument penalty. Any other
// caster adds MAXIMUM_SONGS_BONUS on top of the base two songs.
auto hookedAddBardSong(CLuaBaseEntity* self,
                       CLuaBaseEntity* PEntity,
                       xi::StatusEffect effectID,
                       uint16 power,
                       uint16 tick,
                       uint16 duration,
                       uint16 subType,
                       uint16 subPower,
                       uint16 tier) -> bool
{
    if (self == nullptr || self->GetBaseEntity() == nullptr)
    {
        return false;
    }

    auto* PBattle = dynamic_cast<CBattleEntity*>(self->GetBaseEntity());
    if (PBattle == nullptr)
    {
        ShowError("Invalid entity type calling function (%s).", self->GetBaseEntity()->getName().c_str());
        return false;
    }

    auto* PEffect = new CStatusEffect(effectID,
                                      static_cast<uint16>(effectID),
                                      power,
                                      std::chrono::seconds(tick),
                                      std::chrono::seconds(duration),
                                      subType,
                                      subPower,
                                      0,
                                      tier);

    uint8 maxSongs = 2;
    if (PEntity != nullptr && PEntity->GetBaseEntity() != nullptr)
    {
        auto* caster = dynamic_cast<CBattleEntity*>(PEntity->GetBaseEntity());
        if (caster != nullptr && caster->objtype == TYPE_PC)
        {
            auto* PCaster = static_cast<CCharEntity*>(caster);
            auto* PItem   = static_cast<CItemWeapon*>(PCaster->getEquip(SLOT_RANGED));
            if (PItem == nullptr || PItem->getID() == 65535 ||
                !(PItem->getSkillType() == xi::SkillType::StringInstrument || PItem->getSkillType() == xi::SkillType::WindInstrument))
            {
                maxSongs = 1;
            }

            maxSongs = static_cast<uint8>(maxSongs + PCaster->getMod(xi::Mod::MAXIMUM_SONGS_BONUS));
        }
        else if (caster != nullptr)
        {
            maxSongs = static_cast<uint8>(maxSongs + caster->getMod(xi::Mod::MAXIMUM_SONGS_BONUS));
        }
    }

    return PBattle->StatusEffectContainer->ApplyBardEffect(PEffect, maxSongs);
}

auto hookedGetWeaponDelay(CBattleEntity* self, bool tp) -> uint32
{
    if (self == nullptr)
    {
        return 8000;
    }

    uint32 delay = 8000;
    {
        std::lock_guard lock(g_delayMutex);
        if (g_originalDelay == nullptr || !g_delayHook.remove())
        {
            return delay;
        }

        struct Restore
        {
            ~Restore()
            {
                g_delayHook.install(reinterpret_cast<void*>(&hookedGetWeaponDelay));
            }
        } restore;

        delay = (self->*g_originalDelay)(tp);
    }

    if (tp || self->StatusEffectContainer->HasStatusEffect(xi::StatusEffect::HundredFists))
    {
        return delay;
    }

    if (auto* mob = dynamic_cast<CMobEntity*>(self); mob != nullptr && mob->getMobMod(xi::MobMod::AttackSkillList) != 0)
    {
        return delay;
    }

    auto* samba = self->StatusEffectContainer->GetStatusEffect(xi::StatusEffect::HasteSambaHaste);
    if (samba == nullptr || samba->GetPower() == 0)
    {
        return delay;
    }

    const float dancer = std::clamp(static_cast<float>(samba->GetPower()) / 10000.0f, 0.0f, 0.25f);
    float ability = self->getMod(xi::Mod::HASTE_ABILITY) / 10000.0f;
    auto* weapon  = dynamic_cast<CItemWeapon*>(self->m_Weapons[SLOT_MAIN]);
    if (weapon != nullptr && weapon->isTwoHanded())
    {
        ability += self->getMod(xi::Mod::TWOHAND_HASTE_ABILITY) / 10000.0f;
    }

    const float magic = std::clamp(self->getMod(xi::Mod::HASTE_MAGIC) / 10000.0f, -1.0f, 0.4375f);
    ability           = std::clamp(ability, -0.25f, 0.25f);
    const float gear  = std::clamp(self->getMod(xi::Mod::HASTE_GEAR) / 10000.0f, -0.25f, 0.25f);
    const float cap   = 1.0f - settings::get<float>("main.DELAY_REDUCTION_CAP");
    const float stock = std::clamp(1.0f - magic - ability - gear, cap, 2.0f);
    const float withSamba = std::clamp(1.0f - magic - ability - gear - dancer, cap, 2.0f);
    if (stock < 0.05f)
    {
        return delay;
    }

    auto adjusted = static_cast<uint32>(static_cast<float>(delay) * (withSamba / stock));
    if (weapon != nullptr)
    {
        const uint16 weaponDelay = weapon->getDelay() + self->getMod(xi::Mod::DELAY);
        const uint32 minDelay    = static_cast<uint32>(weaponDelay * 0.2f);
        const uint32 maxDelay    = static_cast<uint32>(weaponDelay) * 2;
        adjusted                 = std::clamp<uint32>(adjusted, minDelay, maxDelay);
    }

    return adjusted;
}

auto installCastHook() -> bool
{
    g_originalCast = &CTrustEntity::OnCastFinished;
    g_castHook.target = memberAddress(g_originalCast, "CTrustEntity::OnCastFinished");
    return g_castHook.target != nullptr && g_castHook.install(reinterpret_cast<void*>(&hookedOnCastFinished));
}

auto installSongHook() -> bool
{
    auto* target = memberAddress(&CLuaBaseEntity::addBardSong, "CLuaBaseEntity::addBardSong");
    if (target == nullptr)
    {
        return false;
    }

    // Permanent redirect. The trampoline object only has to live long
    // enough to write the jump; nothing calls the stock function after.
    static Trampoline hook;
    hook.target = target;
    return hook.install(reinterpret_cast<void*>(&hookedAddBardSong));
}

auto installDelayHook() -> bool
{
    g_originalDelay = &CBattleEntity::GetWeaponDelay;
    g_delayHook.target = memberAddress(g_originalDelay, "CBattleEntity::GetWeaponDelay");
    return g_delayHook.target != nullptr && g_delayHook.install(reinterpret_cast<void*>(&hookedGetWeaponDelay));
}

} // namespace

class Ixi20TrustCombatModule : public CPPModule
{
public:
    void OnInit() override
    {
        const bool castOk  = installCastHook();
        const bool songOk  = installSongHook();
        const bool delayOk = installDelayHook();
        if (castOk && songOk && delayOk)
        {
            ShowInfo("Imagine XI 2.0: trust chain affinity, trust song slots, and Haste Samba's own haste bucket");
        }
        else
        {
            ShowError("Imagine XI 2.0: trust combat hooks incomplete (chain %d, songs %d, samba %d)", castOk, songOk, delayOk);
        }
    }
};

REGISTER_CPP_MODULE(Ixi20TrustCombatModule);
