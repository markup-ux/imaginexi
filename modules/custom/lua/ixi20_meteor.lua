-----------------------------------
-- Imagine XI 2.0: Meteor.
-- Stock Meteor refuses players unless Elemental Seal is up, and the
-- spell row is single-target, so a party meteor never fires.
-- Players cast it without Elemental Seal (overlay and /ma). BLM and SCH
-- both learn it at 37. The hit is a 10-yalm area. Party members who
-- cast together produce one meteor when the last of them to start
-- finishes. Earlier casters spend the cast and add their damage; the
-- last caster counts the most.
-- One party in an alliance can have a meteor in flight. A monster that
-- was just hit resists the next one, and that resistance fades over
-- five minutes. Mob casts stay on the stock formula. Their scripts
-- still set their own area in onSpellPrecast.
-- FileWatcher drops addOverride; the table assignment stays live.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_meteor')

local RADIUS         = 10
local WINDOW         = 20
local RESIST_SECONDS = 300
local RESIST_MULT    = 0.5 -- right after a hit; fades back to 1.0
local MAX_CASTERS    = 6

-- Retail never published the slot table. The wiki's shape is: solo is
-- the normal hit, the first caster of a group counts least, and the
-- last caster of six is multiplied by 6.5.
local ORDER_WEIGHT =
{
    [1] = { 1.0 },
    [2] = { 0.8, 1.8 },
    [3] = { 0.6, 1.2, 2.6 },
    [4] = { 0.5, 1.0, 1.8, 3.6 },
    [5] = { 0.5, 0.9, 1.5, 2.6, 4.8 },
    [6] = { 0.5, 0.8, 1.2, 2.0, 3.4, 6.5 },
}

local pending = {}
local active  = {}
local seq     = 0

local function partyKey(player)
    local leader = player:getPartyLeader()
    if leader then
        return leader:getID()
    end

    return player:getID()
end

local function casterContrib(caster)
    local stat = math.floor(caster:getStat(xi.mod.INT) + caster:getSkillLevel(xi.skill.ELEMENTAL_MAGIC) / 6)
    return ((100 + caster:getMod(xi.mod.MATT)) / 100) * stat * 3.5
end

