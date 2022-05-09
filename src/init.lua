#!/usr/bin/env lua
--local config = dofile("config.lua")
local config = dofile("/etc/handonbot.lua")
--local users = require("database").new_db(config.user_db)
local api = require("telegram-bot-lua.core").configure(config.token)
local proc = require("process")
local s = require("serialize")

local messages = setmetatable({}, {__mode = "k"})

local function run (data)
    local state, rets, out = proc.run(data)
    local mess = {}
    if state then
        table.insert(mess, out)
        if rets.n > 1 then
            table.insert(mess, "\n\n*Returns:*\n```lua\n")
            table.insert(mess, s.ser(rets, true))
            table.insert(mess, "\n```")
        end
    else
        table.insert(mess, "*Error:*\n```lua\n")
        table.insert(mess, rets)
        table.insert(mess, "\n```")
    end

    return mess
end

function api.on_message(message)
    if message.text
    and message.text:match("/run") then
        local data = message.text:match("/run%s*(.+)")
        local mess = run(data)

        local result = api.send_message(message.chat.id,
            table.concat(mess),
            "Markdown", true, true, message.message_id)

        messages[message.message_id] = result.result.message_id
    end
end

function api.on_edited_message(message)
    local response_message = messages[message.message_id]
    if response_message
    and message.text
    and message.text:match("/run") then
        local data = message.text:match("/run%s*(.+)")
        local mess = run(data)

        api.edit_message_text(message.chat.id, response_message,
            table.concat(mess),
            "Markdown", true)
    end
end

api.run()
