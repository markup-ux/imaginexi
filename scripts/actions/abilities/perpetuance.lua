-----------------------------------
-- Ability: Perpetuance
-- Increases the enhancement effect duration of your next white magic spell.
-- Obtained: Scholar Level 87
-- Recast Time: Stratagem Charge
-- Duration: 00:01:00 or first white Enhancing Magic cast, whichever first
-- Stratagem pool (ImagineXI): 5 charges from SCH level 10+; 48s recharge per charge (`abilities_charges.sql`).

-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if player:hasStatusEffect(xi.effect.PERPETUANCE) then
        return xi.msg.basic.EFFECT_ALREADY_ACTIVE, 0
    end

    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    player:addStatusEffect(xi.effect.PERPETUANCE, { power = 1, duration = 60, origin = player })

    return xi.effect.PERPETUANCE
end

return abilityObject
