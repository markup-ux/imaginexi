-----------------------------------
-- Area: Al Zahbi
--  NPC: Zafif
-----------------------------------
local ID = zones[xi.zone.AL_ZAHBI]
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
    }

    player:showText(npc, ID.text.ZAFIF_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
