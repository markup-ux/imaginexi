-----------------------------------
-- Area: Selbina
--  NPC: Falgima
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.SELBINA].text.FALGIMA_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
