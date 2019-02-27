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
        _targets = {"wh_main_grn_greenskins_qb1"}, 
        _armies = {
            ["wh_main_grn_greenskins_qb1"] = {
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
                }
        }, 
        _size = 14
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