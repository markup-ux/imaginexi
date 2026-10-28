-----------------------------------
-- Imagine XI 2.0: !exp
-- Zones whose placed normal mobs sit near the player's level.
-- Camp rows are generated from data/zones/*/mobs.yaml.
-- Command file only: do not call Module:new (no overrides).
-----------------------------------
require('modules/module_utils')
-----------------------------------

package.loaded['modules/custom/lua/ixi20_exp_camps_data'] = nil
local zoneCamps = require('modules/custom/lua/ixi20_exp_camps_data')

local BELOW = 4
local ABOVE = 3
local MIN_SPAWNS = 8
local DETAIL_COUNT = 8
local LINE_LIMIT = 130

local function isPlayer(player)
    return player ~= nil and player.isPC ~= nil and player:isPC()
end

local function levelCap()
    local cap = xi.settings and xi.settings.main and xi.settings.main.MAX_LEVEL
    if type(cap) ~= 'number' or cap < 1 then
        return 75
    end

    return math.floor(cap)
end

local function say(player, text)
    player:printToPlayer(text, xi.msg.channel.SYSTEM_3)
end

local function printUsage(player)
    say(player, string.format('!exp lists XP camps. !exp <level> looks up 1-%u.', levelCap()))
end

local function jobAbbrev(job)
    local names = xi.jobName and xi.jobName[job]
    return names and names[1] or tostring(job)
end

-- WAR75/MNK37. No sub prints the main job only.
local function jobPair(player)
    local main = string.format('%s%u', jobAbbrev(player:getMainJob()), player:getMainLvl())
    local subJob = player:getSubJob()
    if not subJob or subJob == xi.job.NONE then
        return main
    end
    return string.format('%s/%s%u', main, jobAbbrev(subJob), player:getSubLvl())
end

-- Module camps (Garlaige Citadel [S]) are not in the generated yaml list.
local function mergeModuleCamps()
    local extra = xi.ixi20GarlaigeExpCamps
    if type(extra) ~= 'table' or extra.applied or type(extra.mobs) ~= 'table' then
        return
    end

    for _, zone in ipairs(zoneCamps) do
        if zone.name == extra.zone then
            for _, row in ipairs(extra.mobs) do
                zone.mobs[#zone.mobs + 1] = row
            end
            extra.applied = true
            return
        end
    end
end

-- Outdoor and dungeon zones with enough normal mobs in [level-4, level+3].
local function campsForLevel(level)
    mergeModuleCamps()
    local low = math.max(1, level - BELOW)
    local high = level + ABOVE
    local results = {}

    for _, zone in ipairs(zoneCamps) do
        local byName = {}
        local total = 0
        local midSum = 0
        local zmin = 999
        local zmax = 0

        for _, row in ipairs(zone.mobs) do
            local name, lo, hi, count = row[1], row[2], row[3], row[4]
            local grid = row[5]
            if hi >= low and lo <= high then
                local entry = byName[name]
                if not entry then
                    entry = { name = name, count = 0, grid = nil, gridCount = 0 }
                    byName[name] = entry
                end

                entry.count = entry.count + count
                total = total + count
                midSum = midSum + ((lo + hi) / 2) * count
                if lo < zmin then
                    zmin = lo
                end
                if hi > zmax then
                    zmax = hi
                end
                if type(grid) == 'string' and (entry.grid == nil or count > entry.gridCount) then
                    entry.grid = grid
                    entry.gridCount = count
                end
            end
        end

        if total >= MIN_SPAWNS then
            local names = {}
            for _, entry in pairs(byName) do
                names[#names + 1] = entry
            end

            table.sort(names, function(a, b)
                if a.count ~= b.count then
                    return a.count > b.count
                end
                return a.name < b.name
            end)

            local shown = {}
            local limit = math.min(3, #names)
            for i = 1, limit do
                local entry = names[i]
                shown[i] = { name = entry.name, grid = entry.grid }
            end

            local campGrid = shown[1] and shown[1].grid or nil

            results[#results + 1] =
            {
                name = zone.name,
                minLvl = zmin,
                maxLvl = zmax,
                mobs = shown,
                grid = campGrid,
                dist = math.floor(math.abs((midSum / total) - level) * 100 + 0.5),
            }
        end
    end

    table.sort(results, function(a, b)
        if a.dist ~= b.dist then
            return a.dist < b.dist
        end
        return a.name < b.name
    end)

    return results, low, high
end

local function mobLabel(mob)
    if mob.grid then
        return string.format('%s at %s', mob.name, mob.grid)
    end
    return mob.name
end

local function campText(camp, mobLimit)
    local bits = {}
    local limit = math.min(mobLimit, #camp.mobs)
    for i = 1, limit do
        bits[i] = mobLabel(camp.mobs[i])
    end
    return string.format('%s (%u-%u): %s', camp.name, camp.minLvl, camp.maxLvl, table.concat(bits, '; '))
end

local function fitCampText(camp)
    local text = campText(camp, 3)
    if #text > 145 then
        text = campText(camp, 2)
    end
    if #text > 145 then
        text = campText(camp, 1)
    end
    return text
end

local function emitPacked(player, chunks)
    local line = nil
    for _, text in ipairs(chunks) do
        if line == nil then
            line = '  ' .. text
        elseif #line + 3 + #text <= LINE_LIMIT then
            line = line .. ' | ' .. text
        else
            say(player, line)
            line = '  ' .. text
        end
    end

    if line then
        say(player, line)
    end
end

local function printCamps(player, level)
    local camps, low, high = campsForLevel(level)
    if #camps == 0 then
        say(player, string.format('No XP camps with mobs near level %u.', level))
        return
    end

    local who = string.format('%s %s, party %u', player:getName(), jobPair(player), player:getPartySize())
    if player:getMainLvl() == level then
        say(player, string.format('%s. XP camps (%u zones, mobs %u-%u):', who, #camps, low, high))
    else
        say(player, string.format('%s. XP camps for level %u (%u zones, mobs %u-%u):', who, level, #camps, low, high))
    end

    local detail = math.min(DETAIL_COUNT, #camps)
    for i = 1, detail do
        say(player, '  ' .. fitCampText(camps[i]))
    end

    if #camps > detail then
        local rest = {}
        for i = detail + 1, #camps do
            local camp = camps[i]
            if camp.grid then
                rest[#rest + 1] = string.format('%s (%u-%u) at %s', camp.name, camp.minLvl, camp.maxLvl, camp.grid)
            else
                rest[#rest + 1] = string.format('%s (%u-%u)', camp.name, camp.minLvl, camp.maxLvl)
            end
        end

        say(player, 'Also in range:')
        emitPacked(player, rest)
    end

    if level <= 9 then
        say(player, 'Starter elementals also camp in West Ronfaure, North Gustaberg, and East Sarutabaruta.')
    end

    say(player, string.format('!exp <level> looks up another level (1-%u).', levelCap()))
end

local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's',
}

commandObj.onTrigger = function(player, arg)
    if not isPlayer(player) then
        return
    end

    if arg == nil or arg == '' then
        printCamps(player, player:getMainLvl())
        return
    end

    local token = arg:match('^%s*(%S+)')
    if token == nil then
        printCamps(player, player:getMainLvl())
        return
    end

    local lower = string.lower(token)
    if lower == 'help' or lower == '?' then
        printUsage(player)
        return
    end

    local level = tonumber(token)
    if level == nil or level ~= math.floor(level) then
        printUsage(player)
        return
    end

    local cap = levelCap()
    if level < 1 or level > cap then
        say(player, string.format('Level must be 1-%u.', cap))
        return
    end

    printCamps(player, level)
end

xi.module.registerCommand('exp', commandObj)

-- FileWatcher re-runs module files but discards commandRegistry, so also
-- publish here so !exp is live without a map restart.
xi.commands = xi.commands or {}
xi.commands.exp = commandObj
