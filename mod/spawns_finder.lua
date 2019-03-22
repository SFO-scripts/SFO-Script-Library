local spawn_finder = {} 
--# assume spawn_finder: SPAWN_FINDER

local LOG_FINDER = true


--v function(text: any)
local function LOG(text)
    if (not __write_output_to_logfile) or (not LOG_FINDER) then
        return; 
    end

    local logText = tostring(text)
    local popLog = io.open("SPAWN_FINDER.txt","a")
    popLog :write(logText)
    popLog :flush()
    popLog :close()
end


--v function(ax: number, ay: number, bx: number, by: number) --> number
local function distance_2D(ax, ay, bx, by)
    return (((bx - ax) ^ 2 + (by - ay) ^ 2) ^ 0.5);
end;

local SPAWNER_STARTS = {
    ["wh_main_goromandy_mountains_baersonlings_camp"] = {762,594}, 
    ["wh_main_eastern_oblast_volksgrad"] = {724,584}, 
    ["wh_main_eastern_oblast_praag"] = {699,585}, 
    ["wh_main_goromandy_mountains_frozen_landing"] = {734,624}, 
    ["wh_main_gianthome_mountains_sjoktraken"] = {691,637}, 
    ["wh_main_gianthome_mountains_khazid_bordkarag"] = {657,640}, 
    ["wh_main_gianthome_mountains_kraka_drak"] = {685,656}, 
    ["wh2_main_hell_pit_hell_pit"] = {675,611}, 
    ["wh_main_northern_oblast_fort_ostrosk"] = {658,595}, 
    ["wh_main_northern_oblast_fort_straghov"] = {636,622}, 
    ["wh_main_trollheim_mountains_the_tower_of_khrakk"] = {601,625}, 
    ["wh_main_trollheim_mountains_bay_of_blades"] = {545,625}, 
    ["wh_main_trollheim_mountains_sarl_encampment"] = {550,651}, 
    ["wh_main_mountains_of_hel_aeslings_conclave"] = {597,662}, 
    ["wh_main_mountains_of_hel_altar_of_spawns"] = {575,699}, 
    ["wh_main_mountains_of_hel_winter_pyre"] = {637,674}, 
    ["wh_main_mountains_of_naglfari_varg_camp"] = {488,686}, 
    ["wh_main_mountains_of_naglfari_naglfari_plain"] = {495,647}, 
    ["wh_main_helspire_mountains_graeling_moot"] = {477,641}, 
    ["wh_main_helspire_mountains_the_monolith_of_katam"] = {428,673}, 
    ["wh_main_helspire_mountains_serpent_jetty"] = {394,660}, 
    ["wh_main_vanaheim_mountains_troll_fjord"] = {361,609}, 
    ["wh_main_vanaheim_mountains_bjornlings_gathering"] = {427,616}, 
    ["wh_main_vanaheim_mountains_pack_ice_bay"] = {426,575}, 
    ["wh_main_ice_tooth_mountains_icedrake_fjord"] = {467,591}, 
    ["wh_main_ice_tooth_mountains_longship_graveyard"] = {504,597}, 
    ["wh_main_ice_tooth_mountains_doomkeep"] = {517,649}, 
    ["wh_main_troll_country_zoishenk"] = {612,599}, 
    ["wh_main_troll_country_erengrad"] = {609,584}, 
    ["wh_main_southern_oblast_zavastra"] = {649,551}, 
    ["wh_main_southern_oblast_kislev"] = {684,544}, 
    ["wh_main_southern_oblast_fort_jakova"] = {704,508}, 
    ["wh_main_ostermark_bechafen"] = {655,525}, 
    ["wh_main_ostermark_essen"] = {658,476}, 
    ["wh_main_ostland_castle_von_rauken"] = {620,548}, 
    ["wh_main_ostland_wolfenburg"] = {602,538}, 
    ["wh_main_ostland_norden"] = {571,576}, 
    ["wh_main_nordland_salzenmund"] = {536,569}, 
    ["wh_main_nordland_dietershafen"] = {495,562}, 
    ["wh_main_middenland_middenheim"] = {521,531}, 
    ["wh_main_middenland_weismund"] = {498,500}, 
    ["wh_main_middenland_carroburg"] = {487,466}, 
    ["wh_main_hochland_brass_keep"] = {565,538}, 
    ["wh_main_hochland_hergig"] = {580,516}, 
    ["wh_main_talabecland_kemperbad"] = {534,454}, 
    ["wh_main_talabecland_talabheim"] = {569,497}, 
    ["wh_main_stirland_wurtbad"] = {584,441}, 
    ["wh_main_stirland_the_moot"] = {611,409}, 
    ["wh_main_averland_grenzstadt"] = {612,387}, 
    ["wh_main_eastern_sylvania_castle_drakenhof"] = {680,420}, 
    ["wh_main_eastern_sylvania_eschen"] = {678,445}, 
    ["wh_main_eastern_sylvania_waldenhof"] = {684,458}, 
    ["wh_main_western_sylvania_castle_templehof"] = {652,443}, 
    ["wh_main_western_sylvania_fort_oberstyre"] = {634,436}, 
    ["wh_main_western_sylvania_schwartzhafen"] = {641,394},
    ["wh_main_wissenland_wissenburg"] = {531,394}, 
    ["wh_main_wissenland_nuln"] = {524,410}, 
    ["wh_main_wissenland_pfeildorf"] = {563,379}, 
    ["wh_main_reikland_grunburg"] = {514,427}, 
    ["wh_main_reikland_altdorf"] = {496,450}, 
    ["wh_main_reikland_helmgart"] = {466,428}, 
    ["wh_main_reikland_eilhart"] = {445,450}, 
    ["wh_main_the_wasteland_marienburg"] = {428,462}, 
    ["wh_main_the_wasteland_gorssel"] = {432,485}, 
    ["wh_main_forest_of_arden_gisoreux"] = {413,442}, 
    ["wh_main_forest_of_arden_castle_artois"] = {389,451}, 
    ["wh_main_couronne_et_languille_languille"] = {363,470}, 
    ["wh_main_couronne_et_languille_couronne"] = {384,491}, 
    ["wh_main_lyonesse_lyonesse"] = {340,440}, 
    ["wh_main_lyonesse_mousillon"] = {356,420}, 
    ["wh_main_bordeleaux_et_aquitaine_bordeleaux"] = {367,396}, 
    ["wh_main_bordeleaux_et_aquitaine_aquitaine"] = {384,380}, 
    ["wh_main_bastonne_et_montfort_castle_bastonne"] = {404,407}, 
    ["wh_main_bastonne_et_montfort_montfort"] = {438,401}, 
    ["wh_main_northern_grey_mountains_karak_ziflin"] = {441,413}, 
    ["wh_main_northern_grey_mountains_grung_zint"] = {407,466}, 
    ["wh_main_northern_grey_mountains_blackstone_post"] = {422,428}, 
    ["wh_main_parravon_et_quenelles_parravon"] = {450,379}, 
    ["wh_main_parravon_et_quenelles_quenelles"] = {444,349}, 
    ["wh_main_carcassone_et_brionne_castle_carcassonne"] = {431,318}, 
    ["wh_main_carcassone_et_brionne_brionne"] = {399,339}, 
    ["wh2_main_yvresse_elessaeli"] = {270,292}, 
    ["wh2_main_yvresse_tor_yvresse"] = {288,347}, 
    ["wh2_main_cothique_tor_koruali"] = {284,394}, 
    ["wh2_main_cothique_mistnar"] = {290,417}, 
    ["wh2_main_chrace_elisia"] = {261,417}, 
    ["wh2_main_chrace_tor_achare"] = {247,412}, 
    ["wh2_main_nagarythe_shrine_of_khaine"] = {214,447}, 
    ["wh2_main_nagarythe_tor_anlec"] = {197,423}, 
    ["wh2_main_nagarythe_tor_dranil"] = {166,401}, 
    ["wh2_main_unicorn_gate"] = {177,395}, 
    ["wh2_main_phoenix_gate"] = {208,406}, 
    ["wh2_main_griffon_gate"] = {154,371}, 
    ["wh2_main_eagle_gate"] = {148,343}, 
    ["wh2_main_tiranoc_tor_anroc"] = {145,341}, 
    ["wh2_main_tiranoc_whitepeak"] = {147,319}, 
    ["wh2_main_caledor_tor_sethai"] = {162,298}, 
    ["wh2_main_caledor_vauls_anvil"] = {174,274}, 
    ["wh2_main_eataine_tower_of_lysean"] = {198,291}, 
    ["wh2_main_eataine_lothern"] = {211,279}, 
    ["wh2_main_eataine_angerrial"] = {237,289}, 
    ["wh2_main_eataine_shrine_of_asuryan"] = {226,306}, 
    ["wh2_main_saphery_port_elistor"] = {253,305}, 
    ["wh2_main_saphery_tower_of_hoeth"] = {258,327}, 
    ["wh2_main_saphery_tor_finu"] = {261,352}, 
    ["wh2_main_avelorn_tor_saroir"] = {238,370}, 
    ["wh2_main_avelorn_evershale"] = {207,377}, 
    ["wh2_main_avelorn_gaean_vale"] = {226,361},
    ["wh2_main_ellyrion_whitefire_tor"] = {175,358}, 
    ["wh2_main_ellyrion_tor_elyr"] = {171,334}, 
    ["wh2_main_aghol_wastelands_palace_of_princes"] = {373,696}, 
    ["wh2_main_aghol_wastelands_fortress_of_the_damned"] = {337,687},
    ["wh2_main_aghol_wastelands_the_palace_of_ruin"] = {252,697},  
    ["wh2_main_deadwood_shagrath"] = {291,670}, 
    ["wh2_main_deadwood_the_frozen_city"] = {261,684}, 
    ["wh2_main_deadwood_dargoth"] = {224,659}, 
    ["wh2_main_deadwood_nagrar"] = {231,648}, 
    ["wh2_main_the_road_of_skulls_the_black_pillar"] = {187,647}, 
    ["wh2_main_the_road_of_skulls_kauark"] = {177,666}, 
    ["wh2_main_the_road_of_skulls_spite_reach"] = {155,653}, 
    ["wh2_main_the_road_of_skulls_har_ganeth"] = {143,632}, 
    ["wh2_main_the_chill_road_ghrond"] = {130,647}, 
    ["wh2_main_the_chill_road_ashrak"] = {104,668}, 
    ["wh2_main_the_chill_road_the_great_arena"] = {96,640}, 
    ["wh2_main_iron_mountains_naggarond"] = {84,630}, 
    ["wh2_main_iron_mountains_har_kaldra"] = {57,652}, 
    ["wh2_main_iron_mountains_altar_of_ultimate_darkness"] = {21,646}, 
    ["wh2_main_iron_mountains_rackdo_gorge"] = {28,629}, 
    ["wh2_main_the_black_flood_temple_of_khaine"] = {57,605}, 
    ["wh2_main_the_black_flood_cragroth_deep"] = {81,577}, 
    ["wh2_main_the_black_flood_hag_graef"] = {104,593}, 
    ["wh2_main_the_black_flood_shroktak_mount"] = {29,585}, 
    ["wh2_main_obsidian_peaks_circle_of_destruction"] = {122,560}, 
    ["wh2_main_obsidian_peaks_clar_karond"] = {95,534}, 
    ["wh2_main_obsidian_peaks_venom_glade"] = {119,522}, 
    ["wh2_main_obsidian_peaks_storag_kor"] = {50,538}, 
    ["wh2_main_the_clawed_coast_hoteks_column"] = {143,535}, 
    ["wh2_main_the_clawed_coast_the_monoliths"] = {175,543}, 
    ["wh2_main_the_clawed_coast_the_twisted_glade"] = {177,509}, 
    ["wh2_main_the_broken_land_blacklight_tower"] = {177,592}, 
    ["wh2_main_the_broken_land_slavers_point"] = {212,570}, 
    ["wh2_main_the_broken_land_karond_kar"] = {242,605}, 
    ["wh2_main_doom_glades_vauls_anvil"] = {90,483}, 
    ["wh2_main_doom_glades_hag_hall"] = {73,460}, 
    ["wh2_main_doom_glades_ice_rock_gorge"] = {50,453}, 
    ["wh2_main_doom_glades_temple_of_addaioth"] = {54,497}, 
    ["wh2_main_blackspine_mountains_red_desert"] = {11,560}, 
    ["wh2_main_blackspine_mountains_plain_of_spiders"] = {16,508}, 
    ["wh2_main_blackspine_mountains_plain_of_dogs"] = {11,437}, 
    ["wh2_main_the_black_coast_bleak_hold_fortress"] = {87,415}, 
    ["wh2_main_the_black_coast_arnheim"] = {98,379}, 
    ["wh2_main_titan_peaks_ancient_city_of_quintex"] = {47,388}, 
    ["wh2_main_titan_peaks_the_moon_shard"] = {71,357}, 
    ["wh2_main_titan_peaks_ssildra_tor"] = {36,354}, 
    ["wh2_main_titan_peaks_ironspike"] = {21,356}, 
    ["wh2_main_isthmus_of_lustria_ziggurat_of_dawn"] = {70,325}, 
    ["wh2_main_isthmus_of_lustria_skeggi"] = {90,327}, 
    ["wh2_main_isthmus_of_lustria_hexoatl"] = {48,293}, 
    ["wh2_main_isthmus_of_lustria_fallen_gates"] = {21,317},
    ["wh_main_northern_worlds_edge_mountains_karak_ungor"] = {739,494}, 
    ["wh_main_peak_pass_karak_kadrin"] = {717,445}, 
    ["wh_main_zhufbar_oakenhammer"] = {687,391}, 
    ["wh_main_zhufbar_zhufbar"] = {707,396}, 
    ["wh_main_rib_peaks_grom_peak"] = {728,401}, 
    ["wh_main_zhufbar_karag_dromar"] = {656,376}, 
    ["wh_main_black_mountains_mighdal_vongalbarak"] = {617,371}, 
    ["wh_main_black_mountains_karak_hirn"] = {565,353}, 
    ["wh_main_southern_grey_mountains_grimhold"] = {525,351}, 
    ["wh_main_southern_grey_mountains_karak_norn"] = {515,373}, 
    ["wh_main_southern_grey_mountains_karak_azgaraz"] = {484,410}, 
    ["wh_main_estalia_bilbali"] = {389,288}, 
    ["wh_main_estalia_magritta"] = {390,249}, 
    ["wh_main_estalia_tobaro"] = {408,254}, 
    ["wh2_main_skavenblight_skavenblight"] = {448,271}, 
    ["wh_main_tilea_miragliano"] = {481,268}, 
    ["wh_main_tilea_luccini"] = {492,215}, 
    ["wh2_main_sartosa_sartosa"] = {471,198}, 
    ["wh_main_western_border_princes_myrmidens"] = {536,272}, 
    ["wh_main_the_vaults_zarakzil"] = {510,274}, 
    ["wh_main_the_vaults_karak_bhufdar"] = {498,295}, 
    ["wh_main_western_border_princes_zvorak"] = {559,312}, 
    ["wh_main_the_vaults_karak_izor"] = {540,334}, 
    ["wh_main_eastern_border_princes_matorca"] = {592,323}, 
    ["wh_main_black_mountains_karak_angazhar"] = {588,334}, 
    ["wh_main_eastern_border_princes_akendorf"] = {632,341}, 
    ["wh_main_blood_river_valley_varenka_hills"] = {687,340}, 
    ["wh_main_the_silver_road_karaz_a_karak"] = {722,353}, 
    ["wh_main_blood_river_valley_dok_karaz"] = {668,311}, 
    ["wh_main_blood_river_valley_barak_varr"] = {643,316}, 
    ["wh_main_death_pass_iron_rock"] = {688,294}, 
    ["wh_main_death_pass_karag_dron"] = {716,317}, 
    ["wh_main_death_pass_karak_drazh"] = {717,281}, 
    ["wh_main_eastern_badlands_karak_eight_peaks"] = {720,266}, 
    ["wh_main_eastern_badlands_valayas_sorrow"] = {693,260}, 
    ["wh_main_eastern_badlands_crooked_fang_fort"] = {720,238}, 
    ["wh_main_eastern_badlands_dringorackaz"] = {746,239}, 
    ["wh_main_desolation_of_nagash_karak_azul"] = {764,250}, 
    ["wh_main_blightwater_karak_azgal"] = {691,197}, 
    ["wh_main_blightwater_kradtommen"] = {741,191}, 
    ["wh_main_blightwater_misty_mountain"] = {776,176}, 
    ["wh2_main_devils_backbone_lahmia"] = {822,172}, 
    ["wh2_main_devils_backbone_mahrak"] = {816,123}, 
    ["wh2_main_devils_backbone_lybaras"] = {848,129}, 
    ["wh2_main_crater_of_the_walking_dead_doom_glade"] = {853,99}, 
    ["wh2_main_crater_of_the_walking_dead_rasetra"] = {823,79}, 
    ["wh2_main_southlands_jungle_teotiqua"] = {835,29}, 
    ["wh2_main_southlands_jungle_golden_tower_of_the_gods"] = {859,50}, 
    ["wh2_main_kingdom_of_beasts_the_cursed_jungle"] = {884,67}, 
    ["wh2_main_kingdom_of_beasts_temple_of_skulls"] = {935,31}, 
    ["wh2_main_kingdom_of_beasts_serpent_coast"] = {974,20}, 
    ["wh2_main_charnel_valley_granite_massif"] = {786,121}, 
    ["wh2_main_charnel_valley_karag_orrud"] = {746,119}, 
    ["wh2_main_southlands_worlds_edge_mountains_mount_arachnos"] = {748,111}, 
    ["wh_main_western_badlands_stonemine_tower"] = {630,288}, 
    ["wh_main_western_badlands_bitterstone_mine"] = {645,251}, 
    ["wh_main_western_badlands_ekrund"] = {611,251}, 
    ["wh_main_western_badlands_dragonhorn_mines"] = {627,228}, 
    ["wh_main_southern_badlands_gronti_mingol"] = {579,219}, 
    ["wh_main_southern_badlands_galbaraz"] = {612,186}, 
    ["wh_main_southern_badlands_agrul_migdhal"] = {613,154}, 
    ["wh_main_southern_badlands_gor_gazan"] = {552,163}, 
    ["wh_main_blightwater_deff_gorge"] = {696,163}, 
    ["wh2_main_ash_river_quatar"] = {681,124}, 
    ["wh2_main_ash_river_numas"] = {630,117}, 
    ["wh2_main_ash_river_springs_of_eternal_life"] = {661,84}, 
    ["wh2_main_shifting_sands_ka-sabar"] = {725,36}, 
    ["wh2_main_southlands_worlds_edge_mountains_karak_zorn"] = {747,20}, 
    ["wh2_main_heart_of_the_jungle_oreons_camp"] = {692,26}, 
    ["wh2_main_shifting_sands_antoch"] = {666,32}, 
    ["wh2_main_shifting_sands_bhagar"] = {607,39}, 
    ["wh2_main_land_of_the_dervishes_plain_of_tuskers"] = {607,22}, 
    ["wh2_main_great_mortis_delta_black_pyramid_of_nagash"] = {583,63}, 
    ["wh2_main_great_desert_of_araby_black_tower_of_arkhan"] = {566,44}, 
    ["wh2_main_land_of_the_dervishes_sudenburg"] = {565,34}, 
    ["wh2_main_great_desert_of_araby_bel_aliad"] = {484,76}, 
    ["wh2_main_great_desert_of_araby_pools_of_despair"] = {518,77}, 
    ["wh2_main_land_of_the_dead_khemri"] = {579,130}, 
    ["wh2_main_land_of_the_dead_zandri"] = {518,120}, 
    ["wh2_main_coast_of_araby_al_haikk"] = {465,130}, 
    ["wh2_main_coast_of_araby_copher"] = {418,121}, 
    ["wh2_main_land_of_assassins_lashiek"] = {404,56}, 
    ["wh2_main_land_of_assassins_palace_of_the_wizard_caliph"] = {397,26}, 
    ["wh2_main_headhunters_jungle_mangrove_coast"] = {214,21}, 
    ["wh2_main_headhunters_jungle_oyxl"] = {193,24}, 
    ["wh2_main_headhunters_jungle_marks_of_the_old_ones"] = {209,41}, 
    ["wh2_main_southern_great_jungle_axlotl"] = {169,48}, 
    ["wh2_main_southern_great_jungle_subatuun"] = {145,15}, 
    ["wh2_main_spine_of_sotek_mine_of_the_bearded_skulls"] = {78,27}, 
    ["wh2_main_spine_of_sotek_hualotal"] = {87,60}, 
    ["wh2_main_southern_great_jungle_itza"] = {105,73}, 
    ["wh2_main_vampire_coast_the_awakening"] = {213,118}, 
    ["wh2_main_vampire_coast_pox_marsh"] = {232,159}, 
    ["wh2_main_northern_great_jungle_xahutec"] = {150,160}, 
    ["wh2_main_the_creeping_jungle_temple_of_kara"] = {124,171}, 
    ["wh2_main_the_creeping_jungle_tlaxtlan"] = {106,151}, 
    ["wh2_main_northern_great_jungle_chaqua"] = {108,116}, 
    ["wh2_main_northern_great_jungle_xlanhuapec"] = {151,99}, 
    ["wh2_main_the_creeping_jungle_tlanxla"] = {69,136}, 
    ["wh2_main_jungles_of_green_mists_spektazuma"] = {31,168}, 
    ["wh2_main_jungles_of_green_mists_wellsprings_of_eternity"] = {23,111}, 
    ["wh2_main_huahuan_desert_chamber_of_visions"] = {30,76}, 
    ["wh2_main_huahuan_desert_sentinels_of_xeti"] = {16,52}, 
    ["wh2_main_huahuan_desert_the_golden_colossus"] = {27,15}, 
    ["wh2_main_southern_jungle_of_pahualaxa_floating_pyramid"] = {86,200}, 
    ["wh2_main_southern_jungle_of_pahualaxa_the_high_sentinel"] = {78,227}, 
    ["wh2_main_southern_jungle_of_pahualaxa_pahuax"] = {73,256}, 
    ["wh2_main_southern_jungle_of_pahualaxa_monument_of_the_moon"] = {95,259}, 
    ["wh2_main_northern_jungle_of_pahualaxa_swamp_town"] = {51,259}, 
    ["wh2_main_northern_jungle_of_pahualaxa_shrine_of_sotek"] = {37,248}, 
    ["wh2_main_northern_jungle_of_pahualaxa_macu_peaks"] = {31,264}, 
    ["wh2_main_northern_jungle_of_pahualaxa_port_reaver"] = {57,285}, 
}--:map<string, {number, number}>

