-----------------------------------
-- Every trust spell is learned at level 1 (login / create).
-- Trust AI still uses retail level gates (Provoke at 5-10, Sentinel at
-- 30, Chivalry at 50, Palisade at 95). This server's kit is finished at
-- 37, so those gates are compressed onto 1-37 with the same curve as
-- ixi20_job_progression_37cap:
--   1 + round((retail - 1) * 36 / 98)
-- A gate the stock script already opened is left alone. Spell tiers are
-- the paired SQL. Level 2+ player weaponskills open at 23 via
-- ixi20_trust_ws.cpp, called when the trust spawns.
-- A melee trust that stops moving outside melee range is placed
-- beside the target, so a failed path does not leave them in the back.
-- Every trust engages while the player is fighting, so casters still
-- get a combat tick when the player is only casting.
-- Lion's Grapeshot lines were weaponskill reactions, which the gambit
-- runner never executes, so she never stunned and could sit out the fight.
-- Those lines are mob skills now. Arciela is a red mage with an empty
-- spawn script, so she now casts protect, shell, haste, refresh, slow,
-- and paralyze. Arciela II nukes as well.
-- Darrcuiln is Blue Mage / Red Mage. He melees, weaponskills with
-- Aurous Charge, Howling Gust, Righteous Rasp, Starward Yowl, and
-- Stalking Prey, and casts every blue spell at the player levels in
-- ixi20_darrcuiln_spells.sql. An open skillchain is burst with the
-- matching element, and that burst is taken before a heal. Otherwise
-- he casts his best damaging spell of the target's weakest element.
-- Diffusion, Chain Affinity, and Burst Affinity stay on him. His TP
-- moves still chain on their own.
-- Refueling is its own haste buff.
-- Joachim is Bard / White Mage. He learns every BRD and WHM spell at
-- the same compressed levels as a player (ixi20_joachim_spells.sql).
-- Cleanses and heals come first. Then March and Minuet on the party.
-- Pianissimo and Ballad go on mages, White Mage, Scholar, and Red Mage
-- first. Madrigal, Minne, Requiem, and Elegy follow. He nukes and
-- weaponskills when nobody nearby needs a heal or a cleanse.
-- Trusts with an empty weaponskill list get a job kit from
-- ixi20_trust_ws.cpp. Casters, healers, and rangers whose scripts
-- never added gambits are given their role below.
-- Kayeel-Payeel and Robel-Akbel stay black mage / summoner. They keep
-- their nukes. ixi20_trust_avatar.cpp keeps one avatar out with each
-- of them. Both walk the same celestial avatars. An avatar stays for
-- one to three fights, then the next one is summoned. A ward is
-- skipped when anyone the pact would hit already has that buff, or a
-- stronger haste or protection the pact would overwrite. Those wards
-- last as long as a player's party buffs.
-- Closer trusts (Tenzen and others) hold TP until a skillchain window
-- opens, then pick the weaponskill that closes it. That hold is removed:
-- they weaponskill at 1000, and still close a chain if one is already up.
-- The retail key-item cap (3 trusts, 4 with Rhapsody in White) is not
-- applied. A party still holds 6. Selecting another trust while the
-- party is full dismisses the earliest one you summoned.
-- A trust already out levels up with the player. ixi20_trust_level.cpp
-- rebuilds HP, stats, skills, traits, weapon damage, and spells.
-- Trusts stay summoned across a zone change. ixi20_trust_persist.cpp
-- calls them again on the far side, and trust spells can be cast in
-- any zone, including a mog house.
-- Do not return this module.
-- Comment this file out in init.txt to turn trusts back off. Settings
-- leave casting disabled, and this module turns it on. Trusts do not
-- reduce experience.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/player')
require('scripts/globals/trust')
-----------------------------------

local m = Module:new('ixi20_trusts')

if xi.settings and xi.settings.main then
    xi.settings.main.ENABLE_TRUST_CASTING = 1
end

-- Retail closer / high random thresholds sit on TP and weaponskill mainly
-- to close the player's skillchain. Spend TP at 1000 instead. Skill
-- selection is unchanged, so an open window is still closed when they fire.
if type(CBaseEntity) == 'table' and type(CBaseEntity.setTrustTPSkillSettings) == 'function' and not CBaseEntity._ixi20TrustTp then
    CBaseEntity._ixi20TrustTp = true
    local prevTpSettings = CBaseEntity.setTrustTPSkillSettings
    CBaseEntity.setTrustTPSkillSettings = function(mob, trigger, select, value)
        if trigger == ai.tp.CLOSER or trigger == ai.tp.CLOSER_UNTIL_TP or trigger == ai.tp.RANDOM then
            trigger = ai.tp.ASAP
            value = 1000
        end

        return prevTpSettings(mob, trigger, select, value)
    end
end

local TRUST_SPELLS =
{
    896, 897, 898, 899, 900, 901, 902, 903, 904, 905, 906, 907, 908, 909, 910, 911, 912, 913, 914, 915, 916, 917, 918, 919, 920,
    921, 922, 923, 924, 925, 926, 927, 928, 929, 930, 931, 932, 933, 934, 935, 936, 937, 938, 939, 940, 941, 942, 943, 944, 945,
    946, 947, 948, 949, 950, 951, 952, 953, 954, 955, 956, 957, 958, 959, 960, 961, 962, 963, 964, 965, 966, 967, 968, 969, 970,
    971, 972, 973, 974, 975, 976, 977, 978, 979, 980, 981, 982, 983, 984, 985, 986, 987, 988, 989, 990, 991, 992, 993, 994, 995,
    996, 997, 998, 999,
    1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019,
}

-- Retail 99 -> server 37. Matches ixi20_trust_spell_levels.sql.
local function compress(retailLevel)
    if retailLevel <= 1 then
        return 1
    end

    local scaled = 1 + math.floor(((retailLevel - 1) * 36 / 98) + 0.5)
    if scaled < 1 then
        return 1
    end

    if scaled > 37 then
        return 37
    end

    return scaled
end

-- True when the stock script skipped this gate, but the compressed curve has opened it.
local function early(mob, retailGate)
    local lvl = mob:getMainLvl()
    return lvl < retailGate and lvl >= compress(retailGate)
end

local function ja(mob, target, conditions, ability)
    mob:addGambit(target, conditions, { ai.r.JA, ai.s.SPECIFIC, ability })
end

local function unlockWeaponskills(trust)
    if Ixi20TrustUnlockLv3Ws and trust then
        Ixi20TrustUnlockLv3Ws(trust)
    end
end

-- Front line. Casters are left where they stand to cast.
local meleeJobs =
{
    [xi.job.WAR] = true,
    [xi.job.MNK] = true,
    [xi.job.THF] = true,
    [xi.job.PLD] = true,
    [xi.job.DRK] = true,
    [xi.job.BST] = true,
    [xi.job.SAM] = true,
    [xi.job.NIN] = true,
    [xi.job.DRG] = true,
    [xi.job.BLU] = true,
    [xi.job.RUN] = true,
}

-- Bubble trusts. Engaging them sends them into the fight.
local passiveTrusts =
{
    [xi.magic.spell.SAKURA]          = true,
    [xi.magic.spell.MOOGLE]          = true,
    [xi.magic.spell.STAR_SIBYL]      = true,
    [xi.magic.spell.KUYIN_HATHDENNA] = true,
    [xi.magic.spell.BRYGID]          = true,
    [xi.magic.spell.KUPOFRIED]       = true,
    [xi.magic.spell.CORNELIA]        = true,
}

-- Engage while the player is fighting. Spell and weaponskill gambits
-- only run from the combat tick, which requires the trust to be engaged.
-- A melee trust that is not walking and is still outside melee range
-- gets placed beside the target. A caster stuck out of cast range is
-- placed just outside melee. Covers a failed navmesh path.
local function nudgeMeleeTrust(trust)
    if not trust or not trust:isAlive() or passiveTrusts[trust:getTrustID()] then
        return
    end

    local master = trust:getMaster()
    if not master then
        return
    end

    local target = master:getTarget()
    if master:isEngaged() and target and target:isAlive() and not trust:isEngaged() then
        trust:engage(target:getTargID())
    end

    if trust:getMobMod(xi.mobMod.TRUST_DISTANCE) == xi.trust.movementType.NON_COMBAT then
        return
    end

    local melee = meleeJobs[trust:getMainJob()] and trust:getMobMod(xi.mobMod.TRUST_DISTANCE) == 0
    if not melee and trust:getMobMod(xi.mobMod.TRUST_DISTANCE) ~= xi.trust.movementType.NO_MOVE then
        return
    end

    if not trust:isEngaged() then
        return
    end

    target = trust:getTarget() or target
    if not target or not target:isAlive() then
        trust:setLocalVar('ixi20CloseStuck', 0)
        return
    end

    local dist    = trust:checkDistance(target)
    local closeAt = melee and 6 or 18
    local placeAt = melee and 2 or 8
    local x       = math.floor(trust:getXPos() * 10) + 100000
    local z       = math.floor(trust:getZPos() * 10) + 100000
    if dist > closeAt and x == trust:getLocalVar('ixi20CloseX') and z == trust:getLocalVar('ixi20CloseZ') then
        local stuck = trust:getLocalVar('ixi20CloseStuck') + 1
        trust:setLocalVar('ixi20CloseStuck', stuck)
        if stuck >= 3 then
            local angle = math.random() * math.pi * 2
            trust:clearPath()
            trust:setPos(
                target:getXPos() + math.cos(angle) * placeAt,
                target:getYPos(),
                target:getZPos() + math.sin(angle) * placeAt
            )
            trust:setLocalVar('ixi20CloseStuck', 0)
        end
    else
        trust:setLocalVar('ixi20CloseStuck', 0)
    end

    trust:setLocalVar('ixi20CloseX', x)
    trust:setLocalVar('ixi20CloseZ', z)
