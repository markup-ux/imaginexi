-----------------------------------
-- ID: 5317
-- Toolbag Sai
-- When used, you will obtain one stack of sairui-ran
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5317)
end

return itemObject
