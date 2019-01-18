





local confed_reward_custom_functions = {} --:map<string, function(faction: CA_FACTION, key: string)>


--these functions define what each function key does. 
confed_reward_custom_functions["incident_trigger"] = function(faction, key)
    cm:trigger_incident(faction:name(), key, true)
end
confed_reward_custom_functions["dilemma_trigger"] = function(faction, key)
    cm:trigger_dilemma(faction:name(), key, true)
end

confed_reward_custom_functions["bundle_perm"] = function(faction, key)
    cm:apply_effect_bundle(key, faction:name(), 0)
end

confed_reward_custom_functions["bundle_5"] = function(faction, key)
    cm:apply_effect_bundle(key, faction:name(), 5)
end

--enter the faction name of who should be confederated. Then enter a function key, and its associated string key.
--the current ones are enumerated right above this.
local confed_rewards = {
    ["wh_main_brt_bretonnia"] = {"bundle_5", "my_effect_bundle"},
    ["wh_main_brt_carcassone"] = {"dilemma_trigger", "my_dilemma_key"}
}--:map<string, {string, string}>


core:add_listener(
    "ConfederationRewards",
    "FactionJoinsConfederation",
    function(context)
        return not not confed_rewards[context:faction():name()]
    end,
    function(context)
        local instruction = confed_rewards[context:faction():name()][1]
        local key = confed_rewards[context:faction():name()][2]
        confed_reward_custom_functions[instruction](context:confederation():name(), key)
    end,
    true
)