end

local function watchMeleeTrust(trust)
    if not trust or trust:getLocalVar('ixi20MeleeWatch') == 1 then
        return
    end

    trust:setLocalVar('ixi20MeleeWatch', 1)
    local function tick(mobArg)
        if not mobArg or not mobArg:isAlive() or not mobArg:getMaster() then
            return
        end

        nudgeMeleeTrust(mobArg)
        mobArg:timer(1000, tick)
    end

    tick(trust)
end

-- List summons skip the spell cast. They still need the weaponskill
-- unlock and the melee nudge a normal call gets.
xi.trust._ixi20FinishSpawn = function(trust)
    unlockWeaponskills(trust)
    watchMeleeTrust(trust)
end

m:addOverride('xi.trust.spawn', function(caster, spell)
    local result = super(caster, spell)
    if caster and caster.getPartyWithTrusts and spell and spell.getID then
        local spellId = spell:getID()
        for _, member in pairs(caster:getPartyWithTrusts() or {}) do
            if member and member.isTrust and member:isTrust() and member:getTrustID() == spellId then
                unlockWeaponskills(member)
                watchMeleeTrust(member)
                if member:getLocalVar('ixi20BuffWatch') ~= 1 then
                    member:setLocalVar('ixi20BuffWatch', 1)
                    member:addListener('EFFECT_GAIN', 'IXI20_TRUST_BUFF', function(trustArg, effect)
                        if xi.ixi20 and xi.ixi20.extendTrustBuff then
                            xi.ixi20.extendTrustBuff(trustArg, effect)
                        end
                    end)
                end

                break
            end
        end
    end

    return result
end)

if not xi.trust._ixi20TrustWsSpawn then
    xi.trust._ixi20TrustWsSpawn = true
    local prevSpawn = xi.trust.spawn
    xi.trust.spawn = function(caster, spell)
        if xi.trust._ixi20DismissIfFull then
            xi.trust._ixi20DismissIfFull(caster)
        end

        local result = nil
        if prevSpawn then
            result = prevSpawn(caster, spell)
        end

        if caster and caster.getPartyWithTrusts and spell and spell.getID then
            local spellId = spell:getID()
            for _, member in pairs(caster:getPartyWithTrusts() or {}) do
                if member and member.isTrust and member:isTrust() and member:getTrustID() == spellId then
                    unlockWeaponskills(member)
                    watchMeleeTrust(member)
                    break
                end
            end
        end

        return result
    end
end

-- Shattering Stars and the other LB5 fights. Same set as trust.lua.
local rovKIBattlefieldIDs =
{
    [5]    = true,
    [6]    = true,
    [7]    = true,
    [70]   = true,
    [71]   = true,
    [72]   = true,
    [101]  = true,
    [102]  = true,
    [103]  = true,
    [163]  = true,
    [194]  = true,
    [195]  = true,
    [196]  = true,
    [517]  = true,
    [518]  = true,
    [519]  = true,
    [530]  = true,
    [1091] = true,
    [1123] = true,
    [1154] = true,
}

local function trustAlreadyOut(memberId, spellId, notAllowedTrustIds)
    if memberId == spellId then
        return true
    end

    if type(notAllowedTrustIds) == 'number' then
        return memberId == notAllowedTrustIds
    end

    if type(notAllowedTrustIds) == 'table' then
        for _, blockedId in pairs(notAllowedTrustIds) do
            if type(blockedId) == 'number' and memberId == blockedId then
                return true
            end
        end
    end

    return false
end

-- PTrusts is insertion order, and getPartyWithTrusts walks that vector
-- after the players. The first trust that belongs to this caster is the
-- one that was summoned first.
local function earliestOwnTrust(caster)
    if not caster or not caster.getPartyWithTrusts then
        return nil
    end

    local casterId = caster:getID()
    local party    = caster:getPartyWithTrusts() or {}

    for _, member in ipairs(party) do
        if member and member.getObjType and member:getObjType() == xi.objType.TRUST then
            local master = member.getMaster and member:getMaster() or nil
            if master and master.getID and master:getID() == casterId then
                return member
            end
        end
    end

    return nil
end

-- Stock canCast, without the Rhapsody in White / Crimson trust count.
local function canCastFullParty(caster, spell, notAllowedTrustIds)
    if xi.settings.main.ENABLE_TRUST_CASTING == 0 then
        return xi.msg.basic.TRUST_NO_CAST_TRUST
    end

    if caster:getGMLevel() > 0 and caster:getVisibleGMLevel() >= 3 then
        return 0
    end

    if caster:checkSoloPartyAlliance() == 2 then
        return xi.msg.basic.TRUST_NO_CAST_TRUST
    end

    -- No zone gate. ixi20_trust_persist.cpp also clears the spell mask
    -- that the magic state checks, so mog houses accept the cast.
    local leader = caster:getPartyLeader()
    if leader and caster:getID() ~= leader:getID() then
        caster:messageSystem(xi.msg.system.TRUST_SOLO_OR_LEADER)
        return -1
    end

    if caster:isSeekingParty() then
        caster:messageSystem(xi.msg.system.TRUST_NO_SEEKING_PARTY)
        return -1
    end

    local lastPartyMemberAddedTime = caster:getPartyLastMemberJoinedTime()
    if GetSystemTime() - lastPartyMemberAddedTime < 120 then
        caster:messageSystem(xi.msg.system.TRUST_DELAY_NEW_PARTY_MEMBER)
        return -1
    end

    if caster:hasEnmity() then
        caster:messageSystem(xi.msg.system.TRUST_NO_ENMITY)
        return -1
    end

    local numPt = 0
    local party = caster:getPartyWithTrusts()

    for _, member in pairs(party) do
        if member:getObjType() == xi.objType.TRUST then
            if trustAlreadyOut(member:getTrustID(), spell:getID(), notAllowedTrustIds) then
                caster:messageSystem(xi.msg.system.TRUST_ALREADY_CALLED)
                return -1
            end
        end

        numPt = numPt + 1
    end

    -- Room for one more after the earliest trust steps out. A party of
    -- real players, with nobody to dismiss, still refuses the cast.
    if numPt >= 6 and (type(Ixi20TrustDismiss) ~= 'function' or earliestOwnTrust(caster) == nil) then
        caster:messageSystem(xi.msg.system.TRUST_MAXIMUM_NUMBER)
        return -1
    end

    local casterBattlefieldID = caster:getBattlefieldID()
    if rovKIBattlefieldIDs[casterBattlefieldID] then
        if not caster:hasKeyItem(xi.ki.RHAPSODY_IN_UMBER) then
            return xi.msg.basic.TRUST_NO_CAST_TRUST
        end
    elseif
        xi.battlefield.contents[casterBattlefieldID] and
        not xi.battlefield.contents[casterBattlefieldID].allowTrusts
    then
        return xi.msg.basic.TRUST_NO_CAST_TRUST
    end

    if not xi.trust.checkBattlefieldTrustCount(caster) then
        return xi.msg.basic.TRUST_NO_CAST_TRUST
    end

    return 0
end

xi.trust._ixi20CanCast = function(caster, spell, notAllowedTrustIds)
    return canCastFullParty(caster, spell, notAllowedTrustIds)
end

xi.trust._ixi20DismissIfFull = function(caster)
    if type(Ixi20TrustDismiss) ~= 'function' or not caster or not caster.getPartyWithTrusts then
        return
    end

    local count = 0
    for _, member in pairs(caster:getPartyWithTrusts() or {}) do
        if member then
            count = count + 1
        end
    end

    if count < 6 then
        return
    end

    local oldest = earliestOwnTrust(caster)
    if oldest then
        Ixi20TrustDismiss(oldest)
    end
end

m:addOverride('xi.trust.canCast', function(caster, spell, notAllowedTrustIds)
    return xi.trust._ixi20CanCast(caster, spell, notAllowedTrustIds)
end)

if not xi.trust._ixi20TrustParty then
    xi.trust._ixi20TrustParty = true
    xi.trust.canCast = function(caster, spell, notAllowedTrustIds)
        return xi.trust._ixi20CanCast(caster, spell, notAllowedTrustIds)
    end
end

local function grantTrusts(player)
    if not player or not player.isPC or not player:isPC() then
        return
    end

    local pending = {}
    for _, spellId in ipairs(TRUST_SPELLS) do
        if not player:hasSpell(spellId) then
            pending[#pending + 1] = spellId
        end
    end

    for index, spellId in ipairs(pending) do
        player:addSpell(spellId, {
            silentLog  = true,
            saveToDB   = true,
            sendUpdate = index == #pending,
        })
    end
end

m:addOverride('xi.player.charCreate', function(player)
    super(player)
    grantTrusts(player)
end)

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    grantTrusts(player)
end)

if not xi.player._ixi20TrustsGameIn then
    xi.player._ixi20TrustsGameIn = true
    local prevGameIn = xi.player.onGameIn
    xi.player.onGameIn = function(player, firstLogin, zoning)
        if prevGameIn then
            prevGameIn(player, firstLogin, zoning)
        end

        grantTrusts(player)
    end
end

local function openGates(scriptName, apply)
    m:addOverride('xi.actions.spells.trust.' .. scriptName .. '.onMobSpawn', function(mob)
        super(mob)
        apply(mob)
    end)
end

