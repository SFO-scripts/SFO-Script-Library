-- Greentide EBS
-- Written by Drunk Flamingo
-- Original version for Norsca Patch Written 15/10/18
local gt = _G.gt
local sfo = _G.sfo
local events = get_events()

SFO_CONST_GRN_NUM_TURNS_BEFORE_DECAY = 8
SFO_CONST_GRN_NUM_SLAUGHTERS = 3
SFO_CONST_GRN_RANK_FOR_LEVEL = 7
SFO_CONST_GRN_NUM_BATTLES = 10
SFO_CONST_GRN_NUM_SACKS = 3
SFO_CONST_GRN_NUM_AGENT_ACTS = 3

--# type global GT_EVENT = {event: string, condition: (function(context: WHATEVER) --> boolean), faction: (function(context: WHATEVER) --> string), value: number}
local gt_events = {
    --won a battle
    {
        event = "CharacterCompletedBattle",
        condition = function(context --:WHATEVER
        )
            if context:character():won_battle() then
                local sv_string = "GTCharacterCompletedBattle"..context:character():faction():name()
                if not cm:get_saved_value(sv_string) then
                    cm:set_saved_value(sv_string, 0)
                end
                local val = cm:get_saved_value(sv_string)
                val = val + 1
                if val >= SFO_CONST_GRN_NUM_BATTLES then
                    cm:set_saved_value(sv_string, 0)
                    return true
                else
                    cm:set_saved_value(sv_string, val)
                end
            end
            return false
        end,
        faction = function(context --:WHATEVER
        )
            return context:character():faction():name()
        end,
        value = 1 
    },
    --lost a battle
    {
        event = "GTFactionLostBattle",
        condition = function(context --:WHATEVER
        )
            return true
        end,
        faction = function(context --:WHATEVER
        )
            return context:faction():name()
        end,
        value = -1
    },
    --ranked up
    {
        event = "CharacterRankUp",
        condition = function(context --:WHATEVER
        )
            return context:character():rank() == SFO_CONST_GRN_RANK_FOR_LEVEL
        end,
        faction = function(context --:WHATEVER
        )
            return context:character():faction():name()
        end,
        value = 1 
    },
    --build a building
    {
        event = "BuildingCompleted",
        condition = function(context --:WHATEVER
        )
            return (context:building():name() == "grn_tower4" or
             context:building():name() == "grn_tower_orc5" or
             context:building():name() == "grn_tower_gob5" or
              context:building():name() == "grn_tower_sav5")
        end,
        faction = function(context --:WHATEVER
        )
            return context:building():faction():name()
        end,
        value = 1 
    },
    --Sacked Settlement
    {
        event = "CharacterSackedSettlement",
        condition = function(context --:WHATEVER
        )
            local sv_string = "GTCharacterSackedSettlement"..context:character():faction():name()
            if not cm:get_saved_value(sv_string) then
                cm:set_saved_value(sv_string, 0)
            end
            local val = cm:get_saved_value(sv_string)
            val = val + 1
            if val >= SFO_CONST_GRN_NUM_SACKS then
                cm:set_saved_value(sv_string, 0)
                return true
            else
                cm:set_saved_value(sv_string, val)
            end
            return false
        end,
        faction = function(context --:WHATEVER
        )
            return context:character():faction():name()
        end,
        value = 1
    },
    --Occupied a settlement
    {
        event = "GarrisonOccupiedEvent",
        condition = function(context --:WHATEVER
        )
            local char = context:character() --:CA_CHAR
            local gar = context:garrison_residence() --:CA_GARRISON_RESIDENCE
            if cm:get_saved_value("GTGarrisonOccupiedEvent"..char:faction():name()..gar:region():province_name()) then
                return false
            end
            if char:faction():holds_entire_province(gar:region():province_name(), true) then
                cm:set_saved_value("GTGarrisonOccupiedEvent"..char:faction():name()..gar:region():province_name(), true)
                return true
            end
            return false
        end,
        faction = function(context --:WHATEVER
        )
            return context:character():faction():name()
        end,
        value = 1
    },
    --researched a tech
    {
        event = "ResearchCompleted",
        condition = function(context --:WHATEVER
        )
            return (context:technology() == "grn_gob" or
            context:technology() == "grn_orc" or
            context:technology() == "grn_sav" or
            context:technology() == "grn_tech")
        end,
        faction = function(context --:WHATEVER
        )
            return context:faction():name()
        end,
        value = 1
    },
    --post battle slaughter
    {
        event = "CharacterPostBattleSlaughter",
        condition = function(context --:WHATEVER
        )
            local sv_string = "GTCharacterPostBattleSlaughter"..context:character():faction():name()
            if not cm:get_saved_value(sv_string) then
                cm:set_saved_value(sv_string, 0)
            end
            val = cm:get_saved_value(sv_string)
            val = val + 1
            if val >= SFO_CONST_GRN_NUM_SLAUGHTERS then
                cm:set_saved_value(sv_string, 0)
                return true
            else
                cm:set_saved_value(sv_string, val)
                return false
            end
        end,
        faction = function(context --:WHATEVER
        )
            return context:character():faction():name()
        end,
        value = 1
    },
    {
        event = "CharacterCharacterTargetAction",
        condition = function(context --:WHATEVER
        )
            if context:mission_result_success() or context:mission_result_critial_success() then
                local sv_string = "GTCharacterCharacterTargetAction"..context:character():faction():name()
                if not cm:get_saved_value(sv_string) then
                    cm:set_saved_value(sv_string, 0)
                end
                local val = cm:get_saved_value(sv_string)
                val = val + 1
                if val >= SFO_CONST_GRN_NUM_AGENT_ACTS then
                    cm:set_saved_value(sv_string, 0)
                    return true
                else
                    cm:set_saved_value(sv_string, val)
                end
            end
            return false
        end,
        faction = function(context --:WHATEVER
        )
            return context:character():faction():name()
        end,
        value = 1
    },
    --decay over time
    {
        event = "FactionTurnStart",
        condition = function(context --:WHATEVER
        )
            if not cm:get_saved_value("GTFactionTurnStart"..context:faction():name()) then
                cm:set_saved_value("GTFactionTurnStart"..context:faction():name(), 0)
            end
            val = cm:get_saved_value("GTFactionTurnStart"..context:faction():name())
            if val >= SFO_CONST_GRN_NUM_TURNS_BEFORE_DECAY then
                cm:set_saved_value("GTFactionTurnStart"..context:faction():name(), 0)
                return true
            else
                cm:set_saved_value("GTFactionTurnStart"..context:faction():name(), val)
                return false
            end
        end,
        faction = function(context --:WHATEVER
        )
            return context:faction():name()
        end,
        value = -1
    },
    {
        event = "RegionRebels",
        condition = function(context --:WHATEVER
        )
            return true
        end,
        faction = function(context --:WHATEVER
        )
            return context:region():owning_faction():name() 
        end,
        value = -1
    }
}--:vector<GT_EVENT>

    

