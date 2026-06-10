-----------------------------------
-- Conquest: regional NPCs always up (moved from modules/custom/lua)
-----------------------------------
local super = xi.conquest.toggleRegionalNPCs

xi.conquest.toggleRegionalNPCs = function(zone)
    super(zone)

    local id = zone:getID()
    if
        id == xi.zone.PORT_BASTOK or
        id == xi.zone.SOUTHERN_SAN_DORIA or
        id == xi.zone.WINDURST_WOODS
    then
        local regionalNPCNames =
        {
            'Nokkhi_Jinjahl',
            'Ominous_Cloud',
            'Valeriano',
            'Mokop-Sankop',
            'Cheh_Raihah',
            'Nalta',
            'Dahjal'
        }

        for _, name in pairs(regionalNPCNames) do
            local results = zone:queryEntitiesByName(name)
            for _, entity in pairs(results) do
                if math.abs(entity:getXPos()) > 0 then
                    entity:setStatus(xi.status.NORMAL)
                end
            end
        end
    end
end