local function prune()
    local now = GetSystemTime()
    local drop = {}
    for id, entry in pairs(pending) do
        if now - entry.started > WINDOW then
            drop[#drop + 1] = id
        end
    end

    for _, id in ipairs(drop) do
        pending[id] = nil
    end
end

local function allianceBusy(caster, key)
    local alliance = caster:getAlliance()
    if not alliance then
        return false
    end

    local now = GetSystemTime()
    for _, member in pairs(alliance) do
        if member:isPC() and member:getID() ~= caster:getID() and partyKey(member) ~= key then
            local entry = pending[member:getID()]
            if
                entry and
                not entry.fired and
                now - entry.started <= WINDOW and
                member:getCurrentAction() == xi.action.category.MAGIC_CASTING
            then
                return true
            end
        end
    end

    return false
end

local function laterCasterStillGoing(row)
    local wait = false
    local drop = {}

    for id, entry in pairs(pending) do
        if entry.partyKey == row.partyKey and entry.seq > row.seq and not entry.fired then
            local player = GetPlayerByID(entry.id)
            if player and player:getCurrentAction() == xi.action.category.MAGIC_CASTING then
                wait = true
            else
                drop[#drop + 1] = id
            end
        end
    end

    for _, id in ipairs(drop) do
        pending[id] = nil
    end

    return wait
end

local function collectVolley(row)
    local mates = {}
    for _, entry in pairs(pending) do
        if entry.partyKey == row.partyKey and not entry.fired and entry.contrib then
            mates[#mates + 1] = entry
        end
    end

    table.sort(mates, function(a, b)
        return a.seq < b.seq
    end)

    while #mates > MAX_CASTERS do
        if mates[1].id == row.id then
            table.remove(mates, 2)
        else
            table.remove(mates, 1)
        end
    end

    local weights = ORDER_WEIGHT[#mates] or ORDER_WEIGHT[MAX_CASTERS]
    local parts = {}
    for i, entry in ipairs(mates) do
        parts[i] = { contrib = entry.contrib, weight = weights[i] }
        if entry.id ~= row.id then
            entry.fired = true
        end
    end

    pending[row.id] = nil
    return parts
end

local function resistMultiplier(target)
    local recoverAt = target:getLocalVar('ixi20MeteorRecover')
    local now = GetSystemTime()
    if recoverAt <= now then
        return 1
    end

    local remaining = recoverAt - now
    local reduction = (1 - RESIST_MULT) * (remaining / RESIST_SECONDS)
    return 1 - reduction
end

local function applyPlayerDamage(caster, target, spell, parts)
    local damage = 0
    for _, part in ipairs(parts) do
        damage = damage + part.contrib * part.weight
    end

    local mdef = 100 + target:getMod(xi.mod.MDEF)
    if mdef < 1 then
        mdef = 1
    end

    damage = damage * 100 / mdef
    damage = math.floor(damage * resistMultiplier(target))
    damage = math.floor(damage * xi.spells.damage.calculateAbsorption(target, xi.element.NONE, false, true, false, false))
    damage = math.floor(damage * xi.spells.damage.calculateNullification(target, xi.element.NONE, false, true, false, false))
    damage = math.floor(damage * xi.spells.damage.calculateMTDR(caster, spell))
    damage = math.floor(damage * xi.combat.damage.calculateDamageAdjustment(target, false, true, false, false))

    damage = utils.clamp(utils.handlePhalanx(target, damage), 0, 99999)
    damage = utils.clamp(utils.handleOneForAll(target, damage), 0, 99999)
    damage = utils.handleStoneskin(target, damage, xi.attackType.MAGICAL)
    damage = target:checkDamageCap(damage)

    target:setLocalVar('ixi20MeteorRecover', GetSystemTime() + RESIST_SECONDS)
    target:takeSpellDamage(caster, spell, damage, xi.attackType.MAGICAL, xi.damageType.ELEMENTAL)
    target:handleAfflatusMiseryDamage(damage)
    target:updateEnmityFromDamage(caster, damage)

    return damage
end

local function mobMeteor(caster, target, spell)
    local damage = 0
    if caster:getFamily() == xi.mobFamily.BEHEMOTH then
        damage = caster:getMainLvl() * 15.5
    elseif caster:getSpecies() == xi.mobSpecies.PROMATHIA then
        damage = caster:getMainLvl() * 7
    else
        damage = ((100 + caster:getMod(xi.mod.MATT)) / (100 + target:getMod(xi.mod.MDEF)))
            * (caster:getStat(xi.mod.INT) + (caster:getMaxSkillLevel(caster:getMainLvl(), xi.job.BLM, xi.skill.ELEMENTAL_MAGIC)) / 6)
            * 9.4
    end

    damage = math.floor(damage * xi.spells.damage.calculateAbsorption(target, xi.element.NONE, false, true, false, false))
    damage = math.floor(damage * xi.spells.damage.calculateNullification(target, xi.element.NONE, false, true, false, false))
    damage = math.floor(damage * xi.spells.damage.calculateMTDR(caster, spell))
    damage = math.floor(damage * xi.combat.damage.calculateDamageAdjustment(target, false, true, false, false))
    damage = utils.clamp(utils.handlePhalanx(target, damage), 0, 99999)
    damage = utils.clamp(utils.handleOneForAll(target, damage), 0, 99999)
    damage = utils.handleStoneskin(target, damage, xi.attackType.MAGICAL)
    damage = target:checkDamageCap(damage)
    target:takeSpellDamage(caster, spell, damage, xi.attackType.MAGICAL, xi.damageType.ELEMENTAL)
    target:handleAfflatusMiseryDamage(damage)
    target:updateEnmityFromDamage(caster, damage)

    return damage
end

local function resolve(caster)
    local id = caster:getID()
    local row = pending[id]
    if row and row.fired then
        pending[id] = nil
        return { suppress = true }
    end

    if not row then
        row = {
            id       = id,
            seq      = seq,
            partyKey = partyKey(caster),
            contrib  = casterContrib(caster),
            started  = GetSystemTime(),
            fired    = false,
        }
        pending[id] = row
    end

    if laterCasterStillGoing(row) then
        caster:printToPlayer('Meteor is waiting on the last caster in your party.', xi.msg.channel.SYSTEM_3)
        return { suppress = true }
    end

    local parts = collectVolley(row)
    if #parts > 1 then
        caster:printToPlayer(string.format('Meteor strikes with %d casters.', #parts), xi.msg.channel.SYSTEM_3)
    end

    return { suppress = false, parts = parts }
end

local function onMagicCastingCheck(caster, target, spell)
    if not caster:isPC() then
        return 0
    end

    spell:setAoE(xi.magic.aoe.RADIAL)
    spell:setRadius(RADIUS)

    prune()
    active[caster:getID()] = nil

    local key = partyKey(caster)
    if allianceBusy(caster, key) then
        caster:printToPlayer('Another party in your alliance is already casting Meteor.', xi.msg.channel.SYSTEM_3)
        return xi.msg.basic.MAGIC_CANNOT_CAST
    end

    seq = seq + 1
    pending[caster:getID()] = {
        id       = caster:getID(),
        seq      = seq,
        partyKey = key,
        contrib  = casterContrib(caster),
        started  = GetSystemTime(),
        fired    = false,
    }

    return 0
end

local function onSpellCast(caster, target, spell)
    if not caster:isPC() then
        return mobMeteor(caster, target, spell)
    end

    local id = caster:getID()
    local decision = active[id]
    if not decision then
        decision = resolve(caster)
        active[id] = decision
    end

    if decision.suppress then
        spell:setMsg(xi.msg.basic.NONE)
        return 0
    end

    return applyPlayerDamage(caster, target, spell, decision.parts)
end

local function install()
    local meteor = xi.actions and xi.actions.spells and xi.actions.spells.black and xi.actions.spells.black.meteor
    if not meteor then
        return
    end

    meteor.onMagicCastingCheck = onMagicCastingCheck
    meteor.onSpellCast = onSpellCast
end

install()

m:addOverride('xi.actions.spells.black.meteor.onMagicCastingCheck', function(caster, target, spell)
    return onMagicCastingCheck(caster, target, spell)
end)

m:addOverride('xi.actions.spells.black.meteor.onSpellCast', function(caster, target, spell)
    return onSpellCast(caster, target, spell)
end)

m:addOverride('xi.server.onServerStart', function()
    super()
    install()
end)
