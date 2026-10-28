-----------------------------------
-- Imagine XI 2.0: Garlaige Citadel [S] XP camps.
-- Tight packs of the citadel's own bats, slimes, bombs, and scolopendrids,
-- on floors those families already use, plus a pack inside each storeroom.
-- Needs custom/sql/ixi20_garlaige_exp.sql.
-- Do not return this module.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_garlaige_exp')

local ZONE_ID          = xi.zone.GARLAIGE_CITADEL_S
local RESPAWN_SECONDS  = 180
local ROAM_YALMS       = 4

local DIRE_BAT     = 210
local INCUBUS_BATS = 211
local EXPLOSURE    = 212
local MOUSSE       = 213
local SCOLOPENDRID = 214

-- Counts and squares are merged into !exp at lookup time.
xi.ixi20GarlaigeExpCamps =
{
    zone = 'Garlaige Citadel [S]',
    mobs =
    {
        { 'Dire Bat', 62, 64, 4, 'H-8' },
        { 'Dire Bat', 62, 64, 8, 'G-9' },
        { 'Incubus Bats', 62, 64, 4, 'H-8' },
        { 'Mousse', 64, 67, 8, 'G-6' },
        { 'Mousse', 64, 67, 8, 'I-8' },
        { 'Mousse', 64, 67, 8, 'G-9' },
        { 'Explosure', 64, 65, 8, 'F-9' },
        { 'Explosure', 64, 65, 8, 'G-7' },
        { 'Explosure', 64, 65, 8, 'J-6' },
        { 'Scolopendrid', 68, 70, 8, 'H-7' },
        { 'Scolopendrid', 68, 70, 8, 'H-9' },
    },
}

