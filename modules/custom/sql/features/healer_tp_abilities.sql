-- ImagineXI: WHM healer TP-spender abilities (job-agnostic party spec)
-- See: server/documentation/JOB_AGNOSTIC_PARTY_SPEC.md §3.2
-- Idempotent: safe to re-run

DELETE FROM `abilities` WHERE `abilityId` IN (980, 981, 982, 983);

INSERT INTO `abilities` VALUES
-- abilityId, name, job, level, validTarget, recastTime, recastId, message1, message2, animation, animationTime, castTime, actionType, range, isAOE, radius, CE, VE, meritModID, addType, content_tag
(980, 'luminous_strike',   3,  1, 4,  30, 980, 0, 0, 110, 2000, 0, 6, 12.0, 0, 0,  50, 200, 0, 0, NULL),
(981, 'radiant_scission',  3, 14, 4,  60, 981, 0, 0, 111, 2000, 0, 6, 12.0, 0, 0, 100, 300, 0, 0, NULL),
(982, 'sacred_cascade',    3, 27, 1, 120, 982, 0, 0, 112, 2000, 0, 6,  0.0, 1, 10,   0,   0, 0, 0, NULL),
(983, 'divine_resonance',  3, 37, 1, 180, 983, 0, 0, 113, 2000, 0, 6,  0.0, 1, 10,   0,   0, 0, 0, NULL);
