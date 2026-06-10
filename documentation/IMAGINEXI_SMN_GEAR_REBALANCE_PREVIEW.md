# Imagine XI — SMN dead stats & enmity (per-job balance) — preview before deploy

This document is a **design and inventory** for replacing modifiers that no longer matter on Imagine XI:

- **Avatar perpetuation** (`PERPETUATION_REDUCTION` / `346`, `HALF_PERPETUATION_*` / `356`, `1170`, `1171`) — MP perpetuation is forced to zero in `petutils::PerpetuationCost()`.
- **Blood Pact timers** (`BP_DELAY` / `357`, `BP_DELAY_II` / `541`) — BP recast groups are cleared / minimal recast in `z_imagine_xi_30_smn_no_perp_no_bp_timers.sql` on abilities.
- **Enmity** (`ENMITY` / `27`) — **Assume it is useless** on Imagine XI (provoke-style lock makes hate tuning irrelevant). **Remove or replace every `modId = 27` row** in `item_mods`, `item_mods_pet`, and any **`item_latents` / gear-set bonuses** that grant enmity. **Do not** put SMN pet stats (`992`/`993`) on non-SMN jobs: for **master** gear, use the **per-job matrix** from `item_equipment.jobs`. For **pets**, use Wyvern / Automaton / Jug / Avatar rules in this doc—not one stat for all pets.

**Server truth** is `item_mods` / `item_mods_pet` / `item_latents` / `augments` in MariaDB. **Client tooltips** come from ROM DATs; after SQL changes, sync descriptions per `Windower/addons/XIPivot/data/DATs/ImagineXI/README_IMAGINE_XI_DATS.md` and the item-description sync rule.

---

## Modifier mapping (SMN playstyle)

| Old mod | ID | Replacement mod | ID | Scaling notes |
|--------|-----|-----------------|-----|----------------|
| Perpetuation reduction | 346 | Summoning magic skill | 117 | Use tiered values similar to existing `z_imagine_xi_80_item_rebalance.sql` (+5 to +13 where old perp was +1 to +9). |
| Blood Pact ability delay | 357 | Pet MACC & pet MEVA | 993 | Map old BP delay magnitude to **PET_MACC_MEVA** (already used in `z_imagine_xi_80_item_rebalance.sql`). |
| Blood Pact ability delay II | 541 | Pet MAB & pet MDB | 992 | Same file maps II → 992. |
| Half perpetuation / Carby half | 356, 1170, 1171 | Summoning **or** split 117 + small 993 | 117 / 993 | No half-cost left; treat as flavor → skill + light pet support. |
| Avatar Enmity (pet row, petType Avatar) | 27 (pet) | 993 or 992 | 993 / 992 | SMN-only; see pet table later. |
| Master Enmity | 27 (master) | **Per job** — see matrix | — | Use job mask on the item, not the job editing the SQL. |

Reference: `server/scripts/enum/mod.lua` (`SUMMONING`, `PET_MACC_MEVA`, `PET_MAB_MDB`, `BP_DAMAGE`, etc.).

---

## Master Enmity — classify gear, then balance **per job**

**Assumption:** `ENMITY` / `27` does **nothing** worth itemizing. There is no “keep for tanks”—convert **all** + and − values using the job matrix and magnitude (e.g. |Enmity 5| ≈ five points of budget into one or two replacement mods).

**Step 1 — Who can equip it?** Use `item_equipment.jobs` (bit `1 << (jobId - 1)` in this codebase, e.g. SMN job 15 → `16384`).

**Step 2 — Sign of the old line:** **−Enmity** and **+Enmity** both get removed; use the column that matches the *role* of the piece (DPS vs tank slot) when two columns differ.

**Step 3 — Replacement budget:** Spread roughly the same “budget” as |old `27`| into mods natural for that job. Avoid duplicating a stat the item already stacks heavily.

### Per-job replacement cheatsheet (master `item_mods`, mod `27` → delete row, insert replacement)

Mod IDs are from `mod.lua`. Pick one or two cells per row.

