-----------------------------------
-- Ability: Sacred Cascade (Imagine XI)
-- WHM Lv50 TP spender. Party Cure + Esuna.
-- TP: 1000 | Recast: 2:00
-- See: server/documentation/JOB_AGNOSTIC_PARTY_SPEC.md
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.white_mage.checkHealerTpAbility(player, target, ability)
end

abilityObject.onUseAbility = function(player, target, ability)
    return xi.job_utils.white_mage.useSacredCascade(player, target, ability)
end

return abilityObject
