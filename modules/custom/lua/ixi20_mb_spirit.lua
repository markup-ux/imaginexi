-----------------------------------
-- Imagine XI 2.0: a magic burst pops an elemental spirit of that element.
-- The spirit only casts spells that caster's job can use at their level.
-- It leaves when that mob dies. One spirit of each element can be up
-- in a zone at a time. Uses the starter elemental groups (zone 100, 38-45)
-- for the pool, with the summoning-spirit look.
-- Do not return this module.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_mb_spirit')

local GROUP_ZONE_ID = 100
local CAST_LOCK_SEC = 8
local CAST_RANGE    = 18
local MARK_VAR      = 'IXI20_MB_SPIRIT'
local NEXT_CAST_VAR = 'IXI20_MB_NEXT_CAST'

-- One live spirit per element per zone. Value is the spirit entity.
local active = {}

local SPIRIT =
{
    [xi.element.FIRE] =
    {
        packetName = 'Fire Spirit',
        name       = 'Fire_Spirit',
        groupId    = 38,
        look       = '0000080000000000000000000000000000000000',
        spells     =
        {
            xi.magic.spell.FIRE,
            xi.magic.spell.FIRE_II,
            xi.magic.spell.FIRE_III,
            xi.magic.spell.FIRE_IV,
            xi.magic.spell.FIRE_V,
            xi.magic.spell.FLARE,
            xi.magic.spell.BURN,
        },
    },
    [xi.element.ICE] =
    {
        packetName = 'Ice Spirit',
        name       = 'Ice_Spirit',
        groupId    = 39,
        look       = '0000090000000000000000000000000000000000',
        spells     =
        {
            xi.magic.spell.PARALYZE,
            xi.magic.spell.BLIZZARD,
            xi.magic.spell.BLIZZARD_II,
            xi.magic.spell.BLIZZARD_III,
            xi.magic.spell.BLIZZARD_IV,
            xi.magic.spell.BLIZZARD_V,
            xi.magic.spell.FREEZE,
            xi.magic.spell.FROST,
            xi.magic.spell.BIND,
        },
    },
    [xi.element.WIND] =
    {
        packetName = 'Air Spirit',
        name       = 'Air_Spirit',
        groupId    = 40,
        look       = '00000A0000000000000000000000000000000000',
        spells     =
        {
            xi.magic.spell.SILENCE,
            xi.magic.spell.AERO,
            xi.magic.spell.AERO_II,
            xi.magic.spell.AERO_III,
            xi.magic.spell.AERO_IV,
            xi.magic.spell.AERO_V,
            xi.magic.spell.GRAVITY,
            xi.magic.spell.CHOKE,
        },
    },
    [xi.element.EARTH] =
    {
        packetName = 'Earth Spirit',
        name       = 'Earth_Spirit',
        groupId    = 41,
        look       = '00000B0000000000000000000000000000000000',
        spells     =
        {
            xi.magic.spell.SLOW,
            xi.magic.spell.STONE,
            xi.magic.spell.STONE_II,
            xi.magic.spell.STONE_III,
            xi.magic.spell.STONE_IV,
            xi.magic.spell.STONE_V,
            xi.magic.spell.QUAKE,
            xi.magic.spell.RASP,
        },
    },
    [xi.element.THUNDER] =
    {
        packetName = 'Thunder Spirit',
        name       = 'Thunder_Spirit',
        groupId    = 42,
        look       = '00000D0000000000000000000000000000000000',
        spells     =
        {
            xi.magic.spell.THUNDER,
            xi.magic.spell.THUNDER_II,
            xi.magic.spell.THUNDER_III,
            xi.magic.spell.THUNDER_IV,
            xi.magic.spell.THUNDER_V,
            xi.magic.spell.BURST,
            xi.magic.spell.SHOCK,
        },
    },
    [xi.element.WATER] =
    {
        packetName = 'Water Spirit',
        name       = 'Water_Spirit',
        groupId    = 43,
        look       = '00000C0000000000000000000000000000000000',
        spells     =
        {
            xi.magic.spell.WATER,
            xi.magic.spell.WATER_II,
            xi.magic.spell.WATER_III,
            xi.magic.spell.WATER_IV,
            xi.magic.spell.WATER_V,
            xi.magic.spell.FLOOD,
            xi.magic.spell.POISON,
            xi.magic.spell.POISON_II,
            xi.magic.spell.DROWN,
        },
    },
    [xi.element.LIGHT] =
    {
        packetName = 'Light Spirit',
        name       = 'Light_Spirit',
        groupId    = 44,
        look       = '00000E0000000000000000000000000000000000',
        spells     =
        {
            xi.magic.spell.CURE,
            xi.magic.spell.CURE_II,
            xi.magic.spell.CURE_III,
            xi.magic.spell.CURE_IV,
            xi.magic.spell.CURE_V,
            xi.magic.spell.CURAGA,
            xi.magic.spell.CURAGA_II,
            xi.magic.spell.CURAGA_III,
            xi.magic.spell.CURAGA_IV,
            xi.magic.spell.HOLY,
            xi.magic.spell.HOLY_II,
            xi.magic.spell.DIA,
            xi.magic.spell.DIA_II,
            xi.magic.spell.BANISH,
            xi.magic.spell.BANISH_II,
            xi.magic.spell.BANISH_III,
            xi.magic.spell.BANISH_IV,
            xi.magic.spell.PROTECT,
            xi.magic.spell.PROTECT_II,
            xi.magic.spell.PROTECT_III,
            xi.magic.spell.PROTECT_IV,
            xi.magic.spell.PROTECT_V,
            xi.magic.spell.SHELL,
            xi.magic.spell.SHELL_II,
            xi.magic.spell.SHELL_III,
            xi.magic.spell.SHELL_IV,
            xi.magic.spell.SHELL_V,
            xi.magic.spell.HASTE,
            xi.magic.spell.REGEN,
            xi.magic.spell.FLASH,
        },
    },
    [xi.element.DARK] =
    {
        packetName = 'Dark Spirit',
        name       = 'Dark_Spirit',
        groupId    = 45,
        look       = '00000F0000000000000000000000000000000000',
        spells     =
        {
            xi.magic.spell.BIO,
            xi.magic.spell.BIO_II,
            xi.magic.spell.DRAIN,
            xi.magic.spell.ASPIR,
            xi.magic.spell.STUN,
            xi.magic.spell.SLEEP,
            xi.magic.spell.BLIND,
            xi.magic.spell.SLEEP_II,
            xi.magic.spell.DISPEL,
            xi.magic.spell.ABSORB_STR,
            xi.magic.spell.ABSORB_DEX,
            xi.magic.spell.ABSORB_VIT,
            xi.magic.spell.ABSORB_AGI,
            xi.magic.spell.ABSORB_INT,
            xi.magic.spell.ABSORB_MND,
            xi.magic.spell.ABSORB_CHR,
            xi.magic.spell.SLEEPGA,
            xi.magic.spell.SLEEPGA_II,
            xi.magic.spell.ABSORB_TP,
        },
    },
}

