cm = get_cm(); sfo = _G.sfo; rm = _G.rm;

local units = {
{"wh_main_emp_inf_greatswords", "emp_special"},
{"wh_main_emp_cav_reiksguard", "emp_special"},
{"wh_dlc04_emp_cav_knights_blazing_sun_0", "emp_special"},
{"emp_knights_panther", "emp_special"},
{"emp_wolf_knight", "emp_special"},
{"emp_sigmar_war", "emp_special"},
{"emp_wolf_guard", "emp_elite"},
{"emp_witch_squad", "emp_elite"},
{"emp_nuln_ironsides", "emp_elite"},

{"wh_main_emp_cav_demigryph_knights_0", "emp_elite"},
{"wh_main_emp_cav_demigryph_knights_1", "emp_elite"},
{"wh_main_emp_veh_luminark_of_hysh_0", "emp_rare"},
{"wh_main_emp_veh_steam_tank_driver", "emp_rare"},
{"wh_main_vmp_inf_grave_guard_0", "vmp_special"},
{"wh_main_vmp_inf_grave_guard_1", "vmp_special"},
{"wh_main_vmp_inf_cairn_wraiths", "vmp_special"},
{"wh_main_vmp_mon_crypt_horrors", "vmp_special"},
{"wh_main_vmp_mon_terrorgheist", "vmp_elite"},
{"wh_main_vmp_mon_vargheists", "vmp_elite"},
{"wh_main_vmp_mon_varghulf", "vmp_elite"},
{"wh_main_vmp_veh_black_coach", "vmp_elite"},
{"wh_main_vmp_cav_hexwraiths", "vmp_elite"},
{"wh_dlc02_vmp_cav_blood_knights_0", "vmp_rare"},
{"vmp_blood_dragon", "vmp_rare"},
{"vmp_zombie_dragon", "vmp_rare"},
{"wh_dlc04_vmp_veh_mortis_engine_0", "vmp_rare"},

{"wh_main_grn_cav_orc_boar_boy_big_uns", "grn_special"},
{"wh_main_grn_cav_savage_orc_boar_boy_big_uns", "grn_special"},
{"wh_main_grn_inf_orc_big_uns", "grn_special"},
{"wh_main_grn_inf_savage_orc_big_uns", "grn_special"},
{"wh_main_grn_mon_trolls", "grn_special"},
{"wh_main_grn_mon_giant", "grn_elite"},
{"wh_main_grn_inf_black_orcs", "grn_elite"},
{"grn_black_orc_shields", "grn_elite"},
{"grn_savage_big_great", "grn_elite"},
{"wh_main_grn_mon_arachnarok_spider_0", "grn_rare"},

{"wh_dlc06_dwf_inf_bugmans_rangers_0", "dwf_special"},
{"wh_main_dwf_inf_longbeards", "dwf_special"},
{"wh_main_dwf_inf_longbeards_1", "dwf_special"},
{"wh_main_dwf_inf_slayers", "dwf_special"},
{"wh_main_dwf_inf_hammerers", "dwf_elite"},
{"wh_main_dwf_inf_ironbreakers", "dwf_elite"},
{"wh_main_dwf_inf_irondrakes_0", "dwf_elite"},
{"wh_main_dwf_inf_irondrakes_2", "dwf_elite"},
{"dwf_sniper", "dwf_elite"},
{"wh2_dlc10_dwf_inf_giant_slayers", "dwf_rare"},

{"wh_dlc05_wef_inf_deepwood_scouts_0", "wef_special"},
{"wh_dlc05_wef_inf_deepwood_scouts_1", "wef_special"},
{"wh_dlc05_wef_inf_wardancers_0", "wef_special"},
{"wh_dlc05_wef_inf_wardancers_1", "wef_special"},
{"wh_dlc05_wef_inf_wildwood_rangers_0", "wef_special"},
{"wh_dlc05_wef_cav_hawk_riders_0", "wef_special"},
{"wh_dlc05_wef_cav_sisters_thorn_0", "wef_special"},
{"wh_dlc05_wef_mon_great_eagle_0", "wef_special"},
{"wh_dlc05_wef_cav_wild_riders_0", "wef_elite"},
{"wh_dlc05_wef_cav_wild_riders_1", "wef_elite"},
{"wh_dlc05_wef_inf_waywatchers_0", "wef_elite"},
{"wh_dlc05_wef_mon_treekin_0", "wef_elite"},
{"wef_eternal_sword", "wef_elite"},
{"wef_wildwood_warden", "wef_elite"},
{"wh_dlc05_wef_forest_dragon_0", "wef_rare"},
{"wh_dlc05_wef_mon_treeman_0", "wef_rare"},

{"wh_dlc01_chs_inf_chaos_warriors_2", "chs_special"},
{"wh_dlc01_chs_inf_forsaken_0", "chs_special"},
{"wh_main_chs_inf_chaos_warriors_0", "chs_special"},
{"wh_main_chs_inf_chaos_warriors_1", "chs_special"},
{"wh_main_chs_mon_trolls", "chs_special"},
{"wh_dlc01_chs_inf_chosen_2", "chs_elite"},
{"wh_dlc01_chs_mon_dragon_ogre", "chs_elite"},
{"wh_dlc01_chs_mon_trolls_1", "chs_elite"},
{"wh_main_chs_inf_chosen_0", "chs_elite"},
{"wh_main_chs_inf_chosen_1", "chs_elite"},
{"wh_main_chs_mon_giant", "chs_elite"},
{"chs_khorne_berserk", "chs_elite"},
{"chs_nurgle_sons", "chs_elite"},
{"chs_slaanesh_bless", "chs_elite"},
{"chs_zelot", "chs_elite"},
{"wh_main_chs_cav_chaos_knights_0", "chs_elite"},
{"wh_main_chs_cav_chaos_knights_1", "chs_elite"},
{"chs_chaos_dragon", "chs_rare"},
{"wh_dlc01_chs_mon_dragon_ogre_shaggoth", "chs_rare"},

{"wh_dlc07_brt_cav_questing_knights_0", "brt_special"},
{"wh_main_brt_cav_knights_of_the_realm", "brt_special"},
{"wh_main_brt_cav_pegasus_knights", "brt_special"},
{"wh_dlc07_brt_cav_royal_pegasus_knights_0", "brt_elite"},
{"wh_dlc07_brt_inf_grail_reliquae_0", "brt_elite"},
{"wh_main_brt_cav_grail_knights", "brt_elite"},
{"wh_dlc07_brt_cav_grail_guardians_0", "brt_rare"},
{"wh_dlc07_brt_cav_royal_hippogryph_knights_0", "brt_rare"},

{"wh_dlc08_nor_feral_manticore", "nor_special"},
{"wh_dlc08_nor_mon_fimir_0", "nor_special"},
{"wh_dlc08_nor_mon_fimir_1", "nor_special"},
{"wh_dlc08_nor_mon_skinwolves_0", "nor_special"},
{"wh_dlc08_nor_mon_skinwolves_1", "nor_special"},
{"wh_main_nor_mon_chaos_trolls", "nor_special"},
{"wh_dlc08_nor_inf_marauder_champions_0", "nor_special"},
{"wh_dlc08_nor_inf_marauder_champions_1", "nor_special"},
{"wh_dlc08_nor_mon_norscan_giant_0", "nor_elite"},
{"wh_dlc08_nor_mon_norscan_ice_trolls_0", "nor_elite"},
{"wh_dlc08_nor_mon_war_mammoth_0", "nor_elite"},
{"wh_dlc08_nor_mon_war_mammoth_1", "nor_elite"},
{"wh_dlc08_nor_mon_frost_wyrm_0", "nor_rare"},
{"wh_dlc08_nor_mon_war_mammoth_2", "nor_rare"},

{"wh_dlc03_bst_feral_manticore", "bst_special"},
{"wh_dlc03_bst_inf_bestigor_herd_0", "bst_special"},
{"wh_dlc03_bst_inf_razorgor_herd_0", "bst_special"},
{"wh_dlc03_bst_inf_centigors_2", "bst_special"},
{"wh_dlc03_bst_inf_minotaurs_0", "bst_elite"},
{"wh_dlc03_bst_inf_minotaurs_1", "bst_elite"},
{"wh_dlc03_bst_inf_minotaurs_2", "bst_elite"},
{"bst_Khorngor", "bst_elite"},
{"bst_Pestigor", "bst_elite"},
{"bst_Slaangor", "bst_elite"},
{"bst_Tzaangor", "bst_elite"},
{"wh_dlc03_bst_mon_giant_0", "bst_rare"},
{"wh_dlc03_bst_inf_cygor_0", "bst_rare"},

{"wh2_dlc10_def_inf_sisters_of_slaughter", "def_special"},
{"wh2_dlc10_def_mon_feral_manticore_0", "def_special"},
{"wh2_main_def_cav_cold_one_knights_0", "def_special"},
{"wh2_main_def_inf_witch_elves_0", "def_special"},
{"wh2_main_def_cav_cold_one_knights_1", "def_elite"},
{"wh2_main_def_inf_black_guard_0", "def_elite"},
{"wh2_main_def_inf_har_ganeth_executioners_0", "def_elite"},
{"wh2_dlc10_def_mon_kharibdyss_0", "def_rare"},
{"wh2_main_def_mon_black_dragon", "def_rare"},
{"wh2_main_def_mon_war_hydra", "def_rare"},

{"wh2_main_hef_cav_silver_helms_0", "hef_special"},
{"wh2_main_hef_cav_silver_helms_1", "hef_special"},
{"wh2_main_hef_inf_gate_guard", "hef_special"},
{"wh2_main_hef_inf_white_lions_of_chrace_0", "hef_special"},
{"wh2_dlc10_hef_inf_shadow_walkers_0", "hef_special"},
{"wh2_dlc10_hef_inf_shadow_warriors_0", "hef_special"},
{"wh2_main_hef_mon_phoenix_flamespyre", "hef_elite"},
{"wh2_main_hef_mon_phoenix_frostheart", "hef_elite"},
{"wh2_dlc10_hef_inf_sisters_of_avelorn_0", "hef_elite"},
{"wh2_dlc10_hef_mon_treekin_0", "hef_elite"},
{"wh2_main_hef_inf_phoenix_guard", "hef_elite"},
{"wh2_main_hef_inf_swordmasters_of_hoeth_0", "hef_elite"},
{"wh2_dlc10_hef_mon_treeman_0", "hef_rare"},
{"wh2_main_hef_cav_dragon_princes", "hef_rare"},
{"wh2_main_hef_mon_moon_dragon", "hef_rare"},
{"wh2_main_hef_mon_star_dragon", "hef_rare"},
{"wh2_main_hef_mon_sun_dragon", "hef_rare"},

{"wh2_main_skv_inf_stormvermin_0", "skv_special"},
{"wh2_main_skv_inf_stormvermin_1", "skv_special"},
{"wh2_main_skv_mon_rat_ogres", "skv_special"},
{"wh2_main_skv_inf_plague_monk_censer_bearer", "skv_special"},
{"wh2_main_skv_inf_death_globe_bombardiers", "skv_elite"},
{"wh2_main_skv_inf_poison_wind_globadiers", "skv_elite"},
{"wh2_main_skv_inf_warpfire_thrower", "skv_elite"},
{"skv_technox", "skv_elite"},
{"wh2_main_skv_mon_hell_pit_abomination", "skv_rare"},
{"wh2_main_skv_veh_doomwheel", "skv_rare"},
{"wh2_main_lzd_inf_saurus_spearmen_0", "lzd_special"},
{"wh2_main_lzd_inf_saurus_spearmen_1", "lzd_special"},
{"wh2_main_lzd_inf_saurus_spearmen_blessed_1", "lzd_special"},
{"wh2_main_lzd_inf_saurus_warriors_0", "lzd_special"},
{"wh2_main_lzd_inf_saurus_warriors_1", "lzd_special"},
{"wh2_main_lzd_inf_saurus_warriors_blessed_1", "lzd_special"},

{"wh2_main_lzd_cav_horned_ones_0", "lzd_elite"},
{"wh2_main_lzd_cav_horned_ones_blessed_0", "lzd_elite"},
{"wh2_main_lzd_inf_temple_guards", "lzd_elite"},
{"wh2_main_lzd_inf_temple_guards_blessed", "lzd_elite"},
{"wh2_main_lzd_mon_kroxigors", "lzd_elite"},
{"wh2_main_lzd_mon_kroxigors_blessed", "lzd_elite"},
{"wh2_main_lzd_mon_bastiladon_1", "lzd_elite"},
{"wh2_main_lzd_mon_bastiladon_2", "lzd_elite"},
{"wh2_main_lzd_mon_bastiladon_blessed_2", "lzd_elite"},
{"wh2_main_lzd_mon_stegadon_0", "lzd_elite"},
{"wh2_main_lzd_mon_carnosaur_0", "lzd_rare"},
{"wh2_main_lzd_mon_carnosaur_blessed_0", "lzd_rare"},
{"wh2_main_lzd_mon_stegadon_1", "lzd_rare"},
{"wh2_main_lzd_mon_stegadon_blessed_1", "lzd_rare"},

{"wh2_dlc09_tmb_inf_tomb_guard_0", "tmb_special"},
{"wh2_dlc09_tmb_inf_tomb_guard_1", "tmb_special"},
{"wh2_dlc09_tmb_mon_sepulchral_stalkers_0", "tmb_special"},
{"wh2_dlc09_tmb_cav_hexwraiths", "tmb_elite"},
{"wh2_dlc09_tmb_cav_necropolis_knights_0", "tmb_elite"},
{"wh2_dlc09_tmb_cav_necropolis_knights_1", "tmb_elite"},
{"wh2_dlc09_tmb_mon_tomb_scorpion_0", "tmb_elite"},
{"wh2_pro06_tmb_mon_bone_giant_0", "tmb_elite"},
{"wh2_dlc09_tmb_mon_ushabti_0", "tmb_elite"},
{"wh2_dlc09_tmb_mon_ushabti_1", "tmb_elite"},
{"wh2_dlc09_tmb_mon_heirotitan_0", "tmb_rare"},
{"wh2_dlc09_tmb_mon_necrosphinx_0", "tmb_rare"},
{"wh2_dlc09_tmb_veh_khemrian_warsphinx_0", "tmb_rare"}
} --:vector<{string, string}>

