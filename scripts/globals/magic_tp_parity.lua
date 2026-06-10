-----------------------------------
-- Imagine XI: Magic TP earn + Charged Spell spend (no client plugins required)
-- See: server/documentation/JOB_AGNOSTIC_PARTY_SPEC.md
-----------------------------------
require('scripts/globals/utils')

xi = xi or {}
xi.magicTp = xi.magicTp or {}

local removableDebuffs =
{
    xi.effect.FLASH,              xi.effect.BLINDNESS,      xi.effect.MAX_HP_DOWN,    xi.effect.MAX_MP_DOWN,
    xi.effect.PARALYSIS,          xi.effect.POISON,         xi.effect.CURSE_I,        xi.effect.CURSE_II,
    xi.effect.DISEASE,            xi.effect.PLAGUE,         xi.effect.WEIGHT,         xi.effect.BIND,
    xi.effect.BIO,                xi.effect.DIA,            xi.effect.BURN,           xi.effect.FROST,
    xi.effect.CHOKE,              xi.effect.RASP,           xi.effect.SHOCK,          xi.effect.DROWN,
    xi.effect.STR_DOWN,           xi.effect.DEX_DOWN,       xi.effect.VIT_DOWN,       xi.effect.AGI_DOWN,
    xi.effect.INT_DOWN,           xi.effect.MND_DOWN,       xi.effect.CHR_DOWN,       xi.effect.ADDLE,
    xi.effect.SLOW,             xi.effect.HELIX,          xi.effect.ACCURACY_DOWN,  xi.effect.ATTACK_DOWN,
    xi.effect.EVASION_DOWN,     xi.effect.DEFENSE_DOWN,   xi.effect.MAGIC_ACC_DOWN, xi.effect.MAGIC_ATK_DOWN,
    xi.effect.MAGIC_EVASION_DOWN, xi.effect.MAGIC_DEF_DOWN, xi.effect.MAX_TP_DOWN,    xi.effect.SILENCE,
    xi.effect.PETRIFICATION,
}

local nukeSkillchainByJob

local function getNukeSkillchainByJob()
    if nukeSkillchainByJob then
        return nukeSkillchainByJob
    end

    nukeSkillchainByJob =
    {
        [xi.job.BLM] = xi.skillchainType.IMPACTION,
        [xi.job.SCH] = xi.skillchainType.REVERBERATION,
        [xi.job.RDM] = xi.skillchainType.COMPRESSION,
        [xi.job.GEO] = xi.skillchainType.SCISSION,
        [xi.job.BLU] = xi.skillchainType.LIQUEFACTION,
    }

    return nukeSkillchainByJob
end

local nukeSkillchainByElement

local function getNukeSkillchainByElement()
    if nukeSkillchainByElement then
        return nukeSkillchainByElement
    end

    nukeSkillchainByElement =
    {
        [xi.element.FIRE]    = xi.skillchainType.LIQUEFACTION,
        [xi.element.ICE]     = xi.skillchainType.INDURATION,
        [xi.element.WIND]    = xi.skillchainType.DETONATION,
        [xi.element.EARTH]   = xi.skillchainType.SCISSION,
        [xi.element.THUNDER] = xi.skillchainType.IMPACTION,
        [xi.element.WATER]   = xi.skillchainType.REVERBERATION,
        [xi.element.LIGHT]   = xi.skillchainType.TRANSFIXION,
        [xi.element.DARK]    = xi.skillchainType.COMPRESSION,
    }

    return nukeSkillchainByElement
end

-- Skillchain opener for a charged nuke: dedicated mage mains keep their signature
-- property, otherwise fall back to the mage sub job, then to the spell's element.
local function getChargeSkillchain(caster, spell)
    local byJob  = getNukeSkillchainByJob()
    local scType = byJob[caster:getMainJob()] or byJob[caster:getSubJob()]

    if scType then
        return scType
    end

    local element = spell and spell:getElement() or xi.element.NONE

    return getNukeSkillchainByElement()[element]
