-- Feature: Item rebalance
-- Source: extracted ImagineXI-tagged item rows from core SQL
-- - sql/item_mods.sql
-- - sql/item_mods_pet.sql
--
-- These are idempotent for dbtool setup/import flows by treating this file
-- as source of truth for the extracted custom rows.

-- Strip obsolete rows from core `item_mods.sql` so replacements are not duplicated (PK is itemId+modId).
DELETE FROM `item_mods` WHERE `modId` = 346 AND `itemId` IN (10321,10664,10684,11098,11158,11198,11258,13814,13815,14625,14906,15366,15430,17528,17597,17598,19005,19074,19094,19626,19724,19833,19962,21141,21142,22076,22077,23077,23144,23166,23322,23367,23657,26652,26653,26828,26829,26926,26927,27380,27381,27439,27440,27534,28237,28258,28296,28416);
DELETE FROM `item_mods` WHERE `modId` = 357 AND `itemId` IN (10664,10684,10704,10724,10744,11052,11564,11717,11982,12210,12211,12212,12493,13814,13815,13939,13940,14468,14487,14514,14826,14827,14904,14923,15086,15101,15116,15131,15146,15259,15594,15679,17573,21394,21395,23077,23121,23211,23278,23456,26652,26653,26888,27004,27005,27180,27181,27356,27534,27677,27698,27821,27842,27957,27978,28605);
DELETE FROM `item_mods` WHERE `modId` = 541 AND `itemId` IN (21377,21381,21383,21432,23144,23345,23680,26828,26829,26852,26853,27357);
DELETE FROM `item_mods_pet` WHERE (`itemId`,`modId`,`petType`) IN ((10664,346,1),(10684,346,1),(15146,357,1),(15679,357,1));

