--grab rm, cm and events
cm = get_cm(); rm = _G.rm;

--rm:error_checker() --turn on error checking

--[[testing code
core:add_listener(
    "printquantity",
    "ShortcutTriggered",
    function(context) return context.string == "camera_bookmark_view0"; end, --default F9
    function(context)
        rm:log("POOL AT: ".. rm._unitPoolQuantities["wh_dlc04_emp_inf_free_company_militia_0"]["wh_main_emp_empire"])
    end,
    true)

  rm:add_unit_pool("wh_dlc04_emp_inf_free_company_militia_0", "wh_main_emp_empire", 2, 3)

--]]
--add unit added to queue listener
core:add_listener(
    "RecruiterManagerOnRecruitOptionClicked",
    "ComponentLClickUp",
    true,
    function(context)
        --# assume context: CA_UIContext
        local unit_component_ID = tostring(UIComponent(context.component):Id())
        --is our clicked component a unit?
        if string.find(unit_component_ID, "_recruitable") and UIComponent(context.component):CurrentState() == "active" then
            --print_all_uicomponent_children(UIComponent(context.component))
            --its a unit! steal the users input so that they don't click more shit while we calculate.
            cm:steal_user_input(true);
            rm:log("Locking recruitment button for ["..unit_component_ID.."] temporarily");
            --reduce the string to get the name of the unit.
            local unitID = string.gsub(unit_component_ID, "_recruitable", "")
            --add the unit to queue so that our model knows it exists.
            rm:current_character():add_unit_to_queue(unitID)
            --run the checks on that character with the updated queue quantities.
            cm:callback(function()
                rm:check_individual_unit_on_character(rm:current_character(), unitID)
                rm:enforce_all_units_on_current_character()
            end, 0.1)
        end
    end,
    true);
--add unit added to queue from mercenaries listener
core:add_listener(
    "RecruiterManagerOnMercenaryOptionClicked",
    "ComponentLClickUp",
    true,
    function(context)
        --# assume context: CA_UIContext
        local unit_component_ID = tostring(UIComponent(context.component):Id())
        --is our clicked component a unit?
        if string.find(unit_component_ID, "_mercenary") and UIComponent(context.component):CurrentState() == "active" then
            --its a unit! steal the users input so that they don't click more shit while we calculate.
            cm:steal_user_input(true);
            rm:log("Locking recruitment button for ["..unit_component_ID.."] temporarily");
            --reduce the string to get the name of the unit.
            local unitID = string.gsub(unit_component_ID, "_mercenary", "")
            --add the unit to queue so that our model knows it exists.
            rm:current_character():add_unit_to_queue(unitID)
            --run the checks on that character with the updated queue quantities.
            cm:callback(function()
                rm:check_individual_unit_on_character(rm:current_character(), unitID)
                rm:enforce_all_units_on_current_character()
            end, 0.1)
        end
    end,
    true);


--add queued unit clicked listener --TODO REWRITE LISTENER
core:add_listener(
"RecruiterManagerOnQueuedUnitClicked",
"ComponentLClickUp",
true,
function(context)
    --# assume context: CA_UIContext
    local queue_component_ID = tostring(UIComponent(context.component):Id())
    if string.find(queue_component_ID, "QueuedLandUnit") then
        rm:log("Component Clicked was a Queued Unit!")
        --set the queue stale so that when we get it, we refresh the queue!
        local current_character = rm:current_character()
        current_character:set_queue_stale()
        cm:remove_callback("RMOnQueue")
        cm:callback( function() -- we callback this because if we don't do it on a small delay, it will pick up the unit we just cancelled as existing!
            --we want to re-evaluate the units who were previously in queue, they may have changed.
            local queue_counts = current_character:get_queue_counts() 
            rm:check_all_units_on_character(current_character)
            rm:enforce_all_units_on_current_character()
        end, 0.1, "RMOnQueue")
    end
end,
true);
--add queued mercenary listener
core:add_listener(
"RecruiterManagerOnQueuedMercenaryClicked",
"ComponentLClickUp",
true,
function(context)
    --# assume context: CA_UIContext
    local queue_component_ID = tostring(UIComponent(context.component):Id())
    if string.find(queue_component_ID, "temp_merc_") then
        rm:log("Component Clicked was a Queued Unit!")
        --set the queue stale so that when we get it, we refresh the queue!
        local current_character = rm:current_character()
        current_character:set_queue_stale()
        cm:remove_callback("RMOnMerc")
        cm:callback( function() -- we callback this because if we don't do it on a small delay, it will pick up the unit we just cancelled as existing!
            --we want to re-evaluate the units who were previously in queue, they may have changed.
            local queue_counts = current_character:get_queue_counts() 
            rm:check_all_units_on_character(current_character)
            rm:enforce_all_units_on_current_character()
        end, 0.1, "RMOnMerc")
    end
end,
true);






