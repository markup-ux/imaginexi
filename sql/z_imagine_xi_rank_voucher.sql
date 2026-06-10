-- ImagineXI: Equipment Voucher (nation rank-up reward)
-- Uses retail item ID 2552 so the client can display the icon/name.
-- Apply: mysql -u root -p xidb < server/sql/z_imagine_xi_rank_voucher.sql

SET NAMES utf8mb4;

SET @USABLE_TYPE = 5;
SET @FLAG_NOAUCTION = 64;
SET @FLAG_CANUSE = 512;
SET @FLAG_NOSALE = 4096;
SET @FLAG_NODELIVERY = 8192;
SET @FLAG_EX = 16384;
SET @FLAG_RARE = 32768;
SET @NONE = 99;

-- Remove the invisible custom ID if a prior patch was applied.
UPDATE `char_inventory` SET `itemId` = 2552 WHERE `itemId` = 32700;
DELETE FROM `item_usable` WHERE `itemid` = 32700;
DELETE FROM `item_basic` WHERE `itemid` = 32700;

REPLACE INTO `item_basic` VALUES (
    2552, 0,
    'equipment_voucher',
    'equip_voucher',
    '装備引換券',
    @USABLE_TYPE, 99,
    @FLAG_NOAUCTION | @FLAG_CANUSE | @FLAG_NOSALE | @FLAG_NODELIVERY | @FLAG_EX | @FLAG_RARE,
    @NONE, 0
);

REPLACE INTO `item_usable` VALUES (2552, 'equipment_voucher', 1, 1, 30, 0, 0, 0, 0, 0);
