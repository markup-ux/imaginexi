# Feature Module Map

This document tracks feature ownership for custom SQL modules under `modules/custom/sql`.

## Active Feature SQL Modules

- `modules/custom/sql/features/job_progression_75cap.sql`
  - **Feature:** Job progression and ruleset core (75-cap aligned)
  - **Scope:** Traits, skill ranks, progression-related overrides and notes
  - **Tables:** `traits`, `skill_ranks`

- `modules/custom/sql/features/run_geo_af.sql`
  - **Feature:** RUN/GEO AF content
  - **Scope:** AF1 custom NPC clones in Lower Jeuno, AF2 Dynamis droplist remaps
  - **Tables:** `npc_list`, `mob_droplist`

- `modules/custom/sql/features/world_qol.sql`
  - **Feature:** World QoL
  - **Scope:** Safer outpost-adjacent mob placements, mount flags in selected zones
  - **Tables:** `mob_spawn_points`, `zone_settings`

- `modules/custom/sql/features/nm_tuning.sql`
  - **Feature:** NM tuning
  - **Scope:** Orthrus skill list and level/HP tuning
  - **Tables:** `mob_pools`, `mob_groups`

- `modules/custom/sql/features/special_items.sql`
  - **Feature:** Special item tuning
  - **Scope:** Item mods for Matt's Cap (`itemId = 15194`)
  - **Tables:** `item_mods`

- `modules/custom/sql/features/pixie_rescue.sql`
  - **Feature:** Pixie rescue
  - **Scope:** Pixie support spell behavior hook
  - **Tables:** `mob_spell_lists`

- `modules/custom/sql/features/item_rebalance.sql`
  - **Feature:** Item rebalance
  - **Scope:** Extracted ImagineXI-tagged item rows from core SQL (including SMN and AF bridge rows)
  - **Tables:** `item_mods`, `item_mods_pet`

- `modules/custom/sql/features/trust_adjustments.sql`
  - **Feature:** Trust adjustments
  - **Scope:** Extracted strict trust+ImagineXI-tagged spell-list rows
  - **Tables:** `mob_spell_lists`

- `modules/custom/sql/features/healer_tp_abilities.sql`
  - **Feature:** Healer TP ability progression
  - **Scope:** WHM TP-spender abilities Lv1/25/50/70 (Imagine XI job-agnostic party spec)
  - **Tables:** `abilities`
  - **Spec:** `server/documentation/JOB_AGNOSTIC_PARTY_SPEC.md`
  - **Lua:** `server/scripts/actions/abilities/luminous_strike.lua`, `radiant_scission.lua`, `sacred_cascade.lua`, `divine_resonance.lua`

## Planned / Partial Feature Buckets (next extraction pass)

- `modules/custom/sql/features/pixie_rescue.sql` (expand to full pixie-related data rows from core SQL)
- `modules/custom/sql/features/trust_adjustments.sql` (mix of Lua/C++ with SQL where applicable)
- `modules/custom/sql/features/elemental_population.sql` (weather-linked elemental groups/spawns; move block atomically)
- `modules/custom/sql/features/item_rebalance.sql` (expand from extracted pet rows to full item delta set)
  - now partially complete with all `ImagineXI:`-tagged rows from core item tables

## Notes

- `modules/init.txt` includes `custom`, so all files under `modules/custom/**` are loaded.
- Keep SQL modules idempotent whenever possible (`DELETE` guards, conditional inserts, or upserts).
