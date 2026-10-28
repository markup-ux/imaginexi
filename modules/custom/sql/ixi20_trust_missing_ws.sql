-- Imagine XI 2.0: combat trusts whose skill lists were empty placeholders.
-- Each kit matches the trust's job. Passive bubbles are left empty.
-- INSERT IGNORE keeps re-apply safe.

INSERT IGNORE INTO `mob_skill_lists` (`skill_list_name`, `skill_list_id`, `mob_skill_id`) VALUES
    ('TRUST_Shantotto', 1011, 178), -- Earth Crusher
    ('TRUST_Shantotto', 1011, 180), -- Sunburst
    ('TRUST_Shantotto', 1011, 189), -- Cataclysm
    ('TRUST_Ajido-Marujido', 1019, 178), -- Earth Crusher
    ('TRUST_Ajido-Marujido', 1019, 180), -- Sunburst
    ('TRUST_Ajido-Marujido', 1019, 183), -- Spirit Taker
    ('TRUST_Ajido-Marujido', 1019, 184), -- Retribution
    ('TRUST_Ajido-Marujido', 1019, 189), -- Cataclysm
    ('TRUST_Ajido-Marujido', 1019, 191), -- Shattersoul
    ('TRUST_Zeid', 1021, 51), -- Freezebite
    ('TRUST_Zeid', 1021, 56), -- Ground Strike
    ('TRUST_Zeid', 1021, 3195), -- Abyssal Drain
    ('TRUST_Zeid', 1021, 3196), -- Abyssal Strike
    ('TRUST_Joachim', 1026, 40), -- Vorpal Blade
    ('TRUST_Joachim', 1026, 42), -- Savage Blade
    ('TRUST_Ulmia', 1029, 40), -- Vorpal Blade
    ('TRUST_Ulmia', 1029, 42), -- Savage Blade
    ('TRUST_Gadalar', 1034, 178), -- Earth Crusher
    ('TRUST_Gadalar', 1034, 180), -- Sunburst
    ('TRUST_Gadalar', 1034, 189), -- Cataclysm
    ('TRUST_Ingrid', 1036, 166), -- True Strike
    ('TRUST_Ingrid', 1036, 168), -- Hexa Strike
    ('TRUST_Zazarg', 1039, 1), -- Combo
    ('TRUST_Zazarg', 1039, 7), -- Howling Fist
    ('TRUST_Zazarg', 1039, 9), -- Asuran Fists
    ('TRUST_Ovjang', 1040, 40), -- Vorpal Blade
    ('TRUST_Ovjang', 1040, 42), -- Savage Blade
    ('TRUST_Ovjang', 1040, 180), -- Sunburst
    ('TRUST_Luzaf', 1043, 210), -- Sniper Shot
    ('TRUST_Luzaf', 1043, 212), -- Slug Shot
    ('TRUST_Luzaf', 1043, 215), -- Detonator
    ('TRUST_Najelith', 1044, 192), -- Flaming Arrow
    ('TRUST_Najelith', 1044, 196), -- Sidewinder
    ('TRUST_Najelith', 1044, 199), -- Empyreal Arrow
    ('TRUST_Aldo', 1045, 1), -- Combo
    ('TRUST_Aldo', 1045, 7), -- Howling Fist
    ('TRUST_Aldo', 1045, 9), -- Asuran Fists
    ('TRUST_D_Shantotto', 1049, 178), -- Earth Crusher
    ('TRUST_D_Shantotto', 1049, 180), -- Sunburst
    ('TRUST_D_Shantotto', 1049, 189), -- Cataclysm
    ('TRUST_Cid', 1052, 210), -- Sniper Shot
    ('TRUST_Cid', 1052, 212), -- Slug Shot
    ('TRUST_Cid', 1052, 215), -- Detonator
    ('TRUST_Gilgamesh', 1053, 144), -- Tachi: Enpi
    ('TRUST_Gilgamesh', 1053, 150), -- Tachi: Yukikaze
    ('TRUST_Gilgamesh', 1053, 151), -- Tachi: Gekko
    ('TRUST_Gilgamesh', 1053, 152), -- Tachi: Kasha
    ('TRUST_Elivira', 1056, 192), -- Flaming Arrow
    ('TRUST_Elivira', 1056, 196), -- Sidewinder
    ('TRUST_Elivira', 1056, 199), -- Empyreal Arrow
    ('TRUST_Noillurie', 1057, 144), -- Tachi: Enpi
    ('TRUST_Noillurie', 1057, 150), -- Tachi: Yukikaze
    ('TRUST_Noillurie', 1057, 151), -- Tachi: Gekko
    ('TRUST_Noillurie', 1057, 152), -- Tachi: Kasha
    ('TRUST_Lhu_Mhakaracca', 1058, 64), -- Raging Axe
    ('TRUST_Lhu_Mhakaracca', 1058, 72), -- Decimation
    ('TRUST_Lilisette', 1060, 16), -- Wasp Sting
    ('TRUST_Lilisette', 1060, 23), -- Dancing Edge
    ('TRUST_Lilisette', 1060, 25), -- Evisceration
    ('TRUST_Klara', 1063, 40), -- Vorpal Blade
    ('TRUST_Klara', 1063, 42), -- Savage Blade
    ('TRUST_Klara', 1063, 88), -- Steel Cyclone
    ('TRUST_Romaa_Mihgo', 1064, 16), -- Wasp Sting
    ('TRUST_Romaa_Mihgo', 1064, 23), -- Dancing Edge
    ('TRUST_Romaa_Mihgo', 1064, 25), -- Evisceration
    ('TRUST_Koru-Moru', 1067, 40), -- Vorpal Blade
    ('TRUST_Koru-Moru', 1067, 42), -- Savage Blade
    ('TRUST_Koru-Moru', 1067, 180), -- Sunburst
    ('TRUST_Pieuje_UC', 1068, 166), -- True Strike
    ('TRUST_Pieuje_UC', 1068, 168), -- Hexa Strike
    ('TRUST_Invincible_Shield_UC', 1069, 40), -- Vorpal Blade
    ('TRUST_Invincible_Shield_UC', 1069, 42), -- Savage Blade
    ('TRUST_Invincible_Shield_UC', 1069, 88), -- Steel Cyclone
    ('TRUST_Jakoh_Wahcondalo_UC', 1071, 16), -- Wasp Sting
    ('TRUST_Jakoh_Wahcondalo_UC', 1071, 23), -- Dancing Edge
    ('TRUST_Jakoh_Wahcondalo_UC', 1071, 25), -- Evisceration
    ('TRUST_Flaviria_UC', 1072, 112), -- Double Thrust
    ('TRUST_Flaviria_UC', 1072, 118), -- Skewer
    ('TRUST_Flaviria_UC', 1072, 120), -- Impulse Drive
    ('TRUST_Babban', 1073, 1), -- Combo
    ('TRUST_Babban', 1073, 7), -- Howling Fist
    ('TRUST_Babban', 1073, 9), -- Asuran Fists
    ('TRUST_Abenzio', 1074, 1), -- Combo
    ('TRUST_Abenzio', 1074, 7), -- Howling Fist
    ('TRUST_Abenzio', 1074, 9), -- Asuran Fists
    ('TRUST_Kukki-Chebukki', 1076, 178), -- Earth Crusher
    ('TRUST_Kukki-Chebukki', 1076, 180), -- Sunburst
    ('TRUST_Kukki-Chebukki', 1076, 189), -- Cataclysm
    ('TRUST_Margret', 1077, 192), -- Flaming Arrow
    ('TRUST_Margret', 1077, 196), -- Sidewinder
    ('TRUST_Margret', 1077, 199), -- Empyreal Arrow
    ('TRUST_Chacharoon', 1078, 16), -- Wasp Sting
    ('TRUST_Chacharoon', 1078, 23), -- Dancing Edge
    ('TRUST_Chacharoon', 1078, 25), -- Evisceration
    ('TRUST_Lhe_Lhangavo', 1079, 1), -- Combo
    ('TRUST_Lhe_Lhangavo', 1079, 7), -- Howling Fist
    ('TRUST_Lhe_Lhangavo', 1079, 9), -- Asuran Fists
    ('TRUST_Arciela', 1080, 40), -- Vorpal Blade
    ('TRUST_Arciela', 1080, 42), -- Savage Blade
    ('TRUST_Arciela', 1080, 180), -- Sunburst
    ('TRUST_Mayakov', 1081, 16), -- Wasp Sting
    ('TRUST_Mayakov', 1081, 23), -- Dancing Edge
    ('TRUST_Mayakov', 1081, 25), -- Evisceration
    ('TRUST_Halver', 1087, 33), -- Burning Blade
    ('TRUST_Halver', 1087, 40), -- Vorpal Blade
    ('TRUST_Halver', 1087, 42), -- Savage Blade
    ('TRUST_Rongelouts', 1088, 40), -- Vorpal Blade
    ('TRUST_Rongelouts', 1088, 42), -- Savage Blade
    ('TRUST_Rongelouts', 1088, 88), -- Steel Cyclone
    ('TRUST_Leonoyne', 1089, 178), -- Earth Crusher
    ('TRUST_Leonoyne', 1089, 180), -- Sunburst
    ('TRUST_Leonoyne', 1089, 189), -- Cataclysm
    ('TRUST_Maximilian', 1090, 16), -- Wasp Sting
    ('TRUST_Maximilian', 1090, 23), -- Dancing Edge
    ('TRUST_Maximilian', 1090, 25), -- Evisceration
    ('TRUST_Kayeel-Payeel', 1091, 178), -- Earth Crusher
    ('TRUST_Kayeel-Payeel', 1091, 180), -- Sunburst
    ('TRUST_Kayeel-Payeel', 1091, 189), -- Cataclysm
    ('TRUST_Robel-Akbel', 1092, 178), -- Earth Crusher
    ('TRUST_Robel-Akbel', 1092, 180), -- Sunburst
    ('TRUST_Robel-Akbel', 1092, 189), -- Cataclysm
    ('TRUST_Yoran-Oran_UC', 1095, 166), -- True Strike
    ('TRUST_Yoran-Oran_UC', 1095, 168), -- Hexa Strike
    ('TRUST_Sylvie_UC', 1096, 178), -- Earth Crusher
    ('TRUST_Sylvie_UC', 1096, 180), -- Sunburst
    ('TRUST_Sylvie_UC', 1096, 189), -- Cataclysm
    ('TRUST_Balamor', 1098, 96), -- Slice
    ('TRUST_Balamor', 1098, 102), -- Guillotine
    ('TRUST_Balamor', 1098, 103), -- Cross Reaper
    ('TRUST_Rosulatia', 1100, 178), -- Earth Crusher
    ('TRUST_Rosulatia', 1100, 180), -- Sunburst
    ('TRUST_Rosulatia', 1100, 189), -- Cataclysm
    ('TRUST_Teodor', 1101, 178), -- Earth Crusher
    ('TRUST_Teodor', 1101, 180), -- Sunburst
    ('TRUST_Teodor', 1101, 189), -- Cataclysm
    ('TRUST_Ullegore', 1102, 178), -- Earth Crusher
    ('TRUST_Ullegore', 1102, 180), -- Sunburst
    ('TRUST_Ullegore', 1102, 189), -- Cataclysm
    ('TRUST_Makki-Chebukki', 1103, 192), -- Flaming Arrow
    ('TRUST_Makki-Chebukki', 1103, 196), -- Sidewinder
    ('TRUST_Makki-Chebukki', 1103, 199), -- Empyreal Arrow
    ('TRUST_King_of_Hearts', 1104, 40), -- Vorpal Blade
    ('TRUST_King_of_Hearts', 1104, 42), -- Savage Blade
    ('TRUST_King_of_Hearts', 1104, 180), -- Sunburst
    ('TRUST_Morimar', 1105, 64), -- Raging Axe
    ('TRUST_Morimar', 1105, 72), -- Decimation
    ('TRUST_Iroha', 1112, 144), -- Tachi: Enpi
    ('TRUST_Iroha', 1112, 150), -- Tachi: Yukikaze
    ('TRUST_Iroha', 1112, 151), -- Tachi: Gekko
    ('TRUST_Iroha', 1112, 152), -- Tachi: Kasha
    ('TRUST_Ygnas', 1113, 166), -- True Strike
    ('TRUST_Ygnas', 1113, 168), -- Hexa Strike
    ('TRUST_Monberaux', 1114, 33), -- Burning Blade
    ('TRUST_Monberaux', 1114, 40), -- Vorpal Blade
    ('TRUST_Monberaux', 1114, 42), -- Savage Blade
    ('TRUST_Excenmille_S', 1119, 40), -- Vorpal Blade
    ('TRUST_Excenmille_S', 1119, 42), -- Savage Blade
    ('TRUST_Excenmille_S', 1119, 88), -- Steel Cyclone
    ('TRUST_Ayame_UC', 1120, 144), -- Tachi: Enpi
    ('TRUST_Ayame_UC', 1120, 150), -- Tachi: Yukikaze
    ('TRUST_Ayame_UC', 1120, 151), -- Tachi: Gekko
    ('TRUST_Ayame_UC', 1120, 152), -- Tachi: Kasha
    ('TRUST_Aldo_UC', 1122, 16), -- Wasp Sting
    ('TRUST_Aldo_UC', 1122, 23), -- Dancing Edge
    ('TRUST_Aldo_UC', 1122, 25), -- Evisceration
    ('TRUST_Naja_Salaheem_UC', 1123, 16), -- Wasp Sting
    ('TRUST_Naja_Salaheem_UC', 1123, 23), -- Dancing Edge
    ('TRUST_Naja_Salaheem_UC', 1123, 25), -- Evisceration
    ('TRUST_Lilisette_II', 1128, 16), -- Wasp Sting
    ('TRUST_Lilisette_II', 1128, 23), -- Dancing Edge
    ('TRUST_Lilisette_II', 1128, 25), -- Evisceration
    ('TRUST_Mumor_II', 1130, 178), -- Earth Crusher
    ('TRUST_Mumor_II', 1130, 180), -- Sunburst
    ('TRUST_Mumor_II', 1130, 189), -- Cataclysm
    ('TRUST_Ingrid_II', 1131, 166), -- True Strike
    ('TRUST_Ingrid_II', 1131, 168), -- Hexa Strike
    ('TRUST_Arciela_II', 1132, 40), -- Vorpal Blade
    ('TRUST_Arciela_II', 1132, 42), -- Savage Blade
    ('TRUST_Arciela_II', 1132, 180), -- Sunburst
    ('TRUST_Iroha_II', 1133, 144), -- Tachi: Enpi
    ('TRUST_Iroha_II', 1133, 150), -- Tachi: Yukikaze
    ('TRUST_Iroha_II', 1133, 151), -- Tachi: Gekko
    ('TRUST_Iroha_II', 1133, 152); -- Tachi: Kasha
