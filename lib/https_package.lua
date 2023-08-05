local https = require ("ssl.https")

local M = {}

M.loaded = {}

function M.require(uri)
    if M.loaded[uri] then return M.loaded[uri] end
    local data = assert(https.request(uri))
    local res = assert(load(data))()
    M.loaded[uri] = res

    return res
end

return M