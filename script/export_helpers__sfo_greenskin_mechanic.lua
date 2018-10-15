local gt = _G.gt
local sfo = _G.sfo
local events = get_events()
--# type global GT_EVENT = {event: string, condition: (function(context: WHATEVER) --> boolean), faction: (function(context: WHATEVER) --> string), value: number}
local gt_events = {
    --won a battle
    {
        event = "CharacterCompletedBattle",
        condition = function(context --:WHATEVER
        )
            return context:character():won_battle()
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
        value = -2
    },
    --ranked up
    {
        event = "CharacterRankUp",
        condition = function(context --:WHATEVER
        )
            return context:character():rank() == 7
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
            return true
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
            return true
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
            return (context:mission_result_success() or context:mission_result_critial_success())
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
            val = val + 1
            if val >= 8 then
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