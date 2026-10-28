/************************************************************************
 * Imagine XI 2.0: a trust can keep an avatar out.
 *
 * Lua spawnPet ignores TYPE_TRUST, and petutils::DespawnPet / DetachPet
 * cast the master to CCharEntity. This module summons through SpawnPet
 * and, on release, drops both pointers and lets the pet die on its own.
 *
 * CPetEntity::PostTick sends a pet-sync packet whenever
 * PMaster->PPet == this, and it casts that master to CCharEntity.
 * A trust master crashes the map there (the client then sits at R0).
 * After spawn the trust's PPet link is cleared. The pet still follows
 * because its own PMaster stays the trust. The pet is found again by id.
 *
 * Kayeel and Robel are BLM/SMN, so CalculateAvatarStats would build the
 * avatar at subjob level. The main job is set to SMN for the spawn call
 * only, then put back, so the avatar matches the trust's level and the
 * trust stays a black mage.
 *
 * Rebuild xi_map after adding or removing this module.
 ************************************************************************/

#include "map/utils/moduleutils.h"

#include "common/logging.h"
#include "common/lua.h"

#include "map/ai/ai_container.h"
#include "map/entities/pet_entity.h"
#include "map/entities/trust_entity.h"
#include "map/lua/lua_base_entity.h"
#include "map/utils/petutils.h"
#include "map/utils/zoneutils.h"

#include <unordered_map>

namespace
{

constexpr uint8 JobSMN = 15;

// Trust entity id -> avatar entity id. The trust must not keep PPet set.
std::unordered_map<uint32, uint32> trustAvatars;

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

auto findAvatar(CTrustEntity* PTrust) -> CPetEntity*
{
    if (PTrust == nullptr)
    {
        return nullptr;
    }

    auto it = trustAvatars.find(PTrust->id);
    if (it == trustAvatars.end())
    {
        return nullptr;
    }

    auto* entity = zoneutils::GetEntity(it->second);
    auto* pet   = entity != nullptr ? dynamic_cast<CPetEntity*>(entity) : nullptr;
    if (pet == nullptr || pet->PMaster != PTrust || pet->isDead())
    {
        if (pet != nullptr && pet->PMaster == PTrust)
        {
            pet->PMaster = nullptr;
        }
        trustAvatars.erase(it);
        return nullptr;
    }

    return pet;
}

void dropPetLink(CTrustEntity* PTrust, CBaseEntity* PPet)
{
    if (PTrust != nullptr && PPet != nullptr && PTrust->PPet == PPet)
    {
        PTrust->PPet = nullptr;
    }
}

void releaseAvatar(CTrustEntity* PTrust)
{
    if (PTrust == nullptr)
    {
        return;
    }

    auto* PPet = findAvatar(PTrust);
    if (PPet == nullptr && PTrust->PPet != nullptr)
    {
        PPet = dynamic_cast<CPetEntity*>(PTrust->PPet);
    }

    trustAvatars.erase(PTrust->id);
    dropPetLink(PTrust, PPet);
    PTrust->PParty = nullptr;

    if (PPet == nullptr)
    {
        return;
    }

    if (PPet->PMaster == PTrust)
    {
        PPet->PMaster = nullptr;
    }

    if (PPet->PAI != nullptr && !PPet->isDead())
    {
        PPet->Die();
    }
}

void summonAvatar(CTrustEntity* PTrust, uint32 petId)
{
    if (PTrust == nullptr || PTrust->loc.zone == nullptr || petId > 20)
    {
        return;
    }

    // Do not set PTrust->PParty. CMobEntity's destructor calls
    // CParty::DelMember, and a trust is not a party member. Zoning
    // with that pointer set crashes the map.

    if (auto* existing = findAvatar(PTrust))
    {
        if (existing->petID() == petId && existing->GetMLevel() == PTrust->GetMLevel())
        {
            dropPetLink(PTrust, existing);
            return;
        }

        releaseAvatar(PTrust);
    }
    else if (PTrust->PPet != nullptr)
    {
        releaseAvatar(PTrust);
    }

    const auto savedJob = static_cast<uint8>(PTrust->GetMJob());
    PTrust->SetMJob(JobSMN);
    petutils::SpawnPet(PTrust, petId, false);
    PTrust->SetMJob(savedJob);

    auto* PPet = dynamic_cast<CPetEntity*>(PTrust->PPet);
    if (PPet == nullptr)
    {
        return;
    }

    PPet->allegiance = PTrust->allegiance;
    trustAvatars[PTrust->id] = PPet->id;

    if (PTrust->PAI != nullptr && PTrust->PAI->IsEngaged())
    {
        auto* target = PTrust->GetBattleTarget();
        if (target != nullptr)
        {
            petutils::AttackTarget(PTrust, target);
        }
    }

    // PostTick crashes if this link is still set on a trust.
    PTrust->PPet = nullptr;
}

auto luaSummonAvatar(lua_State* L) -> int
{
    auto* PTrust = entityFromLua(L, 1);
    if (PTrust == nullptr || lua_gettop(L) < 2 || !lua_isnumber(L, 2))
    {
        return 0;
    }

    summonAvatar(PTrust, static_cast<uint32>(lua_tointeger(L, 2)));
    return 0;
}

auto luaReleaseAvatar(lua_State* L) -> int
{
    releaseAvatar(entityFromLua(L, 1));
    return 0;
}

auto luaGetAvatar(lua_State* L) -> int
{
    auto* PTrust = entityFromLua(L, 1);
    auto* PPet   = findAvatar(PTrust);
    if (PPet == nullptr)
    {
        lua_pushnil(L);
        return 1;
    }

    sol::stack::push(L, CLuaBaseEntity(PPet));
    return 1;
}

} // namespace

class Ixi20TrustAvatarModule : public CPPModule
{
    void OnInit() override
    {
        lua_register(lua.lua_state(), "Ixi20TrustSummonAvatar", luaSummonAvatar);
        lua_register(lua.lua_state(), "Ixi20TrustReleaseAvatar", luaReleaseAvatar);
        lua_register(lua.lua_state(), "Ixi20TrustGetAvatar", luaGetAvatar);
        ShowInfo("Imagine XI 2.0: Kayeel and Robel keep an avatar out");
    }
};

REGISTER_CPP_MODULE(Ixi20TrustAvatarModule);