end

local function toNumber(value, fallback)
    local number = tonumber(value)
    if number == nil then
        return fallback
    end

    return number
end

local defaultMapSettings =
{
    CHARGED_SPELL_ENABLED     = true,
    CHARGED_SPELL_TP_COST     = 1000,
    CHARGED_CURE_STONESKIN_RATIO     = 0.6,
    CHARGED_CURE_STONESKIN_FLOOR     = 150,
    CHARGED_CURE_STONESKIN_CAP       = 1000,
    CHARGED_CURE_STONESKIN_DURATION  = 60,
    CHARGED_CURE_PARTY_ESUNA_RANGE   = 10,
    CHARGED_CURE_ENMITY_RATIO        = 0.15,
    CHARGED_HYBRID_CURE_HEAL_MULT        = 1.3,
    CHARGED_HYBRID_CURE_STONESKIN_RATIO  = 0.4,
    CHARGED_HYBRID_CURE_STONESKIN_FLOOR  = 100,
    CHARGED_HYBRID_CURE_STONESKIN_CAP    = 500,
    CHARGED_HYBRID_CURE_STONESKIN_DURATION = 45,
    CHARGED_HYBRID_CURE_CLEANSE_RANGE    = 10,
    CHARGED_HYBRID_CURE_ENMITY_RATIO     = 0.15,
    CHARGED_NUKE_DAMAGE_MULT     = 1.5,
    CHARGED_NUKE_ENMITY_RATIO    = 0.15,
    CHARGED_NUKE_DOT_INT_RATIO   = 0.35,
    CHARGED_NUKE_DOT_FLOOR       = 4,
    CHARGED_NUKE_DOT_CAP         = 45,
    CHARGED_NUKE_DOT_DURATION    = 30,
    CHARGED_NUKE_DOT_TICK         = 3,
    MAGIC_TP_ENABLED             = true,
}

local function getMapSettings()
    if xi.settings and xi.settings.map then
        return xi.settings.map
    end

    return defaultMapSettings
end

local function isChargedSpellEnabled()
    local map = getMapSettings()
    return map.CHARGED_SPELL_ENABLED ~= false
end

local function getChargeTpCost()
    local map = getMapSettings()
    if map and map.CHARGED_SPELL_TP_COST then
        local cost = toNumber(map.CHARGED_SPELL_TP_COST, 1000)
        if cost > 0 then
            return cost
        end
    end

    return 1000
end

local function getChargedNukeMult()
    local map  = getMapSettings()
    local mult = toNumber(map.CHARGED_NUKE_DAMAGE_MULT, 1.5)
    if mult <= 0 then
        return 1.5
    end

    return mult
end

-- TP *earn* from magic stays gated to dedicated mage mains (mirrors C++ IsMagicTpEligibleJob);
-- melee jobs earn TP from swings. TP *spend* (Arcane Charge / Mend) is job-agnostic below.
local function isMagicTpEarnEligible(caster)
    if not caster or not caster:isPC() or not caster:isAlive() then
        return false
    end

    local map = getMapSettings()
    if map.MAGIC_TP_ENABLED == false then
        return false
    end

    local job = caster:getMainJob()
    return job == xi.job.BLM or job == xi.job.WHM or job == xi.job.RDM or job == xi.job.SMN or
        job == xi.job.SCH or job == xi.job.GEO or job == xi.job.BLU
end

local function isChargeCapablePc(caster)
    return caster ~= nil and caster:isPC() and caster:isAlive()
end

local function canSpendNukeCharge(caster)
    if not isChargeCapablePc(caster) or not isChargedSpellEnabled() then
        return false
    end

    return toNumber(caster:getTP(), 0) >= getChargeTpCost()
end

-- Dedicated hybrid mage mains: used for messaging only; any non-WHM job gets the Mend package.
local function isHybridMageMain(caster)
    local job = caster:getMainJob()
    return job == xi.job.SCH or job == xi.job.RDM or job == xi.job.GEO or job == xi.job.BLU
