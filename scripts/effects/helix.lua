-----------------------------------
-- xi.effect.HELIX
-----------------------------------
require('scripts/globals/magic_tp_parity')

---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
end

effectObject.onEffectTick = function(target, effect)
    local dmg = utils.handleStoneskin(target, effect:getPower())

    if dmg > 0 then
        target:takeDamage(dmg)
        xi.magicTp.grantDotTickTpFromLocalVar(target, 'magicTpHelixCasterId')
    end
end

effectObject.onEffectLose = function(target, effect)
    xi.magicTp.clearCasterLocalVar(target, 'magicTpHelixCasterId')
end

return effectObject
