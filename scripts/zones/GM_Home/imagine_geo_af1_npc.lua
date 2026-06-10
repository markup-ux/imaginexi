-----------------------------------
-- GEO AF1 Quest NPC (GM Home / zone 210)
-- Moved from modules/custom/lua.
-----------------------------------
require('scripts/enum/item')

local ID = zones[xi.zone.GM_HOME]

local m = {}

local QUEST_STATES =
{
    NOT_STARTED = 0,
    ACCEPTED    = 1,
    COMPLETED   = 2,
}

local STAGES =
{
    {
        questName = 'Circle Without End',
        var = 'ImagineXI_GEO_AF1_WEAPON',
        minLevel = 40,
        rewardItemId = 21461, -- Filiae Bell
        requiredItems =
        {
            { id = xi.item.EARTH_CRYSTAL, qty = 1 },
            { id = xi.item.WIND_CRYSTAL, qty = 1 },
            { id = xi.item.PETRIFIED_LOG, qty = 1 },
        },
        requiredText = 'an earth crystal, a wind crystal, and a petrified log',
        acceptedLore = 'The land around Jeuno is unsettled. A geomancer must learn to listen before commanding the circle.',
        completionLine = 'The circle is complete. Carry this bell as proof that the land has answered you.',
    },
    {
        questName = 'Steps of the Land',
        var = 'ImagineXI_GEO_AF1_FEET',
        minLevel = 50,
        rewardItemId = 28346, -- Geomancy Sandals
        requiredItems =
        {
            { id = xi.item.EARTH_CRYSTAL, qty = 2 },
            { id = xi.item.SQUARE_OF_SHEEP_LEATHER, qty = 1 },
            { id = xi.item.ELM_LOG, qty = 1 },
        },
        requiredText = 'two earth crystals, a sheep leather, and an elm log',
        acceptedLore = 'A geomancer must feel the battlefield before casting.',
        completionLine = 'These sandals will help you feel the land beneath every step.',
    },
    {
        questName = 'Hands of Flow',
        var = 'ImagineXI_GEO_AF1_HANDS',
        minLevel = 50,
        rewardItemId = 28066, -- Geomancy Mitaines
        requiredItems =
        {
            { id = xi.item.WIND_CRYSTAL, qty = 2 },
            { id = xi.item.SPOOL_OF_SILK_THREAD, qty = 1 },
            { id = xi.item.SQUARE_OF_LINEN_CLOTH, qty = 1 },
        },
        requiredText = 'two wind crystals, a silk thread, and a linen cloth',
        acceptedLore = 'Geomancy must be guided, not forced.',
        completionLine = 'Your hands must guide the flow without forcing it.',
    },
    {
        questName = 'Lines of Balance',
        var = 'ImagineXI_GEO_AF1_LEGS',
        minLevel = 50,
        rewardItemId = 28206, -- Geomancy Pants
        requiredItems =
        {
            { id = xi.item.LIGHTNING_CRYSTAL, qty = 1 },
            { id = xi.item.EARTH_CRYSTAL, qty = 1 },
            { id = xi.item.MYTHRIL_INGOT, qty = 1 },
        },
        requiredText = 'a lightning crystal, an earth crystal, and a mythril ingot',
        acceptedLore = 'Balance is not stillness. A geomancer must move with changing energy.',
        completionLine = 'Balance is not stillness. It is motion held in harmony.',
    },
    {
        questName = 'Mantle of the Circle',
        var = 'ImagineXI_GEO_AF1_BODY',
        minLevel = 50,
        rewardItemId = 27926, -- Geomancy Tunic
        requiredItems =
        {
            { id = xi.item.WATER_CRYSTAL, qty = 1 },
            { id = xi.item.EARTH_CRYSTAL, qty = 1 },
            { id = xi.item.DARKSTEEL_INGOT, qty = 1 },
        },
        requiredText = 'a water crystal, an earth crystal, and a darksteel ingot',
        acceptedLore = 'The body piece anchors the geomancer at the center of the circle.',
        completionLine = 'This tunic will help you stand at the center of the storm.',
    },
    {
        questName = 'Crown of Resonance',
        var = 'ImagineXI_GEO_AF1_HEAD',
        minLevel = 50,
        rewardItemId = 27786, -- Geomancy Galero
        requiredItems =
        {
            { id = xi.item.FIRE_CRYSTAL, qty = 1 },
            { id = xi.item.LIGHT_CRYSTAL, qty = 1 },
            { id = xi.item.MAHOGANY_LOG, qty = 1 },
        },
        requiredText = 'a fire crystal, a light crystal, and a mahogany log',
        acceptedLore = 'The final lesson is resonance: when the land listens back.',
        completionLine = 'You are no longer only listening to the land. The land is listening back.',
    },
}

