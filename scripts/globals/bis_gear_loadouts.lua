-----------------------------------
-- Curated 75-era BiS loadouts (priority-ordered per slot).
-- Sources: FFXIclopedia job guides, BG-Wiki gear threads, FFXIAH 75-cap discussions.
-- First equippable item for the player's level/race/job wins.
-----------------------------------
xi = xi or {}
xi.bis_gear_loadouts = xi.bis_gear_loadouts or {}

local I = xi.item

-- Resolved from item_equipment.sql where xi.item has no entry.
local gear =
{
    HAUBERGEON        = 12555,
    KIRINS_OSODE      = 12562,
    NOBLES_TUNIC      = 12605,
    DUSK_GLOVES       = 12701,
    DUSK_TROUSERS     = 12879,
    DUSK_LEDELSENS    = 12957,
    OPTICAL_HAT       = 13915,
    HACHIMAN_KOTE     = 14876,
    AMEMET_MANTLE_P1  = 13646,
    HACHIMAN_SUNE_ATE = 15330,
    SOBORO            = 17813,
    LIGHT_GRIP        = 19037,
    THEW_BOMBLET      = 19249,
    ANCIENT_TORQUE    = 16275,
    PEACOCK_AMULET    = 15515,
    TRIUMPH_EARRING   = 13408,
    BHUJ              = 16707,
    WINDURSTIAN_STAFF = 17537,
    NUMINOUS_SHIELD   = 12409,
    KIRINS_POLE       = 17567,
    FOWLING_EARRING   = 15979,
    CERBERUS_MANTLE   = 16212,
    TEMPLAR_MACE      = 18841,
    MUSE_TARIQAH      = 16175,
    JAMBIYA           = 18023,
}

local function list(...)
    return { ... }
end

local meleeTp =
{
    [xi.slot.HEAD]  = list(I.WALAHRA_TURBAN, gear.OPTICAL_HAT, I.WALKURE_MASK, I.ARES_MASK),
    [xi.slot.BODY]  = list(gear.HAUBERGEON, gear.KIRINS_OSODE, I.ARES_CUIRASS, I.ASKAR_KORAZIN),
    [xi.slot.HANDS] = list(gear.DUSK_GLOVES, I.OCHIUDOS_KOTE, gear.HACHIMAN_KOTE),
    [xi.slot.LEGS]  = list(I.BYAKKOS_HAIDATE, gear.DUSK_TROUSERS, I.SHINIMUSHA_HARA_ATE, I.SHURA_HAIDATE),
    [xi.slot.FEET]  = list(I.FUMA_SUNE_ATE, gear.HACHIMAN_SUNE_ATE, I.AMIR_BOOTS, gear.DUSK_LEDELSENS),
    [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE, gear.ANCIENT_TORQUE, gear.PEACOCK_AMULET),
    [xi.slot.WAIST] = list(I.SWIFT_BELT, I.LIFE_BELT, I.POTENT_BELT, I.WARWOLF_BELT),
    [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, I.BUSHINOMIMI, gear.TRIUMPH_EARRING, gear.FOWLING_EARRING),
    [xi.slot.RING1] = list(I.RAJAS_RING, I.WOODSMAN_RING, I.SOLDIERS_RING),
    [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE, gear.CERBERUS_MANTLE, I.JAGUAR_MANTLE),
}

local function withMeleeTp(overrides)
    local loadout = {}

    for slot, candidates in pairs(meleeTp) do
        loadout[slot] = candidates
    end

    if overrides then
        for slot, candidates in pairs(overrides) do
            loadout[slot] = candidates
        end
    end

    return loadout
end

