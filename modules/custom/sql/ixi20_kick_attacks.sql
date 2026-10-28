-- Imagine XI 2.0: Monk kick attack rate.
-- Apply after ixi20_job_progression_37cap.sql. Revert with ixi20_REVERT.sql
-- on xidb_ixi20 only (traits restore from ixi20_traits_backup).
--
-- Subjob level is at most half of main (map.SUBJOB_RATIO = 1, main 75 -> sub 37),
-- so the level 38 rank is main Monk only. Higher rank replaces the lower one.
-- Footwork still adds 20%. The proc caps at 100%. Kicks only happen while H2H.
-- Monk mobs and trusts use the same trait rows.

DELETE FROM `traits` WHERE `traitid` = 66 AND `job` = 2;

INSERT INTO `traits` (`traitid`,`name`,`job`,`level`,`rank`,`modifier`,`value`,`content_tag`,`meritid`) VALUES
  (66,'kick attacks',2,1,1,292,25,NULL,0),
  (66,'kick attacks',2,38,2,292,50,NULL,0);
