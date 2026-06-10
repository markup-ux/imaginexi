-----------------------------------
-- Area: Bastok Markets
--  NPC: Harmodios
-- !pos -79.928 -4.824 -135.114 235
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.GEMSHORN,                      5416, 3 },
        { xi.item.CORNETTE,                       256, 2 },
        { xi.item.FLUTE,                           50, 3 },
        { xi.item.PICCOLO,                       1144, 1 },
        { xi.item.MAPLE_HARP,                      50, 2 },
    }

    player:showText(npc, zones[xi.zone.BASTOK_MARKETS].text.HARMODIOS_SHOP_DIALOG)
    xi.shop.nation(player, stock, xi.nation.BASTOK)
end

return entity
