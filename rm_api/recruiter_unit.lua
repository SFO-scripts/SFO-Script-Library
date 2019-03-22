 recruiter_unit = {} --# assume recruiter_unit: RECRUITER_UNIT

--v function( manager: RECRUITER_MANAGER, main_unit_key: string, base_unit: RECRUITER_UNIT?) --> RECRUITER_UNIT
function recruiter_unit.create_record(manager, main_unit_key, base_unit)
    local self = {}
    setmetatable(self, {
        __index = recruiter_unit,
        __tostring = function() return "RECRUITER_UNIT" end
    }) --# assume self: RECRUITER_UNIT

    self._key = main_unit_key
    self._manager = manager
    --weight refers to the value a unit is assigned in calculations. 
    self._weight = 1 --:number
    --links a unit to a group key 
    --check comes here to check whether a group is valid for the unit being checked.
    self._groups = {} --:map<string, boolean>
    --Marks the unit as an overriden unit. 
    self._isOverride = not not base_unit
    --points to the base unit an override is based upon. Its ? typed, because it will be nil if the unit is a base!
    self._baseUnit = base_unit
    --holds the default UI profile for a unit. 
    --Override entries hold their own profiles so no profile overrides are needed at the character level.
    self._UIPip = nil --:string
    self._UIText = nil  --:string
    --checkstack!
    -- the first boolean returns the validity of the unit on the passed char. 
    -- the string returns a UI Explaination for the lock on the unit.
    -- the last boolean returns whether the restriction is a faction wide decision.
    self._checkStack = {} --:vector<function(RECRUITER_CHARACTER) --> (boolean, string, boolean)>
    --Visibility check stack
    --takes priority over locking and unlocking for obvious reasons
    self._visibilityStack = {} --:vector<function(RECRUITER_CHARACTER) --> (boolean)>
    --BOTH STACKS RETURN FALSE WHEN A UNIT ISN'T RESTRICTED!!

    return self
end

--v function(self: RECRUITER_UNIT, text: string)
function recruiter_unit.log(self, text)
    self._manager:log(text)
end

--v function(self: RECRUITER_UNIT) --> string
function recruiter_unit.key(self)
    return self._key
end


--sets the UI profile that a unit uses when unlocked. 
--This is an arbitrary type with a text and image path in a table.
--v function(self: RECRUITER_UNIT, text: string, path_to_pip: string)
function recruiter_unit.add_ui_profile(self, text, path_to_pip)
    self._UIPip = path_to_pip 
    self._UIText = text  
end

--v function(self: RECRUITER_UNIT, weight: number)
function recruiter_unit.set_unit_weight(self, weight)
    self._weight = weight
end

--v function(self: RECRUITER_UNIT) --> number
function recruiter_unit.weight(self)
    return self._weight
end

--v function(self: RECRUITER_UNIT, group: string)
function recruiter_unit.add_group_to_unit(self, group)
    self._groups[group] = true
end

--v function(self: RECRUITER_UNIT) --> map<string, boolean>
function recruiter_unit.groups(self)
    return self._groups
end


--carry out the checking functions for a unit, storing them into the characters
--v function(self: RECRUITER_UNIT, rec_char: RECRUITER_CHARACTER)
function recruiter_unit.check_for_character(self, rec_char)
    self:log("Doing checks for ["..self._key.."] on char ["..tostring(rec_char:command_queue_index()).."] ")
    --start looping through the list of checks for the unit. 
    --we want to mimic doing an 'or' statement except for a vector: 
    --if any condition on the list is true this function returns true
    --first, visibility
    local vis_checks = self._visibilityStack
    for i = 1, #vis_checks do
        local result = vis_checks[i](rec_char)
        if result then
            rec_char:set_unit_hiding(self._key, true)
            return
        end
    end
    --if we got this far, the unit isn't hidden!
    rec_char:set_unit_hiding(self._key, false)
    local unlock_faction_wide = false
    --next, locking
    local unit_checks = self._checkStack
    for i = 1, #unit_checks do
        local result, UIstring, factionwide = unit_checks[i](rec_char)
        if result then
            --if our check returns true decide how to handle
            self:log("A check resulted in a restriction for ["..self._key.."]: factionwide ["..tostring(factionwide).."] ui reason: ["..UIstring.."] ")
            if factionwide then
                self._manager:set_unit_restriction_for_faction(self._key, rec_char:faction():name(), true)
                self._manager:add_factionwide_lock_text(self._key, rec_char:faction():name(), UIstring)
            else
                rec_char:set_unit_restriction(self._key, true)
                rec_char:add_lock_text(self._key, UIstring)
            end
            return
        else
            if factionwide and (not unlock_faction_wide) then
                unlock_faction_wide = true
            end
        end
    end
    rec_char:set_unit_restriction(self._key, false)
    --if no checks succeeded, return the false
    self:log("All checks cleared with no restriction for ["..self._key.."]")
    if unlock_faction_wide then
        self._manager:set_unit_restriction_for_faction(self._key, rec_char:faction():name(), false)
    end
end

--v function(self: RECRUITER_UNIT, check: function(RECRUITER_CHARACTER) --> (boolean, string, boolean))
function recruiter_unit.add_restriction_check(self, check)
    if not is_function(check) then
        self:log("Add restriction check called, bad arg #1, check should be a function")
        return
    end
    table.insert(self._checkStack, check)
end

