-----------------------------------
-- ID: 2552 (retail Campaign Voucher slot; repurposed for ImagineXI)
-- Equipment Voucher
-- Grants one piece of equipment suited to your current job and level.
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    local _, rewardId = xi.rank_voucher.getRewardForPlayer(target)

    if not rewardId then
        return xi.msg.basic.ITEM_UNABLE_TO_USE
    end

    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    if not xi.rank_voucher.redeemVoucher(target) then
        -- Item is consumed after onItemUse; restore the voucher when redemption fails.
        target:addItem({ id = xi.item.EQUIPMENT_VOUCHER, quantity = 1, silent = true })
    end
end

return itemObject
