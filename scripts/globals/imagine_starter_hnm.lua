-----------------------------------
-- Starter-zone HNMs (ImagineXI)
-- Level 10 notorious mobs in nation starting fields. Pops when zone XP pool
-- fills; only players with effective main level <= 12 may engage/claim.
-----------------------------------
xi.imagine = xi.imagine or {}
xi.imagine.starterHnm = xi.imagine.starterHnm or {}

local starterHnm = xi.imagine.starterHnm

starterHnm.BASE_XP_THRESHOLD   = 100000
starterHnm.XP_JITTER_MIN       = 0.85
starterHnm.XP_JITTER_MAX       = 1.15
starterHnm.POST_KILL_COOLDOWN  = 45 * 60 -- seconds before XP counting resumes
starterHnm.DESPAWN_SECONDS     = 2 * 60 * 60
starterHnm.MAX_CLAIM_LEVEL     = 12
starterHnm.LOOT_ROLLS          = 3
starterHnm.CLUSTER_ROLLS       = 2
starterHnm.GIL_MIN             = 3000
starterHnm.GIL_MAX             = 8000
starterHnm.HP_SCALE            = 750   -- ~7.5x HP; solo at cap is impractical, 3-5 lowbies is the target
starterHnm.DAMAGE_MULTIPLIER   = 165   -- BASE_DAMAGE_MULTIPLIER percent
starterHnm.REGEN               = 14
starterHnm.AOE_INTERVAL_SEC  = 40
starterHnm.PHASE_HPP           = 50
starterHnm.PHASE_DAMAGE_MULT   = 200
starterHnm.PHASE_ATT_BONUS     = 28
starterHnm.PHASE_REGEN_BONUS   = 8
starterHnm.ADD_COUNT           = 2
starterHnm.XP_LISTENER_ID         = 'IMAGINE_STARTER_HNM_XP'
starterHnm.ENGAGE_GUARD_LISTENER_ID = 'IMAGINE_STARTER_HNM_ENGAGE_GUARD'

-- Oversized appearances borrowed from low-level field NMs (not 75-era world HNMs).
-- Combat stats still come from each zone's original groupId; only the model is swapped.
starterHnm.lookProfiles =
{
    ronfaure =
    {
        look          = '0x0000580100000000000000000000000000000000', -- giant ram
        modelSize     = 3,
        hitboxSize    = 5.8,
        appearanceSrc = 'Steelfleece Baldarich',
    },

    gustaberg =
    {
        look          = '0x0000E30200000000000000000000000000000000', -- giant
        modelSize     = 3,
        hitboxSize    = 5.4,
        appearanceSrc = 'Briareus',
    },

    saruta =
    {
        look          = '0x0000840100000000000000000000000000000000', -- morbol
        modelSize     = 3,
        hitboxSize    = 5.3,
        appearanceSrc = 'Stcemqestcint',
    },
}

-- Per-nation combat behavior (AoE rotation, phase adds, messaging).
starterHnm.combatProfiles =
{
    ronfaure =
    {
        addGroupId   = 18, -- Wild Sheep
        addName      = 'Wild Sheep',
        aoeSpells    = { xi.magic.spell.SLEEPGA, xi.magic.spell.RASP },
        phaseMessage = 'The warden stamps the earth and wild sheep rush to its defense!',
    },

    gustaberg =
    {
        addGroupId   = 19, -- Rock Lizard
        addName      = 'Rock Lizard',
        aoeSpells    = { xi.magic.spell.BIND, xi.magic.spell.STONE },
        phaseMessage = 'The sentinel bellows in rage and rock lizards skitter to its side!',
    },

    saruta =
    {
        addGroupId   = 6, -- Tiny Mandragora
        addName      = 'Tiny Mandragora',
        aoeSpells    = { xi.magic.spell.POISONGA, xi.magic.spell.SLEEPGA },
        phaseMessage = 'The warden exhales a foul spore cloud and mandragora sprouts erupt nearby!',
    },
}

