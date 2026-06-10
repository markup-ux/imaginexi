--[[
HNM healer-pressure mixin: telegraphed AoE pulses, status packages, MP burn,
and one-time Doom spotlights. Companion to hnm_anti_melt -- anti-melt sets
the fight-length floor, this fills the time with sustain pressure that
rewards healing skill.

Per-mob tuning lives in scripts/globals/healer_pressure.lua, keyed by
internal mob name. Mobs without a config entry are unaffected.
--]]

require('scripts/globals/mixins')
require('scripts/globals/healer_pressure')
-----------------------------------
g_mixins = g_mixins or {}

g_mixins.healer_pressure = function(hnmMob)
    hnmMob:addListener('SPAWN', 'HEALER_PRESSURE_SPAWN', function(mob)
        xi.healerPressure.onSpawn(mob)
    end)

    hnmMob:addListener('COMBAT_TICK', 'HEALER_PRESSURE_COMBAT', function(mob)
        xi.healerPressure.onCombatTick(mob)
    end)
end

return g_mixins.healer_pressure
