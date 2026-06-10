# Starter HNM Loot (Lowbie HNMs)

Player-facing reference for **ImagineXI starter-zone HNMs** (level 10 notorious mobs in the six nation starting fields).

Source logic: `server/scripts/globals/imagine_starter_hnm.lua`

## Who can fight and receive loot

- **Attackers must be eligible:** effective main job level **12 or lower** (level sync counts).
- Over-level players **cannot attack** but may **heal and buff** eligible adventurers.
- **Killer must be eligible** to receive rewards.

## Combat (designed for groups)

Starter HNMs are tuned for **3–5 eligible adventurers**, not solo play:

| Mechanic | Detail |
|----------|--------|
| **HP** | ~7.5× base HP (`HP_SCALE` 750) with regen |
| **Damage** | Elevated melee damage; higher still below 50% HP |
| **AoE** | Nation-themed spells every ~40s (Sleepga, Poison, Bind, etc.) |
| **Phase 2 (50% HP)** | Damage and speed increase; **2 adds** spawn (sheep, lizards, or mandragoras) |

On spawn and engage, zone messages remind players to seek allies and explain the mentor/support role.

## Rewards per kill

| Reward | Amount |
|--------|--------|
| **Gil** | **3,000 – 8,000** (random, before any server `GIL_RATE` the client may apply elsewhere) |
| **Items** | **3 random** entries from the pool below (no duplicates within the same kill) |
| **Crystal clusters** | **2 random elements** (1 cluster each; no duplicate element on the same kill) |

Loot is script-granted on death (`NO_DROPS` on the mob prevents duplicate native table drops).

## Spawn zones

| Zone | Zone ID | HNM name |
|------|---------|----------|
| West Ronfaure | 100 | Ronfaure Warden |
| East Ronfaure | 101 | Eastron Warden |
| South Gustaberg | 107 | Gustaberg Warden |
| North Gustaberg | 106 | Gustaberg Sentinel |
| East Sarutabaruta | 116 | Saruta Warden |
| West Sarutabaruta | 115 | Saruta Sentinel |

---

## Crystal cluster drops (every kill)

Each kill always awards **2** crystal clusters from **2 different elements** (1 of each):

| Item ID | Item name |
|---------|-----------|
| 4104 | Fire Cluster |
| 4105 | Ice Cluster |
| 4106 | Wind Cluster |
| 4107 | Earth Cluster |
| 4108 | Lightning Cluster |
| 4109 | Water Cluster |
| 4110 | Light Cluster |
| 4111 | Dark Cluster |

---

## Full item pool (36 items)

Every item below can drop from a starter HNM kill. Each kill rolls **3** distinct items from this list. All equipment is **level 15 or lower**; materials are NM signature drops from level 1–15 zone NMs.

| Item ID | Item name | Original NM (level 1–15 zones) |
|---------|-----------|--------------------------------|
| 550 | Steam Clock | Bubbly Bernie |
| 769 | Red Rock | Bigmouth Billy |
| 910 | Lumbering Horn | Bloodtear Baldurf |
| 911 | Rampaging Horn | Rampaging Ram / Steelfleece Baldarich |
| 912 | Beehive Chip | Stinging Sophie |
| 1152 | Lump of Bomb Steel | Forger |
| 2826 | Mandragora Scale | Backoo |
| 2832 | Samwell's Shank | Slumbering Samwell |
| 2834 | Immortal Molt | Highlander Lizard |
| 2842 | Flawed Garnet | Bedrock Barry |
| 2854 | Stately Crab Shell | Metal Shears |
| 4527 | Jug of Mary's Milk | Stray Mary |
| 12371 | Clipeus | Fungus Beetle |
| 12736 | Mitts | Yagudo Mendicant |
| 12864 | Slacks | Yagudo Mendicant |
| 12992 | Solea | Yagudo Mendicant |
| 13112 | Rabbit Charm | Jaggedy-Eared Jack |
| 13548 | Astral Ring | Treasure and Tribulations / Wings of Fury |
| 13607 | Mist Silk Cape | Spiny Spipi |
| 14803 | Optical Earring | Maighdean Uaine |
| 15218 | Entrancing Ribbon | Sharp-Eared Ropipi |
| 15351 | Bounding Boots | Leaping Lizzy |
| 15546 | Fasting Ring | Yara Ma Yha Who |
| 16185 | Pelte | Duke Decapod |
| 16296 | Armiger's Lace | Tococo |
| 16443 | Fruit Punches | Tom Tit Tat |
| 16486 | Beestinger | Stinging Sophie |
| 17366 | Mary's Horn | Stray Mary |
| 17594 | Gelong Staff | Swamfisk |
| 17811 | Katayama-Ichimonji | Carnero |
| 18246 | Rogetsurin | Haty / Bendigeit Vran |
| 18394 | Pilgrim's Wand | Nunyenunc |
| 18412 | Gassan | Chocoboleech |
| 19043 | Tenax Strap | Amanita |
| 19160 | Estramacon | Ghillie Dhu |
| 19305 | Pike | Numbing Norman |

---

## GM testing

Command: `!starterhnm` (GM permission 1)

| Usage | Effect |
|-------|--------|
| `!starterhnm` | Force-spawn the HNM for your current zone (configured coords) |
| `!starterhnm here` | Force-spawn at your position (best for quick fights) |
| `!starterhnm all` | Force-spawn one in each starter zone |
| `!starterhnm status` | Show XP pool, threshold, active flag, and cooldown for current zone |
| `!starterhnm <zoneId>` | Force-spawn in a specific zone (100, 101, 106, 107, 115, 116) |

GM spawns bypass cooldown and replace any existing active HNM in that zone.

---

## Tuning constants (operators)

In `imagine_starter_hnm.lua`:

| Constant | Current value |
|----------|---------------|
| `LOOT_ROLLS` | 3 |
| `CLUSTER_ROLLS` | 2 |
| `GIL_MIN` | 3,000 |
| `GIL_MAX` | 8,000 |
| `MAX_CLAIM_LEVEL` | 12 |
| `HP_SCALE` | 750 |
| `DAMAGE_MULTIPLIER` | 165 |
| `REGEN` | 14/tick |
| `AOE_INTERVAL_SEC` | 40 |
| `PHASE_HPP` | 50 |
| `ADD_COUNT` | 2 |
| `BASE_XP_THRESHOLD` | 100,000 (85–115% jitter) |
| `POST_KILL_COOLDOWN` | 45 minutes |
| `DESPAWN_SECONDS` | 2 hours |
