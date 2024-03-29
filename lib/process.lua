local https = require ("ssl.https")
local http = require ("socket.http")
local json = require ("dkjson")
local serialize = require ("serialize")
local pkg = require ("https_package")

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
    serialize = setmetatable({}, {__index = serialize}),
    os = {
        clock = os.clock,
        time = os.time,
        date = os.date,
        difftime = os.difftime,
    },
    debug = {
        traceback = debug.traceback,
        getinfo = debug.getinfo,
        getupvalue = debug.getupvalue,
        getuserdata = debug.getuservalue,
        getlocal = debug.getlocal,
        setlocal = debug.setlocal,
        setuservalue = debug.setuservalue,
        upvalueid = debug.upvalueid,
        upvaluejoin = debug.upvaluejoin,
    },
    tohex = function(str)
        if type(str) == "string" then
            return (str:gsub('.', function (c)
                return string.format('%02x', string.byte(c))
            end))
        elseif type(str) == "number" then
            return string.format("%x", str)
        end
    end,
    fromhex = function(str)
        return (str:gsub('..', function (cc)
            return string.char(tonumber(cc, 16))
        end))
    end,
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
        end,
    }, {__index = penv})

    env.require = pkg(env)

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

    local out = table.concat(out, "\n", 1, math.min(10, #out)):gsub("@%w+", "[mention not alowed]"):sub(1,1000)

    return true, state, out
end

return M
