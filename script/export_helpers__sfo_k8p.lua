cm = get_cm(); sfo = _G.sfo

--v function(is_new_game: boolean, dont_transfer: boolean?)
function sfo_eight_peaks(is_new_game, dont_transfer)
    if is_new_game then
        out("Its a new game, moving eight peaks characters!")
        if cm:get_faction("wh_main_grn_crooked_moon"):is_human() == false then
            if not dont_transfer then
                cm:transfer_region_to_faction("wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_crooked_moon")
                cm:transfer_region_to_faction("wh_main_southern_grey_mountains_karak_azgaraz", "wh_main_grn_necksnappers")
            end
            cm:callback(function()
            local x, y = cm:find_valid_spawn_location_for_character_from_position("wh_main_grn_necksnappers", 466, 403, false)
            if x == -1 then 
                --# assume sfo_eight_peaks: function(boolean, boolean?)
                sfo_eight_peaks(true, true) 
                return
            end
            cm:teleport_to(cm:char_lookup_str(cm:get_faction("wh_main_grn_necksnappers"):faction_leader():cqi()), x, y, false ); -- leader dude of necksnarfers
            local x, y = cm:find_valid_spawn_location_for_character_from_position("wh_main_grn_crooked_moon", 737, 262, false)
            cm:teleport_to(cm:char_lookup_str(46), x, y, false);	 --skarsnik
            local x, y = cm:find_valid_spawn_location_for_character_from_position("wh_main_grn_crooked_moon", 739, 263, false)
            cm:teleport_to(cm:char_lookup_str(47), x, y, false);    --his friend
            end, 0.1) 
            if not cm:is_multiplayer() then
                cm:force_declare_war("wh_main_grn_crooked_moon", "wh_main_dwf_karak_azul", false, false);	
                cm:force_declare_war("wh_main_dwf_karak_ziflin", "wh_dlc05_wef_wydrioth", false, false);
                cm:force_declare_war("wh2_main_skv_clan_mors", "wh_main_grn_necksnappers", false, false);
                cm:force_declare_war("wh_main_grn_crooked_moon", "wh_main_grn_necksnappers", false, false);
                cm:force_declare_war("wh_main_dwf_karak_izor", "wh_main_grn_necksnappers", false, false);
                cm:force_declare_war("wh2_main_skv_clan_mors", "wh_main_grn_crooked_moon", false, false);
                cm:force_declare_war("wh2_main_skv_clan_mors", "wh_main_dwf_karak_izor", false, false);
            end
            cm:force_make_trade_agreement("wh_main_dwf_karak_ziflin", "wh_main_dwf_karak_norn");
            cm:force_make_trade_agreement("wh_main_dwf_karak_ziflin", "wh_main_emp_wissenland");
            cm:force_make_peace("wh_main_dwf_karak_ziflin", "wh_main_brt_bastonne");
            cm:force_make_peace("wh_main_grn_crooked_moon", "wh_main_dwf_karak_norn");
            out("finished moving eight peaks characters!")
        elseif cm:get_faction("wh2_main_skv_clan_mors"):is_human() == false then
            cm:teleport_to(cm:char_lookup_str(cm:get_faction("wh2_main_skv_clan_mors"):faction_leader():command_queue_index()), 737, 262, true);
            cm:teleport_to(cm:char_lookup_str(102), 466, 403, false);
            cm:transfer_region_to_faction("wh_main_eastern_badlands_karak_eight_peaks", "wh2_main_skv_clan_mors")
            cm:transfer_region_to_faction("wh2_main_charnel_valley_karag_orrud", "wh2_main_grn_arachnos");	
            local cqi = 102 --# assume cqi: CA_CQI
            cm:kill_character(cqi, true, true)

            if not cm:is_multiplayer() then
                cm:force_declare_war("wh2_main_skv_clan_mors", "wh_main_dwf_karak_azul", false, false);	
                cm:force_declare_war("wh_main_dwf_karak_ziflin", "wh_dlc05_wef_wydrioth", false, false);
                cm:force_declare_war("wh2_main_skv_clan_mors", "wh_main_grn_necksnappers", false, false);
                cm:force_declare_war("wh_main_grn_crooked_moon", "wh_main_grn_necksnappers", false, false);
                cm:force_declare_war("wh_main_dwf_karak_izor", "wh_main_grn_necksnappers", false, false);
                cm:force_declare_war("wh2_main_skv_clan_mors", "wh_main_grn_crooked_moon", false, false);
                cm:force_declare_war("wh2_main_skv_clan_mors", "wh_main_dwf_karak_izor", false, false);
            end
            cm:force_make_peace("wh2_main_skv_clan_mors", "wh2_main_grn_arachnos");
            cm:force_make_trade_agreement("wh_main_dwf_karak_ziflin", "wh_main_dwf_karak_norn");
            cm:force_make_trade_agreement("wh_main_dwf_karak_ziflin", "wh_main_emp_wissenland");		
            cm:force_make_peace("wh_main_dwf_karak_ziflin", "wh_main_brt_bastonne");
            out("finished moving eight peaks characters!")
            --prevent peace
            cm:force_diplomacy("faction:wh2_main_skv_clan_mors", "faction:wh_main_dwf_karak_izor", "peace", false, false, false)
            cm:force_diplomacy("faction:wh2_main_skv_clan_mors", "faction:wh_main_grn_crooked_moon", "peace", false, false, false)
            cm:force_diplomacy("faction:wh_main_dwf_karak_izor", "faction:wh2_main_skv_clan_mors", "peace", false, false, false)
            cm:force_diplomacy("faction:wh_main_grn_crooked_moon", "faction:wh2_main_skv_clan_mors", "peace", false, false, false)
            --allow war with the 8 peaks gits
            cm:force_diplomacy("faction:wh2_main_skv_clan_mors", "faction:wh_main_grn_necksnappers", "war", true, true, false)
            cm:force_diplomacy("faction:wh_main_dwf_karak_izor", "faction:wh_main_grn_necksnappers", "war", true, true, false)
            cm:force_diplomacy("faction:wh_main_grn_crooked_moon", "faction:wh_main_grn_necksnappers", "war", true, true, false)


        end
    end
end

local mcm = _G.mcm

if (not mcm) or (not sfo:save_has_mcm()) then 
    cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context) 
        sfo_eight_peaks(cm:is_new_game())
    end
else
    local sfo_set = sfo:get_settings(mcm)
    local eight_peak = sfo_set:add_tweaker("eight_peaks", "Move Eight Peaks Characters", "Moves Skarsnik to Eight peaks when he is not played. Moves Queek to Eight Peaks when he is.")
    eight_peak:add_option("move", "Enabled", "Move the Eight Peaks characters at campaign start")
    eight_peak:add_option("stay", "Disabled", "Do not move the Eight Peaks characters at campaign start")
    mcm:add_new_game_only_callback(function(context) 
        if sfo:get_settings(mcm):get_tweaker_with_key("eight_peaks"):selected_option():name() == "move" then
            sfo_eight_peaks(true)
        end
    end)
end