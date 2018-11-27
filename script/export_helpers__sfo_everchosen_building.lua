 cm = get_cm(); sfo = _G.sfo
local function sfo_replace_chaos_died_function()
	--v function(faction_key: string, is_ally: boolean)
	function NCI_Chaos_Died(faction_key, is_ally)
		if is_ally == true then
			-- Remove bonus
			cm:remove_effect_bundle("wh_dlc08_bundle_follow_archaon", faction_key);
		else
			-- Give (real) bonus
			cm:remove_effect_bundle("wh_dlc08_bundle_true_everchosen_dummy", faction_key);
			cm:remove_effect_bundle("wh_dlc08_bundle_true_everchosen", faction_key);
			cm:apply_effect_bundle("wh_dlc08_bundle_true_everchosen", faction_key, 0);
			cm:remove_restricted_building_level_record(faction_key, "nor_chaos_chosen")
		end
		NORSCAN_CHAOS_INVASION_STATUS = "dead";
	end
end
cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context) 
	if cm:is_new_game() then
		for i = 1, #cm:get_human_factions() do
			cm:add_restricted_building_level_record(cm:get_human_factions()[i], "nor_chaos_chosen")
		end
	end
	sfo_replace_chaos_died_function()
end;