-----------------------------------
-- Evasion
--
-- Description: Increases evasion
-- Type: Enhancing
-- Utsusemi/Blink absorb: N/A
-- Range: Self
-----------------------------------
require('scripts/globals/mobskill_defense_scaling')

---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local power, duration = xi.mobskillDefenseScaling.evasionBoost(mob)

    skill:setMsg(xi.mobskills.mobBuffMove(mob, xi.effect.EVASION_BOOST, power, 0, duration))

    return xi.effect.EVASION_BOOST
end

return mobskillObject
