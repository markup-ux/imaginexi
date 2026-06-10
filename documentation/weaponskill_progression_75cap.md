# Weapon skill progression (75-cap server)

See also: **[weaponskill_availability_by_level.md](./weaponskill_availability_by_level.md)** — FFXIclopedia-style sections per weapon type (job skill ratings + weapon skills), retail min levels, compressed 61–75 suggestions, and display names from `player_abilities.txt` where available.

## Server behavior (after gate fix)

- **Normal WS:** Shown and used when effective weapon skill (`GetSkill`) meets the `skilllevel` column and any `unlock_id` merit/quest flag is satisfied. Job columns in `weapon_skills` are **not** enforced in code (any job may use the WS if skill + unlock allow).
- **Compressed WS (skill floor above best cap at `main.MAX_LEVEL`):** When `skilllevel` is higher than the best job’s cap for that weapon type at server max level (from `skill_caps` / `skill_ranks`, same basis as **`weaponskill_availability_by_level.md`** “Suggested Lv”), the WS is allowed if: `unlock_id` is satisfied (or zero), **`GetMLevel()`** is at least the **suggested level** (linear map **250 → 61** through **357 → 75**; requirements **≤ 250** use **61**), and **`GetSkill`** is at least the character’s **personal cap** for that category (main job cap, or sub job cap if main has no rank). Implemented in **`battleutils::CanUseWeaponskill`**.
- **Mythic / empyrean / aeonic-style WS (`skilllevel` 0, `unlock_id` > 0):** Require `hasLearnedWeaponskill(unlock_id)` **and** main job level **`>= main.MAX_LEVEL`** (typically 75 here).
- **Relic / special item WS (`skilllevel` 0, `unlock_id` 0):** Not eligible from skill alone. They appear only when an equipped item grants them via **`Mod::ADDS_WEAPONSKILL` (355)** in `item_mods`, or other packet/list paths that set the equipped WS id.

## Suggested progression vs retail “post-75” content

Retail tied the highest tiers to level **80+ / 99 / master** trials. On a **75-cap** server, a practical approach is:

1. **Keep skill floors** as in `weapon_skills.sql` (including 357 for empyrean-tier WS) so players still climb the weapon skill ladder under normal caps.
2. **Gate mythic unlocks** with existing quests (`addLearnedWeaponskill` in quest scripts) when the character reaches **75** on the relevant job.
3. **Treat empyrean / aeonic / omen-era WS** as **endgame at 75**: allow the unlock quests or custom NPCs once base job is 75 and weapon skill is at cap for 75; the server already requires `unlock_id` learned + level `>= MAX_LEVEL` to list those with `skilllevel == 0`.
4. **High `skilllevel` WS (e.g. 357)** use **compression** in code when that floor exceeds the best cap at **`main.MAX_LEVEL`**: players need capped skill for their job combo, the unlock if any, and the mapped main level (see **Compressed WS** above). SQL `skilllevel` can stay at retail values.

---

## Relic & item-granted WS (`skilllevel` 0, `unlock_id` 0)

Equipped **relic** (and some other) weapons grant the WS id via **`ADDS_WEAPONSKILL`**. You must equip the weapon (or have the latent, e.g. Allied Tags) to see/use the WS. Representative item ids (see `item_mods` for full tiers):

| WS name | WS id | Weapon skill type | Typical source |
|--------|-------|-------------------|----------------|
| Final Heaven | 10 | Hand-to-hand | Spharai line (`ADDS_WEAPONSKILL` 10) |
| Mercy Stroke | 26 | Dagger | Mandau line |
| Knights of Round | 43 | Sword | Excalibur line |
| Scourge | 57 | Great sword | Ragnarok line |
| Onslaught | 73 | Axe | Brutal / relic axe line |
| Metatron Torment | 89 | Great axe | Brut / relic GA line |
| Catastrophe | 105 | Scythe | Apocalypse line |
| Geirskogul | 121 | Polearm | Gungnir line |
| Blade: Metsu | 137 | Katana | Kikoku line |
| Tachi: Kaiten | 153 | Great katana | Amanomurakumo line |
| Tachi: Suikawari | 158 | Great katana | Event / special items (if modded) |
| Randgrith | 170 | Club | Mjollnir line |
| Gate of Tartarus | 185 | Staff | Claustrum line |
| Namas Arrow | 200 | Archery | Yoichinoyumi line |
| Coronach | 216 | Marksmanship | Annihilator line |
| Knights of Rotund | 227 | Sword | Custom item (e.g. id 20714) |
| Final Paradise | 228 | Hand-to-hand | Custom item (e.g. id 21509) |
| Uriel Blade | 238 | Sword | Allied Tags latent / campaign |
| Glory Slash | 239 | Sword | Allied Tags latent / campaign |
| Tartarus Torpor | 240 | Staff | Add `ADDS_WEAPONSKILL` if you want it item-gated |

---

## Mythic & merit-style unlocks (`unlock_id` 1–63)

Names and numeric ids live in **`scripts/enum/ws_unlock.lua`**. The **Unlocking a Myth** vigil weapon ↔ WS mapping is in **`scripts/quests/jeuno/helpers.lua`** (`UnlockingAMyth` → `vigilWeaponsData`). Other quests call `player:addLearnedWeaponskill(xi.wsUnlock.*)` (see `scripts/quests/**`).

After this gate change, any WS with **`skilllevel == 0`** and **`unlock_id > 0`** requires:

1. **`hasLearnedWeaponskill(unlock_id)`** (quest / merit / GM), and  
2. **`GetMLevel() >= main.MAX_LEVEL`** (75 on a 75-cap server).

There is **no extra weapon-skill floor** on those rows in SQL (`skilllevel` 0); weapon type still comes from the WS `type` column when resolving the skill category.

---

## Empyrean-tier WS (skill 357, non-zero `unlock_id`)

These rows use **`skilllevel` 357** in SQL and a **learned unlock**. At **75 cap**, 357 is above the natural skill ceiling, so **`CanUseWeaponskill`** uses the **compressed** rules: **capped** weapon skill for the character’s jobs, unlock satisfied, and **`GetMLevel()` ≥ 75** (357 maps to the top of the 61–75 band). Same pattern applies to other WS whose SQL floor is above the best cap at **`main.MAX_LEVEL`**.

| WS name | WS id | Skill type | `unlock_id` |
|--------|-------|------------|-------------|
| Shijin Spiral | 15 | H2H | 60 |
| Resolution | 60 | Great sword | 57 |
| Ruinator | 77 | Axe | 58 |
| Upheaval | 93 | Great axe | 63 |
| Entropy | 109 | Scythe | 52 |
| Stardiver | 125 | Polearm | 61 |
| Blade: Shun | 141 | Katana | 51 |
| Tachi: Shoha | 157 | GKT | 62 |
| Realmrazer | 174 | Club | 55 |
| Shattersoul | 191 | Staff | 59 |
| Apex Arrow | 203 | Archery | 50 |
| Last Stand | 221 | Marksmanship | 54 |
| Exenterator | 224 | Dagger | 53 |
| Requiescat | 226 | Sword | 56 |

---

## Skill type id (`weapon_skills.type`)

| `type` | Category |
|-------|----------|
| 1 | Hand-to-hand |
| 2 | Dagger |
| 3 | Sword |
| 4 | Great sword |
| 5 | Axe |
| 6 | Great axe |
| 7 | Scythe |
| 8 | Polearm |
| 9 | Katana |
| 10 | Great katana |
| 11 | Club |
| 12 | Staff |
| 25 | Archery |
| 26 | Marksmanship |
