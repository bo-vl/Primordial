if (not game:IsLoaded()) then game.Loaded:Wait() end

for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do v:Disable() end
for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do v:Disable() end

local Players        = game:GetService('Players')
local RunService     = game:GetService('RunService')
local Workspace      = game:GetService('Workspace')
local Storage        = game:GetService('ReplicatedStorage')
local InputService   = game:GetService('UserInputService')
local HitBones       = {}
local Client         = Players.LocalPlayer
local Camera         = Workspace.CurrentCamera
local Remote         = Storage:FindFirstChild('MainEvent')
local ping           = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
local Fov            = Drawing.new("Circle")
local Desync         = {OldPos = nil, newPos = nil}
local CurrentPing    = {ping = 0}


for _, v in pairs(Client.Character:GetChildren()) do if v:IsA("BasePart") then table.insert(HitBones, v.Name) end end
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Primordial',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local Silent = Tabs.Main:AddLeftGroupbox('SilentAim')
local Predication = Tabs.Main:AddRightGroupbox('Predication')
local AntiAim = Tabs.Main:AddRightGroupbox('AntiAim')
local Circle = Tabs.Main:AddLeftGroupbox('Fov')

local Drawing = {
    Fov = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
    }
}

local Settings = {
    Version = '1.0.0 | Private',
    SilentAim = {
        Enabled = false,
        HitBone = 'Head',
        Fov = 100,
        Check = {
            Visible = false,
            ForceField = false,
            Grabbed = false
        }
    },
    Prediction = {
        Enabled = false,
        AutoPrediction = false,
        Prediction = 13.4,
        Resolver = false,
        ResolveMethod = "Velocity"
    },
    Desync = {
        Enabled = false,
        X = {Min = -180, Max = 180},
        Y = {Min = -180, Max = 180},
        Z = {Min = -180, Max = 180}
    }
}

Silent:AddToggle('SilentAim', {
    Text = 'SilentAim',
    Default = false,
    Tooltip = 'Checkington',
    Callback = function(Value)
        Settings.SilentAim.Enabled = Value
    end
})

Silent:AddDropdown('HitBone', {
    Values = HitBones,
    Default = 0,
    Multi = false, 
    Text = 'HitBone',
    Tooltip = 'HitBone',
    Callback = function(Value)
        Settings.SilentAim.HitBone = Value
    end
})

AntiAim:AddToggle('Desync', {
    Text = 'Desync',
    Default = false,
    Tooltip = 'Desync',
    Callback = function(Value)
        Settings.Desync.Enabled = Value
    end
})

Circle:AddToggle('Fov', {
    Text = 'Fov',
    Default = false,
    Tooltip = 'Fov',
    Callback = function(Value)
        Drawing.Fov.Enabled = Value
    end
})

Circle:AddSlider('Fov', {
    Text = 'Fov Radius',
    Default = 100,
    Min = 1,
    Max = 1000,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        Settings.SilentAim.Fov = Value
    end
})

Predication:AddToggle('Prediction', {
    Text = 'Prediction',
    Default = false,
    Tooltip = 'Prediction',
    Callback = function(Value)
        Settings.Prediction.Enabled = Value
    end
})

Predication:AddToggle('AutoPrediction', {
    Text = 'Auto Prediction',
    Default = false,
    Tooltip = 'Auto Prediction',
    Callback = function(Value)
        Settings.Prediction.AutoPrediction = Value
    end
})

Predication:AddSlider('PredictionAmound', {
    Text = 'Prediction Amound',
    Default = 13,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        Settings.Prediction.Prediction = Value
    end
})

Predication:AddToggle('Resolver', {
    Text = 'Resolver',
    Default = false,
    Tooltip = 'Resolver',
    Callback = function(Value)
        Settings.Prediction.Resolver = Value
    end
})

Predication:AddDropdown('ResolverMethod', {
    Values = {'Custom Prediction', 'Velocity', 'HumanoidMoveDirection'},
    Default = 0,
    Multi = false, 
    Text = 'Resolve Method',
    Tooltip = 'Resolve Method',
    Callback = function(Value)
        Settings.Prediction.ResolveMethod = Value
    end
})

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

