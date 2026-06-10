-- Feature: Imagine XI — SMN half-perpetuation cleanup, perpetuation latents, augments, pet enmity, enmity-loss rows
-- Run after `z_imagine_xi_80_item_rebalance.sql` (numeric order: 80 → 81 → 82).

-- ----------------------------------------------------------------
-- item_mods: remove dead half-perpetuation / Carby mods (perpetuation MP is disabled server-side)
-- ----------------------------------------------------------------
DELETE FROM `item_mods` WHERE `itemId` = 11118 AND `modId` IN (1170,1171);
DELETE FROM `item_mods` WHERE `itemId` = 11218 AND `modId` = 1170;
DELETE FROM `item_mods` WHERE `itemId` = 14062 AND `modId` = 356;
DELETE FROM `item_mods` WHERE `itemId` = 23233 AND `modId` IN (1170,1171);
DELETE FROM `item_mods` WHERE `itemId` IN (27080,27081) AND `modId` IN (1170,1171);
DELETE FROM `item_mods` WHERE `itemId` IN (27106,27107) AND `modId` = 356;

INSERT INTO `item_mods` VALUES (11118,117,6);   -- ImagineXI: was half perpetuation day/weather
INSERT INTO `item_mods` VALUES (11118,993,5);
INSERT INTO `item_mods` VALUES (11218,117,5);
INSERT INTO `item_mods` VALUES (11218,993,4);
INSERT INTO `item_mods` VALUES (14062,117,4);
INSERT INTO `item_mods` VALUES (14062,993,3);
INSERT INTO `item_mods` VALUES (23233,117,8);
INSERT INTO `item_mods` VALUES (23233,993,6);
INSERT INTO `item_mods` VALUES (27080,117,5);
INSERT INTO `item_mods` VALUES (27080,993,4);
INSERT INTO `item_mods` VALUES (27081,117,5);
INSERT INTO `item_mods` VALUES (27081,993,4);
INSERT INTO `item_mods` VALUES (27106,117,3);
INSERT INTO `item_mods` VALUES (27106,993,2);
INSERT INTO `item_mods` VALUES (27107,117,4);
INSERT INTO `item_mods` VALUES (27107,993,3);

-- ----------------------------------------------------------------
-- augments: BP delay / perpetuation augments → SMN-usable stats (PK includes modId — replace row)
-- ----------------------------------------------------------------
DELETE FROM `augments` WHERE `augmentId` = 320 AND `multiplier` = 0 AND `modId` = 357 AND `isPet` = 0 AND `petType` = 0;
INSERT INTO `augments` VALUES (320,0,993,2,0,0); -- ImagineXI: was Blood Pact ability delay; now pet MACC/MEVA
DELETE FROM `augments` WHERE `augmentId` = 321 AND `multiplier` = 0 AND `modId` = 346 AND `isPet` = 0 AND `petType` = 0;
INSERT INTO `augments` VALUES (321,0,117,2,0,0); -- ImagineXI: was perpetuation; now Summoning magic skill

-- ----------------------------------------------------------------
-- item_latents: perpetuation latents → Summoning / pet MACC
-- ----------------------------------------------------------------
DELETE FROM `item_latents` WHERE `modId` = 346 AND `itemId` IN (11752,12493,13300,14062,14401,14410,14946,15285,16154,25633);

INSERT INTO `item_latents` VALUES (11752,117,2,9,16);
INSERT INTO `item_latents` VALUES (12493,117,2,9,9);
INSERT INTO `item_latents` VALUES (13300,993,2,2,75);
INSERT INTO `item_latents` VALUES (14062,117,2,9,8);
INSERT INTO `item_latents` VALUES (14401,117,1,9,7);
INSERT INTO `item_latents` VALUES (14410,117,1,9,6);
INSERT INTO `item_latents` VALUES (14946,117,1,13,2);
INSERT INTO `item_latents` VALUES (14946,117,1,13,19);
INSERT INTO `item_latents` VALUES (15285,117,3,8,15);
INSERT INTO `item_latents` VALUES (16154,117,3,9,13);
INSERT INTO `item_latents` VALUES (25633,117,1,9,8);

-- ----------------------------------------------------------------
-- item_mods_pet: remove enmity (useless); Avatar → pet MAB/MDB or MACC/MEVA; All Pets → PET_ACC_EVA
-- ----------------------------------------------------------------
DELETE FROM `item_mods_pet` WHERE `modId` = 27;

INSERT INTO `item_mods_pet` VALUES (10914,991,3,0);  -- was All Pets Enmity-2
INSERT INTO `item_mods_pet` VALUES (10915,991,4,0);  -- was All Pets Enmity-3
INSERT INTO `item_mods_pet` VALUES (11739,992,2,1);
INSERT INTO `item_mods_pet` VALUES (12520,993,3,1);
INSERT INTO `item_mods_pet` VALUES (12650,993,2,1);
INSERT INTO `item_mods_pet` VALUES (13975,993,2,1);
INSERT INTO `item_mods_pet` VALUES (14103,993,2,1);
INSERT INTO `item_mods_pet` VALUES (14228,993,2,1);
INSERT INTO `item_mods_pet` VALUES (14468,992,5,1);
INSERT INTO `item_mods_pet` VALUES (14904,993,2,1);
INSERT INTO `item_mods_pet` VALUES (15239,993,3,1);
INSERT INTO `item_mods_pet` VALUES (15366,993,4,1);
INSERT INTO `item_mods_pet` VALUES (15575,993,2,1);
INSERT INTO `item_mods_pet` VALUES (15594,992,2,1);
INSERT INTO `item_mods_pet` VALUES (15679,992,2,1);
INSERT INTO `item_mods_pet` VALUES (15910,991,4,0);
INSERT INTO `item_mods_pet` VALUES (20822,991,8,0);
INSERT INTO `item_mods_pet` VALUES (21167,992,8,1);
INSERT INTO `item_mods_pet` VALUES (25563,991,10,0);
INSERT INTO `item_mods_pet` VALUES (25564,991,12,0);
INSERT INTO `item_mods_pet` VALUES (26677,992,8,1);
INSERT INTO `item_mods_pet` VALUES (26888,992,10,1);
INSERT INTO `item_mods_pet` VALUES (27221,992,4,1);
INSERT INTO `item_mods_pet` VALUES (27677,992,4,1);
INSERT INTO `item_mods_pet` VALUES (27698,992,4,1);
INSERT INTO `item_mods_pet` VALUES (27957,992,5,1);
INSERT INTO `item_mods_pet` VALUES (27978,992,5,1);
INSERT INTO `item_mods_pet` VALUES (28104,992,4,1);
INSERT INTO `item_mods_pet` VALUES (28125,992,4,1);
INSERT INTO `item_mods_pet` VALUES (28237,992,5,1);
INSERT INTO `item_mods_pet` VALUES (28258,992,5,1);
INSERT INTO `item_mods_pet` VALUES (28495,991,6,0);

-- ----------------------------------------------------------------
-- item_latents: any latent that only adjusted enmity
-- ----------------------------------------------------------------
DELETE FROM `item_latents` WHERE `modId` = 27;

-- ----------------------------------------------------------------
-- item_mods: enmity loss reduction (427) — tied to hate; strip from gear
-- ----------------------------------------------------------------
DELETE FROM `item_mods` WHERE `modId` = 427;