--v function(x: number, y: number) --> boolean
local function is_spawn_free_of_characters(x, y)
    local clock = os.clock()
    LOG("\n Is spawn free of characters returning ")
    local faction_list = cm:model():world():faction_list();
	for i = 0, faction_list:num_items() - 1 do
		local current_faction = faction_list:item_at(i);
		local char_list = current_faction:character_list();
		
		for i = 0, char_list:num_items() - 1 do
			local current_char = char_list:item_at(i);
            if current_char:logical_position_x() == x and current_char:logical_position_y() == y then
                LOG("False")
				return false;
			end;
		end;
    end;
    LOG("True ")
	return true;
end


--v function(faction_obj: CA_FACTION) --> CA_REGION_LIST
local function get_adjacent_list(faction_obj)
    if faction_obj:has_home_region() then
        return faction_obj:home_region():adjacent_region_list()
    else
        return faction_obj:region_list():item_at(cm:random_number(faction_obj:region_list():num_items()) - 1):adjacent_region_list()
    end
end

--find a valid spawn location for a faction to have a character in a region bordering the territory of any other faction. 
--blacklist is a map of region keys to true. 
--v function(faction_to_border: CA_FACTION, faction_to_spawn: CA_FACTION, blacklist: (map<string, true>)?) --> (string, number, number)
local function find_spawn_in_bordering_region(faction_to_border, faction_to_spawn, blacklist)
    LOG("\n Getting a faction spawn point for ["..faction_to_spawn:name().."] bordering faction ["..faction_to_border:name().."] ")
    if not faction_to_border:has_home_region() then
        LOG(" \n \t Returning INVALID RESULT due to NO REGIONS HELD BY FACTION TO BORDER")
        return nil, nil, nil 
    end 
    if not blacklist then
        LOG("\n \t no blacklist for current task")
        blacklist = {}
    else
        if LOG_FINDER then
            --# assume blacklist: map<string, true>
            for k, _ in pairs(blacklist) do
                LOG("\n \tregion ["..k.."] blacklisted for this find!")
            end
        end
    end
    --# assume blacklist: map<string, true>
    for j = 0, faction_to_border:region_list():num_items() - 1 do
        LOG("\n\t Checking adjacent list of ["..faction_to_border:region_list():item_at(j):name().."]")
        local adjacent_list = faction_to_border:region_list():item_at(j):adjacent_region_list()
        for i = 0, adjacent_list:num_items() - 1 do
            local current = adjacent_list:item_at(i)
            LOG("\n\t\t Checking the region ["..current:name().."]")
            --is the candidate region owned by the faction we want to border? If not, proceed.
            if (not current:settlement():is_null_interface()) and (current:owning_faction():name() ~= faction_to_border:name()) then
                --is the spawn point starting in that region valid?
                --first, do we even have a start there?
                if SPAWNER_STARTS[current:name()] then
                    --next, is the region in the blacklist?
                    LOG("\n\t\t\t Checking region ["..current:name().."] on the black list, it is: ["..tostring(not not blacklist[current:name()]).."]")
                    if blacklist[current:name()] ~= true then
                        --we have a start there, is it valid?
                        local startx = SPAWNER_STARTS[current:name()][1]
                        local starty = SPAWNER_STARTS[current:name()][2]
                        LOG("\n\t\t\t Checking the spawn point ["..current:name().."], ["..startx.."], ["..starty.."] ")
                        --local x, y = cm:find_valid_spawn_location_for_character_from_position(faction_to_spawn:name(), startx, starty, false)
                        x = startx
                        y = starty
                        if x > -1 and y > -1 then
                            if is_spawn_free_of_characters(x, y) then
                                LOG(" \n \t Returning Spawn set region: ["..current:name().."] x: ["..x.."] y: ["..y.."]")
                                return current:name(), x, y
                            end
                        end
                    else
                        LOG("\n\t\t\t excluding region ["..current:name().."] due to blacklist")
                    end
                end
            end
        end
    end

    LOG(" \n \t Returning INVALID RESULT due to NO VALID RESULT FOUND")
    return nil, nil, nil