-- Signature drops from level 1-15 zone NMs (equipment and notable NM loot).
starterHnm.lootPool =
{
    550,    -- Steam Clock
    769,    -- Red Rock
    910,    -- Lumbering Horn
    911,    -- Rampaging Horn
    1152,   -- Lump Of Bomb Steel
    2826,   -- Mandragora Scale
    2832,   -- Samwells Shank
    2834,   -- Immortal Molt
    2842,   -- Flawed Garnet
    912,    -- Beehive Chip
    12371,  -- Clipeus
    12736,  -- Mitts
    12864,  -- Slacks
    12992,  -- Solea
    13112,  -- Rabbit Charm
    13548,  -- Astral Ring
    13607,  -- Mist Silk Cape
    14803,  -- Optical Earring
    15218,  -- Entrancing Ribbon
    15351,  -- Bounding Boots
    15546,  -- Fasting Ring
    16185,  -- Pelte
    16296,  -- Armigers Lace
    16443,  -- Fruit Punches
    16486,  -- Beestinger
    17366,  -- Marys Horn
    17594,  -- Gelong Staff
    17811,  -- Katayama Ichimonji
    18246,  -- Rogetsurin
    18394,  -- Pilgrims Wand
    18412,  -- Gassan
    19043,  -- Tenax Strap
    19160,  -- Estramacon
    4527,   -- Jug Of Marys Milk
    19305,  -- Pike
    2854,   -- Stately Crab Shell
}

starterHnm.clusterPool =
{
    xi.item.FIRE_CLUSTER,
    xi.item.ICE_CLUSTER,
    xi.item.WIND_CLUSTER,
    xi.item.EARTH_CLUSTER,
    xi.item.LIGHTNING_CLUSTER,
    xi.item.WATER_CLUSTER,
    xi.item.LIGHT_CLUSTER,
    xi.item.DARK_CLUSTER,
}

starterHnm.zones =
{
    [xi.zone.WEST_RONFAURE] =
    {
        internalName = 'StarterHNM_WestRonfaure',
        packetName     = 'Ronfaure Warden',
        lookProfile    = 'ronfaure',
        groupId        = 25, -- Jaggedy-Eared Jack
        groupZoneId    = xi.zone.WEST_RONFAURE,
        x              = -200.0,
        y              = -60.0,
        z              = 200.0,
        rot            = 128,
        areaHint       = 'the La Theine Plateau approaches',
    },

    [xi.zone.EAST_RONFAURE] =
    {
        internalName = 'StarterHNM_EastRonfaure',
        packetName     = 'Eastron Warden',
        lookProfile    = 'ronfaure',
        groupId        = 25, -- Swamfisk
        groupZoneId    = xi.zone.EAST_RONFAURE,
        x              = 86.0,
        y              = -65.0,
        z              = 274.0,
        rot            = 128,
        areaHint       = 'the southern grasslands of East Ronfaure',
    },

    [xi.zone.SOUTH_GUSTABERG] =
    {
        internalName = 'StarterHNM_SouthGustaberg',
        packetName     = 'Gustaberg Warden',
        lookProfile    = 'gustaberg',
        groupId        = 29, -- Leaping Lizzy
        groupZoneId    = xi.zone.SOUTH_GUSTABERG,
        x              = -300.0,
        y              = 22.0,
        z              = -380.0,
        rot            = 64,
        areaHint       = 'the far southern cliffs of Gustaberg',
    },

    [xi.zone.NORTH_GUSTABERG] =
    {
        internalName = 'StarterHNM_NorthGustaberg',
        packetName     = 'Gustaberg Sentinel',
        lookProfile    = 'gustaberg',
        groupId        = 28, -- Maighdean Uaine
        groupZoneId    = xi.zone.NORTH_GUSTABERG,
        x              = 660.0,
        y              = 0.0,
        z              = 306.0,
        rot            = 190,
        areaHint       = 'the Konschtat Highlands border',
    },

    [xi.zone.EAST_SARUTABARUTA] =
    {
        internalName = 'StarterHNM_EastSaruta',
        packetName     = 'Saruta Warden',
        lookProfile    = 'saruta',
        groupId        = 25, -- Duke Decapod
        groupZoneId    = xi.zone.EAST_SARUTABARUTA,
        x              = -125.0,
        y              = -3.0,
        z              = -520.0,
        rot            = 4,
        areaHint       = 'the deep Sarutabaruta savanna',
    },

    [xi.zone.WEST_SARUTABARUTA] =
    {
        internalName = 'StarterHNM_WestSaruta',
        packetName     = 'Saruta Sentinel',
        lookProfile    = 'saruta',
        groupId        = 25, -- Tom Tit Tat
        groupZoneId    = xi.zone.WEST_SARUTABARUTA,
        x              = 320.0,
        y              = -7.0,
        z              = -45.0,
        rot            = 189,
        areaHint       = 'the Tarutaru waterways',
    },
}

