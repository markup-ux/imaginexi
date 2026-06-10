-- Feature: Pixie Rescue
-- Extracted high-confidence SQL deltas:
-- - LightSpirit gets hastega (spell 358) at all levels for Pixie support behavior.
--
-- Source marker in core SQL:
-- - sql/mob_spell_lists.sql (comment: "WHM Pixie party support at all levels")

DELETE FROM `mob_spell_lists`
WHERE `spell_list_name` = 'LightSpirit'
  AND `spell_list_id` = 210
  AND `spell_id` = 358;

INSERT INTO `mob_spell_lists` (`spell_list_name`, `spell_list_id`, `spell_id`, `min_level`, `max_level`)
VALUES ('LightSpirit', 210, 358, 1, 255);