| Job | JobId | −Enmity → (pick 1–2) | +Enmity → (pick 1–2) |
|-----|-------|----------------------|----------------------|
| WAR | 1 | `ATT` 23, `ACC` 25, `STORETP` 73, `DA` 288 | `HP` 2, `VIT` 10, `DEF` 1, `PARRY` 110 |
| MNK | 2 | `ATT`, `ACC`, `HASTE_GEAR` 384, `KICK_ATTACK` | `SUBTLE_BLOW` 289, `COUNTER`, `HP` |
| WHM | 3 | `CURE_POTENCY` 374, `MND` 13, `HEALING` 112, `CONSERVE_MP` 296 | `MND`, `CURE_POTENCY`, `HP` |
| BLM | 4 | `MACC` 30, `MATT` 28, `INT` 12, `ELEM` 115 | `INT`, `MAGIC_BURST_BONUS_CAPPED` 487 |
| RDM | 5 | `FASTCAST` 170, `MACC`, `ENFEEBLE` 114, `CONSERVE_MP` | `ENH_MAGIC_DURATION` 890, `MATT`, `MND` |
| THF | 6 | `ACC`, `DEX` 9, `TRIPLE_ATTACK` 302, `CRITHITRATE` 165 | `EVA` 68, `AGI` 11, `HP` |
| PLD | 7 | `SHIELD` 109, `MND` 13, `DIVINE` 111, `HP` | `DEF`, `HP`, `VIT`, `SHIELD` |
| DRK | 8 | `ATT`, `ACC`, `STP`, `DA` | `HP`, `ATT`, `MACC` 30 (if hybrid piece) |
| BST | 9 | `CHR` 14, `AXE` / reward-line skill, `PET_ACC_EVA` 991 on pet-focused slots | `PET_ACC_EVA` 991, `CHR`, `HP` |
| BRD | 10 | `CHR`, `SINGING` 119, song-duration / song skill mods, `FASTCAST` | `CHR`, `MND`, `HP` |
| RNG | 11 | `RACC` 26, `RATT` 24, `AGI`, `SNAPSHOT` 365 | `AGI`, `RACC`, `TRUE_SHOT` family if item already has it |
| SAM | 12 | `STORETP`, `ZANSHIN` 306, `ATT`, `ACC` | `HASTE_GEAR`, `SUBTLE_BLOW`, `HP` |
| NIN | 13 | `ACC`, `ATT`, `HASTE_GEAR`, `EVA` | `EVA`, `HP`, `AGI` |
| DRG | 14 | `ACC`, `ATT`, `STP`, jump-themed mods on item | `HP`, `VIT`; pet rows → Wyvern table below |
| SMN | 15 | `SUMMONING` 117, `CONSERVE_MP`, `MACC`, `BP_DAMAGE` 126 | `117`, `296`, `126`, `MP` 5 |
| BLU | 16 | `BLUE` 122, `MACC`, `MATT`, `MP` 5 | `HP`, `ACC`, `ATT` |
| COR | 17 | `RACC`, `AGI`, `SNAPSHOT`, roll / QD themed mods | `ACC`, `RACC`, `AGI` |
| PUP | 18 | `AUTO_MELEE_SKILL` 101, `AUTO_RANGED_SKILL` 102, `AUTO_MAGIC_SKILL` 103 | `HP`, `DEF`; pet rows → Automaton table below |
| DNC | 19 | `CHR`, `ACC`, `HASTE_GEAR`, `STORETP` | `SUBTLE_BLOW`, `CHR`, `HP` |
| SCH | 20 | `ENHANCE` 113, Grimoire / Helix themed mods, `MND`, `CONSERVE_MP` | `MND`, `MACC`, `HP` |
| GEO | 21 | `GEOMANCY_SKILL` 123, `HANDBELL_SKILL` 124, `MACC`, `MND` | `MND`, `MACC`, luopan-themed if present |
| RUN | 22 | `PARRY` 110, `ENFEEBLE` 114, `HP`, `DEF` | `HP`, `VIT`, `DEF`, `EVA` 68 |

