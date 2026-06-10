-----------------------------------
-- Area: Port Windurst
--  NPC: Kususu
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.PORT_WINDURST].text.KUSUSU_SHOP_DIALOG)
    xi.shop.nation(player, stock, xi.nation.WINDURST)
end

return entity
