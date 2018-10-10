local gt = _G.gt
local sfo = _G.sfo

local gt_events = {
    --won a battle
    {
        event = "CharacterCompletedBattle",
        condition = function(context)
            return context:character():won_battle()
        end,
        faction = function(context)
            return context:character():faction():name()
        end,
        value = 1 
    },
    --lost a battle
    {
        event = "CharacterCompletedBattle",
        condition = function(context)
            return not context:character():won_battle()
        end,
        faction = function(context)
            return context:character():faction():name()
        end,
        value = -2
    },
    --ranked up
    {
        event = "CharacterRankUp",
        condition = function(context)
            return context:character():rank() == 7
        end,
        faction = function(context)
            return context:character():faction():name()
        end,
        value = 1 
    },
    --build a building
    {
        event = "BuildingCompleted",
        condition = function(context)
            return (context:building():name() == "grn_tower4" or
             context:building():name() == "grn_tower_orc5" or
             context:building():name() == "grn_tower_gob5" or
              context:building():name() == "grn_tower_sav5")
        end,
        faction = function(context)
            return context:building():faction():name()
        end,
        value = 1 
    },
    --Sacked Settlement
    {
        event = "CharacterSackedSettlement",
        condition = function(context)
            return true
        end,
        faction = function(context)
            return context:character():faction():name()
        end,
        value = 1
    },
    --Occupied a settlement
    {
        event = "GarrisonOccupiedEvent",
        condition = function(context)
            return true
        end,
        faction = function(context)
            return context:character():faction():name()
        end,
        value = 1
    },
    --researched a tech
    {
        event = "ResearchCompleted",
        condition = function(context)
            return (context:technology() == "grn_gob" or
            context:technology() == "grn_orc" or
            context:technology() == "grn_sav" or
            context:technology() == "grn_tech")
        end,
        faction = function(context)
            return context:faction():name()
        end,
        value = 1
    },
    --post battle slaughter
    {
        event = "CharacterPostBattleSlaughter",
        condition = function(context)
            if not cm:get_saved_value("GTCharacterPostBattleSlaughter") then
                cm:set_saved_value("GTCharacterPostBattleSlaughter", 0)
            end
            val = cm:get_saved_value("GTCharacterPostBattleSlaughter")
            val = val + 1
            if val >= 3 then
                cm:set_saved_value("GTCharacterPostBattleSlaughter", 0)
                return true
            else
                cm:set_saved_value("GTCharacterPostBattleSlaughter", val)
                return false
            end
        end,
        faction = function(context)
            return context:character():faction():name()
        end,
        value = 1
    },
    {
        event = "CharacterCharacterTargetAction",
        condition = function(context)
            return (context:mission_result_success() or context:mission_result_critial_success())
        end,
        faction = function(context)
            return context:character():faction():name()
        end,
        value = 1
    },
    --decay over time
    {
        event = "FactionTurnStart",
        condition = function(context)
            if not cm:get_saved_value("GTFactionTurnStart") then
                cm:set_saved_value("GTFactionTurnStart", 0)
            end
            val = cm:get_saved_value("GTFactionTurnStart")
            val = val + 1
            if val >= 8 then
                cm:set_saved_value("GTFactionTurnStart", 0)
                return true
            else
                cm:set_saved_value("GTFactionTurnStart", val)
                return false
            end
        end,
        faction = function(context)
            return context:faction():name()
        end,
        value = -1
    },
    {
        event = "RegionRebels",
        condition = function(context)
            return true
        end,
        faction = function(context)
            return context:region():owning_faction():name()
        end,
        value = -1
    }
}--:vector<{event: string, condition: (function(context: WHATEVER) --> boolean), faction: (function(context: WHATEVER) --> string), value: number}>

    

for i = 1, #gt_events do
    local current = gt_events[i]
    gt:add_event(current.event, current.condition, current.faction, current.value)
end


events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() 
    local faction_list = cm:model():world():faction_list()
    for i = 0, faction_list:num_items() do
        local faction = faction_list:item_at(i)
        if faction:subculture() == "wh_main_sc_grn_greenskins" or faction:subculture() == "wh_main_sc_grn_savage_orcs" then
            if cm:get_saved_value("gt_tracker_"..faction:name()) == nil then
                cm:set_saved_value("gt_tracker_"..faction:name(), 1)
                gt._levels[faction:name()] = 1
            else
                gt._levels[faction:name()] = cm:get_saved_value("gt_tracker_"..faction:name())
                sfo:log("Loaded greentide faction ["..faction:name().."] with the value ["..gt._levels[faction:name()].."] ")
            end
        end
    end
end;