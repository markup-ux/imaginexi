-----------------------------------
-- Area: Lower Jeuno
--  NPC: Amalasanda
-- Type: Tenshodo Merchant
-- !pos 28.149 2.899 -44.780 245
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrigger = function(player, npc)
    if not player:hasKeyItem(xi.ki.TENSHODO_MEMBERS_CARD) then
        return -- Anti-Cheat.
    end

    local stock =
    {
        { xi.item.BAMBOO_STICK,               151 },
        { xi.item.SQUARE_OF_SILK_CLOTH,     22050 },
        { xi.item.PINCH_OF_BLACK_PEPPER,      267 },
        { xi.item.KOMA,                       231 },
        { xi.item.LUMP_OF_TAMA_HAGANE,       7350 },
        { xi.item.POT_OF_URUSHI,            77206 },
        { xi.item.BOX_OF_STICKY_RICE,         331 },
        { xi.item.ONZ_OF_TURMERIC,            677 },
        { xi.item.ONZ_OF_CORIANDER,          1664 },
        { xi.item.SPRIG_OF_HOLY_BASIL,        840 },
        { xi.item.ONZ_OF_CURRY_POWDER,       1039 },
        { xi.item.JAR_OF_GROUND_WASABI,      2724 },
        { xi.item.BOTTLE_OF_RICE_VINEGAR,     210 },
        { xi.item.BUNDLE_OF_SHIRATAKI,        516 },
        { xi.item.BAG_OF_BUCKWHEAT_FLOUR,    5250 },
    }

    player:showText(npc, zones[xi.zone.LOWER_JEUNO].text.AMALASANDA_SHOP_DIALOG)
    xi.shop.general(player, stock)
end

return entity
