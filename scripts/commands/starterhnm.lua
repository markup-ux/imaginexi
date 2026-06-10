-----------------------------------
-- func: starterhnm
-- desc: GM tools for starter-zone lowbie HNMs.
-- usage:
--   !starterhnm              spawn in current zone (at configured coords)
--   !starterhnm here         spawn in current zone at your position
--   !starterhnm all          spawn one in every starter zone
--   !starterhnm status       show XP pool / cooldown / active state
--   !starterhnm <zoneId>     spawn in a specific zone (100, 101, 106, 107, 115, 116)
-----------------------------------

---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's'
}

local STARTER_ZONE_IDS =
{
    xi.zone.WEST_RONFAURE,
    xi.zone.EAST_RONFAURE,
    xi.zone.NORTH_GUSTABERG,
    xi.zone.SOUTH_GUSTABERG,
    xi.zone.WEST_SARUTABARUTA,
    xi.zone.EAST_SARUTABARUTA,
}

local function usage(player)
    player:printToPlayer('!starterhnm [here|all|status|<zoneId>]')
    player:printToPlayer('Zones: 100 West Ronfaure, 101 East Ronfaure, 106 North Gustaberg,')
    player:printToPlayer('       107 South Gustaberg, 115 West Saruta, 116 East Saruta')
end

local function requireModule(player)
    if not xi.imagine or not xi.imagine.starterHnm or not xi.imagine.starterHnm.gmSpawn then
        player:printToPlayer('[starterhnm] imagine_starter_hnm globals not loaded.')
        return nil
    end

    return xi.imagine.starterHnm
end

commandObj.onTrigger = function(player, arg)
    local starterHnm = requireModule(player)

    if not starterHnm then
        return
    end

    local token = arg and string.lower(arg) or ''

    if token == '' or token == 'spawn' then
        local zoneId = player:getZoneID()
        local ok, msg = starterHnm.gmSpawn(zoneId)

        if ok then
            player:printToPlayer(string.format('[starterhnm] Spawned %s in zone %u.', msg, zoneId))
        else
            player:printToPlayer(string.format('[starterhnm] Failed zone %u: %s', zoneId, msg))
        end
        return
    end

    if token == 'here' then
        local zoneId = player:getZoneID()
        local ok, msg = starterHnm.gmSpawn(zoneId, { atPlayer = player })

        if ok then
            player:printToPlayer(string.format('[starterhnm] Spawned %s at your position (zone %u).', msg, zoneId))
        else
            player:printToPlayer(string.format('[starterhnm] Failed zone %u: %s', zoneId, msg))
        end
        return
    end

    if token == 'all' then
        local spawned = 0

        for _, zoneId in ipairs(STARTER_ZONE_IDS) do
            local ok, msg = starterHnm.gmSpawn(zoneId)

            if ok then
                spawned = spawned + 1
                player:printToPlayer(string.format('[starterhnm] Spawned %s in zone %u.', msg, zoneId))
            else
                player:printToPlayer(string.format('[starterhnm] Skipped zone %u: %s', zoneId, msg))
            end
        end

        player:printToPlayer(string.format('[starterhnm] Done. Spawned %u/%u.', spawned, #STARTER_ZONE_IDS))
        return
    end

    if token == 'status' then
        local zoneId = player:getZoneID()
        local status = starterHnm.getZoneStatus(zoneId)

        if not status then
            player:printToPlayer(string.format('[starterhnm] Zone %u is not a starter HNM zone.', zoneId))
            player:printToPlayer('[starterhnm] Use !starterhnm here while in a starter field, or pass a zone ID.')
            return
        end

        player:printToPlayer(string.format(
            '[starterhnm] %s (zone %u): XP %u / %u, active=%s, cooldown=%ss',
            status.name,
            status.zoneId,
            status.xp,
            status.threshold,
            status.active and 'yes' or 'no',
            status.cooldownSec
        ))
        return
    end

    local zoneId = tonumber(token)

    if zoneId then
        local ok, msg = starterHnm.gmSpawn(zoneId)

        if ok then
            player:printToPlayer(string.format('[starterhnm] Spawned %s in zone %u.', msg, zoneId))
        else
            player:printToPlayer(string.format('[starterhnm] Failed zone %u: %s', zoneId, msg))
        end
        return
    end

    usage(player)
end

return commandObj
