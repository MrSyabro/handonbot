package = "handonbot"
version = "dev-1"
source = {
   url = "git+https://github.com/MrSyabro/handonbot.git",
   branch = "master"
}
description = {
   homepage = "https://github.com/MrSyabro/handonbot",
   license = "MIT/X11"
}
dependencies = {
   "lua >= 5.2",
   "luafilesystem",
   "dkjson",
   "luasocket",
   "luasec",
   "telegram-bot-lua",
}
build = {
   type = "builtin",
   modules = {},
   install = {
        lua = {
            process = "lib/process.lua",
            serialize = "lib/serialize.lua",
            https_package = "lib/https_package.lua",
        },
        bin = { handonbot = "src/init.lua" },
   }
}
