--[[
HNM anti-melt mixin: per-hit damage caps, baseline mitigation, party-size
scaling, and an optional one-time ward phase at 50% HP.

Per-mob tuning (explicit caps, UDMG floors, ward opt-in) lives in
scripts/globals/hnm_anti_melt.lua, keyed by internal mob name.

Trusts are excluded from the engaged-player count used for scaling.
--]]

require('scripts/globals/mixins')
require('scripts/globals/hnm_anti_melt')
-----------------------------------
g_mixins = g_mixins or {}

g_mixins.hnm_anti_melt = function(hnmMob)
    hnmMob:addListener('SPAWN', 'HNM_ANTI_MELT_SPAWN', function(mob)
        xi.hnmAntiMelt.applyBase(mob)
    end)

    hnmMob:addListener('COMBAT_TICK', 'HNM_ANTI_MELT_COMBAT', function(mob)
        xi.hnmAntiMelt.updatePartyScaling(mob)
        xi.hnmAntiMelt.tryWardPhase(mob)
    end)
end

return g_mixins.hnm_anti_melt
