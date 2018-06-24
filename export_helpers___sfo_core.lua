events.FirstTickAfterWorldCreated[#events.FirstTickAfterWorldCreated+1] = function() fully_loaded_event() end;

function fully_loaded_event()
	cm:callback( function()
		if SFOLOG then 
			SFOLOG("triggering core event, all CA_scripts should have fired by now!", "file.export_helpers__sfo_core");
		end
		out("SFO: firing core event")

		core:trigger_event("AllCaCallbacksFinished")
	end, 0.5)
end;
