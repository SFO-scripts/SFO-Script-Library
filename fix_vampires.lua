--log script to text
--v function(text: any)
local function LOG(text)
    if not __write_output_to_logfile then
        return; 
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("warhammer_expanded_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("PRG:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end
    


cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context)
    if not not Util then
        local UIPANELNAME = "purge"
        local ConfirmFrame = Frame.new(UIPANELNAME.."_confirm")
        ConfirmFrame:Resize(600, 500)
        ConfirmFrame:SetTitle("Vampirate Bug?")
        Util.centreComponentOnScreen(ConfirmFrame)
        local ConfirmText = Text.new(UIPANELNAME.."_confirm_info", ConfirmFrame, "HEADER", "Would you like to attempt a purge pirate coves in an attempt to solve the crash?")
        ConfirmText:Resize(420, 100)
        local ButtonYes = TextButton.new(UIPANELNAME.."_confirm_yes", ConfirmFrame, "TEXT", "Yes");
        ButtonYes:GetContentComponent():SetTooltipText("This will result in some settlements being raised, including possibly yours!", true)
        ButtonYes:Resize(300, 45);
        local ButtonAll = TextButton.new(UIPANELNAME.."_confirm_all", ConfirmFrame, "TEXT", "Purge more!");
        ButtonAll:GetContentComponent():SetTooltipText("This will result in more settlements being raised, including possibly yours! \n Only pick this option if you've tried the other one and it didn't work!", true)
        ButtonAll:Resize(300, 45);
        local ButtonNo = TextButton.new(UIPANELNAME.."_confirm_no", ConfirmFrame, "TEXT", "No");
        ButtonNo:GetContentComponent():SetTooltipText("Cancel", true)
        ButtonNo:Resize(300, 45);
        --v function()
        local function onYes()
            ConfirmFrame:Delete()
            --this is meant to be used to send a CQI, but it can take any integer!
            CampaignUI.TriggerCampaignScriptEvent(1, "PurgePirateCoves")
        end
        
        ButtonYes:RegisterForClick( function()
            local ok, err = pcall(onYes)
            if not ok then
                LOG("Error in reset function!")
                LOG(tostring(err))
            end
        end)
        --v function()
        local function onAll()
            ConfirmFrame:Delete()
            --this is meant to be used to send a CQI, but it can take any integer!
            CampaignUI.TriggerCampaignScriptEvent(3, "PurgePirateCoves")
        end
        ButtonAll:RegisterForClick( function()
            local ok, err = pcall(onYes)
            if not ok then
                LOG("Error in reset function!")
                LOG(tostring(err))
            end
        end)
    

        --v function()
        local function onNo()
            ConfirmFrame:Delete()
        end
        ButtonNo:RegisterForClick(function()
            onNo()
        end)

        Util.centreComponentOnComponent(ConfirmText, ConfirmFrame)
        local nudgeX, nudgeY = ConfirmText:Position()
        ConfirmText:MoveTo(nudgeX, nudgeY - 100)
        local offset = ConfirmText:Width()/2
        local fY = ConfirmFrame:Height()
        ButtonYes:PositionRelativeTo(ConfirmText, offset - 150, 60)
        ButtonAll:PositionRelativeTo(ButtonYes, 0, 60)
        ButtonNo:PositionRelativeTo(ButtonAll, 0, 60)
    end
end



core:add_listener(
    "Purge",
    "UITriggerScriptEvent",
    function(context)
        return context:trigger() == "PurgePirateCoves"
    end,
    function(context)
        LOG("PURGE ASKED FOR!")
        local faction_list = cm:model():world():faction_list()
        for i = 0, faction_list:num_items() - 1 do
            local faction = faction_list:item_at(i)
            if (not faction:is_quest_battle_faction()) and (not (faction:name() == "rebels")) and (not faction:is_human()) then 
                if faction:foreign_slot_managers():num_items() > 0 then
                    --remember we are using faction cqi as a num regions
                    if faction:region_list():num_items() <= context:faction_cqi() then
                        LOG("Starting purge on faction ["..faction:name().."] with ["..faction:region_list():num_items().."] regions and ["..faction:foreign_slot_managers():num_items().."] coves ")
                        for j = 0, faction:foreign_slot_managers():num_items() - 1 do
                            local cove = faction:foreign_slot_managers():item_at(i)
                            local region = cove:region()
                            LOG("Purging a cove in region ["..region:name().."]")
                            cm:treasury_mod(region:owning_faction():name(), 7000)
                            cm:set_region_abandoned(region:name())
                        end
                    end
                end
            end
        end
    end,
    true
)