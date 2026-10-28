# Imagine XI 2.0

This is the Imagine XI 2.0 game server, built on [LandSandBoat](https://github.com/LandSandBoat/server).

**Play:** download [ImagineXILauncher.exe](https://github.com/markup-ux/imaginexi-updates/releases/download/ixi20/ImagineXILauncher.exe) and run it. An official FFXI client is required (not included). Leave **Play on this PC** unchecked unless you are hosting.

To run your own copy, follow the LandSandBoat quick start below. Custom gameplay is already wired in `modules/init.txt` under `modules/custom`. Set `zone_settings.zoneip` in `modules/custom/sql/ixi20_public_zoneip.sql` to your own public IPv4 before remote players zone. This repo does not include a home network address.

Feature notes: `modules/custom/README_IXI20.md`.

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
