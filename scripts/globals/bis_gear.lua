-----------------------------------
-- Best-in-slot gear selection for GM tooling
-- Uses curated job BiS lists (progression + endgame) then DB mod/level fallback.
-----------------------------------
require('scripts/globals/bis_gear_progression')
require('scripts/globals/bis_gear_loadouts')

xi = xi or {}
---@class xi.bisGear
xi.bis_gear = xi.bis_gear or {}

local ITEM_TYPE_EQUIPMENT = 8
local ITEM_TYPE_WEAPON    = 16
local MAX_ITEM_ID         = 32767
local MAX_LEVEL           = 75

-- Shared mod priorities used when a job has no dedicated profile.
local defaultModWeights =
{
    [xi.mod.ACC]        = 2,
    [xi.mod.ATT]        = 2,
    [xi.mod.RACC]       = 2,
    [xi.mod.RATT]       = 2,
    [xi.mod.HASTE_GEAR] = 4,
    [xi.mod.STORETP]    = 3,
    [xi.mod.STR]        = 1,
    [xi.mod.DEX]        = 1,
    [xi.mod.VIT]        = 1,
    [xi.mod.AGI]        = 1,
    [xi.mod.INT]        = 1,
    [xi.mod.MND]        = 1,
    [xi.mod.CHR]        = 1,
    [xi.mod.DEF]        = 1,
    [xi.mod.HP]         = 0.5,
    [xi.mod.MP]         = 0.5,
    [xi.mod.FASTCAST]   = 2,
    [xi.mod.ENMITY]     = 1,
}

