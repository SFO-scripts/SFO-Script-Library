--sfo management object
_G.main_env = getfenv(1) 
local sfo = {} --# assume sfo: SFO_MANAGER


    core:add_listener(
        "GreenKnightExp",
        "UniqueAgentSpawned",
        function(context)
            local character = context:unique_agent_details():character();
            SFOLOG("Unique Agent Spawned, checking if they are the green knight", "Listener.GreenKnightExp.Condition")
            return not character:is_null_interface() and character:character_subtype("dlc07_brt_green_knight");
        end,
        function(context)
            SFOLOG("Leveling Up the Green Knight!", "Listener.GreenKnightExp.Callback")
            local character = context:unique_agent_details():character();
            --# assume character: CA_CHAR
            if character:rank() < 30 then
                local char_str = char_lookup_str(character:command_queue_index());
                cm:add_agent_experience(char_str, _G.get_exp_at_level(10))
            end
        end,
        false);

