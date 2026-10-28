-- Imagine XI 2.0: trust spell lists follow the 37-cap curve.
-- Retail min levels (Cure VI at 80, Flash at 45) are compressed onto 1-37:
--   1 + ROUND((min_level - 1) * 36 / 98)
-- Backup keeps re-apply idempotent. Revert by copying min_level back
-- from ixi20_trust_spell_min_backup.

CREATE TABLE IF NOT EXISTS `ixi20_trust_spell_min_backup` (
    `spell_list_id` SMALLINT(5) UNSIGNED NOT NULL,
    `spell_id` SMALLINT(3) UNSIGNED NOT NULL,
    `min_level` TINYINT(3) UNSIGNED NOT NULL,
    PRIMARY KEY (`spell_list_id`, `spell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO `ixi20_trust_spell_min_backup` (`spell_list_id`, `spell_id`, `min_level`)
SELECT `spell_list_id`, `spell_id`, `min_level`
FROM `mob_spell_lists`
WHERE `spell_list_name` LIKE 'TRUST\_%';

UPDATE `mob_spell_lists` AS live
INNER JOIN `ixi20_trust_spell_min_backup` AS src
    ON live.spell_list_id = src.spell_list_id
    AND live.spell_id = src.spell_id
SET live.min_level = CAST(GREATEST(1, LEAST(37, 1 + ROUND((src.min_level - 1) * 36 / 98))) AS UNSIGNED)
WHERE src.min_level > 1;
