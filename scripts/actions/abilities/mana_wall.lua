-----------------------------------
-- Ability: Mana Wall
-- Description: Allows you to take damage with MP. Use again to turn off (short recast).
-- Obtained: BLM Level 44
-- Recast Time: 00:03:00 (applies when turning on; ~3s when turning off)
-- Duration: Until toggled off, death, zone, or job change
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return 0, 0
end

abilityObject.onUseAbility = function(player, target, ability, action)
    return xi.job_utils.black_mage.useManaWall(player, target, ability, action)
end

return abilityObject
