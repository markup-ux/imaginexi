------------------------------------
-- Pre RMT Drops
-- This module reverts RMT changes from a ToAU era Patch in 2007
------------------------------------
-- Source : http://www.playonline.com/pcd/update/ff11us/20070308c2bbd1/detail.html
------------------------------------
-- Implemented with plain UPDATEs (no DELIMITER / stored procedure) so dbtool/mysql SOURCE imports reliably.

DROP PROCEDURE IF EXISTS replace_drop;

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'cross-counters' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'FeiYin' LIMIT 1) AND `name` = 'Western_Shadow' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'retaliators' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'eurytos_bow' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'FeiYin' LIMIT 1) AND `name` = 'Eastern_Shadow' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'valis_bow' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'leaping_boots' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'South_Gustaberg' LIMIT 1) AND `name` = 'Leaping_Lizzy' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'bounding_boots' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'ochiudos_kote' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Castle_Oztroja' LIMIT 1) AND `name` = 'Mee_Deggi_the_Punisher' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'ochimusha_kote' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'fuma_kyahan' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Castle_Oztroja' LIMIT 1) AND `name` = 'Quu_Domi_the_Gallant' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'sarutobi_kyahan' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'kraken_club' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Labyrinth_of_Onzozo' LIMIT 1) AND `name` = 'Lord_of_Onzozo' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'octave_club' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'emperor_hairpin' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Valkurm_Dunes' LIMIT 1) AND `name` = 'Valkurm_Emperor' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'empress_hairpin' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'peacock_charm' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Maze_of_Shakhrami' LIMIT 1) AND `name` = 'Argus' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'peacock_amulet' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'speed_belt' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Jugner_Forest' LIMIT 1) AND `name` = 'King_Arthro' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'velocious_belt' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'healing_staff' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Sauromugue_Champaign' LIMIT 1) AND `name` = 'Roc' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'dryad_staff' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'strider_boots' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Rolanberry_Fields' LIMIT 1) AND `name` = 'Simurgh' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'trotter_boots' LIMIT 1);

UPDATE `mob_droplist` SET `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'archers_ring' LIMIT 1)
WHERE `dropId` = (SELECT `dropid` FROM `mob_groups` WHERE `zoneid` = (SELECT `zoneid` FROM `zone_settings` WHERE `name` = 'Ordelles_Caves' LIMIT 1) AND `name` = 'Stroper_Chyme' LIMIT 1)
AND `itemId` = (SELECT `itemid` FROM `item_basic` WHERE `name` = 'shikaree_ring' LIMIT 1);

-- Astral Ring (Coffer chests in Castle of Oztroja) handled in modules/era/lua/rmt_drops.lua

-- Define rate variables
SET @COMMON   = 150;  -- 15%
SET @UNCOMMON = 100;  -- 10%
SET @RARE     = 50;   -- 5%
SET @VRARE    = 10;   -- 1%

INSERT INTO `mob_droplist` VALUES (2588,0,0,1000,1313,@RARE); -- Sea Serpent Grotto - Voll the Sharkfinned - Siren's Hair (5%)
INSERT INTO `mob_droplist` VALUES (2813,0,0,1000,1313,@RARE); -- Sea Serpent Grotto - Zuug the Shoreleaper - Siren's Hair (5%)
INSERT INTO `mob_droplist` VALUES (1973,0,0,1000,1313,@RARE); -- Sea Serpent Grotto - Pahh the Gullcaller - Siren's Hair (5%)
INSERT INTO `mob_droplist` VALUES (2673,0,0,1000,1313,@RARE); -- Sea Serpent Grotto - Worr the Clawfisted - Siren's Hair (5%)
INSERT INTO `mob_droplist` VALUES (1825,0,0,1000,1313,@RARE); -- Sea Serpent Grotto - Novv the Whitehearted - Siren's Hair (5%)
INSERT INTO `mob_droplist` VALUES (128,0,0,1000,1312,@RARE);  -- Cape Terrigan - Devil Manta (Fished) - Angel Skin - (5%)
INSERT INTO `mob_droplist` VALUES (149,0,0,1000,836,@VRARE);  -- The Boyahda Tree - Aquarius - Damascene Cloth (1%)
