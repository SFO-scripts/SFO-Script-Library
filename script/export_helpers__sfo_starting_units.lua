cm = get_cm(); sfo = _G.sfo
CONST_SFO_STARTING_UNITS = {
    ["wh_main_emp_middenland"] = {
        "emp_wolf_knight",
        "emp_wolf_knight"
    },
    ["wh2_main_skv_clan_mors"] = {
        "wh2_main_skv_inf_stormvermin_0",
        "wh2_main_skv_inf_stormvermin_0"
    },
    ["wh2_main_lzd_last_defenders"] = {
        "wh2_main_lzd_mon_carnosaur_blessed_0"
    }
} --:map<string, vector<string>>

CONST_SFO_REMOVE_UNITS = {

} --:map<string, vector<string>>


cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context) 
    _G.sfo:log("Checking to grant units")
    if cm:is_new_game() then
        for faction_key, units in pairs(CONST_SFO_STARTING_UNITS) do
            local faction = cm:get_faction(faction_key)
            if faction and faction:faction_leader():has_military_force() then
                for i = 1, #units do
                    _G.sfo:log("Granting Units: "..faction_key.." given ".. units[i])
                    cm:grant_unit_to_character(cm:char_lookup_str(faction:faction_leader():cqi()), units[i])
                end
            end
        end
        for faction_key, units in pairs(CONST_SFO_REMOVE_UNITS) do
            local faction = cm:get_faction(faction_key)
            if faction and faction:faction_leader():has_military_force() then
                for i = 1, #units do
                    if faction:faction_leader():military_force():unit_list():has_unit(units[i]) then
                        _G.sfo:log("Removing unit Units: "..faction_key.." removed ".. units[i])
                        cm:remove_unit_from_character(cm:char_lookup_str(faction:faction_leader():cqi()), units[i])
                    end
                end
            end
        end
    end
end;

