-----------------------------------
-- Imagine XI 2.0: wearing an avatar's equipment summons that avatar
-- when the player engages. Several pieces at once use the one equipped
-- last. A piece already out stays; taking it off, or disengaging,
-- sends that avatar away. A wyvern, jug, or a summon the player called
-- themselves keeps the pet slot.
--
-- Level matching is Ixi20SpawnGearAvatar in ixi20_avatar_equip.cpp.
-- The gear avatar stands beside the pet slot, so a summoner can
-- have their own avatar out at the same time.
-- While it is out it spends its own blood pacts: heals and wards
-- first, then a debuff, then a damage pact. Those pacts do not
-- spend the wearer's MP.
-- Rebuild xi_map after adding that file.
-- FileWatcher drops addOverride; the assignment wraps stay live.
-----------------------------------
require('modules/module_utils')
require('scripts/globals/gear_sets')
require('scripts/globals/player')
require('scripts/globals/job_utils/summoner')
require('scripts/globals/pets')
-----------------------------------

local m = Module:new('ixi20_avatar_equip')

local GEAR_PET_LOCAL = 'IXI20_GEAR_AVATAR'
local GEAR_PET_CHAR  = 'IXI20_GEAR_AVATAR_PET'
local LATEST_ITEM    = 'IXI20_AVATAR_LATEST_ITEM'
local RETRY_AT       = 'IXI20_GEAR_AVATAR_RETRY'
local PACT_GEN       = 'IXI20_GEAR_PACT_GEN'
local PACT_STEP      = 'IXI20_GEAR_PACT_STEP'
local ANNOUNCED_ID   = 'IXI20_GEAR_AVATAR_SAID'
local DEBUFF_FOE     = 'IXI20_GEAR_DEBUFF_FOE'
local GEAR_CAST      = 'IXI20_GEAR_PACT_CAST'

local PACT_RADIUS = 14
local PACT_DELAY  = 7

local LISTENER_ENGAGE    = 'IXI20_AVATAR_EQUIP_ENGAGE'
local LISTENER_DISENGAGE = 'IXI20_AVATAR_EQUIP_DISENGAGE'
local LISTENER_ATTACK    = 'IXI20_AVATAR_EQUIP_ATTACK'
local LISTENER_DEATH     = 'IXI20_AVATAR_EQUIP_DEATH'

local arrivalLines =
{
    [xi.petId.CARBUNCLE] = 'Light gathers.',
    [xi.petId.FENRIR]    = 'The moon is risen.',
    [xi.petId.IFRIT]     = 'Flames, heed me!',
    [xi.petId.TITAN]     = 'The earth itself stands with you!',
    [xi.petId.LEVIATHAN] = 'The tide turns.',
    [xi.petId.GARUDA]    = 'Winds, rise!',
    [xi.petId.SHIVA]     = 'Winter comes.',
    [xi.petId.RAMUH]     = 'Thunder answers.',
    [xi.petId.DIABOLOS]  = 'Dreams end.',
    [xi.petId.CAIT_SITH] = 'The cards are drawn.',
}

local avatarNames =
{
    [xi.petId.CARBUNCLE] = 'Carbuncle',
    [xi.petId.FENRIR]    = 'Fenrir',
    [xi.petId.IFRIT]     = 'Ifrit',
    [xi.petId.TITAN]     = 'Titan',
    [xi.petId.LEVIATHAN] = 'Leviathan',
    [xi.petId.GARUDA]    = 'Garuda',
    [xi.petId.SHIVA]     = 'Shiva',
    [xi.petId.RAMUH]     = 'Ramuh',
    [xi.petId.DIABOLOS]  = 'Diabolos',
    [xi.petId.CAIT_SITH] = 'Cait Sith',
}

