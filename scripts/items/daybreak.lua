-----------------------------------
-- ID: 22040
-- Daybreak
-- Able to cast "Dispelga"
-----------------------------------
---@type TItem
local itemObject = {}

itemObject.onItemCheck = function(target, item, caster)
end

itemObject.onItemEquip = function(target, item)
    local mainWeapon = target:getEquippedItem(xi.slot.MAIN)
    if mainWeapon and mainWeapon:getID() == xi.item.DAYBREAK then
        target:addSpell(xi.magic.spell.DISPELGA, { silentLog = true, saveToDB = false })
    end
end

itemObject.onItemUnequip = function(target, item)
    -- Job-learned Dispelga (RDM 37) is saved; Daybreak's grant is session-only.
    if target:getJobLevel(xi.job.RDM) >= 37 then
        return
    end
    target:delSpell(xi.magic.spell.DISPELGA, { saveToDB = false })
end

return itemObject