-- Per-job stat priorities aligned to 75-cap role expectations.
local jobModWeights =
{
    [xi.job.WAR] =
    {
        [xi.mod.STORETP]    = 6,
        [xi.mod.HASTE_GEAR] = 6,
        [xi.mod.ACC]        = 5,
        [xi.mod.ATT]        = 4,
        [xi.mod.STR]        = 3,
        [xi.mod.ENMITY]     = 2,
        [xi.mod.DOUBLE_ATTACK] = 2,
    },
    [xi.job.MNK] =
    {
        [xi.mod.ACC]             = 5,
        [xi.mod.HASTE_GEAR]      = 5,
        [xi.mod.ATT]             = 4,
        [xi.mod.SUBTLE_BLOW]     = 4,
        [xi.mod.KICK_ATTACK_RATE] = 3,
        [xi.mod.STR]             = 2,
    },
    [xi.job.WHM] =
    {
        [xi.mod.CURE_POTENCY] = 6,
        [xi.mod.MND]          = 5,
        [xi.mod.FASTCAST]     = 5,
        [xi.mod.HASTE_GEAR]   = 4,
        [xi.mod.ENMITY]       = -2,
        [xi.mod.MP]           = 3,
        [xi.mod.MPP]          = 2,
        [xi.mod.HEALING]      = 4,
        [xi.mod.HPHEAL]       = 2,
    },
    [xi.job.BLM] =
    {
        [xi.mod.INT]       = 6,
        [xi.mod.MATT]      = 6,
        [xi.mod.MACC]      = 4,
        [xi.mod.FASTCAST]  = 5,
        [xi.mod.MP]        = 4,
        [xi.mod.SPELLINTERRUPT] = 3,
        [xi.mod.FIRE_MAB]  = 2,
        [xi.mod.ICE_MAB]   = 2,
        [xi.mod.WIND_MAB]  = 2,
        [xi.mod.EARTH_MAB] = 2,
        [xi.mod.WATER_MAB] = 2,
        [xi.mod.THUNDER_MAB] = 2,
    },
    [xi.job.RDM] =
    {
        [xi.mod.MACC]       = 6,
        [xi.mod.ENFEEBLE]   = 5,
        [xi.mod.FASTCAST]   = 5,
        [xi.mod.HASTE_GEAR] = 3,
        [xi.mod.ACC]        = 3,
        [xi.mod.MND]        = 3,
        [xi.mod.INT]        = 3,
        [xi.mod.MP]         = 2,
    },
    [xi.job.THF] =
    {
        [xi.mod.ACC]           = 5,
        [xi.mod.DEX]           = 4,
        [xi.mod.HASTE_GEAR]    = 5,
        [xi.mod.STORETP]       = 3,
        [xi.mod.TRIPLE_ATTACK] = 4,
    },
    [xi.job.PLD] =
    {
        [xi.mod.ENMITY]     = 6,
        [xi.mod.DEF]        = 4,
        [xi.mod.VIT]        = 3,
        [xi.mod.SHIELD]     = 5,
        [xi.mod.HP]         = 2,
        [xi.mod.ACC]        = 2,
    },
    [xi.job.DRK] =
    {
        [xi.mod.ATT]        = 5,
        [xi.mod.ACC]        = 4,
        [xi.mod.HASTE_GEAR] = 4,
        [xi.mod.STORETP]    = 3,
        [xi.mod.DARK]       = 3,
        [xi.mod.STR]        = 2,
    },
    [xi.job.BST] =
    {
        [xi.mod.PET_ACC_EVA]     = 6,
        [xi.mod.PET_ATK_DEF]     = 6,
        [xi.mod.CHR]             = 5,
        [xi.mod.REWARD_HP_BONUS] = 5,
        [xi.mod.ACC]             = 3,
        [xi.mod.ATT]             = 2,
        [xi.mod.STORETP]         = 2,
    },
    [xi.job.BRD] =
    {
        [xi.mod.CHR]        = 5,
        [xi.mod.SINGING]    = 5,
        [xi.mod.STRING]     = 5,
        [xi.mod.HASTE_GEAR] = 3,
        [xi.mod.ENMITY]     = -2,
    },
    [xi.job.RNG] =
    {
        [xi.mod.RACC]    = 6,
        [xi.mod.RATT]    = 5,
        [xi.mod.AGI]     = 4,
        [xi.mod.SNAPSHOT] = 4,
        [xi.mod.STORETP] = 2,
    },
    [xi.job.SAM] =
    {
        [xi.mod.STORETP]    = 6,
        [xi.mod.ACC]        = 5,
        [xi.mod.HASTE_GEAR] = 5,
        [xi.mod.ZANSHIN]    = 4,
        [xi.mod.ATT]        = 3,
    },
    [xi.job.NIN] =
    {
        [xi.mod.ACC]        = 5,
        [xi.mod.HASTE_GEAR] = 5,
        [xi.mod.NINJUTSU]   = 5,
        [xi.mod.DUAL_WIELD] = 4,
        [xi.mod.EVASION]    = 3,
    },
    [xi.job.DRG] =
    {
        [xi.mod.ACC]          = 5,
        [xi.mod.ATT]          = 4,
        [xi.mod.HASTE_GEAR]   = 4,
        [xi.mod.STORETP]      = 3,
        [xi.mod.JUMP_TP_BONUS] = 4,
        [xi.mod.STR]          = 2,
    },
    [xi.job.SMN] =
    {
        -- Leveling SMN: stack MP/perpetuation reduction; avatars + Carbuncle sustain.
        [xi.mod.MP]                         = 8,
        [xi.mod.HALF_PERPETUATION_CARBUNCLE] = 12,
        [xi.mod.PERPETUATION_REDUCTION]     = 8,
        [xi.mod.AVATAR_PERPETUATION]        = -4,
        [xi.mod.SUMMONING]                  = 6,
        [xi.mod.SPELLINTERRUPT]             = 5,
        [xi.mod.MND]                        = 4,
        [xi.mod.MACC]                       = 4,
        [xi.mod.INT]                        = 3,
        [xi.mod.PET_MAB_MDB]                = 3,
        [xi.mod.PET_ACC_EVA]                = 3,
        [xi.mod.FASTCAST]                   = 3,
    },
    [xi.job.BLU] =
    {
        [xi.mod.BLUE]       = 6,
        [xi.mod.ACC]        = 4,
        [xi.mod.MACC]       = 3,
        [xi.mod.ATT]        = 3,
        [xi.mod.FASTCAST]   = 2,
    },
    [xi.job.COR] =
    {
        [xi.mod.RACC]            = 6,
        [xi.mod.RATT]            = 5,
        [xi.mod.SNAPSHOT]        = 5,
        [xi.mod.QUICK_DRAW_MACC] = 5,
        [xi.mod.AGI]             = 3,
        [xi.mod.STORETP]         = 2,
    },
    [xi.job.PUP] =
    {
        [xi.mod.PET_ACC_EVA]      = 6,
        [xi.mod.PET_ATK_DEF]      = 6,
        [xi.mod.AUTO_MELEE_SKILL] = 6,
        [xi.mod.HP]               = 3,
        [xi.mod.ACC]              = 2,
        [xi.mod.ATT]              = 2,
    },
    [xi.job.DNC] =
    {
        [xi.mod.ACC]          = 5,
        [xi.mod.HASTE_GEAR]   = 5,
        [xi.mod.STORETP]      = 3,
        [xi.mod.STEP_ACCURACY] = 4,
        [xi.mod.CHR]          = 2,
    },
    [xi.job.SCH] =
    {
        [xi.mod.MND]          = 5,
        [xi.mod.INT]          = 5,
        [xi.mod.FASTCAST]     = 5,
        [xi.mod.MP]           = 4,
        [xi.mod.CURE_POTENCY] = 3,
        [xi.mod.MACC]         = 3,
        [xi.mod.SPELLINTERRUPT] = 3,
    },
    [xi.job.GEO] =
    {
        [xi.mod.MND]            = 6,
        [xi.mod.GEOMANCY_SKILL] = 6,
        [xi.mod.MACC]           = 4,
        [xi.mod.FASTCAST]       = 4,
        [xi.mod.MP]             = 4,
        [xi.mod.INT]            = 2,
    },
    [xi.job.RUN] =
    {
        [xi.mod.ENMITY] = 5,
        [xi.mod.DEF]    = 4,
        [xi.mod.VIT]    = 3,
        [xi.mod.MEVA]   = 3,
        [xi.mod.HP]     = 2,
    },
}

