-----------------------------------
-- Battle log (0x029) lines for debuff potency after magic applies an effect.
-- Uses client messages 461–467: "${target}:STAT ${number}/${number}" (retail debug-style stat readout).
-- First number = effect power; second = duration in seconds (or power if duration is 0).
-----------------------------------
xi = xi or {}
xi.spells = xi.spells or {}
xi.spells.debuffBattleLog = xi.spells.debuffBattleLog or {}

-- MsgBasic IDs from retail action message table (Windower res/action_messages.lua).
local statDownMessage =
{
    [xi.effect.STR_DOWN] = 461,
    [xi.effect.DEX_DOWN] = 462,
    [xi.effect.VIT_DOWN] = 463,
    [xi.effect.AGI_DOWN] = 464,
    [xi.effect.INT_DOWN] = 465,
    [xi.effect.MND_DOWN] = 466,
    [xi.effect.CHR_DOWN] = 467,
}

---@param caster CBattleEntity
---@param target CBattleEntity
---@param effectId integer
---@param power integer|nil
---@param durationSeconds integer|nil
function xi.spells.debuffBattleLog.onDebuffApplied(caster, target, effectId, power, durationSeconds)
    if caster == nil or target == nil or not caster:isPC() then
        return
    end

    local msgId = statDownMessage[effectId]
    if msgId == nil then
        return
    end

    local p = math.floor(power or 0)
    if p <= 0 then
        return
    end

    local d = math.floor(durationSeconds or 0)
    if d <= 0 then
        d = p
    end

    caster:messageBasic(msgId, p, d, target)
end
