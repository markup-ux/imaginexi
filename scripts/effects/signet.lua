-----------------------------------
-- xi.effect.SIGNET
--   Signet is a a beneficial Status Effect that allows the acquisition of Conquest Points and Crystals
--   from defeated enemies that grant Experience Points.

--   Increased Healing HP
--   No TP loss while resting
--   Bonus experience earned in smaller parties
--   Increased defense and evasion against attacks from your auto-attack target when even match or lower
-----------------------------------
---@type TEffect
local effectObject = {}

local function applyFirstPlaceNationRewards(target, multiplier)
    target:addMod(xi.mod.EXP_BONUS, 10 * multiplier)

    target:addMod(xi.mod.WOOD, 2 * multiplier)
    target:addMod(xi.mod.SMITH, 2 * multiplier)
    target:addMod(xi.mod.GOLDSMITH, 2 * multiplier)
    target:addMod(xi.mod.CLOTH, 2 * multiplier)
    target:addMod(xi.mod.LEATHER, 2 * multiplier)
    target:addMod(xi.mod.BONE, 2 * multiplier)
    target:addMod(xi.mod.ALCHEMY, 2 * multiplier)
    target:addMod(xi.mod.COOK, 2 * multiplier)

    target:addMod(xi.mod.STR, 2 * multiplier)
    target:addMod(xi.mod.DEX, 2 * multiplier)
    target:addMod(xi.mod.VIT, 2 * multiplier)
    target:addMod(xi.mod.AGI, 2 * multiplier)
    target:addMod(xi.mod.INT, 2 * multiplier)
    target:addMod(xi.mod.MND, 2 * multiplier)
    target:addMod(xi.mod.CHR, 2 * multiplier)
end

local function shouldApplyFirstPlaceNationRewards(target)
    return GetNationRank(target:getNation()) == 1
end

local function refreshCraftSkillMenu(target)
    target:refreshCharSkills()
end

effectObject.onEffectGain = function(target, effect)
    target:addLatent(xi.latent.SIGNET_BONUS, 0, xi.mod.DEF, 15)
    target:addLatent(xi.latent.SIGNET_BONUS, 0, xi.mod.EVA, 15)

    local shouldApply = shouldApplyFirstPlaceNationRewards(target)
    target:setLocalVar('SIGNET_NATION_REWARD_ACTIVE', shouldApply and 1 or 0)

    if shouldApply then
        applyFirstPlaceNationRewards(target, 1)
        refreshCraftSkillMenu(target)
        target:printToPlayer('Nation Reward active: +10% EXP, +2 all crafts, +2 all attributes.', xi.msg.channel.SYSTEM_3)
    end
end

effectObject.onEffectTick = function(target, effect)
    local currentlyApplied = target:getLocalVar('SIGNET_NATION_REWARD_ACTIVE') == 1
    local shouldApply      = shouldApplyFirstPlaceNationRewards(target)

    if shouldApply and not currentlyApplied then
        applyFirstPlaceNationRewards(target, 1)
        target:setLocalVar('SIGNET_NATION_REWARD_ACTIVE', 1)
        refreshCraftSkillMenu(target)
    elseif currentlyApplied and not shouldApply then
        applyFirstPlaceNationRewards(target, -1)
        target:setLocalVar('SIGNET_NATION_REWARD_ACTIVE', 0)
        refreshCraftSkillMenu(target)
    end
end

effectObject.onEffectLose = function(target, effect)
    target:delLatent(xi.latent.SIGNET_BONUS, 0, xi.mod.DEF, 15)
    target:delLatent(xi.latent.SIGNET_BONUS, 0, xi.mod.EVA, 15)

    if target:getLocalVar('SIGNET_NATION_REWARD_ACTIVE') == 1 then
        applyFirstPlaceNationRewards(target, -1)
        refreshCraftSkillMenu(target)
    end

    target:setLocalVar('SIGNET_NATION_REWARD_ACTIVE', 0)
end

return effectObject
