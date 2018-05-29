_G.main_env = getfenv(1) 



isLogAllowed = true --:boolean
output("LOG SET TO"..tostring(isLogAllowed))
isDebugSession = true --: boolean


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

--required library
require("df_lib_resources")
require("sfo")




core:add_listener(
  "SFO_REFRESH_LOG",
  "UICreated",
  true,
  function(context)
    SFOLOGRESET()
    if isDebugSession then
      SFOLOG("DEBUG ACTIVE", "file.sfo_env_core")
    end
  end,
  true);

if isDebugSession then
  cm:add_game_created_callback(
    function()


    end
  )

end