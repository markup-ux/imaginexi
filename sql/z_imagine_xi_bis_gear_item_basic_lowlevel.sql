-- Incremental patch: low-level !grantbis fallbacks (apply if you already imported z_imagine_xi_bis_gear_item_basic.sql).
-- mysql -u root -p xidb < server/sql/z_imagine_xi_bis_gear_item_basic_lowlevel.sql

SET NAMES utf8mb4;

SET @EQUIPMENT_TYPE = 6;
SET @WEAPON_TYPE = 7;
SET @FLAG_MYSTERY_BOX = 4;
SET @FLAG_CAN_SEND_ACCT = 16;
SET @FLAG_CANEQUIP = 2048;
SET @H2H = 1; SET @DAGGER = 2; SET @SWORD = 3; SET @GREATSWORD = 4; SET @AXE = 5;
SET @GREATAXE = 6; SET @SCYTHE = 7; SET @POLEARM = 8; SET @KATANA = 9; SET @GREATKATANA = 10;
SET @CLUB = 11; SET @STAFF = 12; SET @BOW = 13; SET @AMMUNITION = 15; SET @SHIELD = 16;
SET @HEAD = 17; SET @BODY = 18; SET @HANDS = 19; SET @LEGS = 20; SET @FEET = 21;
SET @NECK = 22; SET @WAIST = 23; SET @EARRINGS = 24; SET @RINGS = 25; SET @BACK = 26;

INSERT INTO `item_basic` VALUES (12440,0,'leather_bandana','leather_bandana','leather_bandana',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@HEAD,0);
INSERT INTO `item_basic` VALUES (12496,0,'copper_hairpin','copper_hairpin','copper_hairpin',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@HEAD,0);
INSERT INTO `item_basic` VALUES (12696,0,'leather_gloves','leather_gloves','leather_gloves',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@HANDS,0);
INSERT INTO `item_basic` VALUES (12704,0,'bronze_mittens','bronze_mittens','bronze_mittens',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@HANDS,0);
INSERT INTO `item_basic` VALUES (12824,0,'leather_trousers','leather_trousers','leather_trousers',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@LEGS,0);
INSERT INTO `item_basic` VALUES (12832,0,'bronze_subligar','bronze_subligar','bronze_subligar',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@LEGS,0);
INSERT INTO `item_basic` VALUES (12952,0,'leather_highboots','leather_highboots','leather_highboots',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@FEET,0);
INSERT INTO `item_basic` VALUES (12960,0,'bronze_leggings','bronze_leggings','bronze_leggings',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@FEET,0);
INSERT INTO `item_basic` VALUES (13192,0,'leather_belt','leather_belt','leather_belt',@EQUIPMENT_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@WAIST,0);
INSERT INTO `item_basic` VALUES (16833,0,'bronze_spear','bronze_spear','bronze_spear',@WEAPON_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@POLEARM,0);
INSERT INTO `item_basic` VALUES (16966,0,'tachi','tachi','tachi',@WEAPON_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@GREATKATANA,0);
INSERT INTO `item_basic` VALUES (17830,0,'wooden_katana','wooden_katana','wooden_katana',@WEAPON_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@GREATKATANA,0);
INSERT INTO `item_basic` VALUES (18117,0,'gimlet_spear','gimlet_spear','gimlet_spear',@WEAPON_TYPE,1,@FLAG_MYSTERY_BOX | @FLAG_CAN_SEND_ACCT | @FLAG_CANEQUIP,@POLEARM,0);
