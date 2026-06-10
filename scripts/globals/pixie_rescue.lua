-----------------------------------
-- Pixie Rescue (core script)
-- On death: spirit spawns on corpse, pre-raise sneak/invis + aggro wipes, pixie casts Raise,
-- on accept: stronger safety (incl. short invincible), Curaga/Cure VI animations on party,
-- HP/MP to current max (weakness from death penalty stays), then despawn.
-----------------------------------
xi = xi or {}
xi.pixieRescue = xi.pixieRescue or {}

local COOLDOWN_CHAR_VAR = 'PIXIE_RESCUE_NEXT'
local PENDING_LOCAL_VAR = 'PIXIE_RESCUE_PENDING'
local TICKET_LOCAL_VAR = 'PIXIE_RESCUE_TICKET'
local POST_REVIVE_HANDLED_VAR = 'PIXIE_RESCUE_POST_DONE'
local PRE_RAISE_GUARD_VAR = 'PIXIE_PRE_RAISE_G'
--- Stored targid so Lua can resolve the spirit after C++ Raise() (same tick as aggro checks).
local MOB_TARG_LOCAL_VAR = 'PIXIE_R_MTARG'

local COOLDOWN_SECONDS = 45 * 60
local PRE_RAISE_VEIL_SECONDS = 55
--- Brief pause after spawn so the client can finish spawn state before MagicStart (0x028).
local RAISE_CAST_START_DELAY_MS = 1000
--- After accepting Raise, HP can sit below 75% for up to one poll tick; mobs with DETECT_LOWHP aggro instantly.
local REVIVE_WATCH_FAST_MS = 50
local REVIVE_WATCH_FAST_COUNT = 40 -- 2s of 50ms polling right after stand-up
local PIXIE_GROUP_ID = 35
local PIXIE_GROUP_ZONE_ID = 100
local MAX_PACKET_NAME_LEN = 20

local function rescueChat(player, message)
    player:printToPlayer(message, 0x1F)
end

--- addStatusEffect(effectId, { power, tick, duration, origin }) — numeric legacy arity crashes the binding.
local function addPlayerBuff(player, effectId, power, tickSeconds, durationSeconds)
    player:addStatusEffect(effectId, {
        power    = power,
        tick     = tickSeconds,
        duration = durationSeconds,
        origin   = player,
    })
end

local function clearNearbyAggro(player, rescueMob, radius)
    local entities = player:getEntitiesInRange(
        player,
        xi.aoeType.ROUND,
        xi.aoeRadius.ATTACKER,
        radius or 42,
        xi.findFlag.HIT_ALL,
        xi.targetType.MOB
    ) or {}

    for _, ent in ipairs(entities) do
        if ent and ent:getObjType() == xi.objType.MOB then
            -- Never disengage/stomp the rescue spirit: it is in this list (on the corpse) and disengage cancels casts / leaves it roaming idle.
            local skipEnt = false
            if rescueMob and rescueMob:isAlive() then
                skipEnt = ent:getID() == rescueMob:getID()
            end

            if not skipEnt then
                pcall(function() ent:clearEnmityForEntity(player) end)
                pcall(function() ent:resetEnmity(player) end)
                if rescueMob and rescueMob:isAlive() then
                    pcall(function() ent:clearEnmityForEntity(rescueMob) end)
                    pcall(function() ent:resetEnmity(rescueMob) end)
                end

                pcall(function() ent:disengage() end)
            end
        end
    end
end

--- Cure/Raise can add the pixie to mob hate via GenerateCureEnmity; scrub on a short timeline after cast.
local function schedulePostSpellThreatWipe(player, rescueMob, radius)
    if not player or not rescueMob then
        return
    end

    local r = radius or 58
    for _, ms in ipairs({ 250, 700, 1400, 2600, 4200, 7000, 10000 }) do
        player:timer(ms, function(p)
            if rescueMob and rescueMob:isAlive() then
                clearNearbyAggro(p, rescueMob, r)
            end
        end)
    end
end

local function castSpellWithThreatWipe(player, rescueMob, spellId, target)
    clearNearbyAggro(player, rescueMob, 58)
    pcall(function()
        rescueMob:castSpell(spellId, target)
    end)
    schedulePostSpellThreatWipe(player, rescueMob, 58)
end

-- DETECT_LOWHP ("blood aggro"): mobs with this flag aggro players under 75% HP; Sneak/Invis/Deodorize do not block it
-- (HP clamp below still required). Deodorize helps DETECT_SCENT pursuit / deaggro behavior on the engine side.
local function ensureAboveBloodAggroThreshold(pc)
    if not pc or not pc:isPC() or not pc:isAlive() then
        return
    end

    if pc:getHPP() < 75 then
        local minHp = math.ceil(pc:getMaxHP() * 0.75)
        if pc:getHP() < minHp then
            pc:setHP(minHp)
        end
    end
