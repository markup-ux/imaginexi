-----------------------------------
-- Imagine XI 2.0: XP-credited beastmen always grant conquest points
-- and the same amount of Imperial Standing, including outside
-- conquest regions. Stock Signet CP in Ronfaure-Jeuno is not doubled.
-- Conquest points and Imperial Standing are printed with the XP line.
-- Do not return this module.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/player')
-----------------------------------

local m = Module:new('ixi20_beastmen_cp_is')

local LISTENER = 'IXI20_BEASTMEN_CP_IS'

local function settings()
    return xi.settings and xi.settings.main or {}
end

local function enabled()
    return settings().IMAGINEXI_BEASTMEN_CP_IS ~= false
end

local function isPlayer(entity)
    return entity ~= nil and entity.isPC ~= nil and entity:isPC()
end

-- Shadowreign zone -> conquest region of that same place in the present.
-- La Vaule [S] is Davoi. Zones that exist only in the past use the present
-- region they sit in (Grauberg and Ruhotz are Gustaberg, Vunkerl Inlet is
-- Norvallen, Fort Karugo-Narugo and Ghoyu's Reverie are Sarutabaruta).
local PRESENT_CONQUEST_REGION =
{
    [xi.zone.EAST_RONFAURE_S]          = xi.region.RONFAURE,
    [xi.zone.SOUTHERN_SAN_DORIA_S]     = xi.region.SANDORIA,

    [xi.zone.JUGNER_FOREST_S]          = xi.region.NORVALLEN,
    [xi.zone.BATALLIA_DOWNS_S]         = xi.region.NORVALLEN,
    [xi.zone.THE_ELDIEME_NECROPOLIS_S] = xi.region.NORVALLEN,
    [xi.zone.LA_VAULE_S]               = xi.region.NORVALLEN,
    [xi.zone.EVERBLOOM_HOLLOW]         = xi.region.NORVALLEN,

    [xi.zone.NORTH_GUSTABERG_S]        = xi.region.GUSTABERG,
    [xi.zone.GRAUBERG_S]               = xi.region.GUSTABERG,
    [xi.zone.RUHOTZ_SILVERMINES]       = xi.region.GUSTABERG,
    [xi.zone.BASTOK_MARKETS_S]         = xi.region.BASTOK,

    [xi.zone.WEST_SARUTABARUTA_S]      = xi.region.SARUTABARUTA,
    [xi.zone.FORT_KARUGO_NARUGO_S]     = xi.region.SARUTABARUTA,
    [xi.zone.GHOYUS_REVERIE]           = xi.region.SARUTABARUTA,
    [xi.zone.WINDURST_WATERS_S]        = xi.region.WINDURST,

    [xi.zone.ROLANBERRY_FIELDS_S]      = xi.region.DERFLAND,
    [xi.zone.PASHHOW_MARSHLANDS_S]     = xi.region.DERFLAND,
    [xi.zone.CRAWLERS_NEST_S]          = xi.region.DERFLAND,
    [xi.zone.BEADEAUX_S]               = xi.region.DERFLAND,
    [xi.zone.VUNKERL_INLET_S]          = xi.region.NORVALLEN,

    [xi.zone.SAUROMUGUE_CHAMPAIGN_S]   = xi.region.ARAGONEU,
    [xi.zone.MERIPHATAUD_MOUNTAINS_S]  = xi.region.ARAGONEU,
    [xi.zone.CASTLE_OZTROJA_S]         = xi.region.ARAGONEU,
    [xi.zone.GARLAIGE_CITADEL_S]       = xi.region.ARAGONEU,

    [xi.zone.BEAUCEDINE_GLACIER_S]     = xi.region.FAUREGANDI,

    [xi.zone.XARCABARD_S]              = xi.region.VALDEAUNIA,
    [xi.zone.CASTLE_ZVAHL_BAILEYS_S]   = xi.region.VALDEAUNIA,
    [xi.zone.CASTLE_ZVAHL_KEEP_S]      = xi.region.VALDEAUNIA,
    [xi.zone.THRONE_ROOM_S]            = xi.region.VALDEAUNIA,
}

local function conquestRegion(player)
    return PRESENT_CONQUEST_REGION[player:getZoneID()] or player:getCurrentRegion()
end

-- Same rate as conquest::AddConquestPoints (exp * 10-20% + CONQUEST_BONUS).
-- Unknown regions keep the default 15% so Dynamis / ToAU still pay.
local function conquestPointsForExp(player, exp)
    local percentage = 0.15
    local region     = conquestRegion(player)

    if region ~= xi.region.UNKNOWN then
        local owner      = GetRegionOwner(region)
        local nationRank = GetNationRank(player:getNation())

        if owner <= xi.nation.WINDURST and nationRank > 1 then
            if IsConquestAlliance() then
                percentage = GetNationRank(owner) == 1 and 0.2 or 0.1
            elseif owner == player:getNation() then
                percentage = 0.1
            end
        end
    end

    percentage = percentage + (player:getMod(xi.mod.CONQUEST_BONUS) or 0) / 100.0

    return math.max(1, math.floor(exp * percentage))
end

local function stockAlreadyGrantedCp(player)
    local region = player:getCurrentRegion()

    return player:hasStatusEffect(xi.effect.SIGNET) and
        region >= xi.region.RONFAURE and
        region <= xi.region.JEUNO
end

local function tryGrant(player, mob, exp)
    if not enabled() or not isPlayer(player) then
        return
    end

    if type(exp) ~= 'number' or exp <= 0 then
        return
    end

    if mob == nil or mob.isMob == nil or not mob:isMob() then
        return
    end

    if mob:getEcosystem() ~= xi.ecosystem.BEASTMEN then
        return
    end

    if mob:getAllegiance() == xi.allegiance.PLAYER then
        return
    end

    local points = conquestPointsForExp(player, exp)

    -- C++ already paid CP for Signet + conquest-region combat XP.
    if not stockAlreadyGrantedCp(player) then
        player:addCP(points)
    end

    player:addCurrency('imperial_standing', points)
    -- Same log as "gains N experience points" (queued just after that packet).
    -- System chat, not a battle message, so FoV 2/3 progress is left alone.
    -- In-region Signet CP was already paid by C++; the amount is still this kill's CP.
    player:printToPlayer(
        string.format('%s gains %u conquest points and %u Imperial Standing.', player:getName(), points, points),
        xi.msg.channel.SYSTEM_3
    )
end

local function attach(player)
    if not isPlayer(player) then
        return
    end

    player:removeListener(LISTENER)
    player:addListener('EXPERIENCE_POINTS', LISTENER, function(playerObj, mobObj, expGained)
        tryGrant(playerObj, mobObj, expGained)
    end)
end

local function attachOnlinePlayers()
    if not xi.zone or not GetZone then
        return
    end

    local visitedZone = {}
    for _, zoneId in pairs(xi.zone) do
        if type(zoneId) == 'number' and not visitedZone[zoneId] then
            visitedZone[zoneId] = true
            local zone = GetZone(zoneId)
            if zone then
                for _, player in pairs(zone:getPlayers() or {}) do
                    attach(player)
                end
            end
        end
    end
end

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    attach(player)
end)

-- FileWatcher discards addOverride; keep onGameIn live without a restart.
if not xi.player._ixi20BeastmenCpIsGameIn then
    xi.player._ixi20BeastmenCpIsGameIn = true
    local prev = xi.player.onGameIn
    xi.player.onGameIn = function(player, firstLogin, zoning)
        if prev then
            prev(player, firstLogin, zoning)
        end

        attach(player)
    end
end

attachOnlinePlayers()
