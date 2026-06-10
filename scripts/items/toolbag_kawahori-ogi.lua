-----------------------------------
-- ID: 5310
-- Toolbag Kawa
-- When used, you will obtain one stack of kawahori-ogi
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5310)
end

return itemObject