end

local function applyBloodAggroProtectionToNearbyParty(revivee)
    if not revivee then
        return
    end

    ensureAboveBloodAggroThreshold(revivee)

    local party = revivee:getParty() or {}
    for _, member in ipairs(party) do
        if
            member and
            member:isPC() and
            member:isAlive() and
            member:getZoneID() == revivee:getZoneID() and
            member:checkDistance(revivee) <= 40.0
        then
            ensureAboveBloodAggroThreshold(member)
        end
    end
end

--- Full HP/MP for current caps (e.g. after weakness); do not strip weakness — that is the death penalty.
local function fillToCurrentMaxResources(pc)
    if not pc or not pc:isPC() or not pc:isAlive() then
        return
    end

    pc:setHP(pc:getMaxHP())
    pc:setMP(pc:getMaxMP())
end

local function applyPostRaiseSafety(player, rescueTicket, rescueMob)
    local safetyDuration = 75
    local hardGuardDuration = 25

    player:setUnkillable(true)
    player:setLocalVar(TICKET_LOCAL_VAR, rescueTicket)
    applyBloodAggroProtectionToNearbyParty(player)

    player:delStatusEffectSilent(xi.effect.SNEAK)
    player:delStatusEffectSilent(xi.effect.INVISIBLE)
    player:delStatusEffectSilent(xi.effect.DEODORIZE)
    addPlayerBuff(player, xi.effect.SNEAK, 0, 10, safetyDuration)
    addPlayerBuff(player, xi.effect.INVISIBLE, 0, 10, safetyDuration)
    addPlayerBuff(player, xi.effect.DEODORIZE, 0, 10, safetyDuration)
    addPlayerBuff(player, xi.effect.REGEN, 12, 3, 45)
    addPlayerBuff(player, xi.effect.INVINCIBLE, 1, 0, 15)

    clearNearbyAggro(player, rescueMob, 45)

    for i = 1, hardGuardDuration * 2 do
        player:timer(i * 500, function(p)
            if p:getLocalVar(TICKET_LOCAL_VAR) ~= rescueTicket then
                return
            end

            ensureAboveBloodAggroThreshold(p)
            applyBloodAggroProtectionToNearbyParty(p)
            clearNearbyAggro(p, rescueMob, 45)
        end)
    end

    player:timer(hardGuardDuration * 1000, function(p)
        if p:getLocalVar(TICKET_LOCAL_VAR) == rescueTicket then
            p:setUnkillable(false)
            p:setLocalVar(TICKET_LOCAL_VAR, 0)
            p:setLocalVar(MOB_TARG_LOCAL_VAR, 0)
        end
    end)
end

--- Sneak/Invis + aggro wipe on the corpse *before* Raise lands so pops do not snap to the revive.
local function applyPreRaiseVeil(player, rescueMob, rescueTicket)
    player:setUnkillable(true)
    player:setLocalVar(PRE_RAISE_GUARD_VAR, rescueTicket)
    player:delStatusEffectSilent(xi.effect.SNEAK)
    player:delStatusEffectSilent(xi.effect.INVISIBLE)
    player:delStatusEffectSilent(xi.effect.DEODORIZE)
    addPlayerBuff(player, xi.effect.SNEAK, 0, 10, PRE_RAISE_VEIL_SECONDS)
    addPlayerBuff(player, xi.effect.INVISIBLE, 0, 10, PRE_RAISE_VEIL_SECONDS)
    addPlayerBuff(player, xi.effect.DEODORIZE, 0, 10, PRE_RAISE_VEIL_SECONDS)
    addPlayerBuff(player, xi.effect.REGEN, 8, 3, 30)

    clearNearbyAggro(player, rescueMob, 52)

    for i = 1, 16 do
        player:timer(i * 3500, function(p)
            if p:getLocalVar(PRE_RAISE_GUARD_VAR) ~= rescueTicket or p:isAlive() then
                return
            end

            clearNearbyAggro(p, rescueMob, 52)
        end)
    end

    player:timer(30000, function(p)
        if p:getLocalVar(PRE_RAISE_GUARD_VAR) == rescueTicket and p:isDead() then
            p:setUnkillable(false)
            p:setLocalVar(PRE_RAISE_GUARD_VAR, 0)
        end
    end)
end

