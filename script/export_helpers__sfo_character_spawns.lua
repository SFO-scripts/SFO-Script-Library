function chs_cha_bloodthirster_add()
	if not cm:get_faction("wh_main_chs_chaos") then
		return
	end
    if not cm:get_faction("wh_main_chs_chaos"):is_dead() then
        if not cm:get_saved_value("chs_cha_bloodthirster_unlocked") then 
            cm:spawn_character_to_pool("wh_main_chs_chaos", "names_name_1", "names_name_2", "", "", 50, true, "dignitary", "chs_cha_bloodthirster", true, "");
            cm:set_saved_value("chs_cha_bloodthirster_unlocked", true);
        end;
    end;
end;

cm:add_first_tick_callback(function()
    chs_cha_bloodthirster_add()
end)


function dwf_cha_slayer_add()
	if not cm:get_faction("wh_main_dwf_karak_kadrin") then
		return
	end
    if not cm:get_faction("wh_main_dwf_karak_kadrin"):is_dead() then
        if not cm:get_saved_value("dwf_cha_slayer_unlocked") then 
            cm:spawn_character_to_pool("wh_main_dwf_karak_kadrin", "names_name_3", "names_name_4", "", "", 50, true, "champion", "dwf_cha_slayer", true, "");
            cm:set_saved_value("dwf_cha_slayer_unlocked", true);
        end;
    end;
end;

cm:add_first_tick_callback(function()
    dwf_cha_slayer_add()
end)