-- Item id -> pet id. Armor and weapons named for that avatar.
local avatarItems =
{
    [14062] = xi.petId.CARBUNCLE, -- Carbuncle Mitts
    [14931] = xi.petId.CARBUNCLE, -- Carbuncle's Cuffs
    [18581] = xi.petId.CARBUNCLE, -- Carbuncle's Pole
    [27576] = xi.petId.CARBUNCLE, -- Carbuncle Ring
    [27577] = xi.petId.CARBUNCLE, -- Carbuncle Ring +1

    [11496] = xi.petId.FENRIR, -- Fenrir's Crown
    [13138] = xi.petId.FENRIR, -- Fenrir's Torque
    [13399] = xi.petId.FENRIR, -- Fenrir's Earring
    [13572] = xi.petId.FENRIR, -- Fenrir's Cape
    [18165] = xi.petId.FENRIR, -- Fenrir's Stone
    [27578] = xi.petId.FENRIR, -- Fenrir Ring
    [27579] = xi.petId.FENRIR, -- Fenrir Ring +1

    [17192] = xi.petId.IFRIT, -- Ifrit's Bow
    [17665] = xi.petId.IFRIT, -- Ifrit's Blade
    [27564] = xi.petId.IFRIT, -- Ifrit Ring
    [27565] = xi.petId.IFRIT, -- Ifrit Ring +1

    [17438] = xi.petId.TITAN, -- Titan's Cudgel
    [18021] = xi.petId.TITAN, -- Titan's Baselarde
    [27570] = xi.petId.TITAN, -- Titan Ring
    [27571] = xi.petId.TITAN, -- Titan Ring +1

    [17439] = xi.petId.LEVIATHAN, -- Leviathan's Rod
    [18109] = xi.petId.LEVIATHAN, -- Leviathan's Couse
    [27566] = xi.petId.LEVIATHAN, -- Leviathan Ring
    [27567] = xi.petId.LEVIATHAN, -- Leviathan Ring +1

    [17627] = xi.petId.GARUDA, -- Garuda's Dagger
    [18063] = xi.petId.GARUDA, -- Garuda's Sickle
    [27572] = xi.petId.GARUDA, -- Garuda Ring
    [27573] = xi.petId.GARUDA, -- Garuda Ring +1

    [17492] = xi.petId.SHIVA, -- Shiva's Claws
    [17711] = xi.petId.SHIVA, -- Shiva's Shotel
    [27574] = xi.petId.SHIVA, -- Shiva Ring
    [27575] = xi.petId.SHIVA, -- Shiva Ring +1

    [17531] = xi.petId.RAMUH, -- Ramuh's Staff
    [18404] = xi.petId.RAMUH, -- Ramuh's Mace
    [27568] = xi.petId.RAMUH, -- Ramuh Ring
    [27569] = xi.petId.RAMUH, -- Ramuh Ring +1

    [11752] = xi.petId.DIABOLOS, -- Diabolos's Rope
    [14814] = xi.petId.DIABOLOS, -- Diabolos's Earring
    [15516] = xi.petId.DIABOLOS, -- Diabolos's Torque
    [15557] = xi.petId.DIABOLOS, -- Diabolos's Ring
    [17599] = xi.petId.DIABOLOS, -- Diabolos's Pole

    [25910] = xi.petId.CAIT_SITH, -- Cait Sith Subligar
    [26717] = xi.petId.CAIT_SITH, -- Cait Sith Cap
    [26718] = xi.petId.CAIT_SITH, -- Cait Sith Cap +1
    [27631] = xi.petId.CAIT_SITH, -- Cait Sith Guard
    [27632] = xi.petId.CAIT_SITH, -- Cait Sith Guard +1
}