local function isDown(entity)
    if not entity then
        return true
    end

    local ok, down = pcall(function()
        if entity.getStatus and entity:getStatus() == xi.status.DISAPPEAR then
            return true
        end

        if entity.isAlive and not entity:isAlive() then
            return true
        end

        if entity.getHP and entity:getHP() <= 0 then
            return true
        end

        return false
    end)

    if not ok then
        return true
    end

    return down
end

local function zoneSlots(zoneId)
    active[zoneId] = active[zoneId] or {}
    return active[zoneId]
end

local function sameSpirit(left, right)
    if left == right then
        return true
    end

    if type(left) ~= 'userdata' or type(right) ~= 'userdata' then
        return false
    end

    local ok, match = pcall(function()
        return left:getID() == right:getID()
    end)

    return ok and match
end

local function clearSlot(zoneId, element, spirit)
    local slots = active[zoneId]
    if not slots then
        return
    end

    if spirit == nil or spirit == true or sameSpirit(slots[element], spirit) then
        slots[element] = nil
    end
end

local function spiritAlive(zoneId, element)
    local slots = active[zoneId]
    local spirit = slots and slots[element]
    if not spirit or spirit == true then
        return spirit == true
    end

    if isDown(spirit) then
        slots[element] = nil
        return false
    end

    return true
end

local function despawnSpirit(spirit, zoneId, element)
    clearSlot(zoneId, element, spirit)

    if not spirit or not spirit.setStatus or isDown(spirit) then
        return
    end

    pcall(function()
        spirit:disengage()
    end)
    pcall(function()
        spirit:setStatus(xi.status.DISAPPEAR)
    end)
