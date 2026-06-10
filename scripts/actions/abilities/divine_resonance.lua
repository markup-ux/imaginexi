-----------------------------------
-- Ability: Divine Resonance (Imagine XI)
-- WHM Lv70 TP spender. Party Haste + Refresh; optional Reverberation on mob target.
-- TP: 2000 | Recast: 3:00
-- See: server/documentation/JOB_AGNOSTIC_PARTY_SPEC.md
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    return xi.job_utils.white_mage.checkHealerTpAbility(player, target, ability)
end

abilityObject.onUseAbility = function(player, target, ability)
    return xi.job_utils.white_mage.useDivineResonance(player, target, ability)
end

return abilityObject