-- Blood pacts this avatar may cast on its own. heal/spring look for
-- an injured ally. party is a ward around the wearer. foe is one
-- single-target debuff per enemy, then damage. Area pacts that would
-- hit nearby mobs are left out, so a camp being farmed stays put.
-- Astral Flow pacts are left out: their scripts empty the wearer's MP.
local avatarPacts =
{
    [xi.petId.CARBUNCLE] =
    {
        { id = xi.jobAbility.HEALING_RUBY_II, lv = 65, heal = true },
        { id = xi.jobAbility.HEALING_RUBY,    lv = 1,  heal = true },
        { id = xi.jobAbility.SOOTHING_RUBY,   lv = 94, erase = true },
        { id = xi.jobAbility.SHINING_RUBY,    lv = 24, party = 'ruby' },
        { id = xi.jobAbility.GLITTERING_RUBY, lv = 44, party = 'glitter' },
        { id = xi.jobAbility.POISON_NAILS,    lv = 5,  foe = { xi.effect.POISON } },
        { id = xi.jobAbility.METEORITE,       lv = 55, rage = true },
        { id = xi.jobAbility.HOLY_MIST,       lv = 76, rage = true },
    },
    [xi.petId.FENRIR] =
    {
        { id = xi.jobAbility.ECLIPTIC_HOWL,  lv = 54, party = 'howl' },
        { id = xi.jobAbility.ECLIPTIC_GROWL, lv = 43, party = 'growl' },
        { id = xi.jobAbility.LUNAR_CRY,      lv = 21, foe = { xi.effect.ACCURACY_DOWN, xi.effect.EVASION_DOWN } },
        { id = xi.jobAbility.MOONLIT_CHARGE, lv = 5,  rage = true },
        { id = xi.jobAbility.CRESCENT_FANG,  lv = 10, rage = true },
        { id = xi.jobAbility.ECLIPSE_BITE,   lv = 65, rage = true },
        { id = xi.jobAbility.LUNAR_BAY,      lv = 78, rage = true },
        { id = xi.jobAbility.IMPACT,         lv = 99, rage = true },
    },
    [xi.petId.IFRIT] =
    {
        { id = xi.jobAbility.CRIMSON_HOWL,   lv = 38, party = 'warcry' },
        { id = xi.jobAbility.PUNCH,          lv = 1,  rage = true },
        { id = xi.jobAbility.FIRE_II,        lv = 10, rage = true },
        { id = xi.jobAbility.BURNING_STRIKE, lv = 23, rage = true },
        { id = xi.jobAbility.DOUBLE_PUNCH,   lv = 30, rage = true },
        { id = xi.jobAbility.FIRE_IV,        lv = 60, rage = true },
        { id = xi.jobAbility.FLAMING_CRUSH,  lv = 70, rage = true },
        { id = xi.jobAbility.METEOR_STRIKE,  lv = 75, rage = true },
        { id = xi.jobAbility.CONFLAG_STRIKE, lv = 99, rage = true },
    },
    [xi.petId.TITAN] =
    {
        { id = xi.jobAbility.EARTHEN_WARD,    lv = 46, party = 'stoneskin' },
        { id = xi.jobAbility.ROCK_THROW,      lv = 1,  rage = true },
        { id = xi.jobAbility.STONE_II,        lv = 10, rage = true },
        { id = xi.jobAbility.ROCK_BUSTER,     lv = 21, rage = true },
        { id = xi.jobAbility.MEGALITH_THROW,  lv = 35, rage = true },
        { id = xi.jobAbility.STONE_IV,        lv = 60, rage = true },
        { id = xi.jobAbility.MOUNTAIN_BUSTER, lv = 70, rage = true },
        { id = xi.jobAbility.GEOCRUSH,        lv = 75, rage = true },
        { id = xi.jobAbility.CRAG_THROW,      lv = 99, rage = true },
    },
    [xi.petId.LEVIATHAN] =
    {
        { id = xi.jobAbility.SPRING_WATER,   lv = 47, heal = true, spring = true },
        { id = xi.jobAbility.SOOTHING_CURRENT, lv = 99, party = 'conduit' },
        { id = xi.jobAbility.BARRACUDA_DIVE, lv = 1,  rage = true },
        { id = xi.jobAbility.WATER_II,       lv = 10, rage = true },
        { id = xi.jobAbility.TAIL_WHIP,      lv = 26, rage = true },
        { id = xi.jobAbility.WATER_IV,       lv = 60, rage = true },
        { id = xi.jobAbility.SPINNING_DIVE,  lv = 70, rage = true },
        { id = xi.jobAbility.GRAND_FALL,     lv = 75, rage = true },
    },
    [xi.petId.GARUDA] =
    {
        { id = xi.jobAbility.WHISPERING_WIND, lv = 36, heal = true },
        { id = xi.jobAbility.HASTEGA,         lv = 48, party = 'haste' },
        { id = xi.jobAbility.AERIAL_ARMOR,    lv = 25, party = 'blink' },
        { id = xi.jobAbility.CLAW,            lv = 1,  rage = true },
        { id = xi.jobAbility.AERO_II,         lv = 10, rage = true },
        { id = xi.jobAbility.AERO_IV,         lv = 60, rage = true },
        { id = xi.jobAbility.PREDATOR_CLAWS,  lv = 70, rage = true },
        { id = xi.jobAbility.WIND_BLADE,      lv = 75, rage = true },
    },
    [xi.petId.SHIVA] =
    {
        { id = xi.jobAbility.FROST_ARMOR,     lv = 28, party = 'ice' },
        { id = xi.jobAbility.AXE_KICK,        lv = 1,  rage = true },
        { id = xi.jobAbility.BLIZZARD_II,     lv = 10, rage = true },
        { id = xi.jobAbility.DOUBLE_SLAP,     lv = 50, rage = true },
        { id = xi.jobAbility.BLIZZARD_IV,     lv = 60, rage = true },
        { id = xi.jobAbility.RUSH,            lv = 70, rage = true },
        { id = xi.jobAbility.HEAVENLY_STRIKE, lv = 75, rage = true },
    },
    [xi.petId.RAMUH] =
    {
        { id = xi.jobAbility.ROLLING_THUNDER, lv = 31, party = 'enthunder' },
        { id = xi.jobAbility.LIGHTNING_ARMOR, lv = 42, party = 'shock' },
        { id = xi.jobAbility.SHOCK_STRIKE,    lv = 1,  rage = true },
        { id = xi.jobAbility.THUNDER_II,      lv = 10, rage = true },
        { id = xi.jobAbility.THUNDER_IV,      lv = 60, rage = true },
        { id = xi.jobAbility.CHAOTIC_STRIKE,  lv = 70, rage = true },
        { id = xi.jobAbility.THUNDERSTORM,    lv = 75, rage = true },
        { id = xi.jobAbility.VOLT_STRIKE,     lv = 99, rage = true },
    },
    [xi.petId.DIABOLOS] =
    {
        { id = xi.jobAbility.NOCTOSHIELD,     lv = 49, party = 'phalanx' },
        { id = xi.jobAbility.DREAM_SHROUD,    lv = 56, party = 'dream' },
        { id = xi.jobAbility.SOMNOLENCE,      lv = 20, foe = { xi.effect.WEIGHT } },
        { id = xi.jobAbility.CAMISADO,        lv = 1,  rage = true },
        { id = xi.jobAbility.NETHER_BLAST,    lv = 65, rage = true },
    },
    [xi.petId.CAIT_SITH] =
    {
        { id = xi.jobAbility.RAISE_II,       lv = 15, raise = true },
        { id = xi.jobAbility.RERAISE_II,     lv = 30, party = 'reraise' },
        { id = xi.jobAbility.EARIE_EYE,     lv = 55, foe = { xi.effect.SILENCE, xi.effect.AMNESIA } },
        { id = xi.jobAbility.REGAL_SCRATCH, lv = 1,  rage = true },
        { id = xi.jobAbility.LEVEL_QM_HOLY, lv = 75, rage = true },
    },
}

