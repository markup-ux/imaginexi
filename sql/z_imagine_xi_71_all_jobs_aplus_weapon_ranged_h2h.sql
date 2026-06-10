-- Feature: A+ weapon, ranged, and hand-to-hand skill ranks for all jobs
--
-- Completes the all-weapons experiment: any job that equips a weapon can train and
-- auto-cap that weapon/ranged/H2H skill at the A+ ceiling (276 at level 75).
-- Defensive skills (guard, evasion, shield, parry) and magic schools keep retail ranks.
--
-- Idempotent: rerunning keeps the same final state.
UPDATE xidb.skill_ranks
SET war = 1, mnk = 1, whm = 1, blm = 1, rdm = 1, thf = 1,
    pld = 1, drk = 1, bst = 1, brd = 1, rng = 1, sam = 1,
    nin = 1, drg = 1, smn = 1, blu = 1, cor = 1, pup = 1,
    dnc = 1, sch = 1, geo = 1, run = 1
WHERE skillid IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 25, 26, 27);