-- ----------------------------------------------------------------
-- item_mods (ImagineXI-tagged extracted rows)
-- ----------------------------------------------------------------
INSERT INTO `item_mods` VALUES (10321, 117, 6); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 2
INSERT INTO `item_mods` VALUES (10658,391,12); -- CHARM_CHANCE: +12 (ImagineXI: main BST charm is permanent; duration mod unused)
INSERT INTO `item_mods` VALUES (10664, 117, 7); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 3
INSERT INTO `item_mods` VALUES (10664, 993, 9); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 5
INSERT INTO `item_mods` VALUES (10684, 117, 7); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 3
INSERT INTO `item_mods` VALUES (10684, 993, 10); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 6
INSERT INTO `item_mods` VALUES (10704, 993, 8); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 4
INSERT INTO `item_mods` VALUES (10724, 993, 8); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 4
INSERT INTO `item_mods` VALUES (10744, 993, 8); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 4
INSERT INTO `item_mods` VALUES (11052, 993, 9); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: -5
INSERT INTO `item_mods` VALUES (11098, 993, 8); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 4
INSERT INTO `item_mods` VALUES (11158, 117, 7); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 3
INSERT INTO `item_mods` VALUES (11198, 993, 7); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 3
INSERT INTO `item_mods` VALUES (11258, 117, 6); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 2
INSERT INTO `item_mods` VALUES (11717, 993, 5); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 1
INSERT INTO `item_mods` VALUES (11982, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (12210, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (12211, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (12212, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (12493, 993, 8); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 4
INSERT INTO `item_mods` VALUES (13814, 117, 5); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 1
INSERT INTO `item_mods` VALUES (13814, 993, 7); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 3
INSERT INTO `item_mods` VALUES (13815, 117, 6); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 2
INSERT INTO `item_mods` VALUES (13815, 993, 8); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 4
INSERT INTO `item_mods` VALUES (13939, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (13940, 993, 7); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 3
INSERT INTO `item_mods` VALUES (14468, 993, 9); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 5
INSERT INTO `item_mods` VALUES (14487, 993, 8); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 4
INSERT INTO `item_mods` VALUES (14514, 993, 8); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 4
INSERT INTO `item_mods` VALUES (14625,993,3);  -- PET_MACC_MEVA: 3 (ImagineXI: no perpetuation)
INSERT INTO `item_mods` VALUES (14826, 993, 5); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 1
INSERT INTO `item_mods` VALUES (14827, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (14904, 993, 5); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 1
INSERT INTO `item_mods` VALUES (14906, 117, 5); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 1
INSERT INTO `item_mods` VALUES (14923, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (15259, 993, 7); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 3
INSERT INTO `item_mods` VALUES (15366, 117, 5); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 1
INSERT INTO `item_mods` VALUES (15430, 117, 5); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 1
INSERT INTO `item_mods` VALUES (15594, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (15679, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (17528, 117, 6); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 2
INSERT INTO `item_mods` VALUES (17573, 993, 7); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 3
INSERT INTO `item_mods` VALUES (17597, 117, 5); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 1
INSERT INTO `item_mods` VALUES (17598, 993, 7); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 3
INSERT INTO `item_mods` VALUES (19005, 117, 8); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 4
INSERT INTO `item_mods` VALUES (19074, 117, 9); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 5
INSERT INTO `item_mods` VALUES (19094, 117, 10); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 6
INSERT INTO `item_mods` VALUES (19626, 117, 11); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 7
INSERT INTO `item_mods` VALUES (19724, 117, 11); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 7
INSERT INTO `item_mods` VALUES (19833, 117, 12); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 8
INSERT INTO `item_mods` VALUES (19962, 117, 12); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 8
INSERT INTO `item_mods` VALUES (21141, 117, 12); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 8
INSERT INTO `item_mods` VALUES (21142, 117, 12); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 8
INSERT INTO `item_mods` VALUES (21377, 992, 7); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 4
INSERT INTO `item_mods` VALUES (21381, 992, 8); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 5
INSERT INTO `item_mods` VALUES (21383, 992, 6); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 3
INSERT INTO `item_mods` VALUES (21394, 993, 10); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 6
INSERT INTO `item_mods` VALUES (21395, 993, 11); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 7
INSERT INTO `item_mods` VALUES (21432, 992, 8); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 5
INSERT INTO `item_mods` VALUES (22076, 117, 9); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 5
INSERT INTO `item_mods` VALUES (22077, 117, 11); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 7
INSERT INTO `item_mods` VALUES (23077, 117, 8); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: -4
INSERT INTO `item_mods` VALUES (23077, 993, 13); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: -9
INSERT INTO `item_mods` VALUES (23121, 993, 14); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 10
INSERT INTO `item_mods` VALUES (23144, 117, 9); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 5
INSERT INTO `item_mods` VALUES (23144, 992, 6); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: -3
INSERT INTO `item_mods` VALUES (23166, 993, 11); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: -7
INSERT INTO `item_mods` VALUES (23211, 993, 11); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: -7
INSERT INTO `item_mods` VALUES (23278, 993, 11); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: -7
INSERT INTO `item_mods` VALUES (23322, 117, 9); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 5
INSERT INTO `item_mods` VALUES (23345, 992, 5); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 2
INSERT INTO `item_mods` VALUES (23367, 117, 12); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: -8
INSERT INTO `item_mods` VALUES (23456, 993, 15); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 15
INSERT INTO `item_mods` VALUES (23657, 117, 10); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 6
INSERT INTO `item_mods` VALUES (23680, 992, 6); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: -3
INSERT INTO `item_mods` VALUES (26652, 117, 8); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 4
INSERT INTO `item_mods` VALUES (26652, 993, 11); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 7
INSERT INTO `item_mods` VALUES (26653, 117, 8); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 4
INSERT INTO `item_mods` VALUES (26653, 993, 12); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 8
INSERT INTO `item_mods` VALUES (26828, 117, 8); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 4
INSERT INTO `item_mods` VALUES (26828, 992, 4); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 1
INSERT INTO `item_mods` VALUES (26829, 117, 9); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 5
INSERT INTO `item_mods` VALUES (26829, 992, 5); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 2
INSERT INTO `item_mods` VALUES (26852, 992, 5); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 2
INSERT INTO `item_mods` VALUES (26853, 992, 6); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 3
INSERT INTO `item_mods` VALUES (26888, 993, 12); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 8
INSERT INTO `item_mods` VALUES (26926, 993, 9); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 5
INSERT INTO `item_mods` VALUES (26927, 993, 10); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 6
INSERT INTO `item_mods` VALUES (27004, 993, 9); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 5
INSERT INTO `item_mods` VALUES (27005, 993, 10); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 6
INSERT INTO `item_mods` VALUES (27180, 993, 9); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 5
INSERT INTO `item_mods` VALUES (27181, 993, 10); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 6
INSERT INTO `item_mods` VALUES (27356, 993, 9); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 5
INSERT INTO `item_mods` VALUES (27357, 992, 4); -- ImagineXI: replaced BP_DELAY_II (541); was: BP_DELAY_II: 1
INSERT INTO `item_mods` VALUES (27380, 117, 12); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 8
INSERT INTO `item_mods` VALUES (27381, 117, 13); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 9
INSERT INTO `item_mods` VALUES (27439, 117, 10); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 6
INSERT INTO `item_mods` VALUES (27440, 117, 11); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 7
INSERT INTO `item_mods` VALUES (27534, 117, 6); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 2
INSERT INTO `item_mods` VALUES (27534, 993, 6); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 2
INSERT INTO `item_mods` VALUES (27677, 993, 11); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 7
INSERT INTO `item_mods` VALUES (27698, 993, 12); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 8
INSERT INTO `item_mods` VALUES (27821, 993, 10); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 6
INSERT INTO `item_mods` VALUES (27842, 993, 10); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 6
INSERT INTO `item_mods` VALUES (27957, 993, 9); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 5
INSERT INTO `item_mods` VALUES (27978, 993, 10); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 6
INSERT INTO `item_mods` VALUES (28237, 117, 8); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 4
INSERT INTO `item_mods` VALUES (28258, 117, 8); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 4
INSERT INTO `item_mods` VALUES (28296, 117, 7); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 3
INSERT INTO `item_mods` VALUES (28416, 993, 6); -- ImagineXI: replaced PERPETUATION (346); was: PERPETUATION_REDUCTION: 2
INSERT INTO `item_mods` VALUES (28605, 993, 7); -- ImagineXI: replaced BP_DELAY (357); was: BP_DELAY: 3

-- ----------------------------------------------------------------
-- item_mods_pet (ImagineXI-tagged extracted rows)
-- ----------------------------------------------------------------
INSERT INTO `item_mods_pet` VALUES (10664, 30, 7, 1); -- ImagineXI: replaced 346; was: Avatar - PERPETUATION_REDUCTION: 3
INSERT INTO `item_mods_pet` VALUES (10684, 30, 7, 1); -- ImagineXI: replaced 346; was: Avatar - PERPETUATION_REDUCTION: 3
INSERT INTO `item_mods_pet` VALUES (15146, 30, 6, 1); -- ImagineXI: replaced 357; was: Avatar - BP_DELAY: -2
INSERT INTO `item_mods_pet` VALUES (15679, 30, 6, 1); -- ImagineXI: replaced 357; was: Avatar - BP_DELAY: -2
