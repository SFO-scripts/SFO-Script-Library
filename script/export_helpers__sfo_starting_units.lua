CONST_SFO_STARTING_UNITS = {
    ["wh_main_emp_empire"] = {
        "wh_main_emp_inf_greatswords",
        "wh_main_emp_inf_greatswords"
    },
    ["wh_main_dwf_dwarfs"] = {
        "wh_main_dwf_inf_longbeards_1"
    }
} --:map<string, vector<string>>

events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() 
    _G.sfo:log("Checking to grant units")
    if cm:is_new_game() then
        for faction_key, units in pairs(CONST_SFO_STARTING_UNITS) do
            local faction = cm:get_faction(faction_key)
            if faction then
                for i = 1, #units do
                    _G.sfo:log("Granting Units: "..faction_key.." given ".. units[i])
                    cm:grant_unit_to_character(cm:char_lookup_str(faction:faction_leader():cqi()), units[i])
                end
            end
        end
    end
end;