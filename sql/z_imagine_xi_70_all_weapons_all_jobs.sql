-- Feature: All equipment all jobs + weaponskills without job restrictions
--
-- Equipment: set item_equipment.jobs to all 22 jobs (2^22 - 1 = 4194303) for every row.
-- Weaponskills: set jobs blob to non-zero for every stored job slot (server still enforces skill level / unlock).
-- Clear main_only so subjob is not special-cased in data. Runtime job checks are also disabled in battleutils.
--
-- Idempotent: rerunning keeps the same final state.
UPDATE item_equipment
SET jobs = 4194303
WHERE jobs <> 4194303;

-- 22 bytes of 0x01: eligible on every job index used by weapon_skills.jobs blob
UPDATE weapon_skills
SET jobs = UNHEX(REPEAT('01', 22)),
    main_only = 0;
