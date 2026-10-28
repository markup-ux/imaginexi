-----------------------------------
-- xi.effect.HASTE_SAMBA_HASTE
-- JA Haste 5-10%
-- The delay change is applied by modules/custom/cpp/ixi20_trust_combat.cpp,
-- which reads this effect's power into its own haste bucket.
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
