-----------------------------------
-- White Mage Job Utilities
-----------------------------------
xi = xi or {}
xi.job_utils = xi.job_utils or {}
xi.job_utils.white_mage = xi.job_utils.white_mage or {}

local removables =
{
    xi.effect.FLASH,              xi.effect.BLINDNESS,      xi.effect.MAX_HP_DOWN,    xi.effect.MAX_MP_DOWN,
    xi.effect.PARALYSIS,          xi.effect.POISON,         xi.effect.CURSE_I,        xi.effect.CURSE_II,
    xi.effect.DISEASE,            xi.effect.PLAGUE,         xi.effect.WEIGHT,         xi.effect.BIND,
    xi.effect.BIO,                xi.effect.DIA,            xi.effect.BURN,           xi.effect.FROST,
    xi.effect.CHOKE,              xi.effect.RASP,           xi.effect.SHOCK,          xi.effect.DROWN,
    xi.effect.STR_DOWN,           xi.effect.DEX_DOWN,       xi.effect.VIT_DOWN,       xi.effect.AGI_DOWN,
    xi.effect.INT_DOWN,           xi.effect.MND_DOWN,       xi.effect.CHR_DOWN,       xi.effect.ADDLE,
    xi.effect.SLOW,               xi.effect.HELIX,          xi.effect.ACCURACY_DOWN,  xi.effect.ATTACK_DOWN,
    xi.effect.EVASION_DOWN,       xi.effect.DEFENSE_DOWN,   xi.effect.MAGIC_ACC_DOWN, xi.effect.MAGIC_ATK_DOWN,
    xi.effect.MAGIC_EVASION_DOWN, xi.effect.MAGIC_DEF_DOWN, xi.effect.MAX_TP_DOWN,    xi.effect.SILENCE,
    xi.effect.PETRIFICATION
}

-----------------------------------
-- Ability Check Functions
-----------------------------------
xi.job_utils.white_mage.checkAsylum = function(player, target, ability)
    ability:setRecast(math.max(0, ability:getRecast() - player:getMod(xi.mod.ONE_HOUR_RECAST) * 60))
    return 0, 0
end

xi.job_utils.white_mage.checkBenediction = function(player, target, ability)
    ability:setRecast(math.max(0, ability:getRecast() - player:getMod(xi.mod.ONE_HOUR_RECAST) * 60))
    return 0, 0
end

xi.job_utils.white_mage.checkDevotion = function(player, target, ability)
    if player:getID() == target:getID() then
        return xi.msg.basic.CANNOT_PERFORM_TARG, 0
    elseif player:getHP() < 4 then -- Fails if HP < 4
        return xi.msg.basic.UNABLE_TO_USE_JA, 0
    else
        return 0, 0
    end
end

xi.job_utils.white_mage.checkMartyr = function(player, target, ability)
    if player:getID() == target:getID() then
        return xi.msg.basic.CANNOT_PERFORM_TARG, 0
    elseif player:getHP() < 4 then -- Fails if HP < 4
        return xi.msg.basic.UNABLE_TO_USE_JA, 0
    else
        return 0, 0
    end
end

-----------------------------------
-- Ability Use Functions
-----------------------------------
xi.job_utils.white_mage.useAfflatusMisery = function(player, target, ability)
    target:delStatusEffect(xi.effect.AFFLATUS_SOLACE)
    target:delStatusEffect(xi.effect.AFFLATUS_MISERY)
    target:addStatusEffect(xi.effect.AFFLATUS_MISERY, { power = 8, duration = 7200, origin = player })

    return xi.effect.AFFLATUS_MISERY
end

xi.job_utils.white_mage.useAfflatusSolace = function(player, target, ability)
    target:delStatusEffect(xi.effect.AFFLATUS_SOLACE)
    target:delStatusEffect(xi.effect.AFFLATUS_MISERY)
    target:addStatusEffect(xi.effect.AFFLATUS_SOLACE, { power = 8, duration = 7200, origin = player })

    return xi.effect.AFFLATUS_SOLACE
end

xi.job_utils.white_mage.useAsylum = function(player, target, ability)
    target:addStatusEffect(xi.effect.ASYLUM, { power = 3, duration = 30, origin = player })

    return xi.effect.ASYLUM
end

xi.job_utils.white_mage.useBenediction = function(player, target, ability)
    -- To Do: Benediction can remove Charm only while in Assault Mission Lamia No.13
    for i, effect in ipairs(removables) do
        if target:hasStatusEffect(effect) then
            target:delStatusEffect(effect)
        end
    end

    local heal = (target:getMaxHP() * player:getMainLvl()) / target:getMainLvl()

    local maxHeal = target:getMaxHP() - target:getHP()

    if heal > maxHeal then
        heal = maxHeal
    end

    local power = 33 --chance to remove Doom. Basing off of Holy Water?

    if target:hasStatusEffect(xi.effect.DOOM) and power > math.random(1, 100) then
        target:delStatusEffect(xi.effect.DOOM)
    end

    player:updateEnmityFromCure(target, heal)
    target:addHP(heal)
    target:wakeUp()

    return heal
end

xi.job_utils.white_mage.useDevotion = function(player, target, ability, action)
    -- Plus 5 percent mp recovers per extra devotion merit
    local meritBonus = player:getMerit(xi.merit.DEVOTION) - 5
    local mpPercent  = (25 + meritBonus) / 100
    local damageHP   = math.floor(player:getHP() * 0.25)

    -- If stoneskin is present, it should absorb damage
    damageHP = utils.handleStoneskin(player, damageHP)

    local healMP = player:getHP() * mpPercent
    healMP = utils.clamp(healMP, 0, target:getMaxMP() - target:getMP())

    player:delHP(damageHP)
    target:addMP(healMP)

    return healMP