local function xpVar(zoneId)
    return string.format('[StarterHNM]XP_%u', zoneId)
end

local function thresholdVar(zoneId)
    return string.format('[StarterHNM]Threshold_%u', zoneId)
end

local function cooldownVar(zoneId)
    return string.format('[StarterHNM]Cooldown_%u', zoneId)
end

function starterHnm.isEligible(player)
    return player
        and player:getObjType() == xi.objType.PC
        and player:getMainLvl() <= starterHnm.MAX_CLAIM_LEVEL
end

function starterHnm.getThreshold(zoneId)
    local stored = GetServerVariable(thresholdVar(zoneId))

    if stored <= 0 then
        local jitter = starterHnm.XP_JITTER_MIN + math.random() * (starterHnm.XP_JITTER_MAX - starterHnm.XP_JITTER_MIN)
        stored = math.floor(starterHnm.BASE_XP_THRESHOLD * jitter)
        SetServerVariable(thresholdVar(zoneId), stored)
    end

    return stored
end

function starterHnm.isOnCooldown(zoneId)
    return GetServerVariable(cooldownVar(zoneId)) > os.time()
end

function starterHnm.isActive(zoneId)
    local cfg = starterHnm.zones[zoneId]

    if not cfg then
        return false
    end

    local zone = GetZone(zoneId)

    if not zone then
        return false
    end

    local entities = zone:queryEntitiesByName('DE_' .. cfg.internalName)

    for _, mob in pairs(entities) do
        if mob:isSpawned() and mob:isAlive() then
            return true
        end
    end

    return false
end

function starterHnm.notifyIneligible(target, alwaysShow)
    if target:getObjType() ~= xi.objType.PC then
        return
    end

    if alwaysShow or target:getLocalVar('[starterHnm]warned') == 0 then
        target:setLocalVar('[starterHnm]warned', 1)
        target:printToPlayer(
            string.format(
                'Only adventurers of level %u or below may engage this notorious monster. (Your level: %u)',
                starterHnm.MAX_CLAIM_LEVEL,
                target:getMainLvl()
            ),
            xi.msg.channel.SYSTEM
        )
    end
end

function starterHnm.isStarterHnmMob(entity)
    return entity
        and entity:getObjType() == xi.objType.MOB
        and entity:getLocalVar('[starterHnm]mob') == 1
end

function starterHnm.rejectPlayerEngage(player, target)
    if not player or not starterHnm.isStarterHnmMob(target) then
        return false
    end

    if starterHnm.isEligible(player) then
        player:setLocalVar('[starterHnm]warned', 0)
        return false
    end

    starterHnm.notifyIneligible(player, true)
    target:resetEnmity(player)

    if target:isEngaged() then
        target:disengage()
    end

    if player:isEngaged() then
        player:disengage()
    end

    return true
end

function starterHnm.rejectIneligible(mob, target, opts)
    opts = opts or {}

    if not target or target:getObjType() ~= xi.objType.PC then
        return false
    end

    if starterHnm.isEligible(target) then
        target:setLocalVar('[starterHnm]warned', 0)
        return false
    end

    if opts.showMessage ~= false then
        starterHnm.notifyIneligible(target, opts.alwaysShowMessage)
    end

    mob:resetEnmity(target)
    mob:disengage()

    if target:isEngaged() then
        target:disengage()
    end

    return true
end

function starterHnm.getLookProfile(zoneId)
    local cfg = starterHnm.zones[zoneId]

    if not cfg or not cfg.lookProfile then
        return nil
    end

    return starterHnm.lookProfiles[cfg.lookProfile]
end

function starterHnm.getCombatProfile(zoneId)
    local cfg = starterHnm.zones[zoneId]

    if not cfg or not cfg.lookProfile then
        return nil
    end

    return starterHnm.combatProfiles[cfg.lookProfile]
