-----------------------------------
-- func: telemetry
-- desc: Show aggregated telemetry (jobs / party setups). Requires migration 2026_05_03_server_telemetry.sql.
-- usage: !telemetry [limit]   (default 12, max 64)
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 3,
    parameters = 'i'
}

commandObj.onTrigger = function(player, limit)
    local n = limit
    if n == nil or n < 1 then
        n = 12
    end

    player:printToPlayer('=== Telemetry: main jobs (aggregated) ===', xi.msg.channel.SYSTEM_3)
    local mains = GetTelemetryTopMainJobs(n)
    local any   = false
    for i = 1, n do
        local row = mains[i]
        if row and row.mjob then
            any = true
            player:printToPlayer(string.format('  %2u. mjob=%u  samples=%s', row.position, row.mjob, tostring(row.samples)), xi.msg.channel.SYSTEM_3)
        end
    end

    if not any then
        player:printToPlayer('  (no rows — enable TELEMETRY_ENABLED and apply SQL migration)', xi.msg.channel.SYSTEM_3)
    end

    player:printToPlayer('=== Telemetry: main/sub pairs ===', xi.msg.channel.SYSTEM_3)
    any = false
    local pairsTbl = GetTelemetryTopJobPairs(n)
    for i = 1, n do
        local row = pairsTbl[i]
        if row and row.mjob then
            any = true
            player:printToPlayer(string.format('  %2u. %u/%u  samples=%s', row.position, row.mjob, row.sjob, tostring(row.samples)), xi.msg.channel.SYSTEM_3)
        end
    end

    if not any then
        player:printToPlayer('  (no rows)', xi.msg.channel.SYSTEM_3)
    end

    player:printToPlayer('=== Telemetry: party setups (PC only, sorted jobs) ===', xi.msg.channel.SYSTEM_3)
    any = false
    local parties = GetTelemetryTopPartySetups(n)
    for i = 1, n do
        local row = parties[i]
        if row and row.setup then
            any = true
            player:printToPlayer(string.format('  %2u. samples=%s  %s', row.position, tostring(row.samples), row.setup), xi.msg.channel.SYSTEM_3)
        end
    end

    if not any then
        player:printToPlayer('  (no rows)', xi.msg.channel.SYSTEM_3)
    end
end

return commandObj