**Multi-job items:** Prefer stats that **all** flagged jobs can use (e.g. `HP`, `MP`, `HASTE_GEAR`) or split into the **narrowest** job set if the piece is effectively one job’s AF (grep name + `jobs`).

**`item_mods_pet` (non-Avatar):**

| Pet flag (column) | Replace pet `27` with |
|-------------------|------------------------|
| Wyvern (DRG) | `991` **PET_ACC_EVA** or small `ATT` on pet rows if your schema supports it |
| Automaton (PUP) | `991` / `992` / automaton-specific mods already used on that item line |
| Jug pet / “All Pets” BST | `991` or master-side `CHR` / reward mods — match existing BST balance on Imagine |

**Avatar-only** stays: **−Enmity** → `993`, **+Enmity** → `992` as in the table below.

---

## Already drafted: `server/sql/z_imagine_xi_80_item_rebalance.sql`

This file **adds** replacement rows for many `(itemId, modId)` pairs. Because `item_mods` has `PRIMARY KEY (itemId, modId)`, these inserts use **new** `modId`s (117, 992, 993) alongside the **old** rows still present in `item_mods.sql` unless you **delete** the obsolete rows on deploy.

**Included (representative):** Evoker’s / Nashira / Marduk / Caller's / Beckoner’s / Apogee / Glyphic / Azimuth / Bunzi’s / etc., plus `item_mods_pet` swaps for 10664, 10684, 15146, 15679.

**Verify on deploy:** run a post-import check that no item still has mods **346**, **357**, or **541** if you intend those to be fully removed (requires `DELETE` + `INSERT`, or editing the canonical `item_mods.sql` dump).

---

## Gaps — `item_mods.sql` rows **not** covered by `z_imagine_xi_80_item_rebalance.sql`

These items still have **BP_DELAY (357)** only in the base dump and need the same treatment as the rest (example: map delay `N` → `993` using the same curve as nearby items in `z_80`).

| itemId | Name (from `item_equipment`) | Current mod | Proposed replacement (example) |
|--------|------------------------------|---------------|--------------------------------|
| 11564 | tiresias_cape | 357, +3 | `(11564, 993, 7)` — same budget as other “−3 delay” style capes in `z_80`. |
| 15086 | summoners_horn | 357, +3 | `(15086, 993, 7)` |
| 15101 | summoners_dblt. | 357, +3 | `(15101, 993, 7)` |
| 15116 | summoners_brcr. | 357, +2 | `(15116, 993, 6)` |
| 15131 | summoners_spats | 357, +2 | `(15131, 993, 6)` |
| 28605 | samanisi_cape | 357, +3 | `(28605, 993, 7)` |

*(Exact 993 numbers can mirror the closest ilvl piece already mapped in `z_80`.)*

---

## Half-perpetuation and Carby mitts (`item_mods.sql`)

Not present in `z_imagine_xi_80_item_rebalance.sql`. Suggested overrides (delete old PK row, insert new):

| itemId | Current | Suggested |
|--------|---------|-----------|
| 11118 | 1170, 1171 (half perp day/weather) | Remove both; add `(11118, 117, 5)` and `(11118, 993, 4)` or a single stronger 117 row to preserve “bracer” value. |
| 11218 | 1170 (and weather pair if present) | Same pattern as 11118. |
| 14062 | 356 (half perp Carby) | `(14062, 117, 4)` + optional `(14062, 993, 3)` — mitts are SMN support. |
| 23233 | 1170, 1171 | Beckoner line: `(23233, 117, 8)` + `(23233, 993, 6)` (tune to ilevel). |
| 27080, 27081 | 1170, 1171 | Same as 23233 with values scaled to +1 / +1 AF3 tier. |
| 27106, 27107 | 356 | `(27106, 117, 3)`, `(27107, 117, 4)` or add 993 instead of duplicating summoning if 117 already high on set. |

---

## Latents (`item_latents.sql`) — mod 346

Replace latent **346** with **117** (Summoning) or **993** on the avatar depending on whether the latent was “cheap MP” flavor:

