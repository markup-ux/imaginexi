-----------------------------------
-- Delivery Moogle (GM Home / zone 210)
-- Opens the Mog House menu (delivery box, etc.) outside a residential mog house.
-- Same pattern as Nomad Moogle zones.
-----------------------------------
local m = {}

-- Retail Moogle look from npc_list (standard house moogle model).
local MOOGLE_LOOK = '0000520000000000000000000000000000000000'

function m.register(zone)
    zone:insertDynamicEntity({
        objtype    = xi.objType.NPC,
        name       = 'Delivery_Moogle_210',
        packetName = 'Moogle',
        look       = MOOGLE_LOOK,
        x          = -3.0,
        y          = 0.0,
        z          = 0.0,
        rotation   = 64,
        widescan   = 1,

        onTrigger = function(player, npc)
            player:printToPlayer('Moogle: Mog House services, kupo! Check Delivery for your items.', xi.msg.channel.SYSTEM_3, npc:getPacketName())
            player:sendMenu(xi.menuType.MOOGLE)
        end,
    })
end

return m
