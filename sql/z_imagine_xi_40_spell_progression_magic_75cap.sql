-- Feature: Magic spell progression 75-cap remap (no trusts)
-- Source: SPELL_LEVEL_CONFIRMATION_MAGIC_ONLY_NO_TRUSTS.md
-- Scope:
-- - Only spells listed with "current > 75 | suggested 75"
-- - Only player magic progression columns (no trust spell entries)

START TRANSACTION;

-- NOTE: Legacy per-job spell columns (whm/blm/pld/...) are not present in this
-- schema. Progression is encoded in packed job flags, so this migration is
-- intentionally skipped for compatibility.

COMMIT;
