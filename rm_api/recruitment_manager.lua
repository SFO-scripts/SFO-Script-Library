--[[
New System Outline




--]]



--Log script to text
--v function(text: string | number | boolean | CA_CQI)
local function RCLOG(text)
    if not __write_output_to_logfile then
        return;
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("RM:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end

--Reset the log at session start
--v function()
local function RCSESSIONLOG()
    if not __write_output_to_logfile then
        return;
    end
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string

    local popLog = io.open("warhammer_expanded_log.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close() 
end
RCSESSIONLOG()



--v [NO_CHECK] function()
function error_check()
    --Vanish's PCaller
    --All credits to vanish
    --v function(func: function) --> any
    function safeCall(func)
        --RCLOG("safeCall start");
        local status, result = pcall(func)
        if not status then
            RCLOG(tostring(result), "ERROR CHECKER")
            RCLOG(debug.traceback(), "ERROR CHECKER");
        end
        --RCLOG("safeCall end");
        return result;
    end
    
    --local oldTriggerEvent = core.trigger_event;
    
    --v [NO_CHECK] function(...: any)
    function pack2(...) return {n=select('#', ...), ...} end
    --v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
    function unpack2(t) return unpack(t, 1, t.n) end
    
    --v [NO_CHECK] function(f: function(), argProcessor: function()) --> function()
    function wrapFunction(f, argProcessor)
        return function(...)
            --RCLOG("start wrap ");
            local someArguments = pack2(...);
            if argProcessor then
                safeCall(function() argProcessor(someArguments) end)
            end
            local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
            --for k, v in pairs(result) do
            --    RCLOG("Result: " .. tostring(k) .. " value: " .. tostring(v));
            --end
            --RCLOG("end wrap ");
            return unpack2(result);
            end
    end
    
    -- function myTriggerEvent(event, ...)
    --     local someArguments = { ... }
    --     safeCall(function() oldTriggerEvent(event, unpack( someArguments )) end);
    -- end
    
    --v [NO_CHECK] function(fileName: string)
    function tryRequire(fileName)
        local loaded_file = loadfile(fileName);
        if not loaded_file then
            RCLOG("Failed to find mod file with name " .. fileName)
        else
            RCLOG("Found mod file with name " .. fileName)
            RCLOG("Load start")
            local local_env = getfenv(1);
            setfenv(loaded_file, local_env);
            loaded_file();
            RCLOG("Load end")
        end
    end
    
    --v [NO_CHECK] function(f: function(), name: string)
    function logFunctionCall(f, name)
        return function(...)
            RCLOG("function called: " .. name);
            return f(...);
        end
    end
    
    --v [NO_CHECK] function(object: any)
    function logAllObjectCalls(object)
        local metatable = getmetatable(object);
        for name,f in pairs(getmetatable(object)) do
            if is_function(f) then
                RCLOG("Found " .. name);
                if name == "Id" or name == "Parent" or name == "Find" or name == "Position" or name == "CurrentState"  or name == "Visible"  or name == "Priority" or "Bounds" then
                    --Skip
                else
                    metatable[name] = logFunctionCall(f, name);
                end
            end
            if name == "__index" and not is_function(f) then
                for indexname,indexf in pairs(f) do
                    RCLOG("Found in index " .. indexname);
                    if is_function(indexf) then
                        f[indexname] = logFunctionCall(indexf, indexname);
                    end
                end
                RCLOG("Index end");
            end
        end
    end
    
    -- logAllObjectCalls(core);
    -- logAllObjectCalls(cm);
    -- logAllObjectCalls(game_interface);
    
    core.trigger_event = wrapFunction(
        core.trigger_event,
        function(ab)
            --RCLOG("trigger_event")
            --for i, v in pairs(ab) do
            --    RCLOG("i: " .. tostring(i) .. " v: " .. tostring(v))
            --end
            --RCLOG("Trigger event: " .. ab[1])
        end
    );
    
    cm.check_callbacks = wrapFunction(
        cm.check_callbacks,
        function(ab)
            --RCLOG("check_callbacks")
            --for i, v in pairs(ab) do
            --    RCLOG("i: " .. tostring(i) .. " v: " .. tostring(v))
            --end
        end
    )
    
    local currentAddListener = core.add_listener;
    --v [NO_CHECK] function(core: any, listenerName: any, eventName: any, conditionFunc: any, listenerFunc: any, persistent: any)
    function myAddListener(core, listenerName, eventName, conditionFunc, listenerFunc, persistent)
        local wrappedCondition = nil;
        if is_function(conditionFunc) then
            --wrappedCondition =  wrapFunction(conditionFunc, function(arg) RCLOG("Callback condition called: " .. listenerName .. ", for event: " .. eventName); end);
            wrappedCondition =  wrapFunction(conditionFunc);
        else
            wrappedCondition = conditionFunc;
        end
        currentAddListener(
            core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc), persistent
            --core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc, function(arg) RCLOG("Callback called: " .. listenerName .. ", for event: " .. eventName); end), persistent
        )
    end
    core.add_listener = myAddListener;
end
if __write_output_to_logfile then
    error_check()
end

--ui utility to get the names of the units in the queue by reading the UI.
--v function(index: number) --> string
function GetQueuedUnit(index)
    local queuedUnit = find_uicomponent(core:get_ui_root(), "main_units_panel", "units", "QueuedLandUnit " .. index);
    if not not queuedUnit then
        queuedUnit:SimulateMouseOn();
        local unitInfo = find_uicomponent(core:get_ui_root(), "UnitInfoPopup", "tx_unit-type");
        local rawstring = unitInfo:GetStateText();
        local infostart = string.find(rawstring, "unit/") + 5;
        local infoend = string.find(rawstring, "]]") - 1;
        local QueuedUnitName = string.sub(rawstring, infostart, infoend)
        RCLOG("Found queued unit ["..QueuedUnitName.."] at ["..index.."] ")
        return QueuedUnitName
    else
        return nil
    end