end

xi.job_utils.white_mage.useDivineCaress = function(player, target, ability)
    player:addStatusEffect(xi.effect.DIVINE_CARESS_I, { power = 3, duration = 60, origin = player })

    return xi.effect.DIVINE_CARESS_I
end

xi.job_utils.white_mage.useDivineSeal = function(player, target, ability)
    player:addStatusEffect(xi.effect.DIVINE_SEAL, { power = 1, duration = 60, origin = player })

    return xi.effect.DIVINE_SEAL
end

xi.job_utils.white_mage.useMartyr = function(player, target, ability, action)
    -- Plus 5 percent hp recovers per extra martyr merit
    local meritBonus = player:getMerit(xi.merit.MARTYR) - 5

    local hpPercent = (200 + meritBonus) / 100

    local damageHP = math.floor(player:getHP() * 0.25)

    --We need to capture this here because the base damage is the basis for the heal
    local healHP = damageHP * hpPercent
    healHP = utils.clamp(healHP, 0, target:getMaxHP() - target:getHP())

    -- If stoneskin is present, it should absorb damage
    damageHP = utils.handleStoneskin(player, damageHP)
    player:delHP(damageHP)
    target:addHP(healHP)

    return healHP
end

xi.job_utils.white_mage.useSacrosanctity = function(player, target, ability)
    target:addStatusEffect(xi.effect.SACROSANCTITY, { power = 3, duration = 60, origin = player })

    return xi.effect.SACROSANCTITY
end

-----------------------------------
-- Imagine XI: Healer TP spenders (JOB_AGNOSTIC_PARTY_SPEC.md)
-----------------------------------
local healerTpCosts =
{
    [xi.jobAbility.LUMINOUS_STRIKE]  = 500,
    [xi.jobAbility.RADIANT_SCISSION] = 1000,
    [xi.jobAbility.SACRED_CASCADE]   = 1000,
    [xi.jobAbility.DIVINE_RESONANCE] = 2000,
}

local function checkHealerTpCost(player, ability)
    local cost = healerTpCosts[ability:getID()]
    if not cost then
        return 0, 0
    end

    if player:getTP() < cost then
        return xi.msg.basic.NOT_ENOUGH_TP, 0
    end

    return 0, 0
end

local function spendHealerTp(player, ability)
    local cost = healerTpCosts[ability:getID()]
    if cost then
        player:delTP(cost)
    end
end

local function applySkillchainOpener(target, scType)
    if not target or not target:isMob() then
        return
    end

    target:delStatusEffect(xi.effect.SKILLCHAIN)
    target:addStatusEffect(xi.effect.SKILLCHAIN, { power = scType, tier = 0, duration = 10 })
end

xi.job_utils.white_mage.checkHealerTpAbility = function(player, target, ability)
    return checkHealerTpCost(player, ability)
end

xi.job_utils.white_mage.useLuminousStrike = function(player, target, ability, _action)
    spendHealerTp(player, ability)

    local dmg = 40 + player:getMainLvl() * 2 + player:getStat(xi.mod.MND)
    dmg = utils.clamp(dmg, 1, 999)

    local finalDmg = target:takeDamage(dmg, player, xi.attackType.MAGICAL, xi.damageType.LIGHT)
    player:updateEnmityFromDamage(target, finalDmg)

    return finalDmg
end

xi.job_utils.white_mage.useRadiantScission = function(player, target, ability, _action)
    spendHealerTp(player, ability)

    local dmg = 60 + player:getMainLvl() * 3 + player:getStat(xi.mod.MND)
    dmg = utils.clamp(dmg, 1, 999)

    local finalDmg = target:takeDamage(dmg, player, xi.attackType.MAGICAL, xi.damageType.LIGHT)
    player:updateEnmityFromDamage(target, finalDmg)
    applySkillchainOpener(target, xi.skillchainType.SCISSION)

    return finalDmg
end

xi.job_utils.white_mage.useSacredCascade = function(player, target, ability)
    spendHealerTp(player, ability)

    local party = player:getParty()
    if not party then
        return 0
    end

    local totalHeal = 0
    local curePotency = 80 + player:getMainLvl() * 3

    for _, member in pairs(party) do
        if member and member:isAlive() then
            local missing = member:getMaxHP() - member:getHP()
            local heal = utils.clamp(curePotency, 0, missing)
            if heal > 0 then
                member:addHP(heal)
                totalHeal = totalHeal + heal
            end

            for _, effect in ipairs(removables) do
                if member:hasStatusEffect(effect) then
                    member:delStatusEffect(effect)
                end
            end
        end
    end

    return totalHeal
end

xi.job_utils.white_mage.useDivineResonance = function(player, target, ability)
    spendHealerTp(player, ability)

    local party = player:getParty()
    if not party then
        return 0
    end

    for _, member in pairs(party) do
        if member and member:isAlive() then
            member:addStatusEffect(xi.effect.HASTE, { power = 1500, duration = 90, origin = player })
            member:addStatusEffect(xi.effect.REFRESH, { power = 3, duration = 90, origin = player })
        end
    end

    if target and target:isMob() and target:isAlive() then
        applySkillchainOpener(target, xi.skillchainType.REVERBERATION)
    end

    return 90
end