xi.bis_gear_loadouts.byJob =
{
    [xi.job.WAR] = withMeleeTp
    {
        [xi.slot.MAIN]   = list(I.PERDU_VOULGE, I.MARTIAL_BHUJ, gear.BHUJ, I.GAWAINS_AXE),
        [xi.slot.SUB]    = list(I.POLE_GRIP, I.ROSE_STRAP),
        [xi.slot.RANGED] = list(I.BOMB_CORE),
    },

    [xi.job.MNK] = withMeleeTp
    {
        [xi.slot.MAIN] = list(I.DESTROYERS, I.FAITH_BAGHNAKHS, I.KOENIGS_KNUCKLES),
        [xi.slot.SUB]  = list(I.POLE_GRIP),
    },

    [xi.job.WHM] =
    {
        [xi.slot.MAIN]  = list(gear.TEMPLAR_MACE, I.LIGHT_STAFF, I.PERDU_STAFF, I.CAPRICORN_STAFF),
        [xi.slot.SUB]   = list(gear.MUSE_TARIQAH, gear.NUMINOUS_SHIELD, I.STAFF_STRAP, gear.LIGHT_GRIP),
        [xi.slot.HEAD]  = list(I.GOLIARD_CHAPEAU, I.HEALERS_CAP_P1, I.NASHIRA_TURBAN, I.HEALERS_CAP),
        [xi.slot.BODY]  = list(gear.NOBLES_TUNIC, I.GOLIARD_SAIO, I.CLERICS_BLIAUT_P1, I.CLERICS_BLIAUT),
        [xi.slot.HANDS] = list(I.HEALERS_MITTS_P1, I.CLERICS_MITTS, I.GOLIARD_CUFFS, I.NASHIRA_GAGES),
        [xi.slot.LEGS]  = list(I.GOLIARD_TREWS, I.NASHIRA_SERAWEELS, I.YIGIT_SERAWEELS, I.CLERICS_PANTALOONS),
        [xi.slot.FEET]  = list(I.GOLIARD_CLOGS, I.CLERICS_DUCKBILLS, I.NASHIRA_CRACKOWS),
        [xi.slot.NECK]  = list(I.AJARI_BEAD_NECKLACE, I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE),
        [xi.slot.WAIST] = list(I.CLERICS_BELT, I.HIERARCH_BELT, I.LIFE_BELT, I.SWIFT_BELT),
        [xi.slot.EAR1]  = list(I.RELAXING_EARRING, I.BRUTAL_EARRING, I.OPTICAL_EARRING),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.SORCERERS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.BLM] =
    {
        [xi.slot.MAIN]  = list(I.PERDU_STAFF, I.CAPRICORN_STAFF, I.LIGHT_STAFF, gear.WINDURSTIAN_STAFF),
        [xi.slot.SUB]   = list(I.STAFF_STRAP, gear.LIGHT_GRIP),
        [xi.slot.HEAD]  = list(I.SORCERERS_PETASOS_P1, I.WIZARDS_PETASOS_P1, I.SORCERERS_PETASOS, I.WIZARDS_PETASOS),
        [xi.slot.BODY]  = list(I.SORCERERS_COAT_P1, I.SORCERERS_COAT, I.WIZARDS_COAT_P1, I.WIZARDS_COAT),
        [xi.slot.HANDS] = list(I.SORCERERS_GLOVES_P1, I.WIZARDS_GLOVES_P1, I.SORCERERS_GLOVES, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.SORCERERS_TONBAN_P1, I.WIZARDS_TONBAN_P1, I.SORCERERS_TONBAN),
        [xi.slot.FEET]  = list(I.SORCERERS_SABOTS_P1, I.WIZARDS_SABOTS_P1, I.SORCERERS_SABOTS),
        [xi.slot.NECK]  = list(I.AJARI_BEAD_NECKLACE, I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE),
        [xi.slot.WAIST] = list(I.POTENT_BELT, I.SWIFT_BELT, I.CLERICS_BELT),
        [xi.slot.EAR1]  = list(I.OPTICAL_EARRING, I.BRUTAL_EARRING, I.SORCERERS_EARRING),
        [xi.slot.RING1] = list(I.SORCERERS_RING, I.RAJAS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]  = list(I.WIZARDS_MANTLE, I.WARLOCKS_MANTLE, gear.AMEMET_MANTLE_P1),
    },

    [xi.job.RDM] =
    {
        [xi.slot.MAIN]  = list(I.PERDU_SWORD, I.PERDU_HANGER, I.EXCALIBUR_75, I.CALIBURN),
        [xi.slot.SUB]   = list(gear.NUMINOUS_SHIELD, I.GENBUS_KABUTO, I.POLE_GRIP),
        [xi.slot.HEAD]  = list(I.WARLOCKS_CHAPEAU_P1, I.WARLOCKS_CHAPEAU, I.NASHIRA_TURBAN, I.WALAHRA_TURBAN),
        [xi.slot.BODY]  = list(I.WARLOCKS_TABARD_P1, I.WARLOCKS_TABARD, gear.HAUBERGEON),
        [xi.slot.HANDS] = list(I.WARLOCKS_GLOVES_P1, gear.DUSK_GLOVES, I.NASHIRA_GAGES),
        [xi.slot.LEGS]  = list(I.WARLOCKS_TIGHTS_P1, I.BYAKKOS_HAIDATE, I.NASHIRA_SERAWEELS),
        [xi.slot.FEET]  = list(I.WARLOCKS_BOOTS_P1, I.FUMA_SUNE_ATE, I.GOLIARD_CLOGS),
        [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE),
        [xi.slot.WAIST] = list(I.SWIFT_BELT, I.LIFE_BELT),
        [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, I.OPTICAL_EARRING, I.WARLOCKS_EARRING),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.WARLOCKS_MANTLE),
    },

    [xi.job.THF] = withMeleeTp
    {
        [xi.slot.MAIN]  = list(gear.JAMBIYA, I.PERDU_BLADE, I.MANDAU_75, I.KIKOKU_75),
        [xi.slot.SUB]   = list(I.SUPPANOMIMI, I.ANJU),
        [xi.slot.HEAD]  = list(I.ASSASSINS_BONNET, gear.OPTICAL_HAT, I.WALAHRA_TURBAN),
        [xi.slot.BODY]  = list(I.ASSASSINS_VEST, gear.HAUBERGEON, gear.KIRINS_OSODE),
        [xi.slot.HANDS] = list(I.ASSASSINS_ARMLETS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.ASSASSINS_CULOTTES, I.BYAKKOS_HAIDATE),
        [xi.slot.FEET]  = list(I.ASSASSINS_POULAINES, I.FUMA_SUNE_ATE),
    },

    [xi.job.PLD] =
    {
        [xi.slot.MAIN]  = list(I.PERDU_SWORD, I.EXCALIBUR_75, I.BURTGANG_75, I.CALIBURN),
        [xi.slot.SUB]   = list(I.KOENIG_SHIELD, I.RELIC_SHIELD, gear.NUMINOUS_SHIELD),
        [xi.slot.HEAD]  = list(I.VALOR_CORONET, I.GENBUS_KABUTO, I.WALAHRA_TURBAN),
        [xi.slot.BODY]  = list(I.VALOR_SURCOAT, I.KOENIG_CUIRASS, gear.HAUBERGEON),
        [xi.slot.HANDS] = list(I.VALOR_GAUNTLETS, I.KOENIG_HANDSCHUHS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.VALOR_BREECHES, I.KOENIG_DIECHLINGS, I.BYAKKOS_HAIDATE),
        [xi.slot.FEET]  = list(I.VALOR_LEGGINGS, I.KOENIG_SCHUHS, I.FUMA_SUNE_ATE),
        [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE, gear.PEACOCK_AMULET),
        [xi.slot.WAIST] = list(I.POTENT_BELT, I.KOENIGS_BELT, I.SWIFT_BELT),
        [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, I.OPTICAL_EARRING),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.SOLDIERS_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, gear.CERBERUS_MANTLE),
    },

    [xi.job.DRK] = withMeleeTp
    {
        [xi.slot.MAIN] = list(I.PERDU_VOULGE, I.APOCALYPSE_75, I.GAWAINS_AXE, I.RAGNAROK_75),
        [xi.slot.SUB]  = list(I.POLE_GRIP, I.ROSE_STRAP),
    },

    [xi.job.BST] =
    {
        [xi.slot.MAIN]  = list(I.GAWAINS_AXE, gear.BHUJ, I.PERDU_VOULGE),
        [xi.slot.SUB]   = list(I.POLE_GRIP),
        [xi.slot.HEAD]  = list(I.ASKAR_ZUCCHETTO, I.WALAHRA_TURBAN, gear.OPTICAL_HAT),
        [xi.slot.BODY]  = list(I.ASKAR_KORAZIN, gear.HAUBERGEON, I.DENALI_JACKET),
        [xi.slot.HANDS] = list(I.ASKAR_MANOPOLAS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.BYAKKOS_HAIDATE, gear.DUSK_TROUSERS, I.SHURA_HAIDATE),
        [xi.slot.FEET]  = list(I.FUMA_SUNE_ATE, I.AMIR_BOOTS),
        [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE),
        [xi.slot.WAIST] = list(I.LIFE_BELT, I.SWIFT_BELT),
        [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, I.BUSHINOMIMI),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.BRD] =
    {
        [xi.slot.MAIN]  = list(I.PERDU_HANGER, I.MANDAU_75, I.DAGGER),
        [xi.slot.SUB]   = list(I.SUPPANOMIMI, I.POLE_GRIP),
        [xi.slot.HEAD]  = list(I.WALAHRA_TURBAN, I.CHORAL_ROUNDLET_P1, I.CHORAL_ROUNDLET),
        [xi.slot.BODY]  = list(I.CHORAL_JUSTAUCORPS_P1, I.CHORAL_JUSTAUCORPS, gear.HAUBERGEON),
        [xi.slot.HANDS] = list(I.CHORAL_CUFFS_P1, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.CHORAL_CANNIONS_P1, I.BYAKKOS_HAIDATE),
        [xi.slot.FEET]  = list(I.CHORAL_SLIPPERS_P1, I.FUMA_SUNE_ATE),
        [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.AJARI_BEAD_NECKLACE),
        [xi.slot.WAIST] = list(I.SWIFT_BELT, I.LIFE_BELT),
        [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, I.OPTICAL_EARRING),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.RNG] =
    {
        [xi.slot.MAIN]  = list(I.YOICHINOYUMI_75, I.PERDU_BOW, I.ANNIHILATOR_75, I.RELIC_BOW),
        [xi.slot.AMMO]  = list(I.YOICHIS_ARROW),
        [xi.slot.HEAD]  = list(I.SKADIS_VISOR, I.SCOUTS_BERET, gear.OPTICAL_HAT),
        [xi.slot.BODY]  = list(I.SKADIS_CUIRIE, I.SCOUTS_JERKIN, gear.HAUBERGEON),
        [xi.slot.HANDS] = list(I.SKADIS_BAZUBANDS, I.SCOUTS_BRACERS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.SKADIS_CHAUSSES, I.SCOUTS_BRACCAE, I.BYAKKOS_HAIDATE),
        [xi.slot.FEET]  = list(I.SKADIS_JAMBEAUX, I.SCOUTS_SOCKS, I.FUMA_SUNE_ATE),
        [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE, gear.ANCIENT_TORQUE),
        [xi.slot.WAIST] = list(I.SWIFT_BELT, I.POTENT_BELT),
        [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, gear.FOWLING_EARRING, gear.TRIUMPH_EARRING),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.SAM] = withMeleeTp
    {
        [xi.slot.MAIN]   = list(I.HAGUN, gear.SOBORO, I.RAGNAROK_75),
        [xi.slot.SUB]    = list(I.POLE_GRIP, I.ROSE_STRAP),
        [xi.slot.RANGED] = list(I.SMART_GRENADE, gear.THEW_BOMBLET),
        [xi.slot.BODY]   = list(gear.HAUBERGEON, gear.KIRINS_OSODE, I.ASKAR_KORAZIN),
        [xi.slot.HANDS]  = list(gear.DUSK_GLOVES, gear.HACHIMAN_KOTE, I.OCHIUDOS_KOTE),
        [xi.slot.LEGS]   = list(I.BYAKKOS_HAIDATE, I.SHINIMUSHA_HARA_ATE, gear.DUSK_TROUSERS),
        [xi.slot.FEET]   = list(I.FUMA_SUNE_ATE, gear.HACHIMAN_SUNE_ATE),
    },

    [xi.job.NIN] = withMeleeTp
    {
        [xi.slot.MAIN]  = list(I.PERDU_BLADE, gear.SOBORO, I.KIKOKU_75, I.VAJRA_75),
        [xi.slot.SUB]   = list(I.ANJU, I.ZUSHIO, I.SUPPANOMIMI),
        [xi.slot.HEAD]  = list(I.KOGA_HATSUBURI, I.WALAHRA_TURBAN, I.USUKANE_SOMEN),
        [xi.slot.BODY]  = list(I.KOGA_CHAINMAIL, gear.HAUBERGEON, I.USUKANE_HARAMAKI),
        [xi.slot.HANDS] = list(I.KOGA_TEKKO, gear.DUSK_GLOVES, I.USUKANE_GOTE),
        [xi.slot.LEGS]  = list(I.KOGA_HAKAMA, I.BYAKKOS_HAIDATE, I.USUKANE_HIZAYOROI),
        [xi.slot.FEET]  = list(I.KOGA_KYAHAN, I.FUMA_SUNE_ATE, I.USUKANE_SUNE_ATE),
    },

    [xi.job.DRG] =
    {
        [xi.slot.MAIN]  = list(I.PERDU_VOULGE, I.GUNGNIR_75, gear.BHUJ),
        [xi.slot.SUB]   = list(I.POLE_GRIP),
        [xi.slot.HEAD]  = list(I.DRACHEN_ARMET, I.WALAHRA_TURBAN, gear.OPTICAL_HAT),
        [xi.slot.BODY]  = list(I.DRACHEN_MAIL, gear.HAUBERGEON, gear.KIRINS_OSODE),
        [xi.slot.HANDS] = list(I.DRACHEN_FINGER_GAUNTLETS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.DRACHEN_BRAIS, I.BYAKKOS_HAIDATE),
        [xi.slot.FEET]  = list(I.DRACHEN_GREAVES, I.FUMA_SUNE_ATE),
        [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE),
        [xi.slot.WAIST] = list(I.SWIFT_BELT, I.LIFE_BELT),
        [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, I.BUSHINOMIMI),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.SMN] =
    {
        [xi.slot.MAIN]  = list(gear.KIRINS_POLE, I.PERDU_STAFF, I.NIRVANA_75, I.LAEVATEINN_75),
        [xi.slot.SUB]   = list(I.STAFF_STRAP),
        [xi.slot.HEAD]  = list(I.EVOKERS_HORN, I.GOLIARD_CHAPEAU, I.NASHIRA_TURBAN),
        [xi.slot.BODY]  = list(I.EVOKERS_DOUBLET, I.GOLIARD_SAIO, gear.NOBLES_TUNIC),
        [xi.slot.HANDS] = list(I.EVOKERS_BRACERS, I.GOLIARD_CUFFS),
        [xi.slot.LEGS]  = list(I.EVOKERS_SPATS, I.GOLIARD_TREWS, I.NASHIRA_SERAWEELS),
        [xi.slot.FEET]  = list(I.EVOKERS_PIGACHES, I.GOLIARD_CLOGS),
        [xi.slot.NECK]  = list(I.AJARI_BEAD_NECKLACE, I.CHIVALROUS_CHAIN),
        [xi.slot.WAIST] = list(I.CLERICS_BELT, I.LIFE_BELT),
        [xi.slot.EAR1]  = list(I.OPTICAL_EARRING, I.BRUTAL_EARRING),
        [xi.slot.RING1] = list(I.EVOKERS_RING, I.SORCERERS_RING, I.RAJAS_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.BLU] = withMeleeTp
    {
        [xi.slot.MAIN]  = list(I.PERDU_SWORD, I.PERDU_BLADE, gear.TEMPLAR_MACE),
        [xi.slot.SUB]   = list(I.SUPPANOMIMI, gear.NUMINOUS_SHIELD),
        [xi.slot.HEAD]  = list(I.MIRAGE_KEFFIYEH, I.WALAHRA_TURBAN, gear.OPTICAL_HAT),
        [xi.slot.BODY]  = list(I.MIRAGE_JUBBAH, gear.HAUBERGEON, gear.KIRINS_OSODE),
        [xi.slot.HANDS] = list(I.MIRAGE_BAZUBANDS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.MIRAGE_SHALWAR, I.BYAKKOS_HAIDATE),
        [xi.slot.FEET]  = list(I.MIRAGE_CHARUQS, I.FUMA_SUNE_ATE),
    },

    [xi.job.COR] =
    {
        [xi.slot.MAIN]  = list(I.TRUMP_GUN, I.PERDU_CROSSBOW, I.VAJRA_75),
        [xi.slot.RANGED] = list(I.TRUMP_GUN, I.PERDU_CROSSBOW),
        [xi.slot.HEAD]  = list(I.CORSAIRS_TRICORNE, gear.OPTICAL_HAT, I.WALAHRA_TURBAN),
        [xi.slot.BODY]  = list(I.CORSAIRS_FRAC, gear.HAUBERGEON, I.DENALI_JACKET),
        [xi.slot.HANDS] = list(I.CORSAIRS_GANTS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.BYAKKOS_HAIDATE, gear.DUSK_TROUSERS, I.SCOUTS_BRACCAE),
        [xi.slot.FEET]  = list(I.CORSAIRS_BOTTES, I.FUMA_SUNE_ATE),
        [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE),
        [xi.slot.WAIST] = list(I.SWIFT_BELT, I.POTENT_BELT),
        [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, gear.FOWLING_EARRING),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.PUP] =
    {
        [xi.slot.MAIN]   = list(I.MARTIAL_BHUJ, I.DESTROYERS, I.WAR_HOOP),
        [xi.slot.RANGED] = list(I.TURBO_ANIMATOR, I.WAR_HOOP),
        [xi.slot.HEAD]   = list(I.PANTIN_TAJ, gear.OPTICAL_HAT),
        [xi.slot.BODY]   = list(I.PANTIN_TOBE, gear.HAUBERGEON),
        [xi.slot.HANDS]  = list(I.PANTIN_DASTANAS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]   = list(I.PANTIN_CHURIDARS, I.BYAKKOS_HAIDATE),
        [xi.slot.FEET]   = list(I.PANTIN_BABOUCHES, I.FUMA_SUNE_ATE),
        [xi.slot.NECK]   = list(I.CHIVALROUS_CHAIN),
        [xi.slot.WAIST]  = list(I.SWIFT_BELT, I.LIFE_BELT),
        [xi.slot.EAR1]   = list(I.BRUTAL_EARRING, I.OPTICAL_EARRING),
        [xi.slot.RING1]  = list(I.RAJAS_RING, I.WOODSMAN_RING),
        [xi.slot.BACK]   = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.DNC] = withMeleeTp
    {
        [xi.slot.MAIN]  = list(I.PERDU_BLADE, gear.JAMBIYA, I.DAGGER),
        [xi.slot.SUB]   = list(I.SUPPANOMIMI, I.ANJU),
        [xi.slot.HEAD]  = list(I.WALAHRA_TURBAN, gear.OPTICAL_HAT),
        [xi.slot.BODY]  = list(gear.HAUBERGEON, I.ASSASSINS_VEST),
        [xi.slot.HANDS] = list(gear.DUSK_GLOVES, I.ASSASSINS_ARMLETS),
        [xi.slot.LEGS]  = list(I.BYAKKOS_HAIDATE, I.ASSASSINS_CULOTTES),
        [xi.slot.FEET]  = list(I.FUMA_SUNE_ATE, I.ASSASSINS_POULAINES),
    },

    [xi.job.SCH] =
    {
        [xi.slot.MAIN]  = list(I.PERDU_STAFF, I.TUPSIMATI_75, I.CLAYMORE),
        [xi.slot.SUB]   = list(I.STAFF_STRAP),
        [xi.slot.HEAD]  = list(I.SCHOLARS_MORTARBOARD, I.ARGUTE_MORTARBOARD_P1, I.ARGUTE_MORTARBOARD, I.GOLIARD_CHAPEAU),
        [xi.slot.BODY]  = list(I.SCHOLARS_GOWN, I.ARGUTE_GOWN_P1, I.ARGUTE_GOWN, I.GOLIARD_SAIO),
        [xi.slot.HANDS] = list(I.SCHOLARS_BRACERS_P1, I.ARGUTE_BRACERS_P1, I.GOLIARD_CUFFS),
        [xi.slot.LEGS]  = list(I.ARGUTE_PANTS_P1, I.GOLIARD_TREWS, I.NASHIRA_SERAWEELS),
        [xi.slot.FEET]  = list(I.ARGUTE_LOAFERS_P1, I.SCHOLARS_LOAFERS_P1, I.GOLIARD_CLOGS),
        [xi.slot.NECK]  = list(I.AJARI_BEAD_NECKLACE, I.CHIVALROUS_CHAIN),
        [xi.slot.WAIST] = list(I.CLERICS_BELT, I.SWIFT_BELT),
        [xi.slot.EAR1]  = list(I.OPTICAL_EARRING, I.BRUTAL_EARRING),
        [xi.slot.RING1] = list(I.SORCERERS_RING, I.RAJAS_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.GEO] =
    {
        [xi.slot.MAIN]  = list(I.PERDU_STAFF, I.CAPRICORN_STAFF, I.LIGHT_STAFF),
        [xi.slot.SUB]   = list(I.STAFF_STRAP),
        [xi.slot.HEAD]  = list(I.GOLIARD_CHAPEAU, I.NASHIRA_TURBAN, I.SORCERERS_PETASOS),
        [xi.slot.BODY]  = list(I.GOLIARD_SAIO, I.SORCERERS_COAT, gear.NOBLES_TUNIC),
        [xi.slot.HANDS] = list(I.GOLIARD_CUFFS, I.NASHIRA_GAGES, I.SORCERERS_GLOVES),
        [xi.slot.LEGS]  = list(I.GOLIARD_TREWS, I.NASHIRA_SERAWEELS),
        [xi.slot.FEET]  = list(I.GOLIARD_CLOGS, I.SORCERERS_SABOTS),
        [xi.slot.NECK]  = list(I.AJARI_BEAD_NECKLACE, I.CHIVALROUS_CHAIN),
        [xi.slot.WAIST] = list(I.CLERICS_BELT, I.SWIFT_BELT),
        [xi.slot.EAR1]  = list(I.OPTICAL_EARRING, I.BRUTAL_EARRING),
        [xi.slot.RING1] = list(I.SORCERERS_RING, I.RAJAS_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, I.FORAGERS_MANTLE),
    },

    [xi.job.RUN] =
    {
        [xi.slot.MAIN]  = list(I.PERDU_SWORD, I.EXCALIBUR_75, I.BURTGANG_75),
        [xi.slot.SUB]   = list(I.KOENIG_SHIELD, gear.NUMINOUS_SHIELD),
        [xi.slot.HEAD]  = list(I.VALOR_CORONET, I.GENBUS_KABUTO, I.WALAHRA_TURBAN),
        [xi.slot.BODY]  = list(I.VALOR_SURCOAT, I.KOENIG_CUIRASS, gear.HAUBERGEON),
        [xi.slot.HANDS] = list(I.VALOR_GAUNTLETS, gear.DUSK_GLOVES),
        [xi.slot.LEGS]  = list(I.VALOR_BREECHES, I.BYAKKOS_HAIDATE),
        [xi.slot.FEET]  = list(I.VALOR_LEGGINGS, I.FUMA_SUNE_ATE),
        [xi.slot.NECK]  = list(I.CHIVALROUS_CHAIN, I.JUSTICE_TORQUE),
        [xi.slot.WAIST] = list(I.POTENT_BELT, I.KOENIGS_BELT),
        [xi.slot.EAR1]  = list(I.BRUTAL_EARRING, I.OPTICAL_EARRING),
        [xi.slot.RING1] = list(I.RAJAS_RING, I.SOLDIERS_RING),
        [xi.slot.BACK]  = list(gear.AMEMET_MANTLE_P1, gear.CERBERUS_MANTLE),
    },
}

return xi.bis_gear_loadouts
