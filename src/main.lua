local Remotes = {
    "TeleportDetect",
    "CHECKER_1",
    "CHECKER",
    "GUI_CHECK",
    "OneMoreTime",
    "checkingSPEED",
    "BANREMOTE",
    "PERMAIDBAN",
    "KICKREMOTE",
    "BR_KICKPC",
    "BR_KICKMOBILE"
}

local gamerawmetatable = getrawmetatable(game)
setreadonly(gamerawmetatable, false)

local oldnamecall = gamerawmetatable.__namecall
gamerawmetatable.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "FireServer" and table.find(Remotes, tostring(args[1])) then
        return
    end
    return oldnamecall(self, ...)
end)