--add character moved listener
core:add_listener(
"RecruiterManagerPlayerCharacterMoved",
"CharacterFinishedMoving",
function(context)
    return context:character():faction():is_human() and rm:has_character(context:character():command_queue_index())
end,
function(context)
    rm:log("Player Character moved!")
    local character = context:character()
    --# assume character: CA_CHAR
    --the character moved, so we're going to set both their army and their queue stale and force the script to re-evaluate them next time they are available.
    rm:get_character_by_cqi(character:command_queue_index()):set_army_stale()
    rm:get_character_by_cqi(character:command_queue_index()):set_queue_stale()
end,
true)

--add unit trained listener
core:add_listener(
"RecruiterManagerPlayerFactionRecruitedUnit",
"UnitTrained",
function(context)
    return context:unit():faction():is_human() and rm:has_character(context:unit():force_commander():command_queue_index())
end,
function(context)
    local unit = context:unit()
    --# assume unit: CA_UNIT
    local char_cqi = unit:force_commander():command_queue_index();
    rm:log("Player faction recruited a unit!")
    rm:get_character_by_cqi(char_cqi):set_army_stale()
    --we can't just delete the queue when pools are involved.
    --[[
    if rm:unit_has_pool(unit:unit_key()) then
        --take away the cost
        rm:change_unit_pool(unit:unit_key(), unit:faction():name(), -1)
        --remove the unit from queue, this will refund the cost that is there so the user isn't double charged!
        rm:get_character_by_cqi(char_cqi):remove_unit_from_queue(unit:unit_key())
        --raw set the queue stale so that the remaining costs are re-evaluated next time he is looked at.
        rm:get_character_by_cqi(char_cqi):raw_set_queue_stale()
    else
        rm:get_character_by_cqi(char_cqi):set_queue_stale()
    end
    --]] --TODO unit pools 
    rm:get_character_by_cqi(char_cqi):set_queue_stale()
end,
true)

--add character selected listener
core:add_listener(
    "RecruiterManagerOnCharacterSelected",
    "CharacterSelected",
    function(context)
    return context:character():faction():is_human() and context:character():has_military_force()
    end,
    function(context)
        rm:log("Human Character Selected by player!")
        local character = context:character()
        --# assume character: CA_CHAR
        --tell RM which character is selected. This is core to the entire system.
        rm:set_current_character(character:command_queue_index()) 
    end,
    true)
--add recruit panel open listener
core:add_listener(
    "RecruiterManagerOnRecruitPanelOpened",
    "PanelOpenedCampaign",
    function(context) 
        local panel = (context.string == "units_recruitment")
        if rm:current_character() == nil then
            return false
        end
        return panel 
    end,
    function(context)
        local current_character = rm:current_character()
        cm:callback(function() --do this on a delay so the panel has time to fully open before the script tries to read it!
            --first, define a holder for our recruit options
            local rec_opt = {} --:map<string, boolean>
            --next, get the paths we need to get
            local pathset = current_character._UIPathSet
            local paths_to_check = pathset:get_path_list(current_character)
            for j = 1, #paths_to_check do
                local recruitmentList = find_uicomponent_from_table(core:get_ui_root(), pathset:get_path(paths_to_check[j]))
                if not not recruitmentList then
                    for i = 0, recruitmentList:ChildCount() - 1 do	
                        local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                        local unitID = string.gsub(recruitmentOption, "_recruitable", "")
                        rec_opt[unitID] = true
                    end
                end
            end
            rm:check_all_ui_recruitment_options(current_character, rec_opt)
            rm:enforce_units_by_table(rec_opt, current_character)
        end, 0.2)
    end,
    true
)

