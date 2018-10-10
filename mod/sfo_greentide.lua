
--# assume global class GT_TRACKER
local greentide_tracker = {} --# assume greentide_tracker: GT_TRACKER

--v function()
function greentide_tracker.init()
    local self = {} 
    setmetatable(self, {
        __index = greentide_tracker
    })--# assume self: GT_TRACKER

    self._levels = {} --:map<string, number> --faction, level
    self._dilemmas = {} --:vector<string>

    _G.gt = self
end

--v function(self: GT_TRACKER, faction: string, value: number, event: string)
function greentide_tracker.apply_value_change(self, faction, value, event)
    local old_level = self._levels[faction]
    local new_level = old_level + value
    if new_level > 10 then
        new_level = 10
    elseif new_level < 1 then
        new_level = 1 
    end
    if (new_level == old_level) then
        --do nothing
    else
        if cm:get_faction(faction):has_effect_bundle("grn_greentide_"..old_level) then
            cm:remove_effect_bundle("grn_greentide_"..old_level, faction)
        end
        cm:apply_effect_bundle("grn_greentide_"..new_level, faction, 0)
    end
    if new_level > old_level then
        cm:trigger_dilemma("grn_greentide_choice_"..event, faction, true)
    end
    self._levels[faction] = new_level
    cm:set_saved_value("gt_tracker_"..faction, new_level)
end



--v function(self: GT_TRACKER, event: string, condition: (function(context: WHATEVER) --> boolean), path_to_faction: (function(context: WHATEVER) --> string), value: number)
function greentide_tracker.add_event(self, event, condition,path_to_faction, value)
    core:add_listener(
        event.."_gt_tracker",
        event,
        function(context)
            local sc = cm:get_faction(path_to_faction(context)):subculture()
            return condition(context) and (sc == "wh_main_sc_grn_greenskins" or sc == "wh_main_sc_grn_savage_orcs")
        end,
        function(context)
            local faction = path_to_faction(context)
            self:apply_value_change(faction, value, event)
        end,
        true)
end


greentide_tracker.init()