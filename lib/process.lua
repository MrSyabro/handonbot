local https = require ("ssl.https")
local http = require ("socket.http")
local json = require ("dkjson")

local M = {}

local penv = {
    string = setmetatable({}, {__index = string}),
    rawlen = rawlen,
    _VERSION = _VERSION,
    tostring = tostring,
    type = type,
    pairs = pairs,
    coroutine = setmetatable({}, {__index = coroutine}),
    pcall = pcall,
    math = setmetatable({}, {__index = math}),
    table = setmetatable({}, {__index = table}),
    tonumber = tonumber,
    assert = assert,
    warn = warn,
    load = load,
    ipairs = ipairs,
    rawget = rawget,
    next = next,
    utf8 = setmetatable({}, {__index = utf8}),
    rawequal = rawequal,
    setmetatable = setmetatable,
    error = error,
    select = select,
    xpcall = xpcall,
    rawset = rawset,
    https = setmetatable({}, {__index = https}),
    http = setmetatable({}, {__index = http}),
    json = setmetatable({}, {__index = json}),
    os = {
        clock = os.clock,
        time = os.time,
        date = os.date,
        difftime = os.difftime,
    },
}

function M.run (data)
    local out,state = {}, {}
    local start_time = os.time()

    local function hook(mask)
        if os.time() - start_time > 5 then
            print ("Many time")
            error ("timeout")
        end
    end

    local env = setmetatable({
        print = function(...)
            local str = {}
            for k,d in ipairs({...}) do
                str[k] = tostring(d)
            end
            table.insert(out, table.concat(str, "\t"))
        end
    }, {__index = penv})

    local func, err = load(data, "userdata", "t", env)
    if not func then return false, err
    end

    local thread = coroutine.create(func)
    debug.sethook(thread, hook, "c", 5)
    while coroutine.status(thread) ~= "dead" do
        local res, rets = coroutine.resume(thread)
        if res then
            table.insert(state, rets)
        else
            return false, rets
        end
    end

    return true, state, table.concat(out, "\n")
end

return M