end

local function isSacredChargeJob(caster)
    return caster and caster:isPC() and caster:getMainJob() == xi.job.WHM
end

-- WHM main keeps the stronger Sacred Charge; every other job gets the lighter Arcane Mend.
local function isArcaneMendCaster(caster)
    return caster ~= nil and caster:isPC() and caster:getMainJob() ~= xi.job.WHM
end

local function canUseChargedCure(caster)
    if not isChargeCapablePc(caster) or not isChargedSpellEnabled() then
        return false
    end

    return toNumber(caster:getTP(), 0) >= getChargeTpCost()
end

local function isChargedHealingSpell(spell)
    if not spell then
        return false
    end

    local family = spell:getSpellFamily()
    return family == xi.magic.spellFamily.CURE
        or family == xi.magic.spellFamily.CURAGA
        or family == xi.magic.spellFamily.CURA
end

local function getHybridCureHealMult()
    local map  = getMapSettings()
    local mult = toNumber(map.CHARGED_HYBRID_CURE_HEAL_MULT, 1.3)
    if mult <= 0 then
        return 1.3
    end

    return mult
end

local function getChargedCureEnmityRatio(isHybrid)
    local map = getMapSettings()
    if isHybrid then
        return toNumber(map.CHARGED_HYBRID_CURE_ENMITY_RATIO, 0.15)
    end

    return toNumber(map.CHARGED_CURE_ENMITY_RATIO, 0.15)
end

local function applySacredChargeEffects(caster, target, healAmount, map, spendPartyEffects)
    local ratio    = (map and map.CHARGED_CURE_STONESKIN_RATIO) or 0.6
    local floorAmt = (map and map.CHARGED_CURE_STONESKIN_FLOOR) or 150
    local capAmt   = (map and map.CHARGED_CURE_STONESKIN_CAP) or 1000
    local duration = (map and map.CHARGED_CURE_STONESKIN_DURATION) or 60
    local absorb   = math.floor(utils.clamp(healAmount * ratio, floorAmt, capAmt))

    if absorb > 0 and not target:hasStatusEffect(xi.effect.STONESKIN) then
        target:addStatusEffect(xi.effect.STONESKIN, { power = absorb, duration = duration, origin = caster, tier = 0 })
    end

    if spendPartyEffects then
        local partyRange = (map and map.CHARGED_CURE_PARTY_ESUNA_RANGE) or 10
        for _, member in ipairs(partyMembersInRange(caster, partyRange)) do
            removeOneDebuff(member)
        end
    end
end

local function applyArcaneMendEffects(caster, target, healAmount, map, spendPartyEffects)
    local ratio    = (map and map.CHARGED_HYBRID_CURE_STONESKIN_RATIO) or 0.4
    local floorAmt = (map and map.CHARGED_HYBRID_CURE_STONESKIN_FLOOR) or 100
    local capAmt   = (map and map.CHARGED_HYBRID_CURE_STONESKIN_CAP) or 500
    local duration = (map and map.CHARGED_HYBRID_CURE_STONESKIN_DURATION) or 45
    local absorb   = math.floor(utils.clamp(healAmount * ratio, floorAmt, capAmt))

    if absorb > 0 and not target:hasStatusEffect(xi.effect.STONESKIN) then
        target:addStatusEffect(xi.effect.STONESKIN, { power = absorb, duration = duration, origin = caster, tier = 0 })
    end

    if spendPartyEffects then
        removeOneDebuff(caster)
        removeOneDebuff(target)
    end
end

local arcaneChargeDotCasterVar = 'magicTpArcaneChargeCasterId'
local chargeReadyNotifiedVar   = 'magicTpChargeReadyNotified'
local chargedCureArmedVar      = 'magicTpChargedCureArmed' -- 0 idle, 1 armed, 2 TP spent this cast

