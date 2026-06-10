-----------------------------------
-- Area: Norg
--  NPC: Solby-Maholby
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.LUGWORM,                      9 },
        { xi.item.EARTH_SPIRIT_PACT,          450 },
        { xi.item.NORG_WAYSTONE,             9000 },
    }

    player:showText(npc, zones[xi.zone.NORG].text.SOLBYMAHOLBY_SHOP_DIALOG, 0, 0, 0, 0, true, false)
    xi.shop.general(player, stock)
end

return entity
