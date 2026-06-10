-- Imagine XI: Charged nuke DoT (ARCANE_CHARGE = 506)
-- Run on existing DBs; matches server/sql/status_effects.sql seed data.

INSERT INTO `status_effects` (`id`, `name`, `flags`, `type`, `negative_id`, `overwrite`, `block_id`, `remove_id`, `element`, `min_duration`, `sort_key`, `wear_off_message_id`)
VALUES (506, 'arcane_charge', 32, 0, 0, 0, 0, 0, 0, 0, 0, NULL)
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `flags` = VALUES(`flags`);
