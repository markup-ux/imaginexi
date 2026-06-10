-----------------------------------
-- xi.effect.ARCANE_CHARGE -- Imagine XI charged nuke DoT (stacks with Bio/Burn/Helix/etc.)
-- subPower stores spell element for tick damage type
-----------------------------------
require('scripts/globals/magic_tp_parity')

---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
end

effectObject.onEffectTick = function(target, effect)
    local dmg = utils.handleStoneskin(target, effect:getPower())

    if dmg <= 0 then
        return
    end

    local originId = effect:getOriginID()
    local origin   = originId > 0 and GetEntityByID(originId) or nil
    local element  = effect:getSubPower()
    local dmgType  = xi.damageType.ELEMENTAL

    if element and element > xi.element.NONE and element <= xi.element.WATER then
        dmgType = xi.damageType.ELEMENTAL + element
    end

    if origin then
        target:takeDamage(dmg, origin, xi.attackType.MAGICAL, dmgType)
    else
        target:takeDamage(dmg, nil, xi.attackType.MAGICAL, dmgType)
    end

    xi.magicTp.grantDotTickTpFromLocalVar(target, 'magicTpArcaneChargeCasterId')
end

effectObject.onEffectLose = function(target, effect)
    xi.magicTp.clearCasterLocalVar(target, 'magicTpArcaneChargeCasterId')
end

return effectObject
