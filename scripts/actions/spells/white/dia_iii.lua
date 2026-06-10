-----------------------------------
-- Spell: Dia III
-- Lowers an enemy's defense and gradually deals light elemental damage.
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local damage = xi.spells.damage.useDamageSpell(caster, target, spell)
    local tier   = 5

    local existingDia = target:getStatusEffect(xi.effect.DIA)
    if not existingDia or existingDia:getTier() < tier then
        target:delStatusEffect(xi.effect.DIA)
        local power = 3 + caster:getMod(xi.mod.DIA_DOT)

        target:addStatusEffect(xi.effect.DIA, { power = power, duration = 180, origin = caster, tick = 3, subPower = 20, tier = tier })
    end

    return damage
end

return spellObject
