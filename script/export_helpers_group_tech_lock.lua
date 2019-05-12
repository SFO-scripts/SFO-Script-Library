local lockedTechs = {} --: map<string, vector<string>>

--v function(factionName: string, techName: string) --> boolean
function factionHasTech(factionName, techName)
    local resolvedFaction = cm:get_faction(factionName);
    return resolvedFaction:has_technology(techName)
end

--v function(factionName: string, techs: vector<string>) --> boolean
function factionHasAnyTech(factionName, techs)
    for i, tech in ipairs(techs) do
        if factionHasTech(factionName, tech) then
            return true;
        end
    end
    return false;
end

--v function(factionName: string, techs: vector<string>)
function lockTechs(factionName, techs)
    out("Locked techs for " .. factionName);
    cm:restrict_technologies_for_faction(factionName, techs, true);
    lockedTechs[factionName] = techs;
end

--v function(factionName: string, techs: vector<string>, callback: function())
function addListenerForTech(factionName, techs, callback)
    core:add_listener(
        "TechResearchedListener",
        "ResearchCompleted",
        function(context)
            return context:faction():name() == factionName and factionHasAnyTech(factionName, techs);
        end,
        function(context)
            callback();
        end, false
    );
end

--v function(factionName: string, techs: vector<string>)
function applyTechGroupLockForFaction(factionName, techs)
    if factionHasAnyTech(factionName, techs) then
        lockTechs(factionName, techs);
    else
        addListenerForTech(
            factionName, techs,
            function()
                lockTechs(factionName, techs);
            end
        )
    end
end

--v function(culture: string, techs: vector<string>)
function applyTechGroupLockForCulture(culture, techs)
    out("Apply tech lock for culture: " .. culture);
    local factionList = cm:model():world():faction_list();
    for i = 0, factionList:num_items() - 1 do
        local currentFaction = factionList:item_at(i);
        if currentFaction:culture() == culture then
            applyTechGroupLockForFaction(currentFaction:name(), techs);
        end
    end
end

core:add_listener(
    "TechGroupLocker",
    "PanelOpenedCampaign",
    function(context) 
        return context.string == "technology_panel" and not not lockedTechs[cm:get_local_faction(true)]; 
    end,
    function(context)
        local techList = find_uicomponent(core:get_ui_root(), "technology_panel", "listview", "list_clip", "list_box");
        for i, tech in ipairs(lockedTechs[cm:get_local_faction(true)]) do
            local techButton = find_uicomponent(core:get_ui_root(), tech);
            if techButton then
                if not factionHasTech(cm:get_local_faction(true), tech) then
                    techButton:SetDisabled(true);
                    techButton:SetOpacity(50);
                end
            else
                out("Failed to find button for tech: " .. tech);
            end
        end
    end, 
    true
);

-- Sample use
applyTechGroupLockForCulture(
    "wh_main_chs_chaos", {
        "chs_unlock", 
        "chs_unlock1"
    }
);

applyTechGroupLockForCulture(
    "wh_main_chs_chaos", {
        "chs_khorne", 
        "chs_nurgle", 
        "chs_tzeentch",
        "chs_slaanesh"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech1_1", 
        "dwf_tech1_2", 
        "dwf_tech1_3",
        "dwf_tech1_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech2_1", 
        "dwf_tech2_2", 
        "dwf_tech2_3",
        "dwf_tech2_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech3_1", 
        "dwf_tech3_2", 
        "dwf_tech3_3",
        "dwf_tech3_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech4_1", 
        "dwf_tech4_2", 
        "dwf_tech4_3",
        "dwf_tech4_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech5_1", 
        "dwf_tech5_2", 
        "dwf_tech5_3",
        "dwf_tech5_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech6_1", 
        "dwf_tech6_2", 
        "dwf_tech6_3",
        "dwf_tech6_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech7_1", 
        "dwf_tech7_2", 
        "dwf_tech7_3",
        "dwf_tech7_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech8_1", 
        "dwf_tech8_2", 
        "dwf_tech8_3",
        "dwf_tech8_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech9_1", 
        "dwf_tech9_2", 
        "dwf_tech9_3",
        "dwf_tech9_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech10_1", 
        "dwf_tech10_2", 
        "dwf_tech10_3",
        "dwf_tech10_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech11_1", 
        "dwf_tech11_2", 
        "dwf_tech11_3",
        "dwf_tech11_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_dwf_dwarfs", {
        "dwf_tech12_1", 
        "dwf_tech12_2", 
        "dwf_tech12_3",
        "dwf_tech12_4"
    }
);

applyTechGroupLockForCulture(
    "wh_main_brt_bretonnia", {
        "brt_tech_king5",
        "brt_tech_king6"
    }
);

applyTechGroupLockForCulture(
    "wh_main_brt_bretonnia", {
        "brt_tech_alberic5",
        "brt_tech_alberic6"
    }
);

applyTechGroupLockForCulture(
    "wh_main_brt_bretonnia", {
        "brt_tech_fay5",
        "brt_tech_fay6"
    }
);