end

function starterHnm.messagePlayer(player, text)
    if player and player:getObjType() == xi.objType.PC then
        player:printToPlayer(text, xi.msg.channel.SYSTEM)
    end
end

function starterHnm.notifyCombatStart(mob)
    if mob:getLocalVar('[starterHnm]combatAnnounced') == 1 then
        return
    end

    mob:setLocalVar('[starterHnm]combatAnnounced', 1)

    local zone = mob:getZone()

    if not zone then
        return
    end

    for _, player in pairs(zone:getPlayers()) do
        if starterHnm.isEligible(player) then
            starterHnm.messagePlayer(
                player,
                'This notorious monster is far too dangerous to face alone. Gather allies of level 12 or below!'
            )
        else
            starterHnm.messagePlayer(
                player,
                string.format(
                    'Adventurers above level %u cannot attack this notorious monster, but you may heal and buff those who can.',
                    starterHnm.MAX_CLAIM_LEVEL
                )
            )
        end
    end
end

function starterHnm.tryAoe(mob)
    local profile = starterHnm.getCombatProfile(mob:getZoneID())

    if not profile or not profile.aoeSpells or #profile.aoeSpells == 0 then
        return
    end

    if not mob:canUseAbilities() then
        return
    end

    local nextIndex = mob:getLocalVar('[starterHnm]aoeIndex') + 1

    if nextIndex > #profile.aoeSpells then
        nextIndex = 1
    end

    mob:setLocalVar('[starterHnm]aoeIndex', nextIndex)

    local spellTarget = mob:getTarget() or mob

    mob:castSpell(profile.aoeSpells[nextIndex], spellTarget)
end

function starterHnm.spawnAdds(parentMob)
    if parentMob:getLocalVar('[starterHnm]addsSpawned') == 1 then
        return
    end

    local zoneId = parentMob:getZoneID()
    local cfg = starterHnm.zones[zoneId]
    local profile = starterHnm.getCombatProfile(zoneId)

    if not cfg or not profile then
        return
    end

    local zone = parentMob:getZone()

    if not zone then
        return
    end

    parentMob:setLocalVar('[starterHnm]addsSpawned', 1)

    local px = parentMob:getXPos()
    local py = parentMob:getYPos()
    local pz = parentMob:getZPos()
    local parentId = parentMob:getID()
    local target = parentMob:getTarget()

    for i = 1, starterHnm.ADD_COUNT do
        local offset = (i - 1.5) * 2.5
        local add = zone:insertDynamicEntity({
            objtype              = xi.objType.MOB,
            name                 = string.format('StarterHNM_Add_%u_%u', parentId, i),
            packetName           = profile.addName,
            groupId              = profile.addGroupId,
            groupZoneId          = cfg.groupZoneId,
            minLevel             = 8,
            maxLevel             = 8,
            x                    = px + offset,
            y                    = py,
            z                    = pz + offset,
            rotation             = parentMob:getRotPos(),
            releaseIdOnDisappear = true,

            onMobSpawn = function(addMob)
                addMob:setMobMod(xi.mobMod.NO_DROPS, 1)
                addMob:setMobMod(xi.mobMod.SUPERLINK, parentId)
            end,
        })

        if add then
            add:setSpawn(px + offset, py, pz + offset, parentMob:getRotPos())
            add:spawn()
            parentMob:setLocalVar(string.format('[starterHnm]add%u', i), add:getID())

            if target then
                add:updateEnmity(target)
            end
        end
    end

    if profile.phaseMessage then
        starterHnm.broadcast(zone, profile.phaseMessage)
    end
end

function starterHnm.enterPhase2(mob)
    mob:setLocalVar('[starterHnm]phase2', 1)
    mob:addMod(xi.mod.ATT, starterHnm.PHASE_ATT_BONUS)
    mob:addMod(xi.mod.REGEN, starterHnm.PHASE_REGEN_BONUS)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, starterHnm.PHASE_DAMAGE_MULT)
    mob:setMobMod(xi.mobMod.RUN_SPEED_MULT, 115)
    starterHnm.spawnAdds(mob)
end

