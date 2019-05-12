cm.first_tick_callbacks[#cm.first_tick_callbacks+1] =
	function()

		local add_money = true					-- change to true to add extra money to factions specified below
		local disable_shroud = false			--change to true to remove shroud

		if cm:is_new_game() and add_money then	-- only triggers once at game start
			if cm:model():campaign_name("main_warhammer") then  -- ME campaign only

				cm:treasury_mod("wh2_main_lzd_last_defenders", 10000)
				cm:treasury_mod("wh_dlc08_nor_wintertooth", 2500)
				cm:treasury_mod("wh2_main_skv_clan_mors", 2500)
				cm:treasury_mod("wh_main_vmp_schwartzhafen", 2500)
				cm:treasury_mod("wh_main_grn_crooked_moon", 5000)
				cm:treasury_mod("wh_main_brt_bordeleaux", 5000)
				cm:treasury_mod("wh_main_brt_bretonnia", 5000)
				cm:treasury_mod("wh_main_brt_carcassonne", 5000)
				cm:treasury_mod("wh_main_chs_chaos", 5000)

			else 												-- Vortex campaign only

				cm:treasury_mod("wh_main_ksl_kislev", 0)
				cm:treasury_mod("wh_main_ksl_kislev", 0)
				cm:treasury_mod("wh_main_ksl_kislev", 0)
				cm:treasury_mod("wh_main_ksl_kislev", 0)

			end
		end

		if disable_shroud then
			core:add_listener(
				"no_shroud",
				"FactionTurnStart",
			function(context) return context:faction():is_human() end,
			function()
				cm:show_shroud(false)
			end,
			true
			)
		end

	end

core:add_listener(
    "AIBundle_PO",
    "FactionTurnStart",
    function(context)
        return (not context:faction():is_human()) and (cm:model():turn_number() == 5) --conditions
    end,
    function(context)
        --replace duration with a number
        if not context:faction():has_effect_bundle("wh_public_order_event_bundle") then
            cm:apply_effect_bundle("wh_public_order_event_bundle", context:faction():name(), 10)
        end
    end,
    true)

core:add_listener(
    "AIBundle_0",
    "FactionTurnStart",
    function(context)
        return (not context:faction():is_human()) and (cm:model():turn_number() == 50) --conditions
    end,
    function(context)
        --replace duration with a number
        if not context:faction():has_effect_bundle("sfo_ai_buff_0") then
            cm:apply_effect_bundle("sfo_ai_buff_0", context:faction():name(), 0)
        end
    end,
    true)

core:add_listener(
    "AIBundle_1",
    "FactionTurnStart",
    function(context)
        return (not context:faction():is_human()) and (cm:model():turn_number() == 100) --conditions
    end,
    function(context)
        --replace duration with a number
        if not context:faction():has_effect_bundle("sfo_ai_buff_1") then
            cm:apply_effect_bundle("sfo_ai_buff_1", context:faction():name(), 0)
        end
    end,
    true)

core:add_listener(
    "AIBundle_2",
    "FactionTurnStart",
    function(context)
        return (not context:faction():is_human()) and (cm:model():turn_number() == 150) --conditions
    end,
    function(context)
        --replace duration with a number
        if not context:faction():has_effect_bundle("sfo_ai_buff_2") then
            cm:apply_effect_bundle("sfo_ai_buff_2", context:faction():name(), 0)
        end
    end,
    true)

core:add_listener(
    "AIBundle_3",
    "FactionTurnStart",
    function(context)
        return (not context:faction():is_human()) and (cm:model():turn_number() == 200) --conditions
    end,
    function(context)
        --replace duration with a number
        if not context:faction():has_effect_bundle("sfo_ai_buff_3") then
            cm:apply_effect_bundle("sfo_ai_buff_3", context:faction():name(), 0)
        end
    end,
    true)