-----------------------------------
-- ID: 5314
-- Toolbag Shihei
-- When used, you will obtain one stack of Shihei
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5314)
end

return itemObject
