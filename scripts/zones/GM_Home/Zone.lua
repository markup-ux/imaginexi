-----------------------------------
-- Zone: GM Home (210)
-----------------------------------
local imagineRunAf1     = require('scripts/zones/GM_Home/imagine_run_af1_npc')
local imagineGeoAf1     = require('scripts/zones/GM_Home/imagine_geo_af1_npc')
local imagineCurrencyx  = require('scripts/zones/GM_Home/imagine_currencyx_npc')
local imagineTestNpcs   = require('scripts/zones/GM_Home/imagine_test_npcs')
local imagineHnmTests   = require('scripts/zones/GM_Home/imagine_hnm_test_mobs')
local imagineDeliveryMoogle = require('scripts/zones/GM_Home/imagine_delivery_moogle')
-----------------------------------
-- Some cs event info:
-- 0 = Abyssea Debug
-- 1 = Mogsack Debug
-- ...
-- 139 = Janken challenges player to "Rock, Paper, Scissors"
-- ...
-- 140 = Camera test.
-- 141 = "Press confirm button to proceed" nonworking test.
-----------------------------------
---@type TZone
local zoneObject = {}

zoneObject.onInitialize = function(zone)
    imagineDeliveryMoogle.register(zone)
    imagineRunAf1.register(zone)
    imagineGeoAf1.register(zone)
    imagineCurrencyx.register(zone)
    imagineTestNpcs.register(zone)
    imagineHnmTests.register(zone)
end

zoneObject.onZoneIn = function(player, prevZone)
    local cs = -1

    return cs
end

zoneObject.onEventUpdate = function(player, csid, option, npc)
end

zoneObject.onEventFinish = function(player, csid, option, npc)
end

return zoneObject
