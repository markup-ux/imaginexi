-----------------------------------
-- Imagine XI 2.0: no job-ability recast while !godmode is on.
-- GodMode charvar 1 (full) and 2 (tier 1) both count.
-- Turning it on clears every job-ability timer already running (!reset).
-- The ability animation lock stays.
-- Yonin/Innin: server recast 146 also stamps client id 147.
-- Blood Pact timers stay in ixi20_no_bp_timers (applied when the pact fires).
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_godmode_ja')

local LISTENER     = 'IXI20_GODMODE_JA'
local YONIN_RECAST = 146
local INNIN_RECAST = 147

local function inGodMode(player)
    return player and player.isPC and player:isPC() and player:getCharVar('GodMode') ~= 0
end

local function asRecastId(value)
    if type(value) == 'number' then
        return value
    end

    return tonumber(value)
end

local function resetAbilityRecast(player, recastId)
    recastId = asRecastId(recastId)
    if recastId == nil then
        return
    end

    player:resetRecast(xi.recast.ABILITY, recastId)

    if recastId == YONIN_RECAST then
        player:resetRecast(xi.recast.ABILITY, INNIN_RECAST)
    end
end

-- !reset's ability wipe. Clears every timer already in the recast list,
-- including charges, rather than only IDs we can look up on the ability table.
local function clearAbilityRecasts(player)
    player:resetRecasts()
end

local function onAbilityUse(user, target, ability, action)
    if not inGodMode(user) or not ability or not ability.getRecastID then
        return
    end

    -- Battle packet is sent after this listener. A non-zero recast there
    -- starts the client timer again after the server wipe.
    if action and action.setRecast then
        action:setRecast(0)
    end

    resetAbilityRecast(user, ability:getRecastID())
end

local function attach(player)
    if not player or not player.isPC or not player:isPC() then
        return
    end

    player:removeListener(LISTENER)
    player:addListener('ABILITY_USE', LISTENER, onAbilityUse)

    if inGodMode(player) then
        clearAbilityRecasts(player)
    end
end

m:addOverride('xi.commands.godmode.onTrigger', function(player, tier)
    super(player, tier)

    -- Charvar is already 1 or 2 when the command turned godmode on.
    if inGodMode(player) then
        clearAbilityRecasts(player)
    end
end)

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    attach(player)
end)

-- FileWatcher reloads do not run onGameIn. Re-attach whoever is already zoned in.
if xi.zone and GetZone then
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

return m