end

local recruiter_manager = {} --# assume recruiter_manager: RECRUITER_MANAGER

--v function()
function recruiter_manager.init()
    local self = {}
    setmetatable(self, {
        __index = recruiter_manager,
        __tostring = function() return "RECRUITER_MANAGER" end
    }) --# assume self: RECRUITER_MANAGER

    --Stores path sets: used to find the way to the UI
    self._UIPaths = {} --:map<string, RECRUITER_PATHSET>
    self._subculturePathSets = {} --:map<string, string>
    self._subtypePathSets = {} --:map<string, string>

    --stores unit records.
    --unit records contain weights, groups and UI profiles.
    self._recruiterUnits = {} --:map<string, RECRUITER_UNIT>
    --stores copies of "fake" unit records for use by characters as overrides for information
    self._overrideUnits = {} --:map<string, RECRUITER_UNIT>
    --stores subtypes who get specific overriden unit records added to them at creation
    self._overrideSubtypeFilters = {} --:map<string, vector<string>>
    --stores skills which add a specific overriden unit record to a character
    self._overrideSkillRequirements = {} --:map<string, map<string, string>>
    --same for traits
    self._overrideTraitRequirements = {} --:map<string, map<string, string>>

    --stores recruiter characters in some structures that are useful.
    self._recruiterCharacters =  {} --:map<CA_CQI, RECRUITER_CHARACTER>
    self._factionRecCharacters = {} --:map<string, map<CA_CQI, RECRUITER_CHARACTER>>
    --stores the current player character. 
    self._UICurrentCharacter = nil --:CA_CQI

    --stores faction wide restrictions, which prevent recruitment for a whole faction.
    self._factionWideRestrictions = {} --:map<string, map<string, boolean>>
    --stores the acompanying lock texts by faction for units
    self._UIFactionWideLockTexts = {} --:map<string, map<string, string>>

    --individual unit quantity limits
    self._characterUnitLimits = {} --:map<string, number>

    --Group UI names
    self._UIGroupNames = {} --:map<string, string>
    --unit group quantity limits
    self._groupUnitLimits = {} --:map<string, number>
    --grouped units
    self._groupToUnits = {} --:map<string, vector<string>>

    --stores default acceptible units for the AI to use
    self._AIDefaultUnits = {} --:map<string, vector<string>>
    --flags whether to enforce AI functionality
    self._AIEnforce = true --:boolean

    _G.rm = self
end

--log text
--v function(self: RECRUITER_MANAGER, text: any) 
function recruiter_manager.log(self, text)
    RCLOG(tostring(text))
end

--ui utility to get the names of the units in the queue by reading the UI.
--v function(self: RECRUITER_MANAGER, index: number) --> string
function recruiter_manager.GetQueuedUnit(self, index)
    local queuedUnit = find_uicomponent(core:get_ui_root(), "main_units_panel", "units", "QueuedLandUnit " .. index);
    if not not queuedUnit then
        queuedUnit:SimulateMouseOn();
        local unitInfo = find_uicomponent(core:get_ui_root(), "UnitInfoPopup", "tx_unit-type");
        local rawstring = unitInfo:GetStateText();
        local infostart = string.find(rawstring, "unit/") + 5;
        local infoend = string.find(rawstring, "]]") - 1;
        local QueuedUnitName = string.sub(rawstring, infostart, infoend)
        self:log("Found queued unit ["..QueuedUnitName.."] at ["..index.."] ")
        return QueuedUnitName
    else
        return nil
    end
end

---------------------------------
----FACTION WIDE RESTRICTIONS----
---------------------------------

--v function(self: RECRUITER_MANAGER, unitID: string, faction_name: string) --> boolean
function recruiter_manager.is_unit_faction_restricted(self, unitID, faction_name)
    if self._factionWideRestrictions[unitID] == nil then
        return false
    end
    return not not self._factionWideRestrictions[unitID][faction_name]
end

--v function(self: RECRUITER_MANAGER, unitID: string, faction_name: string, restrict: boolean)
function recruiter_manager.set_unit_restriction_for_faction(self, unitID, faction_name, restrict)
    self._factionWideRestrictions[unitID] = self._factionWideRestrictions[unitID] or {}
    self._factionWideRestrictions[unitID][faction_name] = restrict
    if not restrict then
        if self._UIFactionWideLockTexts[unitID] then
            self._UIFactionWideLockTexts[unitID][faction_name] = nil
        end
    end
end

--v function(self: RECRUITER_MANAGER, unitID: string, faction_name: string, lock_reason: string) 
function recruiter_manager.add_factionwide_lock_text(self, unitID, faction_name, lock_reason)
    self._UIFactionWideLockTexts[unitID] = self._UIFactionWideLockTexts[unitID] or {}
    if self._UIFactionWideLockTexts[unitID][faction_name] then
        self._UIFactionWideLockTexts[unitID][faction_name] = self._UIFactionWideLockTexts[unitID][faction_name] .. "\n" .. lock_reason
    else
        self._UIFactionWideLockTexts[unitID][faction_name] = lock_reason
    end
end


--group ui names--
------------------

--get the map of groups to UI names
--v function(self: RECRUITER_MANAGER) --> map<string, string>
function recruiter_manager.get_group_ui_names(self)
    return self._UIGroupNames
end

--get a specific UI name
--v function(self: RECRUITER_MANAGER, groupID: string) --> string
function recruiter_manager.get_ui_name_for_group(self, groupID)
    if self:get_group_ui_names()[groupID] == nil then
        self._UIGroupNames[groupID] = groupID
    end
    return self:get_group_ui_names()[groupID]
