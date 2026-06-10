-----------------------------------
-- Race-tied quest / state reset (xi.player.onRaceChange)
--
-- When a player changes race we clear quest log entries, key items, and titles that are
-- keyed to race so they can redo content for the new race (e.g. a second full RSE set).
-- Inventory items (gear, mannequins, satchels) are not removed.
--
-- Covered: RSE (Goblin Tailor), mannequin quest line, Sacrarium Swift Belt hate.
-- Not reset: CoP orb cutscenes (race only affects CS), missions, battlefield-local vars,
--            party composition checks (e.g. Intermediate Teamwork).
-----------------------------------
xi.raceTiedQuestReset = xi.raceTiedQuestReset or {}

local function qPrefix(logId, questId)
    return string.format('Quest[%d][%d]', logId, questId)
end

-- Standard quests: strip vars + delQuest (clears ACCEPTED and COMPLETED).
local raceTiedStandardQuests =
{
    { logId = xi.questLog.JEUNO,        questId = xi.quest.id.jeuno.THE_GOBLIN_TAILOR },
    { logId = xi.questLog.OTHER_AREAS, questId = xi.quest.id.otherAreas.ITS_RAINING_MANNEQUINS },
    { logId = xi.questLog.OTHER_AREAS, questId = xi.quest.id.otherAreas.BEHIND_THE_SMILE },
    { logId = xi.questLog.OTHER_AREAS, questId = xi.quest.id.otherAreas.KNOCKING_ON_FORBIDDEN_DOORS },
}

-- Remove these if present (race / chain related).
local raceTiedKeyItems =
{
    xi.ki.MAGICAL_PATTERN,
    xi.ki.YE_OLDE_MANNEQUIN_CATALOGUE,
    xi.ki.MANNEQUIN_JOINT_DIAGRAMS,
    xi.ki.RED_OIL,
    xi.ki.MIRE_INCENSE,
    xi.ki.BETTER_HUMES_AND_MANNEQUINS,
}

local raceTiedTitles =
{
    xi.title.GOBLINS_EXCLUSIVE_FASHION_MANNEQUIN,
}

function xi.raceTiedQuestReset.onRaceChange(player)
    for _, ki in ipairs(raceTiedKeyItems) do
        if player:hasKeyItem(ki) then
            player:delKeyItem(ki)
        end
    end

    for _, titleId in ipairs(raceTiedTitles) do
        if player:hasTitle(titleId) then
            player:delTitle(titleId)
        end
    end

    for _, q in ipairs(raceTiedStandardQuests) do
        player:clearVarsWithPrefix(qPrefix(q.logId, q.questId))
        player:delQuest(q.logId, q.questId)
    end

    -- Swift Belt NMs: which draft accepts the codex is race-gated; hate was for the old race's route.
    player:setCharVar('FOMOR_HATE', 0)
end
