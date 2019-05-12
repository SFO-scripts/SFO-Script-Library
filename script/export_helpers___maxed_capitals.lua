cm:add_first_tick_callback(
function()
upgrade_capitals()
end
);

function upgrade_capitals()

if cm:is_new_game() then 
	out("FD: upgrading capitals");

---- DWARFS
	cm:instantly_upgrade_building("wh_main_the_silver_road_karaz_a_karak:0", "wh_main_special_settlement_karaz_a_karak_2_dwf");
	cm:instantly_upgrade_building("wh_main_the_vaults_karak_izor:0", "wh_main_dwf_settlement_major_2");
	cm:instantly_upgrade_building("wh_main_peak_pass_karak_kadrin:0", "wh_main_dwf_settlement_major_2");

---- WOOD ELVES
	cm:instantly_upgrade_building("wh_main_athel_loren_waterfall_palace:0", "wh_dlc05_wef_settlement_major_main_2");
	cm:instantly_upgrade_building("wh_main_athel_loren_yn_edryl_korian:0", "wh_dlc05_wef_settlement_major_main_2");

---- BRETONNIA
	cm:instantly_upgrade_building("wh_main_carcassone_et_brionne_castle_carcassonne:0", "wh_main_brt_settlement_major_3");
	cm:instantly_upgrade_building("wh_main_bordeleaux_et_aquitaine_bordeleaux:0", "wh_main_brt_settlement_major_3_coast");
	cm:instantly_upgrade_building("wh_main_couronne_et_languille_couronne:0", "wh_main_special_settlement_couronne_3_brt");

---- EMPIRE / TEB / KISLEV
	cm:instantly_upgrade_building("wh_main_reikland_altdorf:0", "wh_main_special_settlement_altdorf_2_emp");
	cm:instantly_upgrade_building("wh_main_middenland_middenheim:0", "wh_main_emp_settlement_major_2");
	cm:instantly_upgrade_building("wh_main_estalia_magritta:0", "wh_main_emp_settlement_major_2_coast");
	cm:instantly_upgrade_building("wh_main_wissenland_nuln:0", "wh_main_emp_settlement_major_2");
	cm:instantly_upgrade_building("wh_main_the_wasteland_marienburg:0", "wh_main_emp_settlement_major_2_coast");
	cm:instantly_upgrade_building("wh_main_southern_oblast_kislev:0", "wh_main_special_settlement_kislev_2_ksl");
	cm:instantly_upgrade_building("wh_main_talabecland_talabheim:0", "wh_main_emp_settlement_major_2");
	cm:instantly_upgrade_building("wh_main_tilea_miragliano:0", "wh_main_special_settlement_miragliano_2_teb");

---- VAMPIRE COUNTS
	cm:instantly_upgrade_building("wh_main_eastern_sylvania_castle_drakenhof:0", "wh_main_special_settlement_castle_drakenhof_2_vmp");
	cm:instantly_upgrade_building("wh_main_northern_grey_mountains_blackstone_post:0", "wh_main_vmp_settlement_major_2");

---- GREENSKINS
	cm:instantly_upgrade_building("wh_main_death_pass_karak_drazh:0", "wh_main_special_settlement_black_crag_2_grn");
	cm:instantly_upgrade_building("wh_main_western_badlands_ekrund:0", "wh_main_grn_settlement_major_2_wurrzag");
	cm:instantly_upgrade_building("wh_main_southern_grey_mountains_karak_azgaraz:0", "wh_main_grn_settlement_minor_3_skarsnik");

---- SKAVEN
	cm:instantly_upgrade_building("wh2_main_charnel_valley_karag_orrud:0", "wh2_main_skv_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_southern_jungles_yuatek:0", "wh2_main_skv_settlement_major_2");

	cm:instantly_upgrade_building("wh2_main_hell_pit_hell_pit:0", "wh2_main_special_settlement_hellpit_2");

	cm:instantly_upgrade_building("wh2_main_the_clawed_coast_hoteks_column:0", "wh2_main_skv_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_the_clawed_coast_hoteks_column:0", "wh2_main_skv_settlement_major_2");

	cm:instantly_upgrade_building("wh2_main_headhunters_jungle_oyxl:0", "wh2_main_skv_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_the_lost_valleys_oyxl:0", "wh2_main_skv_settlement_major_2");
	
	cm:instantly_upgrade_building("wh2_main_skavenblight_skavenblight:0", "wh2_main_special_settlement_skavenblight_2");
	cm:instantly_upgrade_building("wh2_main_vor_the_vampire_coast_the_star_tower:0", "wh2_main_special_settlement_colony_major_other_2");

---- DARK ELVES	
	cm:instantly_upgrade_building("wh2_main_iron_mountains_naggarond:0", "wh2_main_special_settlement_naggarond_2");
	cm:instantly_upgrade_building("wh2_main_vor_naggarond_naggarond:0", "wh2_main_special_settlement_naggarond_2");
	cm:instantly_upgrade_building("wh2_main_titan_peaks_ancient_city_of_quintex:0", "wh2_main_def_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_iron_peaks_ancient_city_of_quintex:0", "wh2_main_def_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_the_road_of_skulls_har_ganeth:0", "wh2_main_def_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_the_road_of_skulls_har_ganeth:0", "wh2_main_def_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_headhunters_jungle_chupayotl:0", "wh2_main_def_settlement_minor_3_coast");
	cm:instantly_upgrade_building("wh2_main_vor_culchan_plains_chupayotl:0", "wh2_main_def_settlement_major_3_coast");

