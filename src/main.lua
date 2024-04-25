if (not game:IsLoaded()) then game.Loaded:Wait() end

local Players        = game:GetService('Players')
local RunService     = game:GetService('RunService')
local Workspace      = game:GetService('Workspace')
local Storage        = game:GetService('ReplicatedStorage')
local InputService   = game:GetService('UserInputService')
local Client         = Players.LocalPlayer
local Camera         = Workspace.CurrentCamera
local Remote         = Storage:FindFirstChild('MainEvent')
local mt             = getrawmetatable(game)
local backupnamecall = mt.__namecall
local Fov            = Drawing.new("Circle")

local Drawing = {
    Fov = {
        Enabled = true,
        Color = Color3.fromRGB(255, 255, 255),
    }
}

local Settings = {
    SilentAim = {
        Enabled = true,
        HitBone = 'Head',
        Fov = 100,
        Check = {
            Visible = false,
            ForceField = false,
            Grabbed = false
        }
    }
}

local Fov = function()
    Fov.Visible = Drawing.Fov.Enabled
    Fov.Radius = Settings.SilentAim.Fov
    Fov.Color = Drawing.Fov.Color
    Fov.Position = InputService:GetMouseLocation() - Vector2.new(0, 35 * 3)
end

local GetClosestPlayer = function(Radius)
    local Distance, ClosestPlayer = Radius, nil
    for _,v in pairs(Players:GetPlayers()) do
        if (v == Client) then continue end
        local Character = v.Character
        local RootPart = Character and Character:FindFirstChild('HumanoidRootPart')

        if not (RootPart) then continue end

        local Position, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
        local Magnitude = (Vector2.new(Position.X, Position.Y) - InputService:GetMouseLocation()).Magnitude

        if Magnitude > Distance then continue end
        if OnScreen then
            Distance = Magnitude
            ClosestPlayer = v
        end
    end
    return ClosestPlayer
end

local Update = function()
    Fov()
    Target = GetClosestPlayer(Settings.SilentAim.Fov)
end

RunService.RenderStepped:Connect(Update)

local namecall

namecall = hookmetamethod(game, '__namecall', function(self, ...)
    local Arguments, Method = {...}, getnamecallmethod()
 
    if (not checkcaller() and Settings.SilentAim.Enabled and Target and Method == 'FireServer' and self == Remote and Arguments[1] == 'UpdateMousePos') then 
        Arguments[2] = Target.Character.HumanoidRootPart.Position + (Target.Character.HumanoidRootPart.Velocity * 0.129)
        return namecall(self, unpack(Arguments))
    end
 
    return namecall(self, ...)
end)
