--log script to text
--v function(text: string)
local function GRNLOG(text)
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

--instantiate the tracker
--v function()
function greentide_tracker.init()
    local self = {} 
    setmetatable(self, {
        __index = greentide_tracker
    })--# assume self: GT_TRACKER

    self._levels = {} --:map<string, number> --faction, level
    _G.gt = self
end

--log script to text
--v method(text: any)
function greentide_tracker:log(text)
    GRNLOG(tostring(text))
end

--check if a faction is greenskin in culture and is neither a quest battle nor a companion faction.
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


--apply a value change to the GT bundle of a faction.
--v function(self: GT_TRACKER, faction: string, value: number, event: string)
function greentide_tracker.apply_value_change(self, faction, value, event)
    self:log("Triggering value change for faction ["..faction.."] of value ["..value.."] because of ["..event.."]")
    local old_level = self._levels[faction]
    local new_level = old_level + value
    --clamp levels to not exceed maximums and minimums
    if new_level > 10 then
        new_level = 10
    elseif new_level < 1 then
        new_level = 1 
    end
    --figure out what we need to do with bundles.
    if (new_level == old_level) then
        --do nothing
    else
        --remove old bundle
        if cm:get_faction(faction):has_effect_bundle("grn_greentide_"..old_level) then
            cm:remove_effect_bundle("grn_greentide_"..old_level, faction)
        end
        --add new bundle
        cm:apply_effect_bundle("grn_greentide_"..new_level, faction, 0)
    end
    --if the faction concerned is human, do more.
    if cm:get_faction(faction):is_human() then
        --if the change is an increase.
        if new_level > old_level then
            --check if it is the correct turn
            if cm:model():world():whose_turn_is_it():name() == faction then
                --trigger the associated dilemma.
                cm:trigger_dilemma(faction, "grn_greentide_choice_"..string.lower(event), true)
                --listen for the dilemma ending, then show an event message.
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
            --otherwise, wait for the turn of the player you want then just repeat the above.
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
        --decrease in bundle!
        elseif old_level > new_level then
            --check turn again
            if cm:model():world():whose_turn_is_it():name() == faction then
                --show a message
                cm:show_message_event(
                    faction,
                    "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_"..string.lower(event).."_primary_detail",
                    "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_"..string.lower(event).."_primary_detail",
                    "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_"..string.lower(event).."_secondary_detail",
                    true,
                    593) 
            else
                --wait for the player's turn then show a message
                core:add_listener(
                    "GTFactionTurnStart",
                    "FactionTurnStart",
                    function(context)
                        return context:faction():name() == faction
                    end,
                    function(context)
                        cm:show_message_event(
                            faction,
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_"..string.lower(event).."_primary_detail",
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_"..string.lower(event).."_primary_detail",
                            "event_feed_strings_text_wh_event_feed_scripted_message_grn_nerf_"..string.lower(event).."_secondary_detail",
                            true,
                            593) 
                    end,
                    false)
            end
        end
    end
    --store the new level in the model
    self._levels[faction] = new_level
    --save the new level in the save file.
    cm:set_saved_value("gt_tracker_"..faction, new_level)
end


--add an event.
--v function(self: GT_TRACKER, event: string, condition: (function(context: WHATEVER) --> boolean), path_to_faction: (function(context: WHATEVER) --> string), value: number)
function greentide_tracker.add_event(self, event, condition,path_to_faction, value)
    --suffix the listener name so debugging is easier if there is ever a problem
    local suffix = "_up"
    if value < 0 then
        suffix = "_down"
    end
    --create the new listener with the given info
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

--launch the script
greentide_tracker.init()