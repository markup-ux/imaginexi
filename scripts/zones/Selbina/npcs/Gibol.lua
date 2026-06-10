-----------------------------------
-- Area: Selbina
--  NPC: Gibol
-- Sheep merchant near Melyon
-- !pos 13.591 -7.287 8.569 248
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        xi.item.EAR_OF_MILLIONCORN,    49,
        xi.item.LA_THEINE_CABBAGE,     25,
        xi.item.CLUMP_OF_BOYAHDA_MOSS, 1200,
    }

    xi.shop.general(player, stock, xi.fameArea.SELBINA_RABAO)
end

return entity
