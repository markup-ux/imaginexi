-----------------------------------
-- Area: Rabao
--  NPC: Brave Ox
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.RABAO].text.BRAVEOX_SHOP_DIALOG)
    xi.shop.general(player, stock, xi.fameArea.SELBINA_RABAO)
end

return entity
