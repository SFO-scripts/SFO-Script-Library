
--# assume global class GRAIL_QUEST_MANAGER
local grail_quest_manager = {} --# assume grail_quest_manager: GRAIL_QUEST_MANAGER
--# type global QUEST_TEMPLATE = {_dilemma: string, _skill: string, --_trait: string,
--#_mission: string,  _targets: vector<string>, _armies: map<string, vector<string>>, _size: number, _level: number}


--v method(text: any)
function grail_quest_manager:log(text)
    if not __write_output_to_logfile then
        return; 
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("sfo_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("GQM:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end

--v [NO_CHECK] function()
function grail_quest_manager.enable_error_checker()
    if cm:get_saved_value("MODDER_ERROR_CHECKER") then
        return 
    end
    cm:set_saved_value("MODDER_ERROR_CHECKER", true)

    --safely calls a function
    --v function(func: function) --> any
    function safeCall(func)
        local status, result = pcall(func)
        if not status then
            SFOLOG("ERROR: ")
            SFOLOG(tostring(result))
            SFOLOG(debug.traceback());
        end
        return result;
    end

    --packs a function's args
    --v [NO_CHECK] function(...: any)
    function pack2(...) return {n=select('#', ...), ...} end
    --unpacks a function's args into a vector
    --v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
    function unpack2(t) return unpack(t, 1, t.n) end

    --wraps a function in SafeCall
    --v [NO_CHECK] function(f: function(), argProcessor: function()) --> function()
    function wrapFunction(f, argProcessor)
        return function(...)
            local someArguments = pack2(...);
            if argProcessor then
                safeCall(function() argProcessor(someArguments) end)
            end
            local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
            return unpack2(result);
            end
    end

    --used to log the calls of a function when debugging. Unused in live versions.
    --v [NO_CHECK] function(f: function(), name: string)
    function logFunctionCall(f, name)
        return function(...)
            output("function called: " .. name);
            return f(...);
        end
    end

    --logs the available methods of an object, then logs future calls to that object.
    --v [NO_CHECK] function(object: any)
    function logAllObjectCalls(object)
        local metatable = getmetatable(object);
        for name,f in pairs(getmetatable(object)) do
            if is_function(f) then
                output("Found " .. name);
                if name == "Id" or name == "Parent" or name == "Find" or name == "Position" or name == "CurrentState"  or name == "Visible"  or name == "Priority" or "Bounds" then
                    --Skip UI functions
                else
                    metatable[name] = logFunctionCall(f, name);
                end
            end
            if name == "__index" and not is_function(f) then
                for indexname,indexf in pairs(f) do
                    output("Found in index " .. indexname);
                    if is_function(indexf) then
                        f[indexname] = logFunctionCall(indexf, indexname);
                    end
                end
                output("Index end");
            end
        end
    end

    --wrap trigger event
    core.trigger_event = wrapFunction(
        core.trigger_event,
        function(ab)
        end
    );
    --wrap check callbacks
    cm.check_callbacks = wrapFunction(
        cm.check_callbacks,
        function(ab)
        end
    )

    --wrap Listeners
    local currentAddListener = core.add_listener;
    --v [NO_CHECK] function(core: any, listenerName: any, eventName: any, conditionFunc: any, listenerFunc: any, persistent: any)
    function myAddListener(core, listenerName, eventName, conditionFunc, listenerFunc, persistent)
        local wrappedCondition = nil;
        if is_function(conditionFunc) then
            --wrappedCondition =  wrapFunction(conditionFunc, function(arg) output("Callback condition called: " .. listenerName .. ", for event: " .. eventName); end);
            wrappedCondition =  wrapFunction(conditionFunc);
        else
            wrappedCondition = conditionFunc;
        end
        currentAddListener(
            core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc), persistent
            --core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc, function(arg) output("Callback called: " .. listenerName .. ", for event: " .. eventName); end), persistent
        )
    end
    core.add_listener = myAddListener;
