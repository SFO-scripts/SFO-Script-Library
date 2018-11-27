cm = get_cm()


function ven_spawn_characters()
	if cm:model():campaign_name("main_warhammer") then
		if cm:is_new_game() then

			cm:create_agent(
							"wh_main_dwf_karak_kadrin",
							"champion",
							"dwf_cha_slayer",
							718,
							453,
							false,
							function(cqi)
								cm:replenish_action_points(cm:char_lookup_str(cqi));
							end
						);
		end;
	end;
end;

cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context) 
	ven_spawn_characters();
end;