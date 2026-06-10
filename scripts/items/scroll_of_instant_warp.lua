-----------------------------------
-- ID: 4181
-- Scroll of Instant Warp
-- Transports the user to their Home Point
--
-- Not consumed on use (see CCharEntity::OnItemFinish for item 4181).
-- Rare/Exclusive stack 1 — kept until the player drops or discards it.
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, param, caster)
    return 0
end

itemObject.onItemUse = function(target, user)
    target:addStatusEffect(xi.effect.TELEPORT, { power = xi.teleport.id.WARP, duration = 3, origin = user, icon = 0 })
end

return itemObject
