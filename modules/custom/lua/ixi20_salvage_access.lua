-----------------------------------
-- Imagine XI 2.0: Alzadaal Gilded Gateways open Salvage to every player.
-- No level 65 check, no Remnants Permit, no imbued-item block.
-- Solo, party, and alliance can all register. Gear still locks inside.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/instance')
-----------------------------------

local m = Module:new('ixi20_salvage_access')

local function nothingHappens(player)
    local id = zones[xi.zone.ALZADAAL_UNDERSEA_RUINS]
    if id and id.text then
        player:messageSpecial(id.text.NOTHING_HAPPENS)
    end
end

local doors =
{
    { npc = '_20v', zone = xi.zone.ZHAYOLM_REMNANTS },
    { npc = '_20u', zone = xi.zone.ARRAPAGO_REMNANTS },
    { npc = '_20w', zone = xi.zone.BHAFLAU_REMNANTS },
    { npc = '_20t', zone = xi.zone.SILVER_SEA_REMNANTS },
}

for _, door in ipairs(doors) do
    local zoneId = door.zone

    m:addOverride('xi.zones.Alzadaal_Undersea_Ruins.npcs.' .. door.npc .. '.onTrigger', function(player, npc)
        if not xi.instance.onTrigger(player, npc, zoneId) then
            nothingHappens(player)
        end
    end)

    -- Stock update cancels the whole alliance if anyone is wearing imbued salvage gear.
    m:addOverride('xi.zones.Alzadaal_Undersea_Ruins.npcs.' .. door.npc .. '.onEventUpdate', function(player, csid, option, npc)
        xi.instance.onEventUpdate(player, csid, option, npc)
    end)
end

local instances =
{
    'xi.zones.Zhayolm_Remnants.instances.zhayolm_remnants',
    'xi.zones.Arrapago_Remnants.instances.arrapago_remnants',
    'xi.zones.Bhaflau_Remnants.instances.bhaflau_remnants',
    'xi.zones.Silver_Sea_Remnants.instances.silver_sea_remnants',
}

for _, path in ipairs(instances) do
    m:addOverride(path .. '.registryRequirements', function(player)
        return player ~= nil
    end)

    m:addOverride(path .. '.entryRequirements', function(player)
        return player ~= nil
    end)
end

return m
