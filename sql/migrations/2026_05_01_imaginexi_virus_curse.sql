-- Imagine XI: Virus/Curse player cast + behavior
-- Run on existing DBs; matches server/sql/spell_list.sql seed data.

UPDATE `spell_list`
SET `jobs` = 0x000000141900001E00000000000000000000001E2300
WHERE `spellid` = 256;

UPDATE `spell_list`
SET `jobs` = 0x0000002D000000250000000000000000000000000000
WHERE `spellid` = 257;
