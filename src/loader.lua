local gameid = game.PlaceId
local HttpService = game:GetService("HttpService")
local PlacesData = game:HttpGet("https://raw.githubusercontent.com/Bovanlaarhoven/Hydraware/main/src/places.json")
local Places = HttpService:JSONDecode(PlacesData)

for placeName, placeIds in pairs(Places) do
    for _, id in ipairs(placeIds) do
        if id == tostring(gameid) then
            local Info = {
                PlaceId = id,
                PlaceName = placeName,
            }
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Bovanlaarhoven/Hydraware/main/src/main.lua"))(Info)
        end
    end
end