-----------------------------------
-- Ability: Altruism
-- Increases the accuracy of your next White Magic spell.
-- Obtained: Scholar Level 75 Tier 2 Merit Points
-- Recast Time: Stratagem Charge
-- Duration: 1 white magic spell or 60 seconds, whichever occurs first
-- Stratagem pool (ImagineXI): 5 charges from SCH level 10+; 48s recharge per charge (`abilities_charges.sql`).

-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if player:hasStatusEffect(xi.effect.ALTRUISM) then
        return xi.msg.basic.EFFECT_ALREADY_ACTIVE, 0
    end

    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    player:addStatusEffect(xi.effect.ALTRUISM, { power = player:getMerit(xi.merit.ALTRUISM), duration = 60, origin = player })

    return xi.effect.ALTRUISM
end

return abilityObject