end

-- Job level the caster must be to use this spell. Nil when neither
-- main nor sub can cast it at their current level.
local function spellRequirement(caster, spellId)
    local spell = GetSpell(spellId)
    if not spell or not spell.getLevel then
        return nil
    end

    if spell.canTargetEnemy and not spell:canTargetEnemy() then
        return nil
    end

    local mainJob = caster:getMainJob()
    local mainReq = spell:getLevel(mainJob)
    if mainReq > 0 and caster:getMainLvl() >= mainReq then
        return mainReq
    end

    local subJob = caster:getSubJob()
    if subJob and subJob > 0 then
        local subReq = spell:getLevel(subJob)
        if subReq > 0 and caster:getJobLevel(subJob) >= subReq then
            return subReq
        end
    end

    return nil
end

local function allowedSpells(caster, profile)
    local list    = {}
    local bestReq = 0

    for _, spellId in ipairs(profile.spells) do
        local req = spellRequirement(caster, spellId)
        if req then
            list[#list + 1] = { id = spellId, req = req }
            if req > bestReq then
                bestReq = req
            end
        end
    end

    return list, bestReq
end

local function pickSpell(list, bestReq)
    if #list == 0 then
        return nil
    end

    local pool = list
    if bestReq > 0 and math.randomInt(1, 100) <= 70 then
        local top = {}
        for _, entry in ipairs(list) do
            if entry.req == bestReq then
                top[#top + 1] = entry
            end
        end

        if #top > 0 then
            pool = top
        end
    end

    return pool[math.randomInt(1, #pool)].id
end

local function tryCast(spirit, foe, list, bestReq)
    if not foe or isDown(foe) or #list == 0 then
        return
    end

    local action = spirit:getCurrentAction()
    if action == xi.act.MAGIC_CASTING or action == xi.act.MAGIC_START then
        return
    end

    if spirit:checkDistance(foe) > CAST_RANGE then
        return
    end

    local now = os.time()
    if now < spirit:getLocalVar(NEXT_CAST_VAR) then
        return
    end

    local spellId = pickSpell(list, bestReq)
    if not spellId then
        return
    end

    spirit:setLocalVar(NEXT_CAST_VAR, now + CAST_LOCK_SEC)
    pcall(function()
        spirit:castSpell(spellId, foe)
    end)
end

local function resolveZone(entity)
    local inst = entity.getInstance and entity:getInstance()
    if inst and inst.insertDynamicEntity then
        return inst
    end

    local zone = entity.getZone and entity:getZone()
    if zone and zone.insertDynamicEntity then
        return zone
    end

    local zoneId = entity:getZoneID()
    if zoneId and zoneId > 0 and GetZone then
        return GetZone(zoneId)
    end

    return nil
end

local function popSpirit(caster, target, element)
    local profile = SPIRIT[element]
    if not profile or not caster or not caster:isPC() or not target then
        return
    end

    if target.getObjType and target:getObjType() ~= xi.objType.MOB then
        return
    end

    if target:getLocalVar(MARK_VAR) == 1 or isDown(target) then
        return
    end

    local zoneId = target:getZoneID()
    if not zoneId or zoneId == 0 then
        return
    end

    if spiritAlive(zoneId, element) then
        return
    end

    local zone = resolveZone(target)
    if not zone then
        return
    end

    local list, bestReq = allowedSpells(caster, profile)
    local level         = utils.clamp(caster:getMainLvl() or 1, 1, 255)
    local foeTargid     = target:getTargID()
    local slots         = zoneSlots(zoneId)

    slots[element] = true

    local spirit = zone:insertDynamicEntity({
        objtype               = xi.objType.MOB,
        name                  = profile.name,
        packetName            = profile.packetName,
        look                  = profile.look,
        groupId               = profile.groupId,
        groupZoneId           = GROUP_ZONE_ID,
        minLevel              = level,
        maxLevel              = level,
        x                     = target:getXPos() + 1.5,
        y                     = target:getYPos(),
        z                     = target:getZPos() + 1.5,
        rotation              = target:getRotPos(),
        releaseIdOnDisappear  = true,
        specialSpawnAnimation = true,
        isAggroable           = false,
        onMobSpawn            = function(mobArg)
            mobArg:setLocalVar(MARK_VAR, 1)
            mobArg:setAllegiance(xi.allegiance.PLAYER)
            mobArg:setMobMod(xi.mobMod.NO_AGGRO, 1)
            mobArg:setMobMod(xi.mobMod.NO_LINK, 1)
            mobArg:setMobMod(xi.mobMod.NO_DROPS, 1)
            mobArg:setMobMod(xi.mobMod.GIL_MAX, 0)
            mobArg:setMobMod(xi.mobMod.CHARMABLE, 0)
            mobArg:setMobMod(xi.mobMod.SKIP_ALLEGIANCE_CHECK, 1)
            mobArg:setMobAbilityEnabled(false)
            mobArg:setMagicCastingEnabled(false)
            mobArg:addMod(xi.mod.REFRESH, 25)
            mobArg:setMP(mobArg:getMaxMP())

            local foe = mobArg:getEntity(foeTargid)
            if foe and not isDown(foe) then
                mobArg:updateEnmity(foe)
                mobArg:engage(foeTargid)
            end
        end,
        onMobFight = function(mobArg)
            local foe = mobArg:getEntity(foeTargid)
            if isDown(foe) then
                despawnSpirit(mobArg, zoneId, element)
                return
            end

            if not mobArg:isEngaged() then
                mobArg:updateEnmity(foe)
                mobArg:engage(foeTargid)
            end

            tryCast(mobArg, foe, list, bestReq)
        end,
        onMobRoam = function(mobArg)
            local foe = mobArg:getEntity(foeTargid)
            if isDown(foe) then
                despawnSpirit(mobArg, zoneId, element)
                return
            end

            mobArg:updateEnmity(foe)
            mobArg:engage(foeTargid)
        end,
        onMobDeath = function(mobArg)
            clearSlot(zoneId, element, mobArg)
        end,
    })

    if not spirit then
        clearSlot(zoneId, element, true)
        printf('[ixi20_mb_spirit] spawn failed zone=%u %s', zoneId, profile.packetName)
        return
    end

    slots[element] = spirit
    spirit:setSpawn(target:getXPos() + 1.5, target:getYPos(), target:getZPos() + 1.5, target:getRotPos())
    spirit:spawn()

    spirit:timer(1000, function(mobArg)
        local function watch()
            if not mobArg or isDown(mobArg) then
                clearSlot(zoneId, element, mobArg)
                return
            end

            local foe = mobArg:getEntity(foeTargid)
            if isDown(foe) then
                despawnSpirit(mobArg, zoneId, element)
                return
            end

            mobArg:timer(1000, watch)
        end

        watch()
    end)
end

local function isBurstMessage(spell)
    if not spell or not spell.getMsg then
        return false
    end

    local msg = spell:getMsg()
    if
        msg == xi.msg.basic.MAGIC_BURST_DAMAGE or
        msg == xi.msg.basic.MAGIC_BURST_ENFEEB or
        msg == xi.msg.basic.MAGIC_BURST_ENFEEB_IS
    then
        return true
    end

    return spell.getMagicBurstMessage and msg == spell:getMagicBurstMessage()
end

local function onBurst(caster, target, spell)
    if not isBurstMessage(spell) then
        return
    end

    popSpirit(caster, target, spell:getElement())
end

m:addOverride('xi.spells.damage.useDamageSpell', function(caster, target, spell)
    local result = super(caster, target, spell)
    onBurst(caster, target, spell)
    return result
end)

m:addOverride('xi.spells.enfeebling.useEnfeeblingSpell', function(caster, target, spell)
    local result = super(caster, target, spell)
    onBurst(caster, target, spell)
    return result
end)

m:addOverride('xi.spells.enfeebling.useEnfeeblingSong', function(caster, target, spell)
    local result = super(caster, target, spell)
    onBurst(caster, target, spell)
    return result
end)

m:addOverride('xi.spells.blue.useMagicalSpell', function(caster, target, spell, params)
    local result = super(caster, target, spell, params)
    onBurst(caster, target, spell)
    return result
end)

m:addOverride('xi.spells.blue.useEnfeeblingSpell', function(caster, target, spell, params)
    local result = super(caster, target, spell, params)
    onBurst(caster, target, spell)
    return result
end)