end

--set the UI name for a group
--publically available function
--v function(self: RECRUITER_MANAGER, groupID: string, UIname: string)
function recruiter_manager.set_ui_name_for_group(self, groupID, UIname)
    if not is_string(groupID) then
        self:log("ERROR: set_ui_name_for_group called but the provided group name is not a string!")
        return 
    end
    if not is_string(UIname) then
        self:log("ERROR: set_ui_name_for_group called but the provided unit key is not a string!")
        return 
    end
    self._UIGroupNames[groupID] = UIname
end



------------------------------
------------------------------
----------SUBOBJECTS----------
------------------------------
------------------------------
--TODO immport
cm:load_global_script("rm_api/recruiter_pathset")
--# assume recruiter_pathset.new_path: function(paths: map<string, vector<string>>, merc_path: vector<string>, conditional_tests: (function(rec_char: RECRUITER_CHARACTER) --> vector<string>)?) --> RECRUITER_PATHSET
--------------------------
----SUBOBJECT HANDLERS----
--------------------------


--v function(self: RECRUITER_MANAGER,pathID: string, paths: map<string, vector<string>>, merc_path: vector<string>, conditional_tests: (function(rec_char: RECRUITER_CHARACTER) --> vector<string>)?) 
function recruiter_manager.create_path_set(self, pathID, paths, merc_path, conditional_tests)
    local new_path = recruiter_pathset.new_path(paths, merc_path, conditional_tests)
    self._UIPaths[pathID] = new_path
end

--v function(self: RECRUITER_MANAGER, pathID: string) --> RECRUITER_PATHSET
function recruiter_manager.get_path_set(self, pathID)
    return self._UIPaths[pathID]
end

---------------------------
----RECRUITER CHARACTER----
---------------------------
--TODO import
cm:load_global_script("rm_api/recruiter_character")
--# assume recruiter_character.new: function(manager: RECRUITER_MANAGER, cqi: CA_CQI) --> RECRUITER_CHARACTER

--------------------------
----SUBOBJECT HANDLERS----
--------------------------

--get all characters in the rm
--v function(self: RECRUITER_MANAGER) --> map<CA_CQI, RECRUITER_CHARACTER>
function recruiter_manager.characters(self)
    return self._recruiterCharacters
end

--create and return a new character in the rm
--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_manager.new_character(self, cqi)
    local new_char = recruiter_character.new(self, cqi)
    local ca_char = cm:get_character_by_cqi(cqi)
    local faction = ca_char:faction():name()
    self._factionRecCharacters[faction] = self._factionRecCharacters[faction] or {}
    self._factionRecCharacters[faction][cqi] = new_char
    self._recruiterCharacters[cqi] = new_char
    self:log("Created character ["..tostring(cqi).."], firing UIEvent!")
    core:trigger_event("UIRecruiterCharacterCreated", ca_char)
    return new_char
end

--return whether a character exists in the rm
--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> boolean
function recruiter_manager.has_character(self, cqi)
    return not not self._recruiterCharacters[cqi]
end

--get a character by cqi from the rm
--v function(self: RECRUITER_MANAGER, cqi: CA_CQI) --> RECRUITER_CHARACTER
function recruiter_manager.get_character_by_cqi(self, cqi)
    if cqi == nil then
        self:log("Warning, asked for a char with cqi [nil]")
        return nil
    end
    if self:has_character(cqi) then
        --if we already have that character, return it.
        return self._recruiterCharacters[cqi]
    else
        --otherwise, return a new character
        self:log("Requested character with ["..tostring(cqi).."] who does not exist, creating them!")
        return self:new_character(cqi)
    end
end

--return whether the current character has ever been set
--v function(self: RECRUITER_MANAGER) --> boolean
function recruiter_manager.has_currently_selected_character(self)
    return not not self._UICurrentCharacter
end



--return the current character's object
--v function(self: RECRUITER_MANAGER) --> RECRUITER_CHARACTER
function recruiter_manager.current_character(self)
    return self:get_character_by_cqi(self._UICurrentCharacter)
end

--set the current character by CQI
--v function(self: RECRUITER_MANAGER, cqi:CA_CQI)
function recruiter_manager.set_current_character(self, cqi)
    self:log("Set the current character to cqi ["..tostring(cqi).."]")
    self._UICurrentCharacter = cqi
    if not self:has_character(cqi) then
        self:new_character(cqi)
    end
end

-----------------------
----RECRUITER UNITS----
-----------------------
--TODO import
cm:load_global_script("rm_api/recruiter_unit")
--# assume recruiter_unit.create_record: function( manager: RECRUITER_MANAGER, main_unit_key: string, base_unit: RECRUITER_UNIT?) --> RECRUITER_UNIT
--------------------------
----SUBOBJECT HANDLERS----
--------------------------



--v function(self: RECRUITER_MANAGER) --> map<string, RECRUITER_UNIT>
function recruiter_manager.units(self)
    return self._recruiterUnits
end


--v function(self: RECRUITER_MANAGER, unitID: string) --> RECRUITER_UNIT
function recruiter_manager.new_unit(self, unitID)
    local new_unit = recruiter_unit.create_record(self, unitID)
    self._recruiterUnits[unitID] = new_unit
    return new_unit
end

--v function(self: RECRUITER_MANAGER, unitID: string, rec_char: RECRUITER_CHARACTER?) --> RECRUITER_UNIT
function recruiter_manager.get_unit(self, unitID, rec_char)
    if rec_char then -- if we are passed a rec char, check if they have an owned unit.
        --# assume rec_char: RECRUITER_CHARACTER!
        if rec_char:has_own_unit(unitID) then
            return rec_char:get_owned_unit(unitID)
        end
    end
    if self._recruiterUnits[unitID] then
        return self._recruiterUnits[unitID]
    else
        return self:new_unit(unitID)
    end