| itemId | Notes | Suggestion |
|--------|-------|--------------|
| 11752 | Diabolos perp −1 | `(11752, 117, 2, …)` keep same latent conditions, change mod. |
| 12493 | Fenrir perp −1 | `(12493, 117, 2, …)` |
| 13300 | Perp −1 HP/TP gate | `(13300, 993, 2, …)` or 117 +1 |
| 14062 | placeholder 346,0 | Remove row or set to 117/993 with same condition as C++ special case (see comment in SQL). |
| 14401, 14410 | Spirit perp −1 | `(14401, 117, 1, …)` / `(14410, 117, 1, …)` |
| 14946 | duplicate latent rows | Re-validate both lines; map 346 → 117. |
| 15285, 16154 | perp −2 | `(itemId, 117, 3, …)` |
| 25633 | Carbuncle perp −1 | `(25633, 117, 1, …)` |

---

## Augments (`augments.sql`)

| augmentId | Current | Suggestion |
|-----------|---------|------------|
| 320 | 357, +1 (“BP delay −1”) | **993**, +2 (pet MACC/MEVA) or **117**, +1 |
| 321 | 346, +1 (“perp −1”) | **117**, +2 |

Update any **Lua/SQL loot** that references augment **320** / **321** by name in comments only; IDs stay the same if you `UPDATE augments SET modId=…`.

**Script reference:** `server/scripts/zones/Lower_Jeuno/npcs/Treasure_Coffer_Tenshodo.lua` uses augment **320** for BP delay — change comment and verify power scaling if mod changes.

---

## `item_mods_pet.sql` — Avatar **ENMITY** (mod 27, petType **1** = Avatar)

SMN-only. Replace avatar enmity with pet-focused SMN stats (do **not** copy this table onto Wyvern / Automaton / Jug rows):

| itemId | Current | Suggested |
|--------|---------|-----------|
| 11739 | 27, +2 | `(11739, 992, 2, 1)` |
| 12520 | 27, −3 | `(12520, 993, 3, 1)` |
| 12650 | 27, −2 | `(12650, 993, 2, 1)` |
| 13975 | 27, −2 | `(13975, 993, 2, 1)` |
| 14103 | 27, −2 | `(14103, 993, 2, 1)` |
| 14228 | 27, −2 | `(14228, 993, 2, 1)` |
| 14468 | 27, +5 | `(14468, 992, 5, 1)` |
| 14904 | 27, −2 | `(14904, 993, 2, 1)` |
| 15239 | 27, −3 | `(15239, 993, 3, 1)` |
| 15366 | 27, −4 | `(15366, 993, 4, 1)` |
| 15575 | 27, −2 | `(15575, 993, 2, 1)` |
| 15594 | 27, +2 | `(15594, 992, 2, 1)` |
| 15679 | 27, +2 | `(15679, 992, 2, 1)` |
| 21167 | 27, +10 | `(21167, 992, 8, 1)` (cap if needed) |
| 26677 | 27, +10 | `(26677, 992, 8, 1)` |
| 26888 | 27, +14 | `(26888, 992, 10, 1)` |
| 27221 | 27, +4 | `(27221, 992, 4, 1)` |
| 27677 | 27, +4 | `(27677, 992, 4, 1)` |
| 27698 | 27, +4 | `(27698, 992, 4, 1)` |
| 27957 | 27, +5 | `(27957, 992, 5, 1)` |
| 27978 | 27, +5 | `(27978, 992, 5, 1)` |
| 28104 | 27, +4 | `(28104, 992, 4, 1)` |
| 28125 | 27, +4 | `(28125, 992, 4, 1)` |
| 28237 | 27, +5 | `(28237, 992, 5, 1)` |
| 28258 | 27, +5 | `(28258, 992, 5, 1)` |

**Do not change** rows where `modId=27` is **not** enmity (e.g. Automaton ACC uses column order that can include `27` as a *value* — grep shows `(23080,25,27,3)` is ACC 27, not ENMITY).

---

## `item_mods.sql` — Master **ENMITY** (examples + workflow)

