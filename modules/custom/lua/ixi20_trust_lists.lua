-----------------------------------
-- Imagine XI 2.0: save the trusts you have out, and call a whole list at once.
--
-- !trusts                          trusts out, and every saved list
-- !trusts save <name>              save the trusts you have out
-- !trusts make <name> <trust>...   create a list by name
-- !trusts add <name> <trust>...    add trusts to a list
-- !trusts drop <name> <trust>      take one trust off a list
-- !trusts call <name>              dismiss yours and summon that list
-- !trusts delete <name>            forget a list
--
-- A list holds five trusts, the most a party of six can carry with you
-- in it. Call replaces the trusts you have out and brings the list up
-- together, with no cast time between them. Names are stored on the
-- character. Comment this file out in init.txt to turn the command off.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/trust')
-----------------------------------

local PREFIX    = '[trustlist]'
local MAX_LISTS = 12
local MAX_SLOTS = 5
local TRUST_GROUP = 8

local RESERVED =
{
    save   = true,
    make   = true,
    create = true,
    new    = true,
    add    = true,
    drop   = true,
    call   = true,
    summon = true,
    use    = true,
    delete = true,
    del    = true,
    remove = true,
    list   = true,
    lists  = true,
    help   = true,
}

-- Retail versions that refuse to stand in the same party.
local CONFLICT_PAIRS =
{
    { 'SHANTOTTO', 'SHANTOTTO_II' },
    { 'ZEID', 'ZEID_II' },
    { 'TENZEN', 'TENZEN_II' },
    { 'PRISHE', 'PRISHE_II' },
    { 'NASHMEIRA', 'NASHMEIRA_II' },
    { 'NAJA_SALAHEEM', 'NAJA_UC' },
    { 'MUMOR', 'MUMOR_II' },
    { 'MAAT', 'MAAT_UC' },
    { 'LILISETTE', 'LILISETTE_II' },
    { 'LION', 'LION_II' },
    { 'IROHA', 'IROHA_II' },
    { 'INGRID', 'INGRID_II' },
    { 'EXCENMILLE', 'EXCENMILLE_S' },
    { 'AYAME', 'AYAME_UC' },
    { 'ARCIELA', 'ARCIELA_II' },
    { 'ALDO', 'ALDO_UC' },
}

-- Shattering Stars and the other LB5 fights. Same set as trust.lua.
local ROV_BATTLEFIELDS =
{
    [5]    = true,
    [6]    = true,
    [7]    = true,
    [70]   = true,
    [71]   = true,
    [72]   = true,
    [101]  = true,
    [102]  = true,
    [103]  = true,
    [163]  = true,
    [194]  = true,
    [195]  = true,
    [196]  = true,
    [517]  = true,
    [518]  = true,
    [519]  = true,
    [530]  = true,
    [1091] = true,
    [1123] = true,
    [1154] = true,
}

local nameToId = nil
local idToLabel = nil
local conflicts = nil

local function say(player, text)
    player:printToPlayer(text, xi.msg.channel.SYSTEM_3)
end

local function normalize(text)
    text = tostring(text or ''):lower()
    text = text:gsub(',', ' ')
    text = text:gsub('[%(%)\'%.]', '')
    text = text:gsub('[_%-]', ' ')
    text = text:gsub('%s+', ' ')
    return (text:match('^%s*(.-)%s*$')) or ''
end

