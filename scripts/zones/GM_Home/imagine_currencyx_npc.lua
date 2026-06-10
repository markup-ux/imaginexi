-----------------------------------
-- CP Exchange (GM Home)
-- Moved from modules/custom/lua/currencyx.lua
-----------------------------------
require('scripts/enum/item')

local m = {}

local RATES = {
    { id='byne',      label='Byne Bill',          type='item', itemId=xi.item.ONE_BYNE_BILL,         cp_per_unit=50,   desc='Dynamis currency (single).' },
    { id='obronze',   label='O. Bronzepiece',     type='item', itemId=xi.item.ORDELLE_BRONZEPIECE,   cp_per_unit=50,   desc='Dynamis currency (single).' },
    { id='twhite',    label='T. Whiteshell',      type='item', itemId=xi.item.TUKUKU_WHITESHELL,     cp_per_unit=50,   desc='Dynamis currency (single).' },
    { id='100byne',   label='100 Byne Bill',      type='item', itemId=xi.item.ONE_HUNDRED_BYNE_BILL, cp_per_unit=5000, desc='Dynamis 100-piece.' },
    { id='msilver',   label='M. Silverpiece',     type='item', itemId=xi.item.MONTIONT_SILVERPIECE,  cp_per_unit=5000, desc='Dynamis 100-piece.' },
    { id='ljade',     label='L. Jadeshell',       type='item', itemId=xi.item.LUNGO_NANGO_JADESHELL, cp_per_unit=5000, desc='Dynamis 100-piece.' },
    { id='alex',      label='Alexandrite',        type='item', itemId=xi.item.ALEXANDRITE,           cp_per_unit=60,   desc='Mythic path material.' },
    { id='cruor',     label='Cruor',              type='currency', key='cruor',                      cp_per_unit=1,    out_mult=1,     desc='Abyssea currency.' },
    { id='hmp',       label='Heavy Metal Plate',  type='item', itemId=xi.item.PLATE_OF_HEAVY_METAL,  cp_per_unit=1000, desc='Empyrean upgrade item.' },
    { id='dross',     label='Riftdross',          type='item', itemId=xi.item.CLUMP_OF_RIFTDROSS,    cp_per_unit=7500, desc='Empyrean weapon trial item.' },
    { id='cinder',    label='Riftcinder',         type='item', itemId=xi.item.PINCH_OF_RIFTCINDER,   cp_per_unit=10000,desc='Empyrean weapon trial item.' },
    { id='nyzul',     label='Nyzul Isle assault points', type='currency', key='nyzul_isle_assault_point', cp_per_unit=1,    out_mult=1,     desc='Nyzul Isle assault points (char_points.nyzul_isle_assault_point).' },
    { id='ichor',     label='Therion Ichor',      type='currency', key='therion_ichor',              cp_per_unit=10,   out_mult=1,     desc='Einherjar currency.' },
}

local UNITS_CHOICES  = { 1, 10, 50, 99, 100, 250, 500, 1000, 2500, 5000 }
local UNITS_PER_PAGE = 4

local menu  = { title = 'CP Exchange', options = {} }
local page1, page2, page3 = {}, {}, {}
local currentNpc = nil

local function delaySendMenu(player)
    player:timer(50, function(p) p:customMenu(menu) end)
end

local function printLine(p, npc, text)
    local name = (npc and npc.getPacketName and npc:getPacketName()) or 'CP Exchange'
    p:printToPlayer(text, 0, name)
end

local function getCP(p)
    if p.getCP        then return p:getCP() or 0 end
    if p.getCurrency  then return p:getCurrency('conquest_points') or 0 end
    return 0
end

local function takeCP(p, amount)
    if amount <= 0 then return end
    if p.delCP        then p:delCP(amount) return end
    if p.delCurrency  then p:delCurrency('conquest_points', amount) end
end

local function formatRateLine(r)
    if r.type == 'currency' then
        return string.format('- %s: %d CP -> %d %s', r.label, r.cp_per_unit, (r.out_mult or 1), r.label)
    else
        return string.format('- %s: %d CP -> 1 %s', r.label, r.cp_per_unit, r.label)
    end
end

local function giveOut(p, r, units)
    if r.type == 'currency' then
        local total = units * (r.out_mult or 1)
        p:addCurrency(r.key, total)
        return total
    else
        if (p:getFreeSlotsCount() or 0) <= 0 then
            return false, 'You need at least 1 free inventory slot.'
        end
        local remain, stack = units, 99
        while remain > 0 do
            local give = math.min(remain, stack)
            if not p:addItem(r.itemId, give) then
                return false, 'Inventory full or item could not be added.'
            end
            remain = remain - give
        end
        return true
    end
end

local function canAfford(p, r, units)
    local need = r.cp_per_unit * units
    return getCP(p) >= need, need
end

local function rateById(id)
    for _, r in ipairs(RATES) do
        if r.id == id then return r end
    end
    return nil
end

