-----------------------------------
-- func: grantbis (player)
-- desc: Grants best-in-slot gear for the target's level, race, and main job
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 1,
    parameters = 's',
}

local function error(player, msg)
    player:printToPlayer(msg)
    player:printToPlayer('!grantbis (player)')
end

---@param player CBaseEntity
---@param targetName string|nil
---@return CBaseEntity|nil
local function resolveTarget(player, targetName)
    local cursorTarget = player:getCursorTarget()

    if targetName then
        local namedTarget = GetPlayerByName(targetName)
        if not namedTarget then
            error(player, string.format('Player named "%s" not found!', targetName))
            return nil
        end

        return namedTarget
    end

    if cursorTarget and cursorTarget:isPC() then
        return cursorTarget
    end

    return player
end

commandObj.onTrigger = function(player, target)
    local targ = resolveTarget(player, target)
    if not targ then
        return
    end

    local jobId   = targ:getMainJob()
    local jobName = 'JOB_' .. tostring(jobId)

    for name, id in pairs(xi.job) do
        if id == jobId and type(name) == 'string' then
            jobName = name
            break
        end
    end

    local level      = targ:getMainLvl()
    local savedLevel = targ:getJobLevel(jobId)

    if savedLevel > 0 and savedLevel ~= level and jobId == targ:getMainJob() then
        player:printToPlayer(string.format(
            'Syncing %s to saved %s level %u (session was %u).',
            targ:getName(),
            jobName,
            savedLevel,
            level
        ))
        targ:setLevel(savedLevel)
        level = savedLevel
    end

    if jobId == xi.job.NONE or level <= 0 then
        player:printToPlayer(string.format('%s has no main job level to gear for.', targ:getName()))
        return
    end

    local loadout, _ = xi.bis_gear.findLoadout(targ)
    local itemCount  = xi.bis_gear.countGrantable(targ, loadout)

    if itemCount == 0 then
        local ownedSlots = 0
        local emptySlots = 0
        local grantSlots = {
            xi.slot.MAIN, xi.slot.SUB, xi.slot.RANGED,
            xi.slot.HEAD, xi.slot.BODY, xi.slot.HANDS, xi.slot.LEGS, xi.slot.FEET,
            xi.slot.NECK, xi.slot.WAIST, xi.slot.EAR1, xi.slot.RING1, xi.slot.BACK,
        }
        for _, slot in ipairs(grantSlots) do
            local itemId = loadout[slot]
            if not itemId then
                emptySlots = emptySlots + 1
            elseif targ:getItemCount(itemId) > 0 then
                ownedSlots = ownedSlots + 1
            end
        end

        local hint = ''
        if emptySlots >= 4 then
            local probeId = loadout[xi.slot.MAIN] or 15147 -- garrison_sallet sanity check
            if not GetReadOnlyItem(probeId) then
                hint = ' Hint: item not loaded — re-import server/sql/item_basic.sql (or z_imagine_xi_bis_gear_item_basic.sql) and restart map.'
            end
        elseif emptySlots == 0 and ownedSlots > 0 then
            hint = ' Equipped gear counts as owned; unequip or use a mule to re-grant duplicates.'
        end

        player:printToPlayer(string.format(
            'No new BiS gear to grant %s (%s Lv.%u); already owned (%u slots) / no pick found (%u slots).%s',
            targ:getName(),
            jobName,
            level,
            ownedSlots,
            emptySlots,
            hint
        ))
        return
    end

    if targ:getFreeSlotsCount() < itemCount then
        player:printToPlayer(string.format(
            '%s needs at least %u free inventory slots (has %u).',
            targ:getName(),
            itemCount,
            targ:getFreeSlotsCount()
        ))
        return
    end

    player:printToPlayer(string.format(
        'Granting BiS gear to %s (%s Lv.%u, race %u)...',
        targ:getName(),
        jobName,
        level,
        targ:getRace()
    ))

    local granted, failed, messages, skipped = xi.bis_gear.grantLoadout(player, targ, loadout)

    for _, line in ipairs(messages) do
        player:printToPlayer(line)
    end

    player:printToPlayer(string.format(
        'Done: %u item(s) granted to %s%s%s.',
        granted,
        targ:getName(),
        skipped > 0 and string.format(' (%u skipped, already owned)', skipped) or '',
        failed > 0 and string.format(' (%u failed)', failed) or ''
    ))

    if targ:getID() ~= player:getID() then
        targ:printToPlayer(string.format('A GM granted you BiS gear for %s Lv.%u.', jobName, level))
    end
end

return commandObj
