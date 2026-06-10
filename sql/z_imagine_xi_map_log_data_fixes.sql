-- Applied manually or via: mysql ... xidb < sql/z_imagine_xi_map_log_data_fixes.sql
-- Remove non-upstream npcid 17719990 placeholder if present (not in retail/LSB npc_list).
DELETE FROM `npc_list` WHERE `npcid` = 17719990;

-- Maat THF drop list 2917, Hellish Weapon 1294 (only if lists are still empty)
INSERT INTO `mob_droplist` (`dropId`,`dropType`,`groupId`,`groupRate`,`itemId`,`itemRate`)
SELECT 2917,2,0,1000,4181,0 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `mob_droplist` WHERE `dropId` = 2917 LIMIT 1);

INSERT INTO `mob_droplist` (`dropId`,`dropType`,`groupId`,`groupRate`,`itemId`,`itemRate`)
SELECT 1294,0,0,1000,4749,50 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `mob_droplist` WHERE `dropId` = 1294 LIMIT 1);
