-----------------------------------
-- Area: Batok Markets
--  NPC: Zaira
-- !pos -217.316 -2.824 49.235 235
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.BASTOK_MARKETS].text.ZAIRA_SHOP_DIALOG)
    xi.shop.nation(player, stock, xi.nation.BASTOK)
end

return entity