end


------------------------------------------------------------
-------------------END OF SUBOBJECT STUFF-------------------
------------------------------------------------------------

----UNIT WEIGHTING SYSTEM----
-----------------------------
--get the weight of a specific unit
--v function(self: RECRUITER_MANAGER, unitID: string, rec_char: RECRUITER_CHARACTER?) --> number
function recruiter_manager.get_weight_for_unit(self, unitID, rec_char)
    return self:get_unit(unitID, rec_char):weight()
end

--set the weight for a unit within their groups.
--publically available function
--v function(self: RECRUITER_MANAGER, unitID: string, weight: number)
function recruiter_manager.set_weight_for_unit(self, unitID, weight)
    if not is_string(unitID) then
        self:log("set_weight_for_unit called with bad arg #1, unitID must be a string")
        return
    elseif not is_number(weight) then
        self:log("set_weight_for_unit called with bad arg #2, weight must be a number")
        return
    end

    self:get_unit(unitID):set_unit_weight(weight)
end

--v function(self: RECRUITER_MANAGER, abstractionID: string, weight: number)
function recruiter_manager.set_weight_for_overridden_unit(self, abstractionID, weight)
    if not is_string(abstractionID) then
        self:log("set_weight_for_overridden_unit called with bad arg #1, abstractionID must be a string")
        return
    elseif not self._overrideUnits[abstractionID] then
        self:log("set_weight_for_overridden_unit called with bad arg #1, abstractionID does not refer to any existing override abstraction")
        return
    elseif not is_number(weight) then
        self:log("set_weight_for_overriden_unit called with bad arg #2, weight must be a number")
        return
    end
    self._overrideUnits[abstractionID]:set_unit_weight(weight)

end

-----------------------------
----UNIT OVERRIDE OBJECTS----
-----------------------------

--v function(self: RECRUITER_MANAGER, unitID: string, abstractionID: string) --> RECRUITER_UNIT
function recruiter_manager.create_unit_override(self, unitID, abstractionID)
    local new_unit = recruiter_unit.create_record(self, unitID)
    self._overrideUnits[abstractionID] = new_unit
    return new_unit
end

-----------------------
----UNIT GROUPS API----
-----------------------


--add a unit to a group
--v function(self: RECRUITER_MANAGER, unitID: string, groupID: string, abstractID: string?)
function recruiter_manager.add_unit_to_group(self, unitID, groupID, abstractID)
    local unit = self:get_unit(unitID)
    if abstractID then
        --# assume abstractID: string!
        unit = self.overrideUnits[abstractID]
    end
    unit:add_group_to_unit(groupID)

    self._groupToUnits[groupID] = self._groupToUnits[groupID] or {}
    table.insert(self._groupToUnits[groupID], unitID)
end

--get the list of units for a specific group
--v function(self: RECRUITER_MANAGER, groupID: string) --> vector<string>
function recruiter_manager.get_units_in_group(self, groupID)
    if self._groupToUnits[groupID] == nil then
        --if the group hasn't been used at all, give it a default blank list.
        self._groupToUnits[groupID] = {}
    end
    return self._groupToUnits[groupID]
end




------------------------
----CALLS FOR CHECKS----
------------------------

--v function(self: RECRUITER_MANAGER, rec_char: RECRUITER_CHARACTER, ui_option_table: vector<string>?)
function recruiter_manager.check_all_units_on_character(self, rec_char, ui_option_table)
    local clock = os.clock()
    local character_units = rec_char:get_army_counts()
    local character_queue --:map<string, number>
    if rec_char._isHuman and (rec_char:is_queue_stale() == false) then
        character_queue = rec_char:get_queue_counts()
    else
        character_queue = {}
    end
    for unitID, _ in pairs(character_units) do
        local unit = self:get_unit(unitID, rec_char)
        unit:check_for_character(rec_char)
        for groupID, _ in pairs(unit:groups()) do
            local grouped_units = self:get_units_in_group(groupID)
            for i = 1, #grouped_units do
                local c_unitID = grouped_units[i]
                --avoid as much duplication as possible
                if (not character_units[c_unitID]) and (not character_queue[c_unitID]) then
                    self:get_unit(c_unitID, rec_char):check_for_character(rec_char)
                end
            end
        end
    end
    for unitID, _ in pairs(character_queue) do
        --avoid duplication
        if not character_units[unitID] then 
            local unit = self:get_unit(unitID, rec_char)
            unit:check_for_character(rec_char)
            for groupID, _ in pairs(unit:groups()) do
                local grouped_units = self:get_units_in_group(groupID)
                for i = 1, #grouped_units do
                    local c_unitID = grouped_units[i]
                    --avoid duplication
                    if (not character_units[c_unitID]) and (not character_queue[c_unitID]) then
                        self:get_unit(c_unitID, rec_char):check_for_character(rec_char)
                    end
                end
            end
        end
    end
    if is_table(ui_option_table) then
        --# assume ui_option_table: vector<string>!
        for i = 1, #ui_option_table do
            local c_unitID = ui_option_table[i]
            --avoid duplication
            if (not character_units[c_unitID]) and (not character_queue[c_unitID]) then
                self:get_unit(c_unitID, rec_char):check_for_character(rec_char)
            end
        end
    end
    if __write_output_to_logfile then
        local end_clock = os.clock()
        self:log("Process all checks on character: ".. string.format("elapsed time: %.2f", os.clock() - clock))
    end
end



