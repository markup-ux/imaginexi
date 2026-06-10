-----------------------------------
-- ImagineXI: Limbus (Temenos / Apollyon) — Battlefield framework helpers
-----------------------------------
require('scripts/globals/battlefield')
require('scripts/globals/interaction/container')
-----------------------------------
xi = xi or {}
xi.limbus = xi.limbus or {}

function xi.limbus.enter(player, entrance)
    switch (entrance): caseof
    {
        [0] = function()
            player:setPos(-668, 0.1, -666, 209, xi.zone.APOLLYON)
        end,

        [1] = function()
            player:setPos(643, 0.1, -600, 124, xi.zone.APOLLYON)
        end,
    }
end

function xi.limbus.showRecoverCrate(crateID)
    local crate = GetMobByID(crateID)

    if crate then
        crate:setAnimationSub(8)
        crate:setStatus(xi.status.NORMAL)
        crate:setUntargetable(false)
        crate:resetLocalVars()
    end
end

function xi.limbus.hideCrate(crate)
    crate:setStatus(xi.status.DISAPPEAR)
    crate:setUntargetable(true)
    crate:resetLocalVars()
end

function xi.limbus.spawnFrom(mob, crateID)
    local crate = GetEntityByID(crateID)

    if crate and crate:getLocalVar('opened') == 0 then
        crate:setPos(mob:getXPos(), mob:getYPos(), mob:getZPos(), mob:getRotPos())
        crate:setStatus(xi.status.NORMAL)
        crate:setUntargetable(false)
        crate:setAnimationSub(8)
    end
end

function xi.limbus.spawnRecoverFrom(mob, crateID)
    local crate = GetMobByID(crateID)

    if crate then
        crate:setPos(mob:getXPos(), mob:getYPos(), mob:getZPos(), mob:getRotPos())
        xi.limbus.showRecoverCrate(crateID)
    end
end

Limbus         = setmetatable({ }, { __index = Battlefield })
Limbus.__index = Limbus

---@diagnostic disable-next-line: duplicate-set-field
Limbus.__eq    = function(m1, m2)
    return m1.name == m2.name
end

Limbus.name = ''
Limbus.serverVar = ''

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:new(data)
    data.createsWornItem = false
    data.showTimer       = false
    local obj            = Battlefield:new(data)

    setmetatable(obj, self)
    obj.name          = data.name
    obj.ID            = zones[obj.zoneId][obj.name]
    obj.serverVar     = data.serverVar or ('[' .. obj.name .. ']Time')
    obj.exitLocation  = data.exitLocation or 0
    obj.timeExtension = data.timeExtension or 0

    return obj
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:register()
    Battlefield.register(self)

    if self.ID and self.ID.npc and self.ID.npc.RECOVER_CRATES then
        table.insert(self.groups, { mobIds = self.ID.npc.RECOVER_CRATES })
    end

    return self
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:onEventFinishEnter(player, csid, option, npc)
    Battlefield.onEventFinishEnter(self, player, csid, option)

    local battlefield    = player:getBattlefield()
    local initiatorId, _ = battlefield:getInitiator()

    if player:getID() == initiatorId then
        local zoneText = zones[player:getZoneID()].text
        local alliance   = player:getAlliance()

        for _, member in pairs(alliance) do
            if member:getZoneID() == player:getZoneID() then
                member:messageSpecial(zoneText.HUM)
            end
        end
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:onBattlefieldInitialize(battlefield)
    Battlefield.onBattlefieldInitialize(self, battlefield)
    SetServerVariable(self.serverVar, battlefield:getTimeLimit() / 60)
    self:closeDoors()

    local ID = zones[battlefield:getZoneID()][self.name]

    if ID.npc.ITEM_CRATES then
        for _, crateID in ipairs(ID.npc.ITEM_CRATES) do
            local crate = GetEntityByID(crateID)

            if crate then
                xi.limbus.hideCrate(crate)
                crate:addListener('ON_TRIGGER', 'TRIGGER_ITEM_CRATE', utils.bind(self.handleOpenItemCrate, self))
            end
        end
    end

    if ID.npc.TIME_CRATES then
        for _, crateID in ipairs(ID.npc.TIME_CRATES) do
            local crate = GetEntityByID(crateID)

            if crate then
                xi.limbus.hideCrate(crate)
                crate:addListener('ON_TRIGGER', 'TRIGGER_TIME_CRATE', utils.bind(self.handleOpenTimeCrate, self))
            end
        end
    end

    if ID.npc.RECOVER_CRATES then
        for _, crateID in ipairs(ID.npc.RECOVER_CRATES) do
            local crate = GetEntityByID(crateID)

            if crate then
                xi.limbus.hideCrate(crate)
                crate:setBattleID(1)
                crate:addListener('ON_TRIGGER', 'TRIGGER_RECOVER_CRATE', utils.bind(self.handleOpenRecoverCrate, self))
            end
        end
    end

    if self.lootCrateId then
        local crate = GetEntityByID(self.lootCrateId)

        if crate then
            xi.limbus.hideCrate(crate)
            crate:addListener('ON_TRIGGER', 'TRIGGER_LOOT_CRATE', utils.bind(self.handleOpenLootCrate, self))
        end
    end

    if ID.LINKED_CRATES then
        for crateID, _ in pairs(ID.LINKED_CRATES) do
            local mainCrate = GetEntityByID(crateID)

            if mainCrate then
                mainCrate:addListener('ON_TRIGGER', 'TRIGGER_LINKED_CRATE', utils.bind(self.handleLinkedCrate, self))
            end
        end
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:onBattlefieldTick(battlefield, tick)
    Battlefield.onBattlefieldTick(self, battlefield, tick)

    if battlefield:getRemainingTime() % 60 == 0 then
        SetServerVariable(self.serverVar, battlefield:getRemainingTime() / 60)
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:onBattlefieldRegister(player, battlefield)
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:onBattlefieldEnter(player, battlefield)
    Battlefield.onBattlefieldEnter(self, player, battlefield)
    player:setCharVar('Cosmo_Cleanse_TIME', GetSystemTime())
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:onBattlefieldDestroy(battlefield)
    SetServerVariable(self.serverVar, 0)
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:onBattlefieldWin(player, battlefield)
    player:startEvent(32001, { [0] = self.exitLocation, [4] = self.zoneId, [5] = battlefield:getArea() - 1 })
