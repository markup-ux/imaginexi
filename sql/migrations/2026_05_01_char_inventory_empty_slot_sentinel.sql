-- Normalize legacy empty-slot rows: DEFAULT itemId was 65535 (Gil) with quantity 0.
-- Those loaded as bogus CItemCurrency in LoadInventory. Default is now 0 (see char_inventory.sql).

UPDATE `char_inventory`
SET `itemId` = 0, `quantity` = 0, `bazaar` = 0, `signature` = '', `extra` = NULL
WHERE `itemId` = 65535 AND `quantity` = 0;

ALTER TABLE `char_inventory`
MODIFY COLUMN `itemId` smallint(5) unsigned NOT NULL DEFAULT 0;
