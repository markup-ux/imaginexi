-----------------------------------
-- Quest workarounds (moved from modules/custom/lua)
-- Loads after server.lua (zzz_ prefix) so xi.server.onServerStart exists.
-----------------------------------
require('modules/module_utils')

local super = xi.server.onServerStart

xi.server.onServerStart = function()
    super()

    xi.module.modifyInteractionEntry('scripts/quests/bastok/Wish_Upon_a_Star', function(quest)
        quest.sections[2][xi.zone.BASTOK_MARKETS]['Enu'].onTrade = function(player, npc, trade)
            local isNight = VanadielTOTD() == xi.time.NIGHT or VanadielTOTD() == xi.time.MIDNIGHT
            if npcUtil.tradeHasExactly(trade, xi.item.FALLEN_STAR) then
                if
                    player:getWeather() == xi.weather.NONE or
                    player:getWeather() == xi.weather.SUNSHINE and
                    isNight
                then
                    return quest:progressEvent(334)
                else
                    return quest:event(337)
                end
            end
        end
    end)
end
