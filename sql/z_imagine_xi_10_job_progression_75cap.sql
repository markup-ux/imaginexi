-- Feature: Job progression (75-cap)
-- Source: legacy modules/custom/sql/imaginexi.sql
--
-- NOTE:
-- - This file preserves existing active SQL behavior from the legacy module.
-- - Commented historical sections remain for operator context.


-- 2) Make every ability level 1 (disabled: use stock ability levels from base SQL)
-- UPDATE abilities
-- SET level = 1;

-- Disabled: preserves base/retail ability addType flags (needed for learned/merit/AF/arts logic and learned-message filters)
-- UPDATE abilities
-- SET addType = 0;

-- MERGED INTO server/sql/abilities.sql (ImagineXI parity; do not re-apply on fresh import)
/*
-- Blood Pact: Rage umbrella
UPDATE abilities
SET recastId = 0, recastTime = 1
WHERE abilityId = 91;

-- Blood Pact: Ward umbrella
UPDATE abilities
SET recastId = 0, recastTime = 1
WHERE abilityId = 172;

UPDATE abilities
SET recastId = 0,
    recastTime = 1
WHERE recastId IN (173,174)
  AND job = 15;

COMMIT;


UPDATE abilities
SET recastTime = 1
WHERE abilityId = 176;

UPDATE abilities
SET level = 95
WHERE abilityId = 298       -- Unbridled Learning
  AND job = 16;

UPDATE abilities
SET level = 96
WHERE abilityId = 338       -- Unbridled Wisdom
  AND job = 16;
*/

START TRANSACTION;

-- If you aren't already on the right DB, uncomment the next line:
-- USE xidb;

-- 1) Collapse duplicates that only differ by level.
/* DELETE t
FROM xidb.traits t
JOIN (
  SELECT traitid, job, `rank`, modifier, MIN(`level`) AS keep_level
  FROM xidb.traits
  GROUP BY traitid, job, `rank`, modifier
  HAVING COUNT(*) > 1
) d
  ON d.traitid = t.traitid
 AND d.job     = t.job
 AND d.`rank`  = t.`rank`
 AND d.modifier= t.modifier
WHERE t.`level` <> d.keep_level;

-- 2) Disabled: keep stock trait progression levels (avoid flattening all trait unlocks to level 1)
-- UPDATE xidb.traits
-- SET `level` = 1;

COMMIT; */

