-----------------------------------
-- Shared HNM anti-melt tuning: per-hit damage caps, baseline mitigation,
-- engaged-party scaling, and an optional one-time ward phase at 50% HP.
--
-- Per-mob tuning lives in xi.hnmAntiMelt.config, keyed by internal mob name.
-- Mobs without an explicit damageCap derive one from their max HP, so the
-- same fight-length floor (~30 capped hits at full engagement) holds across
-- very different HP pools.
--
-- Trusts are excluded from the engaged-player count used for scaling.
-----------------------------------
require('scripts/globals/mobskill_defense_scaling')
-----------------------------------
xi = xi or {}
xi.hnmAntiMelt = xi.hnmAntiMelt or {}

xi.hnmAntiMelt.defaults =
{
    BASELINE_ENGAGED_PLAYERS = 6,

    -- Baseline per-hit cap as a slice of max HP (used when no explicit damageCap).
    DAMAGE_CAP_HP_FRACTION   = 0.032,
    DAMAGE_CAP_MIN           = 300,
    DAMAGE_CAP_MAX           = 1800,
    DAMAGE_VARIANCE_FRACTION = 0.1875, -- variance relative to the baseline cap

    UDMG_PHYS                = -2000,
    UDMG_MAGIC               = -2000,
    UDMG_RANGE               = -1500,
    UDMG_BREATH              = -1500,

    WARD_HPP                 = 50,
    WARD_BONUS_UDMG          = -1000,
    WARD_BONUS_DURATION_S    = 30,
    WARD_MESSAGE             = 'A protective ward flares -- incoming damage is blunted.',
}

-- Cap multiplier and extra mitigation by engaged real players (trusts excluded).
-- Fractions reproduce the original sky god table exactly at an 800 baseline cap
-- (450/550/650/700/750/800 with variance 100/100/120/130/140/150).
xi.hnmAntiMelt.scalingByPlayers =
{
    [1] = { extraUDMG = -5000, capScale = 0.5625, varianceScale = 0.6670 },
    [2] = { extraUDMG = -3500, capScale = 0.6875, varianceScale = 0.6670 },
    [3] = { extraUDMG = -2000, capScale = 0.8125, varianceScale = 0.8000 },
    [4] = { extraUDMG = -1000, capScale = 0.8750, varianceScale = 0.8670 },
    [5] = { extraUDMG = -500,  capScale = 0.9375, varianceScale = 0.9340 },
    [6] = { extraUDMG = 0,     capScale = 1.0000, varianceScale = 1.0000 },
}

local skyGodTuning =
{
    damageCap   = 800,
    ward        = true,
    wardMessage = 'The Sky god\'s ward flares -- incoming damage is blunted.',
}

