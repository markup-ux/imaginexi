# Imagine XI — Job-Agnostic Party Combat Spec

**Goal:** Most players should not care which jobs fill party slots. Any reasonable 4–6 job mix should clear content at comparable pace without feeling like a handicap.

**Primary lever:** Break the retail TP loop where only melee jobs generate party tempo (TP → skillchains → magic bursts).

**Related docs:** `docs/IMAGINEXI_GAME_GOALS_FROM_CHATS.md` §3–4, `docs/IMAGINEXI_BACKLOG_NOW_NEXT_LATER.md` Phase 2, `IMAGINE_XI_FEATURES.md`, prototype in `_intake_backup_20260430_122416/server/src/`.

**Status:** Spec approved for implementation. Magic TP earn (C++) and Charged Spell spend (Lua) are merged into active `server/src`. Staff WS at range and legacy WHM TP abilities remain optional polish.

---

## 1) Design principles

1. **Every job earns TP from its primary activity** — not from `/SAM` subjob or sitting idle.
2. **Every job spends TP on something the party values** — WS, job ability, or chain participation.
3. **Clear time variance ≤ ~15–20%** between a “meta burn” comp and a casual mixed comp on the same content tier.
4. **Preserve job identity** — BLM bursts, WHM sustains, SAM chains; do not homogenize kits.
5. **All unlocks ≤ level 75** per workspace progression policy.

---

## 2) Universal TP economy

### 2.1 Base formula (melee-equivalent TP)

Restore from intake backup (`CalculateMeleeEquivalentCastTp`):

```
delayMs   = main weapon delay (dual-wield halves delay when valid)
ratio     = 2.0 if H2H main, else 1.0
baseTp    = CalculateBaseTP(delayMs * 60 / 1000 / ratio)
castTp    = max(1, floor(baseTp * (1 + 0.01 * (StoreTP + merit StoreTP))))
```

When no melee weapon is equipped (optional path), use **synthetic staff delay 612** (D51 staff baseline at 75).

### 2.2 TP gain sources (PC only)

| Source | Trigger | TP amount | Notes |
|--------|---------|-----------|-------|
| **Melee swing** | Standard auto-attack | Retail | Unchanged |
| **Ranged hit** | Standard ranged | Retail | Unchanged |
| **Damage nuke** | `TakeSpellDamage`, damage > 0, not debuff | `castTp` × `MAGIC_TP_NUKE_MULT` | Default mult 1.0 |
| **Enfeeble land** | Debuff spell lands (`tookEffect`) | `castTp` × `MAGIC_TP_ENFEEBLE_MULT` | Default 1.0 |
| **DoT tick** | REGEN_DOWN tick on poisoned/burned/etc. target | `castTp / 2` × mult | Track caster via local vars (intake pattern) |
| **Healing** | Cure spell, HP restored > 0 | `castTp × min(1.0, curedHP / targetMaxHP) × MAGIC_TP_HEAL_MULT` | Default heal mult **0.75** |
| **SMN BP** | Blood pact resolves | Master gains `castTp` × `MAGIC_TP_BP_MULT` | Default 0.5 (avatar also has retail pet TP) |
| **BRD song** | Song effect applied to target | `castTp × 0.5` once per song finish | Phase 4 |
| **COR roll** | Roll applied | `castTp × 0.5` once per roll | Phase 4 |
| **GEO Indi** | Indi effect applied | `castTp × 0.5` once per cast | Phase 4 |

**Eligibility (Imagine XI default):**

- Caster is `TYPE_PC`.
- Spell is offensive **or** healing **or** eligible support (configurable).
- **`MAGIC_TP_REQUIRES_STAFF = false`** (Imagine default): any main job in `{BLM, WHM, RDM, SMN, SCH, GEO, BLU}` gains magic TP regardless of equipped weapon.
- When `MAGIC_TP_REQUIRES_STAFF = true`: prototype behavior — main hand must be `SKILL_STAFF` (stricter, not recommended for job-agnostic goal).

**De-duplication:**

- Debuff openers (Bio) grant enfeeble TP once; DoT ticks grant tick TP separately.
- Multi-hit nukes grant TP once per cast, not per hit (matches intake `GrantPlayerMagicNukeTpFromAppliedDamage`).

### 2.3 Telemetry

When `MAGIC_TP_LOG_ENABLED = true`, log every PC TP change with source tag (intake `addTP` logging):

