-----------------------------------
-- Ability: Addendum: Black
-- Allows access to additional Black Magic spells while using Dark Arts.
-- Obtained: Scholar Level 30
-- Recast Time: Stratagem Charge
-- Duration: 2 hours
-- Stratagem pool (ImagineXI): 5 charges from SCH level 10+; 48s recharge per charge (`abilities_charges.sql`).

-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if player:hasStatusEffect(xi.effect.ADDENDUM_BLACK) then
        return xi.msg.basic.EFFECT_ALREADY_ACTIVE, 0
    end

    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    player:delStatusEffectSilent(xi.effect.DARK_ARTS)

    local effectbonus = player:getMod(xi.mod.DARK_ARTS_EFFECT)
    local helixbonus  = 0

    if player:getMainJob() == xi.job.SCH and player:getMainLvl() >= 20 then
        helixbonus = math.floor(player:getMainLvl() / 4)
    end

    player:addStatusEffect(xi.effect.ADDENDUM_BLACK, { power = effectbonus, duration = 7200, origin = player, subPower = helixbonus, silent = true })

    return xi.effect.ADDENDUM_BLACK
end

return abilityObject