--v function(self: RECRUITER_MANAGER, rec_char: RECRUITER_CHARACTER, ui_option_table: map<string, boolean>)
function recruiter_manager.check_all_ui_recruitment_options(self, rec_char, ui_option_table)
    local clock = os.clock()
    for unitID, _ in pairs(ui_option_table) do
        local unit = self:get_unit(unitID, rec_char)
        unit:check_for_character(rec_char)
        for groupID, _ in pairs(unit:groups()) do
            local grouped_units = self:get_units_in_group(groupID)
            for i = 1, #grouped_units do
                local c_unitID = grouped_units[i]
                --avoid duplication
                if not ui_option_table[c_unitID] then
                    self:get_unit(c_unitID, rec_char):check_for_character(rec_char)
                end
            end
        end
    end

    if __write_output_to_logfile then
        local end_clock = os.clock()
        self:log("Process all checks on character: ".. string.format("elapsed time: %.2f", os.clock() - clock))
    end
end


--v function(self: RECRUITER_MANAGER, rec_char: RECRUITER_CHARACTER, unitID: string)
function recruiter_manager.check_individual_unit_on_character(self, rec_char, unitID)
    local unit = self:get_unit(unitID, rec_char)
    unit:check_for_character(rec_char)
    
    for groupID, _ in pairs(unit:groups()) do
        local grouped_units = self:get_units_in_group(groupID)
        for i = 1, #grouped_units do
            local c_unitID = grouped_units[i]
            --avoid as much duplication as possible
            self:get_unit(c_unitID, rec_char):check_for_character(rec_char)
        end
    end 
end

--v function(self: RECRUITER_MANAGER, rec_char: RECRUITER_CHARACTER, unitID: string)
function recruiter_manager.check_unit_for_loop(self, rec_char, unitID)
    local character_units = rec_char:get_army_counts()
    local character_queue --:map<string, number>
    if rec_char._isHuman and (rec_char:is_queue_stale() == false) then
        character_queue = rec_char:get_queue_counts()
    else
        character_queue = {}
    end
    local unit = self:get_unit(unitID, rec_char)
    unit:check_for_character(rec_char)
end

--ENFORCEMENT--


--applies the restrictions stored in the currently selected rec character to the UI directly.
--v function(self: RECRUITER_MANAGER, rec_unit: RECRUITER_UNIT)
function recruiter_manager.enforce_ui_restriction_on_unit(self, rec_unit)
    local rec_char = self:get_character_by_cqi(self._UICurrentCharacter)
    local pathset = rec_char._UIPathSet
    local unitID = rec_unit._key
    self:log("Enforcing restrictions for ["..unitID.."] ["..tostring(self._UICurrentCharacter).."] on player UI!")
    --check if merc is open
    local path_to_mercs = pathset:mercenary_path()
    local mercenaryRecruitmentList = find_uicomponent_from_table(core:get_ui_root(), path_to_mercs);
    --if we got the panel, proceed
    if is_uicomponent(mercenaryRecruitmentList) and mercenaryRecruitmentList:Visible() then
        --self:log("Checking mercenary list!")
        --attach the UI suffix onto the unit name to get the name of the recruit button.
        local unit_component_ID = unitID.."_mercenary"
        --find the unit card using that name
        local unitCard = find_uicomponent(mercenaryRecruitmentList, unit_component_ID)
        --if we got the unit card, proceed
        if is_uicomponent(unitCard) then
            --first, check if the unit is supposed to be visible.
            if rec_char:is_unit_hidden(unitID) then
                self:log("Setting unit card ["..unit_component_ID.."] hidden")
                if unitCard:Visible() then
                    unitCard:SetVisible(false)
                end
            else --otherwise, care about locking it.
                self:log("Setting unit card ["..unit_component_ID.."] invisible")
                if not unitCard:Visible() then
                    unitCard:SetVisible(true)
                end
                --if the unit is restricted, set the card to be unclickable.
                if rec_char:is_unit_restricted(unitID) == true then
                    self:log("Locking Unit Card ["..unit_component_ID.."]")
                    unitCard:SetInteractive(false)
                    -- unitCard:SetVisible(false)
                    local lockedOverlay = find_uicomponent(unitCard, "disabled_script");
                    if not not lockedOverlay then
                        lockedOverlay:SetVisible(true)
                        lockedOverlay:SetImage("ui/custom/recruitment_controls/locked_unit.png")
                        lockedOverlay:SetTooltipText(rec_char:get_unit_lock_string(unitID))
                        lockedOverlay:SetCanResizeHeight(true)
                        lockedOverlay:SetCanResizeWidth(true)
                        lockedOverlay:Resize(72, 89)
                        lockedOverlay:SetCanResizeHeight(false)
                        lockedOverlay:SetCanResizeWidth(false)
                    end
                    
                    --unitCard:SetVisible(false)
                else
                --otherwise, set the card clickable
                    self:log("Unlocking! Unit Card ["..unit_component_ID.."]")
                    unitCard:SetInteractive(true)
                    -- unitCard:SetVisible(true)
                    local lockedOverlay = find_uicomponent(unitCard, "disabled_script");
                    if not not lockedOverlay then
                        if rec_unit._UIPip then
                            lockedOverlay:SetVisible(true)
                            lockedOverlay:SetTooltipText(rec_unit._UIText)
                            lockedOverlay:SetImage(rec_unit._UIPip)
                            lockedOverlay:SetCanResizeHeight(true)
                            lockedOverlay:SetCanResizeWidth(true)
                            lockedOverlay:Resize(30, 30)
                            lockedOverlay:SetCanResizeHeight(false)
                            lockedOverlay:SetCanResizeWidth(false)
                        else
                            lockedOverlay:SetVisible(false)
                        end
                    end
                end
            end
        else 
            --do nothing
        end
    end
    --check the rest
    local paths_to_check = pathset:get_path_list(rec_char)
    for i = 1, #paths_to_check do
        local localUnitList = find_uicomponent_from_table(core:get_ui_root(), pathset:get_path(paths_to_check[i]));
        --self:log("Checking ["..paths_to_check[i].."] list!")
        --if we got the panel, proceed
        if is_uicomponent(localUnitList) then
            --attach the UI suffix onto the unit name to get the name of the recruit button.
            local unit_component_ID = unitID.."_recruitable"
            --find the unit card using that name
            local unitCard = find_uicomponent(localUnitList, unit_component_ID)
            --if we got the unit card, proceed
            if is_uicomponent(unitCard) then
                --first, check if the unit is supposed to be visible.
                if rec_char:is_unit_hidden(unitID) then
                    self:log("Setting unit card ["..unit_component_ID.."] hidden")
                    if unitCard:Visible() then
                        unitCard:SetVisible(false)
                    end
                else --otherwise, care about locking it.
                    if not unitCard:Visible() then
                        self:log("Setting unit card ["..unit_component_ID.."] visible")
                        unitCard:SetVisible(true)
                    end
                    --if the unit is restricted, set the card to be unclickable.
                    if rec_char:is_unit_restricted(unitID) == true then
                        self:log("Locking Unit Card ["..unit_component_ID.."]")
                        unitCard:SetInteractive(false)
                        -- unitCard:SetVisible(false)
                        local lockedOverlay = find_uicomponent(unitCard, "disabled_script");
                        if not not lockedOverlay then
                            lockedOverlay:SetVisible(true)
                            lockedOverlay:SetImage("ui/custom/recruitment_controls/locked_unit.png")
                            lockedOverlay:SetTooltipText(rec_char:get_unit_lock_string(unitID))
                            lockedOverlay:SetCanResizeHeight(true)
                            lockedOverlay:SetCanResizeWidth(true)
                            lockedOverlay:Resize(72, 89)
                            lockedOverlay:SetCanResizeHeight(false)
                            lockedOverlay:SetCanResizeWidth(false)
                        end
                        
                        --unitCard:SetVisible(false)
                    else
                    --otherwise, set the card clickable
                        self:log("Unlocking! Unit Card ["..unit_component_ID.."]")
                        unitCard:SetInteractive(true)
                        -- unitCard:SetVisible(true)
                        local lockedOverlay = find_uicomponent(unitCard, "disabled_script");
                        if not not lockedOverlay then
                            if rec_unit._UIPip then
                                lockedOverlay:SetVisible(true)
                                lockedOverlay:SetTooltipText(rec_unit._UIText)
                                lockedOverlay:SetImage(rec_unit._UIPip)
                                lockedOverlay:SetCanResizeHeight(true)
                                lockedOverlay:SetCanResizeWidth(true)
                                lockedOverlay:Resize(30, 30)
                                lockedOverlay:SetCanResizeHeight(false)
                                lockedOverlay:SetCanResizeWidth(false)
                            else
                                lockedOverlay:SetVisible(false)
                            end
                        end
                    end
                end
            else 
                --do nothing
            end
        end
    end
    cm:steal_user_input(false);