local function beginChargedCurePrepare(caster)
    local state = caster:getLocalVar(chargedCureArmedVar)

    -- Previous cast finished; a new charge is available.
    if state == 2 and canUseChargedCure(caster) then
        caster:setLocalVar(chargedCureArmedVar, 0)
        state = 0
    end

    if state == 1 or state == 2 then
        return true
    end

    if state == 0 and canUseChargedCure(caster) then
        caster:setLocalVar(chargedCureArmedVar, 1)
        return true
    end

    return false
end

local function spendChargedCureTpOnce(caster)
    if caster:getLocalVar(chargedCureArmedVar) ~= 1 then
        return false
    end

    caster:delTP(getChargeTpCost())
    caster:setLocalVar(chargedCureArmedVar, 2)
    caster:setLocalVar(chargeReadyNotifiedVar, 0)
    return true
end

-- Only chat-notify players who can actually cast a qualifying spell (main or sub job),
-- so pure melee jobs are not spammed every time they cross the TP threshold.
local chargeNotifyJobs

local function getChargeNotifyJobs()
    if chargeNotifyJobs then
        return chargeNotifyJobs
    end

    chargeNotifyJobs =
    {
        [xi.job.WHM] = true,
        [xi.job.BLM] = true,
        [xi.job.RDM] = true,
        [xi.job.PLD] = true,
        [xi.job.DRK] = true,
        [xi.job.NIN] = true,
        [xi.job.SMN] = true,
        [xi.job.BLU] = true,
        [xi.job.SCH] = true,
        [xi.job.GEO] = true,
    }

    return chargeNotifyJobs
end

local function canNotifyChargedReady(caster)
    if not isChargedSpellEnabled() or not isChargeCapablePc(caster) then
        return false
    end

    local jobs = getChargeNotifyJobs()

    return jobs[caster:getMainJob()] == true or jobs[caster:getSubJob()] == true
end

local function notifyCharge(caster, message)
    if caster and caster:isPC() then
        caster:printToPlayer(message, xi.msg.channel.SYSTEM)
    end
end

local function applySkillchainOpener(target, scType)
    if not target or not target:isMob() or not scType or scType == xi.skillchainType.NONE then
        return
    end

    local ok, err = pcall(function()
        target:delStatusEffect(xi.effect.SKILLCHAIN)
        target:addStatusEffect(xi.effect.SKILLCHAIN, { power = scType, tier = 0, duration = 10 })
    end)

    if not ok then
        print(string.format('[magic_tp_parity] skillchain opener failed: %s', tostring(err)))
    end
end

local function removeOneDebuff(target)
    for _, effectId in ipairs(removableDebuffs) do
        if target:hasStatusEffect(effectId) then
            target:delStatusEffect(effectId)
            return true
        end
    end

    return false
end

local function partyMembersInRange(caster, range)
    local members = {}
    local party   = caster:getParty()

    if not party then
        return members
    end

    for _, member in pairs(party) do
        if member and member:isAlive() and member:getZoneID() == caster:getZoneID() then
            if member:getID() == caster:getID() or member:checkDistance(caster) <= range then
                table.insert(members, member)
            end
        end
    end

    return members
end

-----------------------------------
-- DoT tick TP (helix and similar)
-----------------------------------
xi.magicTp.grantDotTickTp = function(caster)
    if not isMagicTpEarnEligible(caster) then
        return
    end

    local map = getMapSettings()
    local syntheticDelay = (map and map.MAGIC_TP_SYNTHETIC_DELAY) or 612
    local dotMult        = (map and map.MAGIC_TP_DOT_MULT) or 0.5
    local baseTp         = 61

    if xi.combat and xi.combat.tp and xi.combat.tp.calculateTPReturn then
        baseTp = xi.combat.tp.calculateTPReturn(caster, syntheticDelay) or baseTp
    end

    local tpGain = math.max(1, math.floor(baseTp / 2 * dotMult * (1 + caster:getMod(xi.mod.STORETP) / 100)))
    caster:addTP(tpGain)
