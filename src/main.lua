repeat wait() until game:IsLoaded()

local utils = 'https://raw.githubusercontent.com/Bovanlaarhoven/Hydraware/main/src/utils/'
local plrs, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local GetMouse = plr:GetMouse()
local Hitbones = {}

local Settings = {
    SilentAim = {
        Enabled = true,
        HitBone = "Head",
        FOV = 100,
        VisibleCheck = false
    },
}

for _, v in pairs(plr.Character:GetChildren()) do
    if v:IsA("BasePart") then
        table.insert(Hitbones, v.Name)
    end
end

local OnScreen = function(pos)
    local vector, onScreen = Camera:WorldToScreenPoint(pos)
    return vector, onScreen
end

local InFov = function(target)
    local vector, onScreen = OnScreen(target.Position)
    if onScreen then
        local distance = (Vector2.new(vector.X, vector.Y) - Vector2.new(GetMouse.X, GetMouse.Y)).Magnitude
        if distance <= Settings.SilentAim.FOV then
            return true
        end
    end
    return false
end

local IsVisible = function(target)
    local ray = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 3000)
    local part = workspace:FindPartOnRayWithIgnoreList(ray, {Camera, plr.Character})
    if part == target then
        return true
    end
    return false
end

local GetClosestPlayer = function()
    local closest, distance = nil, math.huge
    for _, v in pairs(plrs:GetPlayers()) do
        if v ~= plr and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character:FindFirstChild("Humanoid").Health > 0 then
            local vector, onScreen = OnScreen(v.Character[Settings.SilentAim.HitBone].Position)
            if vector and onScreen then
                local magnitude = (Vector2.new(vector.X, vector.Y) - Vector2.new(GetMouse.X, GetMouse.Y)).Magnitude
                if magnitude < distance and magnitude <= Settings.SilentAim.FOV then
                    if Settings.SilentAim.VisibleCheck then
                        if IsVisible(v.Character[Settings.SilentAim.HitBone]) then
                            closest = v
                            distance = magnitude
                        end
                    else
                        closest = v
                        distance = magnitude
                    end
                end
            end
        end
    end
    return closest
end

local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    if tostring(self.Name) == "MainEvent" and getnamecallmethod() == "FireServer" then
        local args = {...}
        if args[1] == "UpdateMousePos" then
            local target = GetClosestPlayer()
            if target then
                local hitpart = target.Character[Settings.SilentAim.HitBone]
                if hitpart then
                    args[2] = hitpart.Position
                    return old(self, unpack(args))
                end
            end
        end
    end
    return old(self, ...)
end)