end


--v function(self: RECRUITER_MANAGER)
function recruiter_manager.enforce_all_units_on_current_character(self)
    if not self._UICurrentCharacter then
        return
    end
    local char = self:get_character_by_cqi(self._UICurrentCharacter)
    local char_restricted_units = char._restrictedUnits
    local char_hidden_units = char._hiddenUnits
    for unit_key, restricted in pairs(char_restricted_units) do
        self:enforce_ui_restriction_on_unit(self:get_unit(unit_key))
    end
    for unit_key, restricted in pairs(char_hidden_units) do
        if char_restricted_units[unit_key] ~= nil then
            self:enforce_ui_restriction_on_unit(self:get_unit(unit_key, char))
        end
    end
end

--v function(self: RECRUITER_MANAGER, ui_table: map<string, boolean>, rec_char: RECRUITER_CHARACTER)
function recruiter_manager.enforce_units_by_table(self, ui_table, rec_char)
    for unit_key, _ in pairs(ui_table) do
        self:enforce_ui_restriction_on_unit(self:get_unit(unit_key, rec_char))
    end
end


----------------------------
----QUANTITY LIMITS API-----
----------------------------

--get the limit of a specific unit
--v function(self: RECRUITER_MANAGER, unitID: string) --> number
function recruiter_manager.get_quantity_limit_for_unit(self, unitID)
    if self._characterUnitLimits[unitID] == nil then
        return 999 --avoid clogging memoryu
    end
    return self._characterUnitLimits[unitID]
end



--adds a quantity check function to the stack of a single unit.
--v function(self: RECRUITER_MANAGER, unitID: string, quantity_limit: number)
function recruiter_manager.add_single_unit_quantity_limit(self, unitID, quantity_limit)
    if not is_string(unitID) then
        self:log("add_single_unit_quantity_limit called, bad arg #1, unitID should be string")
        return
    elseif (not is_number(quantity_limit)) then
        self:log("add_single_unit_quantity_limit called, bad arg #2, quantity_limit should be an integer")
        return
    else
        --set a quantity limit in model
        self._characterUnitLimits[unitID] = quantity_limit
        --send a checking function to the unit
        local unit = self:get_unit(unitID)
        unit:add_restriction_check(function(rec_char)
            --see if the count for this unit is higher or equal to the quantity limit
            local result = self:current_character():get_unit_count(unitID) >= self:get_quantity_limit_for_unit(unitID)
            return result, "This character already has the maximum number of this unit ("..self:get_quantity_limit_for_unit(unitID)..")", false
        end)

    end
end


--get the quantity limit of a specific group
--v function(self: RECRUITER_MANAGER, groupID: string) -->number
function recruiter_manager.get_quantity_limit_for_group(self,groupID)
    if self._groupUnitLimits[groupID] == nil then
        return 999
    end
    return self._groupUnitLimits[groupID]
