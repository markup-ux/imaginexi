-----------------------------------
-- Unlock all mounts at level 10
-----------------------------------
require('modules/module_utils')
require('scripts/globals/player')
require('scripts/enum/key_item')
-----------------------------------
local m = Module:new('unlock_all_mounts_level10')

local function unlockAllMountsIfEligible(player)
    if player:getMainLvl() < 10 then
        return
    end

    for keyItemId = xi.ki.CHOCOBO_COMPANION, xi.ki.CRAKLAW_COMPANION do
        if not player:hasKeyItem(keyItemId) then
            player:addKeyItem(keyItemId)
        end
    end
end

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    unlockAllMountsIfEligible(player)
end)

m:addOverride('xi.player.onPlayerLevelUp', function(player)
    super(player)
    unlockAllMountsIfEligible(player)
end)

return m