end

-----------------------------------
-- Notify when TP crosses the charged-spell threshold (separate from proc-on-cast message).
-----------------------------------
xi.magicTp.onPlayerTpChanged = function(caster, prevTp)
    if not canNotifyChargedReady(caster) then
        return
    end

    local cost   = getChargeTpCost()
    local before = toNumber(prevTp, 0)
    local after  = toNumber(caster:getTP(), 0)

    if after < cost then
        caster:setLocalVar(chargeReadyNotifiedVar, 0)
        return
    end

    if before >= cost or caster:getLocalVar(chargeReadyNotifiedVar) == 1 then
        return
    end

    caster:setLocalVar(chargeReadyNotifiedVar, 1)

    if isSacredChargeJob(caster) then
        notifyCharge(caster, string.format(
            'Sacred Charge ready (%d TP): your next cure or curaga will auto-spend for shield and cleanse.',
            cost))
    elseif isHybridMageMain(caster) then
        notifyCharge(caster, string.format(
            'Arcane Charge ready (%d TP): your next damage or healing spell will auto-spend for a bonus effect.',
            cost))
    elseif getNukeSkillchainByJob()[caster:getMainJob()] then
        notifyCharge(caster, string.format(
            'Arcane Charge ready (%d TP): your next damaging spell will auto-spend for amplified power.',
            cost))
    else
        notifyCharge(caster, string.format(
            'Arcane Charge ready (%d TP): your next damaging or healing spell will auto-spend for a bonus effect, or hold your TP for a weapon skill.',
            cost))
    end
end

xi.magicTp.grantDotTickTpFromLocalVar = function(target, localVarName)
    if not target then
        return
    end

    local casterId = target:getLocalVar(localVarName)
    if casterId <= 0 then
        return
    end

    local caster = GetEntityByID(casterId)
    xi.magicTp.grantDotTickTp(caster)
end

xi.magicTp.clearCasterLocalVar = function(target, localVarName)
    if target then
        target:setLocalVar(localVarName, 0)
    end
end

-----------------------------------
-- Charged cure / curaga / cura (WHM main = Sacred Charge, every other job = Arcane Mend)
-- prepareChargedCure amplifies healing for the whole cast; applyChargedCureEffects spends TP once.
-----------------------------------
xi.magicTp.prepareChargedCure = function(caster, target, spell, healAmount)
    if not caster or not spell or healAmount <= 0 or not isChargedHealingSpell(spell) then
        return healAmount, false
    end

    if not isChargeCapablePc(caster) then
        return healAmount, false
    end

    if not beginChargedCurePrepare(caster) then
        return healAmount, false
    end

    if isArcaneMendCaster(caster) then
        local mult = getHybridCureHealMult()
        return math.max(1, math.floor(healAmount * mult)), true
    end

    -- WHM Sacred Charge: no heal amp, bonus effects only
    return healAmount, true
end

xi.magicTp.getChargedCureEnmity = function(caster, healAmount, willCharge)
    local amount = tonumber(healAmount) or 0

    if not willCharge or amount <= 0 then
        return amount
    end

    local enmityRatio = getChargedCureEnmityRatio(isArcaneMendCaster(caster))

    return math.max(0, math.floor(amount * enmityRatio))
end

xi.magicTp.applyChargedCureEffects = function(caster, target, spell, healAmount, willCharge)
    if not willCharge or not caster or not target or not spell then
        return
    end

    local map       = getMapSettings()
    local isHybrid  = isArcaneMendCaster(caster)
    local isSacred  = isSacredChargeJob(caster)
    local spentNow  = spendChargedCureTpOnce(caster)

    if spentNow then
        if isHybrid then
            notifyCharge(caster, 'Arcane Mend: your healing spell restores extra life and shields the wounded.')
        elseif isSacred then
            notifyCharge(caster, 'Sacred Charge: your cure shields the party and cleanses debuffs.')
        end
    end

    if isSacred then
        applySacredChargeEffects(caster, target, healAmount, map, spentNow)
    elseif isHybrid then
        applyArcaneMendEffects(caster, target, healAmount, map, spentNow)
    end
