-----------------------------------
-- Diamondhide (mobskill; not the BLU spell)
--
-- Description: Gives the effect of "Stoneskin."
-- Type: Magical
-----------------------------------
require('scripts/globals/mobskill_defense_scaling')

---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local power, duration = xi.mobskillDefenseScaling.diamondhide(mob)

    skill:setMsg(xi.mobskills.mobBuffMove(mob, xi.effect.STONESKIN, power, 0, duration))

    local effect = mob:getStatusEffect(xi.effect.STONESKIN)
    if effect then
        effect:delEffectFlag(xi.effectFlag.DISPELABLE)
    end

    return xi.effect.STONESKIN
end

return mobskillObject
