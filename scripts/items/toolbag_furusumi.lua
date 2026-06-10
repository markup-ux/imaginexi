-----------------------------------
-- ID: 6266
-- Toolbag Furu
-- When used, you will obtain one stack of Furusumi
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 6266)
end

return itemObject
