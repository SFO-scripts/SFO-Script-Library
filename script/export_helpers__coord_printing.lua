--v function(text: string)
function WRITE(text)
    local logText = tostring(text)
    local popLog = io.open("coordinates.txt","a")
    popLog :write(logText)
    popLog :flush()
    popLog :close()
end


core:add_listener(
    "WritingDownShit",
    "ShortcutTriggered",
    function(context) return context.string == "camera_bookmark_view0"; end, --default F9
    function(context)
        if not cm:get_saved_value("wars_declared_testing") then
            for i = 0, cm:model():world():faction_list():num_items() - 1 do
                if not cm:model():world():faction_list():item_at(i):is_dead() or cm:model():world():faction_list():item_at(i):name() == "wh_main_chs_chaos" then
                    cm:force_declare_war(cm:model():world():faction_list():item_at(i):name(), "wh_main_chs_chaos", false, false)
                    cm:set_saved_value("wars_declared_testing", true)
                end
            end
        end

        local character = cm:get_faction("wh_main_chs_chaos"):faction_leader()
        WRITE("[\""..character:region():name().." \"] = {"..character:logical_position_x()..","..character:logical_position_y().."}, \n")
    end,
    true
)