-- Feature: AF1 progression and identity pass (ImagineXI)
-- Source: AF1_DETAILED_SUGGESTIONS_IMAGINEXI.md
--
-- Merged into canonical data (fresh import path):
--   - server/sql/item_equipment.sql (AF1 armor Lv 50 incl. SAM Myochin; AF1 weapons Lv 40)
--   - server/sql/item_mods.sql (COR hands, PUP body, AF1 weapon role mods)
--   - server/scripts/globals/gear_sets.lua (ImagineXI AF1 set IDs 134-171 + NIN Anju/Zushio [173])
--
-- Legacy operator-only deltas below (xidb); safe to skip if using merged SQL above.
-- Scope originally implemented:
-- 1) Normalize AF1 armor equip levels to 50 (excluding Saotome policy-tbd section).
-- 2) Normalize AF1 weapon equip levels to 40.
-- 3) Priority identity fixes:
--    - COR hands (14929): remove off-theme learn mod usage and add COR core stats.
--    - PUP body  (14523): add automaton/repair identity stats.

START TRANSACTION;

-- AF1 armor at level 50
UPDATE xidb.item_equipment
SET level = 50
WHERE itemid IN (
    12511,12638,13961,14214,14089, -- WAR
    12512,12639,13962,14215,14090, -- MNK
    13855,12640,13963,14216,14091, -- WHM
    13856,12641,13964,14217,14092, -- BLM
    12513,12642,13965,14218,14093, -- RDM
    12514,12643,13966,14219,14094, -- THF
    12515,12644,13967,14220,14095, -- PLD
    12516,12645,13968,14221,14096, -- DRK
    12517,12646,13969,14222,14097, -- BST
    13857,12647,13970,14223,14098, -- BRD
    12518,12648,13971,14224,14099, -- RNG
    13868,13781,13972,14225,14100, -- SAM (Myochin)
    13869,13782,13973,14226,14101, -- NIN
    12519,12649,13974,14227,14102, -- DRG
    12520,12650,13975,14228,14103, -- SMN
    15265,14521,14928,15600,15684, -- BLU
    15266,14522,14929,15601,15685, -- COR
    15267,14523,14930,15602,15686, -- PUP
    16138,16139,14578,14579,15002,15003,15659,15660,15746,15747 -- DNC (+1 variants)
);

-- AF1 weapons at level 40
UPDATE xidb.item_equipment
SET level = 40
WHERE itemid IN (
    16678,17478,17422,17423,16829,16764,17643,16798,16680,16766,
    17188,17812,17771,17772,16887,17532,17717,18702,17858,19203
);

-- COR hands 14929: remove off-theme Blue-magic learn chance if present and add COR-relevant mods.
DELETE FROM xidb.item_mods
WHERE itemId = 14929
  AND modId IN (122, 945); -- BLUE / BLUE_LEARN_CHANCE

DELETE FROM xidb.item_mods
WHERE itemId = 14929
  AND modId IN (26, 191, 411, 881); -- RACC / QUICK_DRAW_MACC / QUICK_DRAW_DMG / PHANTOM_ROLL

INSERT INTO xidb.item_mods (itemId, modId, value) VALUES
    (14929, 26, 10),   -- RACC +10
    (14929, 191, 5),   -- QUICK_DRAW_MACC +5
    (14929, 411, 5),   -- QUICK_DRAW_DMG +5
    (14929, 881, 1);   -- PHANTOM_ROLL +1

-- PUP body 14523: reinforce automaton/repair identity.
DELETE FROM xidb.item_mods
WHERE itemId = 14523
  AND modId IN (991, 854, 505); -- PET_ACC_EVA / REPAIR_POTENCY / OVERLOAD_THRESH

INSERT INTO xidb.item_mods (itemId, modId, value) VALUES
    (14523, 991, 10),  -- PET_ACC_EVA +10
    (14523, 854, 10),  -- REPAIR_POTENCY +10%
    (14523, 505, 5);   -- OVERLOAD_THRESH +5

COMMIT;
