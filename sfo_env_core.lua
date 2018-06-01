_G.main_env = getfenv(1) 




-- debugging 
isDebugSession = true --: boolean
isLogAllowed = true --:boolean





--v function()
function SFOLOGRESET()
    if not isLogAllowed then
        return;
    end
    
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string
    
    local popLog = io.open("sfo_log.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close()
end

--v function(text: string, ftext: string)
function SFOLOG(text, ftext)

    if not isLogAllowed then
      return;
    end

  local logText = tostring(text)
  local logContext = tostring(ftext)
  local logTimeStamp = os.date("%d, %m %Y %X")
  local popLog = io.open("sfo_log.txt","a")
  --# assume logTimeStamp: string
  popLog :write("SFO:  "..logText .. "    : [" .. logContext .. "] : [".. logTimeStamp .. "]\n")
  popLog :flush()
  popLog :close()
end
_G.SFOLOG = SFOLOG

sfo_manager = require("sfo")
sfo = sfo_manager.new()
_G.sfo = sfo


SFOLOGRESET()

out("SFO: LOG SET TO"..tostring(isLogAllowed))
if isDebugSession then
  SFOLOG("DEBUG ACTIVE", "file.sfo_env_core")
end


--[[ 
  refreshes the log file at the start of each session
]]





--[[

currently unused.

--required library
require("df_lib_resources")
]]

--[[
  launches functions.

]]

core:add_listener(
  "SFO_CORE_START",
  "AllCaCallbacksFinished",
  true,
  function(context)
    sfo:green_knight_experience()
    sfo:lord_of_change_recruitment()
  end,
  true);








if isDebugSession then
  cm:add_game_created_callback(
    function()
      cm:faction_set_food_factor_value("wh_main_brt_bretonnia", "wh_dlc07_chivalry_war", 1000)

    end
  )

end