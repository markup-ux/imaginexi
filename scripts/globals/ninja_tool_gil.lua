-----------------------------------
-- Ninja tools are removed from the economy; toolbags pay gil on use.
-- Quest scripts can use xi.ninjaToolGil.forStack(itemId, qty) when replacing former tool rewards.
-----------------------------------
xi = xi or {}
xi.ninjaToolGil = xi.ninjaToolGil or {}

-- Gil per toolbag (matches prior gobbie/curio purchase tiers where applicable).
local gilByToolbagId =
{
    [5308] =  3000, -- toolbag uchitake
    [5309] =  3000, -- tsurara
    [5310] =  3000, -- kawahori-ogi
    [5311] =  3000, -- makibishi
    [5312] =  3000, -- hiraishin
    [5313] =  3000, -- mizu-deppo
    [5314] =  5000, -- shihei
    [5315] =  5000, -- jusatsu
    [5316] =  5000, -- kaginawa
    [5317] =  5000, -- sairui-ran
    [5318] =  5000, -- kodoku
    [5319] =  3000, -- shinobi-tabi
    [5417] =  3000, -- sanjaku-tenugui
    [5734] =  5000, -- soshi
    [5863] =  6000, -- kabenro
    [5864] =  6000, -- jinko
    [5865] =  6000, -- ryuno
    [5866] =  6000, -- mokujin
    [5867] = 15750, -- inoshishinofuda (higher-tier fuda bundle)
    [5868] = 21000, -- shikanofuda
    [5869] = 21000, -- chonofuda
    [6265] =  8000, -- ranka
    [6266] =  8000, -- furusumi
}

-- Gil per single tool unit (for quest replacements); rarity ~ vendor tier.
local gilPerSingleTool =
{
    [1161] =  400, -- uchitake
    [1164] =  400, -- tsurara
    [1167] =  400, -- kawahori-ogi
    [1170] =  400, -- makibishi
    [1173] =  400, -- hiraishin
    [1176] =  400, -- mizu-deppo
    [1179] = 1200, -- shihei
    [1182] = 1200, -- jusatsu
    [1185] = 1200, -- kaginawa
    [1188] = 1200, -- sairui-ran
    [1191] = 1200, -- kodoku
    [1194] = 1200, -- shinobi-tabi
    [2553] =  500, -- sanjaku-tenugui
    [2555] = 1200, -- soshi
    [2642] = 1200, -- kabenro
    [2643] =  300, -- jinko
    [2644] =  800, -- ryuno
    [2970] =  300, -- mokujin
    [2971] =  400, -- inoshishinofuda
    [2972] =  400, -- shikanofuda
    [2973] =  400, -- chonofuda
    [8803] =  500, -- ranka
    [8804] =  500, -- furusumi
}

xi.ninjaToolGil.getToolbagGil = function(toolbagItemId)
    local gil = gilByToolbagId[toolbagItemId]
    if gil == nil or gil < 1 then
        return 3000
    end

    return gil
end

xi.ninjaToolGil.onToolbagUse = function(player, toolbagItemId)
    player:addGil(xi.ninjaToolGil.getToolbagGil(toolbagItemId))
end

xi.ninjaToolGil.forStack = function(itemId, qty)
    qty = qty or 1
    if qty < 1 then
        return 0
    end

    local unit = gilPerSingleTool[itemId]
    if unit == nil then
        unit = 500
    end

    return unit * qty
end
