-----------------------------------
--  PET: Wyvern (hybrid DD + party support)
--  Breath behavior is unified: elemental breath on WS after status checks,
--  healing breath on party magic (wide party heal thresholds), and periodic
--  combat support via onMobFight.
-----------------------------------
require('scripts/globals/ability')
require('scripts/globals/job_utils/dragoon')
-----------------------------------
xi = xi or {}
xi.pets = xi.pets or {}
xi.pets.wyvern = {}

local BREATH_RANGE_YALMS = 14

-- How often onMobFight runs the extra support pass (combat ticks).
local SUPPORT_COMBAT_INTERVAL = 10

local function healingBreathIdForLevel(player)
    if player:getMainLvl() >= 80 then
        return xi.jobAbility.HEALING_BREATH_IV
    elseif player:getMainLvl() >= 40 then
        return xi.jobAbility.HEALING_BREATH_III
    elseif player:getMainLvl() >= 20 then
        return xi.jobAbility.HEALING_BREATH_II
    end

    return xi.jobAbility.HEALING_BREATH
end

local function inBreathRange(pet, target)
    return pet:getZoneID() == target:getZoneID() and pet:checkDistance(target) <= BREATH_RANGE_YALMS
end

-- Party + trusts: pick who needs healing breath most among those under the HP ratio gate.
local function pickBreathHealTarget(player, divisor)
    local pet = player:getPet()
    if not pet then
        return nil
    end

    local best     = nil
    local bestLoss = -1

    for _, member in pairs(player:getPartyWithTrusts()) do
        if not member:isDead() and inBreathRange(pet, member) then
            local maxHp = member:getMaxHP()
            local hp    = member:getHP()
            if hp <= math.floor(maxHp / divisor) then
                local loss = maxHp - hp
                if loss > bestLoss then
                    bestLoss = loss
                    best     = member
                end
            end
        end
    end

    return best
end

local function tryHealingBreath(player, divisor)
    local target = pickBreathHealTarget(player, divisor)
    if not target then
        return false
    end

    player:getPet():usePetAbility(healingBreathIdForLevel(player), target)
    return true
end

local function doStatusBreath(target, player)
    local wyvern = player:getPet()
    -- https://forum.square-enix.com/ffxi/threads/22659-dev1108-Job-Adjustments-Dragoon
    local removeBreathTable =
    {
        --  { lvl, ability                      , { statuses            } },
        { 40, xi.jobAbility.REMOVE_PARALYSIS, { xi.effect.PARALYSIS } },
        { 60, xi.jobAbility.REMOVE_CURSE    , { xi.effect.CURSE_I, xi.effect.BANE, xi.effect.DOOM } },
        { 80, xi.jobAbility.REMOVE_DISEASE  , { xi.effect.DISEASE, xi.effect.PLAGUE } },
        { 20, xi.jobAbility.REMOVE_BLINDNESS, { xi.effect.BLINDNESS } },
        {  1, xi.jobAbility.REMOVE_POISON   , { xi.effect.POISON    } },
    }

    for _, v in pairs(removeBreathTable) do
        local minLevel      = v[1]
        local ability       = v[2]
        local statusEffects = v[3]

        if wyvern:getMainLvl() >= minLevel then
            for _, effect in pairs(statusEffects) do
                if
                    target:hasStatusEffect(effect) and
                    wyvern:checkDistance(target) <= BREATH_RANGE_YALMS
                then
                    wyvern:usePetAbility(ability, target)
                    return true
                end
            end
        end
    end

    return false
end

-- Master first (self-cleansing), then party and trusts.
local function tryPartyStatusBreaths(master)
    if doStatusBreath(master, master) then
        return true
    end

    for _, member in pairs(master:getPartyWithTrusts()) do
        if member:getID() ~= master:getID() and doStatusBreath(member, master) then
            return true
        end
    end

    return false
end

