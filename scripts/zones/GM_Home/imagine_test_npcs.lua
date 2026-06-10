-----------------------------------
-- Test NPCs (GM Home)
-- Moved from modules/custom/lua/test_npcs_in_gm_home.lua
-----------------------------------

local m = {}

local menu  = {}
local page1 = {}
local page2 = {}

local delaySendMenu = function(player)
    player:timer(50, function(playerArg)
        playerArg:customMenu(menu)
    end)
end

menu =
{
    title = 'Test Menu (Paginated)',
    options = {},
}

page1 =
{
    {
        'Send me to Jeuno!',
        function(playerArg)
            playerArg:setPos(0, 0, 0, 0, xi.zone.LOWER_JEUNO)
        end,
    },
    {
        'Next Page',
        function(playerArg)
            menu.options = page2
            delaySendMenu(playerArg)
        end,
    },
}

page2 =
{
    {
        'Send me to Aht Urghan!',
        function(playerArg)
            playerArg:setPos(0, 0, 0, 0, xi.zone.AHT_URHGAN_WHITEGATE)
        end,
    },
    {
        'Previous Page',
        function(playerArg)
            menu.options = page1
            delaySendMenu(playerArg)
        end,
    },
}

function m.register(zone)
    local horro = zone:insertDynamicEntity({
        objtype = xi.objType.NPC,
        name = 'Horro',
        look = 2430,
        x = 5.000,
        y = 0.000,
        z = 0.000,
        rotation = 128,
        widescan = 1,
        onTrade = function(player, npc, trade)
            player:printToPlayer('No, thanks!', 0, npc:getPacketName())
        end,
        onTrigger = function(player, npc)
            player:printToPlayer('Welcome to GM Home!', 0, npc:getPacketName())
        end,
    })

    utils.unused(horro)

    zone:insertDynamicEntity({
        objtype   = xi.objType.NPC,
        name      = 'Menu Example',
        look      = 2433,
        x         = 5.000,
        y         = 0.000,
        z         = 5.000,
        rotation  = 0,
        widescan  = 1,
        onTrigger  = function(player, npc)
            menu.options = page1
            delaySendMenu(player)
        end,
    })
end

return m