end

--v [NO_CHECK] function()
local function get_spawn_finder()
    if _G.SPAWN_POINT_LOCATOR == nil then
        cm:load_global_script("spawns_finder")
    end
end

--v function()
function grail_quest_manager.init()
    local self = {}
    setmetatable(self, {
        __index = grail_quest_manager
    }) --# assume self: GRAIL_QUEST_MANAGER


    self._activeQuesters = {} --:map<string, number> --MAPS a TOSTRING'D CQI to the LAST DISTANCE FROM THE QUEST TARGET
    self._questTemplates = {} --:map<string, QUEST_TEMPLATE> --dilemma to quest template
    self._questSkills = {} --:map<string, string> -- skill key to dilemma key

    self._activeFactions = {} --:map<string, boolean>
    self._numActiveQuestsLocal = {} --:map<string, number>
    _G.gqm = self
end

--v function(self: GRAIL_QUEST_MANAGER, skill: string) --> boolean
function grail_quest_manager.skill_has_quest(self, skill)
    return not not self._questSkills[skill]
end

--v function(self: GRAIL_QUEST_MANAGER, dilemma: string) --> boolean
function grail_quest_manager.dilemma_is_quest_dilemma(self, dilemma)
    return not not self._questTemplates[dilemma]
end



--v function(self: GRAIL_QUEST_MANAGER, template: QUEST_TEMPLATE)
function grail_quest_manager.new_quest(self, template)
    self._questTemplates[template._dilemma] = template
    self._questSkills[template._skill] = template._dilemma
end

