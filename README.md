# ImagineXI — Custom FFXI Server

**ImagineXI** is a custom Final Fantasy XI private-server project built on the
[LandSandBoat (LSB)](https://github.com/LandSandBoat/server) framework. The goal of
ImagineXI is to rethink classic FFXI design, remove unnecessary grind, and create a
modernized, balanced, and community-driven MMORPG experience.

This repository is the complete server source tree — anyone is welcome to take it,
build it, and run their own server from it. See [DESIGN_PHILOSOPHY.md](DESIGN_PHILOSOPHY.md)
for the design thinking behind the project.

## What's different from stock LSB / retail

- **75-cap progression** — job abilities, traits, and spells are aligned to a level 75
  cap; content above that is clamped or remapped rather than removed where possible.
- **Full kit by 37** — abilities, traits, SMN blood pacts, and spells unlock by level 37,
  so a level-37 subjob grants the complete toolkit (BLU included — no mob learns).
- **Always-capped combat and magic skills** — weapon, ranged, defensive, and magic-school
  skills are kept at full cap for your stored job levels; weapon skill ranks are A+ for
  every job.
- **Universal gear usage** — weapons and armor can be equipped by any job unless
  explicitly restricted.
- **True bidirectional level sync** — party members sync *up or down* to the sync
  target's real main job level, with skills capped to match while synced.
- **Trust optimizations** — trusts auto-cast buffs and support abilities so mages can
  focus on their kits.
- **Mounts, QoL changes, and faster progression** throughout.

Custom behavior lives primarily in:

- `modules/custom/` — Lua/C++/SQL gameplay modules
- `modules/era/` — era-style tuning (exp tables, drops, cooldowns)
- `scripts/` — ability, spell, mob, and zone logic
- `sql/` — database schema and ImagineXI migrations
- `src/` — core C++ changes (level sync, skill caps, etc.)
- `documentation/` — progression tables and feature notes

## Building and running

ImagineXI builds exactly like upstream LSB. Follow the
[LSB Quick Start Guide](https://github.com/LandSandBoat/server/wiki/Quick-Start-Guide)
for prerequisites (CMake, a C++ toolchain, MariaDB) and platform setup, using this
repository in place of the LSB one.

1. Clone this repository.
2. Build with CMake (`cmake -B build` then `cmake --build build`).
3. Create and populate the database from `sql/`.
4. Copy `settings/default/` values you want to override into `settings/` and configure
   your database credentials and server options there.
5. Start the **connect**, **search**, **world**, and **map** servers.

> This repo does **not** include SQL credentials, keys/certificates, or private
> settings files. You provide your own configuration in `settings/`.

## License

Like LandSandBoat, this project is licensed under the
[GNU GPL v3](LICENSE). It is intended for educational and non-commercial use.
Final Fantasy XI and related trademarks belong to Square Enix; this project does not
distribute official game assets.

## Thanks

Built on the work of the [LandSandBoat](https://github.com/LandSandBoat/server)
project and all its contributors.
