-----------------------------------
-- Shared HNM healer-pressure mechanics: telegraphed AoE pulses, status
-- packages, MP burn, and one-time Doom spotlights.
--
-- Design intent: anti-melt (hnm_anti_melt.lua) sets a floor on fight length;
-- this module fills that time with sustain pressure so healing skill decides
-- the fight. Every mechanic telegraphs 2-3s ahead through the same chat
-- channel as the anti-melt ward: Trust healers react late and cure singly,
-- human healers who anticipate keep the party topped.
--
-- Per-mob tuning lives in xi.healerPressure.config, keyed by internal mob
-- name. Pulse damage and MP burn scale down with the same engaged
-- real-player count anti-melt uses (trusts excluded).
-----------------------------------
require('scripts/globals/hnm_anti_melt')
-----------------------------------
xi = xi or {}
xi.healerPressure = xi.healerPressure or {}

xi.healerPressure.settings =
{
    TELEGRAPH_WINDUP_MS = 2500,
    PULSE_RANGE         = 25,
    ENGAGE_GAP_S        = 20, -- combat-tick gap treated as a re-pull (resets pulse timer)
    DOOM_POWER          = 10,
    DOOM_TICK           = 3,
}

-- Pulse/MP-burn multiplier by engaged real players (trusts excluded).
xi.healerPressure.scalingByPlayers =
{
    [1] = 0.50,
    [2] = 0.60,
    [3] = 0.70,
    [4] = 0.80,
    [5] = 0.90,
    [6] = 1.00,
}

local elementTelegraph =
{
    [xi.element.FIRE]    = 'Searing heat builds around you...',
    [xi.element.ICE]     = 'A freezing chill builds around you...',
    [xi.element.WIND]    = 'Howling winds build around you...',
    [xi.element.EARTH]   = 'The ground trembles beneath you...',
    [xi.element.THUNDER] = 'The air crackles with lightning...',
    [xi.element.WATER]   = 'A crushing tide builds around you...',
    [xi.element.LIGHT]   = 'Blinding radiance builds around you...',
    [xi.element.DARK]    = 'Smothering darkness builds around you...',
}

