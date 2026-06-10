-----------------------------------
-- ID: 5319
-- Toolbag Shinobi-tabi
-- When used, you will obtain one stack of Shinobi-tabi
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5319)
end

return itemObject
