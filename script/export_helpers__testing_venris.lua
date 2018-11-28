cm.first_tick_callbacks[#cm.first_tick_callbacks+1] =
	function()

		local add_money = true					-- change to true to add extra money to factions specified below
		local disable_shroud = false			--change to true to remove shroud

		if cm:is_new_game() and add_money then	-- only triggers once at game start
			if cm:model():campaign_name("main_warhammer") then  -- ME campaign only

				cm:treasury_mod("wh_main_ksl_kislev", 15000)
				cm:treasury_mod("wh2_main_lzd_last_defenders", 10000)
				cm:treasury_mod("wh_dlc08_nor_wintertooth", 2500)
				cm:treasury_mod("wh2_main_skv_clan_mors", 2500)
				cm:treasury_mod("wh_main_vmp_schwartzhafen", 5000)
				cm:treasury_mod("wh2_main_lzd_hexoatl", 5000)
				cm:treasury_mod("wh_main_grn_crooked_moon", 5000)

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
