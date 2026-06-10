-----------------------------------
-- Multi-currency exchange (beside conquest / signet guards)
--
-- Design:
--   • Spawns "Exchange" when a player uses a conquest overseer (unchanged).
--   • Economy: one integer weight per asset; 1 Conquest Point = 1 on that scale.
--   • UI: customMenu only — short mTag labels (no parentheses) to match client
--     Result strings reliably; full names + CP weights print to chat.
--   • Fresh menu table per step. Never call customMenu synchronously from inside a menu
--     option handler — HandleCustomMenu is still active and re-entering SetCustomMenuContext
--     can throw (see scripts/commands/menu_paginated.lua). Use a short player:timer defer.
--   • Engine: HandleCustomMenu only erases context when it is still the same Lua table
--     (supports nested menus if you ever open one synchronously elsewhere).
--
-- No exchange fee — only integer rounding dust.
--
-- Gil: kind 'gil' uses inventory currency slot (getGil/addGil/delGil). weight = CP value of 1 gil
-- on the same ladder (100 => ~100 CP per 1 gil when converting gil->CP; ~1 gil per 100 CP the other way).
--
-- ASSETS order (hybrid): signet-adjacent + RoE first, then expansion-era blocks (CoP -> ToAU -> WotG).
-----------------------------------

require('modules/module_utils')
require('scripts/globals/conquest')
require('scripts/enum/item')

local m = Module:new('cp_exchange_signet_buddy')

-- Upper bound for gil received in one trade (engine stack / sane cap).
local GIL_CAP = 999999999

local ASSETS =
{
    -- Signet / book traffic first
    { id = 'cp',      mTag = 'CP',       label = 'Conquest Points', kind = 'cp',        weight = 1 },
    { id = 'sparks',  mTag = 'Sparks',   label = 'Sparks of Eminence (RoE)', kind = 'currency', key = 'spark_of_eminence', cap = 'CAP_CURRENCY_SPARKS', weight = 5 },
    { id = 'tabs',    mTag = 'Tabs',     label = 'Book Tabs (Valor)', kind = 'currency', key = 'valor_point', cap = 'CAP_CURRENCY_VALOR', weight = 5 },
    { id = 'gil',     mTag = 'Gil',      label = 'Gil', kind = 'gil', weight = 100 },
    -- CoP-era
    { id = 'beast',   mTag = 'Beast',    label = 'Ancient beastcoin (Limbus)', kind = 'currency', key = 'ancient_beastcoin', weight = 5 },
    { id = 'byne',    mTag = 'Byne',     label = 'Byne Bill',      kind = 'item', itemId = xi.item.ONE_BYNE_BILL,         weight = 50 },
    { id = 'obronze', mTag = 'O-Bronze', label = 'O. Bronzepiece', kind = 'item', itemId = xi.item.ORDELLE_BRONZEPIECE,   weight = 50 },
    { id = 'twhite',  mTag = 'T-White',  label = 'T. Whiteshell',  kind = 'item', itemId = xi.item.TUKUKU_WHITESHELL,     weight = 50 },
    { id = '100byne', mTag = 'Byne100',  label = '100 Byne Bill',  kind = 'item', itemId = xi.item.ONE_HUNDRED_BYNE_BILL, weight = 5000 },
    { id = 'msilver', mTag = 'M-Silver', label = 'M. Silverpiece', kind = 'item', itemId = xi.item.MONTIONT_SILVERPIECE,  weight = 5000 },
    { id = 'ljade',   mTag = 'L-Jade',   label = 'L. Jadeshell',   kind = 'item', itemId = xi.item.LUNGO_NANGO_JADESHELL, weight = 5000 },
    -- ToAU-era
    { id = 'imperial', mTag = 'Imp',     label = 'Imperial standing', kind = 'currency', key = 'imperial_standing', weight = 1 },
    { id = 'leujao',  mTag = 'Asm-LJ',   label = 'Leujaoam assault points', kind = 'currency', key = 'leujaoam_assault_point', weight = 1 },
    { id = 'mamool',  mTag = 'Asm-MM',   label = 'Mamool Ja assault points', kind = 'currency', key = 'mamool_assault_point', weight = 1 },
    { id = 'lebros',  mTag = 'Asm-LB',   label = 'Lebros assault points', kind = 'currency', key = 'lebros_assault_point', weight = 1 },
    { id = 'periqia', mTag = 'Asm-PQ',   label = 'Periqia assault points', kind = 'currency', key = 'periqia_assault_point', weight = 1 },
    { id = 'ilrusi',  mTag = 'Asm-IL',   label = 'Ilrusi assault points', kind = 'currency', key = 'ilrusi_assault_point', weight = 1 },
    { id = 'nyzul',   mTag = 'Nyzul',    label = 'Nyzul Isle assault points', kind = 'currency', key = 'nyzul_isle_assault_point', weight = 1 },
    { id = 'zeni',    mTag = 'Zeni',     label = 'Zeni (ZNM)', kind = 'currency', key = 'zeni_point', weight = 1 },
    { id = 'alex',    mTag = 'Alex',     label = 'Alexandrite', kind = 'item', itemId = xi.item.ALEXANDRITE, weight = 60 },
    -- WotG-era
    { id = 'allied',  mTag = 'Allied',   label = 'Allied notes', kind = 'currency', key = 'allied_notes', weight = 1 },
}

