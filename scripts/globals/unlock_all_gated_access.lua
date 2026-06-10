-----------------------------------
-- Unlock all requirement-gated entry points (instances, battlefields, zone doors)
-- while preserving mission/quest completion state (read-check bypass only in zone NPC context).
-----------------------------------
xi = xi or {}
xi.unlock_all_gated_access = xi.unlock_all_gated_access or {}

if xi.unlock_all_gated_access._coreHooksApplied then
    return xi.unlock_all_gated_access
end

function xi.unlock_all_gated_access.normalizePath(path)
    return string.gsub(path or '', '\\', '/')
end

function xi.unlock_all_gated_access.isZoneEntranceContext()
    for stackLevel = 3, 10 do
        local info = debug.getinfo(stackLevel, 'S')
        if not info or not info.source then
            break
        end

        local source = xi.unlock_all_gated_access.normalizePath(info.source)
        if string.sub(source, 1, 1) == '@' then
            source = string.sub(source, 2)
        end

        if string.find(source, '/scripts/zones/', 1, true) then
            if
                string.find(source, '/npcs/', 1, true) or
                string.find(source, '/Zone.lua', 1, true)
            then
                return true
            end
        end
    end

    return false
end

function xi.unlock_all_gated_access.isAssaultCounterContext()
    local assaultSources =
    {
        '/scripts/zones/Aht_Urhgan_Whitegate/npcs/Rytaal.lua',
        '/scripts/zones/Aht_Urhgan_Whitegate/npcs/Runic_Portal.lua',
        '/scripts/zones/Aht_Urhgan_Whitegate/npcs/Yahsra.lua',
        '/scripts/zones/Aht_Urhgan_Whitegate/npcs/Isdebaaq.lua',
        '/scripts/zones/Aht_Urhgan_Whitegate/npcs/Famad.lua',
        '/scripts/zones/Aht_Urhgan_Whitegate/npcs/Lageegee.lua',
        '/scripts/zones/Aht_Urhgan_Whitegate/npcs/Bhoy_Yhupplo.lua',
        '/scripts/zones/Aht_Urhgan_Whitegate/npcs/Sorrowful_Sage.lua',
    }

    for stackLevel = 3, 10 do
        local info = debug.getinfo(stackLevel, 'S')
        if not info or not info.source then
            break
        end

        local source = xi.unlock_all_gated_access.normalizePath(info.source)
        if string.sub(source, 1, 1) == '@' then
            source = string.sub(source, 2)
        end

        for _, assaultSource in ipairs(assaultSources) do
            if string.find(source, assaultSource, 1, true) then
                return true
            end
        end
    end

    return false
end

function xi.unlock_all_gated_access.bypassInstanceRequirements()
    if not xi.instance or not xi.instance.lookup then
        return
    end

    for _, zoneEntries in pairs(xi.instance.lookup) do
        for _, entry in ipairs(zoneEntries) do
            local instanceId = entry[1]
            local instanceObj = GetCachedInstanceScript(instanceId)

            if instanceObj then
                instanceObj.registryRequirements = function(player)
                    return true
                end

                instanceObj.entryRequirements = function(player)
                    return true
                end
            end
        end
    end
end