end

xi.magicTp.calculateArcaneChargeDotTick = function(caster)
    local map     = getMapSettings()
    local intStat = caster:getStat(xi.mod.INT)
    local ratio   = map.CHARGED_NUKE_DOT_INT_RATIO or 0.35
    local floorAmt = map.CHARGED_NUKE_DOT_FLOOR or 4
    local capAmt  = map.CHARGED_NUKE_DOT_CAP or 45

    return utils.clamp(math.floor(intStat * ratio), floorAmt, capAmt)
end

local function applyArcaneChargeDot(caster, target, spell)
    if not caster or not target or not target:isMob() or not spell then
        return
    end

    local map      = getMapSettings()
    local tickDmg  = xi.magicTp.calculateArcaneChargeDotTick(caster)
    local duration = map.CHARGED_NUKE_DOT_DURATION or 30
    local tick     = map.CHARGED_NUKE_DOT_TICK or 3
    local element  = spell:getElement() or xi.element.NONE

    target:setLocalVar(arcaneChargeDotCasterVar, caster:getID())
    target:addStatusEffect(xi.effect.ARCANE_CHARGE, {
        power = tickDmg,
        duration = duration,
        origin = caster,
        tick = tick,
        subPower = element,
    })
end

-----------------------------------
-- Any job: Charged nuke (1000 TP). Mage mains keep signature skillchain properties;
-- other jobs use their mage sub job's property, else the spell element's property.
-- prepareChargedNuke amplifies damage before takeSpellDamage; commitChargedNuke spends TP after.
-- Returns (damage, willCharge) from prepare; commit uses the same willCharge flag (no entity local vars).
-----------------------------------
xi.magicTp.prepareChargedNuke = function(caster, target, spell, damage, spellConnected)
    if not spellConnected or not spell or damage <= 0 then
        return damage, false
    end

    if spell.canTargetEnemy and not spell:canTargetEnemy() then
        return damage, false
    end

    if not canSpendNukeCharge(caster) then
        return damage, false
    end

    local mult = getChargedNukeMult()

    return math.max(1, math.floor(damage * mult)), true
end

xi.magicTp.getChargedNukeEnmity = function(finalDamage, willCharge)
    local damage = tonumber(finalDamage) or 0

    if not willCharge then
        return damage
    end

    local map = getMapSettings()
    local enmityRatio = toNumber(map.CHARGED_NUKE_ENMITY_RATIO, 0.15)

    return math.max(0, math.floor(damage * enmityRatio))
end

xi.magicTp.commitChargedNuke = function(caster, target, spell, finalDamage, willCharge)
    if not willCharge then
        return
    end

    caster:delTP(getChargeTpCost())

    notifyCharge(caster, 'Arcane Charge: your spell hits with amplified power, opens a skillchain, and leaves lingering arcane burns.')

    local scType = getChargeSkillchain(caster, spell)
    applySkillchainOpener(target, scType)

    local ok, err = pcall(applyArcaneChargeDot, caster, target, spell)
    if not ok and caster:isPC() then
        print(string.format('[magic_tp_parity] Arcane Charge DoT failed: %s', tostring(err)))
    end
end

-- Backward-compatible aliases for any stale reload paths.
xi.magicTp.applyChargedNuke = function(caster, target, spell, damage, spellConnected)
    return xi.magicTp.prepareChargedNuke(caster, target, spell, damage, spellConnected)
end

xi.magicTp.afterChargedNuke = function(caster, target, spell, finalDamage, willCharge)
    xi.magicTp.commitChargedNuke(caster, target, spell, finalDamage, willCharge == true)
end
