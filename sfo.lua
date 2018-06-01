--sfo management object
_G.main_env = getfenv(1) 
local sfo_manager = {} --# assume sfo_manager: SFO_MANAGER

--v function() --> SFO_MANAGER
function sfo_manager.new()
    local self = {}
    setmetatable(self, {
        __index = sfo_manager
    })
    --# assume self: SFO_MANAGER


    return self
end

--v function (self: SFO_MANAGER)
function sfo_manager.green_knight_experience(self)
    SFOLOG("Removing the vanilla Green Knight listener and creating a new one.", "sfo_manager.green_knight_experience(self)")
    core:remove_listener("Bret_UniqueAgentSpawned")
    core:add_listener(
        "GreenKnightExp",
        "UniqueAgentSpawned",
        function(context)
            local character = context:unique_agent_details():character();
            SFOLOG("Unique Agent Spawned, checking if they are the green knight", "listener.GreenKnightExp.condition(context)")
            return not character:is_null_interface() and character:character_subtype("dlc07_brt_green_knight");
        end,
        function(context)

            local character = context:unique_agent_details():character();
            --# assume character: CA_CHAR
            if character:rank() < 40 then
                SFOLOG("Leveling Up the Green Knight!", "listener.GreenKnightExp.callback(context)")
				local char_str = cm:char_lookup_str(character:cqi());
				
                cm:add_agent_experience(char_str, 1151000);
                cm:replenish_action_points(char_str);
                for i = 1, 33 do
					cm:force_add_skill(char_str, "wh_dlc07_skill_green_knight_dummy");
                end
                if character:faction():is_human() and not cm:is_multiplayer() then
                    -- fly camera to Green Knight
                    cm:scroll_camera_from_current(1, false, {character:display_position_x(), character:display_position_y(), 14.7, 0.0, 12.0});
                end;

            end
        end,
        true);
end;

--v function(self: SFO_MANAGER)
function sfo_manager.lord_of_change_recruitment(self)
    if cm:get_saved_value("sfo_lord_of_change_given") == true then
        SFOLOG("The lord of change was already defeated, aborting listener setup", "sfo_manager.lord_of_change_recruitment(self)")
        return
    end
    SFOLOG("Adding Listener for Lord of Change recruitment", "sfo_manager.lord_of_change_recruitment(self)")
    core:add_listener(
        "SFOAddEverwatcherToPool",
        "FactionTurnStart",
        function(context)
            return context:faction():name() == "wh_main_chs_chaos" and context:faction():is_human() and cm:get_saved_value("lord_of_change_killed") == true
        end,
        function(context)
            SFOLOG("Granting chaos the option to recruit the everwatcher", "listener.SFOAddEverwatcherToPool.callback(context)")
            cm:spawn_character_to_pool("wh_main_chs_chaos", "names_name_2147357518" , "names_name_2147357523", "", "", 18, true, "general", "chs_lord_of_change", true, "");
            cm:set_saved_value("sfo_lord_of_change_given", true)
            SFOLOG("break", "check")
        end,
        false);
end





SFOLOG("SFO MANAGER INIT COMPLETE", "file.sfo_manager")
return {
    new = sfo_manager.new
}