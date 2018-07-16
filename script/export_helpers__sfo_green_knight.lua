cm = get_cm(); events = get_events(); sfo =_G.sfo

local function sfo_green_knight()
    sfo:log("Removing the vanilla Green Knight listener and creating a new one.", "sfo_green_knight")
    core:remove_listener("Bret_UniqueAgentSpawned")
    core:add_listener(
        "GreenKnightExp",
        "UniqueAgentSpawned",
        function(context)
            local character = context:unique_agent_details():character();
            sfo:log("Unique Agent Spawned, checking if they are the green knight", "listener.GreenKnightExp.condition(context)")
            return not character:is_null_interface() and character:character_subtype("dlc07_brt_green_knight");
        end,
        function(context)

            local character = context:unique_agent_details():character();
            --# assume character: CA_CHAR
            if character:rank() < 40 then
                sfo:log("Leveling Up the Green Knight!", "listener.GreenKnightExp.callback(context)")
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
end

events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() 
    sfo_green_knight()
end;