openGates('valaineral', function(mob)
    if early(mob, 5) then
        ja(mob, ai.t.SELF, { ai.c.ALWAYS, 0 }, xi.ja.PROVOKE)
    end

    if early(mob, 30) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, xi.ja.SENTINEL)
    end

    if early(mob, 50) then
        ja(mob, ai.t.SELF, { { ai.c.MPP_LT, 50 }, { ai.c.TP_GTE, 1000 } }, xi.ja.CHIVALRY)
        ja(mob, ai.t.SELF, { { ai.c.JA_ON_COOLDOWN, xi.ja.SENTINEL }, { ai.c.NOT_STATUS, xi.effect.SENTINEL } }, xi.ja.DEFENDER)
    end

    if early(mob, 62) then
        ja(mob, ai.t.TARGET, { ai.c.STATUS, xi.effect.MANAFONT }, xi.ja.RAMPART)
        ja(mob, ai.t.TARGET, { ai.c.STATUS, xi.effect.CHAINSPELL }, xi.ja.RAMPART)
        ja(mob, ai.t.TARGET, { ai.c.STATUS, xi.effect.ASTRAL_FLOW }, xi.ja.RAMPART)
    end

    if early(mob, 70) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.MAJESTY }, xi.ja.MAJESTY)
    end

    if early(mob, 75) then
        ja(mob, ai.t.TARGET, { ai.c.CASTING_DEBUFF, 0 }, xi.ja.FEALTY)
        ja(mob, ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH }, xi.ja.DIVINE_EMBLEM)
    end
end)

openGates('trion', function(mob)
    if early(mob, 5) then
        ja(mob, ai.t.SELF, { ai.c.ALWAYS, 0 }, xi.ja.PROVOKE)
    end

    if early(mob, 15) then
        mob:addGambit(ai.t.TARGET, { ai.l.OR(
            { ai.c.CASTING_MA, 0 },
            { ai.c.READYING_JA, 0 },
            { ai.c.READYING_MS, 0 },
            { ai.c.READYING_WS, 0 }) }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.ROYAL_BASH_TRUST }, 60)
    end

    if early(mob, 30) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, xi.ja.SENTINEL)
    end
end)

openGates('curilla', function(mob)
    if early(mob, 30) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, xi.ja.SENTINEL)
    end
end)

openGates('rughadjeen', function(mob)
    if early(mob, 5) then
        ja(mob, ai.t.TARGET, { ai.c.IS_ECOSYSTEM, xi.ecosystem.UNDEAD }, xi.ja.HOLY_CIRCLE)
    end

    if early(mob, 30) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, xi.ja.SENTINEL)
    end

    if early(mob, 50) then
        ja(mob, ai.t.SELF, { { ai.c.MPP_LT, 50 }, { ai.c.TP_GTE, 1000 } }, xi.ja.CHIVALRY)
    end

    if early(mob, 75) then
        ja(mob, ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH }, xi.ja.DIVINE_EMBLEM)
    end
end)

openGates('rahal', function(mob)
    if early(mob, 10) then
        ja(mob, ai.t.SELF, { ai.c.NOT_HAS_TOP_ENMITY, 0 }, xi.ja.PROVOKE)
    end

    if early(mob, 15) then
        ja(mob, ai.t.TARGET, { ai.l.OR(
            { ai.c.CASTING_MA, 0 },
            { ai.c.READYING_JA, 0 },
            { ai.c.READYING_MS, 0 },
            { ai.c.READYING_WS, 0 }) }, xi.ja.SHIELD_BASH)
    end

    if early(mob, 30) then
        ja(mob, ai.t.MASTER, { ai.c.NOT_STATUS, xi.effect.BERSERK }, xi.ja.BERSERK)
        ja(mob, ai.t.SELF, { ai.c.HPP_LT, 35 }, xi.ja.SENTINEL)
    end
end)

openGates('gessho', function(mob)
    if early(mob, 5) then
        ja(mob, ai.t.SELF, { ai.c.ALWAYS, 0 }, xi.ja.PROVOKE)
    end

    if early(mob, 40) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.YONIN }, xi.ja.YONIN)
    end
end)

openGates('aahm', function(mob)
    if early(mob, 10) then
        ja(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, xi.ja.PROVOKE)
    end

    if early(mob, 30) then
        ja(mob, ai.t.SELF, { { ai.c.NOT_PT_HAS_TANK, 0 }, { ai.c.NOT_STATUS, xi.effect.BERSERK } }, xi.ja.BERSERK)
    end

    if early(mob, 40) then
        ja(mob, ai.t.SELF, { { ai.c.NOT_PT_HAS_TANK, 0 }, { ai.c.NOT_STATUS, xi.effect.INNIN } }, xi.ja.INNIN)
        ja(mob, ai.t.SELF, { { ai.c.PT_HAS_TANK, 0 }, { ai.c.NOT_STATUS, xi.effect.YONIN } }, xi.ja.YONIN)
    end

    if early(mob, 70) then
        ja(mob, ai.t.SELF, { { ai.c.PT_HAS_TANK, 0 }, { ai.c.NOT_STATUS, xi.effect.WARCRY } }, xi.ja.WARCRY)
    end
end)

openGates('amchuchu', function(mob)
    if early(mob, 5) then
        mob:addGambit(ai.t.SELF, { ai.c.NO_MAX_RUNE, 0 }, { ai.r.JA, ai.s.RUNE_DAY, xi.ja.IGNIS })
    end

    if early(mob, 10) then
        ja(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, xi.ja.PROVOKE)
        ja(mob, ai.t.TARGET, { ai.c.CAST_ELE_MA_SELF, xi.effect.VALLATION }, xi.ja.VALLATION)
    end

    if early(mob, 20) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SWORDPLAY }, xi.ja.SWORDPLAY)
    end

    if early(mob, 25) then
        ja(mob, ai.t.TARGET, { ai.c.LUNGE_MB_AVAILABLE, 0 }, xi.ja.LUNGE)
        ja(mob, ai.t.TARGET, { ai.c.LUNGE_MB_AVAILABLE, 0 }, xi.ja.SWIPE)
    end

    if early(mob, 30) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BERSERK }, xi.ja.BERSERK)
    end

    if early(mob, 50) then
        ja(mob, ai.t.TARGET, { ai.c.CASTING_ELE_MA_AOE, 0 }, xi.ja.VALIANCE)
    end

    if early(mob, 60) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.EMBOLDEN }, xi.ja.EMBOLDEN)
    end

    if early(mob, 65) then
        ja(mob, ai.t.SELF, { ai.c.HPP_LT, 50 }, xi.ja.VIVACIOUS_PULSE)
    end

    if early(mob, 75) then
        ja(mob, ai.t.SELF, { ai.c.HPP_LT, 75 }, xi.ja.BATTUTA)
    end

    if early(mob, 95) then
        ja(mob, ai.t.TARGET, { ai.c.CASTING_ELE_MA_AOE, 0 }, xi.ja.ONE_FOR_ALL)
    end
end)

openGates('aaev', function(mob)
    if early(mob, 15) then
        mob:addGambit(ai.t.TARGET, { ai.c.CASTING_ELE_MA_AOE, 0 }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.SHIELD_STRIKE_TRUST })
    end

    if early(mob, 30) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, xi.ja.SENTINEL)
    end

    if early(mob, 50) then
        ja(mob, ai.t.SELF, { { ai.c.MPP_LT, 50 }, { ai.c.TP_GTE, 1000 } }, xi.ja.CHIVALRY)
    end

    if early(mob, 62) then
        ja(mob, ai.t.TARGET, { ai.c.STATUS, xi.effect.MANAFONT }, xi.ja.RAMPART)
        ja(mob, ai.t.TARGET, { ai.c.STATUS, xi.effect.CHAINSPELL }, xi.ja.RAMPART)
        ja(mob, ai.t.TARGET, { ai.c.STATUS, xi.effect.ASTRAL_FLOW }, xi.ja.RAMPART)
    end

    if early(mob, 75) then
        ja(mob, ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH }, xi.ja.DIVINE_EMBLEM)
    end

    if early(mob, 95) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PALISADE }, xi.ja.PALISADE)
    end
end)

openGates('august', function(mob)
    if early(mob, 10) then
        ja(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, xi.ja.PROVOKE)
    end

    if early(mob, 30) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.SENTINEL }, xi.ja.SENTINEL)
    end

    if early(mob, 75) then
        ja(mob, ai.t.SELF, { { ai.c.SUB_ANIMATION, 5 }, { ai.c.NOT_STATUS, xi.effect.DIVINE_EMBLEM } }, xi.ja.DIVINE_EMBLEM)
    end

    if early(mob, 95) then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.PALISADE }, xi.ja.PALISADE)
    end

    -- Stock checks level 51 inside the tick. Replace it with the compressed gate.
    mob:removeListener('AUGUST_CTICK')
    local daybreakLevel = compress(51)
    mob:addListener('COMBAT_TICK', 'AUGUST_CTICK', function(mobArg)
        local daybreakRecast  = 180
        local daybreakEndTime = mobArg:getLocalVar('DaybreakEndTime')
        local daybreakUsed    = mobArg:getLocalVar('DaybreakUsed')
        local now             = GetSystemTime()
        if
            mobArg:getMainLvl() >= daybreakLevel and
            mobArg:getAnimationSub() == 0 and
            (daybreakEndTime == 0 or now >= daybreakEndTime + daybreakRecast) and
            mobArg:getHPP() <= 66 and
            daybreakUsed ~= 1
        then
            mobArg:useMobAbility(xi.mobSkill.DAYBREAK_TRUST)
        end
    end)
end)