RunService.Heartbeat:Connect(function()
    CurrentPing = tonumber(string.format("%.3f", ping:GetValue()))
    if Settings.Desync.Enabled then 
        Desync["OldPos"] = Client.Character.HumanoidRootPart.CFrame

        Desync["newPos"] = CFrame.new(
            Client.Character.HumanoidRootPart.Position + Vector3.new(
                math.random(Settings.Desync.X.Min, Settings.Desync.X.Max),
                math.random(Settings.Desync.Y.Min, Settings.Desync.Y.Max),
                math.random(Settings.Desync.Z.Min, Settings.Desync.Z.Max)
            )
        ) * CFrame.Angles(
            math.rad(math.random(Settings.Desync.X.Min, Settings.Desync.X.Max)),
            math.rad(math.random(Settings.Desync.Y.Min, Settings.Desync.Y.Max)),
            math.rad(math.random(Settings.Desync.Z.Min, Settings.Desync.Z.Max))
        )
    
        Client.Character.HumanoidRootPart.CFrame = Desync["newPos"]
    
        RunService.RenderStepped:Wait()
    
        Client.Character.HumanoidRootPart.CFrame = Desync["OldPos"]
    end

    if Settings.Prediction.AutoPrediction then
        if CurrentPing < 20 then
            if Settings.Prediction.Prediction > 15.7 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 15.7 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 30 then
            if Settings.Prediction.Prediction > 15.5 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 15.5 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 40 then
            if Settings.Prediction.Prediction > 14.5 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 14.5 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 50 then
            if Settings.Prediction.Prediction > 14.3 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 14.3 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 60 then
            if Settings.Prediction.Prediction > 14 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 14 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 70 then
            if Settings.Prediction.Prediction > 13.6 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 13.6 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 80 then
            if Settings.Prediction.Prediction > 13.3 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 13.3 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 90 then
            if Settings.Prediction.Prediction > 13 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 13 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 105 then
            if Settings.Prediction.Prediction > 12.7 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 12.7 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        elseif CurrentPing < 110 then
            if Settings.Prediction.Prediction > 12.4 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 12.4 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        else
            if Settings.Prediction.Prediction > 12 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value-.1) end
            if Settings.Prediction.Prediction < 12 then Options.PredictionAmound:SetValue(Options.PredictionAmound.Value+.1) end
        end
        wait(.2)
    end

end)

local namecall; namecall = hookmetamethod(game, '__namecall', function(self, ...)
    local Arguments, Method = {...}, getnamecallmethod()
 
    if (not checkcaller() and Settings.SilentAim.Enabled and Target and Method == 'FireServer' and self == Remote and Arguments[1] == 'UpdateMousePos') then 
        if Settings.Prediction.Enabled then
            Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position
        elseif Settings.Prediction.Enabled or Settings.Prediction.AutoPrediction and Settings.Prediction.Resolver then
            if Settings.Prediction.ResolveMethod == "Custom Prediction" then
                Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position + Target.Character[Settings.SilentAim.HitBone].Velocity * Settings.Prediction.Prediction
            elseif Settings.Prediction.ResolveMethod == "Velocity" then
                Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position + Target.Character[Settings.SilentAim.HitBone].Velocity * (Settings.Prediction.Prediction / 100)
            elseif Settings.Prediction.ResolveMethod == "HumanoidMoveDirection" then
                Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position + Target.Character[Settings.SilentAim.HitBone].Humanoid.MoveDirection * (Settings.Prediction.Prediction / 100)
            end
        else
            Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position
        end
        return namecall(self, unpack(Arguments))
    end
 
    return namecall(self, ...)
end)

local old; old = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and key == "CFrame" and self == Client.Character.HumanoidRootPart and Settings.Desync.Enabled then
        return Desync["OldPos"]
    end
    return old(self, key)
end)


Library:OnUnload(function()Library.Unloaded=true end)Library:SetWatermark(('Primordial v%s'):format(Settings.Version))local a=Tabs['UI Settings']:AddLeftGroupbox('Menu')local b=a:AddButton({Text='Unload',Func=function()Library:Unload()end,DoubleClick=true,Tooltip='Unload Script'})a:AddButton({Text='Rejoin',Func=function()game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,game.JobId,Client)end,DoubleClick=true,Tooltip='Rejoin game'})a:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind',{Default='End',NoUI=true,Text='Menu keybind'})Library.ToggleKeybind=Options.MenuKeybind;a:AddToggle('keybindframe',{Text='Keybind Frame',Default=false,Tooltip='Toggles KeybindFrame'})Toggles.keybindframe:OnChanged(function()Library.KeybindFrame.Visible=Toggles.keybindframe.Value end)a:AddToggle('Watermark',{Text='Watermark',Default=false,Tooltip='Toggles Watermark'})Toggles.Watermark:OnChanged(function()Library:SetWatermarkVisibility(Toggles.Watermark.Value)end)Library.ToggleKeybind=Options.MenuKeybind;ThemeManager:SetLibrary(Library)SaveManager:SetLibrary(Library)SaveManager:IgnoreThemeSettings()SaveManager:SetIgnoreIndexes({'MenuKeybind'})ThemeManager:SetFolder('Primordial')SaveManager:SetFolder('Primordial/Games')SaveManager:BuildConfigSection(Tabs['UI Settings'])ThemeManager:ApplyToTab(Tabs['UI Settings'])