| itemId | Job context | Current | Suggested |
|--------|-------------|---------|-----------|
| 10321 | SMN-only | 27, −5 | Per SMN row in matrix: `(10321, 296, 5)` or `(10321, 126, 3)` |
| 12210–12212 | Multi-job ears; use **intersection** of jobs | 27, −1 | Prefer `HASTE_GEAR` / `FASTCAST` / `CONSERVE_MP` if many casters share it; else `ACC` for melee share |

**Workflow for every other `item_mods` row with `modId = 27`:**

1. Load `itemId` → `jobs` from `item_equipment.sql`.  
2. If `jobs` has a single job bit → use that job’s row in the matrix.  
3. If multiple bits → prefer universal secondary stats, or the job the item name/set obviously belongs to.  
4. Re-read the item’s other mods so the replacement does not duplicate an existing large bonus.

---

## Deploy checklist

1. **SQL:** Extend `z_imagine_xi_80_item_rebalance.sql` (or add `z_imagine_xi_81_…sql`) with: gap BP rows, half-perp rows, latent updates, augment updates, pet enmity swaps, master enmity swaps on 10321 / 12210–12212.  
2. **Remove dead rows:** For each changed item, `DELETE` / `REPLACE` obsolete `(itemId, modId)` pairs. For **enmity**, **always** remove master and pet `27` and any latent/set lines that only existed for hate (remap with the same job rules as the base item).  
3. **Abilities:** Ensure `z_imagine_xi_30_smn_no_perp_no_bp_timers.sql` is applied in your migration order.  
4. **Client strings:** Regenerate / overlay DAT descriptions so “Blood Pact ability delay”, “Perpetuation cost”, and “Enmity” lines match new stats.  
5. **QA:** `/checkparam` on a few SMN builds; verify pet gains **PET_MACC_MEVA** / **PET_MAB_MDB** from gear; spot-check a **PLD**/**RUN** piece that used to be “+Enmity” and confirm **no** `27` row remains; confirm no duplicate `(itemId, modId)` unless intentional.

---

## Files touched (summary)

| Area | Path |
|------|------|
| BP / perp replacements (partial) | `server/sql/z_imagine_xi_80_item_rebalance.sql` |
| BP recast / perpetuation runtime | `server/sql/z_imagine_xi_30_smn_no_perp_no_bp_timers.sql`, `server/src/map/utils/petutils.cpp` |
| Canonical data | `server/sql/item_mods.sql`, `item_mods_pet.sql`, `item_latents.sql`, `augments.sql` |
| Loot referencing augment 320 | `server/scripts/zones/Lower_Jeuno/npcs/Treasure_Coffer_Tenshodo.lua` |
| DAT workflow | `Windower/addons/XIPivot/data/DATs/ImagineXI/README_IMAGINE_XI_DATS.md` |

## Deployed in repo (SQL + generator)

| File | Role |
|------|------|
| `server/sql/z_imagine_xi_80_item_rebalance.sql` | Prepends `DELETE` for obsolete 346/357/541 + pet perpet/BP rows, then ImagineXI `INSERT`s (unchanged set). |
| `server/sql/z_imagine_xi_81_smn_extras.sql` | Half-perpetuation item rows, augment 320/321 replace, perpetuation latents → 117/993, **all** `item_mods_pet` enmity → 991/992/993, latent `modId` 27 removed, master `427` stripped. |
| `server/sql/z_imagine_xi_82_enmity_replace_generated.sql` | `DELETE` all master `item_mods` enmity `27`; per-job replacements (`tools/scripts/generate_imagine_xi_81_enmity_sql.py`). **Regenerate** after editing `item_mods.sql` / `item_equipment.sql` enmity-related lines. |
| `server/scripts/zones/Lower_Jeuno/npcs/Treasure_Coffer_Tenshodo.lua` | Comments for augments 320/321. |

**Import order:** `…_80` → `…_81` → `…_82`. Reload DB / run migrations, then sync **client** item text (DAT overlay) so removed lines (“Enmity”, “Blood Pact delay”, perpetuation) match server data.

This design doc remains the rationale; the files above are the **implemented** pipeline.