-- Per-mob overrides, keyed by internal mob name.
-- ward:       opt-in; mobs with native defensive phases keep those instead.
-- manageUDMG: false leaves all UDMG* mods to the mob's own script (caps still apply).
xi.hnmAntiMelt.config =
{
    -- Sky (Ru'Aun gods keep their original tuning; Kirin's god summons are its phase mechanic)
    ['Genbu']  = skyGodTuning,
    ['Seiryu'] = skyGodTuning,
    ['Byakko'] = skyGodTuning,
    ['Suzaku'] = skyGodTuning,
    ['Kirin']  = { ward = false },

    -- Dragon's Aery
    ['Fafnir']  = { ward = true },
    ['Nidhogg'] = { ward = true },

    -- Behemoth's Dominion (King Behemoth's Meteor cycle is its midpoint mechanic)
    ['Behemoth']      = { ward = true },
    ['King_Behemoth'] = { ward = false },

    -- Valley of Sorrows (Aspidochelone's shell state machine owns its UDMG mods)
    ['Adamantoise']   = { ward = true },
    ['Aspidochelone'] = { ward = false, manageUDMG = false },

    -- Ancient wyrms: keep their stronger native magic/range/breath floors;
    -- flight phases stand in for a ward.
    ['Tiamat']     = { ward = false, udmgMagic = -5000, udmgRange = -5000, udmgBreath = -5000 },
    ['Jormungand'] = { ward = false, udmgMagic = -5000, udmgRange = -5000, udmgBreath = -5000 },
    ['Vrtra']      = { ward = false, udmgMagic = -5000, udmgRange = -5000, udmgBreath = -5000 },

    -- Other world HNMs (Cerberus' low-HP regain ramp is its native phase)
    ['Roc']               = { ward = true },
    ['Simurgh']           = { ward = true },
    ['Cerberus']          = { ward = false },
    ['Khimaira']          = { ward = true },
    ['Serket']            = { ward = true },
    ['Capricious_Cassie'] = { ward = true },
    ['King_Arthro']       = { ward = true },
    ['Lord_of_Onzozo']    = { ward = true },
}

---@param mob CBaseEntity
---@param key string
---@return any
local function getSetting(mob, key)
    local mobConfig = xi.hnmAntiMelt.config[mob:getName()]

    if mobConfig and mobConfig[key] ~= nil then
        return mobConfig[key]
    end

    return xi.hnmAntiMelt.defaults[key]
end

---@param mob CBaseEntity
---@return boolean
local function managesUDMG(mob)
    local mobConfig = xi.hnmAntiMelt.config[mob:getName()]

    if mobConfig and mobConfig.manageUDMG ~= nil then
        return mobConfig.manageUDMG
    end

    return true
end

---@param mob CBaseEntity
---@return boolean
local function hasWard(mob)
    local mobConfig = xi.hnmAntiMelt.config[mob:getName()]

    return mobConfig ~= nil and mobConfig.ward == true
end

---@param mob CBaseEntity
---@return integer
local function baselineDamageCap(mob)
    local explicit = getSetting(mob, 'damageCap')

    if explicit then
        return explicit
    end

    local defaults = xi.hnmAntiMelt.defaults
    local derived  = math.floor(mob:getMaxHP() * defaults.DAMAGE_CAP_HP_FRACTION)

    return utils.clamp(derived, defaults.DAMAGE_CAP_MIN, defaults.DAMAGE_CAP_MAX)
end

-- Strengthen-only: never weaken a UDMG floor the mob's own script already set.
---@param mob CBaseEntity
---@param mod integer
---@param value integer
local function applyUDMGFloor(mob, mod, value)
    mob:setMod(mod, math.min(mob:getMod(mod), value))
end

---@param mob CBaseEntity
---@return integer
xi.hnmAntiMelt.countEngagedRealPlayers = function(mob)
    local seen  = {}
    local count = 0

    for _, entry in ipairs(mob:getEnmityList()) do
        local member = entry.entity

        if
            member and
            member:isPC() and
            not member:isTrust() and
            not seen[member:getID()]
        then
            seen[member:getID()] = true
            count = count + 1
        end
    end

    return count
end

---@param mob CBaseEntity
xi.hnmAntiMelt.applyBase = function(mob)
    local baseCap  = baselineDamageCap(mob)
    local variance = math.floor(baseCap * xi.hnmAntiMelt.defaults.DAMAGE_VARIANCE_FRACTION)

    mob:setMod(xi.mod.RECEIVED_DAMAGE_CAP, baseCap)
    mob:setMod(xi.mod.RECEIVED_DAMAGE_VARIANT, variance)

    if managesUDMG(mob) then
        applyUDMGFloor(mob, xi.mod.UDMGPHYS, getSetting(mob, 'udmgPhys') or xi.hnmAntiMelt.defaults.UDMG_PHYS)
        applyUDMGFloor(mob, xi.mod.UDMGMAGIC, getSetting(mob, 'udmgMagic') or xi.hnmAntiMelt.defaults.UDMG_MAGIC)
        applyUDMGFloor(mob, xi.mod.UDMGRANGE, getSetting(mob, 'udmgRange') or xi.hnmAntiMelt.defaults.UDMG_RANGE)
        applyUDMGFloor(mob, xi.mod.UDMGBREATH, getSetting(mob, 'udmgBreath') or xi.hnmAntiMelt.defaults.UDMG_BREATH)
    end

    mob:setLocalVar('[antiMelt]baseCap', baseCap)
    mob:setLocalVar('[antiMelt]baseVariance', variance)
    mob:setLocalVar('[antiMelt]extraUDMG', 0)
    mob:setLocalVar('[antiMelt]lastPlayerCount', 0)
    mob:setLocalVar('[antiMelt]wardApplied', 0)
    mob:setLocalVar('[antiMelt]wardBonusActive', 0)
end

---@param mob CBaseEntity
xi.hnmAntiMelt.updatePartyScaling = function(mob)
    local count = xi.hnmAntiMelt.countEngagedRealPlayers(mob)

    if count == 0 then
        count = 1
    end

    count = math.min(xi.hnmAntiMelt.defaults.BASELINE_ENGAGED_PLAYERS, count)

    if count == mob:getLocalVar('[antiMelt]lastPlayerCount') then
        return
    end

    local scale = xi.hnmAntiMelt.scalingByPlayers[count] or xi.hnmAntiMelt.scalingByPlayers[6]

    if managesUDMG(mob) then
        local oldExtra   = mob:getLocalVar('[antiMelt]extraUDMG')
        local extraDelta = scale.extraUDMG - oldExtra

        if extraDelta ~= 0 then
            mob:addMod(xi.mod.UDMGPHYS, extraDelta)
            mob:addMod(xi.mod.UDMGMAGIC, extraDelta)
            mob:addMod(xi.mod.UDMGRANGE, extraDelta)
            mob:addMod(xi.mod.UDMGBREATH, extraDelta)
            mob:setLocalVar('[antiMelt]extraUDMG', scale.extraUDMG)
        end
    end

    local baseCap      = mob:getLocalVar('[antiMelt]baseCap')
    local baseVariance = mob:getLocalVar('[antiMelt]baseVariance')

    mob:setMod(xi.mod.RECEIVED_DAMAGE_CAP, math.floor(baseCap * scale.capScale))
    mob:setMod(xi.mod.RECEIVED_DAMAGE_VARIANT, math.floor(baseVariance * scale.varianceScale))
    mob:setLocalVar('[antiMelt]lastPlayerCount', count)
end

---@param mob CBaseEntity
xi.hnmAntiMelt.tryWardPhase = function(mob)
    if not hasWard(mob) then
        return
    end

    if mob:getLocalVar('[antiMelt]wardApplied') == 1 then
        return
    end

    if mob:getHPP() > xi.hnmAntiMelt.defaults.WARD_HPP then
        return
    end

    mob:setLocalVar('[antiMelt]wardApplied', 1)

    local absorb, duration = xi.mobskillDefenseScaling.diamondhide(mob)
    mob:addStatusEffect(xi.effect.STONESKIN, { power = absorb, duration = duration, origin = mob, tier = 0 })

    local bonusUDMG = xi.hnmAntiMelt.defaults.WARD_BONUS_UDMG
    mob:addMod(xi.mod.UDMGPHYS, bonusUDMG)
    mob:addMod(xi.mod.UDMGMAGIC, bonusUDMG)
    mob:setLocalVar('[antiMelt]wardBonusActive', 1)

    mob:timer(xi.hnmAntiMelt.defaults.WARD_BONUS_DURATION_S * 1000, function(mobArg)
        if mobArg and mobArg:getLocalVar('[antiMelt]wardBonusActive') == 1 then
            mobArg:addMod(xi.mod.UDMGPHYS, -bonusUDMG)
            mobArg:addMod(xi.mod.UDMGMAGIC, -bonusUDMG)
            mobArg:setLocalVar('[antiMelt]wardBonusActive', 0)
        end
    end)

    local wardMessage = getSetting(mob, 'wardMessage')

    for _, entry in ipairs(mob:getEnmityList()) do
        local member = entry.entity

        if member and member:isPC() then
            member:printToPlayer(wardMessage, xi.msg.channel.NARROW_RANGE)
        end
    end
end

return xi.hnmAntiMelt