-- dual wield
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (18,'dual wield',6,1,2,259,15,NULL,0),
  (18,'dual wield',13,1,2,259,15,NULL,0),
  (18,'dual wield',16,1,2,259,15,NULL,0),
  (18,'dual wield',19,1,2,259,15,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

-- treasure hunter iii
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (65,'treasure hunter iii',6,1,3,303,1,NULL,0),
  (65,'treasure hunter iii',9,1,3,303,1,NULL,0),
  (65,'treasure hunter iii',11,1,3,303,1,NULL,0),
  (65,'treasure hunter iii',17,1,3,303,1,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

-- gilfinder
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (20,'gilfinder',6,1,1,897,50,NULL,0),
  (20,'gilfinder',9,1,1,897,50,NULL,0),
  (20,'gilfinder',11,1,1,897,50,NULL,0),
  (20,'gilfinder',17,1,1,897,50,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

-- auto refresh
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (10,'auto refresh',3,1,2,369,2,NULL,0),
  (10,'auto refresh',4,1,2,369,2,NULL,0),
  (10,'auto refresh',5,1,2,369,2,NULL,0),
  (10,'auto refresh',7,1,2,369,2,NULL,0),
  (10,'auto refresh',8,1,2,369,2,NULL,0),
  (10,'auto refresh',15,1,2,369,2,NULL,0),
  (10,'auto refresh',16,1,2,369,2,NULL,0),
  (10,'auto refresh',20,1,2,369,2,NULL,0),
  (10,'auto refresh',21,1,2,369,2,NULL,0),
  (10,'auto refresh',22,1,2,369,2,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

-- clear mind
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (24,'clear mind',3,1,6,71,18,NULL,0),
  (24,'clear mind',4,1,6,71,18,NULL,0),
  (24,'clear mind',5,1,6,71,18,NULL,0),
  (24,'clear mind',7,1,6,71,18,NULL,0),
  (24,'clear mind',8,1,6,71,18,NULL,0),
  (24,'clear mind',15,1,6,71,18,NULL,0),
  (24,'clear mind',16,1,6,71,18,NULL,0),
  (24,'clear mind',20,1,6,71,18,NULL,0),
  (24,'clear mind',21,1,6,71,18,NULL,0),
  (24,'clear mind',22,1,6,71,18,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

-- conserve mp
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (13,'conserve mp',3,1,7,296,43,NULL,0),
  (13,'conserve mp',4,1,7,296,43,NULL,0),
  (13,'conserve mp',5,1,7,296,43,NULL,0),
  (13,'conserve mp',7,1,7,296,43,NULL,0),
  (13,'conserve mp',8,1,7,296,43,NULL,0),
  (13,'conserve mp',15,1,7,296,43,NULL,0),
  (13,'conserve mp',16,1,7,296,43,NULL,0),
  (13,'conserve mp',20,1,7,296,43,NULL,0),
  (13,'conserve mp',21,1,7,296,43,NULL,0),
  (13,'conserve mp',22,1,7,296,43,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

-- fast cast
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (12,'fast cast',3,1,5,170,30,NULL,0),
  (12,'fast cast',4,1,5,170,30,NULL,0),
  (12,'fast cast',5,1,5,170,30,NULL,0),
  (12,'fast cast',7,1,5,170,30,NULL,0),
  (12,'fast cast',8,1,5,170,30,NULL,0),
  (12,'fast cast',10,1,5,170,30,NULL,0),
  (12,'fast cast',15,1,5,170,30,NULL,0),
  (12,'fast cast',16,1,5,170,30,NULL,0),
  (12,'fast cast',20,1,5,170,30,NULL,0),
  (12,'fast cast',21,1,5,170,30,NULL,0),
  (12,'fast cast',22,1,5,170,30,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

UPDATE xidb.skill_ranks
SET name = 'dagger',
    war = 1, mnk = 0, whm = 0, blm = 9, rdm = 1, thf = 1, pld = 8, drk = 7, bst = 6, brd = 1,
    rng = 1, sam = 10, nin = 1, drg = 10, smn = 10, blu = 0, cor = 1, pup = 8, dnc = 1, sch = 9, geo = 8, run = 0
WHERE skillid = 2;

UPDATE xidb.skill_ranks
SET name = 'sword',
    war = 1, mnk = 0, whm = 0, blm = 0, rdm = 1, thf = 9, pld = 1, drk = 1, bst = 10, brd = 1,
    rng = 9, sam = 6, nin = 7, drg = 8, smn = 0, blu = 1, cor = 1, pup = 0, dnc = 9, sch = 0, geo = 0, run = 1
WHERE skillid = 3;

UPDATE xidb.skill_ranks
SET name = 'great sword',
    war = 1, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 1, drk = 1, bst = 0, brd = 0,
    rng = 0, sam = 0, nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 1
WHERE skillid = 4;

UPDATE xidb.skill_ranks
SET name = 'axe',
    war = 1, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 0, drk = 1, bst = 1, brd = 0,
    rng = 1, sam = 0, nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 5
WHERE skillid = 5;

UPDATE xidb.skill_ranks
SET name = 'great axe',
    war = 1, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 0, drk = 1, bst = 0, brd = 0,
    rng = 0, sam = 0, nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 4
WHERE skillid = 6;

UPDATE xidb.skill_ranks
SET name = 'scythe',
    war = 1, mnk = 0, whm = 0, blm = 1, rdm = 0, thf = 0, pld = 0, drk = 1, bst = 1, brd = 0,
    rng = 0, sam = 0, nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 7;

UPDATE xidb.skill_ranks
SET name = 'polearm',
    war = 1, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 1, drk = 0, bst = 0, brd = 0,
    rng = 0, sam = 1, nin = 0, drg = 1, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 8;

UPDATE xidb.skill_ranks
SET name = 'katana',
    war = 0, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 0, drk = 0, bst = 0, brd = 0,
    rng = 0, sam = 0, nin = 1, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 9;

UPDATE xidb.skill_ranks
SET name = 'great katana',
    war = 0, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 0, drk = 0, bst = 0, brd = 0,
    rng = 0, sam = 1, nin = 1, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 10;

UPDATE xidb.skill_ranks
SET name = 'club',
    war = 1, mnk = 6, whm = 1, blm = 1, rdm = 1, thf = 10, pld = 1, drk = 8, bst = 9, brd = 9, rng = 10, sam = 10,
    nin = 10, drg = 10, smn = 6, blu = 5, cor = 0, pup = 9, dnc = 0, sch = 1, geo = 1, run = 8
WHERE skillid = 11;

UPDATE xidb.skill_ranks
SET name = 'staff',
    war = 1, mnk = 1, whm = 1, blm = 1, rdm = 1, thf = 0, pld = 2, drk = 0, bst = 0, brd = 6, rng = 0, sam = 0,
    nin = 0, drg = 5, smn = 1, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 12;

UPDATE xidb.skill_ranks
SET name = 'archery',
    war = 1, mnk = 0, whm = 0, blm = 0, rdm = 9, thf = 1, pld = 0, drk = 0, bst = 0, brd = 0, rng = 1, sam = 1,
    nin = 10, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 25;

UPDATE xidb.skill_ranks
SET name = 'marksmanship',
    war = 1, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 1, pld = 0, drk = 1, bst = 0, brd = 0, rng = 1, sam = 0,
    nin = 7, drg = 0, smn = 0, blu = 0, cor = 1, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 26;

UPDATE xidb.skill_ranks
SET name = 'throwing',
    war = 9, mnk = 10, whm = 10, blm = 9, rdm = 11, thf = 1, pld = 0, drk = 0, bst = 0, brd = 10, rng = 1, sam = 6,
    nin = 1, drg = 0, smn = 0, blu = 1, cor = 6, pup = 6, dnc = 1, sch = 9, geo = 0, run = 0
WHERE skillid = 27;

UPDATE xidb.skill_ranks
SET name = 'guarding',
    war = 0, mnk = 1, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 0, drk = 0, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 5, pup = 1, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 28;

UPDATE xidb.skill_ranks
SET name = 'evasion',
    war = 7, mnk = 3, whm = 10, blm = 10, rdm = 9, thf = 1, pld = 7, drk = 7, bst = 7, brd = 9, rng = 10, sam = 3,
    nin = 2, drg = 4, smn = 10, blu = 8, cor = 9, pup = 4, dnc = 3, sch = 10, geo = 9, run = 3
WHERE skillid = 29;

UPDATE xidb.skill_ranks
SET name = 'shield',
    war = 1, mnk = 0, whm = 1, blm = 0, rdm = 1, thf = 1, pld = 1, drk = 1, bst = 10, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 30;

UPDATE xidb.skill_ranks
SET name = 'parrying',
    war = 8, mnk = 10, whm = 0, blm = 0, rdm = 10, thf = 2, pld = 7, drk = 10, bst = 7, brd = 10, rng = 0, sam = 2,
    nin = 2, drg = 5, smn = 0, blu = 9, cor = 2, pup = 9, dnc = 4, sch = 10, geo = 10, run = 1
WHERE skillid = 31;

UPDATE xidb.skill_ranks
SET name = 'divine',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0, pld = 1, drk = 1, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 1, blu = 1, cor = 0, pup = 0, dnc = 0, sch = 1, geo = 1, run = 1
WHERE skillid = 32;

UPDATE xidb.skill_ranks
SET name = 'healing',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0, pld = 1, drk = 1, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 1, blu = 1, cor = 1, pup = 0, dnc = 0, sch = 1, geo = 1, run = 1
WHERE skillid = 33;

UPDATE xidb.skill_ranks
SET name = 'enhancing',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0, pld = 1, drk = 1, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 1, blu = 1, cor = 1, pup = 0, dnc = 0, sch = 1, geo = 1, run = 1
WHERE skillid = 34;

UPDATE xidb.skill_ranks
SET name = 'enfeebling',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0, pld = 1, drk = 1, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 1, drg = 0, smn = 1, blu = 1, cor = 1, pup = 0, dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 35;

UPDATE xidb.skill_ranks
SET name = 'elemental',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0, pld = 1, drk = 1, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 1, drg = 0, smn = 1, blu = 1, cor = 0, pup = 0, dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 36;

UPDATE xidb.skill_ranks
SET name = 'dark',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0, pld = 1, drk = 1, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 1, drg = 0, smn = 1, blu = 1, cor = 0, pup = 0, dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 37;

UPDATE xidb.skill_ranks
SET name = 'summoning',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0, pld = 0, drk = 0, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 1, blu = 1, cor = 0, pup = 0, dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 38;

UPDATE xidb.skill_ranks
SET name = 'ninjutsu',
    war = 1, mnk = 1, whm = 1, blm = 1, rdm = 1, thf = 1, pld = 1, drk = 1, bst = 1, brd = 1, rng = 1, sam = 1,
    nin = 1, drg = 1, smn = 1, blu = 1, cor = 1, pup = 1, dnc = 1, sch = 1, geo = 1, run = 1
WHERE skillid = 39;

UPDATE xidb.skill_ranks
SET name = 'singing',
    war = 0, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 0, drk = 0, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 40;

UPDATE xidb.skill_ranks
SET name = 'string',
    war = 0, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 0, drk = 0, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 41;

UPDATE xidb.skill_ranks
SET name = 'wind',
    war = 0, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0, pld = 0, drk = 0, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0, dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 42;

-- MERGED INTO server/sql/abilities_charges.sql
/*
UPDATE abilities_charges
SET maxCharges = 10,
    chargeTime = 5
WHERE recastId = 231
  AND job = 20;
*/

START TRANSACTION;

-- Shield Mastery override
DELETE FROM xidb.traits
WHERE traitid = 25
  AND job IN (1, 3, 5, 7)
  AND (rank <> 4 OR level <> 1);

INSERT INTO xidb.traits (traitid, name, job, level, rank, modifier, value, content_tag, meritid)
SELECT 25, 'shield mastery', 1, 1, 4, 485, 40, NULL, 0
WHERE NOT EXISTS (
    SELECT 1 FROM xidb.traits
    WHERE traitid = 25 AND job = 1 AND level = 1 AND rank = 4
);

INSERT INTO xidb.traits (traitid, name, job, level, rank, modifier, value, content_tag, meritid)
SELECT 25, 'shield mastery', 3, 1, 4, 485, 40, NULL, 0
WHERE NOT EXISTS (
    SELECT 1 FROM xidb.traits
    WHERE traitid = 25 AND job = 3 AND level = 1 AND rank = 4
);

INSERT INTO xidb.traits (traitid, name, job, level, rank, modifier, value, content_tag, meritid)
SELECT 25, 'shield mastery', 5, 1, 4, 485, 40, NULL, 0
WHERE NOT EXISTS (
    SELECT 1 FROM xidb.traits
    WHERE traitid = 25 AND job = 5 AND level = 1 AND rank = 4
);

INSERT INTO xidb.traits (traitid, name, job, level, rank, modifier, value, content_tag, meritid)
SELECT 25, 'shield mastery', 7, 1, 4, 485, 40, NULL, 0
WHERE NOT EXISTS (
    SELECT 1 FROM xidb.traits
    WHERE traitid = 25 AND job = 7 AND level = 1 AND rank = 4
);

UPDATE xidb.traits
SET
    name = 'shield mastery',
    modifier = 485,
    value = 40,
    content_tag = NULL,
    meritid = 0
WHERE traitid = 25
  AND job IN (1, 3, 5, 7)
  AND level = 1
  AND rank = 4;

COMMIT;