local weaponDpsWeight =
{
    [xi.job.WAR]  = 4,
    [xi.job.MNK]  = 3,
    [xi.job.DRK]  = 4,
    [xi.job.SAM]  = 4,
    [xi.job.NIN]  = 3,
    [xi.job.DRG]  = 4,
    [xi.job.THF]  = 3,
    [xi.job.RDM]  = 2,
    [xi.job.PLD]  = 2,
    [xi.job.DNC]  = 3,
    [xi.job.BLU]  = 3,
    [xi.job.RNG]  = 5,
    [xi.job.COR]  = 5,
    [xi.job.SMN]  = 0,
    [xi.job.BLM]  = 0,
    [xi.job.WHM]  = 0,
    [xi.job.SCH]  = 0,
    [xi.job.GEO]  = 0,
    default       = 2,
}

-- Weapon skills allowed per job/slot (from item_weapon.skill in DB).
local jobMainSkills =
{
    [xi.job.WAR]  = { [xi.skill.AXE] = true, [xi.skill.GREAT_AXE] = true, [xi.skill.GREAT_SWORD] = true, [xi.skill.POLEARM] = true, [xi.skill.SCYTHE] = true },
    [xi.job.MNK]  = { [xi.skill.HAND_TO_HAND] = true },
    [xi.job.WHM]  = { [xi.skill.CLUB] = true, [xi.skill.STAFF] = true },
    [xi.job.BLM]  = { [xi.skill.STAFF] = true, [xi.skill.CLUB] = true },
    [xi.job.RDM]  = { [xi.skill.SWORD] = true, [xi.skill.STAFF] = true, [xi.skill.CLUB] = true },
    [xi.job.THF]  = { [xi.skill.DAGGER] = true, [xi.skill.HAND_TO_HAND] = true },
    [xi.job.PLD]  = { [xi.skill.SWORD] = true, [xi.skill.GREAT_SWORD] = true, [xi.skill.CLUB] = true },
    [xi.job.DRK]  = { [xi.skill.SCYTHE] = true, [xi.skill.GREAT_SWORD] = true, [xi.skill.AXE] = true, [xi.skill.GREAT_AXE] = true },
    [xi.job.BST]  = { [xi.skill.AXE] = true, [xi.skill.GREAT_AXE] = true, [xi.skill.SCYTHE] = true },
    [xi.job.BRD]  = { [xi.skill.DAGGER] = true, [xi.skill.SWORD] = true, [xi.skill.STAFF] = true, [xi.skill.CLUB] = true },
    [xi.job.RNG]  = { [xi.skill.ARCHERY] = true, [xi.skill.MARKSMANSHIP] = true },
    [xi.job.SAM]  = { [xi.skill.GREAT_KATANA] = true, [xi.skill.KATANA] = true, [xi.skill.POLEARM] = true },
    [xi.job.NIN]  = { [xi.skill.KATANA] = true, [xi.skill.DAGGER] = true, [xi.skill.HAND_TO_HAND] = true },
    [xi.job.DRG]  = { [xi.skill.POLEARM] = true, [xi.skill.SCYTHE] = true },
    [xi.job.SMN]  = { [xi.skill.STAFF] = true, [xi.skill.CLUB] = true },
    [xi.job.BLU]  = { [xi.skill.SWORD] = true, [xi.skill.DAGGER] = true, [xi.skill.CLUB] = true, [xi.skill.STAFF] = true },
    [xi.job.COR]  = { [xi.skill.MARKSMANSHIP] = true },
    [xi.job.PUP]  = { [xi.skill.HAND_TO_HAND] = true, [xi.skill.CLUB] = true, [xi.skill.AXE] = true },
    [xi.job.DNC]  = { [xi.skill.DAGGER] = true, [xi.skill.HAND_TO_HAND] = true, [xi.skill.SWORD] = true },
    [xi.job.SCH]  = { [xi.skill.STAFF] = true, [xi.skill.CLUB] = true },
    [xi.job.GEO]  = { [xi.skill.STAFF] = true, [xi.skill.CLUB] = true },
    [xi.job.RUN]  = { [xi.skill.SWORD] = true, [xi.skill.GREAT_SWORD] = true, [xi.skill.CLUB] = true },
}