| Source tag | Meaning |
|------------|---------|
| `spell_nuke_damage_tp` | Damage spell |
| `spell_enfeeble_land` | Debuff landed |
| `dot_hp_tick_caster_tp` | DoT tick |
| `spell_heal_tp` | Cure (new) |
| `blood_pact_master_tp` | SMN master from BP (new) |

Enable `TELEMETRY_ENABLED` separately for party-comp sampling (`server/scripts/globals/server_telemetry.lua`).

---

## 3) TP spenders by role

**Primary model (v1): Charged Spells** — no client plugins or DAT mods. Casters earn TP from spells (§2.2); at **≥1000 TP**, the next eligible spell auto-spends 1000 TP for a bonus package. Players use the normal spell bar.

**Spending is job-agnostic:** *any* job at ≥1000 TP that casts a qualifying spell triggers the charge (e.g. a WAR/BLM at 1000 TP who casts Stone gets a charged nuke). If the player never casts a qualifying spell, TP keeps building normally for weapon skills — nothing is consumed. TP **earn** from magic remains gated to mage mains (§2.2 eligibility); melee jobs build TP from swings as usual.

Implementation: `server/scripts/globals/magic_tp_parity.lua`, hooked from `magic.lua` / `damage_spell.lua` / cure spell scripts.

### 3.1 Charged nukes (any job)

| Setting | Default | Effect |
|---------|---------|--------|
| `CHARGED_SPELL_TP_COST` | 1000 | TP spent on proc |
| `CHARGED_NUKE_DAMAGE_MULT` | 1.5 | Damage multiplier |
| `CHARGED_NUKE_ENMITY_RATIO` | 0.15 | Enmity = damage × ratio |

On proc: amplified damage + skillchain opener + lingering Arcane Charge DoT. Player message: *Arcane Charge*.

**Skillchain property resolution:** signature mage main (BLM Impaction, SCH Reverberation, RDM Compression, GEO Scission, BLU Liquefaction) → else the mage **sub job's** signature property (WAR/BLM opens Impaction) → else by **spell element** (Fire Liquefaction, Ice Induration, Wind Detonation, Earth Scission, Thunder Impaction, Water Reverberation, Light Transfixion, Dark Compression).

**Chat notification** on crossing 1000 TP fires only when main or sub job can cast a qualifying spell (WHM/BLM/RDM/PLD/DRK/NIN/SMN/BLU/SCH/GEO), so pure melee jobs are not spammed every TP cycle. The overlay charge meter still shows readiness for everyone.

### 3.2 Charged cure (WHM)

| Setting | Default | Effect |
|---------|---------|--------|
| `CHARGED_CURE_STONESKIN_RATIO` | 0.6 | Absorb = heal × ratio |
| `CHARGED_CURE_STONESKIN_FLOOR` | 150 | Minimum absorb |
| `CHARGED_CURE_STONESKIN_CAP` | 1000 | Maximum absorb |
| `CHARGED_CURE_STONESKIN_DURATION` | 60s | Stoneskin duration |
| `CHARGED_CURE_PARTY_ESUNA_RANGE` | 10 yalms | Party cleanse radius |
| `CHARGED_CURE_ENMITY_RATIO` | 0.15 | Enmity = heal × ratio |

On proc (any Cure I–VI): Stoneskin on cure target (skip if already present) + **1 debuff removed per party member** in range + reduced enmity. Player message: *Sacred Charge*.

Wired via `finishWhiteMagicCure()` / `finishWhiteMagicCuraga()` in `server/scripts/globals/magic.lua` → `cure.lua` through `cure_vi.lua`, all `curaga*.lua`, and `cura*.lua`. Compatible with **Accession**, **Manifestation**, **Majesty**, and **Divine Seal** (heal amount is calculated with JA modifiers first, then charged effects apply).

### 3.2b Charged heal — Arcane Mend (any non-WHM job)

Same **1000 TP pool** as Arcane Charge nukes: the next **Cure**, **Curaga**, or **Cura** auto-spends instead of a nuke. Applies to hybrid mage mains (SCH / RDM / GEO / BLU) and any other job casting a cure (e.g. PLD main, WAR/WHM).

