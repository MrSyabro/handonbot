local https = require ("ssl.https")

return function(env)
    local package_t = {}
    local function require(uri)
        if package_t.loaded[uri] then return package_t.loaded[uri] end
        local data = assert(https.request(uri))
        local res = assert(load(data, "uri", "t", env))()
        package_t.loaded[uri] = res

        return res
    end

    return package_t, require
end