--SCRIPT LIBRARY
--Contains utility functions such as: logging, error checking, and version number
--It isn't very interesting
--Written by Drunk Flamingo
--Last updated 10/15/18

--# assume global class SFO_MANAGER
local sfo_util = {} --# assume sfo_util: SFO_MANAGER

--resets the log on session start.
local function SFOLOGRESET()
    if not __write_output_to_logfile then
        return;
    end 
    local logTimeStamp = os.date("%d, %m %Y %X")
    --# assume logTimeStamp: string
    
    local popLog = io.open("sfo_log.txt","w+")
    popLog :write("NEW LOG ["..logTimeStamp.."] \n")
    popLog :flush()
    popLog :close()
end

--log script to text
--v function(text: string, ftext: string?)
local function SFOLOG(text, ftext)
    if not __write_output_to_logfile then
        return; 
    end

    local logText = tostring(text)
    local logTimeStamp = os.date("%d, %m %Y %X")
    local popLog = io.open("sfo_log.txt","a")
    --# assume logTimeStamp: string
    popLog :write("SFO:  [".. logTimeStamp .. "]:  "..logText .. "  \n")
    popLog :flush()
    popLog :close()
end


--instantiate manager
--v function() --> SFO_MANAGER
function sfo_util.init()
    SFOLOGRESET()
    local self = {}
    setmetatable(self, {
        __index = sfo_util,
        __tostring = function() return "SFO_UTILITY" end
    }) --# assume self: SFO_MANAGER
    -- version warnings
    self._versionSV = "SFO_PUBLIC_VERSION"
    if not cm:get_saved_value(self._versionSV) then
        cm:set_saved_value(self._versionSV, "1.5")
    end
    self.versionNum = cm:get_saved_value(self._versionSV) --:string


    _G.sfo = self
    return self
end

--log script to text
--v function(self: SFO_MANAGER, text: any, ftext: any?)
function sfo_util.log(self, text, ftext)
    --ftext is no longer used, but is allowed as an unused arg for this function so I don't have to go back and edit logs
    SFOLOG(tostring(text))
end

--Error checker. Wraps all listeners and callbacks in a safecall.
--Here there be monsters! Kailua strongly dislikes the way this is done and *will* complain. NOCHECK. 
--v [NO_CHECK] function(self: SFO_MANAGER)
function sfo_util.enable_error_checker(self)   

    --safely calls a function
    --v function(func: function) --> any
    function safeCall(func)
        local status, result = pcall(func)
        if not status then
            SFOLOG("ERROR: ")
            SFOLOG(tostring(result))
            SFOLOG(debug.traceback());
        end
        return result;
    end
    
    --packs a function's args
    --v [NO_CHECK] function(...: any)
    function pack2(...) return {n=select('#', ...), ...} end
    --unpacks a function's args into a vector
    --v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
    function unpack2(t) return unpack(t, 1, t.n) end
    
    --wraps a function in SafeCall
    --v [NO_CHECK] function(f: function(), argProcessor: function()) --> function()
    function wrapFunction(f, argProcessor)
        return function(...)
            local someArguments = pack2(...);
            if argProcessor then
                safeCall(function() argProcessor(someArguments) end)
            end
            local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
            return unpack2(result);
            end
    end
    
    --used to log the calls of a function when debugging. Unused in live versions.
    --v [NO_CHECK] function(f: function(), name: string)
    function logFunctionCall(f, name)
        return function(...)
            output("function called: " .. name);
            return f(...);
        end
    end
    
    --logs the available methods of an object, then logs future calls to that object.
    --v [NO_CHECK] function(object: any)
    function logAllObjectCalls(object)
        local metatable = getmetatable(object);
        for name,f in pairs(getmetatable(object)) do
            if is_function(f) then
                output("Found " .. name);
                if name == "Id" or name == "Parent" or name == "Find" or name == "Position" or name == "CurrentState"  or name == "Visible"  or name == "Priority" or "Bounds" then
                    --Skip UI functions
                else
                    metatable[name] = logFunctionCall(f, name);
                end
            end
            if name == "__index" and not is_function(f) then
                for indexname,indexf in pairs(f) do
                    output("Found in index " .. indexname);
                    if is_function(indexf) then
                        f[indexname] = logFunctionCall(indexf, indexname);
                    end
                end
                output("Index end");
            end
        end
    end
    
    --wrap trigger event
    core.trigger_event = wrapFunction(
        core.trigger_event,
        function(ab)
        end
    );
    --wrap check callbacks
    cm.check_callbacks = wrapFunction(
        cm.check_callbacks,
        function(ab)
        end
    )

    --wrap Listeners
    local currentAddListener = core.add_listener;
    --v [NO_CHECK] function(core: any, listenerName: any, eventName: any, conditionFunc: any, listenerFunc: any, persistent: any)
    function myAddListener(core, listenerName, eventName, conditionFunc, listenerFunc, persistent)
        local wrappedCondition = nil;
        if is_function(conditionFunc) then
            --wrappedCondition =  wrapFunction(conditionFunc, function(arg) output("Callback condition called: " .. listenerName .. ", for event: " .. eventName); end);
            wrappedCondition =  wrapFunction(conditionFunc);
        else
            wrappedCondition = conditionFunc;
        end
        currentAddListener(
            core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc), persistent
            --core, listenerName, eventName, wrappedCondition, wrapFunction(listenerFunc, function(arg) output("Callback called: " .. listenerName .. ", for event: " .. eventName); end), persistent
        )
    end
    core.add_listener = myAddListener;

end

--show that SFO is active in the CA script log.
--lets other modders know we exist when debugging.
--v function()
function sfo_lib()
    out("********************")
    out("SFO LIBRARIES LOADED")
    out("********************")
end

sfo_util.init():enable_error_checker() -- launch the library with error checking attached!
