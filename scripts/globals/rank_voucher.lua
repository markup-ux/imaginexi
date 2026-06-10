-----------------------------------
-- Nation rank Equipment Voucher logic
-----------------------------------
require('scripts/globals/rank_voucher_rewards')

xi = xi or {}
---@class xi.rankVoucher
xi.rank_voucher = xi.rank_voucher or {}

local rankVoucher = xi.rank_voucher

local JOB_KEYS =
{
    [xi.job.WAR] = 'WAR',
    [xi.job.MNK] = 'MNK',
    [xi.job.WHM] = 'WHM',
    [xi.job.BLM] = 'BLM',
    [xi.job.RDM] = 'RDM',
    [xi.job.THF] = 'THF',
    [xi.job.PLD] = 'PLD',
    [xi.job.DRK] = 'DRK',
    [xi.job.BST] = 'BST',
    [xi.job.BRD] = 'BRD',
    [xi.job.RNG] = 'RNG',
    [xi.job.SAM] = 'SAM',
    [xi.job.NIN] = 'NIN',
    [xi.job.DRG] = 'DRG',
    [xi.job.SMN] = 'SMN',
    [xi.job.BLU] = 'BLU',
    [xi.job.COR] = 'COR',
    [xi.job.PUP] = 'PUP',
    [xi.job.DNC] = 'DNC',
    [xi.job.SCH] = 'SCH',
    [xi.job.GEO] = 'SCH',
    [xi.job.RUN] = 'PLD',
}

---@param level integer
---@return integer
function rankVoucher.getLevelBracket(level)
    if level <= 10 then
        return 10
    elseif level <= 20 then
        return 20
    elseif level <= 30 then
        return 30
    elseif level <= 40 then
        return 40
    elseif level <= 50 then
        return 50
    elseif level <= 60 then
        return 60
    end

    return 75
end

---@param jobId integer
---@return string|nil
function rankVoucher.getJobKey(jobId)
    return JOB_KEYS[jobId]
end

---@param jobId integer
---@param bracket integer
---@return integer|nil
function rankVoucher.getRewardItemIdForJobBracket(jobId, bracket)
    local jobKey = rankVoucher.getJobKey(jobId)
    local rewards = jobKey and xi.rank_voucher_rewards[jobKey] or nil
    local itemId = rewards and rewards[bracket] or nil

    if not itemId then
        itemId = xi.rank_voucher_rewards.FALLBACK[bracket]
    end

    if itemId and GetReadOnlyItem(itemId) then
        return itemId
    end

    return nil
end

---@param player CBaseEntity
---@return integer|nil bracket
---@return integer|nil itemId
function rankVoucher.getRewardForPlayer(player)
    local jobId  = player:getMainJob()
    local level  = player:getMainLvl()
    local bracket = rankVoucher.getLevelBracket(level)
    local itemId = rankVoucher.getRewardItemIdForJobBracket(jobId, bracket)

    return bracket, itemId
end

---@param itemId integer
---@return string
function rankVoucher.describeItem(itemId)
    local item = GetReadOnlyItem(itemId)

    if item then
        return item:getName()
    end

    return string.format('item %u', itemId)
end

---@param player CBaseEntity
---@return string reason
function rankVoucher.getGrantFailureReason(player)
    local voucherId = xi.item.EQUIPMENT_VOUCHER

    if not GetReadOnlyItem(voucherId) then
        return 'item 2552 is not loaded (apply server/sql/z_imagine_xi_rank_voucher.sql and restart map)'
    end

    if player:getFreeSlotsCount() == 0 then
        return 'inventory has no free slots'
    end

    if player:hasItem(voucherId) then
        return 'already owns an Equipment Voucher (Rare item)'
    end

    return 'addItem failed for an unknown reason'
end

---@param player CBaseEntity
---@return boolean
function rankVoucher.grantVoucher(player)
    local voucherId = xi.item.EQUIPMENT_VOUCHER

    if not GetReadOnlyItem(voucherId) then
        return false
    end

    if player:getFreeSlotsCount() == 0 then
        return false
    end

    if player:hasItem(voucherId) then
        return false
    end

    return npcUtil.giveItem(player, voucherId) == true
end

---@param player CBaseEntity
---@return boolean
function rankVoucher.grantOnRankUp(player)
    return rankVoucher.grantVoucher(player)
end

---@param player CBaseEntity
---@return boolean
function rankVoucher.redeemVoucher(player)
    local _, rewardId = rankVoucher.getRewardForPlayer(player)

    if not rewardId then
        player:messageBasic(xi.msg.basic.ITEM_UNABLE_TO_USE)
        return false
    end

    if player:getFreeSlotsCount() == 0 then
        return false
    end

    if not player:addItem({ id = rewardId, quantity = 1, silent = true }) then
        return false
    end

    local ID = zones[player:getZoneID()]
    player:messageSpecial(ID.text.ITEM_OBTAINED, rewardId)

    return true
end

---@param player CBaseEntity
---@return string
function rankVoucher.formatPreview(player)
    local jobId   = player:getMainJob()
    local jobKey  = rankVoucher.getJobKey(jobId) or 'UNKNOWN'
    local level   = player:getMainLvl()
    local bracket = rankVoucher.getLevelBracket(level)
    local rewardId = rankVoucher.getRewardItemIdForJobBracket(jobId, bracket)

    if not rewardId then
        return string.format(
            '%s (%s Lv.%u) bracket %u -> no reward (missing table entry and fallback).',
            player:getName(),
            jobKey,
            level,
            bracket
        )
    end

    local source = 'job table'
    local rewards = xi.rank_voucher_rewards[jobKey]

    if not rewards or not rewards[bracket] then
        source = 'fallback'
    end

    return string.format(
        '%s (%s Lv.%u) bracket %u -> %s (%u) [%s]',
        player:getName(),
        jobKey,
        level,
        bracket,
        rankVoucher.describeItem(rewardId),
        rewardId,
        source
    )
end

return rankVoucher