--- Party PCs in the same zone (any distance). Used for guaranteed top-off after spell visuals.
local function buildPartyMembersSameZone(owner)
    local party = owner:getParty() or {}
    local members = {}

    for _, member in ipairs(party) do
        if member and member:isPC() and member:getZoneID() == owner:getZoneID() then
            members[#members + 1] = member
        end
    end

    return members
end

--- Party PCs close enough for Curaga / single-target Cure visuals (spirit stays on corpse).
local function buildPartyInHealSpellRange(owner)
    local party = owner:getParty() or {}
    local eligible = {}
    local maxDist = 45.0

    for _, member in ipairs(party) do
        if
            member and
            member:isPC() and
            member:getZoneID() == owner:getZoneID() and
            member:checkDistance(owner) <= maxDist
        then
            eligible[#eligible + 1] = member
        end
    end

    return eligible
end

--- Curaga + Cure VI chain for real cast animations, then silent HP/MP to current max (weakness retained).
local function healPartyWithPixieCasts(owner, mob, finishCb)
    -- Spell animations only hit sensible range; everyone in the same zone still gets the final restore.
    local inSpellRange = buildPartyInHealSpellRange(owner)
    local sameZoneParty = buildPartyMembersSameZone(owner)

    local function topOffAndNotify()
        for _, member in ipairs(sameZoneParty) do
            if member and member:isPC() and member:isAlive() then
                fillToCurrentMaxResources(member)
                rescueChat(member, '[Pixie] Gentle light restores your strength.')
            end
        end

        finishCb()
    end

    if not mob then
        topOffAndNotify()
        return
    end

    -- Keep spirit aligned with revivee for party heals (same battle-ID gate as Raise).
    mob:setBattleID(owner:getBattleID())

    castSpellWithThreatWipe(owner, mob, xi.magic.spell.CURAGA_V, owner)

    owner:timer(6500, function()
        local needHeal = {}

        for _, member in ipairs(inSpellRange) do
            if member and member:isPC() and member:isAlive() and member:getHP() < member:getMaxHP() then
                needHeal[#needHeal + 1] = member
            end
        end

        local idx = 0
        local function nextCure()
            idx = idx + 1
            if idx > #needHeal then
                owner:timer(2000, topOffAndNotify)
                return
            end

            local target = needHeal[idx]
            if mob and mob:isAlive() and target and target:isAlive() then
                castSpellWithThreatWipe(owner, mob, xi.magic.spell.CURE_VI, target)
            end

            owner:timer(5200, nextCure)
        end

        if #needHeal == 0 then
            owner:timer(1200, topOffAndNotify)
        else
            nextCure()
        end
    end)
end

local function despawnRescueMob(mob)
    if mob and mob.setStatus then
        mob:setStatus(xi.status.DISAPPEAR)
    end
end

local function resolveRescueMobFromPlayer(player, mobArg)
    if mobArg and mobArg:isAlive() then
        return mobArg
    end

    local t = player:getLocalVar(MOB_TARG_LOCAL_VAR)
    if not t or t == 0 then
        return nil
    end

    local e = player:getEntity(t)
    if e and e:isAlive() and e:getObjType() == xi.objType.MOB then
        return e
    end

    return nil
end

--- Scripted Raise only (no mob AI); clear spawn-in flag so MagicStart shows the cast pose.
local function tryCastPixieRaise(player, mobArg, isFirstAttempt)
    if not player or not player:isDead() then
        return
    end

    local spirit = resolveRescueMobFromPlayer(player, mobArg)
    if not spirit or not spirit:isAlive() then
        return
    end

    if isFirstAttempt then
        pcall(function()
            spirit:setSpawnAnimation(0)
        end)
    end

    castSpellWithThreatWipe(player, spirit, xi.magic.spell.RAISE, player)
end

--- Completes revive handling (HP/veil/heals). Called from timers and from C++ on the Raise accept tick.
local function tryCompletePixieReviveStand(player, rescueTicket, mobArg)
    if not player or not player:isPC() then
        return
    end

    if player:getLocalVar(POST_REVIVE_HANDLED_VAR) == 1 then
        return
    end

    if player:getLocalVar(TICKET_LOCAL_VAR) ~= rescueTicket then
        return
    end

    if not player:isAlive() then
        return
    end

    local mob = resolveRescueMobFromPlayer(player, mobArg)

    player:setLocalVar(POST_REVIVE_HANDLED_VAR, 1)
    player:setLocalVar(PRE_RAISE_GUARD_VAR, 0)
    -- Before veil: same server tick as Raise accept can run mob aggro (SpawnMOBs / DETECT_*).
    ensureAboveBloodAggroThreshold(player)
    applyBloodAggroProtectionToNearbyParty(player)
    clearNearbyAggro(player, mob, 72)
    applyPostRaiseSafety(player, rescueTicket, mob)
    fillToCurrentMaxResources(player)
    ensureAboveBloodAggroThreshold(player)
    clearNearbyAggro(player, mob, 72)
    rescueChat(player, '[Pixie] Your spirit returns to you. Live.')
    healPartyWithPixieCasts(player, mob, function()
        despawnRescueMob(mob)
    end)
end

--- Instance, then zone pointer, then global zone by ID (getZone() can be nil while zone id is valid).
local function resolveZoneForDynamicSpawn(player)
    local inst = player:getInstance()
    if inst then
        return inst
    end

    local z = player:getZone()
    if z then
        return z
    end

    local zoneId = player:getZoneID()
    if zoneId and zoneId > 0 then
        return GetZone(zoneId)
    end

    return nil
end

local function buildSpiritPacketName(playerName)
    local suffix = ' Spirit'
    local safeName = tostring(playerName or 'Fallen')
    local maxBase = MAX_PACKET_NAME_LEN - #suffix

    if maxBase < 3 then
        return 'Spirit'
    end

    if #safeName > maxBase then
        safeName = string.sub(safeName, 1, maxBase)
    end

    return safeName .. suffix
end

---@return boolean success
local function startPixieRescue(player, rescueTicket)
    local zoneOrInst = resolveZoneForDynamicSpawn(player)
    if not zoneOrInst then
        printf('[pixie_rescue] no zone/instance for dynamic spawn (char=%s zoneId=%s)', player:getName(), tostring(player:getZoneID()))
        rescueChat(player, '[Pixie] (Rescue could not anchor to this area; contact a GM.)')
        return false
    end

    local sx = player:getXPos()
    local sy = player:getYPos()
    local sz = player:getZPos()
    local srot = player:getRotPos()
    local spiritName = buildSpiritPacketName(player:getName())
    local mob = zoneOrInst:insertDynamicEntity({
        objtype = xi.objType.MOB,
        name = 'Rescue_Pixie',
        packetName = spiritName,
        x = sx,
        y = sy,
        z = sz,
        rotation = srot,
        groupId = PIXIE_GROUP_ID,
        groupZoneId = PIXIE_GROUP_ZONE_ID,
        minLevel = 99,
        maxLevel = 99,
        spellList = 356,
        -- Player-allegiance mobs only enter mob-vs-mob aggro scans when true; keep false so casting never pulls via that path.
        isAggroable = false,
        releaseIdOnDisappear = true,
        specialSpawnAnimation = true,
        onMobSpawn = function(mobArg)
            mobArg:setAllegiance(xi.allegiance.PLAYER)
            mobArg:setMobMod(xi.mobMod.SKIP_ALLEGIANCE_CHECK, 1)
            mobArg:setMobMod(xi.mobMod.NO_AGGRO, 1)
            mobArg:setAutoAttackEnabled(false)
            mobArg:setMobAbilityEnabled(false)
            -- Raise is scripted via castSpell; keep AI off until spawn-in finishes.
            mobArg:setMagicCastingEnabled(false)
            mobArg:setMobMod(xi.mobMod.MAGIC_COOL, 999)
            mobArg:setUnkillable(true)
            mobArg:setUntargetable(true)
            pcall(function()
                mobArg:setIsAggroable(false)
            end)
            pcall(function()
                mobArg:setRoamFlags(xi.roamFlag.SCRIPTED)
            end)
        end,
        -- Pixie pool data can include default roam; SCRIPTED + empty roam keeps the spirit on the corpse until despawn.
        onMobRoam = function() end,
    })

    if not mob then
        printf('[pixie_rescue] insertDynamicEntity failed (char=%s zoneId=%s)', player:getName(), tostring(player:getZoneID()))
        rescueChat(player, '[Pixie] (Spirit could not take form; try again or contact a GM.)')
        return false
    end

    mob:setDropID(0)
    mob:setMobMod(xi.mobMod.NO_DROPS, 1)
    -- CMobEntity::Spawn() copies loc.p from m_SpawnPoint; dynamic SQL mobs leave m_SpawnPoint at 0,0,0.
    mob:setSpawn(sx, sy, sz, srot)
    mob:setMobMod(xi.mobMod.SKIP_ALLEGIANCE_CHECK, 1)
    pcall(function()
        mob:setIsAggroable(false)
    end)
    pcall(function()
        mob:setRoamFlags(xi.roamFlag.SCRIPTED)
    end)
    mob:spawn()
    -- Spawn() resets battle ID to 0; Raise (validTargets=PLAYER_DEAD only) rejects targets with a different battle ID.
    mob:setBattleID(player:getBattleID())
    rescueChat(player, string.format('[Pixie] %s rises from your fallen spirit, offering one more chance to live.', spiritName))
    applyPreRaiseVeil(player, mob, rescueTicket)
    clearNearbyAggro(player, mob, 48)
    mob:setUntargetable(false)
    player:setLocalVar(MOB_TARG_LOCAL_VAR, mob:getTargID())
    for i = 0, 8 do
        player:timer(RAISE_CAST_START_DELAY_MS + i * 1200, function(p2)
            tryCastPixieRaise(p2, mob, i == 0)
        end)
    end

    for i = 1, REVIVE_WATCH_FAST_COUNT do
        player:timer(i * REVIVE_WATCH_FAST_MS, function(p2)
            tryCompletePixieReviveStand(p2, rescueTicket, mob)
        end)
    end

    -- Continue ~90s window; start at fastEnd so the last fast tick (2s) overlaps slow i=0 (no 500ms blind spot).
    local fastEndMs = REVIVE_WATCH_FAST_COUNT * REVIVE_WATCH_FAST_MS
    for i = 0, 176 do
        player:timer(fastEndMs + i * 500, function(p2)
            tryCompletePixieReviveStand(p2, rescueTicket, mob)
        end)
    end

    return true
end

---@param player CBaseEntity
---@param options table|nil ignoreCooldown?: boolean ignoreReraise?: boolean
---@return boolean ok
---@return string reason
function xi.pixieRescue.dispatchToPlayer(player, options)
    options = options or {}

    if not player or not player:isPC() or not player:isDead() then
        return false, 'not_dead'
    end

    -- Spell/item Reraise buff
    if not options.ignoreReraise and player:hasStatusEffect(xi.effect.RERAISE) then
        return false, 'reraise'
    end

    -- Gear / auto-raise menu (Reraise I–III mods) does not always mirror the status effect.
    if not options.ignoreReraise and player:hasRaiseTractorMenu() then
        return false, 'reraise'
    end

    local now = os.time()
    if (not options.ignoreCooldown) and now < player:getCharVar(COOLDOWN_CHAR_VAR) then
        local rem = math.max(1, player:getCharVar(COOLDOWN_CHAR_VAR) - now)
        rescueChat(player, string.format('[Pixie] Your guardian spirit is resting... %dm %02ds.', math.floor(rem / 60), rem % 60))
        return false, 'cooldown'
    end

    if player:getLocalVar(PENDING_LOCAL_VAR) == 1 then
        return false, 'pending'
    end

    local rescueTicket = now + math.random(1000, 999999)
    player:setLocalVar(PENDING_LOCAL_VAR, 0)
    player:setLocalVar(TICKET_LOCAL_VAR, rescueTicket)
    player:setLocalVar(POST_REVIVE_HANDLED_VAR, 0)
    rescueChat(player, '[Pixie] Your spirit stirs...')
    local spawned = startPixieRescue(player, rescueTicket)
    if not spawned then
        player:setLocalVar(TICKET_LOCAL_VAR, 0)
        player:setLocalVar(MOB_TARG_LOCAL_VAR, 0)
        return false, 'spawn_failed'
    end

    player:setCharVar(COOLDOWN_CHAR_VAR, now + COOLDOWN_SECONDS)
    return true, 'dispatched'
end

--- Called from xi.player.onPlayerDeath
---@param player CBaseEntity
function xi.pixieRescue.onPlayerDeath(player)
    if not player or not player:isPC() then
        return
    end

    -- Defer one tick so death state / zone pointers match what cast+spawn expect.
    player:timer(100, function(p)
        if not p or not p:isPC() then
            return
        end

        if p:hasStatusEffect(xi.effect.RERAISE) then
            return
        end

        xi.pixieRescue.dispatchToPlayer(p, { ignoreCooldown = false, ignoreReraise = false })
    end)
end

--- Same server tick as C++ Raise accept (before roam/aggro); see luautils::OnPlayerRaiseAccept.
---@param player CBaseEntity
function xi.pixieRescue.onPlayerRaiseAccept(player)
    if not player or not player:isPC() or not player:isAlive() then
        return
    end

    if player:getLocalVar(TICKET_LOCAL_VAR) == 0 or player:getLocalVar(POST_REVIVE_HANDLED_VAR) == 1 then
        return
    end

    local ticket = player:getLocalVar(TICKET_LOCAL_VAR)
    tryCompletePixieReviveStand(player, ticket, nil)
end
