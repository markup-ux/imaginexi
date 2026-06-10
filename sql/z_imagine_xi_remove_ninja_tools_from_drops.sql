-- Remove ninja tools and toolbags from mob drop tables (idempotent).
-- Run after importing base mob_droplist; safe if no rows match.

DELETE FROM `mob_droplist`
WHERE `itemId` IN (
    1161, 1164, 1167, 1170, 1173, 1176, 1179, 1182, 1185, 1188, 1191, 1194,
    2553, 2555, 2642, 2643, 2644,
    2970, 2971, 2972, 2973,
    5308, 5309, 5310, 5311, 5312, 5313, 5314, 5315, 5316, 5317, 5318, 5319,
    5417, 5734,
    5863, 5864, 5865, 5866, 5867, 5868, 5869,
    6265, 6266,
    8803, 8804
);
