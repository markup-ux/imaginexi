-----------------------------------
-- Spell: Bio III
-- Deals dark damage that weakens an enemy's attacks and gradually reduces its HP.
-----------------------------------
---@type TSpell
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return 0
end

spellObject.onSpellCast = function(caster, target, spell)
    local damage = xi.spells.damage.useDamageSpell(caster, target, spell)
    local tier   = 6

    local existingBio = target:getStatusEffect(xi.effect.BIO)
    if not existingBio or existingBio:getTier() < tier then
        target:delStatusEffect(xi.effect.BIO)

        -- Calculate DoT effect: http://wiki.ffo.jp/html/1954.html
        local power      = 0
        local skillLevel = caster:getSkillLevel(xi.skill.DARK_MAGIC)
        if skillLevel > 291 then
            power = 13 + math.floor((skillLevel - 291) / 27) -- 13 + 1 every 27 skill levels.
        elseif skillLevel > 246 then
            power = 9 + math.floor((skillLevel - 246) / 11) -- 9 + 1 every 11 skill levels.
        else
            power = 5 + math.floor((skillLevel - 106) / 35) -- 5 + 1 every 35 skill levels.
        end

        power = utils.clamp(power, 5, 17)

        target:addStatusEffect(xi.effect.BIO, { power = power, duration = 180, origin = caster, tick = 3, subPower = 20, tier = tier })
    end

    return damage
end

return spellObject
