-----------------------------------
-- Zone: North_Gustaberg (106)
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    xi.conquest.setRegionalConquestOverseers(zone:getRegionID())
    xi.voidwalker.zoneOnInit(zone)

    if xi.imagine and xi.imagine.starterElementals then
        xi.imagine.starterElementals.northGustaberg(zone)
    end

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
        player:setPos(660, 0, 306, 190)
    end

    return cs
end

zoneObject.afterZoneIn = function(player)
    xi.chocoboGame.handleMessage(player)

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