| Setting | Default | Effect |
|---------|---------|--------|
| `CHARGED_HYBRID_CURE_HEAL_MULT` | 1.3 | Heal multiplier on proc |
| `CHARGED_HYBRID_CURE_STONESKIN_RATIO` | 0.4 | Absorb = heal × ratio |
| `CHARGED_HYBRID_CURE_STONESKIN_FLOOR` | 100 | Minimum absorb |
| `CHARGED_HYBRID_CURE_STONESKIN_CAP` | 500 | Maximum absorb |
| `CHARGED_HYBRID_CURE_STONESKIN_DURATION` | 45s | Stoneskin duration |
| `CHARGED_HYBRID_CURE_ENMITY_RATIO` | 0.15 | Enmity = heal × ratio |

On proc: amplified heal on **all targets** in the cast (Curaga, Accession+Cure AoE, etc.) + Stoneskin on each healed target + **1 debuff removed** from caster and primary target (once per cast) + reduced enmity. Player message: *Arcane Mend*.

WHM main keeps the stronger **Sacred Charge** package (party-wide cleanse); every other job gets the lighter **Arcane Mend** package.

### 3.3 Optional — staff WS at magic range

**Secondary / polish only.** Useful for players who want a WS button, but fragile on some clients (greyed WS palette without addon).

| WS | ID | Skill | Suggested unlock | SC property | Range |
|----|-----|-------|------------------|-------------|-------|
| Heavy Swing | 176 | 5 | Lv 1 | Impaction | **21 yalms** (magic range) |
| Rock Crusher | 177 | 40 | Lv 13 | Induration | 21 yalms |
| Starburst | 179 | 100 | Lv 33 | Compression / Reverberation | 21 yalms |

**Server rules** (`map.lua` + C++):

- `PREVENT_UNENGAGED_WS = false`
- Staff WS (`weapon_skills.type = 12`): skip auto-engage, bypass unengaged denial, **no facing requirement**, validate distance at **21 yalms**.
- Client: Windower addon `StaffMagicWs` helps palette; not required for Charged Spell path.

See `server/documentation/weaponskill_availability_by_level.md` for 75-cap unlock levels.

### 3.4 Optional — legacy WHM TP abilities

Separate JA buttons (IDs 980–983) exist in SQL/Lua but are **superseded by Charged Cure** for v1. Keep for experimentation or remove after Charged Cure is validated in-game.

SQL: `server/modules/custom/sql/features/healer_tp_abilities.sql`  
Lua: `server/scripts/actions/abilities/luminous_strike.lua`, etc.

### 3.5 SMN

- Master gains TP from BP (§2.2); avatar TP unchanged.
- No extra SMN spenders required for v1 — BP + Charged Spell (future) or staff WS (optional) suffices.

### 3.6 Support (Phase 4 — optional v1)

| Job | TP source | Spender idea | Level |
|-----|-----------|--------------|-------|
| BRD | Song finish | **Resonant Encore** — party Regen + 1 TP feed to party members in range | 50 |
| COR | Roll finish | **Loaded Salvo** — damage vs mob + Random Deal–style bonus | 50 |
| GEO | Indi start | **Ecliptic Surge** — small heal + Geo-Refresh pulse | 40 |

Defer until Phases 1–3 validated.

### 3.7 Melee / tank

No changes required for v1. Retail WS + sticky Provoke already sufficient.

---

## 4) Trust policy

| Setting | Value | When to enable |
|---------|-------|----------------|
| `TRUST_LEVEL_CAP` | 30 | **After** magic TP + Charged Spell spend ship |

**Implementation (restore from intake):**

- `server/src/map/utils/trustutils.cpp` — cap effective level on spawn
- `server/scripts/globals/trust.lua` — reminder message once per hour when player level > cap

Trusts remain strong for leveling; endgame requires real players, and real non-melee jobs must be viable first.

**Trust AI (Phase 3):**

- Call WS at ≥1000 TP when party member opens SC window
- Tank trusts: Provoke reliability (regression: Trion, Curilla)
- See `docs/IMAGINEXI_GAME_GOALS_FROM_CHATS.md` §4

---

## 5) Optional party diversity bonus (Phase 5)

Soft incentive, not a crutch:

```
categories = { melee, magic, heal, support }  // count unique PC mains present
bonus = min(MAGIC_TP_PARTY_DIVERSITY_CAP, categories * MAGIC_TP_PARTY_DIVERSITY_STEP)
// default: step 3% damage + 3% magic TP per category, cap 4 categories (12%)
```

Apply in `battleutils` damage path and magic TP grant. Disable by default (`MAGIC_TP_PARTY_DIVERSITY_ENABLED = false`).

---

## 6) Content tuning guidelines

Not a substitute for TP parity; use to **prove** mixed comps work.