openGates('sylvie_uc', function(mob)
    if early(mob, 20) then
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.COLURE_ACTIVE }, { ai.r.MA, ai.s.BEST_INDI, xi.magic.spellFamily.NONE })
    end

    if early(mob, 50) then
        mob:addGambit(ai.t.SELF, { { ai.c.MPP_LT, 66 }, { ai.c.LVL_GTE, compress(50) }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.NOTT })
    end

    local master = mob:getMaster()
    if early(mob, 93) and master and master:getMainJob() ~= xi.job.GEO then
        ja(mob, ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.ENTRUST }, xi.ja.ENTRUST)
        mob:addGambit(ai.t.SELF, { ai.c.STATUS, xi.effect.ENTRUST }, { ai.r.MA, ai.s.ENTRUSTED, xi.magic.spellFamily.INDI_BUFF })
    end

    if early(mob, 99) then
        mob:addMod(xi.mod.GEOMANCY_BONUS, 3)
    end
end)

openGates('apururu_uc', function(mob)
    if early(mob, 50) then
        mob:addGambit(ai.t.SELF, { { ai.c.MPP_LT, 51 }, { ai.c.LVL_GTE, compress(50) }, { ai.c.TP_GTE, 1000 } }, { ai.r.MS, ai.s.SPECIFIC, xi.mobSkill.NOTT })
    end
end)

openGates('maat_uc', function(mob)
    local master = mob:getMaster()
    if master and master:getMainLvl() < 50 and master:getMainLvl() >= compress(50) then
        mob:setTrustTPSkillSettings(ai.tp.CLOSER_UNTIL_TP, ai.s.HIGHEST, 3000)
    end
end)

-- Grapeshot is mob skill 3198. The stock lines use a weaponskill reaction,
-- and that reaction is never executed, so she never stuns a readying enemy.
openGates('lion', function(mob)
    local grapeshot = 3198

    mob:removeAllGambits()
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_WS, 0 }, { ai.r.MS, ai.s.SPECIFIC, grapeshot })
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_MS, 0 }, { ai.r.MS, ai.s.SPECIFIC, grapeshot })
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_JA, 0 }, { ai.r.MS, ai.s.SPECIFIC, grapeshot })
    mob:addGambit(ai.t.TARGET, { ai.c.CASTING_MA, 0 }, { ai.r.MS, ai.s.SPECIFIC, grapeshot })
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM)
    mob:setAutoAttackEnabled(true)
end)

local function arcielaBuffs(mob)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELL })
    mob:addGambit(ai.t.MASTER, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.MASTER, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REFRESH })
    mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.REFRESH }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REFRESH })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE }, 60)
end

openGates('arciela', arcielaBuffs)

openGates('arciela_ii', function(mob)
    arcielaBuffs(mob)
    mob:addGambit(ai.t.RANGED, { ai.c.NOT_STATUS, xi.effect.FLURRY }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FLURRY })
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 10)
end)

-- Skillchain property to the elements that magic burst it.
local darrcuilnBurstElements =
{
    [xi.skillchainType.TRANSFIXION]   = { xi.element.LIGHT },
    [xi.skillchainType.COMPRESSION]   = { xi.element.DARK },
    [xi.skillchainType.LIQUEFACTION]  = { xi.element.FIRE },
    [xi.skillchainType.SCISSION]      = { xi.element.EARTH },
    [xi.skillchainType.REVERBERATION] = { xi.element.WATER },
    [xi.skillchainType.DETONATION]    = { xi.element.WIND },
    [xi.skillchainType.INDURATION]    = { xi.element.ICE },
    [xi.skillchainType.IMPACTION]     = { xi.element.THUNDER },
    [xi.skillchainType.GRAVITATION]   = { xi.element.DARK, xi.element.EARTH },
    [xi.skillchainType.DISTORTION]    = { xi.element.WATER, xi.element.ICE },
    [xi.skillchainType.FUSION]        = { xi.element.LIGHT, xi.element.FIRE },
    [xi.skillchainType.FRAGMENTATION] = { xi.element.WIND, xi.element.THUNDER },
    [xi.skillchainType.LIGHT]         = { xi.element.LIGHT, xi.element.FIRE, xi.element.WIND, xi.element.THUNDER },
    [xi.skillchainType.DARKNESS]      = { xi.element.DARK, xi.element.EARTH, xi.element.WATER, xi.element.ICE },
    [xi.skillchainType.LIGHT_II]      = { xi.element.LIGHT, xi.element.FIRE, xi.element.WIND, xi.element.THUNDER },
    [xi.skillchainType.DARKNESS_II]   = { xi.element.DARK, xi.element.EARTH, xi.element.WATER, xi.element.ICE },
}

local darrcuilnResRank =
{
    [xi.element.FIRE]    = xi.mod.FIRE_RES_RANK,
    [xi.element.ICE]     = xi.mod.ICE_RES_RANK,
    [xi.element.WIND]    = xi.mod.WIND_RES_RANK,
    [xi.element.EARTH]   = xi.mod.EARTH_RES_RANK,
    [xi.element.THUNDER] = xi.mod.THUNDER_RES_RANK,
    [xi.element.WATER]   = xi.mod.WATER_RES_RANK,
    [xi.element.LIGHT]   = xi.mod.LIGHT_RES_RANK,
    [xi.element.DARK]    = xi.mod.DARK_RES_RANK,
}

-- Sacrifices the caster. He knows them; he does not cast them.
local darrcuilnSkip =
{
    [xi.magic.spell.SELF_DESTRUCT] = true,
    [xi.magic.spell.FINAL_STING]   = true,
}

local darrcuilnDamageSpells

