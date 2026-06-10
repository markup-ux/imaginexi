-----------------------------------
-- Shared scaling for self-defense mobskills (e.g. diamondhide, evasion).
-- In this codebase mob:isNM() is true only for MOBTYPE_NOTORIOUS (typical world HNMs).
-- xi.mobMod.CHECK_AS_NM covers many other NM-class mobs.
-----------------------------------
require('scripts/globals/utils')

xi = xi or {}
xi.mobskillDefenseScaling = xi.mobskillDefenseScaling or {}

---@param mob CBaseEntity
---@return number tier Multiplier >= 1
local function tierMultiplier(mob)
    if mob:isNM() then
        return 2.85
    end

    if mob:getMobMod(xi.mobMod.CHECK_AS_NM) > 0 then
        return 1.70
    end

    return 1.0
end

--- Stoneskin absorb from mobskill diamondhide: level + max HP slice, scaled by tier.
--- Tuned so notorious mobs soak roughly a strong WS worth of damage, not a flat 800.
---@param mob CBaseEntity
---@return integer absorb
---@return integer durationSeconds
xi.mobskillDefenseScaling.diamondhide = function(mob)
    local lvl   = mob:getMainLvl()
    local maxHp = math.max(1, mob:getMaxHP())
    local tier  = tierMultiplier(mob)

    -- Base: modest floor + level growth + ~1.1% max HP (meaningful on HNM HP pools).
    local baseAbsorb = 200 + lvl * 12 + maxHp * 0.011
    local absorb     = math.floor(baseAbsorb * tier)
    absorb             = utils.clamp(absorb, 400, 20000)

    local duration = 300
    if tier >= 2.85 then
        duration = 420
    elseif tier >= 1.70 then
        duration = 360
    end

    return absorb, duration
end

--- Evasion boost from mobskill evasion: scales tier + level; duration grows slightly with tier.
---@param mob CBaseEntity
---@return integer power  EVA mod
---@return integer durationSeconds
xi.mobskillDefenseScaling.evasionBoost = function(mob)
    local lvl  = mob:getMainLvl()
    local tier = tierMultiplier(mob)

    -- Old retail-flat ~50 at midgame; now level-weighted then tiered.
    local power = math.floor((38 + lvl * 0.70) * tier)
    power       = utils.clamp(power, 15, 500)

    local duration = math.floor((155 + lvl * 0.9) * (1.0 + 0.22 * (tier - 1.0)))
    duration       = utils.clamp(duration, 90, 600)

    return power, duration
end

return xi.mobskillDefenseScaling