-- Positions sit a few yalms off placed spawns of the same family.
local camps =
{
    {
        packetName = 'Dire Bat',
        groupId    = DIRE_BAT,
        minLevel   = 62,
        maxLevel   = 64,
        points     =
        {
            { x = -16.5, y = -0.5, z = -11.6, rot = 64 },
            { x = -22.5, y = -0.5, z = -11.6, rot = 192 },
            { x = -16.5, y = -0.5, z = -7.8,  rot = 32 },
            { x = -22.5, y = -0.5, z = -7.8,  rot = 160 },
        },
    },
    {
        packetName = 'Incubus Bats',
        groupId    = INCUBUS_BATS,
        minLevel   = 62,
        maxLevel   = 64,
        points     =
        {
            { x = -25.0, y = -0.5, z = 19.0, rot = 96 },
            { x = -31.0, y = -0.5, z = 19.0, rot = 224 },
            { x = -25.0, y = -0.5, z = 25.0, rot = 16 },
            { x = -31.0, y = -0.5, z = 25.0, rot = 144 },
        },
    },
    {
        packetName = 'Mousse',
        groupId    = MOUSSE,
        minLevel   = 64,
        maxLevel   = 67,
        points     =
        {
            { x = -88.0, y = -0.5, z = 100.0, rot = 0 },
            { x = -84.0, y = -0.5, z = 100.0, rot = 64 },
            { x = -80.0, y = -0.5, z = 100.0, rot = 128 },
            { x = -76.0, y = -0.5, z = 100.0, rot = 192 },
            { x = -88.0, y = -0.5, z = 106.0, rot = 32 },
            { x = -84.0, y = -0.5, z = 106.0, rot = 96 },
            { x = -80.0, y = -0.5, z = 106.0, rot = 160 },
            { x = -76.0, y = -0.5, z = 106.0, rot = 224 },
        },
    },
    {
        packetName = 'Explosure',
        groupId    = EXPLOSURE,
        minLevel   = 64,
        maxLevel   = 65,
        points     =
        {
            { x = -138.0, y = -0.5, z = -109.0, rot = 40 },
            { x = -144.0, y = -0.5, z = -109.0, rot = 168 },
            { x = -141.0, y = -0.5, z = -106.0, rot = 8 },
            { x = -141.0, y = -0.5, z = -112.0, rot = 200 },
            { x = -146.0, y = -0.5, z = -99.0,  rot = 80 },
            { x = -152.0, y = -0.5, z = -99.0,  rot = 208 },
            { x = -149.0, y = -0.5, z = -96.0,  rot = 24 },
            { x = -149.0, y = -0.5, z = -102.0, rot = 152 },
        },
    },
    {
        packetName = 'Scolopendrid',
        groupId    = SCOLOPENDRID,
        minLevel   = 68,
        maxLevel   = 70,
        points     =
        {
            { x = 95.0,  y = 5.6, z = -150.0, rot = 48 },
            { x = 103.0, y = 5.6, z = -150.0, rot = 176 },
            { x = 99.0,  y = 5.6, z = -146.0, rot = 12 },
            { x = 99.0,  y = 5.6, z = -154.0, rot = 140 },
            { x = 136.0, y = 5.6, z = -149.0, rot = 72 },
            { x = 144.0, y = 5.6, z = -149.0, rot = 200 },
            { x = 140.0, y = 5.6, z = -145.0, rot = 28 },
            { x = 140.0, y = 5.6, z = -153.0, rot = 156 },
        },
    },
    -- Storerooms. A few yalms inside each door, short roam, no link.
    {
        packetName = 'Dire Bat',
        groupId    = DIRE_BAT,
        minLevel   = 62,
        maxLevel   = 64,
        noLink     = true,
        roam       = 2,
        points     =
        {
            { x = -264.5, y = -0.5, z = -55.3, rot = 0 },
            { x = -261.5, y = -0.5, z = -55.3, rot = 64 },
            { x = -258.5, y = -0.5, z = -55.3, rot = 128 },
            { x = -255.5, y = -0.5, z = -55.3, rot = 192 },
            { x = -264.5, y = -0.5, z = -60.3, rot = 32 },
            { x = -261.5, y = -0.5, z = -60.3, rot = 96 },
            { x = -258.5, y = -0.5, z = -60.3, rot = 160 },
            { x = -255.5, y = -0.5, z = -60.3, rot = 224 },
        },
    },
    {
        packetName = 'Scolopendrid',
        groupId    = SCOLOPENDRID,
        minLevel   = 68,
        maxLevel   = 70,
        noLink     = true,
        roam       = 2,
        points     =
        {
            { x = -186.5, y = -0.5, z = -55.3, rot = 16 },
            { x = -183.5, y = -0.5, z = -55.3, rot = 80 },
            { x = -180.5, y = -0.5, z = -55.3, rot = 144 },
            { x = -177.5, y = -0.5, z = -55.3, rot = 208 },
            { x = -186.5, y = -0.5, z = -59.3, rot = 48 },
            { x = -183.5, y = -0.5, z = -59.3, rot = 112 },
            { x = -180.5, y = -0.5, z = -59.3, rot = 176 },
            { x = -177.5, y = -0.5, z = -59.3, rot = 240 },
        },
    },
    {
        packetName = 'Mousse',
        groupId    = MOUSSE,
        minLevel   = 64,
        maxLevel   = 67,
        noLink     = true,
        roam       = 2,
        points     =
        {
            { x = -108.0, y = -0.5, z = 55.0, rot = 8 },
            { x = -108.0, y = -0.5, z = 59.0, rot = 72 },
            { x = -108.0, y = -0.5, z = 63.0, rot = 136 },
            { x = -108.0, y = -0.5, z = 65.0, rot = 200 },
            { x = -104.5, y = -0.5, z = 55.0, rot = 40 },
            { x = -104.5, y = -0.5, z = 59.0, rot = 104 },
            { x = -100.5, y = -0.5, z = 55.0, rot = 168 },
            { x = -100.5, y = -0.5, z = 57.0, rot = 232 },
        },
    },
    {
        packetName = 'Explosure',
        groupId    = EXPLOSURE,
        minLevel   = 64,
        maxLevel   = 65,
        noLink     = true,
        roam       = 2,
        points     =
        {
            { x = -66.0, y = -0.5, z = 57.3, rot = 24 },
            { x = -62.0, y = -0.5, z = 57.3, rot = 88 },
            { x = -58.0, y = -0.5, z = 57.3, rot = 152 },
            { x = -54.0, y = -0.5, z = 57.3, rot = 216 },
            { x = -66.0, y = -0.5, z = 64.3, rot = 56 },
            { x = -62.0, y = -0.5, z = 64.3, rot = 120 },
            { x = -58.0, y = -0.5, z = 64.3, rot = 184 },
            { x = -54.0, y = -0.5, z = 64.3, rot = 248 },
        },
    },
    {
        packetName = 'Mousse',
        groupId    = MOUSSE,
        minLevel   = 64,
        maxLevel   = 67,
        noLink     = true,
        roam       = 2,
        points     =
        {
            { x = -66.0, y = -0.5, z = -95.3,  rot = 12 },
            { x = -62.0, y = -0.5, z = -95.3,  rot = 76 },
            { x = -58.0, y = -0.5, z = -95.3,  rot = 140 },
            { x = -54.0, y = -0.5, z = -95.3,  rot = 204 },
            { x = -66.0, y = -0.5, z = -108.3, rot = 44 },
            { x = -62.0, y = -0.5, z = -108.3, rot = 108 },
            { x = -58.0, y = -0.5, z = -108.3, rot = 172 },
            { x = -54.0, y = -0.5, z = -108.3, rot = 236 },
        },
    },
    {
        packetName = 'Explosure',
        groupId    = EXPLOSURE,
        minLevel   = 64,
        maxLevel   = 65,
        noLink     = true,
        roam       = 2,
        points     =
        {
            { x = 136.3, y = -6.0, z = 96.0,  rot = 20 },
            { x = 136.3, y = -6.0, z = 99.0,  rot = 84 },
            { x = 136.3, y = -6.0, z = 102.0, rot = 148 },
            { x = 136.3, y = -6.0, z = 105.0, rot = 212 },
            { x = 142.3, y = -6.0, z = 96.0,  rot = 52 },
            { x = 142.3, y = -6.0, z = 99.0,  rot = 116 },
            { x = 142.3, y = -6.0, z = 102.0, rot = 180 },
            { x = 142.3, y = -6.0, z = 105.0, rot = 244 },
        },
    },
}

