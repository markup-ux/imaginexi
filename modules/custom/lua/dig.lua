-----------------------------------
-- ImagineXI: !dig command for all mounts
-----------------------------------

require('modules/module_utils')
require('scripts/globals/hobbies/chocobo_digging/logic')

local m = Module:new('imaginexi_dig')

m:addOverride('xi.commands.dig.onTrigger', function(player)
    local gysahlGreens = 4545

    if not player:hasStatusEffect(xi.effect.MOUNTED) then
        player:printToPlayer('You must be mounted to dig.', xi.msg.channel.SYSTEM_3)
        return
    end

    if player:getItemCount(gysahlGreens) <= 0 then
        player:printToPlayer("You don't have any Gysahl Greens.", xi.msg.channel.SYSTEM_3)
        return
    end

    if xi.chocoboDig.start(player) then
        player:delItem(gysahlGreens, 1)
    end
end)

return m