local jobRangedSkills =
{
    [xi.job.RNG] = { [xi.skill.ARCHERY] = true, [xi.skill.MARKSMANSHIP] = true },
    [xi.job.COR] = { [xi.skill.MARKSMANSHIP] = true },
}

-- Wearable grant slots: weapons, armor, accessories only (no ammo; ranged weapon slot only for RNG/COR).
local slotsToFill =
{
    xi.slot.MAIN,
    xi.slot.SUB,
    xi.slot.RANGED,
    xi.slot.HEAD,
    xi.slot.BODY,
    xi.slot.HANDS,
    xi.slot.LEGS,
    xi.slot.FEET,
    xi.slot.NECK,
    xi.slot.WAIST,
    xi.slot.EAR1,
    xi.slot.EAR2,
    xi.slot.RING1,
    xi.slot.RING2,
    xi.slot.BACK,
}

local slotLabels =
{
    [xi.slot.MAIN]   = 'Main',
    [xi.slot.SUB]    = 'Sub',
    [xi.slot.RANGED] = 'Ranged',
    [xi.slot.AMMO]   = 'Ammo',
    [xi.slot.HEAD]   = 'Head',
    [xi.slot.BODY]   = 'Body',
    [xi.slot.HANDS]  = 'Hands',
    [xi.slot.LEGS]   = 'Legs',
    [xi.slot.FEET]   = 'Feet',
    [xi.slot.NECK]   = 'Neck',
    [xi.slot.WAIST]  = 'Waist',
    [xi.slot.EAR1]   = 'Ear',
    [xi.slot.EAR2]   = 'Ear',
    [xi.slot.RING1]  = 'Ring',
    [xi.slot.RING2]  = 'Ring',
    [xi.slot.BACK]   = 'Back',
}

-- Jobs that should prefer stat/mod usefulness over weapon DPS and raw item level.
local jobPrefersModScore =
{
    [xi.job.SMN] = true,
    [xi.job.BLM] = true,
    [xi.job.WHM] = true,
    [xi.job.SCH] = true,
    [xi.job.GEO] = true,
    [xi.job.RDM] = true,
}

local jobUsesSlot =
{
    [xi.slot.SUB] = function(job)
        return job == xi.job.PLD or job == xi.job.RUN or job == xi.job.RDM or job == xi.job.NIN
    end,
    [xi.slot.RANGED] = function(job)
        return job == xi.job.RNG or job == xi.job.COR
    end,
}

local pairedSlots =
{
    [xi.slot.EAR2]  = xi.slot.EAR1,
    [xi.slot.RING2] = xi.slot.RING1,
}

---@param item CItem
---@return boolean
local function isGearItem(item)
    return item:isType(ITEM_TYPE_EQUIPMENT) or item:isType(ITEM_TYPE_WEAPON)
end

