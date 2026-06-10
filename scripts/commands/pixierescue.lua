-----------------------------------
-- func: pixierescue
-- desc: Dispatch pixie rescue to all dead online players.
-----------------------------------

---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = ''
}

commandObj.onTrigger = function(player)
    if not xi.pixieRescue or not xi.pixieRescue.dispatchToPlayer then
        player:printToPlayer('[pixierescue] pixie_rescue globals not loaded.')
        return
    end

    local deadFound = 0
    local dispatched = 0
    local skippedReraise = 0
    local skippedOther = 0
    local visitedZone = {}

    for _, zoneId in pairs(xi.zone) do
        if type(zoneId) == 'number' and not visitedZone[zoneId] then
            visitedZone[zoneId] = true
            local zone = GetZone(zoneId)
            if zone then
                for _, p in pairs(zone:getPlayers() or {}) do
                    if p and p:isPC() and p:isDead() then
                        deadFound = deadFound + 1
                        local ok, reason = xi.pixieRescue.dispatchToPlayer(p, { ignoreCooldown = true, ignoreReraise = false })
                        if ok then
                            dispatched = dispatched + 1
                        elseif reason == 'reraise' then
                            skippedReraise = skippedReraise + 1
                        else
                            skippedOther = skippedOther + 1
                        end
                    end
                end
            end
        end
    end

    local summary = string.format(
        '[pixierescue] dead=%u dispatched=%u skipped_reraise=%u skipped_other=%u',
        deadFound,
        dispatched,
        skippedReraise,
        skippedOther
    )

    print(summary)
    player:printToPlayer(summary)
end

return commandObj