local UNITS_CHOICES  = { 1, 10, 50, 99, 100, 250, 500, 1000, 2500, 5000 }
local UNITS_PER_PAGE = 2
local MENU_PAGE      = 4

-- Let HandleCustomMenu finish before the next SetCustomMenuContext (avoids C++ exceptions).
local MENU_DELAY_MS  = 100

local currentNpc = nil

local function openMenu(player, menuTable)
    player:timer(MENU_DELAY_MS, function(p)
        local ok, err = pcall(function()
            p:customMenu(menuTable)
        end)
        if not ok then
            p:printToPlayer(('Exchange: menu error (%s)'):format(tostring(err)), xi.msg.channel.SYSTEM_1)
        end
    end)
end

local function printLine(p, npc, text)
    local name = (npc and npc.getPacketName and npc:getPacketName()) or 'Exchange'
    p:printToPlayer(text, 0, name)
end

local function printRateCard(p)
    printLine(p, currentNpc, '--- Exchange scale: weight = CP value per 1 unit ---')
    for _, a in ipairs(ASSETS) do
        printLine(p, currentNpc, ('  %s = %d CP  |  %s'):format(a.mTag, a.weight, a.label))
    end

    printLine(p, currentNpc, 'Trades convert on that scale. Menu uses short tags.')
end

local function assetById(id)
    for _, a in ipairs(ASSETS) do
        if a.id == id then
            return a
        end
    end
end

local function assetListExcept(excludeId)
    local t = {}
    for _, a in ipairs(ASSETS) do
        if a.id ~= excludeId then
            table.insert(t, a)
        end
    end

    return t
end

local function getBalance(p, a)
    if a.kind == 'cp' then
        if p.getCP then
            return p:getCP() or 0
        end

        return p:getCurrency('conquest_points') or 0
    elseif a.kind == 'currency' then
        return p:getCurrency(a.key) or 0
    elseif a.kind == 'gil' then
        return p:getGil() or 0
    else
        return p:getItemCount(a.itemId) or 0
    end
end

local function takeAsset(p, a, amt)
    if amt <= 0 then
        return true
    end

    if a.kind == 'cp' then
        if p.getCP and p.delCP and p:getCP() >= amt then
            p:delCP(amt)
            return true
        end

        if (p:getCurrency('conquest_points') or 0) < amt then
            return false
        end

        p:delCurrency('conquest_points', amt)
        return true
    elseif a.kind == 'currency' then
        if (p:getCurrency(a.key) or 0) < amt then
            return false
        end

        p:delCurrency(a.key, amt)
        return true
    elseif a.kind == 'gil' then
        return p:delGil(amt)
    else
        if (p:getItemCount(a.itemId) or 0) < amt then
            return false
        end

        return p:delItem(a.itemId, amt)
    end
end

local function giveAsset(p, a, amt)
    if amt <= 0 then
        return true
    end

    if a.kind == 'cp' then
        if p.addCP then
            p:addCP(amt)
        else
            p:addCurrency('conquest_points', amt)
        end

        return true
    elseif a.kind == 'currency' then
        local capVal = nil
        if a.cap and xi.settings and xi.settings.main then
            capVal = xi.settings.main[a.cap]
        end

        if capVal then
            p:addCurrency(a.key, amt, capVal)
        else
            p:addCurrency(a.key, amt)
        end

        return true
    elseif a.kind == 'gil' then
        p:addGil(amt)
        return true
    else
        local remain = amt
        while remain > 0 do
            local give = math.min(remain, 99)
            if not p:addItem(a.itemId, give) then
                return false
            end

            remain = remain - give
        end

        return true
    end
end

local function hasSpaceFor(p, itemId, units)
    local stacksNeeded = math.ceil(units / 99)
    local free         = p:getFreeSlotsCount() or 0
    return free >= stacksNeeded, stacksNeeded, free