local function darrcuilnDamageCatalog()
    if darrcuilnDamageSpells then
        return darrcuilnDamageSpells
    end

    darrcuilnDamageSpells = {}
    for id = 513, 743 do
        if not darrcuilnSkip[id] then
            local spell = GetSpell(id)
            if spell and
                spell:getSkillType() == xi.skill.BLUE_MAGIC and
                spell:dealsDamage() and
                spell:getLevel(xi.job.BLU) > 0
            then
                darrcuilnDamageSpells[#darrcuilnDamageSpells + 1] = id
            end
        end
    end

    return darrcuilnDamageSpells
end

local function darrcuilnBestSpell(mob, element)
    local level = mob:getMainLvl()
    local bestId
    local bestLevel = -1
    for _, id in ipairs(darrcuilnDamageCatalog()) do
        local spell = GetSpell(id)
        if spell and spell:getElement() == element then
            local req = spell:getLevel(xi.job.BLU)
            if req > 0 and req <= level and req >= bestLevel and
                mob:getMP() >= spell:getMPCost() and
                not mob:hasRecast(xi.recast.MAGIC, id)
            then
                bestId = id
                bestLevel = req
            end
        end
    end

    return bestId
end

local function darrcuilnWindowElements(effect)
    local power = effect:getPower()
    local props
    if effect:getTier() == 0 then
        props =
        {
            bit.band(power, 0x0F),
            bit.band(bit.rshift(power, 4), 0x0F),
            bit.band(bit.rshift(power, 8), 0x0F),
        }
    else
        props = { power }
    end

    local elements = {}
    local seen = {}
    for _, prop in ipairs(props) do
        for _, element in ipairs(darrcuilnBurstElements[prop] or {}) do
            if not seen[element] then
                seen[element] = true
                elements[#elements + 1] = element
            end
        end
    end

    return elements
end

-- Highest magical SDT, then lowest resistance rank. A gap under 5%
-- is treated as no elemental weakness.
local function darrcuilnWeakElement(target)
    local bestElement
    local bestScore
    local secondScore
    for element = xi.element.FIRE, xi.element.DARK do
        local sdt = xi.combat.damage.magicalElementSDT(target, element)
        local rank = target:getMod(darrcuilnResRank[element]) or 0
        local score = sdt - rank * 0.25
        if not bestScore or score > bestScore then
            secondScore = bestScore
            bestScore = score
            bestElement = element
        elseif not secondScore or score > secondScore then
            secondScore = score
        end
    end

    if bestElement and secondScore and (bestScore - secondScore) >= 0.05 then
        return bestElement
    end
end

-- Blue Mage. Stays in melee. One combat tick does the whole rotation,
-- burst first, then a heal, then a buff, then the damaging spell of
-- the target's weakest element, then a physical blue spell. Chain
-- Affinity and Burst Affinity are permanent and do not spend his TP.
openGates('darrcuiln', function(mob)
    local affinityFlags = bit.bor(
        xi.effectFlag.ON_JOBCHANGE,
        xi.effectFlag.HIDE_TIMER,
        xi.effectFlag.NO_LOSS_MESSAGE,
        xi.effectFlag.NO_CANCEL
    )
    local affinityEffects =
    {
        xi.effect.DIFFUSION,
        xi.effect.CHAIN_AFFINITY,
        xi.effect.BURST_AFFINITY,
    }

    local function isAffinity(effectId)
        for _, id in ipairs(affinityEffects) do
            if id == effectId then
                return true
            end
        end

        return false
    end

    local function keepAffinities(mobArg)
        if not mobArg or not mobArg:isAlive() then
            return
        end

        for _, effectId in ipairs(affinityEffects) do
            local effect = mobArg:getStatusEffect(effectId)
            if effect then
                if effect:getDuration() ~= 0 then
                    effect:setDuration(0)
                end

                effect:addEffectFlag(affinityFlags)
                effect:delEffectFlag(xi.effectFlag.DEATH)
                effect:delEffectFlag(xi.effectFlag.ON_ZONE)
            else
                mobArg:addStatusEffect(effectId, {
                    duration = 0,
                    origin   = mobArg,
                    silent   = true,
                    flag     = affinityFlags,
                })
            end
        end
    end

    keepAffinities(mob)
    mob:removeListener('IXI20_DARRCULN_DIFFUSION')
    mob:addListener('EFFECT_LOSE', 'IXI20_DARRCULN_DIFFUSION', function(owner, effect)
        if not effect or not effect.getEffectType or not isAffinity(effect:getEffectType()) then
            return
        end

        owner:timer(1, function(restoreTarget)
            keepAffinities(restoreTarget)
        end)
    end)

    -- No gambits. Gambits run before this tick, so a cure there would
    -- beat a magic burst. The tick below is the whole rotation.
    mob:removeAllGambits()

    local function darrcuilnCanCast(mobArg, spellId)
        local spell = GetSpell(spellId)
        if not spell then
            return false
        end

        local req = spell:getLevel(xi.job.BLU)
        return req > 0 and req <= mobArg:getMainLvl() and
            mobArg:getMP() >= spell:getMPCost() and
            not mobArg:hasRecast(xi.recast.MAGIC, spellId)
    end

    local function darrcuilnCast(mobArg, spellId, target)
        if not darrcuilnCanCast(mobArg, spellId) then
            return false
        end

        mobArg:castSpell(spellId, target)
        return true
    end

    local function darrcuilnHeal(mobArg)
        local master = mobArg:getMaster()
        if master and master.getPartyWithTrusts then
            for _, member in pairs(master:getPartyWithTrusts()) do
                if member and member:isAlive() and mobArg:checkDistance(member) <= 20 and member:getHPP() < 60 then
                    if darrcuilnCast(mobArg, xi.magic.spell.MAGIC_FRUIT, member) or
                        darrcuilnCast(mobArg, xi.magic.spell.WILD_CARROT, member)
                    then
                        return true
                    end
                end
            end
        end

        if mobArg:getHPP() < 50 and darrcuilnCast(mobArg, xi.magic.spell.HEALING_BREEZE, mobArg) then
            return true
        end

        if mobArg:getHPP() < 70 and darrcuilnCast(mobArg, xi.magic.spell.POLLEN, mobArg) then
            return true
        end

        return false
    end

    local function darrcuilnBuff(mobArg)
        if not mobArg:hasStatusEffect(xi.effect.STONESKIN) and
            darrcuilnCast(mobArg, xi.magic.spell.METALLIC_BODY, mobArg)
        then
            return true
        end

        if not mobArg:hasStatusEffect(xi.effect.DEFENSE_BOOST) and
            darrcuilnCast(mobArg, xi.magic.spell.COCOON, mobArg)
        then
            return true
        end

        if not mobArg:hasStatusEffect(xi.effect.REFUELING) and
            darrcuilnCast(mobArg, xi.magic.spell.REFUELING, mobArg)
        then
            return true
        end

        return false
    end

    local function darrcuilnBusy(mobArg)
        local action = mobArg:getCurrentAction()
        return action == xi.action.category.MAGIC_CASTING or
            action == xi.action.category.MAGIC_START or
            action == xi.action.category.MOBABILITY_USING or
            action == xi.action.category.MOBABILITY_START or
            action == xi.action.category.WEAPONSKILL_START or
            action == xi.action.category.WEAPONSKILL_FINISH
    end

    mob:removeListener('IXI20_DARRCULN_BURST')
    mob:removeListener('IXI20_DARRCULN_BLU')
    mob:addListener('COMBAT_TICK', 'IXI20_DARRCULN_BLU', function(mobArg)
        keepAffinities(mobArg)
        if not mobArg:isAlive() or not mobArg:getMaster() or darrcuilnBusy(mobArg) then
            return
        end

        if not mobArg:actionQueueEmpty() then
            return
        end

        local target = mobArg:getTarget()
        local chain = target and target:isAlive() and target:getStatusEffect(xi.effect.SKILLCHAIN)
        if chain then
            for _, element in ipairs(darrcuilnWindowElements(chain)) do
                local burstId = darrcuilnBestSpell(mobArg, element)
                if burstId then
                    mobArg:castSpell(burstId, target)
                    return
                end
            end
        end

        if darrcuilnHeal(mobArg) or darrcuilnBuff(mobArg) then
            return
        end

        -- A non-burst nuke would close an open window.
        if chain or not target or not target:isAlive() then
            return
        end

        local weak = darrcuilnWeakElement(target)
        local spellId = weak and darrcuilnBestSpell(mobArg, weak)
        if not spellId then
            spellId = darrcuilnBestSpell(mobArg, xi.element.NONE)
        end

        if spellId then
            mobArg:castSpell(spellId, target)
        end
    end)

    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)
end)

-- Bard / White Mage. Spell access is the player list in ixi20_joachim_spells.sql.
-- Gambits are checked in order, so a cleanse or a heal fires before a song,
-- and a song fires before a nuke. Requiem and Elegy are kept on the enemy.
-- Weaponskills wait while someone nearby needs a heal or a cleanse.
-- Trigger 99 is not a stock TP mode, so TryTrustSkill holds unless he
-- is sitting on 3000 TP. That cap is trimmed while the party needs help.
local JOACHIM_TP_HOLD = 99

local joachimNa =
{
    { xi.effect.POISON, xi.magic.spell.POISONA },
    { xi.effect.PARALYSIS, xi.magic.spell.PARALYNA },
    { xi.effect.BLINDNESS, xi.magic.spell.BLINDNA },
    { xi.effect.SILENCE, xi.magic.spell.SILENA },
    { xi.effect.PETRIFICATION, xi.magic.spell.STONA },
    { xi.effect.DISEASE, xi.magic.spell.VIRUNA },
    { xi.effect.CURSE_I, xi.magic.spell.CURSNA },
}

local joachimErase =
{
    xi.effect.PLAGUE,
    xi.effect.SLOW,
    xi.effect.BIND,
    xi.effect.WEIGHT,
    xi.effect.BURN,
    xi.effect.FROST,
    xi.effect.CHOKE,
    xi.effect.RASP,
    xi.effect.SHOCK,
    xi.effect.DROWN,
    xi.effect.DIA,
    xi.effect.BIO,
    xi.effect.ATTACK_DOWN,
    xi.effect.DEFENSE_DOWN,
    xi.effect.MAGIC_DEF_DOWN,
    xi.effect.ACCURACY_DOWN,
    xi.effect.EVASION_DOWN,
    xi.effect.STR_DOWN,
    xi.effect.DEX_DOWN,
    xi.effect.VIT_DOWN,
    xi.effect.AGI_DOWN,
    xi.effect.INT_DOWN,
    xi.effect.MND_DOWN,
    xi.effect.CHR_DOWN,
    xi.effect.ADDLE,
    xi.effect.MAX_HP_DOWN,
    xi.effect.MAX_MP_DOWN,
    xi.effect.ELEGY,
    xi.effect.REQUIEM,
}

local function joachimNear(mob, member)
    return member and mob:checkDistance(member) <= 20
end

-- Same 15 yalms the party gambit uses. A member farther out is not
-- waiting on March or Minuet.
local function joachimPartyHasSong(mob, effectId)
    local master = mob:getMaster()
    if not master or not master.getPartyWithTrusts then
        return mob:hasStatusEffect(effectId)
    end

    local saw = false
    for _, member in pairs(master:getPartyWithTrusts()) do
        if member and member:isAlive() and mob:checkDistance(member) <= 15 then
            saw = true
            if not member:hasStatusEffect(effectId) then
                return false
            end
        end
    end

    return saw
end

local function joachimPartyNeedsHelp(mob)
    local master = mob:getMaster()
    if not master then
        return false
    end

    local party = master.getPartyWithTrusts and master:getPartyWithTrusts() or {}
    for _, member in pairs(party) do
        if member and member:isAlive() and joachimNear(mob, member) then
            if member:getHPP() < 75 then
                return true
            end

            for _, na in ipairs(joachimNa) do
                if member:hasStatusEffect(na[1]) then
                    return true
                end
            end

            -- Erase is the compressed WHM 17 spell. Before that, a Slow
            -- he cannot remove should not park his weaponskills.
            if mob:getMainLvl() >= 17 then
                for _, effectId in ipairs(joachimErase) do
                    if member:hasStatusEffect(effectId) then
                        return true
                    end
                end
            end
        end
    end

    if master.getParty then
        for _, member in pairs(master:getParty() or {}) do
            if member and member:isDead() and joachimNear(mob, member) then
                return true
            end
        end
    end

    return false
end

-- Healers first, then the other mages. A lower rank is served first.
local joachimMageRank =
{
    [xi.job.WHM] = 1,
    [xi.job.SCH] = 2,
    [xi.job.RDM] = 3,
    [xi.job.GEO] = 4,
    [xi.job.BLM] = 5,
    [xi.job.SMN] = 6,
    [xi.job.BLU] = 7,
    [xi.job.BRD] = 8,
}

local joachimBallads =
{
    xi.magic.spell.MAGES_BALLAD_III,
    xi.magic.spell.MAGES_BALLAD_II,
    xi.magic.spell.MAGES_BALLAD,
}

local function joachimBalladSpell(mob)
    local level = mob:getMainLvl()
    for _, id in ipairs(joachimBallads) do
        local spell = GetSpell(id)
        if spell then
            local req = spell:getLevel(xi.job.BRD)
            if req > 0 and req <= level then
                return id
            end
        end
    end
end

local function joachimNextBalladTarget(mob)
    local master = mob:getMaster()
    if not master or not master.getPartyWithTrusts then
        return nil
    end

    local best
    local bestRank
    for _, member in pairs(master:getPartyWithTrusts()) do
        if member and member:isAlive() and member.getMainJob and joachimNear(mob, member) then
            local rank = joachimMageRank[member:getMainJob()]
            if rank and not member:hasStatusEffect(xi.effect.BALLAD) and (not bestRank or rank < bestRank) then
                best = member
                bestRank = rank
            end
        end
    end

    return best
end

local function joachimBusy(mob)
    local action = mob:getCurrentAction()
    return action == xi.action.category.MAGIC_CASTING or
        action == xi.action.category.MAGIC_START or
        action == xi.action.category.MOBABILITY_USING or
        action == xi.action.category.MOBABILITY_START or
        action == xi.action.category.JOBABILITY_START or
        action == xi.action.category.WEAPONSKILL_START or
        action == xi.action.category.WEAPONSKILL_FINISH
end

local function configureJoachim(mob)
    mob:removeAllGambits()
    -- 2 base songs plus 3. March and Minuet go on the party first.
    -- Ballad is single-target on mages once Pianissimo is learned
    -- (level 8). Madrigal and Minne fill the remaining slots after that.
    mob:setMod(xi.mod.MAXIMUM_SONGS_BONUS, 3)

    for _, na in ipairs(joachimNa) do
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS, na[1] }, { ai.r.MA, ai.s.SPECIFIC, na[2] })
    end

    for _, effectId in ipairs(joachimErase) do
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS, effectId }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.ERASE })
    end

    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURAGA })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY_DEAD, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.RAISE })

    -- Party songs, ahead of Protect and the other buffs. AoE still
    -- radiates from him; the party target recasts for anyone in range
    -- who missed it.
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.MARCH }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MARCH })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.MINUET }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.VALOR_MINUET })

    -- While a mage still needs Ballad, leave the later songs off so
    -- the combat tick can Pianissimo and cast it on that mage.
    local balladSpell = joachimBalladSpell(mob)
    local balladTarget = balladSpell and mob:getMainLvl() >= 8 and joachimNextBalladTarget(mob)
    mob:setLocalVar('ixi20BalladGate', balladTarget and 1 or 0)
    mob:setLocalVar('ixi20JoachimLvl', mob:getMainLvl())
    if not balladTarget then
        mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
        mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT })
        mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
        mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELL })
        mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })
        mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.REGEN }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REGEN })
        mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.RERAISE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.RERAISE })

        if mob:getMainLvl() < 8 then
            mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.BALLAD }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MAGES_BALLAD })
        end

        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.MADRIGAL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.MADRIGAL })
        mob:addGambit(ai.t.SELF, { ai.c.NOT_STATUS, xi.effect.MINNE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.KNIGHTS_MINNE })
        mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.REQUIEM }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.FOE_REQUIEM })
        mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.ELEGY }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.ELEGY })
        mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
        mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.DIA }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.DIA })
        mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW })
        mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE })
        mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HOLY })
        mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.BANISH })
    end

    mob:setAutoAttackEnabled(true)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.MID_RANGE)
    mob:setTrustTPSkillSettings(JOACHIM_TP_HOLD, ai.s.HIGHEST, 1000)
    mob:setLocalVar('ixi20TpMode', 1)
