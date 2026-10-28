-----------------------------------
-- Imagine XI 2.0: Promyvion empties grant combat XP.
-- Floor trash already uses the level-difference formula.
-- Strays in Holla, Dem, and Mea are stamped exp_bonus -100,
-- which multiplies that grant by 0. Clear the stamp so they
-- pay the same formula. Too Weak still pays nothing.
-- Spire battlefields are unchanged.
-- Load after ixi20_combine_kill_xp so the XP wrap stays outside it.
-- Do not return this module.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_promy_exp')

local promyZones =
{
    [xi.zone.PROMYVION_HOLLA] = true,
    [xi.zone.PROMYVION_DEM]   = true,
    [xi.zone.PROMYVION_MEA]   = true,
    [xi.zone.PROMYVION_VAHZL] = true,
}

local function isPromyMob(mob)
    return mob ~= nil and mob.getZoneID ~= nil and promyZones[mob:getZoneID()] == true
end

-- exp_bonus -100 is the "no experience" stamp. 0 restores the normal formula.
local function allowExp(mob)
    if not isPromyMob(mob) or mob.getMobMod == nil then
        return
    end

    if mob.isMobType ~= nil and mob:isMobType(xi.mobType.BATTLEFIELD) then
        return
    end

    if mob:getMobMod(xi.mobMod.EXP_BONUS) <= -100 then
        mob:setMobMod(xi.mobMod.EXP_BONUS, 0)
    end
end

local function sweepLiveMobs()
    if GetZoneByID == nil then
        return
    end

    for zoneId in pairs(promyZones) do
        local zone = GetZoneByID(zoneId)
        if zone ~= nil and zone.getMobs ~= nil then
            for _, mob in pairs(zone:getMobs() or {}) do
                allowExp(mob)
            end
        end
    end
end

m:addOverride('xi.promyvion.emptyOnMobSpawn', function(mob, mobType)
    super(mob, mobType)
    allowExp(mob)
end)

-- FileWatcher drops addOverride. Keep the spawn hook by assignment.
if xi.promyvion ~= nil and not xi.promyvion._ixi20PromyExpWrapped then
    xi.promyvion._ixi20PromyExpWrapped = true
    local prevEmpty = xi.promyvion.emptyOnMobSpawn
    xi.promyvion.emptyOnMobSpawn = function(mob, mobType)
        if prevEmpty then
            prevEmpty(mob, mobType)
        end

        allowExp(mob)
    end
end

if not xi.experiencePoints._ixi20PromyExpWrap then
    xi.experiencePoints._ixi20PromyExpWrap = true
    local prevCalc = xi.experiencePoints.calculate
    xi.experiencePoints.calculate = function(member, mob, data)
        allowExp(mob)
        if prevCalc then
            return prevCalc(member, mob, data)
        end
    end
end

sweepLiveMobs()