local function spawnOne(zone, camp, point)
    local level = math.random(camp.minLevel, camp.maxLevel)
    local mob   = zone:insertDynamicEntity({
        objtype              = xi.objType.MOB,
        name                 = camp.packetName:gsub(' ', '_'),
        packetName           = camp.packetName,
        groupId              = camp.groupId,
        groupZoneId          = ZONE_ID,
        minLevel             = level,
        maxLevel             = level,
        x                    = point.x,
        y                    = point.y,
        z                    = point.z,
        rotation             = point.rot,
        respawn              = RESPAWN_SECONDS,
        releaseIdOnDisappear = false,
    })

    if not mob then
        printf('[ixi20_garlaige_exp] spawn failed %s', camp.packetName)
        return
    end

    mob:setSpawn(point.x, point.y, point.z, point.rot)
    mob:setRespawnTime(RESPAWN_SECONDS)
    mob:setMobMod(xi.mobMod.ROAM_DISTANCE, camp.roam or ROAM_YALMS)
    if camp.noLink then
        mob:setMobMod(xi.mobMod.NO_LINK, 1)
    end
    mob:spawn()
end

local function spawnCamps(zone)
    if not zone or not zone.insertDynamicEntity then
        return
    end

    for _, camp in ipairs(camps) do
        for _, point in ipairs(camp.points) do
            spawnOne(zone, camp, point)
        end
    end
end

m:addOverride('xi.zones.Garlaige_Citadel_[S].Zone.onInitialize', function(zone)
    super(zone)
    spawnCamps(zone)
end)