end

--add a quantity limit to the group. Must be called after all units are in the group already
--publically available function
--v function(self: RECRUITER_MANAGER, groupID: string, quantity_limit: number)
function recruiter_manager.add_character_quantity_limit_for_group(self, groupID, quantity_limit)
    --check for errors in API functions
    if not is_string(groupID) then
        self:log("add_character_quantity_limit_for_group called with bad arg #1, provided groupID is not a string!")
        return
    end
    if not is_number(quantity_limit) then
        self:log("add_character_quantity_limit_for_group called with bad arg #2, provided ququantity_limitantity is not a number!")
        return
    end
    --set the quantity limit
    self._groupUnitLimits[groupID] = quantity_limit
    --add the necessary check
    local group = self:get_units_in_group(groupID)
    for i = 1, #group do
        local unitID = group[i]
        local unit = self:get_unit(unitID)
        unit:add_restriction_check(function(rec_char)
            local count = 0 --:number
            --loop through all members of the group, getting their unit interfaces
            --and counting them in the army, applying weights
            local grouped_units = self:get_units_in_group(groupID) 
            --these closures need to reaqquire group lists incase they are modified post activation
            for j = 1, #grouped_units do
                local c_unitID = grouped_units[j]
                local current_rec_unit = self:get_unit(c_unitID, rec_char)
                if not not current_rec_unit._groups[groupID] then
                    --this if statement filters units whose overriden mode is not a member out.
                    --self:log("A count occured")
                    count = count + (rec_char:get_unit_count(c_unitID)*current_rec_unit:weight())
                end
            end --loop ends, we should have the full quantity
            local comparator = (self:get_weight_for_unit(unitID) - 1) + count
            --self:log("The check comparator is ["..comparator.."] the quantity limit is ["..self:get_quantity_limit_for_group(groupID).."] ")
            local result = comparator >= self:get_quantity_limit_for_group(groupID)
                return result, "This character already has the maximum number of "..self:get_ui_name_for_group(groupID)..". ("..self:get_quantity_limit_for_group(groupID)..")", false
            end)
    end
end

------------------------
----UI UNIT PROFILES----
------------------------

--[[ --TODO this
--sets a UI text for a given unit
--v function(self: RECRUITER_MANAGER, unitID: string, UIText: string)
function recruiter_manager.set_ui_text_for_unit(self, unitID, UIText)
    if (not is_string(unitID)) then 
        self:log("set_ui_text_for_unit called with bad arg #1, unitID must be a string!")
    elseif (not is_string(UIText)) then
        self:log("set_ui_text_for_unit called with bad arg #2, UIText must be a string!")
    end
    self:get_unit(unitID):set_ui_text_for_unit


end--]]




--set the UI profile for a unit.
--DEPRECATED FUNCTION. NOT IDEAL FOR USE. LEFT ALIVE TO PRESERVE API COMPAT.
--# type global RM_UIPROFILE = {_text: string, _image: string}
--v function(self: RECRUITER_MANAGER, unitID: string, UIprofile: RM_UIPROFILE)
function recruiter_manager.set_ui_profile_for_unit(self, unitID, UIprofile)
    if not (is_string(UIprofile._image) and is_string(UIprofile._text)) then
        self:log("ERROR: set_ui_profile_for_unit called but the supplied profile table isn't properly formatted. /n It needs to have a _text and _image field which are both strings!")
        return
    end
    if (not is_string(unitID)) or (not self._recruiterUnits[unitID]) then
        self:log("ERROR set_ui_profile_for_unit called but supplied unit has no base entry, or isn't a string!")
        return
    end
    self:get_unit(unitID):add_ui_profile(UIprofile._text, UIprofile._image)
end

--sets the UI profile for an override unit
--v function(self: RECRUITER_MANAGER, abstractionID: string, text: string, image_path: string)
function recruiter_manager.set_ui_profile_for_unit_override(self, abstractionID, text, image_path)
    if not self._overrideUnits[abstractionID] then
        self:log("Tried to call set_ui_profile_for_unit_override for abtractionID ["..abstractionID.."] which isn't a valid unit override!")
    end
    self._overrideUnits[abstractionID]:add_ui_profile(text, image_path)

end

--------------------------
----PATH SET FILTERING----
--------------------------

--v function(self: RECRUITER_MANAGER, subtype_key: string, pathID: string)
function recruiter_manager.add_subtype_path_filter(self, subtype_key, pathID)
    self._subtypePathSets[subtype_key] = pathID
    if not self._UIPaths[pathID] then
        self:log("Added a subtype path set to ["..subtype_key.."] which doesn't exist ["..pathID.."]")
        self:log("Hopefully for you this a load order problem, because the script don't abort here.")
    end
end

--v function(self: RECRUITER_MANAGER, subculture_key: string, pathID: string)
function recruiter_manager.add_subculture_path_filter(self, subculture_key, pathID)
    self._subculturePathSets[subculture_key] = pathID
    if not self._UIPaths[pathID] then
        self:log("Added a subculture default path set to ["..subculture_key.."] which doesn't exist ["..pathID.."]")
        self:log("Hopefully for you this a load order problem, because the script don't abort here.")
    end
end

--v function(self: RECRUITER_MANAGER, character: CA_CHAR) --> RECRUITER_PATHSET
function recruiter_manager.evaluate_path_set_for_character(self, character)
    --first, check their subtype. This takes precedence over subcultural default
    if self._subtypePathSets[character:character_subtype_key()] then
        return self:get_path_set(self._subtypePathSets[character:character_subtype_key()])
    elseif self._subculturePathSets[character:faction():subculture()] then
        return self:get_path_set(self._subculturePathSets[character:faction():subculture()])
    end
    self:log("Found no valid path sets to match the character ["..tostring(character:command_queue_index()).."] returning a nil path")
    return nil
