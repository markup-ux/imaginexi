-----------------------------------
-- Ability: Luminous Strike (Imagine XI)
-- WHM Lv1 TP spender. Light damage vs one enemy.
-- TP: 500 | Recast: 0:30
-- See: server/documentation/JOB_AGNOSTIC_PARTY_SPEC.md
-----------------------------------
---@type TAbility
local abilityObject = {}

abilityObject.onAbilityCheck = function(player, target, ability)
    if not target or not target:isMob() then
        return xi.msg.basic.INVALID_TARGET, 0
    end

    return xi.job_utils.white_mage.checkHealerTpAbility(player, target, ability)
end

abilityObject.onUseAbility = function(player, target, ability, action)
    return xi.job_utils.white_mage.useLuminousStrike(player, target, ability, action)
end

return abilityObject
