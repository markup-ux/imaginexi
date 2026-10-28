-----------------------------------
-- Imagine XI 2.0: Endark II.
-- Map looks up xi.actions.spells.black.endark_ii. LSB ships no script, so the cast is rejected.
-- Same Endark status (dark enspell decay, Endark job-point attack). Tier II potency.
-- FileWatcher drops addOverride; the table assignment stays live.
-----------------------------------
require('modules/module_utils')
-----------------------------------

local m = Module:new('ixi20_endark_ii')

-- BG-Wiki / JP wiki. Job points are added by scripts/effects/endark.lua.
local function potency(skill)
    skill = skill or 0

    if skill >= 501 then
        return 2 * math.floor((skill + 400) / 20) + math.floor((skill + 400) / 40)
    end

    return 2 * math.floor((skill + 85) / 13) + math.floor((skill + 85) / 26)
end

local function onMagicCastingCheck(caster, target, spell)
    return 0
end

local function onSpellCast(caster, target, spell)
    local effect = xi.effect.ENDARK
    local power = potency(target:getSkillLevel(xi.skill.DARK_MAGIC))

    if target:addStatusEffect(effect, { power = power, duration = 180, origin = caster }) then
        spell:setMsg(xi.msg.basic.MAGIC_GAIN_EFFECT)
    else
        spell:setMsg(xi.msg.basic.MAGIC_NO_EFFECT)
    end

    return effect
end

local function install()
    xi.actions = xi.actions or {}
    xi.actions.spells = xi.actions.spells or {}
    xi.actions.spells.black = xi.actions.spells.black or {}
    xi.actions.spells.black.endark_ii =
    {
        onMagicCastingCheck = onMagicCastingCheck,
        onSpellCast         = onSpellCast,
    }
end

install()

m:addOverride('xi.server.onServerStart', function()
    super()
    install()
end)
