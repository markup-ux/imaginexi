-----------------------------------
-- ID: 5313
-- Toolbag Mizu
-- When used, you will obtain one stack of mizu-deppo
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5313)
end

return itemObject
