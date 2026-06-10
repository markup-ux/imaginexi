-----------------------------------
-- Ability: Futae
-- Grants a bonus to your next elemental ninjutsu (retail expends two tools on that cast; this server does not require tools).
-- Obtained: Ninja Level 77
-- Recast Time: 3:00
-- Duration: 1:00
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    xi.job_utils.ninja.checkFutae(player, target, ability)
end

abilityObject.onUseAbility = function(player, target, ability, action)
    return xi.job_utils.ninja.useFutae(player, target, ability, action)
end

return abilityObject
