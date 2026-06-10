-----------------------------------
-- Periodic sampling of online main/sub jobs and PC party compositions.
-- Requires: sql/migrations/2026_05_03_server_telemetry.sql
-- Enable:   TELEMETRY_ENABLED in settings/map.lua
--
-- Job rows reflect each online character once per sample (accurate across map processes).
-- Party keys use PCs returned by getParty() on that process; members zoned elsewhere may be
-- omitted, so unusual splits are possible when running multiple map processes.
-----------------------------------
require('scripts/enum/job')
require('scripts/enum/obj_type')

xi = xi or {}
xi.telemetry = xi.telemetry or {}

local jobAbbrev = {}
for abbrev, id in pairs(xi.job) do
    if type(abbrev) == 'string' and type(id) == 'number' then
        jobAbbrev[id] = abbrev
    end
end

local function abbrevFor(jobId)
    return jobAbbrev[jobId] or string.format('J%u', jobId)
end

local function formatJobPair(mjob, sjob)
    local main = abbrevFor(mjob)
    if sjob == nil or sjob == 0 or sjob == xi.job.NONE then
        return main
    end

    return string.format('%s/%s', main, abbrevFor(sjob))
end

local lastSampleTime = 0

xi.telemetry.onTimeServerTick = function()
    if xi.settings.map.TELEMETRY_ENABLED ~= true then
        return
    end

    local interval = xi.settings.map.TELEMETRY_INTERVAL_SEC or 300
    local now      = GetSystemTime()
    if now - lastSampleTime < interval then
        return
    end

    lastSampleTime = now

    local visitedJob        = {}
    local visitedPartyRoot  = {}

    ForEachOnlinePlayer(function(player)
        local cid = player:getID()
        if not visitedJob[cid] then
            TelemetryAddJobSample(player:getMainJob(), player:getSubJob(), 1)
            visitedJob[cid] = true
        end

        local party = player:getParty()
        if not party then
            return
        end

        local pcs   = {}
        local minId = nil

        for _, member in pairs(party) do
            if member and member:getObjType() == xi.objType.PC then
                local mid = member:getID()
                table.insert(pcs, {
                    id   = mid,
                    mjob = member:getMainJob(),
                    sjob = member:getSubJob(),
                })

                if not minId or mid < minId then
                    minId = mid
                end
            end
        end

        if not minId or #pcs == 0 then
            return
        end

        if visitedPartyRoot[minId] then
            return
        end

        visitedPartyRoot[minId] = true

        table.sort(pcs, function(a, b)
            if a.mjob ~= b.mjob then
                return a.mjob < b.mjob
            end

            if a.sjob ~= b.sjob then
                return a.sjob < b.sjob
            end

            return a.id < b.id
        end)

        local parts = {}
        for _, p in ipairs(pcs) do
            table.insert(parts, formatJobPair(p.mjob, p.sjob))
        end

        TelemetryAddPartySetupSample(table.concat(parts, '+'), 1)
    end)
end

return xi.telemetry
