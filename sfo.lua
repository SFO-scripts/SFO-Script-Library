--sfo management object
_G.main_env = getfenv(1) 
local sfo_manager = {} --# assume sfo_manager: SFO_MANAGER

--v function() --> SFO_MANAGER
function sfo_manager.new()
    local self = {}
    setmetatable(self, {
        __index = sfo_manager
    })
    --# assume self: SFO_MANAGER


    return self
end

--v function (self: SFO_MANAGER)
function sfo_manager.green_knight_experience(self)
    SFOLOG("Removing the vanilla Green Knight listener and creating a new one.", "sfo_manager.green_knight_experience(self)")
    core:remove_listener("Bret_UniqueAgentSpawned")
    core:add_listener(
        "GreenKnightExp",
        "UniqueAgentSpawned",
        function(context)
            local character = context:unique_agent_details():character();
            SFOLOG("Unique Agent Spawned, checking if they are the green knight", "listener.GreenKnightExp.condition(context)")
            return not character:is_null_interface() and character:character_subtype("dlc07_brt_green_knight");
        end,
        function(context)

            local character = context:unique_agent_details():character();
            --# assume character: CA_CHAR
            if character:rank() < 40 then
                SFOLOG("Leveling Up the Green Knight!", "listener.GreenKnightExp.callback(context)")
				local char_str = cm:char_lookup_str(character:cqi());
				
                cm:add_agent_experience(char_str, 1151000);
                cm:replenish_action_points(char_str);
                for i = 1, 33 do
					cm:force_add_skill(char_str, "wh_dlc07_skill_green_knight_dummy");
                end
                if character:faction():is_human() and not cm:is_multiplayer() then
                    -- fly camera to Green Knight
                    cm:scroll_camera_from_current(1, false, {character:display_position_x(), character:display_position_y(), 14.7, 0.0, 12.0});
                end;

            end
        end,
        true);
end;

--v function(self: SFO_MANAGER)
function sfo_manager.lord_of_change_recruitment(self)
    if cm:get_saved_value("sfo_lord_of_change_given") == true then
        SFOLOG("The lord of change was already defeated, aborting listener setup", "sfo_manager.lord_of_change_recruitment(self)")
        return
    end
    SFOLOG("Adding Listener for Lord of Change recruitment", "sfo_manager.lord_of_change_recruitment(self)")
    core:add_listener(
        "SFOAddEverwatcherToPool",
        "FactionTurnStart",
        function(context)
            return context:faction():name() == "wh_main_chs_chaos" and context:faction():is_human() and cm:get_saved_value("lord_of_change_killed") == true
        end,
        function(context)
            SFOLOG("Granting chaos the option to recruit the everwatcher", "listener.SFOAddEverwatcherToPool.callback(context)")
            cm:spawn_character_to_pool("wh_main_chs_chaos", "names_name_2147357518" , "names_name_2147357523", "", "", 18, true, "general", "chs_lord_of_change", true, "");
            cm:set_saved_value("sfo_lord_of_change_given", true)
            SFOLOG("break", "check")
        end,
        false);
end

--v function(self: SFO_MANAGER)
function sfo_manager.norsca_everchosen_building(self)
local humans = cm:get_human_factions() 
    for i = 1, #humans do
        local current_human = humans[i];
        if cm:get_faction(current_human):subculture() == "wh_main_sc_nor_norsca" then
            SFOLOG("player ["..current_human.."] is Norscan!", "sfo_manager.norsca_everchosen_building(self)")
            if not cm:get_saved_value("sfo_everchosen_building"..current_human) == true then
                cm:add_restricted_building_level_record(current_human, "VENRIS_ADDbuilding_key")
                core:add_listener(
                    "SFO_everchosen_buildings",
                    "FactionTurnStart",
                    function(context)
                        return context:faction():name() == current_human and context:faction():has_effect_bundle("wh_dlc08_bundle_true_everchosen")
                    end,
                    function(context)
                        SFOLOG("Player ["..current_human.."] is everchosen, unlocking their building! ", "listener.SFO_everchosen_buildings.callback")
                        cm:remove_restricted_building_level_record(current_human, "VENRIS_ADDbuilding_key")
                        cm:set_saved_value("sfo_everchosen_building"..current_human, true)
                    end,
                    false);
            else
                SFOLOG("Current player already is everchosen!", "sfo_manager.norsca_everchosen_building(self)")
            end
        end
    end
end


--v function(self: SFO_MANAGER)
function sfo_manager.starting_diplomacy(self)
    SFOLOG("Setting starting diplomacy", "sfo_manager.starting_diplomacy(self)")
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
    
    SFOLOG("starting diplomacy set without error.", "sfo_manager.starting_diplomacy(self)")
end



