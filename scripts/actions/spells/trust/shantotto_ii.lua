-----------------------------------
-- Trust: Shantotto II
-----------------------------------
---@type TSpellTrust
local spellObject = {}

spellObject.onMagicCastingCheck = function(caster, target, spell)
    return xi.trust.canCast(caster, spell, xi.magic.spell.SHANTOTTO)
end

spellObject.onSpellCast = function(caster, target, spell)
    return xi.trust.spawn(caster, spell)
end

spellObject.onMobSpawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.SPAWN)

    -- Backup for the watcher below. Gambits wait out her swings, so a short
    -- burst window can close before this line runs.
    mob:addGambit(ai.t.TARGET, { ai.c.MB_AVAILABLE, 0 }, { ai.r.MA, ai.s.MB_ELEMENT, xi.magic.spellFamily.NONE })
    -- Tier I only, so this is her whole nuke kit. 45s left her idle between casts.
    -- She holds this while any skillchain is up and bursts it instead.
    mob:addGambit(ai.t.TARGET, { ai.c.NOT_SC_AVAILABLE, 0 }, { ai.r.MA, ai.s.HIGHEST, xi.magic.spellFamily.NONE }, 8)

    local trustLevel  = mob:getMainLvl()
    local power       = trustLevel / 5
    local spellDamage = trustLevel * math.floor((trustLevel + 1) / 10)

    mob:addMod(xi.mod.MATT, power)
    mob:addMod(xi.mod.MACC, power)
    mob:addMod(xi.mod.HASTE_MAGIC, 1000) -- 10% Haste (Magic)

    -- Shantotto's tier I spells scale up to mimic tier 2, 3, etc, spells.
    mob:addMod(xi.mod.MAGIC_DAMAGE, spellDamage)

    -- Shantotto has 100% melee hit rate always.
    -- TODO: Add support for 'perfect accuracy' in c++ land and stop hacking her accuracy.
    mob:addMod(xi.mod.ACC, 1000)

    -- Typeless magical swings (skill 3739). The skill row only reaches 7 yalms,
    -- and she stands still out to 15, so the attack was accepted and then
    -- rejected. No hit, no TP, and Final Exam never came out.
    -- The timer fires that same skill from casting distance.
    mob:setMobSkillAttack(1163)
    mob:setAutoAttackEnabled(false)
    mob:setTrustTPSkillSettings(ai.tp.ASAP, ai.s.RANDOM, 1000)

    -- Tier I nukes, the only spells she can burst with. Light and dark
    -- are omitted: Transfixion and Compression have no match in this list.
    local burstSpells =
    {
        { xi.element.FIRE,    xi.magic.spell.FIRE },
        { xi.element.ICE,     xi.magic.spell.BLIZZARD },
        { xi.element.WIND,    xi.magic.spell.AERO },
        { xi.element.EARTH,   xi.magic.spell.STONE },
        { xi.element.THUNDER, xi.magic.spell.THUNDER },
        { xi.element.WATER,   xi.magic.spell.WATER },
    }

    local function burstSpell(mobArg, target)
        local effect = target:getStatusEffect(xi.effect.SKILLCHAIN)
        if not effect or effect:getTier() <= 0 then
            return nil
        end

        local chain = effect:getPower()
        local chainTable = xi.data.element.skillchainElementTable
        if not chainTable or chain < 1 or chain > 16 then
            return nil
        end

        local bestSpell = nil
        local bestRank = 99
        for _, row in ipairs(burstSpells) do
            local element = row[1]
            local spellId = row[2]
            local elements = chainTable[element]
            if elements and elements[chain] and elements[chain] > 0 and mobArg:hasSpell(spellId) then
                local rank = target:getMod(xi.data.element.getElementalResistanceRankModifier(element))
                if rank < bestRank then
                    bestRank = rank
                    bestSpell = spellId
                end
            end
        end

        return bestSpell
    end

    local swingSkill = 3739
    local function act(mobArg)
        if not mobArg or not mobArg:isAlive() then
            return
        end

        local target = mobArg:getTarget()
        local action = mobArg:getCurrentAction()
        local busy = action == xi.action.category.MAGIC_START
            or action == xi.action.category.MAGIC_CASTING
            or action == xi.action.category.MAGIC_FINISH
            or action == xi.action.category.MOBABILITY_START
            or action == xi.action.category.MOBABILITY_USING
            or action == xi.action.category.MOBABILITY_FINISH
            or action == xi.action.category.WEAPONSKILL_START
            or action == xi.action.category.WEAPONSKILL_FINISH

        if mobArg:isEngaged() and target and target:isAlive() and not busy and mobArg:checkDistance(target) <= 20 then
            local spellId = burstSpell(mobArg, target)
            local now = os.time()
            if spellId then
                -- Window is open. Skip the swing so the cast is not stuck behind it.
                if now >= mobArg:getLocalVar('ixi20ShantottoBurst') then
                    mobArg:setLocalVar('ixi20ShantottoBurst', now + 2)
                    mobArg:castSpell(spellId, target)
                end
            else
                if now >= mobArg:getLocalVar('ixi20ShantottoSwing') then
                    mobArg:setLocalVar('ixi20ShantottoSwing', now + 3)
                    mobArg:useMobAbility(swingSkill, target, 0, true)
                end
            end
        end

        mobArg:timer(1000, act)
    end

    mob:timer(1000, act)

    mob:addListener('WEAPONSKILL_USE', 'SHANTOTTO_II_WEAPONSKILL_USE', function(mobArg, target, skill, tp, action, damage)
        if skill:getID() == 3740 then -- Final Exam
            -- And yet again, the flames of life are snuffed out, and I'll say this--it was an out and out rout!
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_1)
        end
    end)

    -- Spellcast (occasionally)
    mob:addListener('MAGIC_USE', 'SHANTOTTO_II_MAGIC', function(mobArg, target, spell, action)
        if math.randomInt(1, 100) <= 33 then
            -- Ohohohohoho!
            xi.trust.message(mobArg, xi.trust.messageOffset.SPECIAL_MOVE_2)
        end
    end)

    mob:setMobMod(xi.mobMod.TRUST_DISTANCE, xi.trust.movementType.NO_MOVE)
end

spellObject.onMobDespawn = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DESPAWN)
end

spellObject.onMobDeath = function(mob)
    xi.trust.message(mob, xi.trust.messageOffset.DEATH)
end

return spellObject