-- Per-mob configuration, keyed by internal mob name.
-- pulse:    element, hpPercent (of each target's max HP at full engagement;
--           0 = telegraphed status/MP delivery only), intervalS, mpPercent.
-- statuses: applied to pulse targets when the pulse resolves.
-- doom:     one-time spotlight below hpp; Cursna/Holy Water counterplay.
xi.healerPressure.config =
{
    -- Sky gods: elemental pulse + one thematic status each. Kirin's pressure
    -- is his god summons; he gets the pulse only.
    ['Genbu']  =
    {
        pulse    = { element = xi.element.WATER, hpPercent = 40, intervalS = 75 },
        statuses = { { effect = xi.effect.SLOW, power = 3000, duration = 30 } },
    },
    ['Seiryu'] =
    {
        pulse    = { element = xi.element.WIND, hpPercent = 40, intervalS = 75 },
        statuses = { { effect = xi.effect.SILENCE, power = 1, duration = 15 } },
    },
    ['Byakko'] =
    {
        pulse    = { element = xi.element.THUNDER, hpPercent = 40, intervalS = 75 },
        statuses = { { effect = xi.effect.PARALYSIS, power = 20, duration = 30 } },
    },
    ['Suzaku'] =
    {
        pulse    = { element = xi.element.FIRE, hpPercent = 40, intervalS = 75 },
        statuses = { { effect = xi.effect.BURN, power = 20, tick = 3, duration = 30 } },
    },
    ['Kirin'] =
    {
        pulse = { element = xi.element.LIGHT, hpPercent = 40, intervalS = 75 },
    },

    -- Ancient wyrms: attrition identity. Slower cadence, lighter damage,
    -- but the pulse burns MP -- long flight-phase fights become an MP
    -- economy test.
    ['Tiamat'] =
    {
        pulse = { element = xi.element.FIRE, hpPercent = 35, intervalS = 90, mpPercent = 10 },
    },
    ['Jormungand'] =
    {
        pulse = { element = xi.element.ICE, hpPercent = 35, intervalS = 90, mpPercent = 10 },
    },
    ['Vrtra'] =
    {
        pulse = { element = xi.element.DARK, hpPercent = 35, intervalS = 90, mpPercent = 10 },
    },

    -- Ground kings: status-triage identity. Light pulse, real cleansing work.
    ['Fafnir'] =
    {
        pulse    = { element = xi.element.DARK, hpPercent = 25, intervalS = 75 },
        statuses =
        {
            { effect = xi.effect.PARALYSIS, power = 15, duration = 30 },
            { effect = xi.effect.BLINDNESS, power = 15, duration = 30 },
        },
    },
    ['Nidhogg'] =
    {
        pulse    = { element = xi.element.DARK, hpPercent = 25, intervalS = 75 },
        statuses =
        {
            { effect = xi.effect.PARALYSIS, power = 15, duration = 30 },
            { effect = xi.effect.BLINDNESS, power = 15, duration = 30 },
        },
    },
    ['Behemoth'] =
    {
        pulse    = { element = xi.element.THUNDER, hpPercent = 25, intervalS = 75 },
        statuses = { { effect = xi.effect.SLOW, power = 2000, duration = 30 } },
    },
    -- King Behemoth's Meteor is his damage spike; statuses only (hpPercent 0).
    ['King_Behemoth'] =
    {
        pulse    = { element = xi.element.THUNDER, hpPercent = 0, intervalS = 75 },
        statuses =
        {
            { effect = xi.effect.SLOW, power = 2500, duration = 30 },
            { effect = xi.effect.PARALYSIS, power = 15, duration = 30 },
        },
    },
    ['Adamantoise'] =
    {
        pulse    = { element = xi.element.WATER, hpPercent = 25, intervalS = 75 },
        statuses = { { effect = xi.effect.BLINDNESS, power = 20, duration = 30 } },
    },
    ['Aspidochelone'] =
    {
        pulse    = { element = xi.element.WATER, hpPercent = 25, intervalS = 75 },
        statuses = { { effect = xi.effect.BLINDNESS, power = 20, duration = 30 } },
    },
    ['Cerberus'] =
    {
        pulse    = { element = xi.element.FIRE, hpPercent = 30, intervalS = 75 },
        statuses = { { effect = xi.effect.BURN, power = 15, tick = 3, duration = 30 } },
    },

    -- Doom spotlights: Cassie (lore-natural) and Khimaira (dread theme).
    ['Capricious_Cassie'] =
    {
        doom = { hpp = 50, durationS = 30 },
    },
    ['Khimaira'] =
    {
        pulse = { element = xi.element.THUNDER, hpPercent = 25, intervalS = 75 },
        doom  = { hpp = 40, durationS = 30 },
    },

    -- Lottery kings: one simple mechanic each.
    ['Serket'] =
    {
        pulse    = { element = xi.element.EARTH, hpPercent = 0, intervalS = 75 },
        statuses = { { effect = xi.effect.POISON, power = 20, tick = 3, duration = 30 } },
    },
    ['King_Arthro'] =
    {
        pulse = { element = xi.element.WATER, hpPercent = 30, intervalS = 75 },
    },
    ['Lord_of_Onzozo'] =
    {
        pulse    = { element = xi.element.THUNDER, hpPercent = 0, intervalS = 75 },
        statuses = { { effect = xi.effect.PARALYSIS, power = 20, duration = 30 } },
    },
    ['Roc'] =
    {
        pulse = { element = xi.element.WIND, hpPercent = 30, intervalS = 75 },
    },
    ['Simurgh'] =
    {
        pulse    = { element = xi.element.WIND, hpPercent = 0, intervalS = 75 },
        statuses = { { effect = xi.effect.SLOW, power = 2500, duration = 30 } },
    },
}

---@param mob CBaseEntity
---@return table|nil
local function getConfig(mob)
    return xi.healerPressure.config[mob:getName()]
end

---@param mob CBaseEntity
---@return number
local function pressureScale(mob)
    local count = xi.hnmAntiMelt.countEngagedRealPlayers(mob)

    if count == 0 then
        count = 1
    end

    count = math.min(6, count)

    return xi.healerPressure.scalingByPlayers[count] or 1.0
end

---@param mob CBaseEntity
---@return table list of engaged PCs in pulse range
local function pulseTargets(mob)
    local targets = {}
    local seen    = {}

    for _, entry in ipairs(mob:getEnmityList()) do
        local member = entry.entity

        if
            member and
            member:isPC() and
            not member:isTrust() and
            not seen[member:getID()] and
            member:getHP() > 0 and
            mob:checkDistance(member) <= xi.healerPressure.settings.PULSE_RANGE
        then
            seen[member:getID()] = true
            table.insert(targets, member)
        end
    end

    return targets
end

