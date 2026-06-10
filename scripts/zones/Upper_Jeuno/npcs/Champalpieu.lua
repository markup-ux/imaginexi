-----------------------------------
-- Area: Upper Jeuno
--  NPC: Champalpieu
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.ROLANBERRY,               120 },
        { xi.item.IRON_ARROW,                 8 },
        { xi.item.CROSSBOW_BOLT,              6 },
        { xi.item.PICKAXE,                  200 },
    }

    player:showText(npc, zones[xi.zone.UPPER_JEUNO].text.MP_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
