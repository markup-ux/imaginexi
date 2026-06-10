-----------------------------------
-- ID: 5316
-- Toolbag Kagi
-- When used, you will obtain one stack of kaginawa
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5316)
end

return itemObject