---@param item CItem
---@return boolean
local function isWearableGrantItem(item)
    if not isGearItem(item) then
        return false
    end

    local slotMask = item:getEquipSlotId()
    if slotMask <= 0 then
        return false
    end

    -- Exclude ammo-only items (arrows, bullets, shuriken stacks, etc.).
    local ammoMask = bit.lshift(1, xi.slot.AMMO)
    if slotMask == ammoMask then
        return false
    end

    return true
end

---@param player CBaseEntity
---@param itemId integer
---@param checkLevel boolean|nil
---@return boolean
local function canPlayerEquip(player, itemId, checkLevel)
    local item = GetReadOnlyItem(itemId)
    if not item or not isWearableGrantItem(item) then
        return false
    end

    return player:canEquipItem(itemId, checkLevel or false)
end

---@param job integer
---@return table<integer, number>
local function getModWeights(job)
    local weights = {}

    for modId, weight in pairs(defaultModWeights) do
        weights[modId] = weight
    end

    local jobWeights = jobModWeights[job]
    if jobWeights then
        for modId, weight in pairs(jobWeights) do
            weights[modId] = weight
        end
    end

    return weights
end

---@param itemId integer
---@return boolean
local function isStarterItem(itemId)
    return xi.bis_gear_progression.starterItemIds[itemId] == true
end

---@param item CItem
---@return boolean
local function isExcludedGear(itemId, item)
    if isStarterItem(itemId) then
        return true
    end

    local name = item:getName():lower()

    if
        name:find('onion') or
        name:find('tarutaru') or
        name:find('hume_') or
        name:find('elvaan') or
        name:find('mithra') or
        name:find('galka_') or
        name:find('windurstian_ring') or
        name:find('sandoria_ring') or
        name:find('bastokan_ring') or
        name:find('federation_aketon') or
        name:find('kingdom_aketon') or
        name:find('republic_aketon') or
        name:find('windurstian_') or
        name:find('federation_') or
        name:find('republic_') or
        name:find('kingdom_') or
        name:find('san_dorian') or
        name:find('bastokan_') or
        name:find('cobra_') or
        name:find('erudite') or
        name:find('i%.r%.') or
        name:find('treat_staff') or
        name:find('nomads_')
    then
        return true
    end

    return false
end

---@param job integer
---@param slot integer
---@param item CItem
---@return boolean
local function isWeaponAllowedForSlot(job, slot, item)
    if slot ~= xi.slot.MAIN and slot ~= xi.slot.SUB and slot ~= xi.slot.RANGED then
        return true
    end

    if not item:isType(ITEM_TYPE_WEAPON) then
        return slot == xi.slot.SUB or slot == xi.slot.AMMO
    end

    if slot == xi.slot.SUB and item:isShield() then
        return job == xi.job.PLD or job == xi.job.RUN or job == xi.job.RDM
    end

    local skill = item:getSkillType()
    if skill == 0 or skill == xi.skill.NONE then
        return true
    end

    local allowed = jobMainSkills[job]
    if slot == xi.slot.RANGED then
        allowed = jobRangedSkills[job]
    end

    if not allowed then
        return true
    end

    return allowed[skill] == true
end

---@param player CBaseEntity
---@param slot integer|nil
---@return integer
local function minReqForFallback(player, slot)
    local level   = player:getMainLvl()
    local tierMin = xi.bis_gear_progression.getTierMinLevel(player:getMainJob(), level)
    local floor   = math.max(1, tierMin - 8)

    if slot == xi.slot.MAIN or slot == xi.slot.RANGED then
        floor = math.max(1, floor - 5)
    end

    return floor
end

---@param item CItem
---@return boolean
local function isRareOrExclusive(item)
    local flag = item:getFlag()
    return bit.band(flag, xi.itemFlag.RARE) ~= 0 or bit.band(flag, xi.itemFlag.EXCLUSIVE) ~= 0
end

---@param player CBaseEntity
---@param itemId integer
---@return boolean
local function playerOwnsItem(player, itemId)
    if player:getItemCount(itemId) > 0 then
        return true
    end

    for _, slot in ipairs(slotsToFill) do
        if player:getEquipID(slot) == itemId then
            return true
        end
    end

    return false
end

---@param player CBaseEntity
---@param itemId integer
---@param reservedItemIds table<integer, boolean>
---@return boolean
local function isItemReserved(player, itemId, reservedItemIds)
    if playerOwnsItem(player, itemId) then
        return true
    end

    if reservedItemIds[itemId] then
        return true
    end

    return false