local function getCurrentStage(player)
    for _, stage in ipairs(STAGES) do
        if player:getCharVar(stage.var) ~= QUEST_STATES.COMPLETED then
            return stage
        end
    end

    return nil
end

local function tradeMatchesRequiredItems(trade, requiredItems)
    local totalRequiredCount = 0
    for _, requirement in ipairs(requiredItems) do
        totalRequiredCount = totalRequiredCount + requirement.qty
    end

    if trade:getItemCount() ~= totalRequiredCount then
        return false
    end

    for _, requirement in ipairs(requiredItems) do
        if not trade:hasItemQty(requirement.id, requirement.qty) then
            return false
        end
    end

    return true
end

local function requiredItemsTotalQty(requiredItems)
    local total = 0
    for _, requirement in ipairs(requiredItems) do
        total = total + requirement.qty
    end

    return total
end

local function printInvalidTradeHelp(player, npc, stage, trade)
    if trade:getItemCount() == 0 then
        return
    end

    local name = npc:getPacketName()
    local needQty = requiredItemsTotalQty(stage.requiredItems)
    local offeredQty = trade:getItemCount()

    if offeredQty ~= needQty then
        player:printToPlayer(string.format(
            '%s: Your trade is incomplete or has too many items. Put exactly %u items: %s.',
            name,
            needQty,
            stage.requiredText
        ), 0x1F)
    else
        player:printToPlayer(string.format(
            '%s: Those are not the materials I asked for. For this trial I need %s.',
            name,
            stage.requiredText
        ), 0x1F)
    end
end

function m.register(zone)
    zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = 'Sylvie_IMAGINE_210',
        packetName = 'Sylvie_IMAGINE',
        look = 3096,
        x = 0.0,
        y = 0.0,
        z = 0.0,
        rotation = 0,
        widescan = 1,

        onTrade = function(player, npc, trade)
            if player:getMainJob() ~= xi.job.GEO then
                return
            end

            local stage = getCurrentStage(player)
            if stage == nil or player:getMainLvl() < stage.minLevel then
                return
            end

            if player:getCharVar(stage.var) ~= QUEST_STATES.ACCEPTED then
                return
            end

            if not tradeMatchesRequiredItems(trade, stage.requiredItems) then
                printInvalidTradeHelp(player, npc, stage, trade)
                return
            end

            if player:getFreeSlotsCount() < 1 then
                player:printToPlayer('Sylvie_IMAGINE: You need at least one free inventory slot.', 0x1F)
                return
            end

            player:tradeComplete()
            player:addItem(stage.rewardItemId)
            player:messageSpecial(ID.text.ITEM_OBTAINED, stage.rewardItemId)
            player:setCharVar(stage.var, QUEST_STATES.COMPLETED)
            player:printToPlayer('Sylvie_IMAGINE: ' .. stage.completionLine, 0x1F)
        end,

        onTrigger = function(player, npc)
            if player:getMainJob() ~= xi.job.GEO then
                player:printToPlayer('Sylvie_IMAGINE: Return as a Geomancer to begin your artifact training.', 0x1F)
                return
            end

            local stage = getCurrentStage(player)
            if stage == nil then
                player:printToPlayer('Sylvie_IMAGINE: You have completed all Geomancer AF1 trials.', 0x1F)
                return
            end

            if player:getMainLvl() < stage.minLevel then
                player:printToPlayer('Sylvie_IMAGINE: Reach level ' .. stage.minLevel .. ' on Geomancer for your next trial.', 0x1F)
                return
            end

            local stageState = player:getCharVar(stage.var)
            if stageState == QUEST_STATES.NOT_STARTED then
                player:setCharVar(stage.var, QUEST_STATES.ACCEPTED)
                player:printToPlayer('Sylvie_IMAGINE: Quest accepted: ' .. stage.questName .. '.', 0x1F)
                player:printToPlayer('Sylvie_IMAGINE: ' .. stage.acceptedLore, 0x1F)
                player:printToPlayer('Sylvie_IMAGINE: Bring me ' .. stage.requiredText .. '.', 0x1F)
            else
                player:printToPlayer('Sylvie_IMAGINE: ' .. stage.acceptedLore, 0x1F)
                player:printToPlayer('Sylvie_IMAGINE: Bring me ' .. stage.requiredText .. '.', 0x1F)
            end
        end,
    })
end

return m