end

local function joachimTp(mob)
    local hold = joachimPartyNeedsHelp(mob)
    local mode = hold and 1 or 2
    if hold and mob:getTP() >= 3000 then
        mob:setTP(2999)
    end

    if mob:getLocalVar('ixi20TpMode') == mode then
        return
    end

    mob:setLocalVar('ixi20TpMode', mode)
    if hold then
        mob:setTrustTPSkillSettings(JOACHIM_TP_HOLD, ai.s.HIGHEST, 1000)
    else
        mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.HIGHEST, 1000)
    end
end

openGates('joachim', function(mob)
    configureJoachim(mob)
    mob:removeListener('IXI20_JOACHIM')
    mob:addListener('COMBAT_TICK', 'IXI20_JOACHIM', function(mobArg)
        if not mobArg or not mobArg:isAlive() then
            return
        end

        if joachimBusy(mobArg) then
            joachimTp(mobArg)
            return
        end

        local level = mobArg:getMainLvl()
        local balladSpell = joachimBalladSpell(mobArg)
        local balladTarget = balladSpell and level >= 8 and joachimNextBalladTarget(mobArg)
        local gate = balladTarget and 1 or 0
        if mobArg:getLocalVar('ixi20JoachimLvl') ~= level or mobArg:getLocalVar('ixi20BalladGate') ~= gate then
            configureJoachim(mobArg)
        end

        joachimTp(mobArg)

        if not balladTarget or not mobArg:actionQueueEmpty() then
            return
        end

        if not joachimPartyHasSong(mobArg, xi.effect.MARCH) or not joachimPartyHasSong(mobArg, xi.effect.MINUET) then
            return
        end

        if not mobArg:hasStatusEffect(xi.effect.PIANISSIMO) then
            mobArg:useJobAbility(xi.ja.PIANISSIMO, mobArg)
            return
        end

        mobArg:castSpell(balladSpell, balladTarget)
    end)
end)

-- Casters stand and cast. A missing spell family simply does not resolve.
local function standToCast(mob)
    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)
end

local function addHeals(mob)
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 75 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURE })
    mob:addGambit(ai.t.PARTY, { ai.c.HPP_LT, 50 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.CURAGA })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECT })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELL })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.HASTE }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.HASTE })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.REGEN }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.REGEN })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.FLASH }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.FLASH }, 60)

    local naSpells =
    {
        { xi.effect.POISON, xi.magic.spell.POISONA },
        { xi.effect.PARALYSIS, xi.magic.spell.PARALYNA },
        { xi.effect.BLINDNESS, xi.magic.spell.BLINDNA },
        { xi.effect.SILENCE, xi.magic.spell.SILENA },
        { xi.effect.PETRIFICATION, xi.magic.spell.STONA },
        { xi.effect.DISEASE, xi.magic.spell.VIRUNA },
        { xi.effect.CURSE_I, xi.magic.spell.CURSNA },
    }
    for _, na in ipairs(naSpells) do
        mob:addGambit(ai.t.PARTY, { ai.c.STATUS, na[1] }, { ai.r.MA, ai.s.SPECIFIC, na[2] })
    end
end

local function addNukes(mob)
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 10)
end

local function addEnfeebles(mob)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SLOW }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SLOW }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.PARALYSIS }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PARALYZE }, 60)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_STATUS, xi.effect.SILENCE }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.SILENCE }, 60)
end

local function asCaster(mob)
    standToCast(mob)
    addNukes(mob)
end

local function asHealer(mob)
    standToCast(mob)
    addHeals(mob)
end

local function asRanger(mob)
    mob:setAutoAttackEnabled(false)
    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.LONG_RANGE)
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.RATTACK, 0, 0 })
end

-- One avatar stays summoned and keeps using its own blood pacts.
-- After one to three fights it is replaced by the next avatar.
-- Kayeel and Robel both walk the celestial avatars. These are
-- job-ability ids, used by the pet.
local celestialAvatars =
{
        {
            id = xi.petId.CARBUNCLE,
            pacts =
            {
                { id = xi.jobAbility.HEALING_RUBY, ward = true },
                { id = xi.jobAbility.SHINING_RUBY, ward = true },
                { id = xi.jobAbility.HEALING_RUBY_II, ward = true },
                { id = xi.jobAbility.SEARING_LIGHT },
            },
        },
        {
            id = xi.petId.IFRIT,
            pacts =
            {
                { id = xi.jobAbility.CRIMSON_HOWL, ward = true },
                { id = xi.jobAbility.INFERNO },
            },
        },
        {
            id = xi.petId.TITAN,
            pacts =
            {
                { id = xi.jobAbility.EARTHEN_WARD, ward = true },
                { id = xi.jobAbility.EARTHEN_FURY },
            },
        },
        {
            id = xi.petId.LEVIATHAN,
            pacts =
            {
                { id = xi.jobAbility.SPRING_WATER, ward = true },
                { id = xi.jobAbility.SLOWGA },
                { id = xi.jobAbility.TIDAL_WAVE },
            },
        },
        {
            id = xi.petId.GARUDA,
            pacts =
            {
                { id = xi.jobAbility.AERIAL_ARMOR, ward = true },
                { id = xi.jobAbility.HASTEGA, ward = true },
                { id = xi.jobAbility.AERIAL_BLAST },
            },
        },
        {
            id = xi.petId.SHIVA,
            pacts =
            {
                { id = xi.jobAbility.FROST_ARMOR, ward = true },
                { id = xi.jobAbility.SLEEPGA },
                { id = xi.jobAbility.DIAMOND_DUST },
            },
        },
        {
            id = xi.petId.RAMUH,
            pacts =
            {
                { id = xi.jobAbility.ROLLING_THUNDER, ward = true },
                { id = xi.jobAbility.THUNDERSPARK },
                { id = xi.jobAbility.JUDGMENT_BOLT },
            },
        },
        {
            id = xi.petId.FENRIR,
            pacts =
            {
                { id = xi.jobAbility.LUNAR_CRY },
                { id = xi.jobAbility.ECLIPTIC_HOWL, ward = true },
                { id = xi.jobAbility.HOWLING_MOON },
            },
        },
        {
            id = xi.petId.DIABOLOS,
            pacts =
            {
                { id = xi.jobAbility.NIGHTMARE },
            },
        },
}

local avatarRosters =
{
    [976] = celestialAvatars, -- Kayeel-Payeel
    [977] = celestialAvatars, -- Robel-Akbel
}

