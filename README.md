# ImagineXI – Custom FFXI Server Project

**ImagineXI** is a custom Final Fantasy XI private-server project built on the LandSandBoat (LSB) framework.  
The goal of ImagineXI is to rethink classic FFXI design, remove unnecessary grind, and create a modernized, balanced, and community-driven MMORPG experience.

This repository stores the core server resources used to run ImagineXI, including modules, scripts, and server-side source files.

---

## 📦 Repository Structure

This repo contains the following archived components:

- **modules.zip**  
  Custom gameplay modules, job modifications, trust behavior changes, and server-side systems.

- **scripts.zip**  
  Lua scripts for NPCs, events, abilities, spells, and zone logic.

- **src.zip**  
  Source files for the map server, authentication server, and compile-time features.

These ZIPs preserve the full folder structure without exceeding GitHub’s per-file upload limits.

---

## 🧩 Features & Vision

ImagineXI includes several unique changes compared to standard LSB or retail FFXI:

- **All abilities and spells unlocked at level 1**  
  Reduces early-game bottlenecks and lets players experiment with job mechanics immediately.

- **Universal gear usage**  
  Weapons and armor can be equipped by any job unless explicitly restricted.

- **Rebalanced leveling progression**  
  Designed to reduce melee-burn dominance and promote varied party compositions.

- **Trust optimizations**  
  Trusts auto-cast buffs and support abilities so mages can focus on their kits.

- **Mounts, QoL changes, and fast progression**  

---

## 🛠 Running the Server (Developers)

To use these files:

1. Unzip each archive into the appropriate directory of a clean LSB installation.
2. Configure your database (`xi_world`, `xi_login`, etc.).
3. Update `settings.lua` (not included here for security).
4. Compile the server using standard LSB build instructions.
5. Start the **login**, **map**, and **connect** servers.

> ⚠️ This repo does **not** include:
> - SQL credentials  
> - API keys  
> - Binary executables  
> - Private settings files  
>
> You will need to provide your own configuration.

---

## 📄 License

This project is intended for **educational and non-commercial use only**.  
Final Fantasy XI and related trademarks belong to Square Enix.  
None of this content is intended to replace, emulate, or distribute official game assets.

