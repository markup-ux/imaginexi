-----------------------------------
-- Spell: Bio V
-- Deals dark damage that weakens an enemy's attacks and gradually reduces its HP.
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local damage = xi.spells.damage.useDamageSpell(caster, target, spell)
    local tier   = 10

    local existingBio = target:getStatusEffect(xi.effect.BIO)
    if not existingBio or existingBio:getTier() < tier then
        target:delStatusEffect(xi.effect.BIO)

        -- Calculate DoT effect (rough, though fairly accurate)
        local power = 5 + math.floor(caster:getSkillLevel(xi.skill.DARK_MAGIC) / 50)

        target:addStatusEffect(xi.effect.BIO, { power = power, duration = 180, origin = caster, tick = 3, subPower = 25, tier = tier })
    end

    return damage
end

return spellObject
