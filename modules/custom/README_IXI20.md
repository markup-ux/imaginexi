# Imagine XI 2.0 feature modules

All 2.0 custom gameplay lives here. Core `src/` and `scripts/` are not modified.

## Loaded by `modules/init.txt`

Comment out the `custom/lua/ixi20_*`, `custom/cpp/*`, and `custom/sql/ixi20_*` lines to disable a feature. Then rebuild `xi_map` if you removed a C++ module.

| Module | What it does |
|---|---|
| `ixi20_all_jobs_at_start` | Unlocks WAR–RUN (no MON, no Soldier) |
| `ixi20_af_levels.sql` | Yinyang Robe + AF1 wear at 50; AF2 / Relic (+1/+2) wear at 60. Pair with the 109.DAT rebuild so the item window shows the new level next to All Jobs |
| `ixi20_haste_belts.sql` | Swift Belt (Sacrarium) and Velocious Belt (King Arthro): Haste +8%, Acc +8, Store TP +4; Velocious wear Lv.50. Native Examine text is `109.DAT` (`python tools/scripts/ixi20_patch_haste_belt_dats.py`); overlay text in `Windower/res/item_descriptions.lua` |
| `ixi20_af1_weapons.sql` | AF1 weapons stay Lv.40 with keep-worthy DMG/stats (armor AF1 stays 50). Native Examine text is `108.DAT` (`python tools/scripts/ixi20_patch_af1_weapon_dats.py`); overlay text in `Windower/res/item_descriptions.lua`. Apply after `ixi20_no_perpetuation.sql` |
| `ixi20_flatten_latents.sql` | Single-condition latents become always-on `item_mods`. Skips Poroggo Cassock +1 (Watersday), Chocobo Shirt, Bard AF draw/sheath, Clown's Subligar, penalty latents, KSNM panic DT earrings (Medicine / Sorcerer's / Fencer's / Slayer's / Minstrel's / Tracker's / Ronin), and mutex stacks (moon / weekday / weather / HP-band / food). Fenrir / Vampire / Serpentes / Louhi / Coven Hat keep both day and night. Inspect text: `Windower/res/item_descriptions.lua`. Regenerate with `python tools/scripts/ixi20_flatten_latents.py` |
| `ixi20_trusts` | Turns trust summoning on. Trusts do not reduce experience. All trust spells at level 1. Ability gates and spell tiers use the 37-cap curve. Trusts fill a party of 6, engage while the player is fighting, and weaponskill at 1000 TP. Empty kits and missing caster, healer, and ranger behavior are filled in. Pair with the SQL and `ixi20_trust_ws.cpp` |
| `ixi20_trust_ws.cpp` | Trust weaponskills that skillchain at Gravitation or higher open at 23 (retail 60 on the 37-cap curve). Trusts with an empty skill list get a job weaponskill kit at spawn. Rebuild `xi_map` |
| `ixi20_trust_level.cpp` | Trusts already out level up with the player. HP, stats, skills, traits, weapon damage, and spells are rebuilt for the new level. Rebuild `xi_map` |
| `ixi20_auto_learn_spells` | Grants eligible spells on login / level-up / job change. Native Available list needs the client DAT rebuild below |
| `ixi20_leftover_magic_menu` | Re-pulses Virus / Curse on login (and after those casts) so the native magic list keeps leftover unused IDs |
| `ixi20_corsair` | All Phantom Rolls learned from create/login (no dice). Quick Draw shots do not require or consume cards |
| `ixi20_corsair.sql` | All Phantom Rolls unlock at level 1 (apply after 37-cap remaps) |
| `ixi20_pixie_rescue` | On death, a spirit appears at the corpse, raises the player, and restores HP/MP (weakness stays; skipped if Reraise is up or a world HNM / Sky fight is in range via `ixi20_sky`) |
| `ixi20_pixie_rescue.cpp` | Same-tick raise-accept buffs + spirit cleanup on homepoint/zone |
| `ixi20_dropped_casket` | Discarded items become community caskets |
| `imagine_job_hooks.cpp` | Provoke on MNK/PLD/NIN/RUN + spell grant hook + first-job starter crate |
| `dropped_casket.cpp` | Intercepts dump packet 0x028 |
| `ixi20_gil_economy` | Gil/sparks become XP; shops cannot sell weapons/armor (fishing rods/bait stay); remaining NPC/guild stock is free to use; vendor-sell XP is dropped combat gear and elemental crystals/clusters (not shop goods or fishing tools); guild sell-back pays 0; DC+ gear loot (starter through 20, shop catalog after) + NM XP burst. Florist flowers (city flower quests, Rain Lily for Flagellant) are a separate DC+ drop |
| `ixi20_cosmetic_drops` | 10% cosmetic on EXP kills (including NMs); race + ownership weighted; deposited to wardrobe with a location message |
| `ixi20_cosmetic_drops.cpp` | Grants those cosmetics into Wardrobe 1-8. Rebuild `xi_map` |
| `ixi20_too_weak_loot` | Too Weak kills drop nothing (drop list, caskets, steal/mug). Shared loot stays if a nearby ally checks Easy Prey+. Death-gil XP is per-player |
| `ixi20_gil_economy.cpp` | Vendor sell of combat gear and crystals → XP; shop goods / fishing tools sell for 0; shop-buy gear block (not fishing tools); 0-gil `addShopItem`; wraps `addGil` / spark `addCurrency` |
| `ixi20_job_progression_37cap.sql` | Abilities, traits, and magic spells unlock by 37 (2hr/1hr at 1; generic SMN BP map). DRK also learns Blaze / Dread / Ice / Shock Spikes at 4 / 6 / 10 / 14 |
| `ixi20_smn_support_progression.sql` | SMN 1–20 support-first Blood Pacts (every avatar a regular BP at 1; Hastega at 4). Apply after 37-cap |
| `ixi20_extra_job_traits.sql` | Dual Wield V on WAR–RUN; TH3 on THF/BST/RNG/COR; caster Refresh/CM/Conserve/FC; RDM Shield Mastery at 1 |
| `ixi20_kick_attacks.sql` | Kick Attacks: 25% at 1 (/MNK and main Monk through 37), 50% at 38 (main Monk only). Apply after 37-cap. Restart `xi_map` |
| `ixi20_combat_skill_ranks.sql` | 1.0 live weapon / H2H / ranged / defensive skill ranks (native weapons A+; H2H/evasion/parry retail; shield A+ on tank/support jobs) |
| `ixi20_magic_skill_ranks.sql` | 1.0 live magic skill ranks (A+ on expanded caster jobs; ninjutsu A+ all jobs; songs A+ BRD; blue/GEO retail) |
| `ixi20_daily_mantra` | Login `/servmes` popup is one shared daily quote |
| `ixi20_infinite_ammo` | Combat ammo is not consumed (WS / JA / `removeAmmo`) |
| `ixi20_infinite_ammo.cpp` | Restores arrows / bullets / shuriken after auto-attack consume |
| `ixi20_player_hit` | Player melee / ranged / physical WS / JA / BLU always connect. Mobs and pets keep Acc/Eva. Shadows, Third Eye, parry, guard, block, Perfect Dodge unchanged. Ranged still misses past 25 yalms |
| `ixi20_ws_weather` | Elemental and hybrid weaponskills always take day / weather (helix rule, not the nuke 33% roll). Matching weather / day boosts; opposite reduces. Rates stay stock |
| `ixi20_blu_damage` | Blue Magic damage: skill-based physical attack, Acc-with-TP and Physical Potency Acc become attack, Cannonball DEF scales with attack mods, per-hit shadows, magical dSTAT inside D + skill D-cap floor + MDT/nuke wall, breath uses max HP, `BLUE_POWER` applied once |
| `ixi20_ninjutsu_damage` | NIN-main ninjutsu skill bonus remapped to 75-cap (Ni 63–276, San 114–276). Ichi, V/M/I, Futae, Innin gear, and `NINJUTSU_POWER` stay stock |
| `ixi20_drain_aspir` | Player Drain / Aspir return 20 / 30 / 40% of max HP and 25 / 35 / 50% of max MP. Drain is clamped to the target's remaining HP. Aspir always returns that MP even when the target has none; only MP removed from the target is limited to its pool. Mob casts use those % of the target's current pool. Resist, weather, absorb gear, and Nether Void still apply |
| `ixi20_blu_affinity` | Main and sub BLU: Chain Affinity, Burst Affinity, and Diffusion always on from level 1 (never expire; restored if a spell / zone / death / job change strips them). Pair with the SQL |
| `ixi20_blu_affinity.sql` | Chain Affinity 40 / Burst Affinity 25 (JA levels stay retail; effects are always-on). Apply after 37-cap remaps |
| `ixi20_job_change.cpp` | Traces mog-menu job change; official LSB packets; strips MON/SOL bits from 0x01B |
| `ixi20_permanent_warp` | Scroll of Instant Warp is not consumed on use |
| `ixi20_ja_windows` | Cascade 8 min +10 MATT (10% MAB). Accession / Manifestation toggles live in `ixi20_caster_kit`. Diffusion is always-on via `ixi20_blu_affinity` |
| `ixi20_ja_windows.sql` | Cascade 90s recast |
| `ixi20_caster_kit` | Magic does not open or close skillchains. Haste and Haste II become Accession AoE (same flag as Protect). Accession and Manifestation are toggles (press on / press off, not eaten by the next spell; drop on death / zone / job change). Accession has no MP/recast tax. Pair with the C++ module |
| `ixi20_caster_kit.cpp` | Magic opens a window, closes it when the properties chain (no 3s wait), and leaves a non-chain window up for magic bursts. Strips Accession tax, zeros Accession / Manifestation charge cost. Rebuild `xi_map` |
| `ixi20_caster_kit.sql` | Accession and Manifestation recastTime 0 (no Stratagem charge). Restart `xi_map` after apply |
| `ixi20_mana_wall` | Mana Wall is a toggle (until off / death / zone / job change); 3s recast when turning off |
| `ixi20_mana_wall.sql` | Mana Wall on-recast 180s |
| `ixi20_public_zoneip.sql` | Sets `zone_settings.zoneip` to the public IPv4 so remote clients can zone |
| `ixi20_hybrid_wyvern` | DRG wyvern is always hybrid DD + party support (status/heal + elemental breath); not dual-pet. Idle at 0 HP (stays at 1, sit pose like /sit), combat again when healed above 1 |
| `ixi20_gm_home_test_mobs` | GM Home (zone 210, `!gmhome`): Wyvern Dummy south of spawn. No aggro; click it to fight. Prefers the wyvern |
| `ixi20_pet_helpful_magic.cpp` | Cure / Protect / other helpful magic can target wyverns and other player pets. Rebuild `xi_map` |
| `ixi20_pet_helpful_magic` | Cure actually heals those pets (`isValidHealTarget` includes PET). Pair with the C++ targeting patch |
| `ixi20_gm_home_test_hub` | GM Home: Nomad Moogle (job change), Test Vendor (buy/sell → XP), XP Hare camp northeast (lv1 / 1 HP, ~1 level per kill) |
| `ixi20_godmode_persist` | Re-applies `!godmode` / `!immortal` after death+raise, and after mob Dispel / overwrite of Regen-Refresh-HP Boost. Those four are YAML-dispelable; Invincible is not. Pixie rescue must not replace Invincible with a 15s copy |
| `ixi20_godmode_ja` | Job ability recasts are 0 while `!godmode` is on (full and tier 1). Turning it on clears every ability timer already running, same wipe as `!reset`. Login and zone do that again. Ability animation lock stays. Blood Pact timers stay in `ixi20_no_bp_timers` |
| `ixi20_subjob_wyvern` | Subjob DRG can Call Wyvern (Dismiss / Spirit Link too). Pair with the C++ module so spawn is not main-DRG-only |
| `ixi20_subjob_wyvern.cpp` | Allows wyvern spawn when DRG is the subjob. Rebuild `xi_map` |
| `ixi20_sp_uptime` | 2-hour and 1-hour timed SPs last 2 minutes. Instants unchanged. Pixie rescue Invincible stays 15s |
| `ixi20_long_stances` | NIN Yonin/Innin/Futae/Issekigan, SAM Hasso/Seigan/Warding Circle, DRG Ancient Circle last 1 hour |
| `ixi20_travel_unlocks` | Crag crystals + both airship passes on create/login; all mount companion KIs at main level 10 |
| `ixi20_planar_rifts` | Planar rifts are visible to every player. Login / zone grants a clear abyssite if the character has none. Examining a rift opens travel to every other rift (zone, then map square). Pair with the C++ module |
| `ixi20_planar_rifts.cpp` | Keeps the Planar Rift swirl when a player walks up to it. Rebuild `xi_map` |
| `ixi20_ethereal_junctions` | Examining an Ethereal Junction pops the Unity notorious monster placed there. No accolades, no Records of Eminence objective. The mob is non-exclusive so any player can fight it. A junction with two notorious monsters asks which one. Pair with the C++ module |
| `ixi20_ethereal_junctions.cpp` | Keeps the Ethereal Junction mesh when a player walks up to it, and marks it triggerable. Rebuild `xi_map` |
| `ixi20_salvage_access` | Alzadaal Gilded Gateways open Salvage for every player (solo, party, or alliance). No level 65, Remnants Permit, or imbued-item block. Gear still locks for the 100-minute run |
| `ixi20_homepoint_heal` | Home Point crystals restore HP/MP before the warp menu |
| `ixi20_safe_outposts` | Moves 1.0 outpost-adjacent goblins/tonberries off the camp (Valkurm, Buburimu, Teriggan, Altepa, Yuhtunga, Yhoator) |
| `ixi20_starter_elementals` | Low-level elementals in West Ronfaure / North Gustaberg / East Sarutabaruta. Pair with the SQL groups |
| `ixi20_starter_elementals.sql` | Same-zone elemental pools/groups 38–45 (not Beaucedine 38). Apply after import |
| `ixi20_mb_spirit` | A player magic burst pops an elemental spirit of that element on the mob. The spirit only casts that element's spirit spells the caster's main or sub job can use at their current level. It despawns when that mob dies. One spirit of each element can be up in a zone at a time. Uses the starter elemental groups |
| `ixi20_garlaige_exp` | Garlaige Citadel [S] XP camps: hallway packs (Dire Bats and Incubus Bats H-8 62–64, Mousse G-6 64–67, Explosures F-9 64–65, Scolopendrids H-7 68–70) and a pack inside each storeroom (Dire Bats G-9, Scolopendrids H-9, Mousse I-8 and G-9, Explosures G-7 and J-6). Storeroom packs do not link. Respawn 3 minutes. `!exp` counts them. Pair with the SQL |
| `ixi20_garlaige_exp.sql` | Pools 9101–9105 and zone 164 groups 210–214 for those camps. Apply after import |
| `ixi20_mount_dig` | `!dig` on any mount; no Gysahl Greens. Pair with the C++ module |
| `ixi20_mount_dig.cpp` | Native chocobo-dig action on any mount, greens not required or consumed. Rebuild `xi_map` |
| `ixi20_instant_reengage.cpp` | No “wait longer” lockout when re-engaging after disengage. Rebuild `xi_map` |
| `ixi20_disable_anon.cpp` | `/anon` does nothing; leftover anon is cleared on zone-in. Rebuild `xi_map` |
| `ixi20_check_level.cpp` | Impossible-to-gauge `/check` sends the mob level in the gray check sentence. Normal checks already send it. The sentence itself is `ROM/27/72.DAT` (`python tools/scripts/ixi20_patch_check_level_dat.py`). Rebuild `xi_map` for notorious monsters |
| `ixi20_cavernous_maws` | All WotG Cavernous Maws usable from create/login (Pure White Feather + all past-maw bits). Pair with the C++ module so the model is visible to every player |
| `ixi20_cavernous_maws.cpp` | Keeps field Cavernous Maw namevis at 96 (that value is the portal) and marks them triggerable. Cutscene copies stay hidden. Rebuild `xi_map` |
| `ixi20_mission_chronicle` | Missions do not gate the world. Create/login grants Sea / Dynamis / Assault / Salvage / Abyssea / Adoulin / sky access. Chronicler NPC (Lower Jeuno, Whitegate, Western Adoulin, GM Home) or `!chronicle`: play a chapter, skip to its next battle, or close it. Toggle: `main.IMAGINEXI_STORY_OPEN_WORLD`. Pair with `FREE_COP_DYNAMIS = 1` |
| `ixi20_chocobo_masque` | Chocobo Masque +1 warps to the home-nation telepoint chocogirl with no 20h recast. Pair with the C++ module |
| `ixi20_overlay_hair` | Overlay hairstyle sync (`!ixihair`). Stores a cosmetic id only; does not change `char_look`. Hidden channel-9 whisper so other overlay users can fake the same hair. People without the overlay see the real style |
| `ixi20_sch_charges` | SCH Arts + all stratagems at level 1, full charge pool. Pair with the SQL and C++ |
| `ixi20_sch_charges.sql` | Light/Dark Arts, Addenda, and every stratagem at 1; 5×48s charges |
| `ixi20_sch_charges.cpp` | Forces GetCharge to 5×48s and stamps the live recast on login. Rebuild `xi_map` |
| `ixi20_sch_arts.cpp` | SCH Light or Dark Arts (or either Addendum) unlocks both light and dark stratagems. Rebuild `xi_map` |
| `ixi20_sch_both_schools` | SCH Light/Dark Arts no longer tax the other school (+20% cost/cast/recast removed). Matching-school -10% stays. Pair with the C++ module |
| `ixi20_sch_both_schools.cpp` | Addendum White/Black spell requirements stripped so Cure IV / Stoneskin / etc. work on either stance. Rebuild `xi_map` |
| `ixi20_sch_arts_skill` | Light / Dark Arts grant +15 skill to the matching schools (Enfeebling on both). Replaces the old D→B+ lift that A+ ranks zeroed out |
| `ixi20_sch_stratagem_refund` | Manifestation enfeebles on 3+ enemies, or Accession -na/Erase/Esuna/Sacrifice on 3+ allies, refund one Stratagem charge. Pair with the C++ module |
| `ixi20_sch_stratagem_refund.cpp` | Lua helpers to count action hits and refund one Stratagem charge. Rebuild `xi_map` |
| `ixi20_thf` | Flee and Hide buff the nearby party (14 yalms, trusts included). Main or sub THF: each melee / weaponskill critical reduces every job-ability recast by 1s except Sneak Attack. Pair with the C++ module |
| `ixi20_thf.cpp` | `Ixi20ReduceAbilityRecasts` so THF crits can shave remaining JA timers (skips Sneak Attack recast 64). Rebuild `xi_map` |
| `ixi20_sa_window` | Main THF: Sneak Attack is a 30s window — every qualifying first swing / weaponskill / physical BLU (behind, Hide, or Doubt). Not consumed on hit. Recast 90s. Sub THF stays retail consume-on-hit. Trick Attack unchanged. Pair with the SQL |
| `ixi20_sa_window.sql` | Sneak Attack recast 90s. Apply after 37-cap remaps. Restart `xi_map` |
| `ixi20_cover.cpp` | Cover intercepts without facing / in-line / in-front. Party, alive, and Cover buff stay. Leash is the JA range (16 yalms + hitboxes) to the Covered player so a distant pull cannot dump onto the Paladin. Rebuild `xi_map` |
| `ixi20_dnc` | Chocobo Jig and Chocobo Jig II use Flee speed and buff the nearby party (14 yalms, trusts included). Spectral Jig also hits the party; existing sneak / invis (spell, oil, powder, Hide, Camouflage) is kept when its remaining time is longer than the jig |
| `ixi20_chakra` | Chakra clears combat debuffs (erasable, waltzable, sleep, doom, petrify, charm, amnesia, terror, helix, geo downs, and the other hard statuses). HP heal is twice the official VIT / level / gear / job-point amount, and MP restores that same amount. Weakness and encumbrance stay. Invigorate is unchanged |
| `ixi20_weakness` | Weakness lasts 30 seconds |
| `ixi20_no_exp_loss.cpp` | Death does not cost experience or delevel. Raise does not refund experience that was never lost. GM `!takexp` still removes experience. Rebuild `xi_map` |
| `ixi20_imagine_linkshell` | Every player gets a pearl for the server linkshell Imagine (forest green with a hint of navy) on create/login. Pair with the C++ module that creates the LS |
| `ixi20_roe` | All implemented RoE records count with no 30-slot cap; First Step Forward completes on login; objective chat is silent. Pair with the C++ module. Rebuild `xi_map` |
| `ixi20_death_repop` | Mobs that despawn without dying (wipe / leash) respawn at their default spawn in 1s. Pair with the C++ module. Rebuild `xi_map` |
| `ixi20_sublimation_stack` | Sublimation stacks with Refresh (all tiers). Load after `ixi20_refresh_stack` |
| `ixi20_mob_drop_sell` | Any NPC-sellable item (mob drops, junk, seals, gear) sells for XP; fishing tools stay 0. Server also appraises NoSale drops. Native DAT may still grey NoSale in the shop list. `ixi20_gil_economy.cpp` prefers `Ixi20GrantsVendorSellExp` when this is loaded |
| `ixi20_city_mounts` | Mounts usable in the same main cities 1.0 enabled (nations, Jeuno, Aht Urhgan, Adoulin, towns). Pair with the C++ module |
| `ixi20_teleport_no_visit` | Teleport items do not require a prior visit. Tidal Talisman also works from the field (unlisted zones go to Ru'Lude Gardens) |
| `ixi20_retrace` | Retrace (and Instant Retrace) cast without Campaign allegiance. Destination is the target's home nation [S] city |
| `ixi20_no_gil_fees` | Homepoints, survival guides, outposts, explorer moogle, airships, chocobos, maps, Sagheera Cosmo-Cleanse (Limbus), and other gil usage fees are free (gil is XP) |
| `ixi20_no_gil_fees.cpp` | `getGil` afford-checks pass and `delGil` does not take gil. Rebuild `xi_map` |
| `ixi20_ah_gifts.cpp` | Auction House is a 0-gil gift locker (no list fee, no buy cost, no seller payout). Catalog is only items players currently have listed. Removes free stock rows. Writes `Windower/addons/imaginexi_overlay/data/ah_board.json` for the overlay (no world HTTP / `src/` edits). Shows the native AH menu path (Weapons > Sword). Rebuild `xi_map` |
| `ixi20_ah_gifts.sql` | Replaces `auction_house_buy` so sellers are not mailed gil; removes free stock; catalog is open player listings only |
| `ixi20_max_storage` | 80-slot inventory + all mog storage (Safe / Safe 2 / Storage / Locker / Satchel / Sack / Case / Wardrobes); locker is all-areas with no expiry; Mog House 2F unlocked |
| `ixi20_cp_exchange` | Conquest/signet guards offer Exchange alongside Conquest; sparks are spend-only; Get XP pays at the spark scale; gil cannot be a payout target while it converts to XP. Guard item buys and EXP-ring recharges cost 0 CP. Nation rank requirements stay |
| `ixi20_signet` | Signet is always on (create / login / zone). Never expires. Restored if a guard, staff, or another influence buff strips it. Crystals / CP / latents stay conquest-region |
| `ixi20_dedication` | Dedication is always on (create / login / zone): +150% EXP, no bonus cap. Never expires. Restored if stripped. Abyssea skip stays stock |
| `ixi20_conquest_fame` | Beastmen XP-kills grant home-nation fame for the conquest region (not current owner). Rank-up chat. `!fame` lists all areas. Toggle: `main.IMAGINEXI_CONQUEST_FAME` |
| `ixi20_exp_camps` | `!exp` lists outdoor and dungeon zones with placed normal mobs near that level (4 under to 3 over), including quieter camps. Header shows current job/sub and party size. Lines include the retail map square (I-7) for those mobs. `!exp <level>` looks up 1 through `main.MAX_LEVEL`. Garlaige Citadel [S] module camps from `ixi20_garlaige_exp` are counted too. Regenerate with `python tools/scripts/ixi20_exp_camps.py` after mob yaml changes |
| `ixi20_promy_exp` | Promyvion Holla / Dem / Mea / Vahzl empties grant normal combat XP. Clears the Stray `exp_bonus -100` stamp (Holla, Dem, Mea) so those pops use the same level-difference formula. Too Weak still pays nothing. Spire battlefields stay unchanged |
| `ixi20_exp_gap` | Combat XP no longer flattens at Incredibly Tough. The +1 to +15 level-gap rows pay their table value (the 400/500/600 per-kill clamp is lifted). Each level past +15 adds 15% of that +15 payout, up to 5x. Even match and below stay on the stock table. Dedication still applies after. Settings: `main.IMAGINEXI_EXP_GAP_ENABLED`, `main.IMAGINEXI_EXP_GAP_STEP`, `main.IMAGINEXI_EXP_GAP_MAX_MULT`. Load after `ixi20_promy_exp` |
| `ixi20_beastmen_cp_is` | XP-credited beastmen always grant conquest points and the same amount of Imperial Standing, including outside conquest regions. Both amounts are printed next to the XP line. In-region Signet CP is not doubled. Toggle: `main.IMAGINEXI_BEASTMEN_CP_IS` |
| `ixi20_nation_liveries` | Royal Guard / Mythril Musketeer / Patriarch Protector liveries: Campaign army control (past) plus present 75-era conquest / nation cities. Future Campaign scripts can set `xi.campaign.getZoneControl` or zone local `campaignNation`. Inspect text: `Windower/res/item_descriptions.lua` |
| `ixi20_share_xp` | Half of gained XP goes to the current subjob (stored job level capped at 37). Per-kill subjob XP chat is omitted so FoV 2/3 regime reports are not overwritten |
| `ixi20_level_tp` | Main-job level-up: instant 3000 TP + Regain power 20 (200 TP / 3s, Meditate rate) for 2 minutes. Skips Weakness (raise) and does not replace `!godmode` Regain |
| `ixi20_capped_skills.cpp` | Combat/magic/defensive skills persist at stored main+sub caps (`char_skills`); crafts/fishing/RID/DIG unchanged. Toggle: `main.IMAGINEXI_ALWAYS_CAP_COMBAT_MAGIC_SKILLS` |
| `ixi20_level_sync` | Party Level Sync matches the designee’s stored main job (up or down, `main.MAX_LEVEL` cap) |
| `ixi20_level_sync.cpp` | Raises effective level / rebuilds kit when LSB would only sync down; combat/magic skills treated as capped while synced |
| `ixi20_gear_sync_scaling.cpp` | Keeps the set on when syncing down and scales haste / DEF / ATT / other gear stats to the synced level |
| `ixi20_refresh_regen` | Every player’s Regen tick equals Refresh from traits / gear / food. Spell Refresh is MP only |
| `ixi20_refresh_stack` | Refresh I and II add on one effect (cap 9, Refresh III equivalent). Same tier recasts duration only |
| `ixi20_enhancing_persist` | Enhancing magic, BRD songs, and COR rolls last until death / job change if self-cast (survive zoning). Party-cast kit lasts until zone / death / job change and drops if the caster leaves that party or changes main job. Blink, Embrava, Foil, bust, and enfeeb songs stay timed |
| `ixi20_persist_party.cpp` | Fires persist audit after party list updates and main-job change. Rebuild `xi_map` |
| `ixi20_prowess` | Grounds Tome prowess types already stack; each kind lasts 3 real days and survives zone / logout / death |
| `ixi20_regime_support` | Field Manual / Grounds Tome support (buffs, food, book warps) is free. Tabs stay XP |
| `ixi20_regime_auto` | Book pages in the current zone are all active and repeating on zone-in / login. No book visit to start |
| `ixi20_all_maps` | Every `MAP_OF_*` key item on create / login |
| `ixi20_survival_guides` | Every Survival Guide unlocked on create / login. Warps stay free via `ixi20_no_gil_fees` |
| `ixi20_whm_bar_enspell` | Main-job WHM Bar-element (Barfire / Barfira and the other five) also grants that element's En-spell to everyone hit, with a chat confirmation |
| `ixi20_endark_ii` | Endark II spell script (LSB ships none). Same Endark status and decay; tier II dark-skill potency |
| `ixi20_meteor` | BLM and SCH learn Meteor at 37. Casts without Elemental Seal. 10-yalm AoE. Overlapping party casts fire once from the last caster; earlier casters add damage (last counts most, up to 6.5x). One party per alliance. A monster resists the next Meteor, fading over 5 minutes. Overlay and `/ma "Meteor"` cast it; the native magic menu still wants Elemental Seal |
| `ixi20_no_perpetuation` | Avatar / spirit MP perpetuation is 0 (1.0 `PerpetuationCost` return 0). Gear with Avatar perpetuation cost or half-perp becomes Summoning skill, or pet MACC if the piece already has summoning |
| `ixi20_no_perpetuation.cpp` | Zeros `AVATAR_PERPETUATION` on zone-in and zone tick (covers level-restriction recalcs). Rebuild `xi_map` |
| `ixi20_no_perpetuation.sql` | Remaps `item_mods` / pet / latents / augment 321; apply after import |
| `ixi20_no_bp_timers` | Blood Pact Rage/Ward recast is 0 (1.0 SMN timer removal). Recast IDs 173/174 stay so they do not collide with 2-hour |
| `ixi20_no_bp_timers.sql` | Zeros SMN BP `recastTime`; BP delay gear becomes pet MACC (993) or pet MAB (992). Restart `xi_map` after apply |

Overlay / Windower inspect text for those remaps lives in `Windower/res/item_descriptions.lua` (script `tools/scripts/ixi20_rewrite_smn_item_descriptions.py`) and `Windower/addons/imaginexi_overlay/item_desc_ixi20.lua`. Native FFXI Examine still uses ROM DATs. Reload the overlay after a res copy. Augment labels: `Windower/addons/libs/extdata.lua` (`0x140` / `0x141` / `0x75` / `0x76`).
| `ixi20_debuff_stack` | Dia and Bio coexist. Different source families of Poison / Slow / Paralyze / Blind stack (magic, ninjutsu, ammo, melee AE, each weaponskill). All six elemental DoTs stack. Helixes stack by element. Same family still overwrites. Rebuild `xi_map` |
| `ixi20_debuff_stack.cpp` | Patches in-memory overwrite / Dia-Bio / elemental-DoT rules so those families can coexist. Rebuild `xi_map` |
| `ixi20_bind_kite` | Bind holds through a few hits for kiting (20% / 40% / 65% / 90% per damaging instance). Duration still ends it. DoTs do not count. Pair with the C++ module |
| `ixi20_bind_kite.cpp` | Hooks Bind break / Bind removal so the ramp applies to melee and nukes. Script `delStatusEffect` still strips Bind. Rebuild `xi_map` |
| `ixi20_starter_hnm` | Lowbie HNMs in the six nation fields. Shared XP pool (~100k) pops the fight. Helpers keep their level and can swing without joining; damage is figured at the other side's level (`ixi20_starter_hnm_scale.cpp`). Claim and loot stay at stored main 12 or under. 45 min cooldown. GMs: `!starterhnm` |
| `ixi20_starter_hnm.sql` | Dynamic mob_groups 36/37 for those field pops (LSB YAML left `mob_groups` empty there) |
| `ixi20_hnm_packages` | All NMs reject Sleep / Sleep II / Lullaby. Dynamis Lord takes no damage while stunned. Incoming WS grants TP + Fast Cast stacks. World HNMs (roster, including Kirin garden-god adds) can fire the 1.0 apex skill pool. Settings: `map.WS_REACTION_*`, `map.HNM_APEX_SKILL_POOL_ENABLED` |
| `ixi20_hnm_access` | Land kings / sky / Kirin stay on ??? pops (items from KSNMs / sky / seals). Timed world HNMs respawn in 20 min. Alliance lockout 12h after a kill (garden gods 3h via `ixi20_sky`). Settings: `map.IMAGINEXI_HNM_LOCKOUT_SECONDS`, `map.IMAGINEXI_HNM_TIMED_RESPAWN_SECONDS` |
| `ixi20_dragons_aery_pop` | Dragon's Aery ??? click (or trade, no item) pops Fafnir or Nidhogg at random. Alliance lockout from `ixi20_hnm_access` still applies |
| `ixi20_hnm_claim` | 10s unclaimable lottery, one ticket per alliance, 90s idle drop. Locked-out alliances do not get a ticket. Settings: `map.IMAGINEXI_HNM_CLAIM_SHIELD_MS`, `map.IMAGINEXI_HNM_CLAIM_IDLE_SECONDS` |
| `ixi20_hnm_difficulty` | World-HNM 3x HP / 2x stats, anti-melt hit caps, healer pulses / doom. Skips Kirin adds. Settings: `map.IMAGINEXI_HNM_HP_MULTIPLIER`, `map.IMAGINEXI_HNM_STAT_MULTIPLIER`, `map.IMAGINEXI_HNM_STORE_TP` |
| `ixi20_sky` | Ru'Aun gods + Kirin: 1.75x / 2x HP, full healer pressure, 3h god lockout, no pixie, per-god mechanics, native apex lists. Kirin summons the garden gods (stats, skill lists, full drop tables), not empty pets. Settings: `map.IMAGINEXI_SKY_*`, `map.IMAGINEXI_KIRIN_*`, `map.IMAGINEXI_HNM_BLOCK_PIXIE` |
| `ixi20_sky_gmhome` | GM Home Sky bench. `!skytest` or Sky Tester NPC (south of spawn): pop a garden god, a 2% HP loot check, or Kirin that summons adds. Test kills do not lock Ru'Aun |
| `ixi20_nm_restart_spawn` | Timed, lottery, and item-pop HNMs spawn when the map process starts (King Behemoth, Nidhogg, Aspidochelone, and Kirin stay down). Idle despawn is cleared so they remain until the kill. Dynamis / instances / Abyssea / GM Home are skipped |
| `ixi20_nm_spawn` | GM `!spawnnms` populates all loaded-zone HNM/NMs (including ???). `!spawnnms zone` is the current zone only |
| `ixi20_bis` | GM `!bis` grants and equips current-job BiS for the player's level (from `ixi20_bis_gear_progression`). `!bis list` previews. Optional player name. |
| `ixi20_hnm_packages.cpp` | Attaches the Lua package to every zone mob on the first zone tick. Rebuild `xi_map` |
| `ixi20_share_xp.cpp` | Applies the subjob half (combat / `addExp` / gil-to-XP) and handles subjob level-up |
| `ixi20_mount_level.cpp` | `/mount` works at main level 10 (stock LSB is 20); cities allowed when `ixi20_city_mounts` is loaded |
| `ixi20_city_mounts.cpp` | `/mount` in main cities; stay mounted when zoning in; rental chocobos may enter. Rebuild `xi_map` |
| `ixi20_ninja_tools.cpp` | Ninjutsu does not require or consume inventory tools |
| `ixi20_craft_always_succeed.cpp` | Valid synth/desynth recipes never break; any skill can attempt them; HQ and skill-ups stay retail |

Helpers (required by the Lua module, not listed in `init.txt`): `ixi20_economy.lua`, `ixi20_gear_loot.lua`, `ixi20_shop_gear.lua`. `ixi20_bis_gear_progression.lua` is the BiS reference lists used by `!bis` (not auto-drop).

Auto-drop (`IMAGINEXI_GEAR_LOOT_*`) rolls on **Decent Challenge or tougher** kills in any zone. Main 1–20 uses starter / tunic / pantheon pools by player level. After 20, nation-shop weapons and armor drop in a 10-level window of the player. Weapons are the job’s A+ combat skills; armor still uses original shop job flags. NMs still give an XP burst instead of this gear roll. No Perdu, AF, relic, sky, or HNM pieces. First time you play a job, a one-time starter crate is granted (inventory space required). Cosmetic kill-drops (`IMAGINEXI_COSMETIC_DROP_*`) are a separate 10% roll on EXP-eligible kills at any level, including NMs. The piece goes into the recipient's wardrobe (inventory if every wardrobe is full) and chat says which bag. Too Weak (`IMAGINEXI_TOO_WEAK_NO_LOOT`) blanks the normal drop list, brown caskets, steal, mug, and death-gil XP. A nearby alliance member who checks Easy Prey or better keeps shared drops (quest help / Level Sync). Script `addTreasure` calls are unchanged.

## Revert

1. Comment the `ixi20` / `dropped_casket` / `imagine_job_hooks` lines in `modules/init.txt`.
2. Apply `sql/ixi20_REVERT.sql` to `xidb_ixi20` only (restores equipment job masks and AF/Yinyang wear levels, AF1 weapon DMG/mods, ability/trait/spell levels including COR rolls and SMN 1–20 support pacts, skill ranks, Cascade / Mana Wall / Sneak Attack recasts, drops casket tables, removes pixie, starter-HNM, starter-elemental, and Garlaige Citadel [S] camp groups, restores perpetuation and Blood Pact delay gear / BP recasts).
3. Restore settings in `settings/main.lua` / `settings/map.lua` / `settings/search.lua` if you changed them (`START_GIL`, `IMAGINEXI_*`, `IMAGINEXI_COSMETIC_DROP_*`, `IMAGINEXI_CONQUEST_FAME`, `IMAGINEXI_BEASTMEN_CP_IS`, `IMAGINEXI_ALWAYS_CAP_COMBAT_MAGIC_SKILLS`, `IMAGINEXI_STORY_OPEN_WORLD`, `FREE_COP_DYNAMIS`, `MOB_GIL_MULTIPLIER`, `DISABLE_AMMO_CONSUMPTION`, `SKILLUP_AMOUNT_MULTIPLIER`, `CRAFT_CHANCE_MULTIPLIER`, `AH_BASE_FEE_*`, `AH_TAX_RATE_*`, `AH_MAX_FEE`, `OMIT_NO_HISTORY`). Homepoint / airship / other gil usage fees return if you comment `ixi20_no_gil_fees`. Gift AH returns to a gil market if you comment `ixi20_ah_gifts`.
4. Reconfigure + rebuild `xi_map`.

Do not apply these SQL files to the Imagine XI 1.0 `xidb`.

## Client magic menu (`114.DAT`)

`ixi20_auto_learn_spells` + `imagine_job_hooks.cpp` teach remapped spells. The stock **Available** list still filters by levels in `ROM/118/114.DAT`. XIPivot cannot fix this file (it loads after FFXiMain already read it). Unused retail leftovers (Virus, Curse) also need their own animation `id` in that DAT (256 / 257) and a listed spell's post-icon tail (Blind / Drain). Stock `id: 0` plus the unused tail makes the client drop the row after one cast. `ixi20_leftover_magic_menu` re-pulses the learn packet so the native list appends them again.

Players get the DAT when the launcher starts, or when they **Play** / **Install / Update**. It downloads changed `ClientContentPackages` from the `ixi20` GitHub release (not a full launcher zip), copies `114.DAT` into their FFXI folder, and keeps `114.DAT.ixi20-retail.bak` beside it. Program Files installs show one Administrator prompt. Host push: `tools\scripts\pack_ixi20_client_content.ps1 -Upload`.

Host rebuild armor wear levels (after changing `ixi20_af_levels.sql` IDs):

```
python tools\scripts\ixi20_patch_af_armor_levels.py
```

Host rebuild haste-belt Examine text:

```
python tools\scripts\ixi20_patch_haste_belt_dats.py
```

Host rebuild AF1 weapon Examine text / DMG / Lv.40 (after changing `ixi20_af1_weapons.sql`):

```
python tools\scripts\ixi20_patch_af1_weapon_dats.py
```

Then `tools\scripts\pack_ixi20_client_content.ps1 -Upload` if remote clients need the new `108.DAT` / `109.DAT`. Fully quit FFXI after the DAT changes.

Host rebuild (after changing `ixi20_job_progression_37cap.sql`):

```
python tools\scripts\ixi20_sync_menu_spell_levels.py
powershell -ExecutionPolicy Bypass -File tools\scripts\deploy_ixi20_spell_menu_114.ps1
```

Then `tools\scripts\pack_ixi20_client_content.ps1 -Upload`. Players pick it up on the next launcher start. Fully quit FFXI after the DAT changes. PlayOnline is shared with 1.0.

## Client (retail FFXiMain)

Soldier client patches are retired. The shared PlayOnline `FFXiMain.dll` is stock retail (job-list loop at 22, no SOL string):

`C:\Program Files (x86)\PlayOnline\SquareEnix\FINAL FANTASY XI\FFXiMain.dll`

Start 2.0 from `D:\ImagineXI20\Windower\Windower.exe` or `Launch Imagine XI 2.0.cmd`. If the DLL is ever re-patched, run `tools\scripts\install_retail_ffximain.ps1` as Administrator.

Party-list HP/MP color is vanilla. The Imagine XI Overlay HUD is `Windower/addons/imaginexi_overlay` (autoload). `//ixo help` for panels, gear sets, and menus. Dual Wield on stock retail `FFXiMain` still uses the overlay's client-side sub-weapon inject.

## Crash diagnosis

### Map server (`xi_map`)

Tombstones are always written on a Windows SEH crash (`server/dmp/tombstone_<pid>_<time>.log`). The watchdog copies a readable summary to `server/log/map_crashes/map_crash_latest.txt` whenever `xi_map` dies. Minidumps (`*.dmp`) require `GENERATE_CORE_DUMP = true` in `server/settings/main.lua`.

```
powershell -ExecutionPolicy Bypass -File "D:\Imagine XI 2.0\tools\scripts\diagnose_map_crash.ps1"
```

Or double-click `Diagnose-Map-Crash.bat` in the repo root. Look at **Crash site** first; `GetMobByID Mob doesn't exist` lines in the log are warnings, not the crash.

| Output | Path |
|---|---|
| Latest map crash report | `server/log/map_crashes/map_crash_latest.txt` |
| Tombstone (stack + breadcrumbs) | `server/dmp/tombstone_*.log` |
| Minidump | `server/dmp/tombstone_*.dmp` |
| Watchdog log | `server/log/watchdog.log` |

### Client

After a client crash:

```
powershell -ExecutionPolicy Bypass -File "D:\Imagine XI 2.0\tools\scripts\ixi20_crash.ps1" -RunDiagnose
```

Setup (once): `-RunSetup` deploys `Windower/addons/crash_watch`, autoloads it from `init.txt`, and starts `watch_ixi20_crashes.ps1`. Restart Windower from `D:\ImagineXI20\Windower\Windower.exe`, then `//cw status`.

| Output | Path |
|---|---|
| Diagnosis report | `server/log/crash_diagnosis/latest_diagnosis.txt` |
| Watcher log | `server/log/client_crash_watch.log` |
| Job-change packet dump | `server/log/crash_sessions/jobchange_latest.txt` |
| Client packet blackbox | `Windower/logs/crash_watch_latest.log` |