function xi.unlock_all_gated_access.grantAccessKeyItems(player)
    local accessKeyItems =
    {
        xi.ki.MOON_CRYSTAL,
        xi.ki.CERULEAN_CRYSTAL,
        xi.ki.COSMO_CLEANSE,
        xi.ki.REMNANTS_PERMIT,
        xi.ki.PRISMATIC_HOURGLASS,
        xi.ki.VIAL_OF_SHROUDED_SAND,
        xi.ki.HYDRA_CORPS_COMMAND_SCEPTER,
        xi.ki.HYDRA_CORPS_EYEGLASS,
        xi.ki.HYDRA_CORPS_LANTERN,
        xi.ki.HYDRA_CORPS_TACTICAL_MAP,
        xi.ki.HYDRA_CORPS_INSIGNIA,
        xi.ki.HYDRA_CORPS_BATTLE_STANDARD,
        xi.ki.DYNAMIS_VALKURM_SLIVER,
        xi.ki.DYNAMIS_BUBURIMU_SLIVER,
        xi.ki.DYNAMIS_QUFIM_SLIVER,
        xi.ki.DYNAMIS_TAVNAZIA_SLIVER,
        xi.ki.ASSAULT_ARMBAND,
        xi.ki.IMPERIAL_ARMY_ID_TAG,
        xi.ki.LEUJAOAM_ASSAULT_ORDERS,
        xi.ki.MAMOOL_JA_ASSAULT_ORDERS,
        xi.ki.LEBROS_ASSAULT_ORDERS,
        xi.ki.PERIQIA_ASSAULT_ORDERS,
        xi.ki.ILRUSI_ASSAULT_ORDERS,
        xi.ki.NYZUL_ISLE_ASSAULT_ORDERS,
        xi.ki.PERIQIA_ASSAULT_AREA_ENTRY_PERMIT,
        xi.ki.NYZUL_ISLE_ROUTE,
        xi.ki.AIRSHIP_PASS,
        xi.ki.AIRSHIP_PASS_FOR_KAZHAM,
        xi.ki.ARCHDUCAL_AUDIENCE_PERMIT,
        xi.ki.MOONGATE_PASS,
        xi.ki.PSOXJA_PASS,
        xi.ki.BOARDING_PERMIT,
        xi.ki.RUNIC_PORTAL_USE_PERMIT,
        xi.ki.ADOULINIAN_CHARTER_PERMIT,
        xi.ki.GEOMAGNETIC_COMPASS,
        xi.ki.GEOMAGNETRON,
        xi.ki.HOLLA_GATE_CRYSTAL,
        xi.ki.DEM_GATE_CRYSTAL,
        xi.ki.MEA_GATE_CRYSTAL,
        xi.ki.VAHZL_GATE_CRYSTAL,
        xi.ki.YHOATOR_GATE_CRYSTAL,
        xi.ki.ALTEPA_GATE_CRYSTAL,
        xi.ki.JUGNER_GATE_CRYSTAL,
        xi.ki.PASHHOW_GATE_CRYSTAL,
        xi.ki.MERIPHATAUD_GATE_CRYSTAL,
        xi.ki.SAN_DORIA_WARP_RUNE,
        xi.ki.BASTOK_WARP_RUNE,
        xi.ki.WINDURST_WARP_RUNE,
        xi.ki.SELBINA_WARP_RUNE,
        xi.ki.MHAURA_WARP_RUNE,
        xi.ki.KAZHAM_WARP_RUNE,
        xi.ki.RABAO_WARP_RUNE,
        xi.ki.NORG_WARP_RUNE,
        xi.ki.TAVNAZIA_WARP_RUNE,
        xi.ki.WHITEGATE_WARP_RUNE,
        xi.ki.NASHMAU_WARP_RUNE,
        xi.ki.IVORY_ABYSSITE_OF_CONFLUENCE,
        xi.ki.CRIMSON_ABYSSITE_OF_CONFLUENCE,
        xi.ki.INDIGO_ABYSSITE_OF_CONFLUENCE,
    }

    for _, keyItem in ipairs(accessKeyItems) do
        if keyItem and not player:hasKeyItem(keyItem) then
            player:addKeyItem(keyItem)
        end
    end
end

function xi.unlock_all_gated_access.grantTravelTeleports(player)
    -- Intentionally do not mass-unlock HOMEPOINT: crystals addTeleport on first trigger
    -- when HOMEPOINT_TELEPORT is enabled (scripts/globals/homepoint.lua).

    for groupIndex = 0, 31 do
        for group = 0, 2 do
            player:addTeleport(xi.teleport.type.SURVIVAL, groupIndex, group)
        end
    end

    for waypointBit = 0, 54 do
        player:addTeleport(xi.teleport.type.WAYPOINT, waypointBit)
    end

    for portalBit = 0, 31 do
        player:addTeleport(xi.teleport.type.ESCHAN_PORTAL, portalBit)
    end

    for mawBit = 0, 8 do
        player:addTeleport(xi.teleport.type.PAST_MAW, mawBit)
    end

    for portalBit = 0, 6 do
        player:addTeleport(xi.teleport.type.RUNIC_PORTAL, portalBit)
    end

    for maskOffset = 0, 8 do
        for confluxBit = 0, 8 do
            player:addTeleport(xi.teleport.type.ABYSSEA_CONFLUX, confluxBit, maskOffset)
        end
    end