--multiplayer safe listener
core:add_listener(
    "UITriggerScriptEventRecruiterManager",
    "UITriggerScriptEvent",
    function(context)
        return context:trigger():starts_with("recruiter_manager|force_stance|")
    end,
    function(context)
        local trigger = context:trigger() --:string
        local cqi = trigger:gsub("recruiter_manager|force_stance|", "")
        --# assume cqi: CA_CQI
        if not (cm:get_character_by_cqi(cqi):military_force():active_stance() == "MILITARY_FORCE_ACTIVE_STANCE_TYPE_SETTLE") then
            cm:force_character_force_into_stance(cm:char_lookup_str(cqi), "MILITARY_FORCE_ACTIVE_STANCE_TYPE_SETTLE")
        end
    end,
    true
)
--stance return listener --TODO figure out if this weird stance stuff is necessary
--TODO2 figure out if this is the reason vandy shit doesn't work with RM 
--[[
core:add_listener(
    "RecruiterManagerPirateShipStance",
    "ForceAdoptsStance",
    function(context)
        return context:military_force():active_stance() ~= "MILITARY_FORCE_ACTIVE_STANCE_TYPE_SETTLE" and context:military_force():has_general() and rm:is_subtype_char_horde(context:military_force():general_character():character_subtype_key())
    end,
    function(context)
        local button = find_uicomponent(core:get_ui_root(), "layout", "hud_center_docker", "hud_center", "small_bar", "button_group_army", "button_recruitment")
        if not not button then
            if cm:get_campaign_ui_manager():is_panel_open("units_recruitment") then
                button:SimulateLClick()
            end
        end
    end,
    true
)--]]

