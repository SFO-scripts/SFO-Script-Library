--grab rm, cm and events
events = get_events(); cm = get_cm(); rm = _G.rm;

rm:error_checker() --turn on error checking

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
            print_all_uicomponent_children(UIComponent(context.component))
            --its a unit! steal the users input so that they don't click more shit while we calculate.
            cm:steal_user_input(true);
            rm:log("Locking recruitment button for ["..unit_component_ID.."] temporarily");
            --reduce the string to get the name of the unit.
            local unitID = string.gsub(unit_component_ID, "_recruitable", "")
            --add the unit to queue so that our model knows it exists.
            rm:current_character():add_unit_to_queue(unitID)
            --run the checks on that character with the updated queue quantities.
            cm:callback(function()
            rm:check_unit_on_character(unitID)
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
            rm:check_unit_on_character(unitID)
            end, 0.1)
        end
    end,
    true);


--add queued unit clicked listener
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
        rm:current_character():set_queue_stale()
        cm:remove_callback("RMOnQueue")
        cm:callback( function() -- we callback this because if we don't do it on a small delay, it will pick up the unit we just cancelled as existing!
            --we want to re-evaluate the units who were previously in queue, they may have changed.
            local queue_counts = rm:current_character():get_queue_counts() 
            for unitID, _ in pairs(queue_counts) do
                --check the units again. This eventually calls a get on the queue counts, which will trigger a queue re-evaluation
                rm:check_unit_on_character(unitID)
            end
        end, 0.2, "RMOnQueue")
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
        rm:current_character():set_queue_stale()
        cm:remove_callback("RMOnMerc")
        cm:callback( function() -- we callback this because if we don't do it on a small delay, it will pick up the unit we just cancelled as existing!
            --we want to re-evaluate the units who were previously in queue, they may have changed.
            local queue_counts = rm:current_character():get_queue_counts() 
            local recruitmentList = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel",
            "recruitment_docker", "recruitment_options", "recruitment_listbox", "global", "unit_list", "listview", "list_clip", "list_box")
            if not not recruitmentList then
                for i = 0, recruitmentList:ChildCount() - 1 do	
                    local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                    local unitID = string.gsub(recruitmentOption, "_recruitable", "")
                    rm:check_unit_on_individual_character_for_loop(unitID)
                    rm:current_character():enforce_unit_restriction(unitID)
                end
            else
                local recruitmentList = find_uicomponent(core:get_ui_root(), 
                "units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox",
                "local1", "unit_list", "listview", "list_clip", "list_box"
                )
                if not not recruitmentList then
                    for i = 0, recruitmentList:ChildCount() - 1 do	
                        local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                        local unitID = string.gsub(recruitmentOption, "_recruitable", "")
                        rm:check_unit_on_individual_character_for_loop(unitID)
                        rm:current_character():enforce_unit_restriction(unitID)
                    end
                end
            end
            local recruitmentList = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "local2", "unit_list", "listview", "list_clip", "list_box")
            if not not recruitmentList then
                for i = 0, recruitmentList:ChildCount() - 1 do	
                    local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                    local unitID = string.gsub(recruitmentOption, "_recruitable", "")
                    rm:check_unit_on_individual_character_for_loop(unitID)
                    rm:current_character():enforce_unit_restriction(unitID)
                end
            end
        end, 0.2, "RMOnMerc")
    end
end,
true);






--add character moved listener
core:add_listener(
"RecruiterManagerPlayerCharacterMoved",
"CharacterFinishedMoving",
function(context)
    return context:character():faction():is_human() and rm:has_character(context:character():cqi())
end,
function(context)
    rm:log("Player Character moved!")
    local character = context:character()
    --# assume character: CA_CHAR
    --the character moved, so we're going to set both their army and their queue stale and force the script to re-evaluate them next time they are available.
    rm:get_character_by_cqi(character:cqi()):set_army_stale()
    rm:get_character_by_cqi(character:cqi()):set_queue_stale()
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
        rm:set_current_character(character:cqi()) 
    end,
    true)
