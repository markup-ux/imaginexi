-- Feature: Summoner Blood Pact progression (support-leaning early)
-- Goals:
-- - Keep all SMN blood pact unlocks usable by level 37.
-- - Front-load supportive/party utility pacts earlier in leveling.
-- - Preserve stronger offensive capstones for later tiers.

START TRANSACTION;

-- SMN command/utility abilities
UPDATE xidb.abilities
SET level = CASE abilityId
    WHEN 232 THEN 4 -- elemental_siphon
    WHEN 250 THEN 28 -- avatars_favor
    WHEN 296 THEN 4 -- mana_cede
    WHEN 337 THEN 28 -- astral_conduit
    WHEN 385 THEN 28 -- apogee
    ELSE level
END
WHERE job = 15
  AND abilityId IN (232, 250, 296, 337, 385);

-- SMN Blood Pact ability progression
UPDATE xidb.abilities
SET level = CASE abilityId
    WHEN 512 THEN 6  -- healing_ruby
    WHEN 513 THEN 6  -- poison_nails
    WHEN 514 THEN 6 -- shining_ruby
    WHEN 515 THEN 6 -- glittering_ruby
    WHEN 516 THEN 8 -- meteorite
    WHEN 517 THEN 21 -- healing_ruby_ii
    WHEN 519 THEN 23 -- holy_mist
    WHEN 520 THEN 15 -- soothing_ruby
    WHEN 521 THEN 1  -- regal_scratch
    WHEN 522 THEN 12 -- mewing_lullaby
    WHEN 523 THEN 21 -- eerie_eye
    WHEN 524 THEN 25 -- level_X_holy
    WHEN 527 THEN 28 -- altana_s_favor
    WHEN 528 THEN 13 -- moonlit_charge
    WHEN 529 THEN 13 -- crescent_fang
    WHEN 530 THEN 10 -- lunar_cry
    WHEN 531 THEN 12 -- lunar_roar
    WHEN 532 THEN 10 -- ecliptic_growl
    WHEN 533 THEN 10 -- ecliptic_howl
    WHEN 534 THEN 17 -- eclipse_bite
    WHEN 537 THEN 29 -- lunar_bay
    WHEN 538 THEN 28 -- heavenward_howl
    WHEN 539 THEN 26 -- impact
    WHEN 544 THEN 8  -- punch
    WHEN 545 THEN 4 -- fire_ii
    WHEN 546 THEN 13 -- burning_strike
    WHEN 547 THEN 12 -- double_punch
    WHEN 548 THEN 10 -- crimson_howl
    WHEN 549 THEN 23 -- fire_iv
    WHEN 550 THEN 23 -- flaming_crush
    WHEN 551 THEN 26 -- meteor_strike
    WHEN 553 THEN 28 -- inferno_howl
    WHEN 554 THEN 26 -- conflag_strike
    WHEN 560 THEN 8  -- rock_throw
    WHEN 561 THEN 4 -- stone_ii
    WHEN 562 THEN 13 -- rock_buster
    WHEN 563 THEN 13 -- megalith_throw
    WHEN 564 THEN 10 -- earthen_ward
    WHEN 565 THEN 23 -- stone_iv
    WHEN 566 THEN 17 -- mountain_buster
    WHEN 567 THEN 23 -- geocrush
    WHEN 569 THEN 15 -- earthen_armor
    WHEN 570 THEN 37 -- crag_throw
    WHEN 576 THEN 8  -- barracuda_dive
    WHEN 577 THEN 4 -- water_ii
    WHEN 578 THEN 13 -- tail_whip
    WHEN 579 THEN 15 -- spring_water
    WHEN 580 THEN 12 -- slowga
    WHEN 581 THEN 23 -- water_iv
    WHEN 582 THEN 17 -- spinning_dive
    WHEN 583 THEN 23 -- grand_fall
    WHEN 585 THEN 31 -- tidal_roar
    WHEN 586 THEN 21 -- soothing_current
    WHEN 592 THEN 8  -- claw
    WHEN 593 THEN 4 -- aero_ii
    WHEN 594 THEN 15 -- whispering_wind
    WHEN 595 THEN 15 -- hastega
    WHEN 596 THEN 15 -- aerial_armor
    WHEN 597 THEN 23 -- aero_iv
    WHEN 598 THEN 17 -- predator_claws
    WHEN 599 THEN 23 -- wind_blade
    WHEN 601 THEN 28 -- fleet_wind
    WHEN 602 THEN 21 -- hastega_ii
    WHEN 608 THEN 1  -- axe_kick
    WHEN 609 THEN 4 -- blizzard_ii
    WHEN 610 THEN 10 -- frost_armor
    WHEN 611 THEN 12 -- sleepga
    WHEN 612 THEN 13 -- double_slap
    WHEN 613 THEN 23 -- blizzard_iv
    WHEN 614 THEN 17 -- rush
    WHEN 615 THEN 17 -- heavenly_strike
    WHEN 617 THEN 12 -- diamond_storm
    WHEN 618 THEN 21 -- crystal_blessing
    WHEN 624 THEN 1  -- shock_strike
    WHEN 625 THEN 4 -- thunder_ii
    WHEN 626 THEN 10 -- rolling_thunder
    WHEN 627 THEN 8 -- thunderspark
    WHEN 628 THEN 10 -- lightning_armor
    WHEN 629 THEN 23 -- thunder_iv
    WHEN 630 THEN 17 -- chaotic_strike
    WHEN 631 THEN 23 -- thunderstorm
    WHEN 633 THEN 12 -- shock_squall
    WHEN 634 THEN 26 -- volt_strike
    WHEN 656 THEN 1 -- camisado
    WHEN 657 THEN 25 -- somnolence
    WHEN 658 THEN 12 -- nightmare
    WHEN 659 THEN 26 -- ultimate_terror
    WHEN 660 THEN 15 -- noctoshield
    WHEN 661 THEN 21 -- dream_shroud
    WHEN 662 THEN 25 -- nether_blast
    WHEN 664 THEN 26 -- ruinous_omen
    WHEN 665 THEN 25 -- night_terror
    WHEN 666 THEN 25 -- pavor_nocturnus
    WHEN 667 THEN 37 -- blindside
    WHEN 773 THEN 37 -- pacifying_ruby
    WHEN 960 THEN 28 -- clarsach_call
    WHEN 961 THEN 1 -- welt
    WHEN 964 THEN 10 -- roundhouse
    WHEN 967 THEN 25 -- sonic_buffet
    WHEN 968 THEN 28 -- tornado_ii
    WHEN 970 THEN 37 -- hysteric_assault
    ELSE level
END
WHERE job = 15
  AND abilityId IN (
      512,513,514,515,516,517,519,520,521,522,523,524,527,528,529,530,531,532,533,534,537,538,539,
      544,545,546,547,548,549,550,551,553,554,560,561,562,563,564,565,566,567,569,570,576,577,578,
      579,580,581,582,583,585,586,592,593,594,595,596,597,598,599,601,602,608,609,610,611,612,613,
      614,615,617,618,624,625,626,627,628,629,630,631,633,634,656,657,658,659,660,661,662,664,665,
      666,667,773,960,961,964,967,968,970
  );

-- SMN summon spell progression for spell_list was authored for a legacy schema
-- with per-job columns. Current schema stores jobs in a packed `jobs` field, so
-- this step is intentionally skipped to keep dbtool update compatible.

COMMIT;
