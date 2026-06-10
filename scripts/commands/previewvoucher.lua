-----------------------------------
-- func: previewvoucher [player]
-- desc: Shows which gear item an Equipment Voucher would grant
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

local function usage(player)
    player:printToPlayer('!previewvoucher [player]')
end

---@param player CBaseEntity
---@param targetName string|nil
---@return CBaseEntity|nil
local function resolveTarget(player, targetName)
    if targetName then
        local namedTarget = GetPlayerByName(targetName)

        if not namedTarget then
            player:printToPlayer(string.format('Player named "%s" not found!', targetName))
            return nil
        end

        return namedTarget
    end

    local cursorTarget = player:getCursorTarget()

    if cursorTarget and cursorTarget:isPC() then
        return cursorTarget
    end

    return player
end

commandObj.onTrigger = function(player, targetName)
    if not xi.rank_voucher then
        player:printToPlayer('[previewvoucher] rank_voucher globals not loaded.')
        return
    end

    local targ = resolveTarget(player, targetName)

    if not targ then
        usage(player)
        return
    end

    player:printToPlayer(xi.rank_voucher.formatPreview(targ), xi.msg.channel.SYSTEM_3)

    for _, bracket in ipairs({ 10, 20, 30, 40, 50, 60, 75 }) do
        local itemId = xi.rank_voucher.getRewardItemIdForJobBracket(targ:getMainJob(), bracket)

        if itemId then
            player:printToPlayer(string.format(
                '  bracket %u -> %s (%u)',
                bracket,
                xi.rank_voucher.describeItem(itemId),
                itemId
            ), xi.msg.channel.SYSTEM_3)
        else
            player:printToPlayer(string.format('  bracket %u -> (none)', bracket), xi.msg.channel.SYSTEM_3)
        end
    end
end

return commandObj