function starterHnm.cleanupAdds(mob)
    for i = 1, starterHnm.ADD_COUNT do
        local addId = mob:getLocalVar(string.format('[starterHnm]add%u', i))

        if addId > 0 then
            local add = GetMobByID(addId)

            if add and add:isSpawned() then
                add:disengage()
                DespawnMob(addId)
            end

            mob:setLocalVar(string.format('[starterHnm]add%u', i), 0)
        end
    end
end

function starterHnm.onCombatTick(mob)
    if not mob:isEngaged() then
        return
    end

    if
        mob:getHPP() <= starterHnm.PHASE_HPP and
        mob:getLocalVar('[starterHnm]phase2') == 0
    then
        starterHnm.enterPhase2(mob)
    end

    local now = os.time()

    if now < mob:getLocalVar('[starterHnm]nextAoe') then
        return
    end

    starterHnm.tryAoe(mob)
    mob:setLocalVar('[starterHnm]nextAoe', now + starterHnm.AOE_INTERVAL_SEC)
end

function starterHnm.applyDisplayScale(mob, zoneId)
    local profile = starterHnm.getLookProfile(zoneId)

    if not profile then
        return
    end

    mob:setModelSize(profile.modelSize)
    mob:setHitboxSize(profile.hitboxSize)
end

function starterHnm.applyMobSetup(mob)
    mob:setMobMod(xi.mobMod.CHECK_AS_NM, 1)
    mob:setMobMod(xi.mobMod.HP_SCALE, starterHnm.HP_SCALE)
    mob:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, starterHnm.DAMAGE_MULTIPLIER)
    mob:setMobMod(xi.mobMod.NO_LINK, 1)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    mob:setMobMod(xi.mobMod.NO_SPELL_COST, 1)
    mob:addMod(xi.mod.REGEN, starterHnm.REGEN)
    mob:setMagicCastingEnabled(true)
    starterHnm.applyDisplayScale(mob, mob:getZoneID())
    mob:setLocalVar('[starterHnm]mob', 1)
    mob:setLocalVar('[starterHnm]aoeIndex', 0)
    mob:setLocalVar('[starterHnm]nextAoe', 0)
    mob:setLocalVar('[starterHnm]phase2', 0)
    mob:setLocalVar('[starterHnm]addsSpawned', 0)
    mob:setLocalVar('[starterHnm]combatAnnounced', 0)

    mob:addListener('ENGAGE', 'STARTER_HNM_ENGAGE', function(mobArg, target)
        if not starterHnm.rejectIneligible(mobArg, target, { alwaysShowMessage = true }) then
            starterHnm.notifyCombatStart(mobArg)
            mobArg:setLocalVar('[starterHnm]nextAoe', os.time() + 15)
        end
    end)

    mob:addListener('COMBAT_TICK', 'STARTER_HNM_COMBAT', function(mobArg)
        starterHnm.onCombatTick(mobArg)
    end)

    mob:addListener('DISENGAGE', 'STARTER_HNM_DISENGAGE', function(mobArg)
        mobArg:setLocalVar('[starterHnm]combatAnnounced', 0)
        starterHnm.cleanupAdds(mobArg)

        if mobArg:getLocalVar('[starterHnm]phase2') == 1 then
            mobArg:delMod(xi.mod.ATT, starterHnm.PHASE_ATT_BONUS)
            mobArg:delMod(xi.mod.REGEN, starterHnm.PHASE_REGEN_BONUS)
            mobArg:setMobMod(xi.mobMod.BASE_DAMAGE_MULTIPLIER, starterHnm.DAMAGE_MULTIPLIER)
            mobArg:setMobMod(xi.mobMod.RUN_SPEED_MULT, 100)
        end

        mobArg:setLocalVar('[starterHnm]phase2', 0)
        mobArg:setLocalVar('[starterHnm]addsSpawned', 0)
    end)

    mob:addListener('TAKE_DAMAGE', 'STARTER_HNM_DAMAGE', function(mobArg, amount, attacker)
        if attacker and attacker:getObjType() == xi.objType.PC then
            starterHnm.rejectIneligible(mobArg, attacker, { showMessage = false })
        end
    end)

    mob:addListener('ROAM_TICK', 'STARTER_HNM_ROAM', function(mobArg)
        local zone = mobArg:getZone()

        if not zone then
            return
        end

        for _, player in pairs(zone:getPlayers()) do
            if not starterHnm.isEligible(player) then
                mobArg:resetEnmity(player)
            end
        end
    end)