--add recruit panel open listener
core:add_listener(
    "RecruiterManagerOnRecruitPanelOpened",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "units_recruitment"; 
    end,
    function(context)
        cm:callback(function() --do this on a delay so the panel has time to fully open before the script tries to read it!
            --check every unit which has a restriction against the character's lists. This will call refresh on queue and army further upstream when necessary!
            local recruitmentList = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel",
            "recruitment_docker", "recruitment_options", "recruitment_listbox", "global", "unit_list", "listview", "list_clip", "list_box")
            if not not recruitmentList then
                for i = 0, recruitmentList:ChildCount() - 1 do	
                    local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                    local unitID = string.gsub(recruitmentOption, "_recruitable", "")
                    rm:check_unit_on_individual_character_for_loop(unitID)
                    rm:current_character():enforce_unit_restriction(unitID)
                end
            else
                local recruitmentList = find_uicomponent(core:get_ui_root(), 
                "units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox",
                "local1", "unit_list", "listview", "list_clip", "list_box"
                )
                if not not recruitmentList then
                    for i = 0, recruitmentList:ChildCount() - 1 do	
                        local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                        local unitID = string.gsub(recruitmentOption, "_recruitable", "")
                        rm:check_unit_on_individual_character_for_loop(unitID)
                        rm:current_character():enforce_unit_restriction(unitID)
                    end
                end
            end
            local recruitmentList = find_uicomponent(core:get_ui_root(), "units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox", "local2", "unit_list", "listview", "list_clip", "list_box")
            if not not recruitmentList then
                for i = 0, recruitmentList:ChildCount() - 1 do	
                    local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                    local unitID = string.gsub(recruitmentOption, "_recruitable", "")
                    rm:check_unit_on_individual_character_for_loop(unitID)
                    rm:current_character():enforce_unit_restriction(unitID)
                end
            end
        end, 0.1)
    end,
    true
)

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
            for i = 0, recruitmentList:ChildCount() - 1 do	
                local recruitmentOption = UIComponent(recruitmentList:Find(i)):Id();
                local unitID = string.gsub(recruitmentOption, "_mercenary", "")
                rm:check_unit_on_individual_character_for_loop(unitID)
                rm:current_character():enforce_unit_restriction(unitID)
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
        return context:unit():faction():is_human() and rm:has_character(context:unit():force_commander():cqi())
    end,
    function(context)
        rm:log("Human character disbanded a unit!")
        local unit = context:unit()
        --# assume unit: CA_UNIT
        --remove the unit from the army
        rm:get_character_by_cqi(unit:force_commander():cqi()):remove_unit_from_army(unit:unit_key())
        --check the unit (+groups) again.
        rm:check_unit_on_character(unit:unit_key())
        --if the unit has a pool, refund it
        if rm:unit_has_pool(unit:unit_key()) then
            rm:change_unit_pool(unit:unit_key(), unit:faction():name(), 1)
        end
    end,
    true);
