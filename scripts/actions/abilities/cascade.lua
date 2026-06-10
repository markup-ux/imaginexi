-----------------------------------
-- Ability: Cascade
-- Description: Grants a damage bonus to the next elemental magic spell cast based on TP consumed.
-- Obtained: BLM Level 85
-- Recast Time: 00:01:30
-- Duration: 0:08:00 (passive magic attack bonus while active)
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability)
    return xi.job_utils.black_mage.useCascade(player, target, ability)
end

return abilityObject