end

local function convertCompute(p, fromA, toA, spendCap)
    local wf, wt = fromA.weight, toA.weight
    local bal      = getBalance(p, fromA)
    local spendMax = math.min(spendCap, bal)
    if spendMax < 1 then
        return nil, 'Not enough to spend.'
    end

    local toReceive = math.floor(spendMax * wf / wt)
    if toReceive < 1 then
        return nil, 'Amount too small to yield even 1 unit.'
    end

    if toA.kind == 'currency' and toA.cap and xi.settings and xi.settings.main then
        local capVal = xi.settings.main[toA.cap]
        if capVal then
            local cur  = p:getCurrency(toA.key) or 0
            local room = math.max(0, capVal - cur)
            toReceive  = math.min(toReceive, room)
        end
    end

    if toA.kind == 'gil' then
        local cur  = p:getGil() or 0
        local room = math.max(0, GIL_CAP - cur)
        toReceive  = math.min(toReceive, room)
    end

    if toReceive < 1 then
        return nil, 'Target currency is at cap.'
    end

    local fromSpend = math.ceil(toReceive * wt / wf)
    if fromSpend > spendMax then
        toReceive  = math.floor(spendMax * wf / wt)
        if toReceive < 1 then
            return nil, 'Amount too small after cap check.'
        end

        fromSpend = math.ceil(toReceive * wt / wf)
    end

    if fromSpend > spendMax or fromSpend < 1 then
        return nil, 'Could not settle conversion.'
    end

    return fromSpend, toReceive
end

local function executeExchange(p, fromA, toA, spendCap)
    local fromSpend, toReceive = convertCompute(p, fromA, toA, spendCap)
    if not fromSpend then
        printLine(p, currentNpc, toReceive or 'Conversion failed.')
        return
    end

    if toA.kind == 'item' then
        local okSpace, need, free = hasSpaceFor(p, toA.itemId, toReceive)
        if not okSpace then
            printLine(p, currentNpc, ('Need %d free slot(s) for items (you have %d).'):format(need, free))
            return
        end
    end

    if not takeAsset(p, fromA, fromSpend) then
        printLine(p, currentNpc, 'Could not remove what you are spending.')
        return
    end

    if not giveAsset(p, toA, toReceive) then
        giveAsset(p, fromA, fromSpend)
        printLine(p, currentNpc, 'Could not deliver — refunded your spend.')
        return
    end

    printLine(p, currentNpc, ('Traded %d [%s] -> %d [%s].'):format(fromSpend, fromA.label, toReceive, toA.label))
end

-- Menus (fresh table per step; openMenu defers via player:timer — see module header)
local showRoot
local showPickFrom
local showPickTo
local showQtyPage

showRoot = function(player)
    openMenu(player, {
        title = 'Exchange',
        options =
        {
            {
                'Trade',
                function(p)
                    -- Hint so players know 0 balance still opens the spend list.
                    printLine(p, currentNpc, 'Pick what to spend. You can open this menu with 0 CP; you only need currency to complete a swap.')
                    showPickFrom(p, 1)
                end,
            },
            {
                'Rates',
                function(p)
                    printRateCard(p)
                    openMenu(p, {
                        title = 'Exchange',
                        options = {
                            {
                                'OK',
                                function(pp)
                                    showRoot(pp)
                                end,
                            },
                        },
                    })
                end,
            },
            {
                'Balances',
                function(p)
                    printLine(p, currentNpc, 'Balances - CP weights are under Rates.')
                    for _, a in ipairs(ASSETS) do
                        printLine(p, currentNpc, ('  %s: %d  [%s]'):format(a.mTag, getBalance(p, a), a.label))
                    end

                    openMenu(p, {
                        title = 'Exchange',
                        options = {
                            {
                                'OK',
                                function(pp)
                                    showRoot(pp)
                                end,
                            },
                        },
                    })
                end,
            },
        },
    })
end

showPickFrom = function(player, page)
    local opts  = {}
    local total = #ASSETS
    local pages = math.max(1, math.ceil(total / MENU_PAGE))
    local start = (page - 1) * MENU_PAGE + 1
    local stop  = math.min(total, start + MENU_PAGE - 1)

    if page > 1 then
        table.insert(opts, { 'Prev', function(pp) showPickFrom(pp, page - 1) end })
    end

    for i = start, stop do
        local a = ASSETS[i]
        local bal = getBalance(player, a)
        table.insert(opts, {
            ('Spend %s x%d'):format(a.mTag, bal),
            function(pp)
                showPickTo(pp, a.id, 1)
            end,
        })
    end

    if stop < total then
        table.insert(opts, { 'More', function(pp) showPickFrom(pp, page + 1) end })
    end

    table.insert(opts, { 'Close', function(pp) showRoot(pp) end })
    openMenu(player, { title = ('Spend? %d/%d'):format(page, pages), options = opts })