--v function(self: SFO_MANAGER)
function sfo_manager.karak_eight_peaks(self)
    SFOLOG("Checking Karak Eight Peaks Status.", "sfo_manager.karak_eight_peaks(self)")
    cm:disable_event_feed_events(true, "wh_event_category_conquest", "", "");
    cm:disable_event_feed_events(true, "wh_event_category_diplomacy", "", "");

    local humans = cm:get_human_factions()
    local skarsnik_human = cm:get_faction("wh_main_grn_crooked_moon"):is_human()
    local belegar_human = cm:get_faction("wh_main_dwf_karak_izor"):is_human() 
    local queek_human = cm:get_faction("wh2_main_skv_clan_mors"):is_human()
    cm:force_diplomacy("faction:wh_main_grn_crooked_moon", "faction:wh2_main_skv_clan_mors", "peace", false, false, true)
    cm:force_diplomacy("faction:wh_main_dwf_karak_izor", "faction:wh2_main_skv_clan_mors", "peace", false, false, true)
    if skarsnik_human and (not queek_human) then
        local clan_mors = cm:get_faction("wh2_main_skv_clan_mors");
	    local mutenious_gits = cm:get_faction("wh_main_grn_necksnappers");
        cm:force_declare_war("wh2_main_skv_clan_mors", "wh_main_dwf_karak_azul", false, false);		
		cm:force_make_peace("wh_main_grn_crooked_moon", "wh_main_grn_necksnappers");
		cm:force_make_peace("wh_main_dwf_karak_izor", "wh_main_grn_necksnappers");
		cm:force_make_peace("wh2_main_skv_clan_mors", "wh_main_grn_necksnappers");
		cm:force_make_peace("wh2_main_skv_clan_mors", "wh2_main_grn_arachnos");
		cm:force_declare_war("wh_main_dwf_karak_ziflin", "wh_dlc05_wef_wydrioth", false, false);
		cm:force_make_trade_agreement("wh_main_dwf_karak_ziflin", "wh_main_dwf_karak_norn");
		cm:force_make_trade_agreement("wh_main_dwf_karak_ziflin", "wh_main_emp_wissenland");		
		cm:force_make_peace("wh_main_dwf_karak_ziflin", "wh_main_brt_bastonne");
        local clan_mors_character_list = clan_mors:character_list();
		local mutenious_gits_character_list = mutenious_gits:character_list();
		local mutenious_gits_region_list = mutenious_gits:region_list();	
		
		for i = 0, mutenious_gits_character_list:num_items() - 1 do
			cm:kill_character(mutenious_gits_character_list:item_at(i):cqi(), true, true);
		end;
		
		for i = 0, mutenious_gits_region_list:num_items() - 1 do
			cm:transfer_region_to_faction(mutenious_gits_region_list:item_at(i):name(), "wh2_main_skv_clan_mors");
		end;
	
		cm:transfer_region_to_faction("wh2_main_charnel_valley_karag_orrud", "wh2_main_grn_arachnos");		
		cm:teleport_to(cm:char_lookup_str(cm:get_faction("wh2_main_skv_clan_mors"):faction_leader():command_queue_index()), 737, 262, true);	
    elseif not skarsnik_human then
        local crooked_moon = cm:get_faction("wh_main_grn_crooked_moon");
	    local mutenious_gits = cm:get_faction("wh_main_grn_necksnappers");	
        cm:force_declare_war("wh_main_grn_crooked_moon", "wh_main_dwf_karak_azul", false, false);		
		cm:force_make_peace("wh_main_grn_crooked_moon", "wh_main_grn_necksnappers");
		cm:force_make_peace("wh_main_dwf_karak_izor", "wh_main_grn_necksnappers");
		cm:force_make_peace("wh2_main_skv_clan_mors", "wh_main_grn_necksnappers");
		cm:force_declare_war("wh_main_dwf_karak_ziflin", "wh_dlc05_wef_wydrioth", false, false);
		cm:force_make_trade_agreement("wh_main_dwf_karak_ziflin", "wh_main_dwf_karak_norn");
		cm:force_make_trade_agreement("wh_main_dwf_karak_ziflin", "wh_main_emp_wissenland");
		cm:force_make_peace("wh_main_dwf_karak_ziflin", "wh_main_brt_bastonne");
		cm:force_make_peace("wh_main_grn_crooked_moon", "wh_main_dwf_karak_norn");		
		

		local crooked_moon_character_list = crooked_moon:character_list();
		local mutenious_gits_character_list = mutenious_gits:character_list();
		local mutenious_gits_region_list = mutenious_gits:region_list();
		
		for i = 0, mutenious_gits_character_list:num_items() - 1 do
			cm:teleport_to(cm:char_lookup_str(mutenious_gits_character_list:item_at(i):cqi()), 467, 403, true);
		end;
		
		for i = 0, mutenious_gits_region_list:num_items() - 1 do
			cm:transfer_region_to_faction(mutenious_gits_region_list:item_at(i):name(), "wh_main_grn_crooked_moon");
		end;
		
		cm:transfer_region_to_faction("wh_main_southern_grey_mountains_karak_azgaraz", "wh_main_grn_necksnappers");
		cm:teleport_to(cm:char_lookup_str(cm:get_faction("wh_main_grn_crooked_moon"):faction_leader():command_queue_index()), 737, 262, true);	
		
		for i = 1, crooked_moon_character_list:num_items() - 1 do
			cm:teleport_to(cm:char_lookup_str(crooked_moon_character_list:item_at(i):cqi()), 740, 262, true);
		end;			
		cm:force_declare_war("wh_main_grn_necksnappers", "wh_main_dwf_karak_norn", false, false);	
    end
    cm:callback(
        function()
            cm:disable_event_feed_events(false, "wh_event_category_conquest", "", "");
            cm:disable_event_feed_events(false, "wh_event_category_diplomacy", "", "");
        end,
        1
    );
    SFOLOG("Karak Eight Peaks script exited without error", "sfo_manager.karak_eight_peaks(self)")
end



SFOLOG("SFO MANAGER INIT COMPLETE", "file.sfo_manager")

return {
    new = sfo_manager.new
}