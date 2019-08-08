local gqm = _G.gqm
    
    
--when the player skills a new skill, if that skill has a quest, close their panel and issue the dilemma!
core:add_listener(
    "QuestsCharacterSkillPointAllocated",
    "CharacterSkillPointAllocated",
    function(context)
        return gqm:skill_has_quest(context:skill_point_spent_on()) and context:character():faction():is_human()
    end,
    function(context)
        gqm:log("Character allocated skill on a quest skill! ["..context:skill_point_spent_on().."]")
        local character = context:character()
        if gqm._numActiveQuestsLocal[character:faction():name()] >= 3 then
            gqm:log("Too many quests currently active, aborting!")
            cm:remove_skill_point(cm:char_lookup_str(character:command_queue_index()), context:skill_point_spent_on())
            return
        end
        if context:skill_point_spent_on() == "brt_quest_errant_grand_1" and (not cm:get_saved_value("allow_grail_for_"..tostring(character:command_queue_index()))) then
            gqm:log("removing grail vow for a character who does not deserve it!")
            cm:remove_skill_point(cm:char_lookup_str(character:command_queue_index()), "brt_quest_errant_grand_1")
            return
        end
        gqm:offer_dilemma_for_skill(context:skill_point_spent_on(), context:character():faction():name(), context:character())
    end,
    true
)


