-----------------------------------
-- Imagine XI 2.0: GM Home test hub.
-- Job-change moogle, vendor (buy/sell), avatar-gear vendor, and a hare
-- camp that grants a full level of XP per kill so level-up messages
-- can be tested.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/shop')
require('scripts/zones/GM_Home/Zone')
-----------------------------------

local m = Module:new('ixi20_gm_home_test_hub')

-- Enough for a ding through the 75 cap (exp_base 74→75 is 42000).
local KILL_EXP            = 45000
local HARE_LEVEL          = 1
local HARE_HP             = 1
local HARE_LOOK           = 268 -- Forest Hare
local HARE_GROUP_ID       = 5
local HARE_GROUP_ZONE_ID  = 154 -- Dragon's Aery (Fafnir group, stats overridden)
local HARE_RESPAWN        = 5
local MOOGLE_LOOK         = 981 -- Nomad Moogle
local SHOP_LOOK           = 150 -- Hume male

local shopStock =
{
    { xi.item.POTION,                    100 },
    { xi.item.ETHER,                     100 },
    { xi.item.ANTIDOTE,                  100 },
    { xi.item.FLASK_OF_ECHO_DROPS,       100 },
        { xi.item.LOAF_OF_BLACK_BREAD,       100 },
        { xi.item.FLASK_OF_DISTILLED_WATER,  100 },
    }

local hareSpawns =
{
    { 12.0, 0.0, 12.0, 192 },
    { 16.0, 0.0, 12.0, 192 },
    { 12.0, 0.0, 16.0, 192 },
    { 16.0, 0.0, 16.0, 192 },
    { 14.0, 0.0, 14.0, 192 },
    { 18.0, 0.0, 14.0, 192 },
}

local function grantKillExp(player)
    if not player or not player.isPC or not player:isPC() then
        return
    end

    player:addExp(KILL_EXP)
end

local function applyHare(mob)
    if not mob then
        return
    end

    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setMobMod(xi.mobMod.NO_AGGRO, 1)
    mob:setMobMod(xi.mobMod.NO_LINK, 1)
    mob:setMobMod(xi.mobMod.NO_MOVE, 1)
    mob:setMobMod(xi.mobMod.ROAM_DISTANCE, 0)
    mob:setMobMod(xi.mobMod.SIGHT_RANGE, 0)
    mob:setMobMod(xi.mobMod.SOUND_RANGE, 0)
    mob:setMobMod(xi.mobMod.SPECIAL_SKILL, 0)
    mob:setMobMod(xi.mobMod.EXP_BONUS, -100)
    mob:setBehavior(xi.behavior.NONE)
    mob:setAggressive(false)
    mob:setMagicCastingEnabled(false)
    mob:setMobAbilityEnabled(false)
    mob:setAutoAttackEnabled(false)
    mob:setMod(xi.mod.DEF, 0)
    mob:setMod(xi.mod.EVA, 0)
    mob:setMod(xi.mod.HP, 0)
    mob:setMod(xi.mod.HPP, 0)
    mob:setMod(xi.mod.BASE_HP, 0)
    if mob.setMobLevel then
        -- Fafnir group stats; recover=false so CalculateMobStats does not refill HP first.
        mob:setMobLevel(HARE_LEVEL, false)
    end

    mob:setMaxHP(HARE_HP)
    mob:setHP(HARE_HP)
end

local function restatHares(zone)
    if not zone or not zone.queryEntitiesByName then
        return
    end

    for index = 1, #hareSpawns do
        local found = zone:queryEntitiesByName(string.format('DE_XPHare%d', index))
        if found then
            for _, hare in pairs(found) do
                if hare then
                    applyHare(hare)
                end
            end
        end
    end
end

local function spawnMoogle(zone)
    zone:insertDynamicEntity({
        objtype    = xi.objType.NPC,
        name       = 'JobMoogle',
        packetName = 'Nomad Moogle',
        look       = MOOGLE_LOOK,
        x          = -8.0,
        y          = 0.0,
        z          = 2.0,
        rotation   = 0,
        widescan   = 1,
        onTrigger  = function(player, npc)
            player:printToPlayer(
                'Kupo! Change jobs here — same menu as a Nomad Moogle.',
                xi.msg.channel.NS_SAY,
                npc:getPacketName()
            )
            player:sendMenu(xi.menuType.MOOGLE)
        end,
    })
