-----------------------------------
-- Zone: East_Ronfaure (101)
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.helm.initZone(zone, xi.helmType.LOGGING)

    if xi.imagine and xi.imagine.starterHnm then
        xi.imagine.starterHnm.onZoneInit(zone)
    end
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    if
        player:getXPos() == 0 and
        player:getYPos() == 0 and
        player:getZPos() == 0
    then
        player:setPos(86.131, -65.817, 273.861, 25)
    end

    return cs
end

zoneObject.afterZoneIn = function(player)
    if xi.imagine and xi.imagine.starterHnm then
        xi.imagine.starterHnm.onPlayerZoneIn(player)
    end
end

zoneObject.onConquestUpdate = function(zone, updatetype, influence, owner, ranking, isConquestAlliance)
    xi.conquest.onConquestUpdate(zone, updatetype, influence, owner, ranking, isConquestAlliance)
end

zoneObject.onTriggerAreaEnter = function(player, triggerArea)
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