| Tier | Target group | Clear time (mixed comp) | Notes |
|------|--------------|-------------------------|-------|
| Starter HNM | 3–5 eligible (≤12) | 5–10 min | Already spec’d in `STARTER_HNM_LOOT.md` |
| Mid HNM / NM | 4–6 level 75 | 8–15 min | Tune HP so WS-reaction doesn’t force burn |
| World HNM | 5–6 level 75 | 15–25 min | Phase mechanics that need magic **or** melee, not one |

**WS reaction:** Keep enabled; document that mixed comps should include at least one sustained TP source (now any job).

**Loot:** Prefer completion-based drops over speed tiers (reduces parse pressure).

---

## 7) Implementation map

### Phase 1 — Magic TP core (Now)

| File | Change |
|------|--------|
| `server/src/map/utils/battleutils.cpp` | Restore `CalculateMeleeEquivalentCastTp`, `GrantPlayerMagicNukeTpFromAppliedDamage`; call from `TakeSpellDamage` |
| `server/src/map/entities/battleentity.cpp` | Restore `GrantMagicTpIfEligible`, `TrackDoTCaster` on spell land |
| `server/src/map/status_effect_container.cpp` | Restore DoT tick TP grant block |
| `server/scripts/effects/{bio,poison,burn,choke,drown,frost,rasp,shock,helix}.lua` | Clear magic TP local vars on effect wear |
| `server/settings/default/map.lua` | `MAGIC_TP_*` settings (see §8) |
| `server/scripts/globals/spells/healing_spell.lua` or C++ heal path | Grant `spell_heal_tp` |

**Reference patch:** `docs/lsb_intake_artifacts/src_imaginexi_vs_lsb.patch` (search `CalculateMeleeEquivalentCastTp`).

### Phase 2 — Charged Spell spend (Now)

| File | Change |
|------|--------|
| `server/scripts/globals/magic_tp_parity.lua` | `prepareChargedCure`, `applyChargedCureEffects`, `prepareChargedNuke`, `commitChargedNuke` |
| `server/scripts/globals/magic.lua` | `finishWhiteMagicCure()` / `finishWhiteMagicCuraga()` helpers |
| `server/scripts/globals/spells/damage_spell.lua` | Charged nuke hooks |
| `server/scripts/actions/spells/white/cure*.lua` | Route heals through `finishWhiteMagicCure` |
| `server/scripts/actions/spells/white/curaga*.lua`, `cura*.lua` | Route AoE heals through `finishWhiteMagicCuraga` |
| `server/settings/default/map.lua` | `CHARGED_SPELL_*` settings |

### Phase 2b — Staff WS range (optional polish)

| File | Change |
|------|--------|
| `server/src/map/packets/c2s/0x01a_action.cpp` | Staff WS unengaged bypass |
| `server/src/map/entities/charentity.cpp` | WS distance check: 21 yalms for staff type 12 |
| `server/src/map/ai/controllers/player_controller.cpp` | Remove facing requirement for staff magic WS |

### Phase 2c — Legacy WHM TP abilities (optional, superseded)

| File | Change |
|------|--------|
| `server/modules/custom/sql/features/healer_tp_abilities.sql` | Ability rows (980–983) |
| `server/scripts/actions/abilities/luminous_strike.lua` | etc. |

### Phase 3 — Trust cap + SC AI (Next)

| File | Change |
|------|--------|
| `server/src/map/utils/trustutils.cpp` | Apply `TRUST_LEVEL_CAP` |
| `server/scripts/globals/trust.lua` | Cap reminder |
| `server/src/map/ai/helpers/gambits_container.cpp` | SC follow / early TP (intake diff) |

### Phase 4 — Support TP + diversity (Later)

| File | Change |
|------|--------|
| New support abilities SQL + Lua | BRD/COR/GEO |
| `battleutils.cpp` | Diversity bonus |

---

## 8) Settings (`server/settings/default/map.lua`)

