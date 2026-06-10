-----------------------------------
-- Area: Apollyon
-----------------------------------
zones = zones or {}

zones[xi.zone.APOLLYON] =
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
        YOU_INSERT_THE_CARD_POLISHED  = 7395, -- You insert the card polished to a brilliant shine.
        HUM                           = 7067, -- You hear a faint hum.
        TIME_EXTENDED                 = 7363, -- Your time in Limbus has been extended <number> [minute/minutes].
        TIME_LEFT                     = 7364, -- You have <number> [minute/minutes] left in Limbus.
        GATE_OPEN                     = 7545, -- A vortex materializes...
        NO_BATTLEFIELD_ENTRY          = 7049, -- You do not meet the requirements to enter the battlefield.
        CONQUEST_BASE                 = 7068, -- Tallying conquest results...
    },
    mob =
    {
        -- These IDs are fixed for this zone and avoid DB-name lookup failures
        -- when spawn rows are pruned/commented in custom datasets.
        CS_CARNAGECHIEF_JACKBODOKK = 16933129,
        CS_DEE_WAPA_THE_DESOLATOR  = 16933144,
        CS_NAQBA_CHIRURGEON        = 16933137,

        NE_APOLLYON_SWEEPER_OFFSET   = 16933081,
        NE_GOOBBUE_HARVESTER         = 16933044,
        NE_TROGLODYTE_DHALMEL_OFFSET = 16933115,

        NW_APOLLYON_SCAVENGER_OFFSET = 16932964,
        NW_BARDHA_OFFSET             = 16932938,
        NW_CYNOPROSOPI               = 16932976,
        NW_GORYNICH_OFFSET           = 16932977,
        NW_KAISER_BEHEMOTH           = 16932985,
        NW_MILLENARY_MOSSBACK        = 16932963,
        NW_MOUNTAIN_BUFFALO_OFFSET   = 16932951,
        NW_PLUTO                     = 16932937,
        NW_ZLATOROG                  = 16932950,

        SE_ADAMANTSHELL_OFFSET = 16933007,
        SE_FLYING_SPEAR_OFFSET = 16933033,
        SE_TIEHOLTSODI         = 16933006,

        SW_BOSS_JIDRA               = 16932881,
        SW_AIR_ELEMENTAL_OFFSET     = 16932918,
        SW_DARK_ELEMENTAL_OFFSET    = 16932919,
        SW_EARTH_ELEMENTAL_OFFSET   = 16932920,
        SW_FIRE_ELEMENTAL_OFFSET    = 16932921,
        SW_ICE_ELEMENTAL_OFFSET     = 16932922,
        SW_LIGHT_ELEMENTAL_OFFSET   = 16932923,
        SW_THUNDER_ELEMENTAL_OFFSET = 16932925,
        SW_WATER_ELEMENTAL_OFFSET   = 16932924,
    },
    npc =
    {
        -- Static IDs: Limbus armoury NPC rows are commented in npc_list.sql (Feb 2025 client note).
        CENTRAL_LOOT_CRATE = 16933123,
        CS_LOOT_CRATE      = 16933126,
        NE_LOOT_CRATE      = 16933112,
        NW_LOOT_CRATE      = 16932984,
        SE_LOOT_CRATE      = 16933031,
        SW_LOOT_CRATE      = 16932909,
    },

    SW_APOLLYON =
    {
        npc =
        {
            PORTAL =
            {
                16933231,
                16933232,
                16933233,
            },
            ITEM_CRATES =
            {
                16932865,
                16932878,
                16932896,
            },

            RECOVER_CRATES =
            {
                16932867,
                16932880,
                16932898,
            },

            TIME_CRATES =
            {
                16932866,
                16932879,
                16932897,
            },
        },

        LINKED_CRATES =
        {
            [16932865] = { 16932866, 16932867 },
            [16932866] = { 16932865, 16932867 },
            [16932867] = { 16932865, 16932866 },
            [16932878] = { 16932879, 16932880 },
            [16932879] = { 16932878, 16932880 },
            [16932880] = { 16932878, 16932879 },
        },
    },

    SE_APOLLYON =
    {
        npc =
        {
            PORTAL =
            {
                16933240,
                16933239,
                16933242,
            },
            ITEM_CRATES =
            {
                16932991,
                16933005,
                16933019,
            },
            RECOVER_CRATES =
            {
                16932990,
                16933004,
                16933018,
            },
            TIME_CRATES =
            {
                16932989,
                16933003,
                16933017,
            },
        },
    },

    NW_APOLLYON =
    {
        npc =
        {
            PORTAL =
            {
                16933227,
                16933228,
                16933229,
                16933225,
            },
            ITEM_CRATES =
            {
                16932934,
                16932947,
                16932960,
                16932973,
            },

            RECOVER_CRATES =
            {
                16932936,
                16932949,
                16932962,
                16932983,
            },

            TIME_CRATES =
            {
                16932935,
                16932945,
                16932946,
                16932948,
                16932958,
                16932959,
                16932961,
                16932971,
                16932972,
                16932974,
                16932975,
                16932982,
            },
        },
    },

    NE_APOLLYON =
    {
        npc =
        {
            PORTAL =
            {
                16933236,
                16933235,
                16933234,
                16933238,
            },
            ITEM_CRATES =
            {
                16933041,
                16933059,
                16933076,
                16933096,
            },

            RECOVER_CRATES =
            {
                16933053,
                16933061,
                16933078,
                16933098,
            },

            TIME_CRATES =
            {
                16933042,
                16933043,
                16933054,
                16933060,
                16933074,
                16933075,
                16933077,
                16933079,
                16933080,
                16933097,
                16933110,
                16933111,
            },
        },
    },

    CENTRAL_APOLLYON =
    {
    },

    CS_APOLLYON =
    {
        npc =
        {
            TIME_CRATES =
            {
                16933127,
                16933128,
            },
        },
    },
}

return zones[xi.zone.APOLLYON]
