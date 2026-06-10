-- Feature: RUN/GEO AF content
-- Scope:
--   - AF1: GM_Home scripts (imagine_geo_af1_npc.lua, imagine_run_af1_npc.lua)
--   - AF2: Dynamis droplist remaps (below)

-- Strip deprecated GEO/RUN AF face NPCs if a DB still has IMAGINE reuses on retail ids.
DELETE FROM `npc_list` WHERE `name` IN ('Sylvie_IMAGINE', 'Octavien_IMAGINE');

-- RUN/GEO AF restructuring (partial)
--
-- Item levels, weapon DMG/delay, and item_mods for AF pieces are merged into canonical dumps:
--   server/sql/item_equipment.sql, server/sql/item_weapon.sql, server/sql/item_mods.sql
-- (see tools/scripts/merge_run_geo_item_mods_into_dump.py).
--
-- This file only applies Dynamis AF2 droplist remaps for RUN/GEO artifact IDs.

-- ------------------------------------------------------------
-- Dynamis AF2 drops for RUN/GEO
-- ------------------------------------------------------------
DELETE FROM `mob_droplist` WHERE `itemId` IN
(26666, 26842, 27018, 27194, 27370, 26664, 26840, 27016, 27192, 27368);

INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 26666, itemRate FROM mob_droplist WHERE itemId = 15072;
INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 26842, itemRate FROM mob_droplist WHERE itemId = 15087;
INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 27018, itemRate FROM mob_droplist WHERE itemId = 15102;
INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 27194, itemRate FROM mob_droplist WHERE itemId = 15117;
INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 27370, itemRate FROM mob_droplist WHERE itemId = 15132;

INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 26664, itemRate FROM mob_droplist WHERE itemId = 15072;
INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 26840, itemRate FROM mob_droplist WHERE itemId = 15087;
INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 27016, itemRate FROM mob_droplist WHERE itemId = 15102;
INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 27192, itemRate FROM mob_droplist WHERE itemId = 15117;
INSERT INTO `mob_droplist`
SELECT dropId, dropType, groupId, groupRate, 27368, itemRate FROM mob_droplist WHERE itemId = 15132;
