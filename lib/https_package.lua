local https = require ("ssl.https")

local loaded = setmetatable({}, {__mode = "kv"})

return function(env)
    local function require(uri)
        if loaded[uri] then return loaded[uri] end
        local data = assert(https.request(uri))
        local res = assert(load(data, "uri", "t", env))()
        loaded[uri] = res

        return res
    end

    return require
end