-----------------------------------
-- Area: Port San d'Oria
--  NPC: Regine
-- !pos 68 -9 -74 232
-----------------------------------
---@type TNpcEntity
local entity = {}

entity.onTrade = function(player, npc, trade)
    local flyersForRegine = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.FLYERS_FOR_REGINE)

    -- FLYERS FOR REGINE
    if
        flyersForRegine == xi.questStatus.QUEST_ACCEPTED and
        npcUtil.tradeHas(trade, { { 'gil', 10 } })
    then
        if npcUtil.giveItem(player, xi.item.MAGICMART_FLYER) then
            player:confirmTrade()
        end
    end
end

entity.onTrigger = function(player, npc)
    local ffr = player:getQuestStatus(xi.questLog.SANDORIA, xi.quest.id.sandoria.FLYERS_FOR_REGINE)

    -- FLYERS FOR REGINE
    if ffr == xi.questStatus.QUEST_AVAILABLE then -- ready to accept quest
        player:startEvent(510, 2)
    elseif
        ffr == xi.questStatus.QUEST_ACCEPTED and
        utils.mask.isFull(player:getCharVar('[ffr]deliveryMask'), 15)
    then
        -- all 15 flyers delivered
        player:startEvent(603)
    elseif
        ffr == xi.questStatus.QUEST_ACCEPTED and
        not player:hasItem(xi.item.MAGICMART_FLYER)
    then -- on quest but out of flyers
        player:startEvent(510, 3)

    -- DEFAULT MENU
    else
        player:startEvent(510)
    end
end

entity.onEventFinish = function(player, csid, option, npc)
    -- FLYERS FOR REGINE
    if csid == 510 and option == 2 then
        if npcUtil.giveItem(player, { { xi.item.MAGICMART_FLYER, 1 }, { xi.item.MAGICMART_FLYER, 14 } })  then
            player:addQuest(xi.questLog.SANDORIA, xi.quest.id.sandoria.FLYERS_FOR_REGINE)
        end
    elseif csid == 603 then
        npcUtil.completeQuest(
            player, xi.questLog.SANDORIA, xi.quest.id.sandoria.FLYERS_FOR_REGINE,
            {
                gil = 440,
                title = xi.title.ADVERTISING_EXECUTIVE,
                var = '[ffr]deliveryMask',
            }
        )

    -- WHITE MAGIC SHOP
    elseif csid == 510 and option == 0 then
        local stockA =
        {
        }
        xi.shop.nation(player, stockA, xi.nation.SANDORIA)

    -- BLACK MAGIC SHOP
    elseif csid == 510 and option == 1 then
        local stockB =
        {
        }
        xi.shop.nation(player, stockB, xi.nation.SANDORIA)
    end
end

return entity