end

function starterHnm.awardLoot(player)
    if not starterHnm.isEligible(player) then
        return
    end

    local zoneTexts = zones[player:getZoneID()].text
    local gilAmount = math.random(starterHnm.GIL_MIN, starterHnm.GIL_MAX)

    player:addGil(gilAmount)
    player:messageSpecial(zoneTexts.GIL_OBTAINED, gilAmount)

    local pool = utils.shuffle(starterHnm.lootPool)
    local rolls = math.min(starterHnm.LOOT_ROLLS, #pool)
    local items = {}

    for i = 1, rolls do
        items[i] = pool[i]
    end

    local clusters = utils.shuffle(starterHnm.clusterPool)
    local clusterRolls = math.min(starterHnm.CLUSTER_ROLLS, #clusters)

    for i = 1, clusterRolls do
        items[#items + 1] = clusters[i]
    end

    -- Defer one tick: addItem during onMobDeath can show messages without persisting items.
    player:timer(100, function(p)
        if not p or not p:isPC() or not starterHnm.isEligible(p) then
            return
        end

        npcUtil.giveItem(p, items)
    end)
end

function starterHnm.onMobDeath(mob, player, optParams)
    local zoneId = mob:getZoneID()

    starterHnm.cleanupAdds(mob)
    SetServerVariable(cooldownVar(zoneId), os.time() + starterHnm.POST_KILL_COOLDOWN)
    SetServerVariable(thresholdVar(zoneId), 0)

    if player and (not optParams or optParams.isKiller) then
        starterHnm.awardLoot(player)
    end
end

function starterHnm.scheduleDespawn(mob)
    mob:timer(starterHnm.DESPAWN_SECONDS * 1000, function(mobArg)
        if mobArg and mobArg:isAlive() then
            mobArg:disengage()
            DespawnMob(mobArg:getID())
        end
    end)
end

function starterHnm.broadcast(zone, message)
    for _, player in pairs(zone:getPlayers()) do
        player:printToArea(message, xi.msg.area.SYSTEM)
    end
end

function starterHnm.despawnActive(zoneId)
    local cfg = starterHnm.zones[zoneId]

    if not cfg then
        return false
    end

    local zone = GetZone(zoneId)

    if not zone then
        return false
    end

    local despawned = false
    local entities = zone:queryEntitiesByName('DE_' .. cfg.internalName)

    for _, mob in pairs(entities) do
        if mob:isSpawned() then
            mob:disengage()
            DespawnMob(mob:getID())
            despawned = true
        end
    end

    return despawned
end

function starterHnm.spawnMob(zoneId, opts)
    opts = opts or {}
    local cfg = starterHnm.zones[zoneId]

    if not cfg then
        return false, 'invalid zone'
    end

    if starterHnm.isActive(zoneId) then
        if opts.replaceActive then
            starterHnm.despawnActive(zoneId)
        else
            return false, 'already active'
        end
    end

    if starterHnm.isOnCooldown(zoneId) and not opts.ignoreCooldown then
        return false, 'on cooldown'
    end

    local zone = GetZone(zoneId)

    if not zone then
        return false, 'zone unavailable'
    end

    local spawnX = cfg.x
    local spawnY = cfg.y
    local spawnZ = cfg.z
    local spawnRot = cfg.rot

    if opts.atPlayer then
        spawnX = opts.atPlayer:getXPos()
        spawnY = opts.atPlayer:getYPos()
        spawnZ = opts.atPlayer:getZPos()
        spawnRot = opts.atPlayer:getRotPos()
    end

    local lookProfile = starterHnm.getLookProfile(zoneId)

    local mob = zone:insertDynamicEntity({
        objtype               = xi.objType.MOB,
        name                  = cfg.internalName,
        packetName            = cfg.packetName,
        look                  = lookProfile and lookProfile.look or nil,
        groupId               = cfg.groupId,
        groupZoneId           = cfg.groupZoneId,
        minLevel              = 10,
        maxLevel              = 10,
        x                     = spawnX,
        y                     = spawnY,
        z                     = spawnZ,
        rotation              = spawnRot,
        releaseIdOnDisappear  = true,
        specialSpawnAnimation = true,
        isAggroable           = true,
        modelSize             = lookProfile and lookProfile.modelSize or nil,
        modelHitboxSize       = lookProfile and lookProfile.hitboxSize or nil,

        onMobSpawn = function(mobArg)
            starterHnm.applyMobSetup(mobArg)
        end,

        onMobEngage = function(mobArg, target)
            starterHnm.rejectIneligible(mobArg, target, { alwaysShowMessage = true })
        end,

        onMobFight = function(mobArg, target)
            starterHnm.rejectIneligible(mobArg, target, { showMessage = false })
        end,

        onMobDeath = function(mobArg, player, optParams)
            starterHnm.onMobDeath(mobArg, player, optParams)
        end,
    })

    if not mob then
        return false, 'insertDynamicEntity failed'
    end

    if opts.ignoreCooldown then
        SetServerVariable(cooldownVar(zoneId), 0)
    end

    mob:setSpawn(spawnX, spawnY, spawnZ, spawnRot)
    mob:spawn()
    starterHnm.scheduleDespawn(mob)

    if not opts.silent then
        local areaHint = cfg.areaHint or 'this zone'

        starterHnm.broadcast(zone, string.format(
            '%s has emerged near %s! Only adventurers of level %u or below may claim it — seek allies!',
            cfg.packetName,
            areaHint,
            starterHnm.MAX_CLAIM_LEVEL
        ))
    end

    return true, cfg.packetName
end

function starterHnm.trySpawn(zoneId)
    starterHnm.spawnMob(zoneId)
end

function starterHnm.gmSpawn(zoneId, opts)
    opts = opts or {}
    opts.ignoreCooldown = true
    opts.replaceActive = true
    return starterHnm.spawnMob(zoneId, opts)
end

function starterHnm.getZoneStatus(zoneId)
    local cfg = starterHnm.zones[zoneId]

    if not cfg then
        return nil
    end

    local cooldownUntil = GetServerVariable(cooldownVar(zoneId))
    local now = os.time()

    return {
        zoneId      = zoneId,
        name        = cfg.packetName,
        xp          = GetServerVariable(xpVar(zoneId)),
        threshold   = starterHnm.getThreshold(zoneId),
        active      = starterHnm.isActive(zoneId),
        onCooldown  = cooldownUntil > now,
        cooldownSec = math.max(0, cooldownUntil - now),
    }
end

function starterHnm.addZoneExp(zoneId, exp)
    local cfg = starterHnm.zones[zoneId]

    if not cfg or exp <= 0 then
        return
    end

    if starterHnm.isOnCooldown(zoneId) or starterHnm.isActive(zoneId) then
        return
    end

    local total = GetServerVariable(xpVar(zoneId)) + exp
    local threshold = starterHnm.getThreshold(zoneId)

    if total >= threshold then
        SetServerVariable(xpVar(zoneId), 0)
        starterHnm.trySpawn(zoneId)
    else
        SetServerVariable(xpVar(zoneId), total)
    end
end

function starterHnm.syncXpListener(player)
    if not player or player:getObjType() ~= xi.objType.PC then
        return
    end

    player:removeListener(starterHnm.XP_LISTENER_ID)
    player:removeListener(starterHnm.ENGAGE_GUARD_LISTENER_ID)

    local zoneId = player:getZoneID()

    if not starterHnm.zones[zoneId] then
        return
    end

    player:addListener('EXPERIENCE_POINTS', starterHnm.XP_LISTENER_ID, function(playerObj, mobObj, expGained)
        if expGained <= 0 then
            return
        end

        starterHnm.addZoneExp(playerObj:getZoneID(), expGained)
    end)

    player:addListener('ENGAGE', starterHnm.ENGAGE_GUARD_LISTENER_ID, function(playerObj, target)
        starterHnm.rejectPlayerEngage(playerObj, target)
    end)
end

function starterHnm.onZoneInit(zone)
    for _, player in pairs(zone:getPlayers()) do
        starterHnm.syncXpListener(player)
    end
end

function starterHnm.onPlayerZoneIn(player)
    starterHnm.syncXpListener(player)
end
