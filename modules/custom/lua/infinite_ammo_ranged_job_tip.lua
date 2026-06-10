-----------------------------------
-- One-line reminder when switching to a job that uses SLOT_AMMO (infinite ammo mode).
-----------------------------------
require('modules/module_utils')

local m = Module:new('infinite_ammo_ranged_job_tip')

local CHAR_VAR_MJ = 'ImagineAmmoTipMJ'
local CHAR_VAR_SJ = 'ImagineAmmoTipSJ'

local function usesAmmoSlotJob(jobId)
    return
        jobId == xi.job.RNG or
        jobId == xi.job.COR or
        jobId == xi.job.NIN
end

local function maybeRemind(player)
    if not xi.settings.map.DISABLE_AMMO_CONSUMPTION then
        return
    end

    local mj = player:getMainJob()
    local sj = player:getSubJob()

    if not usesAmmoSlotJob(mj) and not usesAmmoSlotJob(sj) then
        player:setCharVar(CHAR_VAR_MJ, mj)
        player:setCharVar(CHAR_VAR_SJ, sj)
        return
    end

    local prevMj = player:getCharVar(CHAR_VAR_MJ)
    local prevSj = player:getCharVar(CHAR_VAR_SJ)

    player:setCharVar(CHAR_VAR_MJ, mj)
    player:setCharVar(CHAR_VAR_SJ, sj)

    if prevMj == mj and prevSj == sj then
        return
    end

    player:printToPlayer('Imagine: Equipped ammo is not consumed on this server.', xi.msg.channel.SYSTEM_3)
end

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    maybeRemind(player)
end)

m:addOverride('xi.player.onMoghouseJobChange', function(player)
    super(player)
    maybeRemind(player)
end)

return m
