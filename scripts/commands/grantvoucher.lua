-----------------------------------
-- func: grantvoucher [player]
-- desc: Grants one Equipment Voucher for rank-reward testing
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

local function usage(player)
    player:printToPlayer('!grantvoucher [player]')
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
        player:printToPlayer('[grantvoucher] rank_voucher globals not loaded.')
        return
    end

    local targ = resolveTarget(player, targetName)

    if not targ then
        usage(player)
        return
    end

    if xi.rank_voucher.grantVoucher(targ) then
        player:printToPlayer(string.format('Granted Equipment Voucher to %s.', targ:getName()))
    else
        local reason = xi.rank_voucher.getGrantFailureReason(targ)
        player:printToPlayer(string.format(
            '%s cannot receive the voucher: %s.',
            targ:getName(),
            reason or 'unknown error'
        ))
        player:printToPlayer(string.format(
            '  free slots: %u | has voucher: %s | item loaded: %s',
            targ:getFreeSlotsCount(),
            tostring(targ:hasItem(xi.item.EQUIPMENT_VOUCHER)),
            tostring(GetReadOnlyItem(xi.item.EQUIPMENT_VOUCHER) ~= nil)
        ))
    end
end

return commandObj
