-----------------------------------
-- Area: Lower Jeuno
--  NPC: Creepstix
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, zones[xi.zone.LOWER_JEUNO].text.JUNK_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