end

function xi.unlock_all_gated_access.grantAccessUnlocks(player)
    xi.unlock_all_gated_access.grantTravelTeleports(player)
    xi.unlock_all_gated_access.grantAccessKeyItems(player)
    player:setCharVar('dynaWaitxDay', 0)
    player:setCharVar('nextTagTime', 0)
    player:setCharVar('[ein]lockout', 0)
    player:setCurrency('id_tags', 3)
end

-----------------------------------
-- Runtime wraps (after xi.besieged / xi.einherjar / CBaseEntity exist)
-----------------------------------
do
    local superHasCompletedMission = CBaseEntity.hasCompletedMission
    CBaseEntity.hasCompletedMission = function(self, area, mission)
        if xi.unlock_all_gated_access.isZoneEntranceContext() then
            return true
        end

        return superHasCompletedMission(self, area, mission)
    end
end

do
    local superHasCompletedQuest = CBaseEntity.hasCompletedQuest
    CBaseEntity.hasCompletedQuest = function(self, area, quest)
        if xi.unlock_all_gated_access.isZoneEntranceContext() then
            return true
        end

        return superHasCompletedQuest(self, area, quest)
    end
end

do
    local superGetCurrentMission = CBaseEntity.getCurrentMission
    CBaseEntity.getCurrentMission = function(self, area)
        if xi.unlock_all_gated_access.isZoneEntranceContext() then
            return 32767
        end

        return superGetCurrentMission(self, area)
    end
end

do
    local superGetMissionStatus = CBaseEntity.getMissionStatus
    CBaseEntity.getMissionStatus = function(self, area, missionStatusType)
        if xi.unlock_all_gated_access.isZoneEntranceContext() then
            return 32767
        end

        return superGetMissionStatus(self, area, missionStatusType)
    end
end

do
    local superGetQuestStatus = CBaseEntity.getQuestStatus
    CBaseEntity.getQuestStatus = function(self, area, quest)
        if xi.unlock_all_gated_access.isZoneEntranceContext() then
            return xi.questStatus.QUEST_COMPLETED
        end

        return superGetQuestStatus(self, area, quest)
    end
end

do
    local superGetMainLvl = CBaseEntity.getMainLvl
    CBaseEntity.getMainLvl = function(self)
        if xi.unlock_all_gated_access.isAssaultCounterContext() then
            return math.max(superGetMainLvl(self), 50)
        end

        return superGetMainLvl(self)
    end
end

do
    local superGetCharVar = CBaseEntity.getCharVar
    CBaseEntity.getCharVar = function(self, varName)
        if
            varName == 'dynaWaitxDay' or
            varName == 'nextTagTime' or
            varName == '[ein]lockout'
        then
            return 0
        end

        return superGetCharVar(self, varName)
    end
end

do
    local superGetCurrency = CBaseEntity.getCurrency
    CBaseEntity.getCurrency = function(self, currencyName)
        if xi.unlock_all_gated_access.isAssaultCounterContext() and currencyName == 'id_tags' then
            return math.max(superGetCurrency(self, currencyName), 3)
        end

        return superGetCurrency(self, currencyName)
    end
end

do
    local superMercRank = xi.besieged.getMercenaryRank
    xi.besieged.getMercenaryRank = function(player)
        if xi.unlock_all_gated_access.isAssaultCounterContext() then
            return 11
        end

        return superMercRank(player)
    end
end

do
    xi.einherjar.isLockedOut = function(player)
        return 0
    end
end

xi.unlock_all_gated_access._coreHooksApplied = true

return xi.unlock_all_gated_access
