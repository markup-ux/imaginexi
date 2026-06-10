-----------------------------------
-- Area: Aht Urhgan Whitegate
--  NPC: Mazween
-----------------------------------
local ID = zones[xi.zone.AHT_URHGAN_WHITEGATE]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, ID.text.MAZWEEN_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
