-----------------------------------
-- Area: Temenos
-----------------------------------
zones = zones or {}

zones[xi.zone.TEMENOS] =
{
    text =
    {
        ITEM_CANNOT_BE_OBTAINED       = 6385, -- You cannot obtain the <item>. Come back after sorting your inventory.
        ITEM_OBTAINED                 = 6391, -- Obtained: <item>.
        GIL_OBTAINED                  = 6392, -- Obtained <number> gil.
        KEYITEM_OBTAINED              = 6394, -- Obtained key item: <keyitem>.
        CARRIED_OVER_POINTS           = 7002, -- You have carried over <number> login point[/s].
        LOGIN_CAMPAIGN_UNDERWAY       = 7003, -- The [/January/February/March/April/May/June/July/August/September/October/November/December] <number> Login Campaign is currently underway!
        LOGIN_NUMBER                  = 7004, -- In celebration of your most recent login (login no. <number>), we have provided you with <number> points! You currently have a total of <number> points.
        MEMBERS_LEVELS_ARE_RESTRICTED = 7024, -- Your party is unable to participate because certain members' levels are restricted.
        CHIP_TRADE_T                  = 7031, -- What do you wish to do? Show me the cutscene again. Skip the cutscene and continue.
        YOU_INSERT_THE_CARD_POLISHED  = 7395, -- You insert the card polished to a brilliant shine.
        HUM                           = 7071, -- You hear a faint hum.
        TIME_EXTENDED                 = 7372, -- Your time in Limbus has been extended <number> [minute/minutes].
        TIME_LEFT                     = 7373, -- You have <number> [minute/minutes] left in Limbus.
        GATE_OPEN                     = 7557, -- The gate opens...
        CANNOT_OPEN_CHEST             = 7556, -- You cannot open the treasure chest now.
        NO_BATTLEFIELD_ENTRY          = 7049, -- You do not meet the requirements to enter the battlefield.
        CONQUEST_BASE                 = 7068, -- Tallying conquest results...
    },
    mob =
    {
    },
    npc =
    {
        -- Static IDs: see commented npc_list.sql Temenos Limbus crates.
        C1_LOOT_CRATE = 16929045,
        C2_LOOT_CRATE = 16929029,
        C3_LOOT_CRATE = 16929004,
        C4_LOOT_CRATE = 16928965,
        CB_LOOT_CRATE = 16929052,
        N_LOOT_CRATE  = 16928830,
        W_LOOT_CRATE  = 16928958,
    },

    TEMENOS_NORTHERN_TOWER =
    {
        mob =
        {
            MOBLIN_DUSTMAN = 16928774,
            KARI = 16928784,
            TELCHINES_DRAGOON = 16928790,
            TELCHINES_MONK = 16928792,
            KINDRED_BLACK_MAGE = 16928802,
            CRYPTONBERRY_ABDUCTOR = 16928818,
            CRYPTONBERRY_DESIGNATOR = 16928819,
        },

        npc =
        {
            PORTAL =
            {
                16929198,
                16929199,
                16929200,
                16929201,
                16929202,
                16929203,
                16929204,
            },

            ITEM_CRATES =
            {
                16928770,
                16928779,
                16928786,
                16928795,
                16928807,
                16928814,
            },

            TIME_CRATES =
            {
                16928771,
                16928780,
                16928787,
                16928796,
                16928808,
                16928815,
            },

            RECOVER_CRATES =
            {
                16928769,
                16928778,
                16928785,
                16928794,
                16928806,
                16928813,
            },
        },

        LINKED_CRATES =
        {
            [16932865] = { 16932866, 16932867 },
            [16928769] = { 16928770, 16928771 },
            [16928770] = { 16928769, 16928771 },
            [16928771] = { 16928769, 16928770 },
            [16928778] = { 16928779, 16928780 },
            [16928779] = { 16928778, 16928780 },
            [16928780] = { 16928778, 16928779 },
            [16928785] = { 16928786, 16928787 },
            [16928786] = { 16928785, 16928787 },
            [16928787] = { 16928785, 16928786 },
            [16928794] = { 16928795, 16928796 },
            [16928795] = { 16928794, 16928796 },
            [16928796] = { 16928794, 16928795 },
            [16928806] = { 16928807, 16928808 },
            [16928807] = { 16928806, 16928808 },
            [16928808] = { 16928806, 16928807 },
            [16928813] = { 16928814, 16928815 },
            [16928814] = { 16928813, 16928815 },
            [16928815] = { 16928813, 16928814 },
        },
    },

    TEMENOS_WESTERN_TOWER =
    {
        mob =
        {
            ENHANCED_TIGER      = 16928898,
            ENHANCED_MANDRAGORA = 16928910,
            ENHANCED_BEETLE     = 16928922,
            ENHANCED_LIZARD     = 16928931,
            ENHANCED_SLIME      = 16928943,
        },
        npc =
        {
            PORTAL =
            {
                16929212,
                16929213,
                16929214,
                16929215,
                16929216,
                16929217,
                16929218,
            },
            CRATE_OFFSETS =
            {
                16928895,
                16928907,
                16928919,
                16928928,
                16928940,
                16928949,
            },
        },
    },

    TEMENOS_EASTERN_TOWER =
    {
        mob =
        {
            ICE_ELEMENTAL     = 16928849,
            AIR_ELEMENTAL     = 16928858,
            THUNDER_ELEMENTAL = 16928876,
        },
        npc =
        {
            PORTAL =
            {
                16929205,
                16929206,
                16929207,
                16929208,
                16929209,
                16929210,
                16929211,
            },
            CRATE_OFFSETS =
            {
                16928836,
                16928845,
                16928854,
                16928863,
                16928872,
                16928881,
                16928890,
            },
        },
    },

    -- Central instances use loot crates from top-level npc; optional PORTAL/CRATE data not required for these BFs.
    CENTRAL_TEMENOS_BASEMENT  = { npc = {} },
    CENTRAL_TEMENOS_1ST_FLOOR = { npc = {} },
    CENTRAL_TEMENOS_2ND_FLOOR = { npc = {} },
    CENTRAL_TEMENOS_3RD_FLOOR = { npc = {} },

    CENTRAL_TEMENOS_4TH_FLOOR =
    {
        npc =
        {
            GROUPS =
            {
                { offset = 16928967, count = 4 },
                { offset = 16928971, count = 7 },
                { offset = 16928978, count = 8 },
            },
        },
        mob =
        {
            GROUPS =
            {
                { offset = 16928986, count = 3 },
                { offset = 16928991, count = 6 },
                { offset = 16928997, count = 7 },
            },
        },
    },
}

return zones[xi.zone.TEMENOS]
