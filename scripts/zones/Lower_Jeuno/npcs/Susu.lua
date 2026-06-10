-----------------------------------
-- Area: Lower Jeuno
--  NPC: Susu
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.LOWER_JEUNO].text.WAAG_DEEG_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
