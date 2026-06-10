-----------------------------------
-- ID: 6265
-- Toolbag Ranka
-- When used, you will obtain one stack of Ranka
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 6265)
end

return itemObject