--add merged listener
core:add_listener(
    "RecruiterManagerUnitMerged",
    "UnitMergedAndDestroyed",
    function(context)
        return context:new_unit():faction():is_human() and rm:has_character(context:new_unit():force_commander():cqi())
    end,
    function(context)
        local unit = context:new_unit():unit_key() --:string
        local cqi = context:new_unit():force_commander():cqi() --:CA_CQI
        --there is a lot of possibilies when a merge has happened
        --to be safe, we just set the army stale. 
        rm:get_character_by_cqi(cqi):set_army_stale()
        cm:callback(function()
            rm:check_unit_on_character(unit)
        end, 0.5)
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

    local first_char = cm:get_character_by_cqi(rm._currentCharacter)
    local char_list = first_char:faction():character_list()
    local closest_char --:CA_CHAR
    local last_distance = 50 --:number
    local ax = first_char:logical_position_x()
    local ay = first_char:logical_position_y()
    for i = 0, char_list:num_items() - 1 do
        local char = char_list:item_at(i)
        if cm:char_is_mobile_general_with_army(char) then
            if char:cqi() == first_char:cqi() then

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
        return rm:get_character_by_cqi(closest_char:cqi()):cqi()
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
        ok_button:SetImage("ui/skins/default/icon_disband.png")
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

--v function(first_army_count: map<string, number>, second_army_count:map<string, number>) --> (boolean, string)
local function are_armies_valid(first_army_count, second_army_count)

    for unitID, count in pairs(first_army_count) do
        if count > rm:get_quantity_limit_for_unit(unitID) then
            return false, "Too many individual restricted units in an army!"
        end
        local groups = rm:get_groups_for_unit(unitID, RM_TRANSFERS.first)
        for i = 1, #groups do
            local grouped_units = rm:get_units_in_group(groups[i])
            local group_total = 0 --:number
            rm:log("Doing group ["..groups[i].."] for ["..tostring(RM_TRANSFERS.first).."] looking for limit ["..rm:get_quantity_limit_for_group(groups[i]).."] ")
            for j = 1, #grouped_units do
                if not rm:unit_has_group_override(RM_TRANSFERS.first, grouped_units[j], groups[i]) then
                    if first_army_count[grouped_units[j]] == nil then
                        first_army_count[grouped_units[j]] = 0
                    end
                    group_total = group_total + (first_army_count[grouped_units[j]] * rm:get_weight_for_unit(grouped_units[j], RM_TRANSFERS.first))
                    rm:log("processed unit ["..grouped_units[j].."], group total at ["..group_total.."] ")
                end
            end
            local joined_units = rm:get_override_joiners_for_group(groups[i], cm:get_character_by_cqi(RM_TRANSFERS.first):character_subtype_key())
            for j = 1, #joined_units do
                if first_army_count[joined_units[j]] == nil then
                    first_army_count[joined_units[j]] = 0
                end
                group_total = group_total + (first_army_count[joined_units[j]] * rm:get_weight_for_unit(joined_units[j], RM_TRANSFERS.first))
            end
            if group_total > rm:get_quantity_limit_for_group(groups[i]) then
                return false, "Too many units from group "..rm:get_ui_name_for_group(groups[i]).." in an army!"
            end
        end
    end

    for unitID, count in pairs(second_army_count) do
        if count > rm:get_quantity_limit_for_unit(unitID) then
            return false, "Too many individual restricted units in an army!"
        end
        local groups = rm:get_groups_for_unit(unitID, RM_TRANSFERS.second)
        for i = 1, #groups do
            local grouped_units = rm:get_units_in_group(groups[i])
            local group_total = 0 --:number
            rm:log("Doing group ["..groups[i].."] for ["..tostring(RM_TRANSFERS.second).."] looking for limit ["..rm:get_quantity_limit_for_group(groups[i]).."] ")
            for j = 1, #grouped_units do
                if not rm:unit_has_group_override(RM_TRANSFERS.second, grouped_units[j], groups[i]) then
                    if second_army_count[grouped_units[j]] == nil then
                        second_army_count[grouped_units[j]] = 0
                    end
                    group_total = group_total + (second_army_count[grouped_units[j]] * rm:get_weight_for_unit(grouped_units[j], RM_TRANSFERS.second))
                    rm:log("processed unit ["..grouped_units[j].."], group total at ["..group_total.."] ")
                end
            end
            local joined_units = rm:get_override_joiners_for_group(groups[i], cm:get_character_by_cqi(RM_TRANSFERS.second):character_subtype_key())
            for j = 1, #joined_units do
                if first_army_count[joined_units[j]] == nil then
                    first_army_count[joined_units[j]] = 0
                end
                group_total = group_total + (second_army_count[joined_units[j]] * rm:get_weight_for_unit(joined_units[j], RM_TRANSFERS.second))
            end
            if group_total > rm:get_quantity_limit_for_group(groups[i]) then
                return false, "Too many units from group "..rm:get_ui_name_for_group(groups[i]).." in an army!"
            end
        end
    end
    return true, "valid"
end

--v function() --> (map<string, number>, map<string, number>)
local function count_armies()
    local first_army_count = {} --:map<string, number>
    local second_army_count = {} --:map<string, number>

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
            RM_TRANSFERS.first = rm._currentCharacter
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
        rm:log("refreshing army validity")
        cm:callback( function()
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
    true);


core:add_listener(
    "RecruiterManagerOnExchangePanelClosed",
    "PanelClosedCampaign",
    function(context)
        return context.string == "unit_exchange"
    end,
    function(context)
        rm:log("Exchange panel closed, setting armies stale!")
        for cqi, character in pairs(rm:characters()) do
            character:set_army_stale()
        end
    end,
    true
)