xi.pets.wyvern.onMobSpawn = function(mob)
    local master = mob:getMaster()

    if master:getMod(xi.mod.WYVERN_SUBJOB_TRAITS) > 0 then
        mob:addWyvernJobTraits(master:getSubJob(), master:getSubLvl())
    end

    -- Hybrid: try status removal first, then elemental breath on master's WS target.
    master:addListener('WEAPONSKILL_USE', 'PET_WYVERN_WS', function(player, target, skill, tp, action, damage)
        if not tryPartyStatusBreaths(player) then
            xi.job_utils.dragoon.pickAndUseDamageBreath(player, target)
        end
    end)

    -- Same thresholds as former MULTI wyvern (25% gate; 33% with Wyvern +1 line).
    master:addListener('MAGIC_USE', 'PET_WYVERN_MAGIC', function(player, target, spell, action)
        local divisor = 4
        if player:getMod(xi.mod.WYVERN_EFFECTIVE_BREATH) > 0 then
            divisor = 3
        end

        tryHealingBreath(player, divisor)
    end)

    master:addListener('ATTACK', 'PET_WYVERN_ENGAGE', function(player, target, action)
        local pet = player:getPet()
        if not pet then
            return
        end

        -- Prefer master's combat target; if invalid or absent, assist a nearby party member fighting a mob.
        local engageTarget = nil
        if target and (target:isMob() or target:isPet()) then
            engageTarget = target
        else
            for _, member in pairs(player:getPartyWithTrusts()) do
                if member:getID() ~= player:getID() and not member:isDead() then
                    local memberTarget = member:getTarget()
                    if
                        memberTarget and
                        memberTarget:isMob() and
                        member:checkDistance(memberTarget) < 30 and
                        player:checkDistance(memberTarget) < 30
                    then
                        engageTarget = memberTarget
                        break
                    end
                end
            end
        end

        if engageTarget == nil then
            return
        end

        if pet:getTarget() == nil or engageTarget:getID() ~= pet:getTarget():getID() then
            player:petAttack(engageTarget)
        end
    end)

    master:addListener('DISENGAGE', 'PET_WYVERN_DISENGAGE', function(player)
        player:petRetreat()
    end)

    -- https://www.bg-wiki.com/ffxi/Wyvern_(Dragoon_Pet)#Parameter_Increase
    master:addListener('EXPERIENCE_POINTS', 'PET_WYVERN_EXP', function(playerObj, mobObj, exp)
        xi.job_utils.dragoon.addWyvernExp(playerObj, exp)
    end)
end

-- Opportunistic support while fighting: status breaths, then emergency heal.
xi.pets.wyvern.onMobFight = function(wyvern, target)
    local master = wyvern:getMaster()
    if not master or not master:isPC() then
        return
    end

    local phase = wyvern:getLocalVar('WYVERN_SUPPORT_PHASE') + 1
    wyvern:setLocalVar('WYVERN_SUPPORT_PHASE', phase)
    if phase % SUPPORT_COMBAT_INTERVAL ~= 0 then
        return
    end

    if not wyvern:canUseAbilities() then
        return
    end

    if tryPartyStatusBreaths(master) then
        return
    end

    local emergency = nil
    local worstRatio = 1.0

    for _, member in pairs(master:getPartyWithTrusts()) do
        if not member:isDead() and inBreathRange(wyvern, member) then
            local ratio = member:getHP() / math.max(1, member:getMaxHP())
            if ratio <= 0.20 and ratio < worstRatio then
                worstRatio = ratio
                emergency  = member
            end
        end
    end

    if emergency then
        wyvern:usePetAbility(healingBreathIdForLevel(master), emergency)
    end
end

xi.pets.wyvern.removeWyvernLevels = function(mob)
    local master  = mob:getMaster()
    local numLvls = mob:getLocalVar('level_Ups')

    if numLvls ~= 0 then
        local wyvernAttributeIncreaseEffectJP = master:getJobPointLevel(xi.jp.WYVERN_ATTR_BONUS)
        local wyvernBonusDA = master:getMod(xi.mod.WYVERN_ATTRIBUTE_DA)

        master:delMod(xi.mod.ATT, wyvernAttributeIncreaseEffectJP * numLvls)
        master:delMod(xi.mod.DEF, wyvernAttributeIncreaseEffectJP * numLvls)
        master:delMod(xi.mod.ATTP, 4 * numLvls)
        master:delMod(xi.mod.DEFP, 4 * numLvls)
        master:delMod(xi.mod.HASTE_ABILITY, 200 * numLvls)
        master:delMod(xi.mod.DOUBLE_ATTACK, wyvernBonusDA * numLvls)
        master:delMod(xi.mod.ALL_WSDMG_ALL_HITS, 2 * numLvls)
    end
end

xi.pets.wyvern.onMobDeath = function(mob, player)
    xi.pets.wyvern.removeWyvernLevels(mob)

    local master = mob:getMaster()
    master:removeListener('PET_WYVERN_WS')
    master:removeListener('PET_WYVERN_MAGIC')
    master:removeListener('PET_WYVERN_ENGAGE')
    master:removeListener('PET_WYVERN_DISENGAGE')
    master:removeListener('PET_WYVERN_EXP')
end

xi.pets.wyvern.onPetLevelRestriction = function(pet)
    xi.pets.wyvern.removeWyvernLevels(pet)
    pet:setLocalVar('wyvern_exp', 0)
    pet:setLocalVar('level_Ups', 0)
end
