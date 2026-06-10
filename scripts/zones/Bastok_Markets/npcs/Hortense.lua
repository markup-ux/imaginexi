-----------------------------------
-- Area: Bastok Markets
--  NPC: Hortense
-- !pos -82.503 -4.849 -132.376 235
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.BASTOK_MARKETS].text.HORTENSE_SHOP_DIALOG)
    xi.shop.nation(player, stock, xi.nation.BASTOK)
end

return entity
