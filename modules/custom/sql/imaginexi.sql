

-- dual wield (max rank for every job at level 1; keep in sync with server/sql/traits.sql)
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (18,'dual wield',1,1,5,259,35,NULL,0),
  (18,'dual wield',2,1,5,259,35,NULL,0),
  (18,'dual wield',3,1,5,259,35,NULL,0),
  (18,'dual wield',4,1,5,259,35,NULL,0),
  (18,'dual wield',5,1,5,259,35,NULL,0),
  (18,'dual wield',6,1,5,259,35,NULL,0),
  (18,'dual wield',7,1,5,259,35,NULL,0),
  (18,'dual wield',8,1,5,259,35,NULL,0),
  (18,'dual wield',9,1,5,259,35,NULL,0),
  (18,'dual wield',10,1,5,259,35,NULL,0),
  (18,'dual wield',11,1,5,259,35,NULL,0),
  (18,'dual wield',12,1,5,259,35,NULL,0),
  (18,'dual wield',13,1,5,259,35,NULL,0),
  (18,'dual wield',14,1,5,259,35,NULL,0),
  (18,'dual wield',15,1,5,259,35,NULL,0),
  (18,'dual wield',16,1,5,259,35,NULL,0),
  (18,'dual wield',17,1,5,259,35,NULL,0),
  (18,'dual wield',18,1,5,259,35,NULL,0),
  (18,'dual wield',19,1,5,259,35,NULL,0),
  (18,'dual wield',20,1,5,259,35,NULL,0),
  (18,'dual wield',21,1,5,259,35,NULL,0),
  (18,'dual wield',22,1,5,259,35,NULL,0),
  (18,'dual wield',23,1,5,259,35,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), `level`=VALUES(`level`), `rank`=VALUES(`rank`), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

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

-- auto refresh (traitid 10)  <<< this is the one that tripped the error
INSERT INTO xidb.traits (traitid,name,job,`level`,`rank`,modifier,value,content_tag,meritid) VALUES
  (10,'auto refresh',3,1,2,369,3,NULL,0),
  (10,'auto refresh',4,1,2,369,3,NULL,0),
  (10,'auto refresh',5,1,2,369,3,NULL,0),
  (10,'auto refresh',7,1,2,369,3,NULL,0),
  (10,'auto refresh',8,1,2,369,3,NULL,0),
  (10,'auto refresh',15,1,2,369,3,NULL,0),
  (10,'auto refresh',16,1,2,369,3,NULL,0),
  (10,'auto refresh',20,1,2,369,3,NULL,0),
  (10,'auto refresh',21,1,2,369,3,NULL,0),
  (10,'auto refresh',22,1,2,369,3,NULL,0)
ON DUPLICATE KEY UPDATE
  name=VALUES(name), value=VALUES(value), content_tag=VALUES(content_tag), meritid=VALUES(meritid);

-- clear mind (traitid 24)
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

-- conserve mp (traitid 13)
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

-- fast cast (traitid 12)
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

-- end mage traits	 



-- Weapon, ranged, and H2H: A+ for every job (pairs with all-weapons + auto-cap)
UPDATE xidb.skill_ranks
SET war = 1, mnk = 1, whm = 1, blm = 1, rdm = 1, thf = 1,
    pld = 1, drk = 1, bst = 1, brd = 1, rng = 1, sam = 1,
    nin = 1, drg = 1, smn = 1, blu = 1, cor = 1, pup = 1,
    dnc = 1, sch = 1, geo = 1, run = 1
WHERE skillid IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 25, 26, 27);

UPDATE xidb.skill_ranks
SET name = 'guarding',
    war = 0, mnk = 1, whm = 0, blm = 0, rdm = 0, thf = 0,
    pld = 0, drk = 0, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 5, pup = 1,
    dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 28;

