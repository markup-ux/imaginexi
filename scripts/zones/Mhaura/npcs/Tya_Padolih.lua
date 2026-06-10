-----------------------------------
-- Area: Mhaura
--  NPC: Tya Padolih
-- !pos -48 -4 30 249
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.MHAURA].text.TYAPADOLIH_SHOP_DIALOG)
    xi.shop.general(player, stock, xi.fameArea.WINDURST)
end

return entity