-- These wards are an area around the avatar, radius 14. The trust
-- often stands behind that circle, so a check centered on the trust
-- never sees the party's buffs and the pact is cast again.
-- Haste and Warcry land only when the new power is at least the old
-- one, so a weaker pact is skipped and a stronger one is left alone.
-- Earthen Ward, Aerial Armor, Frost Armor, Shining Ruby, and Ecliptic
-- Howl delete the current effect first, so they are held when anyone
-- in the circle would lose a stronger protection.
local PACT_RADIUS = 14

local debuffEffects =
{
    [xi.jobAbility.SLEEPGA]   = { xi.effect.SLEEP_I },
    [xi.jobAbility.SLOWGA]    = { xi.effect.SLOW },
    [xi.jobAbility.LUNAR_CRY] = { xi.effect.ACCURACY_DOWN, xi.effect.EVASION_DOWN },
    [xi.jobAbility.NIGHTMARE] = { xi.effect.SLEEP_I },
}

local springAilments =
{
    xi.effect.BLINDNESS,
    xi.effect.POISON,
    xi.effect.PARALYSIS,
    xi.effect.DISEASE,
    xi.effect.PETRIFICATION,
    xi.effect.SILENCE,
    xi.effect.SLOW,
}

local spikeFamily =
{
    xi.effect.BLAZE_SPIKES,
    xi.effect.SHOCK_SPIKES,
    xi.effect.DREAD_SPIKES,
    xi.effect.REPRISAL,
    xi.effect.DELUGE_SPIKES,
    xi.effect.GALE_SPIKES,
    xi.effect.CLOD_SPIKES,
    xi.effect.GLINT_SPIKES,
    xi.effect.DAMAGE_SPIKES,
}

local enspells =
{
    xi.effect.ENFIRE,
    xi.effect.ENBLIZZARD,
    xi.effect.ENAERO,
    xi.effect.ENSTONE,
    xi.effect.ENTHUNDER,
    xi.effect.ENWATER,
    xi.effect.ENLIGHT,
    xi.effect.ENDARK,
}

local function effectPower(member, effectId)
    local effect = member:getStatusEffect(effectId)
    if not effect then
        return nil
    end

    return effect:getPower()
end

local function eclipticPowers()
    local cycleBuffs =
    {
        [xi.moonCycle.NEW_MOON]                = 1,
        [xi.moonCycle.LESSER_WAXING_CRESCENT]  = 5,
        [xi.moonCycle.GREATER_WAXING_CRESCENT] = 9,
        [xi.moonCycle.FIRST_QUARTER]           = 13,
        [xi.moonCycle.LESSER_WAXING_GIBBOUS]   = 17,
        [xi.moonCycle.GREATER_WAXING_GIBBOUS]  = 21,
        [xi.moonCycle.FULL_MOON]               = 25,
        [xi.moonCycle.GREATER_WANING_GIBBOUS]  = 21,
        [xi.moonCycle.LESSER_WANING_GIBBOUS]   = 17,
        [xi.moonCycle.THIRD_QUARTER]           = 13,
        [xi.moonCycle.GREATER_WANING_CRESCENT] = 9,
        [xi.moonCycle.LESSER_WANING_CRESCENT]  = 5,
    }

    local accuracy = cycleBuffs[getVanadielMoonCycle()] or 1
    return accuracy, 25 - accuracy
end