--v function(self: GRAIL_QUEST_MANAGER, dilemma: string, quester_cqi: CA_CQI, faction_to_spawn: string, region: string, x: number, y: number)
function grail_quest_manager.start_quest_for_character(self, dilemma, quester_cqi, faction_to_spawn, region, x, y)
    self:log("Starting quest for character ["..tostring(quester_cqi).."] from faction ["..faction_to_spawn.."] with location ["..region.."] after dilemma ["..dilemma.."]")
    local quest_char = cm:get_character_by_cqi(quester_cqi)
    if not quest_char:faction():is_human() then
        return
    end
    local template = self._questTemplates[dilemma]
    --cm:force_add_trait(cm:char_lookup_str(quester_cqi), template._trait, false)

    local units = template._armies[faction_to_spawn]
    local unit_string = units[cm:random_number(#units)]
    for i = 1, template._size - 1 do
        unit_string = unit_string .. ",".. units[cm:random_number(#units)]
    end
    self:log("Build quest army string as ["..unit_string.."] ")
    cm:create_force(
        faction_to_spawn,
        unit_string,
        region, x, y, true,
        function(spawn_cqi)
            local mission_name = template._mission..faction_to_spawn
            local bundle_key = template._dilemma.."_reward_"..cm:random_number(10)
            local marker_key = template._dilemma.."_marker"
            self:log("Spawned the quest army, new army CQI is ["..tostring(spawn_cqi).."], mission to be triggered is ["..mission_name.."] for [".. quest_char:faction():name().."], with Payload ["..bundle_key.."]")
            --add a vfx to our character
            cm:add_character_vfx(spawn_cqi, "scripted_effect3", true)
            --add buff to our character
            cm:apply_effect_bundle_to_characters_force(template._mission.."buff", spawn_cqi, 0, true)
            --add a marker to the quester
            cm:apply_effect_bundle_to_characters_force(marker_key, quester_cqi, 0, true)
            --add exp to the character
            cm:add_agent_experience(cm:char_lookup_str(spawn_cqi), template._level*1500)
            --prevent other factions from killing our amigo
            cm:force_diplomacy("all", "faction:"..faction_to_spawn, "all", false, false, false)
            cm:force_diplomacy("faction:".. quest_char:faction():name(), "faction:"..faction_to_spawn, "war", true, true, false)
            cm:cai_disable_movement_for_character(cm:char_lookup_str(spawn_cqi))
            cm:force_declare_war(quest_char:faction():name(), faction_to_spawn, false, false)
            --set up a listener to reveal shroud each turn!
            core:add_listener("BrtQuestListener"..mission_name, "FactionTurnStart", true,
                function(context)
                    cm:make_region_visible_in_shroud(quest_char:faction():name(), region)
                end, 
            true)
            --now reveal the shroud this turn
            cm:make_region_visible_in_shroud(quest_char:faction():name(), region)
            --increment the number of active quests
            self._numActiveQuestsLocal[quest_char:faction():name()] = self._numActiveQuestsLocal[quest_char:faction():name()] + 1
            cm:set_saved_value("grail_quests_"..quest_char:faction():name(), self._numActiveQuestsLocal[quest_char:faction():name()])
            --set the faction active
            cm:set_saved_value("grail_quests_active_factions_"..faction_to_spawn, true)
            --set the cqi of the mission
            cm:set_saved_value("grail_questers_"..mission_name, quester_cqi)

           --set up new mission
           local mm = mission_manager:new(
                quest_char:faction():name(),
                mission_name)
                mm:set_mission_issuer("CLAN_ELDERS")
           --mm:add_heading("mission_text_text_"..mission_name.."_head")
          -- mm:add_description("mission_text_text_"..mission_name.."_desc")
            mm:add_new_objective("ENGAGE_FORCE")
            mm:add_condition("cqi ".. tostring(cm:get_character_by_cqi(spawn_cqi):military_force():command_queue_index()))
            mm:add_condition("requires_victory");
            mm:add_payload("effect_bundle{bundle_key "..bundle_key..";turns 10;}");
            mm:trigger()
          --  mm:add_payload("money 2000");
          -- mm:add_payload("money "..tostring((template._size*50)+(150*cm:random_number(3))));
           --mm:set_turn_limit(15)
           self:log("Triggering the quest mission!")
           local enemy = cm:get_character_by_cqi(spawn_cqi)
          
           cm:callback(function()
            cm:scroll_camera_from_current(false, 1, {enemy:display_position_x(), enemy:display_position_y(), 14.7, 0.0, 12.0});
            end, 0.3)
           
           cm:replenish_action_points(cm:char_lookup_str(quester_cqi))
        end
    )
    --add a listener to see if they have moved closer to their quest!
end


--v function(self: GRAIL_QUEST_MANAGER, template: QUEST_TEMPLATE) --> string
function grail_quest_manager.pick_faction_to_spawn(self, template)
    local targets = template._targets
    local num_checks = #targets
    local index_offset = cm:random_number(num_checks)
    for i = 1, num_checks do
        local index = i + index_offset
        if index > num_checks then
            index = index - num_checks
        end
        local faction = targets[index]
        if faction and cm:get_saved_value("grail_quests_active_factions_"..faction) == true then --if faction exists but its active
            --do nothing
        elseif faction then --if it exists
            return faction --return it.
        end
    end
    return nil
end

--v function(self: GRAIL_QUEST_MANAGER, faction: string, mission: string)
function grail_quest_manager.cleanup_completed_mission(self, faction, mission)
    --decrement the number of active quests
    self._numActiveQuestsLocal[faction] = self._numActiveQuestsLocal[faction] + 1
    cm:set_saved_value("grail_quests_"..faction, self._numActiveQuestsLocal[faction])
    --get the faction
    local quest_target --:string

    --get the quester
    local quester_cqi = cm:get_saved_value("grail_questers_"..mission) --:CA_CQI
    --let them do grail quests
    cm:set_saved_value("allow_grail_for_"..tostring(quester_cqi), true)
    if mission:find("brt_questing_") then
        quest_target = mission:gsub("brt_questing_", "")
    elseif mission:find("brt_grail_") then
        quest_target = mission:gsub("brt_grail_", "")
    end
    local quest_enemy = cm:get_faction(quest_target)
    if quest_enemy:is_dead() then
        cm:set_saved_value("grail_quests_active_factions_"..quest_enemy:name(), false)
    else
        for i = 0, quest_enemy:character_list():num_items() - 1 do
            if cm:char_is_mobile_general_with_army(quest_enemy:character_list():item_at(i)) then
                cm:kill_character(quest_enemy:character_list():item_at(i):command_queue_index(), true, true)
            end
        end
        cm:set_saved_value("grail_quests_active_factions_"..quest_enemy:name(), false)
    end
    local dilemma_key = mission:gsub(quest_target, ""):gsub("brt_", "brt_quest_")
    cm:remove_effect_bundle_from_characters_force(dilemma_key.."marker", quester_cqi)
    cm:set_saved_value("grail_questers_"..mission, nil)
end

--v function(self: GRAIL_QUEST_MANAGER, faction: string, mission: string)
function grail_quest_manager.cleanup_failed_mission(self, faction, mission)
    --decrement the number of active quests
    self._numActiveQuestsLocal[faction] = self._numActiveQuestsLocal[faction] + 1
    cm:set_saved_value("grail_quests_"..faction, self._numActiveQuestsLocal[faction])
    --get the faction
    local quest_target --:string

    --get the quester
    local quester_cqi = cm:get_saved_value("grail_questers_"..mission) --:CA_CQI
    if mission:find("brt_questing_") then
        cm:remove_skill_point(cm:char_lookup_str(quester_cqi), "brt_quest_errant_small_1")
        --we remove their skill point
        quest_target = mission:gsub("brt_questing_", "")
    elseif mission:find("brt_grail_") then
        quest_target = mission:gsub("brt_grail_", "")
        cm:remove_skill_point(cm:char_lookup_str(quester_cqi), "brt_quest_errant_grand_1")
        --we remove their skill point
    end
    local quest_enemy = cm:get_faction(quest_target)
    if quest_enemy:is_dead() then
        cm:set_saved_value("grail_quests_active_factions_"..quest_enemy:name(), false)
    else
        for i = 0, quest_enemy:character_list():num_items() - 1 do
            if cm:char_is_mobile_general_with_army(quest_enemy:character_list():item_at(i)) then
                cm:kill_character(quest_enemy:character_list():item_at(i):command_queue_index(), true, true)
            end
        end
        cm:set_saved_value("grail_quests_active_factions_"..quest_enemy:name(), false)
    end
    cm:set_saved_value("grail_questers_"..mission, nil)
end


--v function(self: GRAIL_QUEST_MANAGER, human_faction: string)
function grail_quest_manager.turn_start_reveals(self, human_faction)
    for key, template in pairs(self._questTemplates) do
        for i = 1, #template._targets do
            local target = template._targets[i]
            if (not cm:get_faction(target):is_dead()) and (not cm:get_faction(target):faction_leader():region():is_null_interface()) then
                cm:make_region_visible_in_shroud(human_faction, cm:get_faction(target):faction_leader():region():name())
            end
        end
    end
end


--v function(self: GRAIL_QUEST_MANAGER, skill: string, faction: string, char: CA_CHAR)
function grail_quest_manager.offer_dilemma_for_skill(self, skill, faction, char)
    self:log("Offering dilemma  ")
    cm:trigger_dilemma(faction, self._questSkills[skill], true)
    --if the player says no to the dilemma, refund them their skill point.
    core:add_listener(
        "QuestsDilemmaChoiceMadeEvent"..tostring(char:cqi()),
        "DilemmaChoiceMadeEvent",
        function(context)
            return self:dilemma_is_quest_dilemma(context:dilemma()) and context:choice() == 1
        end,
        function(context)
            cm:remove_skill_point(cm:char_lookup_str(char), skill)
            core:remove_listener("QuestsDilemmaChoiceMadeEvent"..tostring(char:cqi()))
        end,
        false
    )
    core:add_listener(
        "QuestsDilemmaChoiceMadeEvent"..tostring(char:cqi()),
        "DilemmaChoiceMadeEvent",
        function(context)
            return self:dilemma_is_quest_dilemma(context:dilemma()) and context:choice() == 0
        end,
        function(context)
            self:log("Player accepted quest from dilemma ["..context:dilemma().."]! Resolving a spawn!")
            core:remove_listener("QuestsDilemmaChoiceMadeEvent"..tostring(char:cqi()))
            local faction_to_spawn = self:pick_faction_to_spawn(self._questTemplates[context:dilemma()])
            self:log("Faction to spawn resolved to ["..faction_to_spawn.."]")
            if not _G.SPAWN_POINT_LOCATOR then
                get_spawn_finder()
            end
            --here, we want to find multiple valid spawns
            local spawns = {} --:map<string, true>
            --this one gets repeatedly passed as the black list
            local full_spawns = {} --:map<string, {x: number, y:number}>
            --this one holds valid coordinates
            local num_spawns = 0
            --this one holds the number of spawns we've found
            while num_spawns < 5 do --find spawns until we have 3 to randomly choose from
                local region, x, y = _G.SPAWN_POINT_LOCATOR.find_spawn_in_region_bordering_character(char, cm:get_faction(faction_to_spawn), false, spawns)
                if region then
                    spawns[region] = true
                    full_spawns[region] = {x = x, y = y}
                    num_spawns = num_spawns + 1
                else
                    if region then
                        spawns[region] = true
                        full_spawns[region] = {x = x, y = y}
                        num_spawns = num_spawns + 1
                    else
                        break --we can't find a spawn, so lets stop trying.
                    end
                end
            end
            if num_spawns == 0 then --if we didn't find any spawns, we need to warn the log. This shouldn't happen.
                self:log("FATAL: Could not resolve a spawn point for a questing army.")
                return
            end
            local chance_var = 100/num_spawns --:number
            --we define this to keep it static
            for region, spawn_data in pairs(full_spawns) do
                if (num_spawns == 0) or (cm:random_number(100) > (100/chance_var)) then --if its the last spawn we have, always take it. Otherwise, 50% chance.
                    self:start_quest_for_character(context:dilemma(), char:cqi(), faction_to_spawn, region, spawn_data.x, spawn_data.y)
                    break --only spawn once
                else
                    num_spawns = num_spawns - 1 --reduce the number of remeaning spawns to check
                end
            end
            --self:start_quest_for_character(context:dilemma(), char:cqi(), faction_to_spawn, region, x, y)
        end,
        false
    )
end


grail_quest_manager.init()
cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context)
    for i = 1, #cm:get_human_factions() do
        local c_fac = cm:get_human_factions()[i]
        _G.gqm._numActiveQuestsLocal[c_fac] = cm:get_saved_value("grail_quests_"..c_fac) or 0
    end

end


core:add_listener(
    "GrailQuestsRevealTurnStart",
    "FactionTurnStart",
    function(context)
        return context:faction():is_human() and context:faction():subculture() == "wh_main_sc_brt_bretonnia"
    end,
    function(context)
        _G.gqm:turn_start_reveals(context:faction():name())
    end,
    true
)

core:add_listener(
	"GrailQuestSucceeeded",
	"MissionSucceeded",
	true,
	function(context)
		local ok, err = pcall(function()
            _G.gqm:cleanup_completed_mission(context:faction():name(), context:mission():mission_record_key())
		end)
		if not ok then
		end
	end,
	true);

core:add_listener(
	"GrailQuestSucceeededCancalled",
	"MissionCancelled",
	true,
	function(context)
		local ok, err = pcall(function()
			_G.gqm:cleanup_failed_mission(context:faction():name(), context:mission():mission_record_key())
			end)
			if not ok then
			end
	end,
	true);
