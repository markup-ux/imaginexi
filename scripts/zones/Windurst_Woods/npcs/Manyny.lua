-----------------------------------
-- Area: Windurst Woods
--  NPC: Manyny
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.WINDURST_WOODS].text.MANYNY_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
