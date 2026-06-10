-----------------------------------
-- Area: Nashmau
--  NPC: Mamaroon
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.WHITE_PUPPET_TURBAN,     29950 },
        { xi.item.BLACK_PUPPET_TURBAN,     29950 },
    }

    player:showText(npc, zones[xi.zone.NASHMAU].text.MAMAROON_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
