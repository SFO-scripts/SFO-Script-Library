events = get_events(); cm = get_cm(); sfo = _G.sfo

local function sfo_starting_diplomacy()
    sfo:log("Setting starting diplomacy", "sfo_starting_diplomacy")
    cm:force_make_peace("wh2_main_hef_eataine", "wh2_main_hef_yvresse");
	cm:force_make_peace("wh2_main_hef_eataine", "wh2_main_hef_cothique");
	
	cm:force_make_peace("wh_main_emp_marienburg", "wh_main_brt_bretonnia");	
	cm:force_make_peace("wh_main_brt_carcassonne", "wh2_main_hef_yvresse");
	cm:force_make_peace("wh_main_brt_lyonesse", "wh2_main_hef_cothique");
	cm:force_make_peace("wh_main_brt_lyonesse", "wh_main_vmp_mousillon");		
	cm:force_make_trade_agreement("wh_main_brt_carcassonne", "wh2_main_hef_yvresse");
	cm:force_make_trade_agreement("wh_main_brt_lyonesse", "wh2_main_hef_cothique");		

	cm:force_make_trade_agreement("wh_main_teb_estalia", "wh2_main_hef_yvresse");
	cm:force_make_trade_agreement("wh_main_teb_estalia", "wh2_main_emp_new_world_colonies");
	cm:force_make_trade_agreement("wh_main_teb_tilea", "wh2_main_emp_new_world_colonies");

	cm:force_make_peace("wh_main_emp_empire", "wh_main_grn_skull-takerz");		
	cm:force_make_peace("wh_main_emp_middenland", "wh_main_grn_skull-takerz");
	cm:force_make_peace("wh_main_emp_wissenland", "wh_main_grn_skull-takerz");
	cm:force_make_peace("wh_main_dwf_karak_izor", "wh_main_grn_skull-takerz");	
	cm:teleport_to(cm:char_lookup_str(cm:get_faction("wh_main_grn_skull-takerz"):faction_leader():command_queue_index()), 691, 195, true);
	cm:force_declare_war("wh_main_grn_skull-takerz", "wh_main_teb_border_princes", false, false);

	cm:force_make_peace("wh2_main_skv_clan_pestilens", "wh2_main_skv_clan_eshin");

	cm:force_make_peace("wh2_dlc09_tmb_khemri", "wh_main_grn_top_knotz");		
	cm:force_declare_war("wh2_dlc09_tmb_khemri", "wh2_main_vmp_strygos_empire", false, false);

	cm:force_declare_war("wh_main_grn_bloody_spearz", "wh_main_grn_red_eye", false, false);

	cm:force_declare_war("wh_dlc03_bst_beastmen", "wh_main_teb_tilea", false, false);

	cm:disable_event_feed_events(true, "wh_event_category_conquest", "", "");
	cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "");

	cm:transfer_region_to_faction("wh2_main_jungles_of_green_mists_spektazuma", "wh2_main_skv_clan_eshin");

	cm:callback(
		function()
			cm:disable_event_feed_events(false, "wh_event_category_conquest", "", "");
			cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "");
		end,
		1
    );
    
    sfo:log("starting diplomacy set without error.", "sfo_starting_diplomacy")
end



events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() 
    if cm:is_new_game() then
        sfo_starting_diplomacy()
    end
end;