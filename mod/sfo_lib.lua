local sfo_util = {} --# assume sfo_util: SFO_MANAGER

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

--v function(text: string, ftext: string)
local function SFOLOG(text, ftext)
    if not __write_output_to_logfile then
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



--v function() 
function sfo_util.init()
    SFOLOGRESET()
    local self = {}
    setmetatable(self, {
        __index = sfo_util,
        __tostring = function() return "SFO_UTILITY" end
    }) --# assume self: SFO_MANAGER
    self._logLastContext = "No Context Set" --:string


    _G.sfo = self
end

--v function(self: SFO_MANAGER, ftext: string)
function sfo_util.set_log_context(self, ftext)
    self.logLastContext = ftext
end

--v function(self: SFO_MANAGER) --> string
function sfo_util.log_context(self)
    return self._logLastContext
end


--v function(self: SFO_MANAGER, text: any, ftext: any?)
function sfo_util.log(self, text, ftext)
    if ftext then
        self:set_log_context(tostring(ftext))
    end
    SFOLOG(tostring(text), self:log_context())
end

--v [NO_CHECK] function(self: SFO_MANAGER)
function sfo_util.enable_error_checker(self)   
    --Vanish's PCaller
    --All credits to vanish
    --v function(func: function) --> any
    function safeCall(func)
        --output("safeCall start");
        local status, result = pcall(func)
        if not status then
            SFOLOG(tostring(result), "ERROR CHECKER")
            SFOLOG(debug.traceback(), "ERROR CHECKER");
        end
        --output("safeCall end");
        return result;
    end
    
    --local oldTriggerEvent = core.trigger_event;
    
    --v [NO_CHECK] function(...: any)
    function pack2(...) return {n=select('#', ...), ...} end
    --v [NO_CHECK] function(t: vector<WHATEVER>) --> vector<WHATEVER>
    function unpack2(t) return unpack(t, 1, t.n) end
    
    --v [NO_CHECK] function(f: function(), argProcessor: function()) --> function()
    function wrapFunction(f, argProcessor)
        return function(...)
            --output("start wrap ");
            local someArguments = pack2(...);
            if argProcessor then
                safeCall(function() argProcessor(someArguments) end)
            end
            local result = pack2(safeCall(function() return f(unpack2( someArguments )) end));
            --for k, v in pairs(result) do
            --    output("Result: " .. tostring(k) .. " value: " .. tostring(v));
            --end
            --output("end wrap ");
            return unpack2(result);
            end
    end
    
    -- function myTriggerEvent(event, ...)
    --     local someArguments = { ... }
    --     safeCall(function() oldTriggerEvent(event, unpack( someArguments )) end);
    -- end
    
    --v [NO_CHECK] function(fileName: string)
    function tryRequire(fileName)
        local loaded_file = loadfile(fileName);
        if not loaded_file then
            output("Failed to find mod file with name " .. fileName)
        else
            output("Found mod file with name " .. fileName)
            output("Load start")
            local local_env = getfenv(1);
            setfenv(loaded_file, local_env);
            loaded_file();
            output("Load end")
        end
    end
    
    --v [NO_CHECK] function(f: function(), name: string)
    function logFunctionCall(f, name)
        return function(...)
            output("function called: " .. name);
            return f(...);
        end
    end
    
    --v [NO_CHECK] function(object: any)
    function logAllObjectCalls(object)
        local metatable = getmetatable(object);
        for name,f in pairs(getmetatable(object)) do
            if is_function(f) then
                output("Found " .. name);
                if name == "Id" or name == "Parent" or name == "Find" or name == "Position" or name == "CurrentState"  or name == "Visible"  or name == "Priority" or "Bounds" then
                    --Skip
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
    
    -- logAllObjectCalls(core);
    -- logAllObjectCalls(cm);
    -- logAllObjectCalls(game_interface);
    
    core.trigger_event = wrapFunction(
        core.trigger_event,
        function(ab)
            --output("trigger_event")
            --for i, v in pairs(ab) do
            --    output("i: " .. tostring(i) .. " v: " .. tostring(v))
            --end
            --output("Trigger event: " .. ab[1])
        end
    );
    
    cm.check_callbacks = wrapFunction(
        cm.check_callbacks,
        function(ab)
            --output("check_callbacks")
            --for i, v in pairs(ab) do
            --    output("i: " .. tostring(i) .. " v: " .. tostring(v))
            --end
        end
    )
    
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


function sfo_lib()
    out("********************")
    out("SFO LIBRARIES LOADED")
    out("********************")
end

sfo_util.init()
