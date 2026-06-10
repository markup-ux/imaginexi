-- Restores item_basic rows required for racial starter gear + job starter weapons.

-- item_equipment / item_weapon / item_mods already reference these IDs; without

-- item_basic, xi_map logs "AddItem: Item <id> is not found in a database".

--

-- Flags (numeric): MYSTERY_BOX 4, CAN_SEND_ACCT 16, CANEQUIP 2048, NOSALE 4096, EX 16384

-- Item types: EQUIPMENT 6, WEAPON 7 (not GENERAL 1 — general items cannot be equipped)

-- AH categories: BODY 18, HANDS 19, LEGS 20, FEET 21, WAIST 23, RINGS 25

--                DAGGER 2, SWORD 3, CLUB 11, STAFF 12



SET NAMES utf8mb4;



REPLACE INTO `item_basic` (`itemid`,`subid`,`name`,`sortname`,`name_jp`,`type`,`stackSize`,`flags`,`aH`,`BaseSell`) VALUES

(12631,0,'hume_tunic','hume_tunic','ヒュームチュニック',6,1,22544,18,0),

(12632,0,'hume_vest','hume_vest','ヒュームベスト',6,1,22544,18,0),

(12633,0,'elvaan_jerkin','elvaan_jerkin','エルヴジャーキン',6,1,22544,18,0),

(12634,0,'elvaan_bodice','elvaan_bodice','エルヴボディス',6,1,22544,18,0),

(12635,0,'tarutaru_kaftan','tarutaru_kaftan','タルタルカフタン',6,1,22544,18,0),

(12636,0,'mithran_separates','mithran_separates','ミスラセパレーツ',6,1,22544,18,0),

(12637,0,'galkan_surcoat','galkan_surcoat','ガルカサーコート',6,1,22544,18,0),

(12754,0,'hume_m_gloves','hume_m_gloves','ヒュームＭグローブ',6,1,22544,19,0),

(12755,0,'elvaan_gloves','elvaan_gloves','エルヴガントレット',6,1,22544,19,0),

(12756,0,'tarutaru_mitts','tarutaru_mitts','タルタルミトン',6,1,22544,19,0),

(12757,0,'mithran_gauntlets','mithran_gauntlets','ミスラガントレット',6,1,22544,19,0),

(12758,0,'galkan_bracers','galkan_bracers','ガルカブレーサー',6,1,22544,19,0),

(12759,0,'elvaan_gauntlets','elvaan_gauntlets','エルヴグローブ',6,1,22544,19,0),

(12760,0,'hume_f_gloves','hume_f_gloves','ヒュームＦグローブ',6,1,22544,19,0),

(12883,0,'hume_slacks','hume_slacks','ヒュームズボン',6,1,22544,20,0),

(12884,0,'hume_pants','hume_pants','ヒュームパンツ',6,1,22544,20,0),

(12885,0,'elvaan_m_chausses','elv._m_chausses','エルヴＭショウス',6,1,22544,20,0),

(12886,0,'tarutaru_braccae','tarutaru_braccae','タルタルブラッカエ',6,1,22544,20,0),

(12887,0,'mithran_loincloth','mithran_loincloth','ミスラロインクロス',6,1,22544,20,0),

(12888,0,'galkan_braguette','galkan_braguette','ガルカブラケット',6,1,22544,20,0),

(12889,0,'elvaan_f_chausses','elvaan_f_chausses','エルヴＦショウス',6,1,22544,20,0),

(13005,0,'hume_m_boots','hume_m_boots','ヒュームＭブーツ',6,1,22544,21,0),

(13006,0,'elvaan_m_ledelsens','elv._m_ledelsens','エルヴＭレデルセン',6,1,22544,21,0),

(13007,0,'tarutaru_clomps','tarutaru_clomps','タルタルクロンプ',6,1,22544,21,0),

(13008,0,'mithran_gaiters','mithran_gaiters','ミスラゲートル',6,1,22544,21,0),

(13009,0,'galkan_sandals','galkan_sandals','ガルカサンダル',6,1,22544,21,0),

(13010,0,'hume_f_boots','hume_f_boots','ヒュームＦブーツ',6,1,22544,21,0),

(13011,0,'elvaan_f_ledelsens','elv._f_ledelsens','エルヴＦレデルセン',6,1,22544,21,0),

(13184,0,'white_belt','white_belt','白帯',6,1,6148,23,0),

(13495,0,'san_dorian_ring','san_dorian_ring','サンドリアリング',6,1,22544,25,0),

(13496,0,'windurstian_ring','windurstian_ring','ウィンダスリング',6,1,22544,25,0),

(13497,0,'bastokan_ring','bastokan_ring','バストゥークリング',6,1,22544,25,0),

(16482,0,'onion_dagger','onion_dagger','オニオンダガー',7,1,6148,2,0),

(16483,0,'onion_knife','onion_knife','オニオンナイフ',7,1,6148,2,0),

(16534,0,'onion_sword','onion_sword','オニオンソード',7,1,6148,3,0),

(17068,0,'onion_rod','onion_rod','オニオンロッド',7,1,6148,11,0),

(17104,0,'onion_staff','onion_staff','オニオンスタッフ',7,1,6148,12,0);


