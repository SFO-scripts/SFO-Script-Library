local gqm = _G.gqm
    
    
    
    
    
--when the player skills a new skill, if that skill has a quest, close their panel and issue the dilemma!
core:add_listener(
    "QuestsCharacterSkillPointAllocated",
    "CharacterSkillPointAllocated",
    function(context)
        return gqm:skill_has_quest(context:skill_point_spent_on()) and context:character():faction():is_human()
    end,
    function(context)
        gqm:offer_dilemma_for_skill(context:skill_point_spent_on(), context:character():faction():name(), context:character())
    end,
    true
)


local quests = {
    {
        _dilemma = "brt_quest_questing",
        _skill = "wh_dlc07_skill_brt_questing_vow",
        --_trait = "",
        _mission = "brt_questing_", 
        _targets = {"wh_main_grn_greenskins_qb1", "wh_dlc03_bst_beastmen_qb1", "wh_main_nor_norsca_qb1"}, 
        _armies = {
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
            ["wh_main_nor_norsca_qb1"] = {
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
        _size = 16
    },
    {
        _dilemma = "brt_quest_grail",
        _skill = "FIND GRAIL SKILL",
        --_trait = "",
        _mission = "brt_grail_", 
        _targets = {"wh_main_vmp_vampire_counts_qb1", "wh_main_chs_chaos_qb1", "wh2_main_def_dark_elves_qb1"}, 
        _armies = {
            ["wh_main_vmp_vampire_counts_qb1"] = {
                
                },
            ["wh_main_chs_chaos_qb1"] = {
                
                },
            ["wh2_main_def_dark_elves_qb1"] = {
                }
        }, 
        _size = 19
    }



}--:vector<QUEST_TEMPLATE>

for i = 1, #quests do
    gqm:new_quest(quests[i])
end


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
)