--add mercenary panel open listener
core:add_listener(
    "RecruiterManagerOnMercenaryPanelOpened",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "mercenary_recruitment"; 
    end,
    function(context)
        cm:callback(function() --do this on a delay so the panel has time to fully open before the script tries to read it!
            --check every unit which has a restriction against the character's lists. This will call refresh on queue and army further upstream when necessary!
            local recruitmentList = find_uicomponent(core:get_ui_root(), 
            "units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "mercenary_display", "listview", "list_clip", "list_box")
            local current_character = rm:current_character()
            for i = 0, recruitmentList:ChildCount() - 1 do	
                local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                local unitID = string.gsub(recruitmentOption, "_mercenary", "")
                rm:check_unit_for_loop(current_character, unitID)
                rm:enforce_ui_restriction_on_unit(rm:get_unit(unitID))
            end
        end, 0.1)
    end,
    true
)

--add disbanded listener
core:add_listener(
    "RecruiterManagerUnitDisbanded",
    "UnitDisbanded",
    function(context)
        return context:unit():faction():is_human() and rm:has_character(context:unit():force_commander():command_queue_index())
    end,
    function(context)
        rm:log("Human character disbanded a unit!")
        local unit = context:unit()
        --# assume unit: CA_UNIT
        --remove the unit from the army
        rm:get_character_by_cqi(unit:force_commander():command_queue_index()):remove_unit_from_army(unit:unit_key())
        --check the unit (+groups) again.
        rm:check_individual_unit_on_character(rm:current_character(), unit:unit_key())
        --if the unit has a pool, refund it
        --[[ --TODO unit pools
        if rm:unit_has_pool(unit:unit_key()) then
            rm:change_unit_pool(unit:unit_key(), unit:faction():name(), 1)
        end--]]
        rm:enforce_all_units_on_current_character()
    end,
    true);
--add merged listener
core:add_listener(
    "RecruiterManagerUnitMerged",
    "UnitMergedAndDestroyed",
    function(context)
        return context:new_unit():faction():is_human() and rm:has_character(context:new_unit():force_commander():command_queue_index())
    end,
    function(context)
        local unit = context:new_unit():unit_key() --:string
        local cqi = context:new_unit():force_commander():command_queue_index() --:CA_CQI
        --there is a lot of possibilies when a merge has happened
        --to be safe, we just set the army stale. 
        rm:get_character_by_cqi(cqi):set_army_stale()
        cm:remove_callback("RMMergeDestroy")
        cm:callback(function()
            rm:check_all_units_on_character(rm:get_character_by_cqi(cqi))
        end, 0.2, "RMMergeDestroy")
    end,
    true)

-------------
--transfers--
-------------
RM_TRANSFERS = {} --:map<string, CA_CQI>
--v function() --> CA_CQI
local function find_second_army()

    --v function(ax: number, ay: number, bx: number, by: number) --> number
    local function distance_2D(ax, ay, bx, by)
        return (((bx - ax) ^ 2 + (by - ay) ^ 2) ^ 0.5);
    end;

    local first_char = cm:get_character_by_cqi(rm._UICurrentCharacter)
    local char_list = first_char:faction():character_list()
    local closest_char --:CA_CHAR
    local last_distance = 50 --:number
    local ax = first_char:logical_position_x()
    local ay = first_char:logical_position_y()
    for i = 0, char_list:num_items() - 1 do
        local char = char_list:item_at(i)
        if cm:char_is_mobile_general_with_army(char) then
            if char:command_queue_index() == first_char:command_queue_index() then

            else
                local dist = distance_2D(ax, ay, char:logical_position_x(), char:logical_position_y())
                if dist < last_distance then
                    last_distance = dist
                    closest_char = char
                end
            end
        end
    end
    if closest_char then
        --the extra call is to force load the char into the model
        return rm:get_character_by_cqi(closest_char:command_queue_index()):command_queue_index()
    else
        rm:log("failed to find the other char!")
        return nil
    end
end

--v function(panel: string, index: number) --> (string, boolean)
local function GetUnitNameInExchange(panel, index)
    local Panel = find_uicomponent(core:get_ui_root(), "unit_exchange", panel)
    if not not Panel then
        local armyUnit = find_uicomponent(Panel, "units", "UnitCard" .. index);
        if not not armyUnit then
            armyUnit:SimulateMouseOn();
            local unitInfo = find_uicomponent(core:get_ui_root(), "UnitInfoPopup", "tx_unit-type");
            local rawstring = unitInfo:GetStateText();
            local infostart = string.find(rawstring, "unit/") + 5;
            local infoend = string.find(rawstring, "]]") - 1;
            local armyUnitName = string.sub(rawstring, infostart, infoend)
            rm:log("Found unit ["..armyUnitName.."] at ["..index.."] ")
            local is_transfered = false --:boolean
            local transferArrow = find_uicomponent(armyUnit, "exchange_arrow")
            if not not transferArrow then 
                is_transfered = transferArrow:Visible()
            end
            return armyUnitName, is_transfered
        else
            return nil, false
        end
    end
    return nil, false
end

--v function(reason: string)
local function LockExchangeButton(reason)
    local ok_button = find_uicomponent(core:get_ui_root(), "unit_exchange", "hud_center_docker", "ok_cancel_buttongroup", "button_ok")
    if not not ok_button then
        ok_button:SetInteractive(false)
        ok_button:SetImage("ui/custom/recruitment_controls/fuckoffbutton.png")
    else
        rm:log("ERROR: could not find the exchange ok button!")
    end
end

--v function()
local function UnlockExchangeButton()
    local ok_button = find_uicomponent(core:get_ui_root(), "unit_exchange", "hud_center_docker", "ok_cancel_buttongroup", "button_ok")
    if not not ok_button then
        ok_button:SetInteractive(true)
        ok_button:SetImage("ui/skins/default/icon_check.png")
    else
        rm:log("ERROR: could not find the exchange ok button!")
    end
end


--v function(army_count: map<string, number>, rec_char: RECRUITER_CHARACTER) --> (boolean, string)
local function check_individual_army_validity(army_count, rec_char)
    local clock = os.clock()
    --for each unit that appears in the army
    for unitID, count in pairs(army_count) do
        --make sure the army isn't over an individual limit
        if count > rm:get_quantity_limit_for_unit(unitID) then
            rm:log("Army validity processed: ".. string.format("elapsed time: %.2f", os.clock() - clock))
            return false, "Too many individual restricted units in an army!"
        end
        local unit = rm:get_unit(unitID, rec_char)
        local groups = unit:groups()
        --loop through the groups that the unit is a member of.
        for groupID, _ in pairs(groups) do
            local grouped_count = 0 --:number
            local grouped_units = rm:get_units_in_group(groupID) --get the full list of units in that group.
            for i = 1, #grouped_units do
                local c_unitID = grouped_units[i]
                --if the army has that unit, (and the copy of the unit we are dealing with is really in the group) add the number of that unit weighted.
                if army_count[c_unitID] and rm:get_unit(c_unitID, rec_char)._groups[groupID] then
                    grouped_count = grouped_count + (army_count[c_unitID] * rm:get_unit(c_unitID, rec_char):weight())
                end
            end
            --joiners are factored 
            if grouped_count > rm:get_quantity_limit_for_group(groupID) then
                rm:log("Army validity processed: ".. string.format("elapsed time: %.2f", os.clock() - clock))
                return false, "Too many units from group "..rm:get_ui_name_for_group(groupID).." in an army!"
            end
        end        
    end
    return true, "valid"
end



--v function(first_army_count: map<string, number>, second_army_count:map<string, number>) --> (boolean, string)
local function are_armies_valid(first_army_count, second_army_count)
    local first_result, first_string = check_individual_army_validity(first_army_count, rm:get_character_by_cqi(RM_TRANSFERS.first))
    if first_result == false then
        return first_result, first_string
    end
    local second_result, second_string = check_individual_army_validity(second_army_count, rm:get_character_by_cqi(RM_TRANSFERS.second))
    return second_result, second_string
end

--v function() --> (map<string, number>, map<string, number>)
local function count_armies()
    local first_army_count = {} --:map<string, number>
    local second_army_count = {} --:map<string, number>
    local clock = os.clock()
    for i = 1, 20 do
        local unitID, is_transfer = GetUnitNameInExchange("main_units_panel_1", i)
        if not not unitID then
            if is_transfer then
                if second_army_count[unitID] == nil then
                    second_army_count[unitID] = 0
                end
                second_army_count[unitID] = second_army_count[unitID] + 1
            else
                if first_army_count[unitID] == nil then
                    first_army_count[unitID] = 0
                end
                first_army_count[unitID] = first_army_count[unitID] + 1
            end
        end
    end
    rm:log("First army processed: ".. string.format("elapsed time: %.2f", os.clock() - clock))
    local clock = os.clock()
    for i = 1, 20 do
        local unitID, is_transfer = GetUnitNameInExchange("main_units_panel_2", i)
        if not not unitID then
            if not is_transfer then
                if second_army_count[unitID] == nil then
                    second_army_count[unitID] = 0
                end
                second_army_count[unitID] = second_army_count[unitID] + 1
            else
                if first_army_count[unitID] == nil then
                    first_army_count[unitID] = 0
                end
                first_army_count[unitID] = first_army_count[unitID] + 1
            end
        end
    end
    rm:log("Secondary army processed: ".. string.format("elapsed time: %.2f", os.clock() - clock))
    return first_army_count, second_army_count
end





core:add_listener(
    "RecruiterManagerOnExchangePanelOpened",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "unit_exchange"; 
    end,
    function(context)
        cm:callback(function() --do this on a delay so the panel has time to fully open before the script tries to read it!
            -- print_all_uicomponent_children(find_uicomponent(core:get_ui_root(), "unit_exchange"))
            RM_TRANSFERS.first = rm._UICurrentCharacter
            RM_TRANSFERS.second = find_second_army()
            local first_army, second_army = count_armies()
            local valid_armies, reason = are_armies_valid(first_army, second_army)
            if valid_armies then
                UnlockExchangeButton()
            else
                rm:log("locking exchange button for reason ["..reason.."] ")
                LockExchangeButton(reason)
            end
        end, 0.1)
    end,
    true
)

core:add_listener(
    "RecruiterManagerOnExchangeOptionClicked",
    "ComponentLClickUp",
    function(context)
        return not not string.find(context.string, "UnitCard") 
    end,
    function(context)
        cm:remove_callback("RMTransferReval")
        cm:callback(function()
                rm:log("refreshing army validity")
                local first_army, second_army = count_armies()
                local valid_armies, reason = are_armies_valid(first_army, second_army)
                if valid_armies then
                    UnlockExchangeButton()
                else
                    rm:log("locking exchange button for reason ["..reason.."] ")
                    LockExchangeButton(reason)
                end
        end, 0.1, "RMTransferReval")
    
    end,
    true);


core:add_listener(
    "RecruiterManagerOnExchangePanelClosed",
    "PanelClosedCampaign",
    function(context)
        return context.string == "unit_exchange"
    end,
    function(context)
        rm:log("Exchange panel closed, setting armies stale!")
        for _, cqi in pairs(RM_TRANSFERS) do
            rm:get_character_by_cqi(cqi):set_army_stale()
        end
    end,
    true
)


--[[
if Util then
    core:add_listener(
        "ComponentMouseHoverRMInfo",
        "ComponentMouseHover",
        function(context)
            local hoverbox = find_uicomponent()
        end,
    )




end]]