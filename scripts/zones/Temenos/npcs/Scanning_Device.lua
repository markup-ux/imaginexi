-----------------------------------
-- Area: Temenos
--  NPC: Scanning_Device
-- !pos 586 0 66 37
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    if npcUtil.tradeHas(trade, xi.item.METAL_CHIP) then
        player:startEvent(121, 257)
    elseif npcUtil.tradeHas(trade, { 1986, 1908, 1907 }) then
        player:startEvent(121, 17)
    elseif npcUtil.tradeHas(trade, xi.item.IVORY_CHIP) then
        player:startEvent(121, 33)
    elseif npcUtil.tradeHas(trade, xi.item.SCARLET_CHIP) then
        player:startEvent(121, 65)
    elseif npcUtil.tradeHas(trade, xi.item.EMERALD_CHIP) then
        player:startEvent(121, 129)
    end
end

entity.onTrigger = function(player, npc)
    player:startEvent(121, 511)
end

local timeVarNames =
{
    [1] = '[TEMENOS_NORTHERN_TOWER]Time',
    [2] = '[TEMENOS_EASTERN_TOWER]Time',
    [3] = '[TEMENOS_WESTERN_TOWER]Time',
    [4] = '[CENTRAL_TEMENOS_4TH_FLOOR]Time',
    [5] = '[CENTRAL_TEMENOS_3RD_FLOOR]Time',
    [6] = '[CENTRAL_TEMENOS_2ND_FLOOR]Time',
    [7] = '[CENTRAL_TEMENOS_1ST_FLOOR]Time',
    [8] = '[CENTRAL_TEMENOS_BASEMENT]Time',
}

entity.onEventUpdate = function(player, csid, option, npc)
    if csid ~= 121 or option == utils.EVENT_CANCELLED_OPTION then
        return
    end

    -- option can be 0 on first paint or carry flags in high bits; nil lookup used to break Lua/C++ and softlock the client.
    local varName = timeVarNames[option] or timeVarNames[bit.band(option, 0xF)]
    local towerTime = 0
    if varName ~= nil then
        towerTime = GetServerVariable(varName)
    end

    player:updateEvent(0, towerTime, 0, 0, 0, 0, 0, 0)
end

return entity