local spikeFamily =
{
    xi.effect.BLAZE_SPIKES,
    xi.effect.SHOCK_SPIKES,
    xi.effect.DREAD_SPIKES,
    xi.effect.REPRISAL,
    xi.effect.DELUGE_SPIKES,
    xi.effect.GALE_SPIKES,
    xi.effect.CLOD_SPIKES,
    xi.effect.GLINT_SPIKES,
    xi.effect.DAMAGE_SPIKES,
    xi.effect.ICE_SPIKES,
}

local enspells =
{
    xi.effect.ENFIRE,
    xi.effect.ENBLIZZARD,
    xi.effect.ENAERO,
    xi.effect.ENSTONE,
    xi.effect.ENTHUNDER,
    xi.effect.ENWATER,
    xi.effect.ENLIGHT,
    xi.effect.ENDARK,
}

local statBoosts =
{
    xi.effect.STR_BOOST,
    xi.effect.DEX_BOOST,
    xi.effect.VIT_BOOST,
    xi.effect.AGI_BOOST,
    xi.effect.INT_BOOST,
    xi.effect.MND_BOOST,
    xi.effect.CHR_BOOST,
}

local ailments =
{
    xi.effect.BLINDNESS,
    xi.effect.POISON,
    xi.effect.PARALYSIS,
    xi.effect.DISEASE,
    xi.effect.PETRIFICATION,
    xi.effect.SILENCE,
    xi.effect.SLOW,
    xi.effect.CURSE_I,
    xi.effect.PLAGUE,
}

-- char id -> { [itemId] = equip sequence }
local equippedAt = {}
local nextSeq    = 0

local function isPlayer(player)
    return player and player.isPC and player:isPC()
end

local function markedPetId(player)
    local localId = player:getLocalVar(GEAR_PET_LOCAL)
    if localId ~= 0 then
        return localId
    end

    local saved = player:getCharVar(GEAR_PET_CHAR) or 0
    if saved ~= 0 then
        player:setLocalVar(GEAR_PET_LOCAL, saved)
    end

    return saved
end

local function gearPet(player)
    if Ixi20GetGearAvatar then
        local side = Ixi20GetGearAvatar(player)
        if side then
            return side
        end
    end

    return nil
end

local function isGearAvatar(player)
    return gearPet(player) ~= nil
end

local function clearMark(player)
    player:setLocalVar(GEAR_PET_LOCAL, 0)
    if (player:getCharVar(GEAR_PET_CHAR) or 0) ~= 0 then
        player:setCharVar(GEAR_PET_CHAR, 0)
    end
end

local function markGearPet(player, petId)
    player:setLocalVar(GEAR_PET_LOCAL, petId)
    if (player:getCharVar(GEAR_PET_CHAR) or 0) ~= petId then
        player:setCharVar(GEAR_PET_CHAR, petId)
    end
end

local function releaseGearAvatar(player)
    if not isPlayer(player) then
        return
    end

    local marked = markedPetId(player)
    clearMark(player)

    if Ixi20ReleaseGearAvatar then
        Ixi20ReleaseGearAvatar(player)
        return
    end

    local pet = player:getPet()
    if pet and pet.getPetID and marked ~= 0 and pet:getPetID() == marked then
        player:despawnPet()
    end
end

local function scanEquipped(player)
    local set    = {}
    local bySlot = {}

    for slot = 0, xi.MAX_SLOTID do
        local item = player:getEquippedItem(slot)
        if item then
            local itemId = item:getID()
            if avatarItems[itemId] then
                set[itemId] = true
                bySlot[slot] = itemId
            end
        end
    end

    return set, bySlot
end

local function consumePending(player)
    if not Ixi20ConsumeAvatarEquipOrder then
        return {}
    end

    return Ixi20ConsumeAvatarEquipOrder(player) or {}
end

local function stamp(known, itemId)
    if known[itemId] then
        return
    end

    nextSeq = nextSeq + 1
    known[itemId] = nextSeq
end

local function latestChoice(known)
    local bestId  = nil
    local bestSeq = -1

    for itemId, seq in pairs(known) do
        if seq > bestSeq then
            bestSeq = seq
            bestId  = itemId
        end
    end

    if not bestId then
        return nil
    end

    return avatarItems[bestId], bestId
end

local function rememberLatest(player, itemId)
    local stored = itemId or 0
    if (player:getCharVar(LATEST_ITEM) or 0) ~= stored then
        player:setCharVar(LATEST_ITEM, stored)
    end
end

