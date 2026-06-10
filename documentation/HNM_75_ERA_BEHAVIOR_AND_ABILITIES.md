# 75-Era HNM Behavior and Abilities (Current Custom System)

This document describes how 75-era HNMs behave with the current custom logic in this repo.

Scope:
- Major world HNMs configured in this project.
- Effective behavior = native mob behavior + global HNM system + per-mob additive overrides.
- Levels below come from current `mob_spawn_points.sql` entries for each HNM.

## Global System Applied to HNMs

- **HNM anti-melt system (`scripts/globals/hnm_anti_melt.lua` + mixin `scripts/mixins/hnm_anti_melt.lua`)**
  - Applied to all world HNMs profiled below (sky gods, Kirin, ground kings, ancient wyrms, Roc, Simurgh, Cerberus, Khimaira, Serket, Capricious Cassie, King Arthro, Lord of Onzozo).
  - **Per-hit damage cap**: `RECEIVED_DAMAGE_CAP` derived from max HP (~3.2%, clamped 300–1800) unless the per-mob config sets an explicit cap; variance is ~18.75% of the cap. Sky gods keep their original explicit 800/150.
  - **Baseline mitigation**: `UDMGPHYS`/`UDMGMAGIC` -2000, `UDMGRANGE`/`UDMGBREATH` -1500, applied strengthen-only (never weakens a stronger floor a mob script already set, e.g. the ancient wyrms' -5000 magic/range/breath).
  - **Party-size scaling**: engaged real-player count on the hate list (trusts excluded) tightens the cap and adds extra `-UDMG*` below six players (solo: 56.25% cap, -5000 extra UDMG).
  - **Ward phase (opt-in per mob)**: once at 50% HPP, diamondhide-scaled Stoneskin plus a 30s extra `-1000 UDMG` burst, with a chat telegraph to everyone on the hate list.
  - **Exclusions**: Nyzul Isle copies and Dynamis Lord do not use the mixin. Aspidochelone's config disables UDMG management (`manageUDMG = false`) so its shell state machine keeps ownership of those mods; caps still apply.
  - Per-mob tuning lives in `xi.hnmAntiMelt.config`, keyed by internal mob name.

- **HNM healer-pressure system (`scripts/globals/healer_pressure.lua` + mixin `scripts/mixins/healer_pressure.lua`)**
  - Companion to anti-melt: anti-melt sets the fight-length floor, healer pressure fills that time with sustain demands that reward healing skill.
  - **Telegraphed AoE pulses**: every 75s (wyrms 90s) a chat telegraph fires, then 2.5s later all engaged real players within 25 yalms take elemental damage as a percentage of their max HP (40% sky gods, 35% wyrms, 25–30% kings at full engagement). Stoneskin absorbs pulse damage, rewarding anticipation. Trusts are not damaged and do not count toward scaling.
  - **Status packages**: pulse resolution applies short (15–30s) high-frequency debuffs per mob identity — cleanse triage, not lockouts.
  - **MP burn**: ancient wyrm pulses drain 10% max MP — long flight-phase fights become an MP economy test.
  - **Doom spotlights**: one-time, telegraphed by name, below an HPP threshold on Capricious Cassie (50%) and Khimaira (40%). 30s countdown; Cursna/Holy Water counterplay.
  - **Party scaling**: pulse damage and MP burn scale 0.5x (solo) to 1.0x (6+) using the same engaged-player count as anti-melt.
  - **Per-mob identities**: sky gods = elemental pulse + one thematic status (Genbu slow, Seiryu silence, Byakko paralysis, Suzaku burn; Kirin pulse only); wyrms = attrition/MP; ground kings = status triage (KB statuses only, Meteor stays his spike); lottery kings = one simple mechanic each.
  - Tuning lives in `xi.healerPressure.config`, keyed by internal mob name. Mobs without a config entry are unaffected.

- **HNM sleep immunity**
  - Notorious mobs reject `Sleep`, `Sleep II`, and `Lullaby`.

- **HNM stun package (Dynamis Lord exempt)**
  - While stunned, HNMs do not lose HP/MP from damage.
  - WS TP and spell MP are refunded in the implemented stun-protected paths.
  - `Dynamis Lord` is excluded.

- **WS reaction system (all enemies, including HNMs)**
  - Incoming weapon skills grant TP and stack Fast Cast (capped at 50%).
  - Tiered TP bonus: normal / NM / HNM.

- **Global additive HNM extra skills (current)**
  - `717` venom_breath: poison breath.
  - `724` evasion: self **EVASION_BOOST**; power and duration scale by main level, `CHECK_AS_NM`, and **notorious** (`mob:isNM()`). See `scripts/globals/mobskill_defense_scaling.lua`.
  - `1744` diamondhide (**mobskill**, not the BLU spell): self **Stoneskin**; absorb = \((200 + 12×level + 1.1\%×maxHP) × tier\), clamped **400–20000**, duration **300s** (NM-class **360s**, notorious **420s**). Tier **1.0** normal, **1.70** if `CHECK_AS_NM`, **2.85** if notorious. Non-dispelable after application. Logic lives in `mobskill_defense_scaling.lua`.
  - `1017` call_beast: pet summon attempt (requires valid linked pet to pass check).
  - `1901` activate: automaton/pet summon attempt (requires valid linked pet to pass check).
  - *(Removed from pool for bad cross-family animation fit: `272`, `658`, `1388`, `1747`.)*
  - *(Removed from global pool: `721` stasis.)*

## Animation Safety Status

- **Mostly safe, not guaranteed 100%**:
  - The list avoids many high-risk scripted gimmick moves.
  - Two global skills are behavior-risky for lore/visual consistency:
    - `1017` call_beast
    - `1901` activate
  - These do not always execute because pet checks can block them, but they are still in the global candidate pool.

## HNM Profiles

## Fafnir

- **Configured level(s)**: 80, 90 (common era spawn entry shown as 90 in Dragons Aery)
- **Native family moves (Wyrm)**
  - `951` hurricane_wing
  - `952` spike_flail
  - `953` dragon_breath
  - `957` absolute_terror
  - `958` horrid_roar_1
- **Per-mob additive overrides enabled**
  - Wyrm additions:
    - `1039` hurricane_wing (Nidhogg variant)
    - `1040` spike_flail (outside-alliance variant)
    - `1041` dragon_breath (Nidhogg variant)
    - `1046` horrid_roar_2
  - Safe cross-family additions (toggle on):
    - `724` evasion
    - `717` venom_breath
- **Effective ability pool**
  - Native Wyrm set + global additive HNM list + per-mob additions above.
- **Anti-melt**: yes, with 50% ward phase.

## Nidhogg

- **Configured level(s)**: 90
- **Native family moves (Wyrm/Nidhogg)**
  - `1039` hurricane_wing
  - `1040` spike_flail
  - `1041` dragon_breath
  - `957` absolute_terror
  - `1046` horrid_roar_2
- **Per-mob additive overrides**
  - None currently.
- **Effective ability pool**
  - Native Nidhogg set + global additive HNM list.
- **Anti-melt**: yes, with 50% ward phase.

## Adamantoise

- **Configured level(s)**: 70, 80
- **Native family moves (Adamantoise)**
  - `804` tortoise_song: dispels statuses in AoE.
  - `805` head_butt_turtle: physical hit, accuracy down.
  - `806` tortoise_stomp: physical hit, defense down.
  - `807` harden_shell: defense buff.
  - `808` earth_breath: fan-shaped earth breath.
  - `809` aqua_breath: fan-shaped water breath.
- **Per-mob additive overrides enabled**
  - Re-adds Adamantoise family set explicitly.
  - Safe cross-family additions (toggle on):
    - `724` evasion
    - `717` venom_breath
- **Effective ability pool**
  - Native Adamantoise set + global additive HNM list + per-mob additions above.
- **Anti-melt**: yes, with 50% ward phase.

## Aspidochelone

- **Configured level(s)**: 85
- **Native family moves**
  - Uses Adamantoise family base set (`804`-`809`) plus native script shell behavior.
- **Native script behavior**
  - Shell in/out state machine with heavy mitigation in-shell and TP burst on shell exit.
- **Per-mob additive overrides enabled**
  - Re-adds Adamantoise family set explicitly.
  - Safe cross-family additions (toggle on):
    - `724` evasion
    - `717` venom_breath
- **Effective ability pool**
  - Native Aspid behavior + native family moves + global additive HNM list + per-mob additions above.
- **Anti-melt**: caps and party scaling only. No ward (shell phase is its native mitigation mechanic); UDMG mods stay owned by the shell state machine.

## Behemoth

- **Configured level(s)**: 70, 80
- **Native family moves (Behemoth)**
  - `628` wild_horn
  - `629` thunderbolt_behemoth
  - `630` kick_out
  - `631` shock_wave_behemoth
  - `632` flame_armor
  - `633` howl
- **Per-mob additive overrides**
  - None currently.
- **Effective ability pool**
  - Native Behemoth set + global additive HNM list.
- **Anti-melt**: yes, with 50% ward phase.

## King Behemoth

- **Configured level(s)**: 85
- **Native family moves**
  - Same Behemoth family core (`628`-`633`), via King Behemoth list.
- **Native script behavior**
  - Additional immunities and recurring Meteor behavior in script.
- **Per-mob additive overrides**
  - None currently.
- **Effective ability pool**
  - Native King Behemoth behavior + native move set + global additive HNM list.
- **Anti-melt**: yes. No ward (recurring Meteor is its native midpoint pressure).

## Roc

- **Configured level(s)**: 55, 75-80
- **Native NM_Rocs moves**
  - `402` feather_barrier
  - `922` blind_vortex
  - `923` giga_scream
  - `924` dread_dive
  - `926` stormwind
- **Native script behavior**
  - Draw-in enforcement, always aggro, dark sleep/terror immunity, boosted combat stats.
- **Per-mob additive overrides**
  - None currently.
- **Effective ability pool**
  - Native Roc set + global additive HNM list.
- **Anti-melt**: yes, with 50% ward phase. Cap derives from max HP, so the low-level spawn entry stays proportionate.

## Simurgh

- **Configured level(s)**: 58, 75-80
- **Native NM_Rocs moves**
  - `402` feather_barrier
  - `922` blind_vortex
  - `923` giga_scream
  - `924` dread_dive
  - `926` stormwind
- **Native script behavior**
  - Draw-in enforcement, always aggro, dark sleep/terror immunity, boosted combat stats.
- **Per-mob additive overrides**
  - None currently.
- **Effective ability pool**
  - Native Simurgh set + global additive HNM list.
- **Anti-melt**: yes, with 50% ward phase. Cap derives from max HP, so the low-level spawn entry stays proportionate.

## Cerberus

- **Configured level(s)**: 80, 85
- **Native Cerberus moves**
  - `1785` lava_spit
  - `1786` sulfurous_breath
  - `1787` scorching_lash
  - `1788` ululation
  - `1789` magma_hoplon
  - `1790` gates_of_hades
- **Native script behavior**
  - Draw-in arena logic, regain scaling by HPP.
- **Per-mob additive overrides**
  - None currently.
- **Effective ability pool**
  - Native Cerberus set + global additive HNM list.
- **Anti-melt**: yes. No ward (low-HP regain ramp is its native phase).

## Khimaira

- **Configured level(s)**: 70, 80, 85
- **Native Khimaira moves**
  - `2022` tenebrous_mist
  - `2023` thunderstrike
  - `2024` tourbillion
  - `2025` dreadstorm
  - `2026` fossilizing_breath
  - `2027` plague_swipe
  - `2028` fulmination
- **Per-mob additive overrides**
  - None currently.
- **Effective ability pool**
  - Native Khimaira set + global additive HNM list.
- **Anti-melt**: yes, with 50% ward phase.

## Sky Gods (Ru'Aun Gardens)

- **Configured level(s)**: 88–90 (notorious)
- **Configured HP pools (`mob_groups`, zone 130)**: Genbu 22200, Seiryu/Byakko 25600, Suzaku 29000 (~17% bump over retail pools)
- **Anti-melt baseline (mixin `scripts/mixins/hnm_anti_melt.lua`, explicit sky god tuning)**
  - `RECEIVED_DAMAGE_CAP` 800 (variance 150) at full engagement
  - `UDMGPHYS` / `UDMGMAGIC` -2000, `UDMGRANGE` / `UDMGBREATH` -1500
- **Party-size scaling**: engaged real-player count on hate list (trusts excluded) tightens caps and adds extra `-UDMG*` below six players
- **Ward phase**: once at **50% HPP**, diamondhide-scaled Stoneskin plus 30s extra `-UDMG` burst
- **Native script behavior**: per-god mechanics unchanged (Genbu ATT ramp, Seiryu regain, etc.)
- **Kirin**: anti-melt caps and scaling, no ward (its god-summon cycle is the phase mechanic)
- **Instanced Tu'Lia**: Ark Angels 1–5 and Divine Might disallow trusts; Divine Might level cap **75**

## Ancient Wyrms (Tiamat / Jormungand / Vrtra)

- **Anti-melt**: caps and party scaling, no ward (flight phases / pet phases stand in for it).
- Native `-5000` `UDMGMAGIC`/`UDMGRANGE`/`UDMGBREATH` floors are preserved (anti-melt applies UDMG strengthen-only); physical baseline `-2000` added.

## Lottery Kings (Serket / Capricious Cassie / King Arthro / Lord of Onzozo)

- **Anti-melt**: yes, with 50% ward phase. Caps derive from max HP, so they stay proportionate to these smaller HP pools.

## Recommended Hardening (If You Want Zero Lore-Summon Surprises)

- Remove from global HNM additive list:
  - `1017` call_beast
  - `1901` activate
- Keep summon skills as per-mob explicit opt-in only with verified linked pets.