-- People standing in the avatar's ward circle. The trust in the back
-- is outside it, so that trust being unbuffed is not a reason to recast.
local function pactAllies(trust, radius)
    local allies = {}
    local avatar = Ixi20TrustGetAvatar and Ixi20TrustGetAvatar(trust) or nil
    local master = trust:getMaster()
    if not avatar or not avatar.isAlive or not avatar:isAlive() or not master then
        return allies
    end

    local party = master.getPartyWithTrusts and master:getPartyWithTrusts() or nil
    if not party then
        if master:isAlive() and avatar:checkDistance(master) <= radius then
            allies[1] = master
        end

        return allies
    end

    for _, member in pairs(party) do
        if member and member:isAlive() and avatar:checkDistance(member) <= radius then
            allies[#allies + 1] = member
        end
    end

    return allies
end

local function needsHeal(member, spring)
    if member:getHPP() < 95 then
        return true
    end

    if not spring then
        return false
    end

    for _, effectId in ipairs(springAilments) do
        if member:hasStatusEffect(effectId) then
            return true
        end
    end

    return false
end

local function lowestInjured(trust, spring)
    local best = nil
    local bestHp = 101
    for _, member in ipairs(pactAllies(trust, 20)) do
        if needsHeal(member, spring) and member:getHPP() < bestHp then
            best = member
            bestHp = member:getHPP()
        end
    end

    return best
end

-- 'gain' the pact would help them. 'safe' it would leave a stronger
-- buff alone. 'harm' the script deletes first and would wipe something
-- better, so the whole area is held.
local function wardOutcome(member, pact)
    local id = pact.id

    if id == xi.jobAbility.HEALING_RUBY or id == xi.jobAbility.HEALING_RUBY_II then
        if needsHeal(member, false) then
            return 'gain'
        end

        return 'safe'
    end

    if id == xi.jobAbility.SPRING_WATER then
        if needsHeal(member, true) then
            return 'gain'
        end

        return 'safe'
    end

    if id == xi.jobAbility.EARTHEN_WARD then
        if member:hasStatusEffect(xi.effect.STONESKIN) then
            return 'harm'
        end

        return 'gain'
    end

    if id == xi.jobAbility.HASTEGA then
        local have = effectPower(member, xi.effect.HASTE)
        -- Garuda is 1494. Haste is 1465. Haste II is 2998.
        if have == nil or have < 1494 then
            return 'gain'
        end

        return 'safe'
    end

    if id == xi.jobAbility.CRIMSON_HOWL then
        local have = effectPower(member, xi.effect.WARCRY)
        if have == nil or have < 9 then
            return 'gain'
        end

        return 'safe'
    end

    if id == xi.jobAbility.AERIAL_ARMOR then
        if member:hasStatusEffect(xi.effect.COPY_IMAGE) then
            return 'safe'
        end

        local have = effectPower(member, xi.effect.BLINK)
        if have == nil then
            return 'gain'
        end

        if have > 3 then
            return 'harm'
        end

        if have < 3 then
            return 'gain'
        end

        return 'safe'
    end

    if id == xi.jobAbility.FROST_ARMOR then
        for _, effectId in ipairs(spikeFamily) do
            if member:hasStatusEffect(effectId) then
                return 'harm'
            end
        end

        local have = effectPower(member, xi.effect.ICE_SPIKES)
        if have == nil or have < 15 then
            return 'gain'
        end

        if have > 15 then
            return 'harm'
        end

        return 'safe'
    end

    if id == xi.jobAbility.ROLLING_THUNDER then
        if member:hasStatusEffect(xi.effect.ENTHUNDER) then
            return 'safe'
        end

        for _, effectId in ipairs(enspells) do
            if member:hasStatusEffect(effectId) then
                return 'harm'
            end
        end

        return 'gain'
    end

    if id == xi.jobAbility.SHINING_RUBY then
        if member:hasStatusEffect(xi.effect.SHINING_RUBY) then
            return 'safe'
        end

        return 'gain'
    end

    if id == xi.jobAbility.ECLIPTIC_HOWL then
        local accuracy, evasion = eclipticPowers()
        local haveAccuracy = effectPower(member, xi.effect.ACCURACY_BOOST)
        local haveEvasion = effectPower(member, xi.effect.EVASION_BOOST)
        if (haveAccuracy and haveAccuracy > accuracy) or (haveEvasion and haveEvasion > evasion) then
            return 'harm'
        end

        if haveAccuracy == nil or haveAccuracy < accuracy or haveEvasion == nil or haveEvasion < evasion then
            return 'gain'
        end

        return 'safe'
    end

    return 'safe'
end

local function wardIsUseful(trust, pact)
    local gains = false
    for _, member in ipairs(pactAllies(trust, PACT_RADIUS)) do
        local outcome = wardOutcome(member, pact)
        if outcome == 'harm' then
            return false
        end

        if outcome == 'gain' then
            gains = true
        end
    end

    return gains
end

local function pactTarget(trust, pact)
    -- Healing Ruby is single target. The area wards recenter on the avatar.
    if pact.id == xi.jobAbility.HEALING_RUBY then
        return lowestInjured(trust, false)
    end

    if pact.ward then
        return trust
    end

    local foe = trust:getTarget()
    if foe and foe:isAlive() then
        return foe
    end

    local master = trust:getMaster()
    foe = master and master:getTarget() or nil
    if foe and foe:isAlive() then
        return foe
    end

    return nil
end

local function foeHasAll(foe, effects)
    for _, effectId in ipairs(effects) do
        if not foe:hasStatusEffect(effectId) then
            return false
        end
    end

    return true
end

local function pactIsUseful(trust, pact, target)
    if pact.id == xi.jobAbility.HEALING_RUBY then
        return target ~= nil
    end

    if pact.ward then
        return wardIsUseful(trust, pact)
    end

    local debuffs = debuffEffects[pact.id]
    if debuffs then
        return not foeHasAll(target, debuffs)
    end

    return true
end

-- Astral Flow scripts set the summoner's MP to 0. Put it back so the
-- black magic keeps going after Inferno, Diamond Dust, and the rest.
local function refillSummonerMp(trust)
    local maxMp = trust:getMaxMP()
    if maxMp > 0 and trust:getMP() < maxMp then
        trust:setMP(maxMp)
    end
end

local function rollFights(trust)
    trust:setLocalVar('ixi20FightsLeft', math.random(1, 3))
end

local function summonRosterAvatar(trust, roster, avIndex)
    if Ixi20TrustSummonAvatar then
        Ixi20TrustSummonAvatar(trust, roster[avIndex].id)
    end
end

-- The current foe died, or combat dropped. Either one spends a fight.
-- At zero the next avatar comes out and a fresh 1-3 is rolled.
local function completeFight(trust, roster)
    local left = trust:getLocalVar('ixi20FightsLeft')
    if left < 1 then
        left = 1
    end

    trust:setLocalVar('ixi20FightId', 0)
    if left <= 1 then
        local avIndex = trust:getLocalVar('ixi20AvIndex')
        if avIndex < 1 or avIndex > #roster then
            avIndex = 1
        end

        avIndex = avIndex % #roster + 1
        trust:setLocalVar('ixi20AvIndex', avIndex)
        trust:setLocalVar('ixi20PactIndex', 0)
        rollFights(trust)
        summonRosterAvatar(trust, roster, avIndex)
    else
        trust:setLocalVar('ixi20FightsLeft', left - 1)
    end
end

-- Only the player's own fight counts. A trust that is still in the
-- attack animation, or a pact with nobody to hit, must not burn a
-- fight and summon the next avatar while the player is standing around.
local function trackFights(trust, roster)
    if trust:getLocalVar('ixi20FightsLeft') < 1 then
        rollFights(trust)
    end

    local master = trust:getMaster()
    local foe = nil
    if master and master:isEngaged() then
        foe = master:getTarget()
        if foe and not foe:isAlive() then
            foe = nil
        end
    end

    local previous = trust:getLocalVar('ixi20FightId')
    if foe and foe:getID() ~= 0 then
        local foeId = foe:getID()
        if previous ~= 0 and previous ~= foeId then
            local old = GetEntityByID(previous)
            if not old or not old:isAlive() then
                completeFight(trust, roster)
            end
        end

        trust:setLocalVar('ixi20FightId', foeId)
    elseif previous ~= 0 then
        completeFight(trust, roster)
    end
end

local avatarTickEntry
local avatarEngageEntry

-- A blood pact replaces the attack state, so the avatar goes back to
-- standing on the trust. Put it on the mob again every second.
local function avatarEngage(trust)
    if not trust or not trust:isAlive() or not trust:getMaster() then
        return
    end

    trust:timer(1000, avatarEngageEntry)

    local roster = avatarRosters[trust:getTrustID()]
    if roster then
        trackFights(trust, roster)
    end

    local pet = Ixi20TrustGetAvatar and Ixi20TrustGetAvatar(trust) or nil
    if not pet or not pet:isAlive() then
        return
    end

    local master = trust:getMaster()
    local foe = master:isEngaged() and master:getTarget() or nil
    if (not foe or not foe:isAlive()) and trust:isEngaged() then
        foe = trust:getTarget()
    end

    if foe and foe:isAlive() then
        pet:setBattleID(foe:getBattleID())
        if not pet:isEngaged() then
            pet:engage(foe:getTargID())
        end
    elseif pet:isEngaged() then
        pet:disengage()
    end
end

local function avatarTick(trust)
    if not trust or not trust:isAlive() or not trust:getMaster() then
        return
    end

    local roster = avatarRosters[trust:getTrustID()]
    if not roster then
        return
    end

    local avIndex = trust:getLocalVar('ixi20AvIndex')
    -- Robel starts halfway down the same list so the two of them are
    -- not both on Carbuncle, casting the same blood pacts.
    if trust:getLocalVar('ixi20AvStagger') ~= 1 then
        trust:setLocalVar('ixi20AvStagger', 1)
        if trust:getTrustID() == 977 and avIndex <= 1 then
            avIndex = math.floor(#roster / 2) + 1
            trust:setLocalVar('ixi20AvIndex', avIndex)
            trust:setLocalVar('ixi20PactIndex', 1)
        end
    end

    if avIndex < 1 or avIndex > #roster then
        avIndex = trust:getTrustID() == 977 and (math.floor(#roster / 2) + 1) or 1
        trust:setLocalVar('ixi20AvIndex', avIndex)
    end

    if trust:getLocalVar('ixi20FightsLeft') < 1 then
        rollFights(trust)
    end

    summonRosterAvatar(trust, roster, avIndex)

    -- The trust does not keep PPet set. That link makes the avatar's
    -- update packet treat the trust as a player and crash the map.
    local pet = Ixi20TrustGetAvatar and Ixi20TrustGetAvatar(trust) or nil
    if not pet or not pet:isAlive() then
        trust:timer(3000, avatarTickEntry)
        return
    end

    local master = trust:getMaster()
    if master:isEngaged() then
        local foe = master:getTarget()
        if foe and foe:isAlive() then
            if not trust:isEngaged() then
                trust:engage(foe:getTargID())
            end

            if not pet:isEngaged() then
                pet:engage(foe:getTargID())
            end
        end
    end

    local pacts = roster[avIndex].pacts
    local start = trust:getLocalVar('ixi20PactIndex')
    if start < 1 or start > #pacts then
        start = 1
    end

    local chosen = nil
    local chosenTarget = nil
    local chosenIndex = start
    for step = 0, #pacts - 1 do
        local pactIndex = (start - 1 + step) % #pacts + 1
        local pact = pacts[pactIndex]
        local target = pactTarget(trust, pact)
        if target and pactIsUseful(trust, pact, target) then
            chosen = pact
            chosenTarget = target
            chosenIndex = pactIndex
            break
        end
    end

    if not chosen then
        trust:timer(8000, avatarTickEntry)
        return
    end

    -- Remember the next pact. The one just used is not chosen again
    -- until the rest of this avatar's list has been tried.
    trust:setLocalVar('ixi20PactIndex', chosenIndex % #pacts + 1)

    refillSummonerMp(trust)
    pet:usePetAbility(chosen.id, chosenTarget)
    trust:timer(8000, avatarTickEntry)
end

-- The timer keeps this wrapper. A file reload replaces the body on
-- xi.trust, so a trust that is already out picks up the new rules.
avatarTickEntry = function(trust)
    local tick = xi.trust._ixi20AvatarTick
    if tick then
        tick(trust)
    end
end

avatarEngageEntry = function(trust)
    local tick = xi.trust._ixi20AvatarEngage
    if tick then
        tick(trust)
    end
end

xi.trust._ixi20AvatarTick = avatarTick
xi.trust._ixi20AvatarEngage = avatarEngage

local function asHybridSummoner(mob)
    asCaster(mob)
    -- Kayeel's list is only ice and thunder. The normal nuke is held
    -- while a skillchain window is open, and the burst cast does nothing
    -- when the chain is not one of those elements. He was standing idle.
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 8)
    if mob:getLocalVar('ixi20SmnWatch') == 1 then
        return
    end

    mob:setLocalVar('ixi20SmnWatch', 1)
    mob:addListener('DESPAWN', 'IXI20_AVATAR_DESPAWN', function(mobArg)
        if Ixi20TrustReleaseAvatar then
            Ixi20TrustReleaseAvatar(mobArg)
        end
    end)
    mob:timer(1000, avatarTickEntry)
    mob:timer(1000, avatarEngageEntry)
end

local nukers =
{
    'gadalar', 'd_shantotto', 'kukki-chebukki', 'leonoyne',
    'rosulatia', 'teodor', 'ullegore', 'mumor_ii', 'aatt',
}
for _, name in ipairs(nukers) do
    openGates(name, asCaster)
end

openGates('kayeel-payeel', asHybridSummoner)
openGates('robel-akbel', asHybridSummoner)

local healers = { 'ingrid', 'ingrid_ii', 'pieuje_uc', 'ygnas' }
for _, name in ipairs(healers) do
    openGates(name, asHealer)
end

openGates('ovjang', function(mob)
    standToCast(mob)
    addNukes(mob)
    addEnfeebles(mob)
end)

openGates('king_of_hearts', function(mob)
    asHealer(mob)
    addNukes(mob)
end)

-- Samurai who also carry white magic. They stay in melee.
openGates('noillurie', addHeals)
openGates('iroha', function(mob)
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
end)
openGates('iroha_ii', function(mob)
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.PROTECT }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.PROTECTRA })
    mob:addGambit(ai.t.PARTY, { ai.c.NOT_STATUS, xi.effect.SHELL }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.SHELLRA })
    addNukes(mob)
end)

openGates('halver', function(mob)
    addHeals(mob)
    ja(mob, ai.t.TARGET, { ai.c.ALWAYS, 0 }, xi.ja.PROVOKE)
end)

openGates('zeid', function(mob)
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.DRAIN }, 15)
    mob:addGambit(ai.t.SELF, { ai.c.MPP_LT, 40 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.ASPIR }, 20)
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_MS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
    mob:addGambit(ai.t.TARGET, { ai.c.READYING_WS, 0 }, { ai.r.MA, ai.s.SPECIFIC, xi.magic.spell.STUN })
end)

openGates('balamor', function(mob)
    mob:addGambit(ai.t.TARGET, { ai.c.ALWAYS, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.ABSORB }, 30)
end)

local rangers = { 'najelith', 'elivira', 'margret', 'makki-chebukki', 'luzaf', 'cid' }
for _, name in ipairs(rangers) do
    openGates(name, asRanger)
end

-- Level-up happens before this hook, and the party list was already sent.
-- Raise trusts to the new level, then send the list again.
m:addOverride('xi.player.onPlayerLevelUp', function(player)
    super(player)

    if Ixi20TrustMatchMaster then
        Ixi20TrustMatchMaster(player)
    end

    local party = player:getPartyWithTrusts()
    if party then
        for _, member in pairs(party) do
            local master = member:isTrust() and member:getMaster() or nil
            if master and master:getID() == player:getID() then
                unlockWeaponskills(member)
            end
        end
    end

    player:reloadParty()
end)