end

-- A general shop stops at 16 lines, so each avatar is its own page.
local AVATAR_PRICE = 1

local avatarShops =
{
    {
        'Carbuncle',
        {
            { 14062, AVATAR_PRICE }, -- Carbuncle Mitts
            { 14931, AVATAR_PRICE }, -- Carbuncle's Cuffs
            { 18581, AVATAR_PRICE }, -- Carbuncle's Pole
            { 27576, AVATAR_PRICE }, -- Carbuncle Ring
            { 27577, AVATAR_PRICE }, -- Carbuncle Ring +1
        },
    },
    {
        'Fenrir',
        {
            { 11496, AVATAR_PRICE }, -- Fenrir's Crown
            { 13138, AVATAR_PRICE }, -- Fenrir's Torque
            { 13399, AVATAR_PRICE }, -- Fenrir's Earring
            { 13572, AVATAR_PRICE }, -- Fenrir's Cape
            { 18165, AVATAR_PRICE }, -- Fenrir's Stone
            { 27578, AVATAR_PRICE }, -- Fenrir Ring
            { 27579, AVATAR_PRICE }, -- Fenrir Ring +1
        },
    },
    {
        'Ifrit',
        {
            { 17192, AVATAR_PRICE }, -- Ifrit's Bow
            { 17665, AVATAR_PRICE }, -- Ifrit's Blade
            { 27564, AVATAR_PRICE }, -- Ifrit Ring
            { 27565, AVATAR_PRICE }, -- Ifrit Ring +1
        },
    },
    {
        'Titan',
        {
            { 17438, AVATAR_PRICE }, -- Titan's Cudgel
            { 18021, AVATAR_PRICE }, -- Titan's Baselarde
            { 27570, AVATAR_PRICE }, -- Titan Ring
            { 27571, AVATAR_PRICE }, -- Titan Ring +1
        },
    },
    {
        'Leviathan',
        {
            { 17439, AVATAR_PRICE }, -- Leviathan's Rod
            { 18109, AVATAR_PRICE }, -- Leviathan's Couse
            { 27566, AVATAR_PRICE }, -- Leviathan Ring
            { 27567, AVATAR_PRICE }, -- Leviathan Ring +1
        },
    },
    {
        'Garuda',
        {
            { 17627, AVATAR_PRICE }, -- Garuda's Dagger
            { 18063, AVATAR_PRICE }, -- Garuda's Sickle
            { 27572, AVATAR_PRICE }, -- Garuda Ring
            { 27573, AVATAR_PRICE }, -- Garuda Ring +1
        },
    },
    {
        'Shiva',
        {
            { 17492, AVATAR_PRICE }, -- Shiva's Claws
            { 17711, AVATAR_PRICE }, -- Shiva's Shotel
            { 27574, AVATAR_PRICE }, -- Shiva Ring
            { 27575, AVATAR_PRICE }, -- Shiva Ring +1
        },
    },
    {
        'Ramuh',
        {
            { 17531, AVATAR_PRICE }, -- Ramuh's Staff
            { 18404, AVATAR_PRICE }, -- Ramuh's Mace
            { 27568, AVATAR_PRICE }, -- Ramuh Ring
            { 27569, AVATAR_PRICE }, -- Ramuh Ring +1
        },
    },
    {
        'Diabolos',
        {
            { 11752, AVATAR_PRICE }, -- Diabolos's Rope
            { 14814, AVATAR_PRICE }, -- Diabolos's Earring
            { 15516, AVATAR_PRICE }, -- Diabolos's Torque
            { 15557, AVATAR_PRICE }, -- Diabolos's Ring
            { 17599, AVATAR_PRICE }, -- Diabolos's Pole
        },
    },
    {
        'Cait Sith',
        {
            { 25910, AVATAR_PRICE }, -- Cait Sith Subligar
            { 26717, AVATAR_PRICE }, -- Cait Sith Cap
            { 26718, AVATAR_PRICE }, -- Cait Sith Cap +1
            { 27631, AVATAR_PRICE }, -- Cait Sith Guard
            { 27632, AVATAR_PRICE }, -- Cait Sith Guard +1
        },
    },
}

