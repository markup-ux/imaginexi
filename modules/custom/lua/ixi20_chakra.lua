-----------------------------------
-- Imagine XI 2.0: Chakra clears every combat debuff, heals twice
-- the official HP amount, and restores that same amount of MP.
-- VIT, Monk level, Chakra gear, and Chakra job points still apply.
-- Weakness and encumbrance stay. Do not return this module.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_chakra')

local HEAL_MULTIPLIER = 2

-- Erasable / waltzable covers poison, para, blind, silence, slow, bind,
-- weight, disease, plague, curse, stat downs, dia, bio, stun, and the
-- elemental DoTs. These lack those flags but are still debuffs.
local EXTRA_DEBUFFS =
{
    xi.effect.SLEEP_I,
    xi.effect.SLEEP_II,
    xi.effect.LULLABY,
    xi.effect.PETRIFICATION,
    xi.effect.GRADUAL_PETRIFICATION,
    xi.effect.CHARM_I,
    xi.effect.CHARM_II,
    xi.effect.DOOM,
    xi.effect.AMNESIA,
    xi.effect.CURSE_II,
    xi.effect.INTIMIDATE,
    xi.effect.KAUSTRA,
    xi.effect.TERROR,
    xi.effect.MUTE,
    xi.effect.INHIBIT_TP,
    xi.effect.HELIX,
    xi.effect.THRENODY,
    xi.effect.NOCTURNE,
    xi.effect.DIRGE,
    xi.effect.AVOIDANCE_DOWN,
    xi.effect.DOUBT,
    xi.effect.ELEMENTALRES_DOWN,
    xi.effect.GEO_POISON,
    xi.effect.GEO_ATTACK_DOWN,
    xi.effect.GEO_DEFENSE_DOWN,
    xi.effect.GEO_MAGIC_ATK_DOWN,
    xi.effect.GEO_MAGIC_DEF_DOWN,
    xi.effect.GEO_ACCURACY_DOWN,
    xi.effect.GEO_EVASION_DOWN,
    xi.effect.GEO_MAGIC_ACC_DOWN,
    xi.effect.GEO_MAGIC_EVASION_DOWN,
    xi.effect.GEO_SLOW,
    xi.effect.GEO_PARALYSIS,
    xi.effect.GEO_WEIGHT,
}

local function stripEffect(player, effectId)
    local guard = 0
    while player:delStatusEffect(effectId) and guard < 32 do
        guard = guard + 1
    end
end

local function clearDebuffs(player)
    player:delStatusEffectsByFlag(xi.effectFlag.ERASABLE + xi.effectFlag.WALTZABLE, false)

    for _, effectId in ipairs(EXTRA_DEBUFFS) do
        stripEffect(player, effectId)
    end

    player:wakeUp()
end

local function chakraAmount(player, target)
    -- https://www.bg-wiki.com/ffxi/Chakra
    local monkLevel        = utils.getActiveJobLevel(player, xi.job.MNK)
    local jpModifier       = target:getJobPointLevel(xi.jp.CHAKRA_EFFECT)
    local hpModifier       = ((monkLevel + 1) * 0.2 / 100) * player:getMaxHP()
    local chakraMultiplier = 1 + player:getMod(xi.mod.CHAKRA_MULT) / 100
    local official         = (player:getStat(xi.mod.VIT) * 2 + hpModifier) * chakraMultiplier + jpModifier

    return math.floor(official * HEAL_MULTIPLIER)
end

m:addOverride('xi.job_utils.monk.useChakra', function(player, target, ability)
    clearDebuffs(player)

    local amount  = chakraAmount(player, target)
    local hpGain  = math.min(player:getMaxHP() - player:getHP(), amount)
    local mpRoom  = player:getMaxMP() - player:getMP()
    local mpGain  = math.min(mpRoom, amount)

    if hpGain > 0 then
        player:setHP(player:getHP() + hpGain)
    end

    if mpGain > 0 then
        player:messageBasic(xi.msg.basic.RECOVERS_MP, 0, player:addMP(mpGain))
    end

    local merits = player:getMerit(xi.merit.INVIGORATE)
    if merits > 0 then
        if player:hasStatusEffect(xi.effect.REGEN) then
            player:delStatusEffect(xi.effect.REGEN)
        end

        player:addStatusEffect(xi.effect.REGEN, { power = 10, duration = merits, origin = player, tier = 1 })
    end

    return hpGain
end)
