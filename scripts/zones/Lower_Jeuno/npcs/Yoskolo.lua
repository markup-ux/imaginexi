-----------------------------------
-- Area: Lower Jeuno
--  NPC: Yoskolo
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.FLASK_OF_DISTILLED_WATER,       12 },
        { xi.item.BOTTLE_OF_ORANGE_JUICE,        200 },
        { xi.item.BOTTLE_OF_APPLE_JUICE,         300 },
        { xi.item.BOTTLE_OF_MELON_JUICE,        1100 },
        { xi.item.BOTTLE_OF_GRAPE_JUICE,         930 },
        { xi.item.BOTTLE_OF_PINEAPPLE_JUICE,     400 },
        { xi.item.SERVING_OF_ICECAP_ROLANBERRY, 5544 },
    }

    player:showText(npc, zones[xi.zone.LOWER_JEUNO].text.YOSKOLO_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
