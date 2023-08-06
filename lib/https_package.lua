local https = require ("ssl.https")

local loaded = setmetatable({}, {__mode = "kv"})
local fmt = "/(%w+).lua$"

return function(env)
    local function require(uri)
        if loaded[uri] then return loaded[uri] end
        local name = uri:match(fmt)
        local data = assert(https.request(uri))
        local res = assert(load(data, "uri", "t", env))()
        loaded[name] = res

        return res, name
    end

    return require
end