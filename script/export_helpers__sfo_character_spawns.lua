


local function spawn_characters()

    cm:create_agent(
        "wh_main_dwf_karak_kadrin",
        "champion",
        "dwf_cha_slayer",
        100,
        100,
        true
    )


end











events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() 
    if cm:is_new_game() then
        spawn_characters()
    end
end;