end

showPickTo = function(player, fromId, page)
    local fromA = assetById(fromId)
    if not fromA then
        showRoot(player)
        return
    end

    local list  = assetListExcept(fromId)
    local total = #list
    local pages = math.max(1, math.ceil(total / MENU_PAGE))
    local opts  = {}
    local start = (page - 1) * MENU_PAGE + 1
    local stop  = math.min(total, start + MENU_PAGE - 1)

    if page > 1 then
        table.insert(opts, { 'Prev', function(pp) showPickTo(pp, fromId, page - 1) end })
    end

    for i = start, stop do
        local a = list[i]
        table.insert(opts, {
            ('Get %s'):format(a.mTag),
            function(pp)
                showQtyPage(pp, fromId, a.id, 1)
            end,
        })
    end

    if stop < total then
        table.insert(opts, { 'More', function(pp) showPickTo(pp, fromId, page + 1) end })
    end

    table.insert(opts, { 'Back', function(pp) showPickFrom(pp, 1) end })
    openMenu(player, { title = ('Get? %s %d/%d'):format(fromA.mTag, page, pages), options = opts })
end

showQtyPage = function(player, fromId, toId, qtyPage)
    local fromA = assetById(fromId)
    local toA   = assetById(toId)
    if not fromA or not toA then
        showRoot(player)
        return
    end

    local bal = getBalance(player, fromA)
    printLine(player, currentNpc, ('%s -> %s | can spend up to %d'):format(fromA.label, toA.label, bal))

    local opts    = {}
    local start   = (qtyPage - 1) * UNITS_PER_PAGE + 1
    local stop    = math.min(#UNITS_CHOICES, start + UNITS_PER_PAGE - 1)
    local hasPrev = start > 1
    local hasNext = stop < #UNITS_CHOICES

    if hasPrev then
        table.insert(opts, { 'Prev', function(pp) showQtyPage(pp, fromId, toId, qtyPage - 1) end })
    end

    for i = start, stop do
        local u = UNITS_CHOICES[i]
        table.insert(opts, {
            ('x%d'):format(u),
            function(pp)
                executeExchange(pp, fromA, toA, u)
                showQtyPage(pp, fromId, toId, qtyPage)
            end,
        })
    end

    table.insert(opts, {
        'MAX',
        function(pp)
            executeExchange(pp, fromA, toA, getBalance(pp, fromA))
            showQtyPage(pp, fromId, toId, qtyPage)
        end,
    })

    if hasNext then
        table.insert(opts, { 'More', function(pp) showQtyPage(pp, fromId, toId, qtyPage + 1) end })
    end

    table.insert(opts, { 'Back', function(pp) showPickTo(pp, fromId, 1) end })
    openMenu(player, {
        title = ('%s>%s'):format(fromA.mTag, toA.mTag),
        options = opts,
    })
end

-----------------------------------
-- Dynamic NPC (spawn beside guard on overseer trigger)
-----------------------------------
local spawnedForGuard = {}

local function spawnExchangeBeside(guardNpc)
    local zone = guardNpc and guardNpc:getZone()
    if not zone or not zone.insertDynamicEntity then
        return
    end

    local key = tostring(zone:getID()) .. ':' .. tostring(guardNpc:getID())
    if spawnedForGuard[key] then
        return
    end

    zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = 'Exchange',
        look     = 2433,
        x = guardNpc:getXPos() + 1.2,
        y = guardNpc:getYPos(),
        z = guardNpc:getZPos() + 0.8,
        rotation = guardNpc:getRotPos(),
        widescan = 1,
        onTrigger = function(player, exNpc)
            currentNpc = exNpc
            printLine(player, exNpc, 'Currency exchange. Menu uses short tags; pick Rates for the full CP scale.')
            showRoot(player)
        end,
        onTrade = function(player, exNpc, trade)
            printLine(player, exNpc, 'Use Trade in the menu. Rates print to chat when you open this NPC.')
        end,
    })

    spawnedForGuard[key] = true
end

m:addOverride('xi.conquest.overseerOnTrigger', function(player, npc, guardNation, guardType, guardEvent, guardRegion)
    spawnExchangeBeside(npc)
    super(player, npc, guardNation, guardType, guardEvent, guardRegion)
end)

return m
