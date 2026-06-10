-----------------------------------
-- Ability: Manifestation
-- Extends the effect of your next enfeebling1 black magic spell to targets within range. MP cost and casting time2 are doubled.
-- Obtained: Scholar Level 40
-- Recast Time: Stratagem Charge
-- Duration (ImagineXI): 45 seconds, timed window (multiple eligible spells); matches BLU Diffusion. Other stratagem JAs do not cancel this.
-- Stratagem pool (ImagineXI): 5 charges from SCH level 10+; 48s recharge per charge (`abilities_charges.sql`).

-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if player:hasStatusEffect(xi.effect.MANIFESTATION) then
        return xi.msg.basic.EFFECT_ALREADY_ACTIVE, 0
    end

    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    player:addStatusEffect(xi.effect.MANIFESTATION, { power = 1, duration = 45, origin = player })

    return xi.effect.MANIFESTATION
end

return abilityObject
