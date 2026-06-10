-----------------------------------
-- Spell: Curaga
-- Restores HP of all party members within area of effect.
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local minCure = 60

    local divisor = 1
    local constant = 20
    local power = getCurePowerOld(caster)
    if power > 170 then
        divisor = 35.6666
        constant = 87.62
    elseif power > 110 then
        divisor =  2
        constant = 47.5
    end

    local final = getCureFinal(caster, spell, getBaseCureOld(power, divisor, constant), minCure, false)

    final = final + (final * (target:getMod(xi.mod.CURE_POTENCY_RCVD) / 100))

    --Applying server mods
    final = final * xi.settings.main.CURE_POWER

    local diff = (target:getMaxHP() - target:getHP())
    if final > diff then
        final = diff
    end

    if final > 0 then
        final = finishWhiteMagicCuraga(caster, target, spell, final)
    end

    local mpBonusPercent = (final * caster:getMod(xi.mod.CURE2MP_PERCENT)) / 100
    if mpBonusPercent > 0 then
        caster:addMP(mpBonusPercent)
    end

    return final
end

return spellObject
