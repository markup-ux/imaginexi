# Imagine XI 2.0

This is the Imagine XI 2.0 game server, built on [LandSandBoat](https://github.com/LandSandBoat/server).

**Play:** download [ImagineXILauncher.exe](https://github.com/markup-ux/imaginexi-updates/releases/download/ixi20/ImagineXILauncher.exe) and run it. An official FFXI client is required (not included). Leave **Play on this PC** unchecked unless you are hosting.

**Modules:** drop-in copies and the per-feature catalog are in [imaginexi-2.0-modules](https://github.com/markup-ux/imaginexi-2.0-modules). This repo already loads them from `modules/init.txt`. Notes for each file are in `modules/custom/README_IXI20.md`.

To run your own copy, follow the LandSandBoat quick start below. Set `zone_settings.zoneip` in `modules/custom/sql/ixi20_public_zoneip.sql` to your own public IPv4 before remote players zone. This repo does not include a home network address.

## Server features

### Jobs and progression

- Cap: main 75 / sub 37. Start at level 1. No Limit Breaks.
- All jobs unlocked at creation (WAR–RUN). Subjob unlocked from the start.
- Abilities, traits, and magic unlock by 37. Two-hours and one-hours from level 1; timed specials last 2 minutes.
- Dual Wield V on WAR–RUN. Treasure Hunter 3 on THF / BST / RNG / COR.
- Casters get Refresh, Conserve MP, and Fast Cast. RDM Shield Mastery at 1.
- Native weapons A+. Ninjutsu A+ on every job. Songs A+ on BRD.
- Combat, magic, and defensive skills stay at the stored job cap.
- Half of gained XP also levels the current subjob (capped at 37). Dedication is always on (+150% EXP).
- Spells are granted on login, level-up, and job change.

### Gear and economy

- Any equipment on any job. AF1 / Yinyang at 50; AF2 / Relic at 60. AF1 weapons stay 40.
- Gil and Sparks become XP. Shops do not sell weapons or armor. Remaining NPC and guild stock is free.
- Decent Challenge+ kills drop gear. Too Weak drops nothing. 10% cosmetic drop on EXP kills, into wardrobe.
- The Auction House is a gift locker: no gil fees or payouts.
- Vendor sells of combat gear and crystals become XP. Valid craft recipes never break; HQ stays retail.

### Combat

- Trusts fill a party of 6, do not reduce experience, level with you, and weaponskill at 1000 TP. `!trusts` saves a list of five.
- Party members share each other's job traits. Level Sync can raise or lower to the designee, and the set stays on.
- Player melee, ranged, and physical weaponskills connect. Mobs can still miss. Shadows, parry, and guard still work.
- Provoke on MNK / PLD / NIN / RUN. Combat ammo is not consumed. Ninjutsu needs no tools.
- Mana Wall, Accession, and Manifestation are toggles. Cascade lasts 8 minutes at 10% magic attack bonus.
- Scholar stratagems from level 1 (5×48s). Light or Dark Arts unlocks both schools.
- Corsair: every Phantom Roll from the start, no dice. Quick Draw does not use cards.
- Dragoon wyvern is hybrid damage and party support. A subjob Dragoon can Call Wyvern. Avatar perpetuation is 0.
- Enhancing magic, songs, and rolls last until you zone, die, or change jobs. Ninja, Samurai, and Dragoon stances last 1 hour.

### Travel and world

- On death, a spirit raises you. Weakness stays. Death does not cost experience.
- Crag crystals, both airship passes, every map, and Survival Guides on creation. Mounts at main level 10, including cities.
- Homepoints, airships, and chocobos are free. Teleports do not require a prior visit. Instant Warp is not consumed.
- Missions do not gate the world. Sea, Dynamis, Assault, Salvage, Abyssea, Adoulin, and Sky are open from the start. A Chronicler NPC can play, skip, or close a chapter.
- Home-nation fields have lowbie HNMs. World HNMs use timed respawns, lottery claim, and raised HP. Sky gods and Kirin keep their own lockout.

---

<p align="center">
    <img width="256" height="256" src="res/lsb_logo_circle.png">
    <h1 align="center">LandSandBoat</h1>
</p>

<p align="center">
An open-source server emulator for FFXI.
</p>

<p align="center">
<a href="https://github.com/LandSandBoat/server/actions/workflows/build.yml"><img src="https://github.com/LandSandBoat/server/actions/workflows/build.yml/badge.svg?branch=base"/></a>
<a href="https://github.com/LandSandBoat/server/actions/workflows/test.yml"><img src="https://github.com/LandSandBoat/server/actions/workflows/test.yml/badge.svg?branch=base"/></a>
<a href="https://www.gnu.org/licenses/gpl-3.0"><img src="https://img.shields.io/badge/License-GPLv3-blue.svg"/></a>
<a href="https://github.com/LandSandBoat/server/pulls"><img src="https://img.shields.io/badge/Contributions-welcome-brightgreen.svg?style=flat"/></a>
</p>

## Getting Started

A [quick start guide](https://github.com/LandSandBoat/server/wiki/Quick-Start-Guide), the [frequently asked questions](https://github.com/LandSandBoat/server/wiki/Frequently-Asked-Questions), and a table of "[what works](https://github.com/LandSandBoat/server/wiki/What-Works)" are all available on [our wiki](https://github.com/LandSandBoat/server/wiki).

## Interacting with LandSandBoat

### Crashes, warnings, errors, bugs, gameplay issues, visual issues, questions, documentation issues, build problems, etc.

Please create a new issue in the [issues tab](https://github.com/LandSandBoat/server/issues) after searching to see if your issue is already logged.

*If you are encountering an issue, please open an issue!* It's easier for us to track and you're more likely to get resolution through an issue than any other means.

### AI Agents and their use

If you're a human using AI agents or an AI agent you should go read `./docs/ai_agents/README.md`.

## LICENSE

LandSandBoat is licensed under [GNU GPL v3](https://github.com/LandSandBoat/server/blob/base/LICENSE)

## Thanks

Thanks to all contributors past and present, we wouldn't be here without you!

Thanks to GitHub for hosting us, and for all the CI minutes we use!
