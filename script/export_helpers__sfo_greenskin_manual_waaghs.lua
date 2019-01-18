cm = get_cm(); sfo = _G.sfo
---[[mr. venris edit this 
local spawn_units = {
    regular = {
    "wh_main_grn_inf_orc_boyz", 
    "wh_main_grn_inf_orc_boyz", 
    "wh_main_grn_inf_orc_boyz", 
    "wh_main_grn_inf_orc_boyz", 
    "wh_main_grn_inf_orc_boyz", 
    "wh_main_grn_inf_orc_boyz", 
    "wh_main_grn_inf_orc_arrer_boyz", 
    "wh_main_grn_inf_orc_arrer_boyz",
    "wh_main_grn_inf_orc_arrer_boyz",
    "wh_main_grn_cav_orc_boar_boyz", 
    "wh_main_grn_cav_orc_boar_boyz", 
    "wh_main_grn_cav_orc_boar_boyz", 
    "wh_main_grn_cav_orc_boar_chariot"
    },
    savage_orcs = {
    "wh_main_grn_inf_savage_orcs",
    "wh_main_grn_inf_savage_orcs",
    "wh_main_grn_inf_savage_orcs",
    "wh_main_grn_inf_savage_orcs",
    "wh_main_grn_inf_savage_orcs",
    "wh_main_grn_inf_savage_orcs",
    "wh_main_grn_cav_savage_orc_boar_boyz",
    "wh_main_grn_cav_savage_orc_boar_boyz",
    "wh_main_grn_inf_savage_orc_arrer_boyz",
    "wh_main_grn_inf_savage_orc_arrer_boyz"
    },
    crooked_moon = {
    "wh_main_grn_inf_goblin_spearmen",
    "wh_main_grn_inf_goblin_spearmen",
    "wh_main_grn_inf_goblin_spearmen",
    "wh_main_grn_inf_goblin_spearmen",
    "wh_main_grn_inf_goblin_spearmen",
    "wh_main_grn_inf_goblin_archers",
    "wh_main_grn_inf_goblin_archers",
    "wh_main_grn_inf_goblin_archers",
    "wh_dlc06_grn_inf_nasty_skulkers_0",
    "wh_dlc06_grn_inf_nasty_skulkers_0",
    "wh_dlc06_grn_inf_squig_herd_0",
    "wh_dlc06_grn_inf_squig_herd_0",
    "wh_main_grn_cav_goblin_wolf_riders_0",
    "wh_main_grn_cav_goblin_wolf_riders_0",
    "wh_main_grn_cav_goblin_wolf_riders_1",
    "wh_main_grn_cav_goblin_wolf_riders_1",
    "wh_main_grn_art_goblin_rock_lobber"
    }
}--:{regular: vector<string>, savage_orcs: vector<string>, crooked_moon: vector<string>}
SFO_CONST_WAAGH_SIZE_BASE = 19 --:number
SFO_CONST_WAAGH_SIZE_VARIANCE = 0 --:number
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
    local x, y = cm:find_valid_spawn_location_for_character_from_settlement(faction:name(), home_region:name(), false, false)
    cm:create_force(
        faction:name(),
        unit_list,
        home_region:name(),
        x,
        y,
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