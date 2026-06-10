-- Feature: Magic spell progression 37-cap (main 75 / sub 37 full kit)
-- Source: SPELL_PROGRESSION_37CAP_DRAFT.md
-- Scope: Magic spell groups 1-7 (BLU included; auto-learn via level gates)
--
-- MERGED INTO server/sql/spell_list.sql for fresh imports.
-- Re-run tools/scripts/apply_spell_37cap_compression.py to refresh merged data.
--
START TRANSACTION;
-- No standalone UPDATE statements: progression lives in packed `jobs` bytes.
COMMIT;
