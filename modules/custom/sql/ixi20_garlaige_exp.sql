-- Imagine XI 2.0: Garlaige Citadel [S] XP camps.
-- Pools clone the citadel families already placed in that zone
-- (bats, bombs, slimes, scolopendrids). Groups 210-214 are zone 164 only.
-- Revert with ixi20_REVERT.sql on xidb_ixi20 only.

INSERT INTO `mob_pools` (
    `poolid`, `name`, `packet_name`, `speciesid`, `modelid`,
    `mJob`, `sJob`, `cmbSkill`, `cmbDelay`, `cmbDmgMult`,
    `behavior`, `aggro`, `true_detection`, `links`, `mobType`,
    `immunity`, `name_prefix`, `flag`, `entityFlags`, `animationsub`,
    `hasSpellScript`, `spellList`, `namevis`, `roamflag`,
    `skill_list_id`, `resist_id`, `modelSize`, `modelHitboxSize`
) VALUES
    -- Dire Bat: species bat 173, model 256, skill list 224, resist Bat
    (9101, 'Ixi20_Gcs_Dire_Bat', 'Dire_Bat', 173, UNHEX('0000000100000000000000000000000000000000'),
     1, 1, 11, 240, 100, 0, 1, 0, 1, 0, 0, 0, 0, 643, 8, 0, 0, 0, 0, 224, 46, 1, 12),
    -- Incubus Bats: species flock_bat 181, model 260, skill list 2015
    (9102, 'Ixi20_Gcs_Incubus', 'Incubus_Bats', 181, UNHEX('0000040100000000000000000000000000000000'),
     1, 1, 11, 240, 100, 0, 1, 0, 1, 0, 0, 64, 0, 1669, 16, 0, 0, 0, 0, 2015, 46, 2, 18),
    -- Explosure: species bomb 46, model 280, skill list 56, resist Bomb
    (9103, 'Ixi20_Gcs_Explosure', 'Explosure', 46, UNHEX('0000180100000000000000000000000000000000'),
     1, 1, 11, 240, 100, 0, 1, 0, 0, 0, 0, 0, 0, 1153, 0, 0, 0, 0, 0, 56, 56, 1, 10),
    -- Mousse: species slime 18, model 292, skill list 229, resist Slime
    (9104, 'Ixi20_Gcs_Mousse', 'Mousse', 18, UNHEX('0000240100000000000000000000000000000000'),
     1, 1, 7, 240, 100, 0, 1, 0, 0, 0, 0, 0, 0, 645, 0, 0, 0, 0, 0, 229, 229, 2, 27),
    -- Scolopendrid: species scorpion 460, model 2243, skill list 217, resist Scorpion
    (9105, 'Ixi20_Gcs_Scolopendrid', 'Scolopendrid', 460, UNHEX('0000C30800000000000000000000000000000000'),
     1, 1, 7, 280, 100, 0, 1, 0, 1, 0, 0, 0, 0, 131, 0, 0, 0, 0, 0, 217, 217, 1, 27)
ON DUPLICATE KEY UPDATE
    `name`            = VALUES(`name`),
    `packet_name`     = VALUES(`packet_name`),
    `speciesid`       = VALUES(`speciesid`),
    `modelid`         = VALUES(`modelid`),
    `mJob`            = VALUES(`mJob`),
    `sJob`            = VALUES(`sJob`),
    `cmbSkill`        = VALUES(`cmbSkill`),
    `cmbDelay`        = VALUES(`cmbDelay`),
    `aggro`           = VALUES(`aggro`),
    `links`           = VALUES(`links`),
    `entityFlags`     = VALUES(`entityFlags`),
    `animationsub`    = VALUES(`animationsub`),
    `name_prefix`     = VALUES(`name_prefix`),
    `skill_list_id`   = VALUES(`skill_list_id`),
    `resist_id`       = VALUES(`resist_id`),
    `modelSize`       = VALUES(`modelSize`),
    `modelHitboxSize` = VALUES(`modelHitboxSize`);

-- 210 Dire Bat, 211 Incubus Bats, 212 Explosure, 213 Mousse, 214 Scolopendrid
INSERT INTO `mob_groups`
    (`groupid`, `poolid`, `zoneid`, `name`, `respawntime`, `spawntype`, `dropid`, `HP`, `MP`, `allegiance`)
VALUES
    (210, 9101, 164, 'Ixi20GcsDireBat',     180, 0, 0, 0, 0, 0),
    (211, 9102, 164, 'Ixi20GcsIncubus',     180, 0, 0, 0, 0, 0),
    (212, 9103, 164, 'Ixi20GcsExplosure',   180, 0, 0, 0, 0, 0),
    (213, 9104, 164, 'Ixi20GcsMousse',      180, 0, 0, 0, 0, 0),
    (214, 9105, 164, 'Ixi20GcsScolopendrid', 180, 0, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE
    `poolid`      = VALUES(`poolid`),
    `name`        = VALUES(`name`),
    `respawntime` = 180,
    `spawntype`   = 0,
    `dropid`      = 0,
    `HP`          = 0,
    `MP`          = 0,
    `allegiance`  = 0;