end

---@param itemId integer
---@param reservedItemIds table<integer, boolean>
local function reserveItem(itemId, reservedItemIds)
    reservedItemIds[itemId] = true
end

---@param player CBaseEntity
---@param itemId integer
---@return boolean
local function isEligible(player, itemId)
    local item = GetReadOnlyItem(itemId)
    if not item or not isWearableGrantItem(item) then
        return false
    end

    if isExcludedGear(itemId, item) then
        return false
    end

    if not canPlayerEquip(player, itemId, false) then
        return false
    end

    local reqLevel = item:getReqLvl()
    local level    = player:getMainLvl()

    if reqLevel > level or reqLevel > MAX_LEVEL then
        return false
    end

    local suLevel = item:getSuperiorLevel()
    if suLevel > 0 and player:getMod(xi.mod.SUPERIOR_LEVEL) < suLevel then
        return false
    end

    return true
end

---@param player CBaseEntity
---@param itemId integer
---@param slot integer
---@return boolean
local function isEligibleForSlot(player, itemId, slot)
    if not isEligible(player, itemId) then
        return false
    end

    local item = GetReadOnlyItem(itemId)
    if not item then
        return false
    end

    if not isWeaponAllowedForSlot(player:getMainJob(), slot, item) then
        return false
    end

    local reqLevel = item:getReqLvl()
    if reqLevel < minReqForFallback(player, slot) then
        return false
    end

    local slotMask = bit.lshift(1, slot)
    return bit.band(item:getEquipSlotId(), slotMask) ~= 0
end

---@param item CItem
---@param job integer
---@param slot integer
---@return number
local function getJobScore(item, job, slot)
    local score      = 0
    local jobWeights = jobModWeights[job]

    if jobWeights then
        for modId, weight in pairs(jobWeights) do
            local value = item:getMod(modId)
            if value ~= 0 then
                score = score + (value * weight)
            end
        end
    end

    if
        slot == xi.slot.MAIN or
        slot == xi.slot.SUB or
        slot == xi.slot.RANGED
    then
        local damage = item:getWeaponDamage()
        local delay  = item:getWeaponDelay()
        if damage > 0 and delay > 0 then
            local dpsWeight = weaponDpsWeight[job] or weaponDpsWeight.default
            score = score + ((damage * 1000) / delay) * dpsWeight
        end
    end

    if job == xi.job.PLD and slot == xi.slot.SUB and item:isShield() then
        score = score + 25 + (item:getShieldSize() * 5)
    end

    return score
end

---@param item CItem
---@param job integer
---@return number
local function getFallbackScore(item, job)
    local weights = getModWeights(job)
    local score   = 0

    for modId, weight in pairs(weights) do
        local value = item:getMod(modId)
        if value ~= 0 then
            score = score + (value * weight)
        end
    end

    return score
end

---@param player CBaseEntity
---@param item CItem
---@param job integer
---@param slot integer
---@return number jobScore
---@return number fallbackScore
---@return number reqLevel
local function scoreItem(player, item, job, slot)
    local jobScore      = getJobScore(item, job, slot)
    local fallbackScore = getFallbackScore(item, job)
    local reqLevel      = item:getReqLvl()

    if jobScore <= 0 then
        fallbackScore = fallbackScore * 0.1
    end

    return jobScore, fallbackScore, reqLevel
end

---@param player CBaseEntity
---@param itemId integer
---@param slot integer
---@return boolean
local function isCuratedEligibleForSlot(player, itemId, slot)
    if not isEligible(player, itemId) then
        return false
    end

    local item = GetReadOnlyItem(itemId)
    if not item then
        return false
    end

    if not isWeaponAllowedForSlot(player:getMainJob(), slot, item) then
        return false
    end

    local slotMask = bit.lshift(1, slot)
    return bit.band(item:getEquipSlotId(), slotMask) ~= 0
end

---@param player CBaseEntity
---@param slot integer
---@return integer[]
local function getCuratedCandidates(player, slot)
    local job   = player:getMainJob()
    local level = player:getMainLvl()
    local endgame = xi.bis_gear_loadouts.byJob[job]
    local endgameList = endgame and endgame[slot] or nil

    local merged = xi.bis_gear_progression.getCandidates(job, level, slot, endgameList)
    local filtered = {}

    for _, itemId in ipairs(merged) do
        local item = GetReadOnlyItem(itemId)
        if item and item:getReqLvl() <= level then
            table.insert(filtered, itemId)
        end
    end

    return filtered
