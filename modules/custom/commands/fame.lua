-----------------------------------
-- func: fame
-- desc: Show your reputation (fame) in all fame areas
-----------------------------------
---@type TCommand
local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = '',
}

commandObj.onTrigger = function(player)
    local fameAreaNames = {}
    for name, value in pairs(xi.fameArea) do
        if type(value) == 'number' then
            fameAreaNames[value] = name
        end
    end

    player:printToPlayer(string.format('Fame report for %s:', player:getName()), xi.msg.channel.SYSTEM_3)

    for fameArea = 0, 15 do
        local areaName = fameAreaNames[fameArea] or ('AREA_' .. tostring(fameArea))
        local fame = player:getFame(fameArea)
        local fameLevel = player:getFameLevel(fameArea)
        player:printToPlayer(string.format('[%2u] %-22s Fame: %5u  Level: %u', fameArea, areaName, fame, fameLevel), xi.msg.channel.SYSTEM_3)
    end
end

return commandObj