end



--------------------------
----AI CAP REPLICATION----
--------------------------

--add a list of core units to use as the replacements for a subculture
--v function(self: RECRUITER_MANAGER, subculture: string, units: vector<string>, default: boolean?)
function recruiter_manager.add_ai_units_for_subculture_with_table(self, subculture, units, default)
    if self._AIDefaultUnits[subculture] == nil then
        self._AIDefaultUnits[subculture] = {}
    else
        if default then
            return 
        end
    end
    for i = 1, #units do
        table.insert(self._AIDefaultUnits[subculture], units[i])
    end
end

--v function(self: RECRUITER_MANAGER) --> boolean
function recruiter_manager.should_enforce_ai_restrictions(self)
    return self._AIEnforce
end

--v function(self: RECRUITER_MANAGER, enforce: boolean)
function recruiter_manager.enforce_ai_restrictions(self, enforce)
    self._AIEnforce = enforce
end

--ai function--
--v function(self: RECRUITER_MANAGER) --> map<string, vector<string>>
function recruiter_manager.ai_subculture_defaults(self)
    return self._AIDefaultUnits
end

---------------------------------------------
----SUBTYPE AND CHARACTER BASED OVERRIDES----
---------------------------------------------

--v function(self: RECRUITER_MANAGER, subtype_key: string, abstractionID: string)
function recruiter_manager.add_subtype_filter_for_unit_override(self, subtype_key, abstractionID)
    if not is_string(abstractionID) then
        self:log("add_subtype_filter_for_unit_override called with bad arg #2, abstractionID must be a string!")
        return
    elseif not self._overrideUnits[abstractionID] then
        self:log("add_subtype_filter_for_unit_override called with bad arg #2, abstractionID must refer to a created unit override record!")
        return
    elseif not is_string(subtype_key) then
        self:log("add_subtype_filter_for_unit_override called with bad arg #1, subtype key must be a string!")
        return
    end
    self._overrideSubtypeFilters[subtype_key] = self._overrideSubtypeFilters[subtype_key] or {}
    table.insert(self._overrideSubtypeFilters[subtype_key], abstractionID) 
end

--v function(self: RECRUITER_MANAGER, subtype_key: string, skill_key: string, abstractionID: string)
function recruiter_manager.add_skill_requirement_for_unit_override(self, subtype_key, skill_key, abstractionID)
    if not is_string(abstractionID) then
        self:log("add_subtype_filter_for_unit_override called with bad arg #3, abstractionID must be a string!")
        return
    elseif not self._overrideUnits[abstractionID] then
        self:log("add_subtype_filter_for_unit_override called with bad arg #3, abstractionID must refer to a created unit override record!")
        return
    elseif not is_string(subtype_key) then
        self:log("add_subtype_filter_for_unit_override called with bad arg #1, subtype key must be a string!")
        return
    elseif not is_string(skill_key) then
        self:log("add_subtype_filter_for_unit_override called with bad arg #2, skill key must be a string!")
        return
    end
    self._overrideSkillRequirements[subtype_key] = self._overrideSkillRequirements[subtype_key]  or {}
    self._overrideSkillRequirements[subtype_key][abstractionID] = skill_key
end


--v function(self: RECRUITER_MANAGER, subtype_key: string, trait_key: string, abstractionID: string)
function recruiter_manager.add_skill_requirement_for_unit_override(self, subtype_key, trait_key, abstractionID)
    if not is_string(abstractionID) then
        self:log("add_subtype_filter_for_unit_override called with bad arg #3, abstractionID must be a string!")
        return
    elseif not self._overrideUnits[abstractionID] then
        self:log("add_subtype_filter_for_unit_override called with bad arg #3, abstractionID must refer to a created unit override record!")
        return
    elseif not is_string(subtype_key) then
        self:log("add_subtype_filter_for_unit_override called with bad arg #1, subtype key must be a string!")
        return
    elseif not is_string(trait_key) then
        self:log("add_subtype_filter_for_unit_override called with bad arg #2, trait key must be a string!")
        return
    end
    self._overrideTraitRequirements[subtype_key] = self._overrideTraitRequirements[subtype_key]  or {}
    self._overrideTraitRequirements[subtype_key][abstractionID] = trait_key
end


---DEPRECATED API-----
----------------------

--these don't do anything, they just warn the modder
--v [NO_CHECK] function(self: RECRUITER_MANAGER, ...:any) 
function recruiter_manager.add_subtype_group_override(self, ...)
    self:log("add_subtype_group_override called from an API script!")
    self:log("WARNING: This API method is outdated: It won't crash your script, but it doesn't do anything and it will eventually be removed entirely!")
end

--these don't do anything, they just warn the modder
--v [NO_CHECK] function(self: RECRUITER_MANAGER, ...:any) 
function recruiter_manager.whitelist_unit_for_subculture(self, ...)
    self:log("whitelist_unit_for_subculture called from an API script!")
    self:log("WARNING: This API method is outdated: It won't crash your script, but it doesn't do anything and it will eventually be removed entirely!")
end

--these don't do anything, they just warn the modder
--v [NO_CHECK] function(self: RECRUITER_MANAGER, subtype: string) 
function recruiter_manager.register_subtype_as_char_bound_horde(self, subtype)
    self:log("register_subtype_as_char_bound_horde called from an API script!")
    self:log("WARNING: This API method is incomplete: It doesn't really capture all cases and more setup is sometimes involved getting custom char bound hordes to work!")
    self:log("\t ask DrunkFlamingo for help if you need it, but you should really check the source code of the core implementation and try to match the situation your CBH fits best.")
    self:add_subtype_path_filter(subtype, "CharBoundHordeWithGlobal")
end


--institation 
recruiter_manager.init()
