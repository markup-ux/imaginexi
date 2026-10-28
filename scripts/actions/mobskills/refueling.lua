-----------------------------------
-- Refueling
-- Increases attack speed.
-----------------------------------
---@type TMobSkill
local mobskillObject = {}

mobskillObject.onMobSkillCheck = function(target, mob, skill)
    return 0
end

mobskillObject.onMobWeaponSkill = function(mob, target, skill, action)
    local applied = mob:addStatusEffect(xi.effect.REFUELING, {
        power    = 2000, -- 20%
        duration = 180,
        origin   = mob,
        icon     = xi.effect.HASTE,
    })

    skill:setMsg(applied and xi.msg.basic.SKILL_GAIN_EFFECT or xi.msg.basic.SKILL_NO_EFFECT)

    return xi.effect.REFUELING
end

return mobskillObject
