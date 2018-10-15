local sfo = _G.sfo
local events = get_events()
---[[mr. venris edit this 
local spawn_units = {
    regular = {
    "wh_main_grn_mon_trolls", 
    "wh_main_grn_mon_trolls" 
    },
    savage_orcs = {
        "wh_main_grn_mon_trolls", 
        "wh_main_grn_mon_trolls" 
    },
    crooked_moon = {
        "wh_main_grn_mon_trolls", 
        "wh_main_grn_mon_trolls" 
    }
}--:{regular: vector<string>, savage_orcs: vector<string>, crooked_moon: vector<string>}
SFO_CONST_WAAGH_SIZE_BASE = 13 --:number
SFO_CONST_WAAGH_SIZE_VARIANCE = 6 --:number
SFO_CONST_WAAGH_ARMY_BUNDLE = "grn_greentide_manual_waagh" --:string
SFO_CONST_WAAGH_BUNDLE_TIMER = 0 --:number --set to 0 for infinite
--]]


--v function(faction: CA_FACTION)
local function sfo_spawn_waaagh(faction)
    local home_region = faction:home_region()
    if home_region:is_null_interface() or home_region:settlement():is_null_interface() then
        sfo:log("Failed to find a home region for spawning!")
        return
    end
    local grn_units = spawn_units.regular
    if faction:subculture() == "wh_main_sc_grn_savage_orcs" then
        grn_units = spawn_units.savage_orcs
    elseif faction:name() == "wh_main_grn_crooked_moon" then
        grn_units = spawn_units.crooked_moon
    end
    local unit_list = grn_units[cm:random_number(#grn_units)]
    for i = 1, SFO_CONST_WAAGH_SIZE_BASE + cm:random_number(SFO_CONST_WAAGH_SIZE_VARIANCE) - 1 do
        unit_list = unit_list .. ",".. grn_units[cm:random_number(#grn_units)]
    end

    cm:create_force(
        faction:name(),
        unit_list,
        home_region:name(),
        home_region:settlement():logical_position_x() - 1,
        home_region:settlement():logical_position_y() + 1,
        true,
        true,
        function(cqi)
            cm:apply_effect_bundle_to_characters_force(SFO_CONST_WAAGH_ARMY_BUNDLE, cqi, 0, true)
        end
    )

end

core:add_listener(
    "WaaghDilemma",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == "grn_greentide_choice_charactercompletedbattle"
    end,
    function(context)
        if context:choice() == 0 then
            sfo_spawn_waaagh(context:faction())
        end
    end,
    true
)