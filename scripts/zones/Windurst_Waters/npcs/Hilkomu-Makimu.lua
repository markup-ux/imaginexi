-----------------------------------
-- Area: Windurst Waters
--  NPC: Hilkomu-Makimu
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.WINDURST_WATERS].text.HIKOMUMAKIMU_SHOP_DIALOG)
    xi.shop.nation(player, stock, xi.nation.WINDURST)
end

return entity