end

---@param player CBaseEntity
---@param slot integer
---@param reservedItemIds table<integer, boolean>
---@return integer|nil itemId
local function pickCuratedForSlot(player, slot, reservedItemIds)
    local bestId  = nil
    local bestReq = -1

    for _, itemId in ipairs(getCuratedCandidates(player, slot)) do
        if not isItemReserved(player, itemId, reservedItemIds) and isCuratedEligibleForSlot(player, itemId, slot) then
            local item = GetReadOnlyItem(itemId)
            local req  = item and item:getReqLvl() or 0
            if req > bestReq then
                bestReq = req
                bestId  = itemId
            end
        end
    end

    return bestId
end

---@param player CBaseEntity
---@param slot integer
---@param reservedItemIds table<integer, boolean>
---@return integer|nil itemId
---@return number score
local function findBestForSlot(player, slot, reservedItemIds)
    local job = player:getMainJob()

    local curatedId = pickCuratedForSlot(player, slot, reservedItemIds)
    if curatedId then
        local item = GetReadOnlyItem(curatedId)
        return curatedId, item and getJobScore(item, job, slot) or 0
    end

    xi.bis_gear.ensureCache()

    local job              = player:getMainJob()
    local slotMask         = bit.lshift(1, slot)
    local bestItemId       = nil
    local bestJobScore     = -math.huge
    local bestFallback     = -math.huge
    local bestReq          = -1
    local candidateList    = xi.bis_gear.equipmentBySlot[slot]
    local preferModScore   = jobPrefersModScore[job] == true
    local requireJobScore  = preferModScore and (slot == xi.slot.MAIN or slot == xi.slot.RANGED)
    local bestPositiveId   = nil
    local bestPositiveScore = -math.huge
    local bestPositiveFallback = -math.huge
    local bestPositiveReq  = -1

    for _, itemId in ipairs(candidateList) do
        if not isItemReserved(player, itemId, reservedItemIds) and isEligibleForSlot(player, itemId, slot) then
            local item = GetReadOnlyItem(itemId)
            if item and bit.band(item:getEquipSlotId(), slotMask) ~= 0 then
                local jobScore, fallbackScore, req = scoreItem(player, item, job, slot)

                if requireJobScore and jobScore > 0 then
                    if
                        jobScore > bestPositiveScore or
                        (jobScore == bestPositiveScore and req > bestPositiveReq) or
                        (jobScore == bestPositiveScore and req == bestPositiveReq and fallbackScore > bestPositiveFallback)
                    then
                        bestPositiveScore    = jobScore
                        bestPositiveFallback = fallbackScore
                        bestPositiveReq      = req
                        bestPositiveId       = itemId
                    end
                end

                if preferModScore then
                    if
                        jobScore > bestJobScore or
                        (jobScore == bestJobScore and req > bestReq) or
                        (jobScore == bestJobScore and req == bestReq and fallbackScore > bestFallback)
                    then
                        bestJobScore  = jobScore
                        bestFallback  = fallbackScore
                        bestReq       = req
                        bestItemId    = itemId
                    end
                elseif
                    req > bestReq or
                    (req == bestReq and jobScore > bestJobScore) or
                    (req == bestReq and jobScore == bestJobScore and fallbackScore > bestFallback)
                then
                    bestReq      = req
                    bestJobScore = jobScore
                    bestFallback = fallbackScore
                    bestItemId   = itemId
                end
            end
        end
    end

    if requireJobScore and bestPositiveId then
        return bestPositiveId, bestPositiveScore
    end

    return bestItemId, bestJobScore
end

