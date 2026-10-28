/************************************************************************
 * Imagine XI 2.0: Starter HNM helper scaling (module only).
 *
 * City of Heroes giant-monster rule. A higher-level player does not
 * level-sync. Damage they deal to a starter HNM (local var
 * [starterHnm]mob) is figured as if they were the monster's level.
 * Damage the monster deals to them is figured as if the monster were
 * their level.
 *
 * FFXI's final hit already includes gear, weapon damage, and stats, which
 * grow faster than level. The level ratio is squared so a wide gap lands
 * near a same-level hit instead of a shaved-down endgame hit.
 *
 * Rebuild xi_map.
 ************************************************************************/

#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include "map/utils/moduleutils.h"

#include "common/logging.h"

#include "map/entities/battle_entity.h"
#include "map/entities/char_entity.h"

#include <algorithm>
#include <cmath>
#include <cstring>
#include <mutex>

#include <Windows.h>

namespace
{

constexpr size_t HookSize       = 12;
constexpr double kLevelExponent = 2.0;
constexpr char   kMobFlag[]     = "[starterHnm]mob";

using TakeDamageFn = int32 (CBattleEntity::*)(int32, CBattleEntity*, xi::AttackType, xi::DamageType, bool);

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

Trampoline        g_hook;
std::mutex        g_mutex;
TakeDamageFn      g_original = nullptr;

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

auto takeDamageBytes() -> uint8*
{
    TakeDamageFn fn = &CBattleEntity::takeDamage;
    static_assert(sizeof(fn) >= sizeof(void*), "member pointer smaller than a code pointer");

    void* raw = nullptr;
    std::memcpy(&raw, &fn, sizeof(raw));
    if (!isExecutable(raw))
    {
        ShowError("Imagine XI 2.0: starter HNM scale could not resolve takeDamage (ptr %p)", raw);
        return nullptr;
    }

    g_original = fn;
    return static_cast<uint8*>(raw);
}

auto isStarterHnm(CBattleEntity* entity) -> bool
{
    return entity != nullptr && entity->objtype == TYPE_MOB && entity->GetLocalVar(kMobFlag) == 1;
}

// Stored main job of a player, or of a pet's master. 0 when this hit has no player behind it.
auto contributorLevel(CBattleEntity* entity) -> uint8
{
    if (entity == nullptr)
    {
        return 0;
    }

    if (entity->objtype != TYPE_PC && entity->PMaster != nullptr && entity->PMaster->objtype == TYPE_PC)
    {
        entity = entity->PMaster;
    }

    auto* player = dynamic_cast<CCharEntity*>(entity);
    if (player == nullptr)
    {
        return 0;
    }

    const auto job = static_cast<uint8>(player->GetMJob());
    if (job >= MAX_JOBTYPE)
    {
        return player->GetMLevel();
    }

    const uint8 stored = player->jobs.job[job];
    return stored > 0 ? stored : player->GetMLevel();
}

auto applyScale(int32 amount, double scale) -> int32
{
    if (amount <= 0 || scale == 1.0)
    {
        return amount;
    }

    const auto scaled = static_cast<int32>(std::lround(static_cast<double>(amount) * scale));
    return std::clamp(std::max<int32>(1, scaled), 1, 99999);
}

// Higher-level player -> monster: figure the hit at the monster's level.
// Monster -> higher-level player: figure the hit at the player's level.
auto scaleStarterDamage(CBattleEntity* defender, CBattleEntity* attacker, int32 amount) -> int32
{
    if (amount <= 0 || defender == nullptr || attacker == nullptr)
    {
        return amount;
    }

    const bool defenderIsMob = isStarterHnm(defender);
    const bool attackerIsMob = isStarterHnm(attacker);
    if (defenderIsMob == attackerIsMob)
    {
        return amount;
    }

    if (defenderIsMob)
    {
        const uint8 playerLevel = contributorLevel(attacker);
        const uint8 mobLevel    = defender->GetMLevel();
        if (playerLevel <= mobLevel || mobLevel == 0)
        {
            return amount;
        }

        const double scale = std::pow(static_cast<double>(mobLevel) / static_cast<double>(playerLevel), kLevelExponent);
        return applyScale(amount, scale);
    }

    const uint8 playerLevel = contributorLevel(defender);
    const uint8 mobLevel    = attacker->GetMLevel();
    if (playerLevel <= mobLevel || mobLevel == 0)
    {
        return amount;
    }

    const double scale = std::pow(static_cast<double>(playerLevel) / static_cast<double>(mobLevel), kLevelExponent);
    return applyScale(amount, scale);
}

auto hookedTakeDamage(CBattleEntity* self,
                      int32           amount,
                      CBattleEntity*  attacker,
                      xi::AttackType  attackType,
                      xi::DamageType  damageType,
                      bool            isSkillchainDamage) -> int32
{
    const int32 scaled = scaleStarterDamage(self, attacker, amount);

    std::lock_guard lock(g_mutex);

    if (g_original == nullptr || !g_hook.remove())
    {
        return scaled;
    }

    struct Restore
    {
        ~Restore()
        {
            g_hook.install(reinterpret_cast<void*>(&hookedTakeDamage));
        }
    } restore;

    return (self->*g_original)(scaled, attacker, attackType, damageType, isSkillchainDamage);
}

auto installHook() -> bool
{
    g_hook.target = takeDamageBytes();
    if (g_hook.target == nullptr)
    {
        return false;
    }

    return g_hook.install(reinterpret_cast<void*>(&hookedTakeDamage));
}

} // namespace

class Ixi20StarterHnmScaleModule : public CPPModule
{
public:
    void OnInit() override
    {
        if (installHook())
        {
            ShowInfo("Imagine XI 2.0: starter HNM helpers keep their level; damage is figured at the other side's level");
        }
        else
        {
            ShowError("Imagine XI 2.0: starter HNM scale failed to hook takeDamage");
        }
    }
};

REGISTER_CPP_MODULE(Ixi20StarterHnmScaleModule);