UPDATE xidb.skill_ranks
SET name = 'evasion',
    war = 7, mnk = 3, whm = 10, blm = 10, rdm = 9, thf = 1,
    pld = 7, drk = 7, bst = 7, brd = 9, rng = 10, sam = 3,
    nin = 2, drg = 4, smn = 10, blu = 8, cor = 9, pup = 4,
    dnc = 3, sch = 10, geo = 9, run = 3
WHERE skillid = 29;

UPDATE xidb.skill_ranks
SET name = 'shield',
    war = 1, mnk = 0, whm = 1, blm = 0, rdm = 1, thf = 1,
    pld = 1, drk = 1, bst = 10, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0,
    dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 30;

UPDATE xidb.skill_ranks
SET name = 'parrying',
    war = 8, mnk = 10, whm = 0, blm = 0, rdm = 10, thf = 2,
    pld = 7, drk = 10, bst = 7, brd = 10, rng = 0, sam = 2,
    nin = 2, drg = 5, smn = 0, blu = 9, cor = 2, pup = 9,
    dnc = 4, sch = 10, geo = 10, run = 1
WHERE skillid = 31;

UPDATE xidb.skill_ranks
SET name = 'divine',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0,
    pld = 1, drk = 1, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 1, blu = 1, cor = 0, pup = 0,
    dnc = 0, sch = 1, geo = 1, run = 1
WHERE skillid = 32;

UPDATE xidb.skill_ranks
SET name = 'healing',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0,
    pld = 1, drk = 1, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 1, blu = 1, cor = 1, pup = 0,
    dnc = 0, sch = 1, geo = 1, run = 1
WHERE skillid = 33;

UPDATE xidb.skill_ranks
SET name = 'enhancing',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0,
    pld = 1, drk = 1, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 1, blu = 1, cor = 1, pup = 0,
    dnc = 0, sch = 1, geo = 1, run = 1
WHERE skillid = 34;

UPDATE xidb.skill_ranks
SET name = 'enfeebling',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0,
    pld = 1, drk = 1, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 1, drg = 0, smn = 1, blu = 1, cor = 1, pup = 0,
    dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 35;

UPDATE xidb.skill_ranks
SET name = 'elemental',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0,
    pld = 1, drk = 1, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 1, drg = 0, smn = 1, blu = 1, cor = 0, pup = 0,
    dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 36;

UPDATE xidb.skill_ranks
SET name = 'dark',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0,
    pld = 1, drk = 1, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 1, drg = 0, smn = 1, blu = 1, cor = 0, pup = 0,
    dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 37;

UPDATE xidb.skill_ranks
SET name = 'summoning',
    war = 0, mnk = 0, whm = 1, blm = 1, rdm = 1, thf = 0,
    pld = 0, drk = 0, bst = 0, brd = 0, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 1, blu = 1, cor = 0, pup = 0,
    dnc = 0, sch = 1, geo = 1, run = 0
WHERE skillid = 38;

UPDATE xidb.skill_ranks
SET name = 'ninjutsu',
    war = 1, mnk = 1, whm = 1, blm = 1, rdm = 1, thf = 1,
    pld = 1, drk = 1, bst = 1, brd = 1, rng = 1, sam = 1,
    nin = 1, drg = 1, smn = 1, blu = 1, cor = 1, pup = 1,
    dnc = 1, sch = 1, geo = 1, run = 1
WHERE skillid = 39;

UPDATE xidb.skill_ranks
SET name = 'singing',
    war = 0, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0,
    pld = 0, drk = 0, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0,
    dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 40;

UPDATE xidb.skill_ranks
SET name = 'string',
    war = 0, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0,
    pld = 0, drk = 0, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0,
    dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 41;

UPDATE xidb.skill_ranks
SET name = 'wind',
    war = 0, mnk = 0, whm = 0, blm = 0, rdm = 0, thf = 0,
    pld = 0, drk = 0, bst = 0, brd = 1, rng = 0, sam = 0,
    nin = 0, drg = 0, smn = 0, blu = 0, cor = 0, pup = 0,
    dnc = 0, sch = 0, geo = 0, run = 0
WHERE skillid = 42;