local function labelFromEnum(enumName)
    if enumName == 'EXCENMILLE_S' then
        return 'Excenmille (S)'
    end

    local words = {}
    for word in enumName:gmatch('[^_]+') do
        if word == 'II' or word == 'UC' then
            words[#words + 1] = word
        else
            words[#words + 1] = word:sub(1, 1) .. word:sub(2):lower()
        end
    end

    return table.concat(words, ' ')
end

local function addKey(key, spellId)
    if key ~= '' and type(spellId) == 'number' and nameToId[key] == nil then
        nameToId[key] = spellId
    end
end

local function ensureCatalog()
    if nameToId then
        return true
    end

    if type(GetSpell) ~= 'function' or not xi.magic or not xi.magic.spell then
        return false
    end

    nameToId = {}
    idToLabel = {}
    conflicts = {}

    for enumName, spellId in pairs(xi.magic.spell) do
        if type(enumName) == 'string' and type(spellId) == 'number' then
            local spell = GetSpell(spellId)
            if spell and spell.getSpellGroup and spell:getSpellGroup() == TRUST_GROUP and idToLabel[spellId] == nil then
                idToLabel[spellId] = labelFromEnum(enumName)
                local spaced = normalize(enumName)
                addKey(spaced, spellId)
                addKey(spaced:gsub(' ', ''), spellId)
                if spaced:find(' ii$') then
                    local stem = spaced:gsub(' ii$', '')
                    addKey(stem .. ' 2', spellId)
                    addKey(stem .. '2', spellId)
                end
            end
        end
    end

    addKey('d shantotto', xi.magic.spell.DOMINA_SHANTOTTO)
    addKey('dshantotto', xi.magic.spell.DOMINA_SHANTOTTO)
    addKey('i shield', xi.magic.spell.INVINCIBLE_SHIELD_UC)
    addKey('ishield', xi.magic.spell.INVINCIBLE_SHIELD_UC)
    addKey('invincible shield', xi.magic.spell.INVINCIBLE_SHIELD_UC)

    for _, pair in ipairs(CONFLICT_PAIRS) do
        local left = xi.magic.spell[pair[1]]
        local right = xi.magic.spell[pair[2]]
        if type(left) == 'number' and type(right) == 'number' then
            conflicts[left] = conflicts[left] or {}
            conflicts[right] = conflicts[right] or {}
            conflicts[left][right] = true
            conflicts[right][left] = true
        end
    end

    return true
end

local function trustLabel(spellId)
    ensureCatalog()
    return (idToLabel and idToLabel[spellId]) or tostring(spellId)
end

local function isTrustSpell(spellId)
    ensureCatalog()
    return idToLabel ~= nil and idToLabel[spellId] ~= nil
end

local function slotVar(name, slot)
    return string.format('%s%s/%d', PREFIX, name, slot)
end

local function readList(player, name)
    local ids = {}
    for slot = 1, MAX_SLOTS do
        local spellId = player:getCharVar(slotVar(name, slot))
        if spellId and spellId > 0 then
            ids[#ids + 1] = spellId
        end
    end

    return ids
end

local function writeList(player, name, ids)
    for slot = 1, MAX_SLOTS do
        player:setCharVar(slotVar(name, slot), ids[slot] or 0)
    end
end

local function savedNames(player)
    local seen = {}
    local vars = player:getCharVarsWithPrefix(PREFIX)
    if type(vars) ~= 'table' then
        return {}
    end

    for varName, value in pairs(vars) do
        if type(value) == 'number' and value > 0 then
            local listName = tostring(varName):match('^%[trustlist%]([%a][%w]*)/%d+$')
            if listName then
                seen[listName] = true
            end
        end
    end

    local names = {}
    for listName in pairs(seen) do
        names[#names + 1] = listName
    end

    table.sort(names)
    return names
end

local function formatIds(ids)
    local labels = {}
    for _, spellId in ipairs(ids) do
        labels[#labels + 1] = trustLabel(spellId)
    end

    if #labels == 0 then
        return 'none'
    end

    return table.concat(labels, ', ')
end

local function listName(token)
    if type(token) ~= 'string' or token == '' then
        return nil
    end

    local name = token:lower()
    if RESERVED[name] or not name:match('^%a[%w]*$') or #name > 16 then
        return nil
    end

    return name
end

local function conflictIn(ids)
    for index, spellId in ipairs(ids) do
        local blocked = conflicts and conflicts[spellId]
        if blocked then
            for other = 1, index - 1 do
                if blocked[ids[other]] then
                    return ids[other], spellId
                end
            end
        end
    end

    return nil, nil
end

local function parseTrusts(text)
    if not ensureCatalog() then
        return nil, 'Trust names are not loaded yet.'
    end

    local tokens = {}
    for token in tostring(text or ''):gmatch('%S+') do
        tokens[#tokens + 1] = token
    end

    if #tokens == 0 then
        return nil, 'Name the trusts. Example: !trusts make exp Kupipi Shantotto Valaineral'
    end

    local ids = {}
    local index = 1
    while index <= #tokens do
        local matched = nil
        local take = 1
        local window = math.min(6, #tokens - index + 1)
        for length = window, 1, -1 do
            local slice = {}
            for offset = 0, length - 1 do
                slice[#slice + 1] = tokens[index + offset]
            end

            local key = normalize(table.concat(slice, ' '))
            local spellId = nameToId[key] or nameToId[key:gsub(' ', '')]
            if not spellId and length == 1 and slice[1]:match('^%d+$') then
                local numeric = tonumber(slice[1])
                if isTrustSpell(numeric) then
                    spellId = numeric
                end
            end

            if spellId then
                matched = spellId
                take = length
                break
            end
        end

        if not matched then
            return nil, string.format('No trust named "%s".', tokens[index])
        end

        ids[#ids + 1] = matched
        index = index + take
    end

    return ids
end

local function rejectList(player, ids, learned)
    local seen = {}
    for _, spellId in ipairs(ids) do
        if not isTrustSpell(spellId) then
            say(player, string.format('%s is not a trust.', tostring(spellId)))
            return true
        end

        if seen[spellId] then
            say(player, string.format('%s is already on that list.', trustLabel(spellId)))
            return true
        end

        seen[spellId] = true

        if learned and not player:hasSpell(spellId) then
            say(player, string.format('You have not learned %s.', trustLabel(spellId)))
            return true
        end
    end

    if #ids > MAX_SLOTS then
        say(player, string.format('A list holds %d trusts.', MAX_SLOTS))
        return true
    end

    local left, right = conflictIn(ids)
    if left then
        say(player, string.format('%s and %s cannot share a list.', trustLabel(left), trustLabel(right)))
        return true
    end

    return false
end

local function ownTrusts(player)
    local ids = {}
    local playerId = player:getID()
    local party = player:getPartyWithTrusts() or {}

    for _, member in ipairs(party) do
        if member and member.getObjType and member:getObjType() == xi.objType.TRUST then
            local master = member.getMaster and member:getMaster() or nil
            if master and master.getID and master:getID() == playerId and member.getTrustID then
                local spellId = member:getTrustID()
                if spellId and spellId > 0 then
                    ids[#ids + 1] = spellId
                end
            end
        end
    end

    return ids
end

local function occupied(player)
    local count = 0
    for _, member in pairs(player:getPartyWithTrusts() or {}) do
        if member then
            count = count + 1
        end
    end

    if count < 1 then
        return 1
    end

    return count
end

local function slotsAfterDismiss(player)
    local playerId = player:getID()
    local count = 0
    for _, member in pairs(player:getPartyWithTrusts() or {}) do
        local ownTrust = false
        if member and member.getObjType and member:getObjType() == xi.objType.TRUST then
            local master = member.getMaster and member:getMaster() or nil
            ownTrust = master and master.getID and master:getID() == playerId
        end

        if member and not ownTrust then
            count = count + 1
        end
    end

    if count < 1 then
        count = 1
    end

    return math.max(0, 6 - count)
end

local function dismissOwn(player)
    local own = {}
    local playerId = player:getID()
    for _, member in pairs(player:getPartyWithTrusts() or {}) do
        if member and member.getObjType and member:getObjType() == xi.objType.TRUST then
            local master = member.getMaster and member:getMaster() or nil
            if master and master.getID and master:getID() == playerId then
                own[#own + 1] = member
            end
        end
    end

    if type(Ixi20TrustDismiss) == 'function' then
        for _, trust in ipairs(own) do
            Ixi20TrustDismiss(trust)
        end
        return
    end

    if #own > 0 and player.clearTrusts then
        player:clearTrusts()
    end
end

local function gmBypass(player)
    return player:getGMLevel() > 0 and player:getVisibleGMLevel() >= 3
end

local function battlefieldAllows(player)
    local battlefieldId = player.getBattlefieldID and player:getBattlefieldID() or 0
    if not battlefieldId or battlefieldId == 0 then
        return true
    end

    if ROV_BATTLEFIELDS[battlefieldId] then
        return player:hasKeyItem(xi.ki.RHAPSODY_IN_UMBER)
    end

    local contents = xi.battlefield and xi.battlefield.contents and xi.battlefield.contents[battlefieldId]
    if contents and not contents.allowTrusts then
        return false
    end

    return true
end

local function callBlocked(player)
    if xi.settings and xi.settings.main and xi.settings.main.ENABLE_TRUST_CASTING == 0 then
        return 'Trusts are turned off.'
    end

    if not player:isAlive() then
        return 'You cannot call trusts while unconscious.'
    end

    if gmBypass(player) then
        return nil
    end

    if player:checkSoloPartyAlliance() == 2 then
        return 'Trusts cannot be called from an alliance.'
    end

    local leader = player:getPartyLeader()
    if leader and leader.getID and player:getID() ~= leader:getID() then
        return 'Only the party leader can call trusts.'
    end

    if player:isSeekingParty() then
        return 'You cannot call trusts while seeking a party.'
    end

    local joined = player:getPartyLastMemberJoinedTime()
    if joined > 0 and GetSystemTime() - joined < 120 then
        return 'Wait a moment after someone joins the party.'
    end

    if player:hasEnmity() then
        return 'You cannot call trusts while in combat.'
    end

    if not battlefieldAllows(player) then
        return 'This fight does not allow trusts.'
    end

    return nil
end

local function finishSpawn(trust)
    if trust and xi.trust and type(xi.trust._ixi20FinishSpawn) == 'function' then
        xi.trust._ixi20FinishSpawn(trust)
        return
    end

    if trust and type(Ixi20TrustUnlockLv3Ws) == 'function' then
        Ixi20TrustUnlockLv3Ws(trust)
    end
end

local function usage(player)
    say(player, '!trusts save <name>            save the trusts you have out')
    say(player, '!trusts make <name> <trust>... create a list')
    say(player, '!trusts add <name> <trust>...  add to a list')
    say(player, '!trusts drop <name> <trust>    remove one trust')
    say(player, '!trusts call <name>            summon that list at once')
    say(player, '!trusts delete <name>          forget a list')
end

local function showOverview(player)
    local current = ownTrusts(player)
    say(player, 'Trusts out: ' .. formatIds(current))

    local names = savedNames(player)
    if #names == 0 then
        say(player, 'No saved lists. !trusts save <name> stores the trusts you have out.')
        return
    end

    for _, name in ipairs(names) do
        say(player, string.format('%s: %s', name, formatIds(readList(player, name))))
    end
end

local function saveCurrent(player, rest)
    local token = rest:match('^(%S+)$')
    local name = listName(token or '')
    if not name then
        say(player, 'Name the list with a word, up to 16 letters. Example: !trusts save exp')
        return
    end

    local ids = ownTrusts(player)
    if #ids == 0 then
        say(player, 'You have no trusts out to save.')
        return
    end

    if rejectList(player, ids, false) then
        return
    end

    local replacing = #readList(player, name) > 0
    if not replacing and #savedNames(player) >= MAX_LISTS then
        say(player, string.format('You already have %d lists. Delete one first.', MAX_LISTS))
        return
    end

    writeList(player, name, ids)
    if replacing then
        say(player, string.format('Replaced %s: %s.', name, formatIds(ids)))
    else
        say(player, string.format('Saved %s: %s.', name, formatIds(ids)))
    end
end

local function storeNew(player, name, ids, existed, label)
    if not existed and #savedNames(player) >= MAX_LISTS then
        say(player, string.format('You already have %d lists. Delete one first.', MAX_LISTS))
        return
    end

    writeList(player, name, ids)
    say(player, string.format('%s %s: %s.', label, name, formatIds(ids)))
end

local function makeList(player, rest)
    local token, trustText = rest:match('^(%S+)%s*(.*)$')
    local name = listName(token or '')
    if not name then
        say(player, 'Name the list, then the trusts. Example: !trusts make exp Kupipi Shantotto Valaineral')
        return
    end

    local ids, err = parseTrusts(trustText)
    if not ids then
        say(player, err)
        return
    end

    if rejectList(player, ids, true) then
        return
    end

    local existed = #readList(player, name) > 0
    storeNew(player, name, ids, existed, existed and 'Replaced' or 'Saved')
end

local function addToList(player, rest)
    local token, trustText = rest:match('^(%S+)%s*(.*)$')
    local name = listName(token or '')
    if not name then
        say(player, 'Name the list, then the trusts to add. Example: !trusts add exp Qultada')
        return
    end

    if trustText == '' then
        say(player, 'Name the trusts to add. Example: !trusts add exp Qultada')
        return
    end

    local extra, err = parseTrusts(trustText)
    if not extra then
        say(player, err)
        return
    end

    local ids = readList(player, name)
    for _, spellId in ipairs(extra) do
        ids[#ids + 1] = spellId
    end

    if rejectList(player, ids, true) then
        return
    end

    storeNew(player, name, ids, #readList(player, name) > 0, 'Saved')
end

local function dropFromList(player, rest)
    local token, trustText = rest:match('^(%S+)%s*(.*)$')
    local name = listName(token or '')
    if not name then
        say(player, 'Name the list and the trust. Example: !trusts drop exp Kupipi')
        return
    end

    if #readList(player, name) == 0 then
        say(player, string.format('No list named %s.', name))
        return
    end

    if trustText == '' then
        say(player, 'Name the trust to remove. Example: !trusts drop exp Kupipi')
        return
    end

    local extra, err = parseTrusts(trustText)
    if not extra or #extra ~= 1 then
        say(player, err or 'Name one trust to remove.')
        return
    end

    local removing = extra[1]
    local ids = {}
    local found = false
    for _, spellId in ipairs(readList(player, name)) do
        if spellId == removing and not found then
            found = true
        else
            ids[#ids + 1] = spellId
        end
    end

    if not found then
        say(player, string.format('%s is not on %s.', trustLabel(removing), name))
        return
    end

    writeList(player, name, ids)
    if #ids == 0 then
        say(player, string.format('Removed %s. List %s is gone.', trustLabel(removing), name))
    else
        say(player, string.format('%s: %s.', name, formatIds(ids)))
    end
end

local function deleteList(player, rest)
    local name = listName(rest:match('^(%S+)$') or '')
    if not name then
        say(player, 'Name the list. Example: !trusts delete exp')
        return
    end

    if #readList(player, name) == 0 then
        say(player, string.format('No list named %s.', name))
        return
    end

    writeList(player, name, {})
    say(player, string.format('Deleted %s.', name))
end

local function callList(player, rest)
    local name = listName(rest:match('^(%S+)$') or '')
    if not name then
        say(player, 'Name the list. Example: !trusts call exp')
        return
    end

    local ids = readList(player, name)
    if #ids == 0 then
        say(player, string.format('No list named %s.', name))
        return
    end

    if rejectList(player, ids, true) then
        return
    end

    local blocked = callBlocked(player)
    if blocked then
        say(player, blocked)
        return
    end

    local room = slotsAfterDismiss(player)
    if room < 1 then
        say(player, 'The party is full.')
        return
    end

    dismissOwn(player)

    local summoned = {}
    local leftOut = {}
    for _, spellId in ipairs(ids) do
        local battlefieldOk = not xi.trust.checkBattlefieldTrustCount or xi.trust.checkBattlefieldTrustCount(player)
        if #summoned >= room or occupied(player) >= 6 or not battlefieldOk then
            leftOut[#leftOut + 1] = spellId
        else
            local trust = player:spawnTrust(spellId)
            if trust then
                finishSpawn(trust)
                summoned[#summoned + 1] = spellId
            else
                leftOut[#leftOut + 1] = spellId
            end
        end
    end

    if #summoned == 0 then
        say(player, string.format('No room to call %s.', name))
        return
    end

    if player.getEminenceProgress and player:getEminenceProgress(932) and xi.roe and xi.roe.onRecordTrigger then
        xi.roe.onRecordTrigger(player, 932)
    end

    say(player, string.format('Called %s: %s.', name, formatIds(summoned)))
    if #leftOut > 0 then
        say(player, 'No room for ' .. formatIds(leftOut) .. '.')
    end
end

local commandObj = {}

commandObj.cmdprops =
{
    permission = 0,
    parameters = 's',
}

commandObj.onTrigger = function(player, arg)
    if not player or not player.isPC or not player:isPC() then
        return
    end

    local text = arg and tostring(arg) or ''
    text = text:match('^%s*(.-)%s*$') or ''
    if text == '' or text == 'list' or text == 'lists' then
        showOverview(player)
        return
    end

    if text == 'help' or text == '?' then
        usage(player)
        return
    end

    local verb, rest = text:match('^(%S+)%s*(.*)$')
    verb = verb and verb:lower() or ''
    rest = rest or ''

    if verb == 'save' then
        saveCurrent(player, rest)
    elseif verb == 'make' or verb == 'create' or verb == 'new' then
        makeList(player, rest)
    elseif verb == 'add' then
        addToList(player, rest)
    elseif verb == 'drop' then
        dropFromList(player, rest)
    elseif verb == 'call' or verb == 'summon' or verb == 'use' then
        callList(player, rest)
    elseif verb == 'delete' or verb == 'del' or verb == 'remove' then
        deleteList(player, rest)
    else
        local name = listName(verb)
        if name and rest == '' and #readList(player, name) > 0 then
            say(player, string.format('%s: %s.', name, formatIds(readList(player, name))))
            say(player, string.format('!trusts call %s summons them.', name))
            return
        end

        usage(player)
    end
end

xi.module.registerCommand('trusts', commandObj)

-- FileWatcher re-runs the file and then discards commandRegistry.
xi.commands = xi.commands or {}
xi.commands.trusts = commandObj