local quests = {
    {
        _dilemma = "brt_quest_questing",
        _skill = "brt_quest_errant_small_1",
        --_trait = "",
        _mission = "brt_questing_", 
        _targets = {"wh_main_grn_greenskins_qb1", "wh_dlc03_bst_beastmen_qb1", "wh_main_nor_varg", "wh2_main_skv_skaven_qb1"}, 
        _armies = {
            ["wh2_main_skv_skaven_qb1"] = {
                "wh2_main_skv_inf_clanrats_0", 
                "wh2_main_skv_inf_clanrats_1", 
                "wh2_main_skv_inf_clanrats_1", 
                "wh2_main_skv_inf_clanrat_spearmen_0", 
                "wh2_main_skv_inf_clanrat_spearmen_1", 
                "wh2_main_skv_inf_clanrat_spearmen_1", 
                "wh2_main_skv_inf_plague_monks", 
                "wh2_main_skv_inf_plague_monks", 
                "wh2_main_skv_inf_poison_wind_globadiers", 
                "wh2_main_skv_inf_death_globe_bombardiers", 
                "wh2_main_skv_inf_stormvermin_0", 
                "wh2_main_skv_inf_stormvermin_1",
                "wh2_main_skv_mon_rat_ogres",
                "wh2_main_skv_art_plagueclaw_catapult"
                },
            ["wh_main_grn_greenskins_qb1"] = {
                "wh_main_grn_inf_orc_boyz", 
                "wh_main_grn_inf_orc_boyz", 
                "wh_main_grn_inf_orc_boyz", 
                "wh_dlc06_grn_inf_nasty_skulkers_0", 
                "wh_dlc06_grn_inf_nasty_skulkers_0", 
                "wh_dlc06_grn_inf_nasty_skulkers_0", 
                "wh_main_grn_cav_orc_boar_boyz", 
                "wh_main_grn_cav_forest_goblin_spider_riders_1", 
                "wh_main_grn_inf_orc_arrer_boyz", 
                "wh_main_grn_inf_night_goblin_fanatics_1", 
                "wh_main_grn_inf_night_goblin_fanatics",
                "wh_main_grn_inf_orc_big_uns",
                "wh_main_grn_art_goblin_rock_lobber"
                },
            ["wh_main_nor_varg"] = {
                "wh_main_nor_inf_chaos_marauders_0", 
                "wh_main_nor_inf_chaos_marauders_0", 
                "wh_main_nor_inf_chaos_marauders_1", 
                "wh_main_nor_inf_chaos_marauders_1", 
                "wh_dlc08_nor_inf_marauder_spearman_0", 
                "wh_dlc08_nor_inf_marauder_spearman_0", 
                "wh_dlc08_nor_inf_marauder_berserkers_0", 
                "wh_dlc08_nor_inf_marauder_berserkers_0", 
                "wh_dlc08_nor_inf_marauder_hunters_1", 
                "wh_dlc08_nor_inf_marauder_hunters_1", 
                "wh_main_nor_mon_chaos_trolls",
                "wh_dlc08_nor_mon_war_mammoth_0",
                "wh_dlc08_nor_cav_marauder_horsemasters_0"
                },
            ["wh_dlc03_bst_beastmen_qb1"] = {
                "wh_dlc03_bst_inf_ungor_herd_1", 
                "wh_dlc03_bst_inf_ungor_herd_1", 
                "wh_dlc03_bst_inf_ungor_spearmen_0", 
                "wh_dlc03_bst_inf_ungor_spearmen_0", 
                "wh_dlc03_bst_inf_ungor_spearmen_1", 
                "wh_dlc03_bst_inf_ungor_spearmen_1", 
                "wh_dlc03_bst_inf_ungor_raiders_0", 
                "wh_dlc03_bst_inf_ungor_raiders_0", 
                "wh_dlc03_bst_inf_chaos_warhounds_0", 
                "wh_dlc03_bst_inf_chaos_warhounds_0", 
                "wh_dlc03_bst_inf_gor_herd_0", 
                "wh_dlc03_bst_inf_gor_herd_0", 
                "wh_dlc03_bst_inf_centigors_0", 
                "wh_dlc03_bst_inf_centigors_0",
                "wh_dlc03_bst_inf_chaos_warhounds_1"
                }
        }, 
        _size = 16,
        _level = 7
    },
    {
        _dilemma = "brt_quest_grail",
        _skill = "brt_quest_errant_grand_1",
        --_trait = "",
        _mission = "brt_grail_", 
        _targets = {"wh_main_vmp_vampire_counts_qb1", "wh_main_chs_chaos_qb1", "wh2_main_def_dark_elves_qb1", "wh2_dlc09_tmb_tombking_qb2", "wh2_dlc11_cst_vampire_coast_qb1"}, 
        _armies = {
            ["wh2_dlc09_tmb_tombking_qb2"] = {
                "wh2_dlc09_tmb_inf_skeleton_warriors_0", 
                "wh2_dlc09_tmb_inf_skeleton_spearmen_0", 
                "wh2_dlc09_tmb_inf_tomb_guard_0", 
                "wh2_dlc09_tmb_inf_tomb_guard_1", 
                "wh2_dlc09_tmb_inf_skeleton_warriors_0", 
                "wh2_dlc09_tmb_inf_skeleton_spearmen_0", 
                "wh2_dlc09_tmb_inf_tomb_guard_0", 
                "wh2_dlc09_tmb_inf_tomb_guard_1", 
                "wh2_dlc09_tmb_mon_ushabti_1", 
                "wh2_dlc09_tmb_mon_ushabti_1", 
                "wh2_dlc09_tmb_mon_tomb_scorpion_0", 
                "wh2_dlc09_tmb_mon_sepulchral_stalkers_0", 
                "wh2_dlc09_tmb_mon_ushabti_0", 
                "wh2_dlc09_tmb_veh_skeleton_chariot_0",
                "wh2_dlc09_tmb_veh_skeleton_archer_chariot_0",
                "wh2_pro06_tmb_mon_bone_giant_0"
                },
            ["wh_main_vmp_vampire_counts_qb1"] = {
                "wh_main_vmp_inf_grave_guard_0", 
                "wh_main_vmp_inf_grave_guard_0", 
                "wh_main_vmp_inf_grave_guard_1", 
                "wh_main_vmp_inf_grave_guard_1", 
                "wh_main_vmp_inf_crypt_ghouls", 
                "wh_main_vmp_inf_crypt_ghouls", 
                "wh_main_vmp_mon_crypt_horrors", 
                "wh_main_vmp_mon_vargheists", 
                "wh_main_vmp_mon_varghulf", 
                "wh_main_vmp_inf_cairn_wraiths", 
                "wh_main_vmp_inf_cairn_wraiths", 
                "wh_main_vmp_cav_black_knights_3", 
                "wh_main_vmp_cav_black_knights_3",
                "wh_dlc04_vmp_veh_mortis_engine_0"
                },
            ["wh2_dlc11_cst_vampire_coast_qb1"] = {
                "wh2_dlc11_cst_inf_zombie_deckhands_mob_0", 
                "wh2_dlc11_cst_inf_zombie_deckhands_mob_0", 
                "wh2_dlc11_cst_inf_zombie_deckhands_mob_1", 
                "wh2_dlc11_cst_inf_zombie_deckhands_mob_1", 
                "wh2_dlc11_cst_inf_zombie_gunnery_mob_1", 
                "wh2_dlc11_cst_inf_zombie_gunnery_mob_1", 
                "wh2_dlc11_cst_inf_zombie_gunnery_mob_2", 
                "wh2_dlc11_cst_inf_zombie_gunnery_mob_2", 
                "wh2_dlc11_cst_cav_deck_droppers_1", 
                "wh2_dlc11_cst_inf_syreens", 
                "wh2_dlc11_cst_inf_depth_guard_1", 
                "wh2_dlc11_cst_mon_animated_hulks_0", 
                "wh2_dlc11_cst_mon_rotting_prometheans_0", 
                "wh2_dlc11_cst_mon_mournguls_0", 
                "wh2_dlc11_cst_art_carronade",
                "wh2_dlc11_cst_art_mortar"
                },
            ["wh_main_chs_chaos_qb1"] = {
                "wh_dlc01_chs_inf_chaos_warriors_2", 
                "wh_dlc01_chs_inf_chaos_warriors_2", 
                "wh_main_chs_inf_chaos_warriors_0", 
                "wh_main_chs_inf_chaos_warriors_0", 
                "wh_main_chs_inf_chaos_warriors_1", 
                "wh_main_chs_inf_chaos_warriors_1", 
                "wh_dlc01_chs_inf_forsaken_0", 
                "wh_dlc01_chs_inf_forsaken_0", 
                "wh_dlc01_chs_mon_trolls_1", 
                "wh_main_chs_mon_chaos_spawn", 
                "wh_main_chs_mon_chaos_warhounds_1", 
                "wh_main_chs_inf_chaos_marauders_1", 
                "wh_main_chs_inf_chaos_marauders_1", 
                "wh_main_chs_inf_chaos_marauders_0", 
                "wh_main_chs_inf_chaos_marauders_0", 
                "wh_main_chs_mon_giant"
                },
            ["wh2_main_def_dark_elves_qb1"] = {
                "wh2_main_def_inf_bleakswords_0", 
                "wh2_main_def_inf_bleakswords_0", 
                "wh2_main_def_inf_dreadspears_0", 
                "wh2_main_def_inf_dreadspears_0", 
                "wh2_main_def_inf_witch_elves_0", 
                "wh2_main_def_inf_witch_elves_0", 
                "wh2_main_def_inf_black_ark_corsairs_0", 
                "wh2_main_def_inf_black_ark_corsairs_0", 
                "wh2_main_def_inf_black_ark_corsairs_1", 
                "wh2_main_def_inf_black_ark_corsairs_1", 
                "wh2_main_def_inf_darkshards_1", 
                "wh2_main_def_inf_darkshards_1", 
                "wh2_main_def_inf_darkshards_0", 
                "wh2_main_def_inf_darkshards_0",
                "wh2_main_def_inf_har_ganeth_executioners_0",
                "wh2_main_def_inf_har_ganeth_executioners_0",
                "wh2_main_def_mon_war_hydra_0",
                "wh2_main_def_cav_dark_riders_1",
                "wh2_main_def_cav_dark_riders_0",
                "wh2_main_def_art_reaper_bolt_thrower"
                }
        }, 
        _size = 19,
        _level = 14
    }
}--:vector<QUEST_TEMPLATE>

for i = 1, #quests do
    gqm:new_quest(quests[i])
end
--[[

core:add_listener(
    "WritingDownShit",
    "ShortcutTriggered",
    function(context) return context.string == "camera_bookmark_view0"; end, --default F9
    function(context)
        local char_list = cm:get_faction(cm:get_local_faction(true)):character_list()
        for i = 0, char_list:num_items() - 1 do
            if cm:char_is_mobile_general_with_army(char_list:item_at(i)) then
                cm:add_agent_experience(cm:char_lookup_str(char_list:item_at(i):cqi()), 4000)
            end
        end
    end,
    true
)--]]