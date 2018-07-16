events = get_events(); cm = get_cm(); sfo = _G.sfo
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
			cm:remove_restricted_building_level_record(faction_key, "VENRIS_ADDbuilding_key")
		end
		NORSCAN_CHAOS_INVASION_STATUS = "dead";
	end
end
events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() 
	if cm:is_new_game() then
		for i = 1, #cm:get_human_factions() do
			cm:add_restricted_building_level_record(cm:get_human_factions()[i], "VENRIS_ADDbuilding_key")
		end
	end
	sfo_replace_chaos_died_function()
end;