---- LIZARDMEN
	cm:instantly_upgrade_building("wh2_main_isthmus_of_lustria_hexoatl:0", "wh2_main_special_settlement_hexoatl_hexoatl_2");
	cm:instantly_upgrade_building("wh2_main_vor_isthmus_of_lustria_hexoatl:0", "wh2_main_special_settlement_hexoatl_hexoatl_2");

	cm:instantly_upgrade_building("wh2_main_kingdom_of_beasts_temple_of_skulls:0", "wh2_main_lzd_settlement_major_3");
	cm:instantly_upgrade_building("wh2_main_vor_kingdom_of_beasts_temple_of_skulls:0", "wh2_main_lzd_settlement_major_3");

	cm:instantly_upgrade_building("wh2_main_southern_great_jungle_itza:0", "wh2_main_special_settlement_itza_itza_2");
	cm:instantly_upgrade_building("wh2_main_vor_northern_great_jungle_itza:0", "wh2_main_special_settlement_itza_itza_2");

	cm:instantly_upgrade_building("wh2_main_northern_great_jungle_xlanhuapec:0", "wh2_main_lzd_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_culchan_plains_kaiax:0", "wh2_main_lzd_settlement_major_2_coast");

	cm:instantly_upgrade_building("wh2_main_western_jungles_tlaqua:0", "wh2_main_lzd_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_western_jungles_tlaqua:0", "wh2_main_lzd_settlement_major_2");


---- TOMB KINGS
	cm:instantly_upgrade_building("wh2_main_vor_copper_desert_the_forgotten_isles:0", "wh2_dlc09_tmb_settlement_major_coast_2");
	cm:instantly_upgrade_building("wh2_main_vor_ashen_coast_scarpels_lair:0", "wh2_dlc09_tmb_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_land_of_the_dead_khemri:0", "wh2_dlc09_special_settlement_khemri_tmb_2");
	cm:instantly_upgrade_building("wh2_main_land_of_the_dead_khemri:0", "wh2_dlc09_special_settlement_khemri_tmb_2");
	cm:instantly_upgrade_building("wh2_main_land_of_assassins_palace_of_the_wizard_caliph:0", "wh2_dlc09_tmb_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_vor_land_of_assassins_palace_of_the_wizard_caliph:0", "wh2_dlc09_tmb_settlement_major_2");
	cm:instantly_upgrade_building("wh2_main_blackspine_mountains_plain_of_spiders:0", "wh2_dlc09_tmb_settlement_minor_3");
	cm:instantly_upgrade_building("wh2_main_devils_backbone_lybaras:0", "wh2_dlc09_tmb_settlement_minor_3");
	
---- NORSCA
	cm:instantly_upgrade_building("wh_main_mountains_of_hel_winter_pyre:0", "wh_main_nor_settlement_minor_3_coast");
	cm:instantly_upgrade_building("wh_main_ice_tooth_mountains_icedrake_fjord:0", "wh_main_nor_settlement_major_2_coast");
	
---- HIGH ELVES
	cm:instantly_upgrade_building("wh2_main_eataine_lothern:0", "wh2_main_special_settlement_lothern_2");
	cm:instantly_upgrade_building("wh2_main_vor_straits_of_lothern_lothern:0", "wh2_main_special_settlement_lothern_2");
	cm:instantly_upgrade_building("wh2_main_volcanic_islands_the_star_tower:0", "wh2_main_special_settlement_colony_major_hef_2");
	cm:instantly_upgrade_building("wh2_main_vor_the_turtle_isles_great_turtle_isle:0", "wh2_main_special_settlement_colony_major_hef_2");
	cm:instantly_upgrade_building("wh2_main_avelorn_gaean_vale:0", "wh2_main_special_settlement_gaean_vale_2");
	cm:instantly_upgrade_building("wh2_main_vor_avelorn_gaean_vale:0", "wh2_main_special_settlement_gaean_vale_2");
	cm:instantly_upgrade_building("wh2_main_vor_the_broken_land_black_creek_spire:0", "wh2_main_hef_settlement_minor_3");
	cm:instantly_upgrade_building("wh2_main_the_black_coast_arnheim:0", "wh2_main_special_settlement_colony_major_hef_3");

---- VAMPIRE COAST
	cm:instantly_upgrade_building("wh2_main_vor_sartosa_sartosa:0", "wh2_main_special_settlement_sartosa_cst_2");
	cm:instantly_upgrade_building("wh2_main_sartosa_sartosa:0", "wh2_main_special_settlement_sartosa_cst_2");
	cm:instantly_upgrade_building("wh2_main_vampire_coast_the_awakening:0", "wh2_main_special_settlement_the_awakening_cst_2");
	cm:instantly_upgrade_building("wh2_main_vor_the_vampire_coast_the_awakening:0", "wh2_main_special_settlement_the_awakening_cst_2");
	cm:instantly_upgrade_building("wh2_main_the_galleons_graveyard:0", "wh2_dlc11_special_settlement_galleons_graveyard_2");
	cm:instantly_upgrade_building("wh2_main_vor_the_galleons_graveyard:0", "wh2_dlc11_special_settlement_galleons_graveyard_2");
	cm:instantly_upgrade_building("wh2_main_southern_jungle_of_pahualaxa_monument_of_the_moon:0", "wh2_dlc11_vampirecoast_settlement_minor_coast_3");
	cm:instantly_upgrade_building("wh2_main_vor_grey_guardians_grey_rock_point:0", "wh2_dlc11_vampirecoast_settlement_minor_coast_3");

end 

end;
