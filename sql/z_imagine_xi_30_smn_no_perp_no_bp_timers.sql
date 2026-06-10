-- Feature: Summoner - remove perpetuation cost and Blood Pact timers
-- Notes:
-- - Perpetuation cost is disabled in server runtime code (`petutils.cpp`).
-- - This SQL removes BP recast behavior by clearing BP recast groups and setting minimal recast.

START TRANSACTION;

-- Blood Pact: Rage and Blood Pact: Ward umbrellas
UPDATE xidb.abilities
SET recastId = 0,
    recastTime = 1
WHERE abilityId IN (91, 172)
  AND job = 15;

-- All SMN Blood Pact actions tied to BP recast groups
UPDATE xidb.abilities
SET recastId = 0,
    recastTime = 1
WHERE job = 15
  AND recastId IN (173, 174);

COMMIT;
