-----------------------------------
-- xi.effect.REFUELING
-- Blue Mage Refueling. Job-ability haste, so it stacks with magic haste
-- (Haste, March), gear haste, and Haste Samba. Shares the 25% ability-haste
-- cap with Spirit Surge, Hasso, Last Resort, and Prowess attack speed.
-----------------------------------
---@type TEffect
local effectObject = {}

effectObject.onEffectGain = function(target, effect)
    effect:addMod(xi.mod.HASTE_ABILITY, effect:getPower())
end

effectObject.onEffectTick = function(target, effect)
end

effectObject.onEffectLose = function(target, effect)
end

return effectObject
