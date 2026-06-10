-----------------------------------
-- Area: Kazham
--  NPC: Toji Mumosulah
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    local stock =
    {
        { xi.item.YELLOW_JAR,                  520 },
        { xi.item.BLOOD_STONE,                 109 },
        { xi.item.FANG_NECKLACE,              4006 },
        { xi.item.BONE_EARRING,               1902 },
        { xi.item.GEMSHORN,                   5418 },
        { xi.item.PEELED_CRAYFISH,              73 },
        { xi.item.BALL_OF_INSECT_PASTE,         42 },
        { xi.item.JUG_OF_FISH_BROTH,            94 },
        { xi.item.JUG_OF_SEEDBED_SOIL,         499 },
        { xi.item.HATCHET,                     525 },
    }

    player:showText(npc, zones[xi.zone.KAZHAM].text.TOJIMUMOSULAH_SHOP_DIALOG)
    xi.shop.general(player, stock, xi.fameArea.WINDURST)
end

return entity
