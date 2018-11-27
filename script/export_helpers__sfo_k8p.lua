cm = get_cm(); sfo = _G.sfo

function sfo_eight_peaks()
    if cm:is_new_game() then
        out("Its a new game, moving eight peaks characters!")
        if cm:get_faction("wh_main_grn_crooked_moon"):is_human() == false then
            cm:transfer_region_to_faction("wh_main_eastern_badlands_karak_eight_peaks", "wh_main_grn_crooked_moon")
            cm:transfer_region_to_faction("wh_main_southern_grey_mountains_karak_azgaraz", "wh_main_grn_necksnappers")
            cm:teleport_to(cm:char_lookup_str(102), 466, 403, false);
            cm:teleport_to(cm:char_lookup_str(12), 737, 262, false);	
            cm:teleport_to(cm:char_lookup_str(11), 739, 262, false);
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


cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context) 
    if cm:is_new_game() then
        sfo_eight_peaks()
    end
end;