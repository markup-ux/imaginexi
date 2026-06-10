-----------------------------------
-- ID: 5867
-- Toolbag Ino
-- When used, you will obtain one stack of inoshishinofuda
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5867)
end

return itemObject