xi.bis_gear.ensureCache = function()
    if xi.bis_gear.equipmentBySlot then
        return
    end

    xi.bis_gear.equipmentBySlot = {}

    for slot = 0, xi.MAX_SLOTID do
        xi.bis_gear.equipmentBySlot[slot] = {}
    end

    for itemId = 1, MAX_ITEM_ID do
        local item = GetReadOnlyItem(itemId)
        if item and isWearableGrantItem(item) then
            local slotMask = item:getEquipSlotId()
            for slot = 0, xi.MAX_SLOTID do
                if slot ~= xi.slot.AMMO and bit.band(slotMask, bit.lshift(1, slot)) ~= 0 then
                    table.insert(xi.bis_gear.equipmentBySlot[slot], itemId)
                end
            end
        end
    end

    local function sortByReqDesc(a, b)
        local reqA = GetReadOnlyItem(a):getReqLvl()
        local reqB = GetReadOnlyItem(b):getReqLvl()
        return reqA > reqB
    end

    for slot = 0, xi.MAX_SLOTID do
        table.sort(xi.bis_gear.equipmentBySlot[slot], sortByReqDesc)
    end
end

---@param player CBaseEntity
---@return table<integer, integer> slot -> itemId
---@return table<integer, number> slot -> score
xi.bis_gear.findLoadout = function(player)
    local loadout         = {}
    local scores          = {}
    local reservedItemIds = {}
    local job             = player:getMainJob()

    for _, slot in ipairs(slotsToFill) do
        local usesSlot = jobUsesSlot[slot]
        if not usesSlot or usesSlot(job) then
            local pairedSlot = pairedSlots[slot]
            local itemId     = nil
            local itemScore  = nil

            if pairedSlot and loadout[pairedSlot] then
                local pairedItemId = loadout[pairedSlot]
                if not isItemReserved(player, pairedItemId, reservedItemIds) then
                    itemId    = pairedItemId
                    itemScore = scores[pairedSlot]
                end
            end

            if not itemId then
                itemId, itemScore = findBestForSlot(player, slot, reservedItemIds)
            end

            if itemId then
                loadout[slot] = itemId
                scores[slot]  = itemScore
                reserveItem(itemId, reservedItemIds)
            end
        end
    end

    local mainItem = loadout[xi.slot.MAIN] and GetReadOnlyItem(loadout[xi.slot.MAIN])
    if mainItem and mainItem:isTwoHanded() then
        loadout[xi.slot.SUB] = nil
        scores[xi.slot.SUB]  = nil
    end

    return loadout, scores
end

---@param player CBaseEntity
---@param loadout table<integer, integer>
---@return integer
xi.bis_gear.countGrantable = function(player, loadout)
    local count      = 0
    local countedIds = {}

    for _, slot in ipairs(slotsToFill) do
        local itemId = loadout[slot]
        if itemId and not countedIds[itemId] and not playerOwnsItem(player, itemId) then
            countedIds[itemId] = true
            count = count + 1
        end
    end

    return count
end

---@param gm CBaseEntity
---@param player CBaseEntity
---@param loadout table<integer, integer>
---@return integer granted
---@return integer failed
---@return string[] messages
xi.bis_gear.grantLoadout = function(gm, player, loadout)
    local granted  = 0
    local failed   = 0
    local skipped  = 0
    local messages = {}
    local grantedIds = {}

    for _, slot in ipairs(slotsToFill) do
        local itemId = loadout[slot]
        if itemId and not grantedIds[itemId] then
            if playerOwnsItem(player, itemId) then
                skipped = skipped + 1
                local item = GetReadOnlyItem(itemId)
                local name = item and item:getName() or tostring(itemId)
                table.insert(messages, string.format('Skipped %s: %s (already owned).', slotLabels[slot] or tostring(slot), name))
            elseif player:getFreeSlotsCount() == 0 then
                table.insert(messages, string.format('Inventory full; stopped before %s.', slotLabels[slot] or tostring(slot)))
                break
            elseif player:addItem(itemId) then
                granted = granted + 1
                grantedIds[itemId] = true

                local item = GetReadOnlyItem(itemId)
                local name = item and item:getName() or tostring(itemId)
                table.insert(messages, string.format('%s: %s (Lv.%u)', slotLabels[slot] or tostring(slot), name, item:getReqLvl()))

                local ID = zones[player:getZoneID()]
                player:messageSpecial(ID.text.ITEM_OBTAINED, itemId)
            else
                failed = failed + 1
                table.insert(messages, string.format('Failed to add %s (id %u).', slotLabels[slot] or tostring(slot), itemId))
            end
        end
    end

    return granted, failed, messages, skipped
end

---@param slot integer
---@return string
xi.bis_gear.getSlotLabel = function(slot)
    return slotLabels[slot] or ('Slot ' .. tostring(slot))
end
