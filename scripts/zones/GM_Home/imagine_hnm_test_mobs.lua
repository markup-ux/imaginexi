-----------------------------------
-- HNM Test Mobs (GM Home)
-- Zone 210 only: passive (no aggro/link) and rapid mob-skill spam while engaged.
-----------------------------------

local m = {}

-- Time between forced skills while fighting (ms). Keep > ~1s so animations can play.
local skillSpamIntervalMs = 1100
-- TP top-up so MobSkill selection almost always has TP.
local skillSpamTpGrant    = 4500
-- Forced Call Beast / Activate attempts while pet is not already out (ms).
local summonSkillIntervalMs = 6500

local function applyPassiveTestMods(mobArg)
    mobArg:setDropID(0)
    mobArg:setMobMod(xi.mobMod.NO_DROPS, 1)

    mobArg:setMobMod(xi.mobMod.NO_AGGRO, 1)
    mobArg:setMobMod(xi.mobMod.NO_LINK, 1)
    mobArg:setMobMod(xi.mobMod.SIGHT_RANGE, 0)
    mobArg:setMobMod(xi.mobMod.SOUND_RANGE, 0)
    mobArg:setMobMod(xi.mobMod.MAGIC_RANGE, 0)

    mobArg:setLocalVar('[gmHnmTest]spamArmed', 0)
    mobArg:setLocalVar('[gmHnmTest]summonArmed', 0)
end

local function scheduleAbilitySpam(mobArg)
    mobArg:timer(skillSpamIntervalMs, function(m)
        if not m or not m:isAlive() then
            return
        end

        if m:isEngaged() then
            m:addTP(skillSpamTpGrant)
            if m:canUseAbilities() then
                m:useMobAbility()
            end

            scheduleAbilitySpam(m)
        end
    end)
end

--- Periodically forces Call Beast (1017) or Activate (1901) when no pet is spawned (requires xi.pet.setMobPet on spawn).
local function scheduleSummonSkillSpam(mobArg, skillId)
    mobArg:timer(summonSkillIntervalMs, function(m)
        if not m or not m:isAlive() then
            return
        end

        if m:isEngaged() then
            if not m:hasPet() and m:canUseAbilities() then
                -- ignoreDistance = true: easier to test in GM Home without position failures.
                m:useMobAbility(skillId, nil, 0, true)
            end

            scheduleSummonSkillSpam(m, skillId)
        end
    end)
end

local hnmTestMobs =
{
    -- name, groupId, groupZoneId, minLevel, maxLevel, x, y, z, rotation
    { 'Fafnir',        5, 154, 90, 90, -24.0, 0.0, -12.0, 128 },
    { 'Nidhogg',       6, 154, 90, 90, -24.0, 0.0,  12.0, 128 },
    { 'Adamantoise',   6, 128, 70, 70, -12.0, 0.0, -12.0, 128 },
    { 'Aspidochelone', 7, 128, 85, 85, -12.0, 0.0,  12.0, 128 },
    { 'Behemoth',      9, 127, 70, 70,   0.0, 0.0, -12.0, 128 },
    { 'King Behemoth', 10, 127, 85, 85,  0.0, 0.0,  12.0, 128 },
    { 'Roc',          41, 120, 55, 55,  12.0, 0.0, -12.0, 128 },
    { 'Simurgh',      41, 110, 58, 58,  12.0, 0.0,  12.0, 128 },
    { 'Cerberus',     37,  61, 85, 85,  24.0, 0.0, -12.0, 128 },
    { 'Khimaira',     59,  79, 85, 85,  24.0, 0.0,  12.0, 128 },
}

-- Same pool/group linkage as retail Mamool Ja Handler / Hilltroll Puppetmaster; pets match zone scripts.
local summonTestMobs =
{
    {
        name        = 'GMTest_Mamool_Handler',
        packetName  = 'Mamool Ja Handler [Call Beast test]',
        groupId     = 5,
        groupZoneId = 48,
        minLevel    = 75,
        maxLevel    = 75,
        x = 36.0, y = 0.0, z = -12.0, rotation = 128,
        petOffset   = 1,
        petName     = 'Mamool_Jas_Lizard',
        summonSkillId = xi.mobSkill.CALL_BEAST,
    },
    {
        name        = 'GMTest_Hilltroll_Puppetmaster',
        packetName  = 'Hilltroll Puppetmaster [Activate test]',
        groupId     = 17,
        groupZoneId = 61,
        minLevel    = 80,
        maxLevel    = 80,
        x = 36.0, y = 0.0, z = 12.0, rotation = 128,
        petOffset   = 1,
        petName     = 'Trolls_Automaton',
        summonSkillId = 1901, -- activate (mob_skills.sql); spawns linked Trolls_Automaton
    },
}

local function registerTestMob(zone, data, opts)
    opts = opts or {}

    local mob = zone:insertDynamicEntity({
        objtype     = xi.objType.MOB,
        name        = data.name,
        packetName  = data.packetName,
        groupId     = data.groupId,
        groupZoneId = data.groupZoneId,
        minLevel    = data.minLevel,
        maxLevel    = data.maxLevel,
        x           = data.x,
        y           = data.y,
        z           = data.z,
        rotation    = data.rotation,
        releaseIdOnDisappear  = true,
        specialSpawnAnimation = true,

        onMobSpawn = function(mobArg)
            applyPassiveTestMods(mobArg)

            if opts.onSpawnExtra then
                opts.onSpawnExtra(mobArg)
            end
        end,

        onMobFight = function(mobArg, target)
            if not target then
                return
            end

            if mobArg:getLocalVar('[gmHnmTest]spamArmed') == 0 then
                mobArg:setLocalVar('[gmHnmTest]spamArmed', 1)
                scheduleAbilitySpam(mobArg)
            end

            if opts.summonSkillId and mobArg:getLocalVar('[gmHnmTest]summonArmed') == 0 then
                mobArg:setLocalVar('[gmHnmTest]summonArmed', 1)
                scheduleSummonSkillSpam(mobArg, opts.summonSkillId)
            end
        end,

        onMobDisengage = function(mobArg)
            mobArg:setLocalVar('[gmHnmTest]spamArmed', 0)
            mobArg:setLocalVar('[gmHnmTest]summonArmed', 0)
        end,
    })

    if mob then
        mob:setSpawn(data.x, data.y, data.z, data.rotation)
        mob:spawn()
    end
end

function m.register(zone)
    for _, data in ipairs(hnmTestMobs) do
        registerTestMob(zone, {
            name        = data[1],
            packetName  = data[1],
            groupId     = data[2],
            groupZoneId = data[3],
            minLevel    = data[4],
            maxLevel    = data[5],
            x           = data[6],
            y           = data[7],
            z           = data[8],
            rotation    = data[9],
        })
    end

    for _, data in ipairs(summonTestMobs) do
        registerTestMob(zone, data, {
            summonSkillId = data.summonSkillId,
            onSpawnExtra = function(mobArg)
                xi.pet.setMobPet(mobArg, data.petOffset, data.petName)
            end,
        })
    end
end

return m
