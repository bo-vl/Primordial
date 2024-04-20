repeat wait() until game:IsLoaded()

local gameid = game.PlaceId
local HttpService = game:GetService("HttpService")
local PlacesData = game:HttpGet("https://raw.githubusercontent.com/Bovanlaarhoven/Hydraware/main/src/places.json")
local Places = HttpService:JSONDecode(PlacesData)

local supported = false

for placeName, placeIds in pairs(Places) do
    print("Checking place:", placeName)
    for _, id in ipairs(placeIds) do
        print("Comparing IDs: ", id, gameid)
        if tonumber(id) == gameid then
            print("Match found!")
            supported = true
            break
        end
    end
    if supported then
        break
    end
end

if supported then
    print("Game is supported by HydraWare.")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Bovanlaarhoven/Hydraware/main/src/main.lua"))()
    if not isfolder("HydraWare") then
        makefolder("HydraWare")
    end
    writefile("HydraWare/Support.txt", gameid)
else
    game:GetService("Players").LocalPlayer:Kick(gameid .. " is not supported by HydraWare.")
end