---@param mob CBaseEntity
---@param message string
local function telegraph(mob, message)
    for _, entry in ipairs(mob:getEnmityList()) do
        local member = entry.entity

        if member and member:isPC() then
            member:printToPlayer(message, xi.msg.channel.NARROW_RANGE)
        end
    end
end

---@param mob CBaseEntity
local function resolvePulse(mob)
    mob:setLocalVar('[healerPressure]pulsePending', 0)

    local config = getConfig(mob)

    if not config or not config.pulse or not mob:isAlive() or not mob:isEngaged() then
        return
    end

    local pulse = config.pulse
    local scale = pressureScale(mob)

    for _, member in ipairs(pulseTargets(mob)) do
        if pulse.hpPercent and pulse.hpPercent > 0 then
            local damage = math.floor(member:getMaxHP() * (pulse.hpPercent / 100) * scale)
            damage = utils.clamp(utils.handleStoneskin(member, damage), 0, 99999)

            if damage > 0 then
                member:takeDamage(damage, mob, xi.attackType.MAGICAL, xi.damageType.ELEMENTAL + pulse.element)
            end
        end

        if pulse.mpPercent and pulse.mpPercent > 0 then
            member:delMP(math.floor(member:getMaxMP() * (pulse.mpPercent / 100) * scale))
        end

        if config.statuses then
            for _, status in ipairs(config.statuses) do
                member:addStatusEffect(status.effect,
                {
                    power    = status.power,
                    tick     = status.tick or 0,
                    duration = status.duration,
                })
            end
        end
    end
end

---@param mob CBaseEntity
local function tryPulse(mob)
    local config = getConfig(mob)

    if not config or not config.pulse then
        return
    end

    local now      = GetSystemTime()
    local lastTick = mob:getLocalVar('[healerPressure]lastTick')
    local nextAt   = mob:getLocalVar('[healerPressure]nextPulseAt')

    mob:setLocalVar('[healerPressure]lastTick', now)

    -- Fresh engage or re-pull after a wipe: start a full interval out.
    if nextAt == 0 or (lastTick > 0 and now - lastTick > xi.healerPressure.settings.ENGAGE_GAP_S) then
        mob:setLocalVar('[healerPressure]nextPulseAt', now + config.pulse.intervalS)
        return
    end

    if now < nextAt or mob:getLocalVar('[healerPressure]pulsePending') == 1 then
        return
    end

    mob:setLocalVar('[healerPressure]pulsePending', 1)
    mob:setLocalVar('[healerPressure]nextPulseAt', now + config.pulse.intervalS)

    telegraph(mob, config.pulse.message or elementTelegraph[config.pulse.element])

    mob:timer(xi.healerPressure.settings.TELEGRAPH_WINDUP_MS, function(mobArg)
        if mobArg then
            resolvePulse(mobArg)
        end
    end)
end

---@param mob CBaseEntity
local function tryDoom(mob)
    local config = getConfig(mob)

    if not config or not config.doom then
        return
    end

    if mob:getLocalVar('[healerPressure]doomApplied') == 1 then
        return
    end

    if mob:getHPP() > config.doom.hpp then
        return
    end

    local targets = pulseTargets(mob)

    if #targets == 0 then
        return
    end

    mob:setLocalVar('[healerPressure]doomApplied', 1)

    local victim = targets[math.random(1, #targets)]

    telegraph(mob, victim:getName() .. ' has been marked for doom!')

    mob:timer(2000, function(mobArg)
        if
            mobArg and
            mobArg:isAlive() and
            victim:isAlive() and
            mobArg:checkDistance(victim) <= xi.healerPressure.settings.PULSE_RANGE
        then
            victim:addStatusEffect(xi.effect.DOOM,
            {
                power    = xi.healerPressure.settings.DOOM_POWER,
                tick     = xi.healerPressure.settings.DOOM_TICK,
                duration = config.doom.durationS,
            })
        end
    end)
end

---@param mob CBaseEntity
xi.healerPressure.onSpawn = function(mob)
    mob:setLocalVar('[healerPressure]nextPulseAt', 0)
    mob:setLocalVar('[healerPressure]lastTick', 0)
    mob:setLocalVar('[healerPressure]pulsePending', 0)
    mob:setLocalVar('[healerPressure]doomApplied', 0)
end

---@param mob CBaseEntity
xi.healerPressure.onCombatTick = function(mob)
    tryPulse(mob)
    tryDoom(mob)
end

return xi.healerPressure
