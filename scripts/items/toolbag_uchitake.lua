-----------------------------------
-- ID: 5308
-- Toolbag Uchi
-- When used, grants gil (ninja tools removed from this server).
-----------------------------------
require('scripts/globals/ninja_tool_gil')

---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return xi.itemUtils.itemBoxOnItemCheck(target)
end

itemObject.onItemUse = function(target)
    xi.ninjaToolGil.onToolbagUse(target, 5308)
end

return itemObject
