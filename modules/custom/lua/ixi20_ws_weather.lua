-----------------------------------
-- Imagine XI 2.0: weather and day always apply to elemental weaponskills.
-- Stock addBonusesAbility uses the nuke 33% roll. Burning Blade, Frostbite,
-- hybrids (Tachi: Jinpu, Flaming Arrow), and other WS with params.ele now
-- use the helix rule: matching weather / day always boosts, opposite always
-- reduces. Rates stay stock (10% single / 25% double / 10% day, obi and
-- iridescence included). Physical WS with no element are unchanged.
-- FileWatcher drops addOverride; assignment wrap stays live.
-- Do not return this module.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/spells/damage_spell')
require('scripts/globals/weaponskills')
-----------------------------------

local m = Module:new('ixi20_ws_weather')

local forceWeather = false

local function isElementalWS(wsParams)
    return wsParams and (wsParams.ele or 0) > xi.element.NONE
end

local function wrapDayWeather(fn)
    return function(caster, spellElement, alwaysApply)
        return fn(caster, spellElement, alwaysApply or forceWeather)
    end
end

local function wrapWeaponskill(fn)
    return function(attacker, target, wsID, wsParams, ...)
        local previous = forceWeather
        if isElementalWS(wsParams) then
            forceWeather = true
        end

        local ok, a, b, c, d, e = pcall(fn, attacker, target, wsID, wsParams, ...)
        forceWeather = previous
        if not ok then
            error(a)
        end

        return a, b, c, d, e
    end
end

m:addOverride('xi.spells.damage.calculateDayAndWeather', function(caster, spellElement, alwaysApply)
    return super(caster, spellElement, alwaysApply or forceWeather)
end)

m:addOverride('xi.weaponskills.doMagicWeaponskill', function(attacker, target, wsID, wsParams, tp, action, primaryMsg)
    local previous = forceWeather
    if isElementalWS(wsParams) then
        forceWeather = true
    end

    local a, b, c, d, e = super(attacker, target, wsID, wsParams, tp, action, primaryMsg)
    forceWeather = previous
    return a, b, c, d, e
end)

m:addOverride('xi.weaponskills.doPhysicalWeaponskill', function(attacker, target, wsID, wsParams, tp, action, primaryMsg, taChar)
    local previous = forceWeather
    if isElementalWS(wsParams) then
        forceWeather = true
    end

    local a, b, c, d, e = super(attacker, target, wsID, wsParams, tp, action, primaryMsg, taChar)
    forceWeather = previous
    return a, b, c, d, e
end)

m:addOverride('xi.weaponskills.doRangedWeaponskill', function(attacker, target, wsID, wsParams, tp, action, primaryMsg)
    local previous = forceWeather
    if isElementalWS(wsParams) then
        forceWeather = true
    end

    local a, b, c, d, e = super(attacker, target, wsID, wsParams, tp, action, primaryMsg)
    forceWeather = previous
    return a, b, c, d, e
end)

if xi.spells.damage and not xi.spells.damage._ixi20WsWeather then
    xi.spells.damage._ixi20WsWeather = true
    xi.spells.damage.calculateDayAndWeather = wrapDayWeather(xi.spells.damage.calculateDayAndWeather)
end

if xi.weaponskills and not xi.weaponskills._ixi20WsWeather then
    xi.weaponskills._ixi20WsWeather = true
    xi.weaponskills.doMagicWeaponskill    = wrapWeaponskill(xi.weaponskills.doMagicWeaponskill)
    xi.weaponskills.doPhysicalWeaponskill = wrapWeaponskill(xi.weaponskills.doPhysicalWeaponskill)
    xi.weaponskills.doRangedWeaponskill   = wrapWeaponskill(xi.weaponskills.doRangedWeaponskill)
end