end

---@diagnostic disable-next-line: duplicate-set-field
function Limbus:onBattlefieldLeave(player, battlefield, leavecode)
    Battlefield.onBattlefieldLeave(self, player, battlefield, leavecode)

    local zoneText = zones[battlefield:getZoneID()].text
    player:messageSpecial(zoneText.HUM + 1)
end

function Limbus:extendTimeLimit(zoneTable, battlefield)
    local timeLimit = battlefield:getTimeLimit()
    battlefield:setTimeLimit(timeLimit + utils.minutes(self.timeExtension))

    local remaining = battlefield:getRemainingTime() / 60

    for _, p in pairs(battlefield:getPlayers()) do
        p:messageSpecial(zoneTable.text.TIME_EXTENDED, self.timeExtension)
        p:messageSpecial(zoneTable.text.TIME_LEFT, remaining)
    end
end

function Limbus:handleOpenItemCrate(player, crate)
    npcUtil.openCrate(crate, function()
        self:handleLootRolls(player:getBattlefield(), self.loot[crate:getID()], crate)
    end)
end

function Limbus:handleOpenTimeCrate(player, crate)
    npcUtil.openCrate(crate, function()
        self:extendTimeLimit(zones[self.zoneId], player:getBattlefield())
    end)
end

function Limbus:handleOpenRecoverCrate(player, crate)
    npcUtil.openCrate(crate, function()
        crate:useMobAbility(1531, player)
    end)
end

function Limbus:handleOpenLootCrate(player, crate)
    npcUtil.openCrate(crate, function()
        local battlefield = player:getBattlefield()

        self:handleLootRolls(battlefield, self.loot[self.lootCrateId], crate)
        battlefield:setLocalVar('cutsceneTimer', self.delayToExit)
        battlefield:setStatus(xi.battlefield.status.WON)
    end)
end

function Limbus:handleLinkedCrate(player, npc)
    for _, crateID in ipairs(self.ID.LINKED_CRATES[npc:getID()]) do
        local crate = GetEntityByID(crateID)

        if crate then
            crate:setLocalVar('opened', 1)
            npcUtil.disappearCrate(crate)
        end
    end
end

function Limbus:openDoor(battlefield, floor)
    local door = GetNPCByID(self.ID.npc.PORTAL[floor])

    if not door or door:getAnimation() == xi.animation.OPEN_DOOR then
        return
    end

    local zoneText  = zones[door:getZoneID()].text
    local remaining = battlefield:getRemainingTime() / 60

    for _, p in pairs(battlefield:getPlayers()) do
        p:messageSpecial(zoneText.GATE_OPEN)
        p:messageSpecial(zoneText.TIME_LEFT, remaining)
    end

    door:setAnimation(xi.animation.OPEN_DOOR)
end

function Limbus:closeDoors()
    if self.ID.npc.PORTAL then
        for _, doorID in ipairs(self.ID.npc.PORTAL) do
            local door = GetNPCByID(doorID)
            if door then
                door:setAnimation(xi.animation.CLOSE_DOOR)
            end
        end
    end
end

return xi.limbus
