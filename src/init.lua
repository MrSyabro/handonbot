#!/usr/bin/env lua
--local config = dofile("config.lua")
local config = dofile("/etc/handonbot.lua")
--local users = require("database").new_db(config.user_db)
local api = require("telegram-bot-lua.core").configure(config.token)
local proc = require("process")
local s = require("serialize")


function api.on_message(message)
    if message.text
    and message.text:match("/run") then
        local data = message.text:match("/run%s*(.+)")
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

        api.send_message(message.chat.id,
                table.concat(mess),
                "Markdown", true, true, message.message_id)
    end
end

api.run()
