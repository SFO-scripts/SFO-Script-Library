--# assume global class SPAWN_FINDER







--# assume global class MCM
--# assume global class MCM_MOD
--# assume global class MCM_VAR
--# assume global class MCM_TWEAKER
--# assume global class MCM_OPTION

--MOD CONFIGURATION MANAGER
--# assume MCM.register_mod: method(key: string, ui_name: string, ui_tooltip: string) --> MCM_MOD
--# assume MCM.get_mod: method(key: string) --> MCM_MOD
--# assume MCM.started_with_mod: method(key: string) --> boolean
    --// an important check to include. Returns true if both your mod and MCM were active at the start of the save file. 
    --// returns false otherwise.
--# assume MCM.has_mod: method(key: string) --> boolean
--# assume MCM.add_pre_process_callback: method(callback: function())
    --// happens before any MCM value callbacks. Happens regardless of whether the game is new or loaded. 
--# assume MCM.add_post_process_callback: method(callback: function())
    --// happens after any MCM value callbacks. Happens regardless of whether the game is new or loaded. 
    --// This is the recommended method for using your settings.
--# assume MCM.add_new_game_only_callback: method(callback: function())
    --// happens after any MCM value callbacks only in new saves.
    --// this is the recommended method for using settings only applicable to game start. 

--MOD OBJECT
--# assume MCM_MOD.name: method() --> string
--# assume MCM_MOD.add_tweaker: method(key: string, ui_name: string, tooltip: string) --> MCM_TWEAKER
    --// All tweakers set a save value "mcm_tweaker_<mod_key>_<tweaker_key>_value" 
    --// This value equals the option key of the selected option
    --// Tweakers additionally trigger an event called "mcm_tweaker_<mod_key>_<tweaker_key>_event".
    --// The value is easily accessible within this event through context.string
--# assume MCM_MOD.add_variable: method(key: string,
--# minimum: number, maximum: number, default: number, step_value: number,
--# ui_name: string, ui_tooltip: string) --> MCM_VAR
    --// All variables set a save value "mcm_variable_<mod_key>_<variable_key>_value" 
    --// This value equals the option key of the selected option
    --// variables additionally trigger an event called "mcm_variable_<mod_key>_<variable_key>_event".
    --// The value is easily accessible within this event through tonumber(context.string)
--# assume MCM_MOD.get_variable_with_key: method(key: string) --> MCM_VAR
--# assume MCM_MOD.get_tweaker_with_key: method(key: string) --> MCM_TWEAKER
--# assume MCM_MOD.model: method() --> MCM

--TWEAKER OBJECT
--# assume MCM_TWEAKER.name: method() -->string
--# assume MCM_TWEAKER.selected_option: method() --> MCM_OPTION
--# assume MCM_TWEAKER.get_option_with_key: method(key: string) --> MCM_OPTION
--# assume MCM_TWEAKER.add_option: method(key: string, ui_name: string, ui_tooltip: string) --> MCM_OPTION
    --// the first option added to any tweaker is the default value.

--OPTION OBJECT
--# assume MCM_OPTION.name: method() -->string
--# assume MCM_OPTION.has_callback: method() --> boolean
--# assume MCM_OPTION.add_callback: method(callback: function(context: MCM)) 
    --// The added callback will happen both in new and saved games.
    --// The callback will occur when the MCM panel closes.
    --// These callbacks are best used to load values into another defined data structure or object; 
    --// general purpose uses are better off using the methods of MCM for callbacks.

--VAR OBJECT
--# assume MCM_VAR.name: method() --> string
--# assume MCM_VAR.current_value: method() --> number
--# assume MCM_VAR.has_callback: method() --> boolean
--# assume MCM_VAR.add_callback: method(callback: function(context: MCM)) 
    --// The added callback will happen both in new and saved games.
    --// The callback will occur when the MCM panel closes.
    --// These callbacks are best used to load values into another defined data structure or object; 
    --// general purpose uses are better off using the methods of MCM for callbacks.

--GLOBAL ACCESS
--# assume mcm:MCM
_G.mcm = mcm

