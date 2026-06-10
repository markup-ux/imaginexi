-----------------------------------
-- Area: Port Jeuno
--  NPC: Leyla
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.HAWKEYE,                      60 },
        { xi.item.IRON_ARROW,                    8 },
        { xi.item.CROSSBOW_BOLT,                 6 },
        { xi.item.FLASK_OF_DISTILLED_WATER,     12 },
    }

    player:showText(npc, zones[xi.zone.PORT_JEUNO].text.DUTY_FREE_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
