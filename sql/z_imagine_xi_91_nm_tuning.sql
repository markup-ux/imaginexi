-- Feature: NM tuning

-- === Orthrus: attach Cerberus TP list ===
START TRANSACTION;

UPDATE mob_pools
SET skill_list_id = 62      -- Cerberus list id from mob_skill_lists
WHERE name = 'Orthrus';

COMMIT;

-- === Orthrus: give real NM levels & HP (zone 218 Abyssea-Altepa) ===
START TRANSACTION;

-- Levels are stored on spawn points in this schema; HP is on mob_groups.
UPDATE mob_spawn_points
SET minLevel = 90,
    maxLevel = 92
WHERE groupid = (
    SELECT groupid
    FROM mob_groups
    WHERE zoneid = 218 AND name = 'Orthrus'
    LIMIT 1
);

UPDATE mob_groups
SET HP = 35000           -- adjust to taste or remove if your schema auto-scales HP
WHERE zoneid = 218 AND name = 'Orthrus';

COMMIT;
