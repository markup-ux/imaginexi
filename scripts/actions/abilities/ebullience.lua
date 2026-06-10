-----------------------------------
-- Ability: Ebullience
-- Enhances the potency of your next black magic spell.
-- Obtained: Scholar Level 55
-- Recast Time: Stratagem Charge
-- Duration: 1 black magic spell or 60 seconds, whichever occurs first
-- Stratagem pool (ImagineXI): 5 charges from SCH level 10+; 48s recharge per charge (`abilities_charges.sql`).

-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if player:hasStatusEffect(xi.effect.EBULLIENCE) then
        return xi.msg.basic.EFFECT_ALREADY_ACTIVE, 0
    end

    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    player:addStatusEffect(xi.effect.EBULLIENCE, { power = 1, duration = 60, origin = player })

    return xi.effect.EBULLIENCE
end

return abilityObject
