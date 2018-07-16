events = get_events(); cm = get_cm(); sfo = _G.sfo
local function sfo_everwatcher()
if cm:get_saved_value("sfo_lord_of_change_given") == true then
    sfo:log("The lord of change was already defeated, aborting listener setup", "sfo_lord_of_change")
    return
end
sfo:log("Adding Listener for Lord of Change recruitment", "sfo_lord_of_change")
core:add_listener(
    "SFOAddEverwatcherToPool",
    "FactionTurnStart",
    function(context)
        return context:faction():name() == "wh_main_chs_chaos" and context:faction():is_human() and cm:get_saved_value("lord_of_change_killed") == true
    end,
    function(context)
        sfo:log("Granting chaos the option to recruit the everwatcher", "listener.SFOAddEverwatcherToPool.callback(context)")
        cm:spawn_character_to_pool("wh_main_chs_chaos", "names_name_2147357518" , "names_name_2147357523", "", "", 18, true, "general", "chs_lord_of_change", true, "");
        cm:set_saved_value("sfo_lord_of_change_given", true)
    end,
    false);
end


events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() 
    sfo_everwatcher()
end;