local groups = {} --:map<string, boolean>
local prefix_to_subculture = {
    bst = "wh_dlc03_sc_bst_beastmen",
    wef = "wh_dlc05_sc_wef_wood_elves",
    brt = "wh_main_sc_brt_bretonnia",
    chs = "wh_main_sc_chs_chaos",
    dwf = "wh_main_sc_dwf_dwarfs",
    emp = "wh_main_sc_emp_empire",
    grn = "wh_main_sc_grn_greenskins",
    ksl = "wh_main_sc_ksl_kislev",
    nor = "wh_main_sc_nor_norsca",
    teb = "wh_main_sc_teb_teb",
    vmp = "wh_main_sc_vmp_vampire_counts",
    tmb = "wh2_dlc09_sc_tmb_tomb_kings",
    def = "wh2_main_sc_def_dark_elves",
    hef = "wh2_main_sc_hef_high_elves",
    lzd = "wh2_main_sc_lzd_lizardmen",
    skv = "wh2_main_sc_skv_skaven"
}--:map<string, string>


--v function()
local function sfo_add_unit_caps()
    for i = 1, #units do
        groups[units[i][2]] = true;
        rm:add_unit_to_group(units[i][1], units[i][2])

        if string.find(units[i][2], "_special") then
            local prefix = string.gsub(units[i][2], "_special", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This is a Special Unit. \n Armies may have up to 6 Special Units.",
                _image = "ui/custom/recruitment_controls/special.png"
            })
        end
        if string.find(units[i][2], "_elite") then
            local prefix = string.gsub(units[i][2], "_elite", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This is an Elite Unit. \n Armies may have up to 4 Elite Units",
                _image = "ui/custom/recruitment_controls/elite.png"
            })
        end
        if string.find(units[i][2], "_rare") then
            local prefix = string.gsub(units[i][2], "_rare", "")
            rm:whitelist_unit_for_subculture(units[i][1], prefix_to_subculture[prefix])
            rm:set_ui_profile_for_unit(units[i][1], {
                _text = "This is a Rare Unit. \n Armies may have up to 2 Rare Units.",
                _image = "ui/custom/recruitment_controls/rare.png"
            })
        end
    end


