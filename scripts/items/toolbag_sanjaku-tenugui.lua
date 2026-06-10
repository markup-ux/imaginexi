-----------------------------------
-- ID: 5314
-- Toolbag Sanjaku-tenugui
-- When used, you will obtain one stack of Sanjaku-tenugui
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5417)
end

return itemObject