for i = 1, #gt_events do
    local current = gt_events[i]
    gt:add_event(current.event, current.condition, current.faction, current.value)
end


events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() 
    local faction_list = cm:model():world():faction_list()
    for i = 0, faction_list:num_items() - 1 do
        local faction = faction_list:item_at(i)
        if gt:is_valid_greentide_faction(faction:name()) then
            if cm:get_saved_value("gt_tracker_"..faction:name()) == nil then
                cm:set_saved_value("gt_tracker_"..faction:name(), 1)
                gt._levels[faction:name()] = 1
                cm:apply_effect_bundle("grn_greentide_1", faction:name(), 0)
            else
                gt._levels[faction:name()] = cm:get_saved_value("gt_tracker_"..faction:name())
                gt:log("Loaded greentide faction ["..faction:name().."] with the value ["..gt._levels[faction:name()].."] ")
            end
        end
    end
end;


core:add_listener(
    "GTSupplementCharacterLostBattle",
    "CharacterCompletedBattle",
    function(context)
        return context:character():won_battle()
    end,
    function(context)
        local pb = context:pending_battle() --:CA_PENDING_BATTLE
        local character = context:character() --:CA_CHAR
        local enemies = cm:pending_battle_cache_get_enemies_of_char(character)
        for i = 1, #enemies do
            local enemy = enemies[i]
            local enemy_faction = enemy:faction():name()
            if gt:is_valid_greentide_faction(enemy_faction) then
                core:trigger_event("GTFactionLostBattle", enemy:faction())
            end
        end
    end,
    true
)