end

--v function(character_to_border: CA_CHAR, faction_to_spawn: CA_FACTION, allow_own_territory: boolean, blacklist: (map<string, true>)?)  --> (string, number, number)
function find_spawn_in_region_bordering_character(character_to_border, faction_to_spawn, allow_own_territory, blacklist)
    if character_to_border:region():is_null_interface() then
        return nil, nil, nil
    end
    LOG("\n Getting a character spawn point for ["..faction_to_spawn:name().."] bordering character ["..tostring(character_to_border:command_queue_index()).."] ")
    if not blacklist then
        LOG("\n \t no blacklist for current task")
        blacklist = {}
    else
        if LOG_FINDER then
            --# assume blacklist: map<string, true>
            for k, _ in pairs(blacklist) do
                LOG("\n \tregion ["..k.."] blacklisted for this find!")
            end
        end
    end
    --# assume blacklist: map<string, true>
    local adjacent_list = character_to_border:region():adjacent_region_list()
    for i = 0, adjacent_list:num_items() - 1 do
        local current = adjacent_list:item_at(i)
        LOG("\n\t\t Checking the region ["..current:name().."]")
        --is the candidate region owned by the faction we want to border? If not, proceed.
        if (allow_own_territory) or (not current:settlement():is_null_interface()) and (current:owning_faction():name() ~= character_to_border:faction():name()) then
            --is the spawn point starting in that region valid?
            --first, do we even have a start there?
            if SPAWNER_STARTS[current:name()] then
                --next, is the region in the blacklist?
                LOG("\n\t\t\t Checking region ["..current:name().."] on the black list, it is: ["..tostring(not not blacklist[current:name()]).."]")
                if blacklist[current:name()] ~= true then
                    --we have a start there, is it valid?
                    local startx = SPAWNER_STARTS[current:name()][1]
                    local starty = SPAWNER_STARTS[current:name()][2]
                    LOG("\n\t\t\t Checking the spawn point ["..current:name().."], ["..startx.."], ["..starty.."] ")
                    --local x, y = cm:find_valid_spawn_location_for_character_from_position(faction_to_spawn:name(), startx, starty, false)
                    x = startx
                    y = starty
                    --# assume min_distance: number
                    if current:name() ~= character_to_border:region():name() then
                        if x > -1 and y > -1 then
                            if is_spawn_free_of_characters(x, y) then
                                LOG(" \n \t Returning Spawn set region: ["..current:name().."] x: ["..x.."] y: ["..y.."]")
                                return current:name(), x, y
                            else
                                LOG("\n\t\t\t excluding region ["..current:name().."] due to spawn being occupied")
                            end
                        else
                            LOG("\n\t\t\t excluding region ["..current:name().."] due to invalid coordinates")
                        end
                    end
                else
                    LOG("\n\t\t\t excluding region ["..current:name().."] due to blacklist")
                end
            end
        end
    end
    --if we got here, none of our adjacents are gonna work, so lets do a double loop before giving up
    local first_adjacents = character_to_border:region():adjacent_region_list()
    for j = 0, first_adjacents:num_items() - 1 do
        local adjacent_list = first_adjacents:item_at(j):adjacent_region_list()
        for i = 0, adjacent_list:num_items() - 1 do
            local current = adjacent_list:item_at(i)
            LOG("\n\t\t Checking the region ["..current:name().."]")
            --is the candidate region owned by the faction we want to border? If not, proceed.
            if (allow_own_territory) or (not current:settlement():is_null_interface()) and (current:owning_faction():name() ~= character_to_border:faction():name()) then
                --is the spawn point starting in that region valid?
                --first, do we even have a start there?
                if SPAWNER_STARTS[current:name()] then
                    --next, is the region in the blacklist?
                    --# assume blacklist: map<string, true>
                    LOG("\n\t\t\t Checking region ["..current:name().."] on the black list, it is: ["..tostring(not not blacklist[current:name()]).."]")
                    if blacklist[current:name()] ~= true then
                        --we have a start there, is it valid?
                        local startx = SPAWNER_STARTS[current:name()][1]
                        local starty = SPAWNER_STARTS[current:name()][2]
                        LOG("\n\t\t\t Checking the spawn point ["..current:name().."], ["..startx.."], ["..starty.."] ")
                        --local x, y = cm:find_valid_spawn_location_for_character_from_position(faction_to_spawn:name(), startx, starty, false)
                        x = startx
                        y = starty
                        if current:name() ~= character_to_border:region():name() then
                            if x > -1 and y > -1 then
                                if is_spawn_free_of_characters(x, y) then
                                    LOG(" \n \t Returning Spawn set region: ["..current:name().."] x: ["..x.."] y: ["..y.."]")
                                    return current:name(), x, y
                                else
                                    LOG("\n\t\t\t excluding region ["..current:name().."] due to spawn being occupied")
                                end
                            else
                                LOG("\n\t\t\t excluding region ["..current:name().."] due to invalid coordinates")
                            end
                        end
                    else
                        LOG("\n\t\t\t excluding region ["..current:name().."] due to blacklist")
                    end
                end
            end
        end
    end
    return nil, nil, nil
end
_G.SPAWN_POINT_LOCATOR = {
        is_spawn_free_of_characters = is_spawn_free_of_characters,
        find_spawn_in_bordering_region = find_spawn_in_bordering_region,
        find_spawn_in_region_bordering_character = find_spawn_in_region_bordering_character
    }
