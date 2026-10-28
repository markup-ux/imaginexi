-----------------------------------
-- Imagine XI 2.0: Ethereal Junctions pop their Unity notorious monster.
-- No accolades, no Records of Eminence objective, no private confrontation.
-- The mob is non-exclusive, so any player can fight it.
-- A junction that hosts more than one notorious monster asks which one.
-- Pair with ixi20_ethereal_junctions.cpp, which keeps the junction clickable.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_ethereal_junctions')

local RANGE = 20
local RANGE_SQ = RANGE * RANGE
local MENU_DELAY_MS = 50

-- Retail Unity Wanted level, used when the spawn was saved with no level.
local levels =
{
    Bounding_Belinda         = 75,
    Hugemaw_Harold           = 75,
    Prickly_Pitriv           = 75,
    Ironhorn_Baldurno        = 99,
    Sleepy_Mabel             = 99,
    Serpopard_Ninlil         = 99,
    Abyssdiver               = 119,
    Immanibugard             = 119,
    Intuila                  = 119,
    Jester_Malatrix          = 119,
    Orcfeltrap               = 119,
    Sybaritic_Samantha       = 119,
    Valkurm_Imperator        = 119,
    Cactrot_Veloz            = 122,
    Emperor_Arthro           = 122,
    Garbage_Gel              = 122,
    Joyous_Green             = 122,
    Keeper_of_Heiligtum      = 122,
    Tiyanak                  = 122,
    Voso                     = 122,
    Warblade_Beak            = 122,
    Woodland_Mender          = 122,
    Arke                     = 125,
    Ayapec                   = 125,
    ['Azure-toothed_Clawberry'] = 125,
    Bakunawa                 = 125,
    Beist                    = 125,
    ['Centurio_XX-I']        = 125,
    Coca                     = 125,
    Douma_Weapon             = 125,
    King_Uropygid            = 125,
    Kubool_Jas_Mhuufya       = 125,
    Largantua                = 125,
    Lumber_Jill              = 125,
    Mephitas                 = 125,
    Muut                     = 125,
    Specter_Worm             = 125,
    Strix                    = 125,
    Vermillion_Fishfly       = 125,
    Azrael                   = 128,
    Borealis_Shadow          = 128,
    Camahueto                = 128,
    Carousing_Celine         = 128,
    Grand_Grenade            = 128,
    Vedrfolnir               = 128,
    Vidmapire                = 128,
    Volatile_Cluster         = 128,
    Glazemane                = 128,
    Wyvernhunter_Bambrox     = 128,
    Hidhaegg                 = 135,
    Sovereign_Behemoth       = 135,
    Tolba                    = 135,
    Thuban                   = 135,
    Sarama                   = 135,
    Shedu                    = 135,
    Tumult_Curator           = 145,
}

local function spokenName(name)
    return (name:gsub('_', ' '))
end

local function isJunction(npc)
    return npc and npc:getName() == 'Ethereal_Junction'
end

local function say(player, text)
    player:printToPlayer(text, xi.msg.channel.SYSTEM_3)
end

-- Closest placed copy of each wanted notorious monster within RANGE.
local function mobsHere(npc)
    local found = {}
    local zx = npc:getXPos()
    local zy = npc:getYPos()
    local zz = npc:getZPos()

    for _, mob in pairs(npc:getZone():getMobs()) do
        local name = mob:getName()
        local level = levels[name]
        if level then
            local pos = mob:getSpawnPos()
            if pos and pos.x then
                local dx = pos.x - zx
                local dy = pos.y - zy
                local dz = pos.z - zz
                local dist = dx * dx + dy * dy + dz * dz
                if dist <= RANGE_SQ and (found[name] == nil or dist < found[name].dist) then
                    found[name] =
                    {
                        mob   = mob,
                        dist  = dist,
                        level = level,
                    }
                end
            end
        end
    end

    local list = {}
    for name, entry in pairs(found) do
        list[#list + 1] =
        {
            name  = name,
            mob   = entry.mob,
            level = entry.level,
        }
    end

    table.sort(list, function(a, b)
        return a.name < b.name
    end)

    return list
end

local function popMob(player, mob, level)
    mob:setMobMod(xi.mobMod.CLAIM_TYPE, xi.claimType.NON_EXCLUSIVE)

    if mob:isSpawned() then
        say(player, spokenName(mob:getName()) .. ' is already out.')
        return
    end

    mob:spawn()

    if mob:getMainLvl() == 0 then
        mob:setMobLevel(level)
    end

    mob:setMobMod(xi.mobMod.CLAIM_TYPE, xi.claimType.NON_EXCLUSIVE)
    mob:updateEnmity(player)
    say(player, spokenName(mob:getName()) .. ' appears.')
end

local function openJunction(player, npc)
    local list = mobsHere(npc)
    if #list == 0 then
        say(player, 'Nothing answers this junction.')
        return
    end

    if #list == 1 then
        popMob(player, list[1].mob, list[1].level)
        return
    end

    local options = {}
    for _, entry in ipairs(list) do
        local mob = entry.mob
        local level = entry.level
        options[#options + 1] =
        {
            spokenName(entry.name),
            function(playerArg)
                popMob(playerArg, mob, level)
            end,
        }
    end

    player:timer(MENU_DELAY_MS, function(playerArg)
        playerArg:customMenu({
            title   = 'Ethereal Junction',
            options = options,
        })
    end)
end

m:addOverride('InteractionGlobal.onTrigger', function(player, npc, fallbackFn)
    if isJunction(npc) then
        openJunction(player, npc)
        return
    end

    return super(player, npc, fallbackFn)
end)

return m