local function avatarVendorPresent(zone)
    if not zone or not zone.queryEntitiesByName then
        return false
    end

    local found = zone:queryEntitiesByName('DE_AvatarVendor')
    if not found then
        return false
    end

    for _, entity in pairs(found) do
        if entity then
            return true
        end
    end

    return false
end

local function openAvatarShop(player, stock)
    player:timer(50, function(shopper)
        if shopper then
            xi.shop.general(shopper, stock)
        end
    end)
end

local function spawnAvatarVendor(zone)
    if not zone or not zone.insertDynamicEntity or avatarVendorPresent(zone) then
        return
    end

    local options = {}
    for _, entry in ipairs(avatarShops) do
        local avatarName = entry[1]
        local stock      = entry[2]
        options[#options + 1] =
        {
            avatarName,
            function(playerArg)
                openAvatarShop(playerArg, stock)
            end,
        }
    end

    zone:insertDynamicEntity({
        objtype    = xi.objType.NPC,
        name       = 'AvatarVendor',
        packetName = 'Avatar Vendor',
        look       = SHOP_LOOK,
        x          = -8.0,
        y          = 0.0,
        z          = -6.0,
        rotation   = 0,
        widescan   = 1,
        onTrigger  = function(player, npc)
            player:printToPlayer(
                'Pick an avatar. Wearing that gear summons it when you engage.',
                xi.msg.channel.NS_SAY,
                npc:getPacketName()
            )
            player:timer(50, function(shopper)
                shopper:customMenu({
                    title   = 'Avatar Gear',
                    options = options,
                })
            end)
        end,
    })
end

local function spawnShop(zone)
    zone:insertDynamicEntity({
        objtype    = xi.objType.NPC,
        name       = 'TestVendor',
        packetName = 'Test Vendor',
        look       = SHOP_LOOK,
        x          = -8.0,
        y          = 0.0,
        z          = -2.0,
        rotation   = 0,
        widescan   = 1,
        onTrigger  = function(player, npc)
            player:printToPlayer(
                'Buy is free. Vendor-sell XP is dropped weapons and armor only, not shop goods.',
                xi.msg.channel.NS_SAY,
                npc:getPacketName()
            )
            xi.shop.general(player, shopStock)
        end,
    })
end

local function spawnHares(zone)
    for index, pos in ipairs(hareSpawns) do
        local x, y, z, rot = pos[1], pos[2], pos[3], pos[4]
        local name         = string.format('XPHare%d', index)
        local hare         = zone:insertDynamicEntity({
            objtype              = xi.objType.MOB,
            name                 = name,
            packetName           = 'XP Hare',
            look                 = HARE_LOOK,
            groupId              = HARE_GROUP_ID,
            groupZoneId          = HARE_GROUP_ZONE_ID,
            minLevel             = HARE_LEVEL,
            maxLevel             = HARE_LEVEL,
            x                    = x,
            y                    = y,
            z                    = z,
            rotation             = rot,
            respawn              = HARE_RESPAWN,
            releaseIdOnDisappear = false,
            onMobSpawn           = function(mob)
                applyHare(mob)
            end,
            onMobDeath           = function(mob, player, optParams)
                grantKillExp(player)
            end,
        })

        if hare then
            hare:setSpawn(x, y, z, rot)
            hare:spawn()
            applyHare(hare)
        end
    end
end

m:addOverride('xi.zones.GM_Home.Zone.onInitialize', function(zone)
    super(zone)
    spawnMoogle(zone)
    spawnShop(zone)
    spawnAvatarVendor(zone)
    spawnHares(zone)
end)

-- FileWatcher cannot re-run zone init. Restat already-spawned hares on zone-in
-- and on this file reload so they become lv1 / 1 HP without a map restart.
m:addOverride('xi.zones.GM_Home.Zone.onZoneIn', function(player, prevZone)
    local cs   = super(player, prevZone)
    local zone = player.getZone and player:getZone()
    restatHares(zone)
    spawnAvatarVendor(zone)
    return cs
end)

if xi.zone and GetZone and xi.zone.GM_HOME then
    local gmHome = GetZone(xi.zone.GM_HOME)
    restatHares(gmHome)
    spawnAvatarVendor(gmHome)
end

return m
