-----------------------------------
-- Area: Bastok Markets
--  NPC: Sororo
-- !pos -220.217 -2.824 51.542 235
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.BASTOK_MARKETS].text.SORORO_SHOP_DIALOG)
    xi.shop.nation(player, stock, xi.nation.BASTOK)
end

return entity
