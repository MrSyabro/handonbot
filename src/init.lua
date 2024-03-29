#!/usr/bin/env lua
local config = dofile(arg[1] == "-c" and arg[2] or "config.lua")
local api = require("telegram-bot-lua.core").configure(config.token)
local proc = require("process")
local s = require("serialize")

local messages = setmetatable({}, { __mode = "k" })

local function run(data)
	local state, rets, out = proc.run(data)
	local mess = {}
	if state then
		table.insert(mess, out)
		if #rets > 0 then
			table.insert(mess, "\n\n*Returns:*\n```lua\n")
			table.insert(mess, s.ser(rets, true))
			table.insert(mess, "\n```")
		end
	else
		table.insert(mess, "*Error:*\n```lua\n")
		table.insert(mess, rets)
		table.insert(mess, "\n```")
	end

	if #table.concat(mess) < 1 then table.insert(mess, "`Nothing.`") end

	return mess
end

function api.on_message(message)
	if message.text
			and message.text:match("/run") then
		local data = message.text:match("/run%g*%s*(.+)")
		print("loading code with " .. message.from.username or message.from.firstname)
		local mess = run(data or "")

		-- chat_id [or message object],
		-- text,
		-- message_thread_id,
		-- parse_mode,
		-- entities,
		-- link_preview_options,
		-- disable_notification,
		-- protect_content,
		-- reply_parameters,
		-- reply_markup

		local result = api.send_message(
			message.chat.id,
			table.concat(mess),
			nil,
			"Markdown",
			nil,
			nil,
			true,
			false,
			{
				chat_id = message.chat.id,
				message_id = message.message_id,
			})

		if type(result) == "table"
				and result.result
				and result.result.message_id then
			messages[message.message_id] = result.result.message_id
		end
	end
end

function api.on_edited_message(message)
	local response_message = messages[message.message_id]
	if response_message
			and message.text
			and message.text:match("/run") then
		local data = message.text:match("/run%g*%s*(.+)")
		local mess = run(data)

		api.edit_message_text(message.chat.id, response_message,
			table.concat(mess),
			"Markdown", true)
	end
end

api.run()