-- Diff worn avatar pieces against the last scan. Newly equipped pieces
-- take the next sequence, in packet order when a gearset sent several.
local function noteGear(player)
    if not isPlayer(player) then
        return nil
    end

    local key   = player:getID()
    local first = equippedAt[key] == nil
    if first then
        equippedAt[key] = {}
    end

    local known          = equippedAt[key]
    local equipped, bySlot = scanEquipped(player)
    local pending        = consumePending(player)

    for itemId in pairs(known) do
        if not equipped[itemId] then
            known[itemId] = nil
        end
    end

    if first then
        local pendingSet = {}
        for _, itemId in ipairs(pending) do
            pendingSet[itemId] = true
        end

        for slot = 0, xi.MAX_SLOTID do
            local itemId = bySlot[slot]
            if itemId and not pendingSet[itemId] then
                stamp(known, itemId)
            end
        end
    end

    for _, itemId in ipairs(pending) do
        if equipped[itemId] and avatarItems[itemId] then
            stamp(known, itemId)
        end
    end

    for slot = 0, xi.MAX_SLOTID do
        local itemId = bySlot[slot]
        if itemId then
            stamp(known, itemId)
        end
    end

    if first and #pending == 0 then
        local saved = player:getCharVar(LATEST_ITEM) or 0
        if saved ~= 0 and known[saved] then
            known[saved] = nil
            stamp(known, saved)
        end
    end

    local petId, itemId = latestChoice(known)
    rememberLatest(player, itemId)
    return petId
end

local function sendIn(player, target)
    if not target then
        return
    end

    local pet = gearPet(player)
    if not pet then
        return
    end

    local current = pet.getTarget and pet:getTarget() or nil
    if current and current.getID and current:getID() == target:getID() and pet.isEngaged and pet:isEngaged() then
        return
    end

    if pet.setBattleID and target.getBattleID then
        pet:setBattleID(target:getBattleID())
    end

    if pet.engage and target.getTargID then
        pet:engage(target:getTargID())
    end
end

local function effectPower(member, effectId)
    local effect = member:getStatusEffect(effectId)
    if not effect then
        return nil
    end

    return effect:getPower()
end

local function partyMembers(player)
    if player.getPartyWithTrusts then
        local party = player:getPartyWithTrusts()
        if party then
            return party
        end
    end

    if player.getParty then
        local party = player:getParty()
        if party then
            return party
        end
    end

    return { player }
end

