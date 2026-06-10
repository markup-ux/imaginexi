-- Fix starter gear item_basic.type: must be 6 (equipment) or 7 (weapon), not 1 (general).

-- Wrong type loads CItemGeneral; equip packets silently fail because items are not equipment.



SET NAMES utf8mb4;



UPDATE `item_basic` SET `type` = 6 WHERE `itemid` IN (

    12631,12632,12633,12634,12635,12636,12637,

    12754,12755,12756,12757,12758,12759,12760,

    12883,12884,12885,12886,12887,12888,12889,

    13005,13006,13007,13008,13009,13010,13011,

    13086,13184,13495,13496,13497

);



UPDATE `item_basic` SET `type` = 7 WHERE `itemid` IN (

    16482,16483,16534,17068,17104

);