end
--v function()
function sfo_apply_cap_bundle()
    local SFO_UNIT_CAPS_EFFECT_BUNDLE = "cap_factionwide"


    local faction_list = cm:model():world():faction_list()
    for i = 0, faction_list:num_items() - 1 do
        if not faction_list:item_at(i):is_dead() then
            cm:apply_effect_bundle(SFO_UNIT_CAPS_EFFECT_BUNDLE, faction_list:item_at(i):name(), 0)
        end
    end


end



core:add_listener(
    "SFOcapsDilemma",
    "DilemmaChoiceMadeEvent",
    function(context)
        return context:dilemma() == "cap_army_choice"
    end,
    function(context)
        if context:choice() == 1 or context:choice() == 2 then
            sfo_add_unit_caps()
            cm:set_saved_value("SFO_APPLY_CAPS", true)
            cm:callback(function()
                for name, _ in pairs(groups) do
                    if string.find(name, "special") then
                        rm:set_ui_name_for_group(name, "Special Units")
                        rm:add_character_quantity_limit_for_group(name, 6)
                    end
                    if string.find(name, "elite") then
                        rm:set_ui_name_for_group(name, "Elite Units")
                        rm:add_character_quantity_limit_for_group(name, 4)
                    end
                    if string.find(name, "rare") then
                        rm:set_ui_name_for_group(name, "Rare Units")
                        rm:add_character_quantity_limit_for_group(name, 2)
                    end
                end
            end, 5)
        end
        if context:choice() == 2 or context:choice() == 3 then
            sfo_apply_cap_bundle()
        end
    end,
    false)


if cm:get_saved_value("SFO_APPLY_CAPS") then
    sfo_add_unit_caps()
    cm.first_tick_callbacks[#cm.first_tick_callbacks+1] = function(context) 
        for name, _ in pairs(groups) do
            if string.find(name, "special") then
                rm:set_ui_name_for_group(name, "Special Units")
                rm:add_character_quantity_limit_for_group(name, 6)
            end
            if string.find(name, "elite") then
                rm:set_ui_name_for_group(name, "Elite Units")
                rm:add_character_quantity_limit_for_group(name, 4)
            end
            if string.find(name, "rare") then
                rm:set_ui_name_for_group(name, "Rare Units")
                rm:add_character_quantity_limit_for_group(name, 2)
            end
        end
    end
end
    
    