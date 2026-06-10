-----------------------------------
-- RUN AF1 Quest NPC (GM Home / zone 210)
-- Moved from modules/custom/lua (zone script; avoids module loader timing).
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
        questName = 'Blade of the First Ward',
        var = 'ImagineXI_RUN_AF1_WEAPON',
        minLevel = 40,
        rewardItemId = 20776, -- Beorc Sword
        requiredItems =
        {
            { id = xi.item.FIRE_CRYSTAL, qty = 1 },
            { id = xi.item.ICE_CRYSTAL, qty = 1 },
            { id = xi.item.MYTHRIL_SWORD, qty = 1 },
        },
        requiredText = 'a fire crystal, an ice crystal, and a mythril sword',
        acceptedLore = 'A rune fencer\'s blade must learn restraint before power.',
        completionLine = 'This blade is now warded. Protect others before you seek glory.',
    },
    {
        questName = 'Steps of the Ward',
        var = 'ImagineXI_RUN_AF1_FEET',
        minLevel = 50,
        rewardItemId = 28347, -- Runeist Bottes
        requiredItems =
        {
            { id = xi.item.ICE_CRYSTAL, qty = 2 },
            { id = xi.item.IRON_INGOT, qty = 1 },
            { id = xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, qty = 1 },
        },
        requiredText = 'two ice crystals, an iron ingot, and a tiger leather',
        acceptedLore = 'Holding the line begins with footwork.',
        completionLine = 'A rune fencer must hold the line before drawing the blade.',
    },
    {
        questName = 'Grip of Resolve',
        var = 'ImagineXI_RUN_AF1_HANDS',
        minLevel = 50,
        rewardItemId = 28067, -- Runeist Mitons
        requiredItems =
        {
            { id = xi.item.FIRE_CRYSTAL, qty = 2 },
            { id = xi.item.MYTHRIL_INGOT, qty = 1 },
            { id = xi.item.SQUARE_OF_BLACK_TIGER_LEATHER, qty = 1 },
        },
        requiredText = 'two fire crystals, a mythril ingot, and a tiger leather',
        acceptedLore = 'The grip is about restraint, not violence.',
        completionLine = 'Strength is not in the swing. It is in the restraint before it.',
    },
    {
        questName = 'Stride Through Flame',
        var = 'ImagineXI_RUN_AF1_LEGS',
        minLevel = 50,
        rewardItemId = 28207, -- Runeist Trousers
        requiredItems =
        {
            { id = xi.item.LIGHTNING_CRYSTAL, qty = 1 },
            { id = xi.item.ICE_CRYSTAL, qty = 1 },
            { id = xi.item.DARKSTEEL_INGOT, qty = 1 },
        },
        requiredText = 'a lightning crystal, an ice crystal, and a darksteel ingot',
        acceptedLore = 'Movement lets a rune fencer answer danger before it arrives.',
        completionLine = 'Your movement must answer danger before danger arrives.',
    },
    {
        questName = 'Aegis Without Shield',
        var = 'ImagineXI_RUN_AF1_BODY',
        minLevel = 50,
        rewardItemId = 27927, -- Runeist Coat
        requiredItems =
        {
            { id = xi.item.LIGHT_CRYSTAL, qty = 1 },
            { id = xi.item.DARK_CRYSTAL, qty = 1 },
            { id = xi.item.ADAMAN_INGOT, qty = 1 },
        },
        requiredText = 'a light crystal, a dark crystal, and an adaman ingot',
        acceptedLore = 'A rune fencer becomes the shield even when no shield is held.',
        completionLine = 'A rune fencer is the shield even when no shield is held.',
    },
    {
        questName = 'Crown of the First Rune',
        var = 'ImagineXI_RUN_AF1_HEAD',
        minLevel = 50,
        rewardItemId = 27787, -- Runeist Bandeau
        requiredItems =
        {
            { id = xi.item.FIRE_CRYSTAL, qty = 1 },
            { id = xi.item.LIGHT_CRYSTAL, qty = 1 },
            { id = xi.item.MAHOGANY_LOG, qty = 1 },
        },
        requiredText = 'a fire crystal, a light crystal, and a mahogany log',
        acceptedLore = 'The final lesson is responsibility. The rune is not power. The rune is protection.',
        completionLine = 'Now you understand. The rune is not power. The rune is responsibility.',
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
        name = 'Octavien_IMAGINE_210',
        packetName = 'Octavien_IMAGINE',
        look = 3096,
        x = 2.0,
        y = 0.0,
        z = 0.0,
        rotation = 0,
        widescan = 1,

        onTrade = function(player, npc, trade)
            if player:getMainJob() ~= xi.job.RUN then
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
                player:printToPlayer('Octavien_IMAGINE: You need at least one free inventory slot.', 0x1F)
                return
            end

            player:tradeComplete()
            player:addItem(stage.rewardItemId)
            player:messageSpecial(ID.text.ITEM_OBTAINED, stage.rewardItemId)
            player:setCharVar(stage.var, QUEST_STATES.COMPLETED)
            player:printToPlayer('Octavien_IMAGINE: ' .. stage.completionLine, 0x1F)
        end,

        onTrigger = function(player, npc)
            if player:getMainJob() ~= xi.job.RUN then
                player:printToPlayer('Octavien_IMAGINE: Return as a Rune Fencer to begin your artifact training.', 0x1F)
                return
            end

            local stage = getCurrentStage(player)
            if stage == nil then
                player:printToPlayer('Octavien_IMAGINE: You have completed all Rune Fencer AF1 trials.', 0x1F)
                return
            end

            if player:getMainLvl() < stage.minLevel then
                player:printToPlayer('Octavien_IMAGINE: Reach level ' .. stage.minLevel .. ' on Rune Fencer for your next trial.', 0x1F)
                return
            end

            local stageState = player:getCharVar(stage.var)
            if stageState == QUEST_STATES.NOT_STARTED then
                player:setCharVar(stage.var, QUEST_STATES.ACCEPTED)
                player:printToPlayer('Octavien_IMAGINE: Quest accepted: ' .. stage.questName .. '.', 0x1F)
                player:printToPlayer('Octavien_IMAGINE: ' .. stage.acceptedLore, 0x1F)
                player:printToPlayer('Octavien_IMAGINE: Bring me ' .. stage.requiredText .. '.', 0x1F)
            else
                player:printToPlayer('Octavien_IMAGINE: ' .. stage.acceptedLore, 0x1F)
                player:printToPlayer('Octavien_IMAGINE: Bring me ' .. stage.requiredText .. '.', 0x1F)
            end
        end,
    })
end

return m
