-----------------------------------
-- Area: Windurst Waters [S]
--  NPC: Ezura-Romazura
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.WINDURST_WATERS_S].text.EZURAROMAZURA_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
