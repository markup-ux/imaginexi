# Weapon skill availability by level (75-cap progression)

<!-- Regenerate: `python tools/gen_weaponskill_availability_md.py` (from `server/`) -->

Layout follows **[FFXIclopedia weapon categories](https://ffxiclopedia.fandom.com/wiki/Category:Daggers)** style: each weapon type has **Job skill ratings** then **Weapon skills**, sorted by required combat skill.

## Server rules (summary)

- **Skill math** uses this repo’s **`skill_caps`** and **`skill_ranks`** (`battleutils::GetMaxSkill`). Caps below use **level 75** (not 99).
- **Job flags on WS are not enforced** in map code: any job may use a WS if skill/unlock/item rules pass. Weapon/ranged/H2H categories are **A+ for all jobs** in `skill_ranks`; defensive and magic schools keep retail ranks.
- **Post–75-era** requirements in SQL are folded into **suggested levels** where the skill floor exceeds the best cap at 75.

- See [Combat Skills](https://ffxiclopedia.fandom.com/wiki/Category:Combat_Skills) on the wiki for retail context; numbers here come from **your** SQL dumps.
- **Weapon skill** display names prefer `documentation/player_abilities.txt` (WeaponSkill rows); anything missing there is title-cased from the SQL slug.

## Archery

Ranged archery. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Namas Arrow | 200 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Jishnu's Radiance | 202 | 0 | 47 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Flaming Arrow | 192 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Piercing Arrow | 193 | 40 | 0 | 13 | 13 | 13 | Natural cap (best job rank for this weapon type) |
| Dulling Arrow | 194 | 80 | 0 | 26 | 26 | 26 | Natural cap (best job rank for this weapon type) |
| Sidewinder | 196 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Blast Arrow | 197 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Arching Arrow | 198 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Empyreal Arrow | 199 | 250 | 13 | 70 | 70 | 70 | Natural cap (best job rank for this weapon type) |
| Refulgent Arrow | 201 | 290 | 0 |  |  | 66 | Req. 290 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Apex Arrow | 203 | 357 | 50 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Axes

One-handed axes. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Onslaught | 73 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Primal Rend | 74 | 0 | 23 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Cloudsplitter | 76 | 0 | 39 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Raging Axe | 64 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Smash Axe | 65 | 40 | 0 | 13 | 13 | 13 | Natural cap (best job rank for this weapon type) |
| Gale Axe | 66 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Avalanche Axe | 67 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Spinning Axe | 68 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Rampage | 69 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Calamity | 70 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Mistral Axe | 71 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Decimation | 72 | 240 | 5 | 68 | 68 | 68 | Natural cap (best job rank for this weapon type) |
| Bora Axe | 75 | 290 | 0 |  |  | 66 | Req. 290 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Ruinator | 77 | 357 | 58 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Clubs

One-handed clubs. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Randgrith | 170 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Mystic Boon | 171 | 0 | 29 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Dagan | 173 | 0 | 45 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Shining Strike | 160 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Seraph Strike | 161 | 40 | 0 | 13 | 13 | 13 | Natural cap (best job rank for this weapon type) |
| Brainshaker | 162 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Starlight | 163 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Moonlight | 164 | 125 | 0 | 41 | 41 | 41 | Natural cap (best job rank for this weapon type) |
| Skullbreaker | 165 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| True Strike | 166 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Judgment | 167 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Hexa Strike | 168 | 220 | 0 | 64 | 64 | 64 | Natural cap (best job rank for this weapon type) |
| Black Halo | 169 | 230 | 11 | 66 | 66 | 66 | Natural cap (best job rank for this weapon type) |
| Flash Nova | 172 | 290 | 0 |  |  | 66 | Req. 290 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Realmrazer | 174 | 357 | 55 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Daggers

One-handed daggers. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Mercy Stroke | 26 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Mandalic Stab | 27 | 0 | 17 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Mordant Rime | 28 | 0 | 18 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Pyrrhic Kleos | 29 | 0 | 19 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Rudra's Storm | 31 | 0 | 36 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Wasp Sting | 16 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Gust Slash | 19 | 40 | 0 | 13 | 13 | 13 | Natural cap (best job rank for this weapon type) |
| Shadowstitch | 18 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Viper Bite | 17 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Cyclone | 20 | 125 | 0 | 41 | 41 | 41 | Natural cap (best job rank for this weapon type) |
| Energy Steal | 21 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Energy Drain | 22 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Dancing Edge | 23 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Shark Bite | 24 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Evisceration | 25 | 230 | 2 | 66 | 66 | 66 | Natural cap (best job rank for this weapon type) |
| Aeolian Edge | 30 | 290 | 0 |  |  | 66 | Req. 290 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Exenterator | 224 | 357 | 53 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Great Axes

Two-handed great axes. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Metatron Torment | 89 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| King's Justice | 90 | 0 | 24 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Ukko's Fury | 92 | 0 | 40 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Shield Break | 80 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Iron Tempest | 81 | 40 | 0 | 13 | 13 | 13 | Natural cap (best job rank for this weapon type) |
| Sturmwind | 82 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Armor Break | 83 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Keen Edge | 84 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Weapon Break | 85 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Raging Rush | 86 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Full Break | 87 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Steel Cyclone | 88 | 240 | 6 | 68 | 68 | 68 | Natural cap (best job rank for this weapon type) |
| Fell Cleave | 91 | 300 | 0 |  |  | 68 | Req. 300 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Upheaval | 93 | 357 | 63 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Great Katana

Two-handed great katana. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Tachi: Kaiten | 153 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Tachi: Rana | 154 | 0 | 28 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Tachi: Fudo | 156 | 0 | 44 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Tachi Suikawari | 158 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Tachi: Enpi | 144 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Tachi: Hobaku | 145 | 30 | 0 | 9 | 9 | 9 | Natural cap (best job rank for this weapon type) |
| Tachi: Goten | 146 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Tachi: Kagero | 147 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Tachi: Jinpu | 148 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Tachi: Koki | 149 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Tachi: Yukikaze | 150 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Tachi: Gekko | 151 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Tachi: Kasha | 152 | 250 | 10 | 70 | 70 | 70 | Natural cap (best job rank for this weapon type) |
| Tachi: Ageha | 155 | 300 | 0 |  |  | 68 | Req. 300 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Tachi: Shoha | 157 | 357 | 62 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Great Swords

Two-handed great swords. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Scourge | 57 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Torcleaver | 59 | 0 | 38 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Dimidiation | 61 | 0 | 49 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Hard Slash | 48 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Power Slash | 49 | 30 | 0 | 9 | 9 | 9 | Natural cap (best job rank for this weapon type) |
| Frostbite | 50 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Freezebite | 51 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Shockwave | 52 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Crescent Moon | 53 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Sickle Moon | 54 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Spinning Slash | 55 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Ground Strike | 56 | 250 | 4 | 70 | 70 | 70 | Natural cap (best job rank for this weapon type) |
| Herculean Slash | 58 | 290 | 0 |  |  | 66 | Req. 290 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Resolution | 60 | 357 | 57 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Hand-to-hand

Unarmed and knuckle weapons. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Final Heaven | 10 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Ascetic's Fury | 11 | 0 | 15 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Stringing Pummel | 12 | 0 | 16 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Victory Smite | 14 | 0 | 35 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Final Paradise | 228 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Combo | 1 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Shoulder Tackle | 2 | 40 | 0 | 13 | 13 | 13 | Natural cap (best job rank for this weapon type) |
| One Inch Punch | 3 | 75 | 0 | 24 | 24 | 24 | Natural cap (best job rank for this weapon type) |
| Backhand Blow | 4 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Raging Fists | 5 | 125 | 0 | 41 | 41 | 41 | Natural cap (best job rank for this weapon type) |
| Spinning Attack | 6 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Howling Fist | 7 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Dragon Kick | 8 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Asuran Fists | 9 | 250 | 1 | 70 | 70 | 70 | Natural cap (best job rank for this weapon type) |
| Tornado Kick | 13 | 300 | 0 |  |  | 68 | Req. 300 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Shijin Spiral | 15 | 357 | 60 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Katana

One-handed katana. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Blade: Metsu | 137 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Blade: Kamu | 138 | 0 | 27 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Blade: Hi | 140 | 0 | 43 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Blade: Rin | 128 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Blade: Retsu | 129 | 30 | 0 | 9 | 9 | 9 | Natural cap (best job rank for this weapon type) |
| Blade: Teki | 130 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Blade: To | 131 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Blade: Chi | 132 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Blade: Ei | 133 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Blade: Jin | 134 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Blade: Ten | 135 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Blade: Ku | 136 | 250 | 9 | 70 | 70 | 70 | Natural cap (best job rank for this weapon type) |
| Blade: Yu | 139 | 290 | 0 |  |  | 66 | Req. 290 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Blade: Shun | 141 | 357 | 51 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Marksmanship

Ranged guns/crossbows. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Coronach | 216 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Trueflight | 217 | 0 | 33 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Leaden Salute | 218 | 0 | 34 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Wildfire | 220 | 0 | 48 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Hot Shot | 208 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Split Shot | 209 | 40 | 0 | 13 | 13 | 13 | Natural cap (best job rank for this weapon type) |
| Sniper Shot | 210 | 80 | 0 | 26 | 26 | 26 | Natural cap (best job rank for this weapon type) |
| Slug Shot | 212 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Blast Shot | 213 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Heavy Shot | 214 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Detonator | 215 | 250 | 14 | 70 | 70 | 70 | Natural cap (best job rank for this weapon type) |
| Numbing Shot | 219 | 290 | 0 |  |  | 66 | Req. 290 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Last Stand | 221 | 357 | 54 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Polearms

Two-handed polearms. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Geirskogul | 121 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Drakesbane | 122 | 0 | 26 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Camlann's Torment | 124 | 0 | 42 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Double Thrust | 112 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Thunder Thrust | 113 | 30 | 0 | 9 | 9 | 9 | Natural cap (best job rank for this weapon type) |
| Raiden Thrust | 114 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Leg Sweep | 115 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Penta Thrust | 116 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Vorpal Thrust | 117 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Skewer | 118 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Wheeling Thrust | 119 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Impulse Drive | 120 | 240 | 8 | 68 | 68 | 68 | Natural cap (best job rank for this weapon type) |
| Sonic Thrust | 123 | 300 | 0 |  |  | 68 | Req. 300 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Stardiver | 125 | 357 | 61 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Scythes

Two-handed scythes. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Catastrophe | 105 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Insurgency | 106 | 0 | 25 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Quietus | 108 | 0 | 41 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Slice | 96 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Dark Harvest | 97 | 30 | 0 | 9 | 9 | 9 | Natural cap (best job rank for this weapon type) |
| Shadow of Death | 98 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Nightmare Scythe | 99 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Spinning Scythe | 100 | 125 | 0 | 41 | 41 | 41 | Natural cap (best job rank for this weapon type) |
| Vorpal Scythe | 101 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Guillotine | 102 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Cross Reaper | 103 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Spiral Hell | 104 | 240 | 7 | 68 | 68 | 68 | Natural cap (best job rank for this weapon type) |
| Infernal Scythe | 107 | 300 | 0 |  |  | 68 | Req. 300 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Entropy | 109 | 357 | 52 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Staves

Staves. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Gate of Tartarus | 185 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Vidohunir | 186 | 0 | 30 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Garland of Bliss | 187 | 0 | 31 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Omniscience | 188 | 0 | 32 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Myrkr | 190 | 0 | 46 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Tartarus Torpor | 240 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Heavy Swing | 176 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Rock Crusher | 177 | 40 | 0 | 13 | 13 | 13 | Natural cap (best job rank for this weapon type) |
| Earth Crusher | 178 | 70 | 0 | 23 | 23 | 23 | Natural cap (best job rank for this weapon type) |
| Starburst | 179 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Sunburst | 180 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Shell Crusher | 181 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Full Swing | 182 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Spirit Taker | 183 | 215 | 0 | 63 | 63 | 63 | Natural cap (best job rank for this weapon type) |
| Retribution | 184 | 230 | 12 | 66 | 66 | 66 | Natural cap (best job rank for this weapon type) |
| Cataclysm | 189 | 290 | 0 |  |  | 66 | Req. 290 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Shattersoul | 191 | 357 | 59 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

## Swords

One-handed swords. Skill caps follow `skill_caps` / `skill_ranks` in this repo.

### Job skill ratings

| Job | Skill ranking | Cap at level 1 | Cap at level 49 | Cap at level 75 |
| --- | --- | ---: | ---: | ---: |
| Bard | 01) A+ | 6 | 150 | 276 |
| Beastmaster | 01) A+ | 6 | 150 | 276 |
| Black Mage | 01) A+ | 6 | 150 | 276 |
| Blue Mage | 01) A+ | 6 | 150 | 276 |
| Corsair | 01) A+ | 6 | 150 | 276 |
| Dancer | 01) A+ | 6 | 150 | 276 |
| Dark Knight | 01) A+ | 6 | 150 | 276 |
| Dragoon | 01) A+ | 6 | 150 | 276 |
| Geomancer | 01) A+ | 6 | 150 | 276 |
| Monk | 01) A+ | 6 | 150 | 276 |
| Ninja | 01) A+ | 6 | 150 | 276 |
| Paladin | 01) A+ | 6 | 150 | 276 |
| Puppetmaster | 01) A+ | 6 | 150 | 276 |
| Ranger | 01) A+ | 6 | 150 | 276 |
| Red Mage | 01) A+ | 6 | 150 | 276 |
| Rune Fencer | 01) A+ | 6 | 150 | 276 |
| Samurai | 01) A+ | 6 | 150 | 276 |
| Scholar | 01) A+ | 6 | 150 | 276 |
| Summoner | 01) A+ | 6 | 150 | 276 |
| Thief | 01) A+ | 6 | 150 | 276 |
| Warrior | 01) A+ | 6 | 150 | 276 |
| White Mage | 01) A+ | 6 | 150 | 276 |

