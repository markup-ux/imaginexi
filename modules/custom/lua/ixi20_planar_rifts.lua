-----------------------------------
-- Imagine XI 2.0: planar rifts for every player.
-- Retail hides these NPCs unless the character holds a voidwalker abyssite.
-- Players with none receive a clear abyssite on login / zone.
-- Examining a rift opens travel to every other rift.
-- Pair with ixi20_planar_rifts.cpp, which keeps the swirl when the player stands on it.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/player')
-----------------------------------

local destinations = require('modules/custom/lua/ixi20_planar_rift_destinations')

local m = Module:new('ixi20_planar_rifts')

local abyssites =
{
    xi.ki.CLEAR_ABYSSITE,
    xi.ki.COLORFUL_ABYSSITE,
    xi.ki.BLUE_ABYSSITE,
    xi.ki.ORANGE_ABYSSITE,
    xi.ki.BROWN_ABYSSITE,
    xi.ki.YELLOW_ABYSSITE,
    xi.ki.PURPLE_ABYSSITE,
    xi.ki.GREY_ABYSSITE,
    xi.ki.BLACK_ABYSSITE,
}

local function hasAnyAbyssite(player)
    for _, keyItemId in ipairs(abyssites) do
        if player:hasKeyItem(keyItemId) then
            return true
        end
    end

    return false
end

local function grantPlanarRiftAccess(player)
    if not player or not player.isPC or not player:isPC() then
        return
    end

    if not hasAnyAbyssite(player) then
        player:addKeyItem(xi.ki.CLEAR_ABYSSITE)
    end
end

m:addOverride('xi.player.charCreate', function(player)
    super(player)
    grantPlanarRiftAccess(player)
end)

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    grantPlanarRiftAccess(player)
end)

local PAGE_SIZE = 7
local MENU_DELAY_MS = 50

local openZones
local openRifts

local function later(player, menu)
    player:timer(MENU_DELAY_MS, function(playerArg)
        playerArg:customMenu(menu)
    end)
end

local function isHere(here, zoneId, rift)
    if here == nil or here.zone ~= zoneId then
        return false
    end

    local dx = here.x - rift[1]
    local dz = here.z - rift[3]
    return dx * dx + dz * dz < 9
end

local function zonesFromHere(here)
    local list = {}

    for _, entry in ipairs(destinations) do
        local rifts = {}
        for _, rift in ipairs(entry.rifts) do
            if not isHere(here, entry.zone, rift) then
                rifts[#rifts + 1] = rift
            end
        end

        if #rifts > 0 then
            list[#list + 1] =
            {
                name  = entry.name,
                zone  = entry.zone,
                rifts = rifts,
            }
        end
    end

    return list
end

local function travel(player, zoneId, rift)
    player:setPos(rift[1], rift[2], rift[3], 0, zoneId)
end

openRifts = function(player, here, entry, page)
    local options = {}

    for _, rift in ipairs(entry.rifts) do
        local spot = rift
        options[#options + 1] =
        {
            spot[4],
            function(playerArg)
                travel(playerArg, entry.zone, spot)
            end,
        }
    end

    options[#options + 1] =
    {
        'Back',
        function(playerArg)
            openZones(playerArg, here, page)
        end,
    }

    later(player, {
        title   = entry.name,
        options = options,
    })
end

openZones = function(player, here, page)
    local list    = zonesFromHere(here)
    local start   = (page - 1) * PAGE_SIZE + 1
    local options = {}

    for index = start, math.min(start + PAGE_SIZE - 1, #list) do
        local entry = list[index]
        options[#options + 1] =
        {
            entry.name,
            function(playerArg)
                if #entry.rifts == 1 then
                    travel(playerArg, entry.zone, entry.rifts[1])
                else
                    openRifts(playerArg, here, entry, page)
                end
            end,
        }
    end

    if start + PAGE_SIZE - 1 < #list then
        options[#options + 1] =
        {
            'Next',
            function(playerArg)
                openZones(playerArg, here, page + 1)
            end,
        }
    end

    if page > 1 then
        options[#options + 1] =
        {
            'Back',
            function(playerArg)
                openZones(playerArg, here, page - 1)
            end,
        }
    end

    later(player, {
        title   = 'Planar Rift',
        options = options,
    })
end

m:addOverride('InteractionGlobal.onTrigger', function(player, npc, fallbackFn)
    if npc and npc:getName() == 'Planar_Rift' then
        openZones(player, {
            zone = npc:getZoneID(),
            x    = npc:getXPos(),
            z    = npc:getZPos(),
        }, 1)
        return
    end

    return super(player, npc, fallbackFn)
end)

return m
