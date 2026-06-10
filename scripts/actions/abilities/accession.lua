-----------------------------------
-- Ability: Accession
-- Extends the effect of your next healing or enhancing white magic spell to party members within range.
-- MP cost and casting time are doubled.
-- Obtained: Scholar Level 40
-- Recast Time: Stratagem Charge
-- Duration (ImagineXI): 45 seconds, timed window (multiple eligible spells); matches BLU Diffusion. Other stratagem JAs do not cancel this.
-- Stratagem pool (ImagineXI): 5 charges from SCH level 10+; 48s recharge per charge (`abilities_charges.sql`).

-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if player:hasStatusEffect(xi.effect.ACCESSION) then
        return xi.msg.basic.EFFECT_ALREADY_ACTIVE, 0
    end

    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    player:addStatusEffect(xi.effect.ACCESSION, { power = 1, duration = 45, origin = player })

    return xi.effect.ACCESSION
end

return abilityObject
