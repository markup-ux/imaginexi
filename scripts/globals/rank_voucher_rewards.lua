-----------------------------------
-- Nation rank Equipment Voucher rewards (deterministic).
-- Edit item IDs here; keys are job abbreviations and level brackets (10-75).
-- Brackets: 1-10 -> 10, 11-20 -> 20, ... 61+ -> 75.
-----------------------------------
xi = xi or {}

local I = xi.item

-- Item IDs not present in xi.item (verified in item_basic.sql).
local EXTRA =
{
    JAMBIYA          = 18023,
    BHUJ             = 16707,
    CRUEL_SPEAR      = 16863,
    CARBUNCLE_MITTS  = 14062,
    SOLID_WAND       = 17141,
    YEW_WAND_P1      = 17140,
    NOBLES_TUNIC     = 12605,
    SHINOBI_GATANA   = 16919,
    SOBORO           = 17813, -- soboro_sukehiro
    SEERS_CROWN      = 15163,
    HERMITS_WAND     = 17413,
    DOLPHIN_STAFF    = 17134,
    TEMPLAR_MACE     = 18841,
}

---@type table<string, table<integer, integer>>
xi.rank_voucher_rewards =
{
    WAR =
    {
        [10] = I.LEGIONNAIRES_AXE,
        [20] = I.BRONZE_ZAGHNAL,
        [30] = I.GAWAINS_AXE,
        [40] = EXTRA.BHUJ,
        [50] = I.PERDU_VOULGE,
        [60] = I.PERDU_VOULGE,
        [75] = I.PERDU_VOULGE,
    },
    MNK =
    {
        [10] = I.DESTROYERS,
        [20] = I.FAITH_BAGHNAKHS,
        [30] = I.DESTROYERS,
        [40] = I.FAITH_BAGHNAKHS,
        [50] = I.DESTROYERS,
        [60] = I.WALAHRA_TURBAN,
        [75] = I.WALAHRA_TURBAN,
    },
    WHM =
    {
        [10] = I.WILLOW_WAND_P1,
        [20] = EXTRA.YEW_WAND_P1,
        [30] = EXTRA.SOLID_WAND,
        [40] = EXTRA.DOLPHIN_STAFF,
        [50] = I.HEALING_STAFF,
        [60] = I.LIGHT_STAFF,
        [75] = EXTRA.TEMPLAR_MACE,
    },
    BLM =
    {
        [10] = I.HOLLY_STAFF,
        [20] = EXTRA.DOLPHIN_STAFF,
        [30] = EXTRA.SOLID_WAND,
        [40] = I.HIGH_MANA_WAND,
        [50] = I.DARK_STAFF,
        [60] = I.DARK_STAFF,
        [75] = I.PERDU_STAFF,
    },
    RDM =
    {
        [10] = I.WILLOW_WAND_P1,
        [20] = EXTRA.YEW_WAND_P1,
        [30] = EXTRA.SOLID_WAND,
        [40] = I.PERDU_SWORD,
        [50] = I.PERDU_SWORD,
        [60] = EXTRA.NOBLES_TUNIC,
        [75] = I.PERDU_SWORD,
    },
    THF =
    {
        [10] = EXTRA.JAMBIYA,
        [20] = EXTRA.JAMBIYA,
        [30] = I.PERDU_BLADE,
        [40] = I.PERDU_BLADE,
        [50] = I.ASSASSINS_BONNET,
        [60] = I.PERDU_BLADE,
        [75] = I.PERDU_BLADE,
    },
    PLD =
    {
        [10] = I.HOLY_MACE,
        [20] = I.KOENIG_SHIELD,
        [30] = I.VALOR_CORONET,
        [40] = I.VALOR_CORONET,
        [50] = I.PERDU_SWORD,
        [60] = I.PERDU_SWORD,
        [75] = I.EXCALIBUR_75,
    },
    DRK =
    {
        [10] = I.BRONZE_ZAGHNAL,
        [20] = I.GAWAINS_AXE,
        [30] = I.GAWAINS_AXE,
        [40] = I.PERDU_VOULGE,
        [50] = I.PERDU_VOULGE,
        [60] = I.PERDU_VOULGE,
        [75] = I.APOCALYPSE_75,
    },
    BST =
    {
        [10] = I.LEGIONNAIRES_AXE,
        [20] = I.GAWAINS_AXE,
        [30] = EXTRA.BHUJ,
        [40] = I.HUNTERS_BERET,
        [50] = I.GAWAINS_AXE,
        [60] = I.GAWAINS_AXE,
        [75] = I.GAWAINS_AXE,
    },
    BRD =
    {
        [10] = EXTRA.JAMBIYA,
        [20] = I.PERDU_HANGER,
        [30] = I.CHORAL_ROUNDLET,
        [40] = I.CHORAL_ROUNDLET,
        [50] = I.PERDU_HANGER,
        [60] = I.PERDU_HANGER,
        [75] = I.PERDU_HANGER,
    },
    RNG =
    {
        [10] = I.POWER_BOW,
        [20] = I.POWER_BOW,
        [30] = I.CROSSBOW,
        [40] = I.YOICHINOYUMI_75,
        [50] = I.YOICHINOYUMI_75,
        [60] = I.SKADIS_VISOR,
        [75] = I.YOICHINOYUMI_75,
    },
    SAM =
    {
        [10] = I.BRONZE_SPEAR,
        [20] = EXTRA.CRUEL_SPEAR,
        [30] = EXTRA.SOBORO,
        [40] = I.HAGUN,
        [50] = I.HAGUN,
        [60] = I.WALAHRA_TURBAN,
        [75] = I.HAGUN,
    },
    NIN =
    {
        [10] = EXTRA.SHINOBI_GATANA,
        [20] = EXTRA.SHINOBI_GATANA,
        [30] = I.KOGA_HATSUBURI,
        [40] = I.PERDU_BLADE,
        [50] = I.PERDU_BLADE,
        [60] = I.PERDU_BLADE,
        [75] = I.KIKOKU_75,
    },
    DRG =
    {
        [10] = EXTRA.CRUEL_SPEAR,
        [20] = EXTRA.CRUEL_SPEAR,
        [30] = EXTRA.BHUJ,
        [40] = I.DRACHEN_ARMET,
        [50] = I.PERDU_VOULGE,
        [60] = I.PERDU_VOULGE,
        [75] = I.GUNGNIR_75,
    },
    SMN =
    {
        [10] = EXTRA.HERMITS_WAND,
        [20] = EXTRA.CARBUNCLE_MITTS,
        [30] = I.BLACK_TUNIC,
        [40] = I.EVOKERS_HORN,
        [50] = I.DARK_STAFF,
        [60] = I.NIRVANA_75,
        [75] = I.NIRVANA_75,
    },
    BLU =
    {
        [10] = EXTRA.JAMBIYA,
        [20] = I.PERDU_SWORD,
        [30] = I.PERDU_BLADE,
        [40] = I.MIRAGE_KEFFIYEH,
        [50] = I.PERDU_SWORD,
        [60] = I.PERDU_SWORD,
        [75] = I.PERDU_SWORD,
    },
    COR =
    {
        [10] = I.CROSSBOW,
        [20] = I.TRUMP_GUN,
        [30] = I.TRUMP_GUN,
        [40] = I.CORSAIRS_TRICORNE,
        [50] = I.PERDU_CROSSBOW,
        [60] = I.PERDU_CROSSBOW,
        [75] = I.TRUMP_GUN,
    },
    PUP =
    {
        [10] = I.BRONZE_MACE,
        [20] = I.TURBO_ANIMATOR,
        [30] = I.MARTIAL_BHUJ,
        [40] = I.PANTIN_TAJ,
        [50] = I.MARTIAL_BHUJ,
        [60] = I.MARTIAL_BHUJ,
        [75] = I.MARTIAL_BHUJ,
    },
    DNC =
    {
        [10] = EXTRA.JAMBIYA,
        [20] = EXTRA.JAMBIYA,
        [30] = I.PERDU_BLADE,
        [40] = I.PERDU_BLADE,
        [50] = I.ASSASSINS_BONNET,
        [60] = I.PERDU_BLADE,
        [75] = I.PERDU_BLADE,
    },
    SCH =
    {
        [10] = I.HOLLY_STAFF,
        [20] = EXTRA.SEERS_CROWN,
        [30] = EXTRA.SEERS_CROWN,
        [40] = I.HEALERS_CAP,
        [50] = I.ARGUTE_GOWN,
        [60] = I.TUPSIMATI_75,
        [75] = I.TUPSIMATI_75,
    },
}

-- Broad-use fallbacks when a job has no table entry (or bracket is missing).
xi.rank_voucher_rewards.FALLBACK =
{
    [10] = I.LEATHER_BELT,
    [20] = I.SWIFT_BELT,
    [30] = I.SWIFT_BELT,
    [40] = I.RAJAS_RING,
    [50] = I.RAJAS_RING,
    [60] = I.RAJAS_RING,
    [75] = I.RAJAS_RING,
}
