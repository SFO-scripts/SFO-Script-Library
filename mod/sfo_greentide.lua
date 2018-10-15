--v function(text: string, ftext: string?)
    local function GRNLOG(text, ftext)
        if not __write_output_to_logfile then
            return; 
        end
    
        local logText = tostring(text)
        local logTimeStamp = os.date("%d, %m %Y %X")
        local popLog = io.open("sfo_log.txt","a")
        --# assume logTimeStamp: string
        popLog :write("GRN:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
        popLog :flush()
        popLog :close()
    end

--# assume global class GT_TRACKER
local greentide_tracker = {} --# assume greentide_tracker: GT_TRACKER

--v function()
function greentide_tracker.init()
    local self = {} 
    setmetatable(self, {
        __index = greentide_tracker
    })--# assume self: GT_TRACKER

    self._levels = {} --:map<string, number> --faction, level
    _G.gt = self
end

--v method(text: any)
function greentide_tracker:log(text)
    GRNLOG(tostring(text))
end

--v method(faction: string) --> boolean
function greentide_tracker:is_valid_greentide_faction(faction)
    local obj = cm:get_faction(faction)
    if obj:culture() == "wh_main_grn_greenskins" then
        if string.find(faction, "_qb") or string.find(faction, "_waaagh") then
            return false
        else
            return true
        end
    else
        return false
    end
end



--v function(self: GT_TRACKER, faction: string, value: number, event: string)
function greentide_tracker.apply_value_change(self, faction, value, event)
    self:log("Triggering value change for faction ["..faction.."] of value ["..value.."] because of ["..event.."]")
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
    if cm:get_faction(faction):is_human() then
        if new_level > old_level then
            if cm:model():world():whose_turn_is_it():name() == faction then
                cm:trigger_dilemma(faction, "grn_greentide_choice_"..string.lower(event), true)
                core:add_listener(
                    "GTDilemmaChoiceMade",
                    "DilemmaChoiceMadeEvent",
                    function(context)
                        return context:dilemma() == "grn_greentide_choice_"..string.lower(event)
                    end,
                    function(context)
                        cm:show_message_event(
                            faction,
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_upgrade_primary_detail",
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_upgrade_primary_detail",
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_upgrade_secondary_detail",
                            true,
                            593)
                    end,
                    false)
            elseif not cm:get_saved_value("greentide_dilemma_pending") then
                cm:set_saved_value("greentide_dilemma_pending", true)
                core:add_listener(
                        "GTFactionTurnStart",
                        "FactionTurnStart",
                        function(context)
                            return context:faction():name() == faction
                        end,
                        function(context)
                            cm:set_saved_value("greentide_dilemma_pending", false)
                            cm:trigger_dilemma(faction, "grn_greentide_choice_"..string.lower(event), true)
                            core:add_listener(
                                "GTDilemmaChoiceMade",
                                "DilemmaChoiceMadeEvent",
                                function(context)
                                    return context:dilemma() == "grn_greentide_choice_"..string.lower(event)
                                end,
                                function(context)
                                    cm:show_message_event(
                                        faction,
                                        "event_feed_strings_text_wh_event_feed_scripted_message_grn_upgrade_primary_detail",
                                        "event_feed_strings_text_wh_event_feed_scripted_message_grn_upgrade_primary_detail",
                                        "event_feed_strings_text_wh_event_feed_scripted_message_grn_upgrade_secondary_detail",
                                        true,
                                        593)
                                end,
                                false)
                        end,
                        false)

            end
        elseif old_level > new_level then
            if cm:model():world():whose_turn_is_it():name() == faction then
                cm:show_message_event(
                    faction,
                    "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_primary_detail",
                    "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_primary_detail",
                    "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_secondary_detail",
                    true,
                    593) 
            else
                core:add_listener(
                    "GTFactionTurnStart",
                    "FactionTurnStart",
                    function(context)
                        return context:faction():name() == faction
                    end,
                    function(context)
                        cm:show_message_event(
                            faction,
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_primary_detail",
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_primary_detail",
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_secondary_detail",
                            true,
                            593) 
                    end,
                    false)
            end
        end
    end
    self._levels[faction] = new_level
    cm:set_saved_value("gt_tracker_"..faction, new_level)
end



--v function(self: GT_TRACKER, event: string, condition: (function(context: WHATEVER) --> boolean), path_to_faction: (function(context: WHATEVER) --> string), value: number)
function greentide_tracker.add_event(self, event, condition,path_to_faction, value)
    local suffix = "_up"
    if value < 0 then
        suffix = "_down"
    end
    core:add_listener(
        string.lower(event).."_gt_tracker"..suffix,
        event,
        function(context)
            return condition(context) and self:is_valid_greentide_faction(path_to_faction(context))
        end,
        function(context)
            self:log("A greentide event ["..event.."] ["..value.."] was triggered!")
            local faction = path_to_faction(context)
            self:apply_value_change(faction, value, event)
        end,
        true)
end


greentide_tracker.init()