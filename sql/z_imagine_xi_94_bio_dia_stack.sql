-- Bio and Dia can coexist on the same target.
-- Bio previously used negative_id = 134 (Dia), causing C++ to strip Dia on application.

UPDATE `status_effects`
SET `negative_id` = 135
WHERE `id` = 135;
