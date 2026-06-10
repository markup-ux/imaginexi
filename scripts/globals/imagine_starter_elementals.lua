-----------------------------------
-- Starter area elementals (moved from modules/custom/lua)
-- Called from West Ronfaure / North Gustaberg / East Sarutabaruta Zone.lua
-----------------------------------
xi.imagine = xi.imagine or {}
xi.imagine.starterElementals = xi.imagine.starterElementals or {}

local ELEMENTAL_GROUP_ZONE = 38
local ELEMENTAL_GROUPS =
{
    FIRE    = 14,
    ICE     = 15,
    AIR     = 11,
    EARTH   = 13,
    THUNDER = 18,
    WATER   = 17,
    LIGHT   = 16,
    DARK    = 12,
}

local function spawnElemental(zone, data)
    local rolledLevel = math.random(4, 9)

    local mob = zone:insertDynamicEntity({
        objtype              = xi.objType.MOB,
        name                 = data.internalName,
        packetName           = data.packetName,
        groupId              = data.groupId,
        groupZoneId          = ELEMENTAL_GROUP_ZONE,
        minLevel             = rolledLevel,
        maxLevel             = rolledLevel,
        x                    = data.x,
        y                    = data.y,
        z                    = data.z,
        rotation             = data.rot,
        releaseIdOnDisappear = false,
    })

    if not mob then
        return
    end

    mob:setSpawn(data.x, data.y, data.z, data.rot)
    mob:setRespawnTime(900)
    mob:spawn()
end

local function spawnZoneElementals(zone, entries)
    for _, entry in ipairs(entries) do
        spawnElemental(zone, entry)
    end
end

function xi.imagine.starterElementals.westRonfaure(zone)
    spawnZoneElementals(zone,
    {
        { internalName = 'Starter_Fire_Elemental_A',    packetName = 'Fire Elemental',    groupId = ELEMENTAL_GROUPS.FIRE,    x = -338.0, y = -60.0, z = 258.0, rot = 96  },
        { internalName = 'Starter_Water_Elemental_A',   packetName = 'Water Elemental',   groupId = ELEMENTAL_GROUPS.WATER,   x = -120.0, y = -60.0, z = 142.0, rot = 160 },
        { internalName = 'Starter_Air_Elemental_A',     packetName = 'Air Elemental',     groupId = ELEMENTAL_GROUPS.AIR,     x = -45.0,  y = -60.0, z = 356.0, rot = 32  },
        { internalName = 'Starter_Earth_Elemental_A',   packetName = 'Earth Elemental',   groupId = ELEMENTAL_GROUPS.EARTH,   x = -274.0, y = -59.0, z = 20.0,  rot = 208 },
        { internalName = 'Starter_Ice_Elemental_A',     packetName = 'Ice Elemental',     groupId = ELEMENTAL_GROUPS.ICE,     x = -218.0, y = -60.0, z = 404.0, rot = 8   },
        { internalName = 'Starter_Thunder_Elemental_A', packetName = 'Thunder Elemental', groupId = ELEMENTAL_GROUPS.THUNDER, x = -390.0, y = -59.0, z = 104.0, rot = 128 },
    })
end

function xi.imagine.starterElementals.northGustaberg(zone)
    spawnZoneElementals(zone,
    {
        { internalName = 'Starter_Light_Elemental_A', packetName = 'Light Elemental', groupId = ELEMENTAL_GROUPS.LIGHT, x = 510.0, y = 0.0, z = 126.0, rot = 64  },
        { internalName = 'Starter_Dark_Elemental_A',  packetName = 'Dark Elemental',  groupId = ELEMENTAL_GROUPS.DARK,  x = 670.0, y = 0.0, z = 338.0, rot = 196 },
        { internalName = 'Starter_Fire_Elemental_B',  packetName = 'Fire Elemental',  groupId = ELEMENTAL_GROUPS.FIRE,  x = 380.0, y = -8.0, z = -10.0, rot = 24  },
        { internalName = 'Starter_Water_Elemental_B', packetName = 'Water Elemental', groupId = ELEMENTAL_GROUPS.WATER, x = 740.0, y = -7.0, z = 40.0,  rot = 222 },
        { internalName = 'Starter_Air_Elemental_B',   packetName = 'Air Elemental',   groupId = ELEMENTAL_GROUPS.AIR,   x = 540.0, y = 0.0, z = 420.0, rot = 144 },
    })
end

function xi.imagine.starterElementals.eastSarutabaruta(zone)
    spawnZoneElementals(zone,
    {
        { internalName = 'Starter_Earth_Elemental_B',   packetName = 'Earth Elemental',   groupId = ELEMENTAL_GROUPS.EARTH,   x = -318.0, y = -3.0, z = -225.0, rot = 48  },
        { internalName = 'Starter_Ice_Elemental_B',     packetName = 'Ice Elemental',     groupId = ELEMENTAL_GROUPS.ICE,     x = -58.0,  y = -3.0, z = -420.0, rot = 184 },
        { internalName = 'Starter_Thunder_Elemental_B', packetName = 'Thunder Elemental', groupId = ELEMENTAL_GROUPS.THUNDER, x = -420.0, y = -3.0, z = -520.0, rot = 110 },
        { internalName = 'Starter_Light_Elemental_B',   packetName = 'Light Elemental',   groupId = ELEMENTAL_GROUPS.LIGHT,   x = -15.0,  y = -3.0, z = -190.0, rot = 12  },
        { internalName = 'Starter_Dark_Elemental_B',    packetName = 'Dark Elemental',    groupId = ELEMENTAL_GROUPS.DARK,    x = -260.0, y = -3.0, z = -640.0, rot = 236 },
    })
end
