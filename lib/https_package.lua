local https = require ("ssl.https")

local loaded = setmetatable({}, {__mode = "kv"})
local fmt = "/(%w+).lua$"

return function(env)
    local function require(uri)
        local name = uri:match(fmt)
        if loaded[name] then return loaded[name] end
        local data = assert(https.request(uri))
        local res = assert(load(data, "uri", "t", env))()
        loaded[name] = res

        return res, name
    end

    return require
end