```lua
-- Magic TP parity (Imagine XI)
MAGIC_TP_ENABLED              = true,
MAGIC_TP_REQUIRES_STAFF       = false,  -- false = any eligible magic job
MAGIC_TP_NUKE_MULT            = 1.0,
MAGIC_TP_ENFEEBLE_MULT        = 1.0,
MAGIC_TP_HEAL_MULT            = 0.75,
MAGIC_TP_DOT_MULT             = 0.5,    -- applied to castTp/2 tick grant
MAGIC_TP_BP_MULT              = 0.5,
MAGIC_TP_LOG_ENABLED          = true,   -- set false in production after balance pass
MAGIC_TP_SYNTHETIC_DELAY       = 612,    -- used when no weapon delay available

-- Charged spell spend (primary TP spender — no client plugin)
CHARGED_SPELL_ENABLED            = true,
CHARGED_SPELL_TP_COST            = 1000,
CHARGED_CURE_STONESKIN_RATIO     = 0.6,
CHARGED_CURE_STONESKIN_FLOOR     = 150,
CHARGED_CURE_STONESKIN_CAP       = 1000,
CHARGED_CURE_STONESKIN_DURATION  = 60,
CHARGED_CURE_PARTY_ESUNA_RANGE   = 10,
CHARGED_CURE_ENMITY_RATIO        = 0.15,
CHARGED_NUKE_DAMAGE_MULT         = 1.5,
CHARGED_NUKE_ENMITY_RATIO        = 0.15,

-- Staff WS at magic range (optional polish, type 12)
STAFF_MAGIC_WS_RANGE          = 21.0,
STAFF_MAGIC_WS_NO_FACING      = true,

-- Optional diversity bonus
MAGIC_TP_PARTY_DIVERSITY_ENABLED = false,
MAGIC_TP_PARTY_DIVERSITY_STEP    = 3,   -- percent per job category
MAGIC_TP_PARTY_DIVERSITY_CAP     = 12,

-- Existing (keep)
TRUST_LEVEL_CAP               = 30,
PREVENT_UNENGAGED_WS          = false,
WS_REACTION_ENABLED           = true,
TELEMETRY_ENABLED             = false,
```

---

## 9) Balance targets (acceptance tests)

Run with `MAGIC_TP_LOG_ENABLED = true` and 6 real players or GM alts.

| Test | Setup | Pass criteria |
|------|-------|---------------|
| **TP parity — BLM** | L75 BLM, staff, spam Fire IV on dummy | TP/min within **±10%** of same-gear WAR auto-attacking |
| **TP parity — WHM** | L75 WHM, Cure IV spam on injured ally | TP to 1000 in ≤ **120s** (heal mult 0.75) |
| **Charged nuke** | L75 BLM 1000 TP, Fire IV on dummy | 1.5× damage; Impaction SC window opens |
| **Charged cure** | L75 WHM 1000 TP, Cure IV on ally | Stoneskin on target; 1 debuff cleansed per party member in 10 yalms; low enmity |
| **Arcane Mend** | L75 RDM 1000 TP, Cure IV on ally (or Curaga with Accession) | 1.3× heal; Stoneskin on targets; caster + target cleanse once; low enmity |
| **SC from back line (optional)** | BLM disengaged, 21 yalms | Heavy Swing / Rock Crusher / Starburst land (staff WS path) |
| **Mixed comp clear** | PLD + WHM + BLM + BRD + WAR + RNG vs mid HNM | Kill within **120%** of WAR×4 + WHM + BRD burn comp time |
| **Party comp telemetry** | 1 week live, telemetry on | Top party keys show **≥3 unique mains** in >50% of endgame samples |

---

## 10) Player-facing summary (advertising copy)

> On Imagine XI, mages and healers earn TP from spells and cures—not just melee swings. At 1000 TP, your next nuke or cure triggers a **Charged Spell** bonus (amplified damage + skillchain, or party shield + cleanse). It works on **every job**: a WAR/BLM can spend melee TP on a charged Stone, or just keep building toward a weapon skill. Bring your friends on whatever job they like.

---

## 11) Execution checklist

- [x] Phase 1: Magic TP C++ merged; heal TP; settings; map server builds
- [ ] Phase 1: Verify TP logs for nuke / enfeeble / DoT / heal (in-game)
- [x] Phase 2: Charged Spell Lua + cure/nuke hooks
- [x] Phase 2b: Staff WS range + facing (C++)
- [ ] Phase 2: In-game Charged Spell smoke test (BLM nuke + WHM cure)
- [ ] Phase 2c: Legacy WHM TP abilities SQL apply (optional)
- [ ] Phase 3: Trust level cap + trust SC regression
- [ ] Phase 4: Support TP + optional diversity bonus
- [ ] Enable telemetry; review party comp after 2 weeks
- [ ] Tune `MAGIC_TP_*_MULT` if mixed-comp clear times exceed 120% of burn baseline
