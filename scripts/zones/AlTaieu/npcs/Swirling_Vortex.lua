-----------------------------------
-- Area: Al'Taieu
--  NPC: Swirling_Vortex
-- ImagineXI: open legacy Limbus zones — no key items required.
-----------------------------------
local ID = zones[xi.zone.ALTAIEU]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local offset = npc:getID() - ID.npc.SWIRLING_VORTEX_OFFSET

    if offset < 0 or offset > 1 then
        return
    end

    player:startEvent(159 + offset)
end

entity.onEventFinish = function(player, csid, option, npc)
    if option ~= 1 then
        return
    end

    if csid == 160 then
        player:setPos(580, -1.5, 4.452, 192, xi.zone.TEMENOS)
    elseif csid == 159 then
        player:setPos(643, 0.1, -600, 192, xi.zone.APOLLYON)
    end
end

return entity
