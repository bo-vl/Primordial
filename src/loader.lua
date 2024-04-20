local HttpService = game:GetService('HttpService')

local url = 'https://raw.githubusercontent.com/username/repo/master/places.json'

local response = HttpService:GetAsync(url)

local data = HttpService:JSONDecode(response)

for _, id in ipairs(data["Dahood"]) do
    if tostring(game.PlaceId) == id then
        print("Da Hood")
        break
    end
end