local function showUnitsPage(player, rate, pageIndex, backPage)
    printLine(player, currentNpc, formatRateLine(rate))

    local opts = {}
    local function push(label, fn) table.insert(opts, { label, fn }) end

    local startIdx = (pageIndex - 1) * UNITS_PER_PAGE + 1
    local endIdx   = math.min(#UNITS_CHOICES, startIdx + UNITS_PER_PAGE - 1)
    local hasPrev  = startIdx > 1
    local hasNext  = endIdx < #UNITS_CHOICES

    if hasPrev then
        push('<< Prev', function(pp) showUnitsPage(pp, rate, pageIndex - 1, backPage) end)
    end

    for i = startIdx, endIdx do
        local u = UNITS_CHOICES[i]
        push(('Buy x%d'):format(u), function(pp)
            local ok, need = canAfford(pp, rate, u)
            if not ok then
                printLine(pp, currentNpc, ('Not enough CP. Need %d CP for x%d.'):format(need, u))
                return
            end
            takeCP(pp, need)
            local out, err = giveOut(pp, rate, u)
            if out == false then
                printLine(pp, currentNpc, 'Conversion failed: ' .. (err or 'inventory/cap issue') .. ' CP was spent.')
            else
                if rate.type == 'currency' then
                    printLine(pp, currentNpc, ('Converted %d CP -> %d %s.'):format(need, out, rate.label))
                else
                    printLine(pp, currentNpc, ('Converted %d CP -> %d %s.'):format(need, u, rate.label))
                end
            end
        end)
    end

    push('MAX', function(pp)
        local cp = getCP(pp)
        local u  = math.floor(cp / rate.cp_per_unit)
        if rate.type == 'item' then u = math.min(u, 12 * 99) end
        if u <= 0 then
            printLine(pp, currentNpc, 'You cannot afford any units right now.')
            return
        end
        local need = rate.cp_per_unit * u
        takeCP(pp, need)
        local out, err = giveOut(pp, rate, u)
        if out == false then
            printLine(pp, currentNpc, 'Conversion failed: ' .. (err or 'inventory/cap issue') .. ' CP was spent.')
        else
            if rate.type == 'currency' then
                printLine(pp, currentNpc, ('Converted %d CP -> %d %s.'):format(need, (rate.out_mult or 1) * u, rate.label))
            else
                printLine(pp, currentNpc, ('Converted %d CP -> %d %s.'):format(need, u, rate.label))
            end
        end
    end)

    if hasNext then
        push('Next >>', function(pp) showUnitsPage(pp, rate, pageIndex + 1, backPage) end)
    end

    push('<< Back', function(pp)
        if backPage == 1 then
            menu.options = page1
        elseif backPage == 2 then
            menu.options = page2
        else
            menu.options = page3
        end
        delaySendMenu(pp)
    end)

    menu.options = opts
    delaySendMenu(player)
end

page1 = {
    { 'Rates & Info', function(p)
        printLine(p, currentNpc, 'Exchange Rates:')
        for _, r in ipairs(RATES) do
            printLine(p, currentNpc, '  ' .. formatRateLine(r))
        end
        printLine(p, currentNpc, 'Tip: In the quantity menu, use "MAX" to spend as much CP as you can afford.')
    end },
    { 'Your CP', function(p)
        local cp = getCP(p)
        printLine(p, currentNpc, ('You currently have %d CP.'):format(cp))
    end },
    { 'Byne Bill',      function(p) showUnitsPage(p, rateById('byne'),    1, 1) end },
    { 'O. Bronzepiece', function(p) showUnitsPage(p, rateById('obronze'), 1, 1) end },
    { 'T. Whiteshell',  function(p) showUnitsPage(p, rateById('twhite'),  1, 1) end },
    { '100 Byne Bill',  function(p) showUnitsPage(p, rateById('100byne'), 1, 1) end },
    { 'M. Silverpiece', function(p) showUnitsPage(p, rateById('msilver'), 1, 1) end },
    { 'Next >>',        function(p) menu.options = page2; delaySendMenu(p) end },
}

page2 = {
    { '<< Prev',        function(p) menu.options = page1; delaySendMenu(p) end },
    { 'L. Jadeshell',   function(p) showUnitsPage(p, rateById('ljade'),   1, 2) end },
    { 'Alexandrite',    function(p) showUnitsPage(p, rateById('alex'),    1, 2) end },
    { 'Cruor',          function(p) showUnitsPage(p, rateById('cruor'),   1, 2) end },
    { 'Heavy Metal Plate', function(p) showUnitsPage(p, rateById('hmp'),   1, 2) end },
    { 'Riftdross',         function(p) showUnitsPage(p, rateById('dross'), 1, 2) end },
    { 'Next >>',        function(p) menu.options = page3; delaySendMenu(p) end },
}

page3 = {
    { '<< Prev',       function(p) menu.options = page2; delaySendMenu(p) end },
    { 'Riftcinder',    function(p) showUnitsPage(p, rateById('cinder'), 1, 3) end },
    { 'Nyzul Tokens',  function(p) showUnitsPage(p, rateById('nyzul'),  1, 3) end },
    { 'Therion Ichor', function(p) showUnitsPage(p, rateById('ichor'),  1, 3) end },
}

function m.register(zone)
    zone:insertDynamicEntity({
        objtype  = xi.objType.NPC,
        name     = 'CP Exchange',
        look     = 2433,
        x = 7.000, y = 0.000, z = 5.000, rotation = 64, widescan = 1,

        onTrigger = function(player, npc)
            currentNpc   = npc
            menu.title   = 'CP Exchange'
            menu.options = page1
            delaySendMenu(player)
        end,

        onTrade = function(player, npc, trade)
            printLine(player, npc, 'No trades - use the menu to convert CP.')
        end,
    })
end

return m
