local M = {}

function ser (o, readable, prefix)
	local p = prefix or ""
	local r = readable or false
	local out = {}
	if type(o) == "number" then
		out[1] = o
	elseif type(o) == "string"
	or type(o) == "boolean" then
		out[1] = string.format("%q", o)
	elseif type(o) == "table" then
		table.insert(out, "{"..((r and "\n") or ""))
		local c = 0
		for i, k in pairs(o) do
			local lo = ser(k, r, r and (p.."\t"))
			if lo then
				table.insert(out, (p.."[%q]="):format(i))
				table.insert(out, lo..","..((r and "\n") or ""))
			end
		end
		table.insert(out, p.."}")
	else
		out[1] = string.format("%q", type(o))
	end
	
	return table.concat(out)
end

function M.deser(str)
	local f, err = load("return "..str, "desrialize", "tb", {})
	if not f then return nil, err end
	local data = f()
	return data
end

function M.deser_file(filepath)
	local file, err = io.open(filepath)
	if not file then return nil, err end
	local str = file:read("a")
	file:close()
	return M.deser(str)
end

function M.ser_file(filepath, data, readable)
	local file, err = io.open(filepath, "w")
	if not file then return nil, err end
	file:write(ser(data, readable))
	file:close()
end

M.ser = ser

return M