### Weapon skills

| Weapon skill | WS id | Req. skill | Unlock | Min Lv (best job) | Min Lv (worst job) | Suggested Lv | Notes |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Knights of Round | 43 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Death Blossom | 44 | 0 | 20 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Atonement | 45 | 0 | 21 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Expiacion | 46 | 0 | 22 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Chant du Cygne | 225 | 0 | 37 |  |  | 75 | Mythic-style: `hasLearnedWeaponskill` + `GetMLevel() >= main.MAX_LEVEL` |
| Knights of Rotund | 227 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Uriel Blade | 238 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Glory Slash | 239 | 0 | 0 |  |  | — | Relic / item `ADDS_WEAPONSKILL` (no SQL skill floor) |
| Fast Blade | 32 | 5 | 0 | 1 | 1 | 1 | Natural cap (best job rank for this weapon type) |
| Burning Blade | 33 | 30 | 0 | 9 | 9 | 9 | Natural cap (best job rank for this weapon type) |
| Red Lotus Blade | 34 | 50 | 0 | 16 | 16 | 16 | Natural cap (best job rank for this weapon type) |
| Flat Blade | 35 | 75 | 0 | 24 | 24 | 24 | Natural cap (best job rank for this weapon type) |
| Shining Blade | 36 | 100 | 0 | 33 | 33 | 33 | Natural cap (best job rank for this weapon type) |
| Seraph Blade | 37 | 125 | 0 | 41 | 41 | 41 | Natural cap (best job rank for this weapon type) |
| Circle Blade | 38 | 150 | 0 | 49 | 49 | 49 | Natural cap (best job rank for this weapon type) |
| Spirits Within | 39 | 175 | 0 | 55 | 55 | 55 | Natural cap (best job rank for this weapon type) |
| Vorpal Blade | 40 | 200 | 0 | 60 | 60 | 60 | Natural cap (best job rank for this weapon type) |
| Swift Blade | 41 | 225 | 0 | 65 | 65 | 65 | Natural cap (best job rank for this weapon type) |
| Savage Blade | 42 | 240 | 3 | 68 | 68 | 68 | Natural cap (best job rank for this weapon type) |
| Sanguine Blade | 47 | 300 | 0 |  |  | 68 | Req. 300 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |
| Requiescat | 226 | 357 | 56 |  |  | 75 | Req. 357 > best cap @75 (276); **Suggested Lv** uses 61–75 compression band |

