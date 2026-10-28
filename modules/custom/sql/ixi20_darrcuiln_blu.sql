-- Imagine XI 2.0: Darrcuiln is the Blue Mage trust.
-- Main BLU / sub RDM, and his own TP moves instead of the sword kit.
-- The full blue spell list is ixi20_darrcuiln_spells.sql, loaded next.
-- Apply this file after ixi20_trust_missing_ws.sql.
-- Rebuild xi_map so ixi20_trust_ws.cpp stops adding the sword kit.

UPDATE `mob_pools`
SET `mJob` = 16,
    `sJob` = 5,
    `spellList` = 568
WHERE `poolid` = 5991
  AND `name` = 'darrcuiln';

DELETE FROM `mob_skill_lists`
WHERE `skill_list_id` = 1106
  AND `mob_skill_id` IN (40, 42, 88);

INSERT IGNORE INTO `mob_skill_lists` (`skill_list_name`, `skill_list_id`, `mob_skill_id`) VALUES
    ('TRUST_Darrcuiln', 1106, 3684), -- Aurous Charge
    ('TRUST_Darrcuiln', 1106, 3685), -- Howling Gust
    ('TRUST_Darrcuiln', 1106, 3686), -- Righteous Rasp
    ('TRUST_Darrcuiln', 1106, 3687), -- Starward Yowl
    ('TRUST_Darrcuiln', 1106, 3688); -- Stalking Prey

-- NM ids 3168-3172 share the script names with the trust ids.
UPDATE `mob_skills` SET `primary_sc` = 3,  `secondary_sc` = 1  WHERE `mob_skill_id` IN (3168, 3684); -- Liquefaction / Transfixion
UPDATE `mob_skills` SET `primary_sc` = 12, `secondary_sc` = 2  WHERE `mob_skill_id` IN (3169, 3685); -- Fragmentation / Compression
UPDATE `mob_skills` SET `primary_sc` = 11, `secondary_sc` = 1  WHERE `mob_skill_id` IN (3170, 3686); -- Fusion / Transfixion
UPDATE `mob_skills` SET `primary_sc` = 9,  `secondary_sc` = 5  WHERE `mob_skill_id` IN (3171, 3687); -- Gravitation / Reverberation
UPDATE `mob_skills`
SET `primary_sc` = 13,
    `secondary_sc` = 12,
    `mob_skill_aoe` = 1,
    `mob_skill_aoe_radius` = 10.0
WHERE `mob_skill_id` IN (3172, 3688); -- Light / Fragmentation

-- Spell rows are the full blue kit in ixi20_darrcuiln_spells.sql,
-- loaded after this file. This file keeps the job, the TP moves, and
-- the skillchain properties.
