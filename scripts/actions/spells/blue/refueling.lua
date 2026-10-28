-----------------------------------
-- Spell: Refueling
-- Increases attack speed
-- Spell cost: 29 MP
-- Monster Type: Arcana
-- Spell Type: Magical (Wind)
-- Blue Magic Points: 4
-- Stat Bonus: AGI+2
-- Level: 48
-- Casting Time: 1.5 seconds
-- Recast Time: 30 seconds
-- Duration: 5 minutes
-----------------------------------
-- Combos: None
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local power    = 1000 -- 10%
    local duration = xi.spells.blue.calculateDurationWithDiffusion(caster, 300)

    -- Own buff. Icon matches Haste so the client can draw it. The effect
    -- id is separate, so it does not overwrite Haste, March, or Geo-Haste.
    if not target:addStatusEffect(xi.effect.REFUELING, {
        power    = power,
        duration = duration,
        origin   = caster,
        icon     = xi.effect.HASTE,
    }) then
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return xi.effect.REFUELING
end

return spellObject