local function nearMaster(player, wantDead)
    local found = {}
    for _, member in pairs(partyMembers(player)) do
        if member and member:getZoneID() == player:getZoneID() and player:checkDistance(member) <= PACT_RADIUS then
            if wantDead then
                if member.isPC and member:isPC() and member:isDead() then
                    found[#found + 1] = member
                end
            elseif member.isAlive and member:isAlive() then
                found[#found + 1] = member
            end
        end
    end

    return found
end

local function hasAny(member, effects)
    for _, effectId in ipairs(effects) do
        if member:hasStatusEffect(effectId) then
            return true
        end
    end

    return false
end

local function hasAll(member, effects)
    for _, effectId in ipairs(effects) do
        if not member:hasStatusEffect(effectId) then
            return false
        end
    end

    return true
end

local function needsAilmentCleanse(member)
    return hasAny(member, ailments)
end

-- 'gain' somebody in the circle would benefit. 'harm' the pact deletes
-- a stronger effect first, so the whole circle is left alone.
local function wardOutcome(member, kind)
    if kind == 'ruby' then
        if member:hasStatusEffect(xi.effect.SHINING_RUBY) then
            return 'safe'
        end

        return 'gain'
    end

    if kind == 'glitter' then
        local missing = 0
        for _, effectId in ipairs(statBoosts) do
            if not member:hasStatusEffect(effectId) then
                missing = missing + 1
            end
        end

        if missing >= 4 then
            return 'gain'
        end

        return 'safe'
    end

    if kind == 'warcry' then
        local have = effectPower(member, xi.effect.WARCRY)
        if have == nil or have < 9 then
            return 'gain'
        end

        return 'safe'
    end

    if kind == 'stoneskin' then
        if member:hasStatusEffect(xi.effect.STONESKIN) then
            return 'harm'
        end

        return 'gain'
    end

    if kind == 'conduit' then
        if member:hasStatusEffect(xi.effect.CURING_CONDUIT) then
            return 'safe'
        end

        return 'gain'
    end

    if kind == 'haste' then
        local have = effectPower(member, xi.effect.HASTE)
        if have == nil or have < 1494 then
            return 'gain'
        end

        return 'safe'
    end

    if kind == 'blink' then
        if member:hasStatusEffect(xi.effect.COPY_IMAGE) then
            return 'safe'
        end

        local have = effectPower(member, xi.effect.BLINK)
        if have == nil then
            return 'gain'
        end

        if have > 3 then
            return 'harm'
        end

        if have < 3 then
            return 'gain'
        end

        return 'safe'
    end

    if kind == 'ice' or kind == 'shock' then
        local mine = kind == 'ice' and xi.effect.ICE_SPIKES or xi.effect.SHOCK_SPIKES
        for _, effectId in ipairs(spikeFamily) do
            if effectId ~= mine and member:hasStatusEffect(effectId) then
                return 'harm'
            end
        end

        local have = effectPower(member, mine)
        if have == nil or have < 15 then
            return 'gain'
        end

        if have > 15 then
            return 'harm'
        end

        return 'safe'
    end

    if kind == 'enthunder' then
        if member:hasStatusEffect(xi.effect.ENTHUNDER) then
            return 'safe'
        end

        if hasAny(member, enspells) then
            return 'harm'
        end

        return 'gain'
    end

    if kind == 'howl' then
        if not member:hasStatusEffect(xi.effect.ACCURACY_BOOST) or not member:hasStatusEffect(xi.effect.EVASION_BOOST) then
            return 'gain'
        end

        return 'safe'
    end

    if kind == 'growl' then
        if hasAny(member, statBoosts) then
            return 'harm'
        end

        return 'gain'
    end

    if kind == 'phalanx' then
        local have = effectPower(member, xi.effect.PHALANX)
        if have == nil or have < 13 then
            return 'gain'
        end

        return 'safe'
    end

    if kind == 'dream' then
        if member:hasStatusEffect(xi.effect.MAGIC_ATK_BOOST) or member:hasStatusEffect(xi.effect.MAGIC_DEF_BOOST) then
            return 'harm'
        end

        return 'gain'
    end

    if kind == 'reraise' then
        if member:hasStatusEffect(xi.effect.RERAISE) then
            return 'safe'
        end

        return 'gain'
    end

    return 'safe'
end

local function wardHelps(allies, kind)
    local gains = false
    for _, member in ipairs(allies) do
        local outcome = wardOutcome(member, kind)
        if outcome == 'harm' then
            return false
        end

        if outcome == 'gain' then
            gains = true
        end
    end

    return gains
end

local function lowestHurt(allies, threshold, spring)
    local best   = nil
    local bestHp = 101
    for _, member in ipairs(allies) do
        local hpp  = member:getHPP()
        local hurt = hpp < threshold
        if spring and not hurt and needsAilmentCleanse(member) then
            hurt = true
        end

        if hurt and hpp <= bestHp then
            best   = member
            bestHp = hpp
        end
    end

    return best
end

local function bestHeal(list, level, allies, threshold)
    local best = nil
    local who  = nil
    for _, pact in ipairs(list) do
        if pact.heal and pact.lv <= level then
            local target = lowestHurt(allies, threshold, pact.spring)
            if target and (not best or pact.lv > best.lv) then
                best = pact
                who  = target
            end
        end
    end

    return best, who
end

local function pickPact(player, list, foe)
    local level  = player:getMainLvl()
    local allies = nearMaster(player, false)
    local dead   = nearMaster(player, true)

    local emergency, emergencyWho = bestHeal(list, level, allies, 50)
    if emergency then
        return emergency, emergencyWho
    end

    for _, pact in ipairs(list) do
        if pact.raise and pact.lv <= level and dead[1] then
            return pact, dead[1]
        end
    end

    local heal, who = bestHeal(list, level, allies, 80)
    if heal then
        return heal, who
    end

    for _, pact in ipairs(list) do
        if pact.lv <= level then
            if pact.erase then
                for _, member in ipairs(allies) do
                    if needsAilmentCleanse(member) then
                        return pact, member
                    end
                end
            elseif pact.party and #allies > 0 and wardHelps(allies, pact.party) then
                return pact, player
            elseif pact.foe and foe and foe:isAlive() and player:getLocalVar(DEBUFF_FOE) ~= foe:getID() then
                local avatar = gearPet(player)
                if avatar and avatar:checkDistance(foe) <= 10 and not hasAll(foe, pact.foe) then
                    player:setLocalVar(DEBUFF_FOE, foe:getID())
                    return pact, foe
                end
            end
        end
    end

    if not foe or not foe:isAlive() then
        return nil, nil
    end

    local rages = {}
    for _, pact in ipairs(list) do
        if pact.rage and pact.lv <= level then
            rages[#rages + 1] = pact
        end
    end

    if #rages == 0 then
        return nil, nil
    end

    local step = player:getLocalVar(PACT_STEP)
    if step < 1 or step > #rages then
        step = 1
    end

    player:setLocalVar(PACT_STEP, step % #rages + 1)
    return rages[step], foe
end

local function pactTick(player, gen)
    if not isPlayer(player) or player:getLocalVar(PACT_GEN) ~= gen then
        return
    end

    if player:isDead() or not player:isEngaged() or not isGearAvatar(player) then
        return
    end

    local avatar = gearPet(player)
    local list   = avatar and avatarPacts[avatar:getPetID()] or nil
    if not list then
        return
    end

    local foe = player:getTarget()
    if foe and foe.isAlive and not foe:isAlive() then
        foe = nil
    end

    if foe and avatar.isEngaged and not avatar:isEngaged() then
        sendIn(player, foe)
    end

    local pact, target = pickPact(player, list, foe)
    if pact and target and avatar:isEngaged() then
        player:setLocalVar(GEAR_CAST, pact.id)
        avatar:usePetAbility(pact.id, target)
    end

    player:timer(PACT_DELAY * 1000, function(owner)
        local tick = xi.gear_sets._ixi20AvatarPact
        if tick then
            tick(owner, gen)
        end
    end)
end

xi.gear_sets._ixi20AvatarPact = pactTick

local function startPactLoop(player)
    local gen = player:getLocalVar(PACT_GEN) + 1
    if gen > 1000000 then
        gen = 1
    end

    player:setLocalVar(PACT_GEN, gen)
    player:timer(2000, function(owner)
        local tick = xi.gear_sets._ixi20AvatarPact
        if tick then
            tick(owner, gen)
        end
    end)
end

-- A normal say is dropped unless a player with that name is nearby.
-- NS_SAY still prints the speaker, so Shiva's line shows in the log.
local function announceArrival(player, spawned, petId)
    local line = arrivalLines[petId]
    if not line or not spawned or not spawned.getID then
        return
    end

    local entityId = spawned:getID()
    if entityId == 0 or player:getLocalVar(ANNOUNCED_ID) == entityId then
        return
    end

    local name = spawned.getName and spawned:getName() or ''
    if name == '' then
        name = avatarNames[petId]
    end

    if not name or name == '' then
        return
    end

    player:setLocalVar(ANNOUNCED_ID, entityId)
    player:printToArea(line, xi.msg.channel.NS_SAY, xi.msg.area.SAY, name)
end

local function summonAvatar(player, petId, target)
    local side = gearPet(player)
    if side and side.getPetID and side:getPetID() == petId then
        sendIn(player, target)
        startPactLoop(player)
        announceArrival(player, side, petId)
        return
    end

    if player:getLocalVar(RETRY_AT) > os.time() then
        return
    end

    -- A gear avatar left in the pet slot from before this change steps
    -- aside, still on the field, so the summon spell can use the slot.
    local slot = player:getPet()
    if not side and slot and slot.getPetID and slot:getPetID() == petId and markedPetId(player) == petId then
        if Ixi20AdoptGearAvatar then
            Ixi20AdoptGearAvatar(player)
        end

        side = gearPet(player)
        if side then
            markGearPet(player, petId)
            sendIn(player, target)
            startPactLoop(player)
            announceArrival(player, side, petId)
            return
        end
    end

    if side and Ixi20ReleaseGearAvatar then
        Ixi20ReleaseGearAvatar(player)
    end

    markGearPet(player, petId)

    if Ixi20SpawnGearAvatar then
        Ixi20SpawnGearAvatar(player, petId)
    elseif not player:getPet() then
        player:spawnPet(petId)
    end

    local spawned = gearPet(player)
    if not spawned or not spawned.getPetID or spawned:getPetID() ~= petId then
        clearMark(player)
        player:setLocalVar(RETRY_AT, os.time() + 5)
        return
    end

    player:setLocalVar(RETRY_AT, 0)
    announceArrival(player, spawned, petId)

    local engageTarget = target or player:getTarget()
    sendIn(player, engageTarget)
    startPactLoop(player)

    player:timer(500, function(owner)
        if not isPlayer(owner) or not owner:isEngaged() or not isGearAvatar(owner) then
            return
        end

        sendIn(owner, owner:getTarget())
    end)
end

local function syncAvatar(player, target)
    if not isPlayer(player) or player:isDead() or not player:isEngaged() then
        return
    end

    local petId = noteGear(player)
    if not petId then
        if isGearAvatar(player) then
            releaseGearAvatar(player)
        end

        return
    end

    summonAvatar(player, petId, target or player:getTarget())
end

local function onGearChange(player)
    if not isPlayer(player) then
        return
    end

    noteGear(player)
    if player:isEngaged() then
        syncAvatar(player, player:getTarget())
    end
end

local function settleOnGameIn(player)
    local marked = player:getCharVar(GEAR_PET_CHAR) or 0
    if marked == 0 then
        player:setLocalVar(GEAR_PET_LOCAL, 0)
        return
    end

    if player:isEngaged() then
        player:setLocalVar(GEAR_PET_LOCAL, marked)
        summonAvatar(player, marked, player:getTarget())
        return
    end

    releaseGearAvatar(player)
end

local function bind(player)
    -- The body looks up the latest function. A file reload replaces
    -- that function, and the listener already on a logged-in player
    -- follows it.
    player:addListener('ENGAGE', LISTENER_ENGAGE, function(playerArg, target)
        local fn = xi.gear_sets._ixi20AvatarEngage
        if fn then
            fn(playerArg, target)
        end
    end)

    player:addListener('DISENGAGE', LISTENER_DISENGAGE, function(playerArg)
        local fn = xi.gear_sets._ixi20AvatarDisengage
        if fn then
            fn(playerArg)
        end
    end)

    player:addListener('ATTACK', LISTENER_ATTACK, function(playerArg, target)
        local fn = xi.gear_sets._ixi20AvatarAttack
        if fn then
            fn(playerArg, target)
        end
    end)

    player:addListener('DEATH', LISTENER_DEATH, function(playerArg)
        local fn = xi.gear_sets._ixi20AvatarDeath
        if fn then
            fn(playerArg)
        end
    end)
end

local function onGameIn(player, firstLogin, zoning)
    if not isPlayer(player) then
        return
    end

    bind(player)
    noteGear(player)
    settleOnGameIn(player)
end

m:addOverride('xi.gear_sets.checkForGearSet', function(player)
    super(player)
    local fn = xi.gear_sets._ixi20AvatarOnGear
    if fn then
        fn(player)
    end
end)

m:addOverride('xi.player.onGameIn', function(player, firstLogin, zoning)
    super(player, firstLogin, zoning)
    local fn = xi.player._ixi20AvatarOnGameIn
    if fn then
        fn(player, firstLogin, zoning)
    end
end)

xi.gear_sets._ixi20AvatarOnGear = onGearChange
xi.player._ixi20AvatarOnGameIn = onGameIn
xi.gear_sets._ixi20AvatarEngage = function(playerArg, target)
    syncAvatar(playerArg, target)
end
xi.gear_sets._ixi20AvatarDisengage = function(playerArg)
    releaseGearAvatar(playerArg)
end
xi.gear_sets._ixi20AvatarAttack = function(playerArg, target)
    local present = gearPet(playerArg)
    if present then
        local send = xi.gear_sets._ixi20AvatarSendIn
        if send then
            send(playerArg, target)
        end

        return
    end

    syncAvatar(playerArg, target)
end
xi.gear_sets._ixi20AvatarSendIn = sendIn
xi.gear_sets._ixi20AvatarDeath = function(playerArg)
    if Ixi20ReleaseGearAvatar then
        Ixi20ReleaseGearAvatar(playerArg)
    end

    clearMark(playerArg)
end

if not xi.gear_sets._ixi20AvatarEquip then
    xi.gear_sets._ixi20AvatarEquip = true
    xi.gear_sets._ixi20AvatarEquipRouted = true
    local previous = xi.gear_sets.checkForGearSet
    xi.gear_sets.checkForGearSet = function(player)
        if previous then
            previous(player)
        end

        local fn = xi.gear_sets._ixi20AvatarOnGear
        if fn then
            fn(player)
        end
    end
end

-- The wrap installed at process start calls the summon function from
-- that first load. Route it through the table so a reload can speak.
if not xi.gear_sets._ixi20AvatarEquipRouted then
    xi.gear_sets._ixi20AvatarEquipRouted = true
    local previous = xi.gear_sets.checkForGearSet
    xi.gear_sets.checkForGearSet = function(player)
        if previous then
            previous(player)
        end

        local fn = xi.gear_sets._ixi20AvatarOnGear
        if fn then
            fn(player)
        end
    end
end

if not xi.job_utils.summoner._ixi20GearAvatarMp then
    xi.job_utils.summoner._ixi20GearAvatarMp = true
    local previous = xi.job_utils.summoner.onUseBloodPact
    xi.job_utils.summoner.onUseBloodPact = function(target, petskill, summoner, action)
        local restore = nil
        local casting = summoner and summoner.getLocalVar and summoner:getLocalVar(GEAR_CAST) or 0
        local skillId = petskill and petskill.getID and petskill:getID() or 0
        if summoner and summoner.isPC and summoner:isPC() and casting ~= 0 and skillId == casting then
            restore = summoner:getMP()
            summoner:setLocalVar(GEAR_CAST, 0)
        end

        if previous then
            previous(target, petskill, summoner, action)
        end

        if restore ~= nil then
            summoner:setMP(restore)
        end
    end
end

if not xi.player._ixi20AvatarEquipGameIn then
    xi.player._ixi20AvatarEquipGameIn = true
    xi.player._ixi20AvatarGameInRouted = true
    local previous = xi.player.onGameIn
    xi.player.onGameIn = function(player, firstLogin, zoning)
        if previous then
            previous(player, firstLogin, zoning)
        end

        local fn = xi.player._ixi20AvatarOnGameIn
        if fn then
            fn(player, firstLogin, zoning)
        end
    end
end

if not xi.player._ixi20AvatarGameInRouted then
    xi.player._ixi20AvatarGameInRouted = true
    local previous = xi.player.onGameIn
    xi.player.onGameIn = function(player, firstLogin, zoning)
        if previous then
            previous(player, firstLogin, zoning)
        end

        local fn = xi.player._ixi20AvatarOnGameIn
        if fn then
            fn(player, firstLogin, zoning)
        end
    end
end

-- A summoner's spell finds the gear avatar in the pet slot and
-- would refuse. Move that avatar out of the slot first. It stays
-- on the field, and the spell takes the slot.
local function onSummonCheck(caster)
    if not isPlayer(caster) or gearPet(caster) then
        return
    end

    local slot = caster:getPet()
    local marked = markedPetId(caster)
    if slot and marked ~= 0 and slot.getPetID and slot:getPetID() == marked and Ixi20AdoptGearAvatar then
        Ixi20AdoptGearAvatar(caster)
    end
end

xi.pet._ixi20AvatarSummonCheck = onSummonCheck

if not xi.pet._ixi20AvatarSummonWrapped then
    xi.pet._ixi20AvatarSummonWrapped = true
    local previous = xi.pet.onCastingCheck
    xi.pet.onCastingCheck = function(caster, target, spell)
        local fn = xi.pet._ixi20AvatarSummonCheck
        if fn then
            fn(caster)
        end

        if previous then
            return previous(caster, target, spell)
        end

        return 0
    end
end

-- Players already online keep the listener from when they logged in.
-- Replace it so the next engage uses the current speech.
if xi.zone and GetZone then
    local visitedZone = {}
    for _, zoneId in pairs(xi.zone) do
        if type(zoneId) == 'number' and not visitedZone[zoneId] then
            visitedZone[zoneId] = true
            local zone = GetZone(zoneId)
            if zone and zone.getPlayers then
                for _, player in pairs(zone:getPlayers() or {}) do
                    if isPlayer(player) then
                        bind(player)
                    end
                end
            end
        end
    end
end

return m
