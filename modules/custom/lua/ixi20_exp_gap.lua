-----------------------------------
-- Imagine XI 2.0: combat XP keeps climbing past Incredibly Tough.
-- Retail looks up a level-gap table that freezes at +15, then clamps
-- the kill to 400 / 500 / 600 by player level. An IT++ pull paid the
-- same as the first mob that hit that ceiling, so pages on easy prey
-- were the better hour.
-- This leaves even-match and below on the stock table. It lets the
-- +1..+15 rows pay what they already say, and each level past +15
-- adds a fraction of that +15 payout (Dedication still applies after).
-- Load after ixi20_promy_exp so this wrap stays outside the gil-XP
-- and Promyvion wraps. Do not return this module.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_exp_gap')

local TABLE_GAP = 15
-- Highest +15 cell in the stock table is 1500. Room for the stretch,
-- a chain, and a monster EXP_BONUS before Dedication.
local SAFETY_CAP = 20000

local retailCaps = xi.experiencePoints.perMonsterCaps

local function settings()
    return xi.settings and xi.settings.main or {}
end

local function enabled()
    return settings().IMAGINEXI_EXP_GAP_ENABLED ~= false
end

local function step()
    local value = settings().IMAGINEXI_EXP_GAP_STEP
    if type(value) == 'number' and value >= 0 then
        return value
    end

    return 0.15
end

local function maxMult()
    local value = settings().IMAGINEXI_EXP_GAP_MAX_MULT
    if type(value) == 'number' and value >= 1 then
        return value
    end

    return 5
end

local function syncCaps()
    if not enabled() then
        xi.experiencePoints.perMonsterCaps = retailCaps
        return
    end

    xi.experiencePoints.perMonsterCaps = {
        { maxLevel = 255, cap = SAFETY_CAP },
    }
end

local function mobExpLevel(mob)
    if mob == nil or mob.getMainLvl == nil then
        return 0
    end

    local level = mob:getMainLvl() or 0
    local adj   = 0
    if mob.getMod ~= nil then
        adj = mob:getMod(xi.mod.EXP_LVL_MOD) or 0
    end

    return level + adj
end

-- baseExp is already the +15 row when the mob is farther above than that.
local function stretchBase(mob, data)
    if not enabled() or data == nil then
        return
    end

    local base = data.baseExp or 0
    if base <= 0 then
        return
    end

    local reference = data.highestMemberLevel or data.memberLevel or 0
    if reference <= 0 then
        return
    end

    local extra = mobExpLevel(mob) - reference - TABLE_GAP
    if extra <= 0 then
        return
    end

    local mult = math.min(1 + extra * step(), maxMult())
    data.baseExp = math.floor(base * mult)
end

if not xi.experiencePoints._ixi20ExpGapWrap then
    xi.experiencePoints._ixi20ExpGapWrap = true
    local prevCalc = xi.experiencePoints.calculate
    xi.experiencePoints.calculate = function(member, mob, data)
        syncCaps()
        stretchBase(mob, data)
        if prevCalc then
            return prevCalc(member, mob, data)
        end
    end
end

syncCaps()
