if (not game:IsLoaded()) then game.Loaded:Wait() end

for _, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do v:Disable() end
for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do v:Disable() end

local Players        = game:GetService('Players')
local RunService     = game:GetService('RunService')
local Workspace      = game:GetService('Workspace')
local Storage        = game:GetService('ReplicatedStorage')
local InputService   = game:GetService('UserInputService')
local ping           = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
local Remote         = Storage:FindFirstChild('MainEvent')
local Fov            = Drawing.new("Circle")
local Tracer         = Drawing.new("Line")
local Client         = Players.LocalPlayer
local Camera         = Workspace.CurrentCamera
local Shop           = workspace.Ignored.Shop
local backpack       = Client.Backpack
local Desync         = {OldPos = nil, newPos = nil}
local CurrentPing    = {ping = 0}
local HitBones       = {}


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
local Visuals = Tabs.Main:AddLeftGroupbox('Visuals')
local AutoShop = Tabs.Main:AddRightGroupbox('AutoShop')

local Guns = {
    ["Glock"] = {
        Gun = "[Glock] - $318",
        Ammo = "30 [Glock Ammo] - $64"
    },
    ["Silencer"] = {
        Gun = "[Silencer] - $424",
        Ammo = "25 [Silencer Ammo] - $53"
    },
    ["Revolver"] = {
        Gun = "[Revolver] - $1379",
        Ammo = "12 [Revolver Ammo] - $80"
    },
    ["TacticalShotgun"] = {
        Gun = "[TacticalShotgun] - $1857",
        Ammo = "20 [TacticalShotgun Ammo] - $64"
    },
    ["Shotgun"] = {
        Gun = "[Shotgun] - $1326",
        Ammo = "20 [Shotgun Ammo] - $64"
    },
    ["Double-Barrel SG"] = {
        Gun = "[Double-Barrel SG] - $1432",
        Ammo = "18 [Double-Barrel SG Ammo] - $53"
    },
    ["SMG"] = {
        Gun = "[SMG] - $796",
        Ammo = "80 [SMG Ammo] - $64"
    },
    ["P90"] = {
        Gun = "[P90] - $1061",
        Ammo = "120 [P90 Ammo] - $64"
    },
    ["DrumGun"] = {
        Gun = "[DrumGun] - $3183",
        Ammo = "100 [DrumGun Ammo] - $212"
    },
    ["LMG"] = {
        Gun = "[LMG] - $3978",
        Ammo = "200 [LMG Ammo] - $318"
    },
    ["AUG"] = {
        Gun = "[AUG] - $2069",
        Ammo = "90 [AUG Ammo] - $85"
    },
    ["AR"] = {
        Gun = "[AR] - $1061",
        Ammo = "100 [AR Ammo] - $80"
    },
    ["AK47"] = {
        Gun = "[AK47] - $2387",
        Ammo = "90 [AK47 Ammo] - $85"
    },
    ["SilencerAR"] = {
        Gun = "[SilencerAR] - $1326",
        Ammo = "25 [Silencer Ammo] - $53"
    },
    ["Flamethrower"] = {
        Gun = "[Flamethrower] - $15914",
        Ammo = "140 [Flamethrower Ammo] - $1644"
    },
    ["GrenadeLauncher"] = {
        Gun = "[GrenadeLauncher] - $10609",
        Ammo = "12 [GrenadeLauncher Ammo] - $3183"
    },
    ["RPG"] = {
        Gun = "[RPG] - $6365",
        Ammo = "5 [RPG Ammo] - $1061"
    }
}

local Drawing = {
    Fov = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
    },
    Tracer = {
        Enabled = false,
        Color = Color3.fromRGB(255, 255, 255),
    }
}

local Settings = {
    Version = '1.1.6 | Private',
    SilentAim = {
        Enabled = false,
        HitBone = 'Head',
        AimMethod = {'ClosestToMouse', 'ClosestToPlayer'},
        Fov = 100,
        Check = {'Visible', 'ForceField', 'Grabbed', "Knocked"}
    },
    Prediction = {
        Enabled = false,
        AutoPrediction = false,
        Prediction = 13.4,
        Resolver = false,
        ResolveMethod = {"Custom Prediction", "Velocity", "HumanoidMoveDirection"}
    },
    Desync = {
        Enabled = false,
        DesyncMode = {"Static", "Dynamic", "Jitter", "Spin"},
        Range = 1,
        X = {Min = -180, Max = 180},
        Y = {Min = -180, Max = 180},
        Z = {Min = -180, Max = 180}
    },
    AutoBuy = {
        Enabled = false,
        Weapons = { "Glock","SMG","Silencer","TacticalShotgun","P90","AUG","Shotgun","RPG","AR","Double-Barrel SG","Flamethrower","Revolver","LMG","AK47","DrumGun","Silencer","GrenadeLauncher", "SilencerAR"},
        Ammo = 1
    },
    Misc = {
        AutoReload = false,
    }
}

Silent:AddToggle('SilentAim', {
    Text = 'SilentAim',
    Default = false,
    Tooltip = 'Checkington',
    Callback = function(Value)
        Settings.SilentAim.Enabled = Value
    end
}):AddKeyPicker('KeyPicker', {
    Default = 'C',
    SyncToggleState = true,
    Mode = 'Toggle',

    Text = 'Silent Aim',
    NoUI = false
})

Silent:AddDropdown('AimMethods', {
    Values = Settings.SilentAim.AimMethod,
    Default = 0,
    Multi = false, 
    Text = 'AimMethods',
    Tooltip = 'AimMethods',
    Callback = function(Value)
        Settings.SilentAim.AimMethods = Value
    end
})

Silent:AddDropdown('Checks', {
    Values = Settings.SilentAim.Check,
    Default = 0,
    Multi = true, 
    Text = 'Checks',
    Tooltip = 'Checks',
    Callback = function(Value)
        Settings.SilentAim.Check = Value
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
}):AddKeyPicker('KeyPicker', {
    Default = 'X',
    SyncToggleState = true,
    Mode = 'Toggle',

    Text = 'Desync',
    NoUI = false
})

AntiAim:AddDropdown('AntiAim', {
    Values = Settings.Desync.DesyncMode,
    Default = 0,
    Multi = false, 
    Text = 'Desync Mode',
    Tooltip = 'Desync',
    Callback = function(Value)
        Settings.Desync.DesyncMode = Value
    end
})

AntiAim:AddSlider('AntiAimRange', {
    Text = 'Desync Range',
    Default = 1,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Settings.Desync.Range = Value
    end
})

Visuals:AddToggle('Fov', {
    Text = 'Fov',
    Default = false,
    Tooltip = 'Fov',
    Callback = function(Value)
        Drawing.Fov.Enabled = Value
    end
})

Visuals:AddToggle('Tracer', {
    Text = 'Tracer',
    Default = false,
    Tooltip = 'Tracer',
    Callback = function(Value)
        Drawing.Tracer.Enabled = Value
    end
})

Visuals:AddSlider('Fov', {
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

AutoShop:AddToggle('AutoBuy', {
    Text = 'Enable',
    Default = false,
    Tooltip = 'Enable',
    Callback = function(Value)
        Settings.AutoBuy.Enabled = Value
    end
})

AutoShop:AddDropdown('AutoBuyWeapon', {
    Values = Settings.AutoBuy.Weapons,
    Default = 0,
    Multi = true, 
    Text = 'Auto Buy',
    Tooltip = 'Auto Buy Weapon',
    Callback = function(Value)
        Settings.AutoBuy.Weapons = Value
    end
})

AutoShop:AddSlider('AmmoAmound', {
    Text = 'AmmoAmound',
    Default = 1,
    Min = 0,
    Max = 10,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        Settings.AutoBuy.Ammo = Value
    end
})

local IsAlive = function(Target)
    return Target and Target.Character and Target.Character:FindFirstChild('Humanoid') and Target.Character.Humanoid.Health > 0
end

local IsVisible = function(Target)
    if not IsAlive(Target) or not IsAlive(Client) then return false end
    return #Camera:GetPartsObscuringTarget({Target.Character[Settings.SilentAim.HitBone].Position, Client.Character[Settings.SilentAim.HitBone].Position}, {Camera, Client.Character, Target.Character}) == 0
end

local IsGrabbed = function(Target)
    if not IsAlive(Target) then return false end
    return Target.Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
end

local IsForceField = function(Target)
    if not IsAlive(Target) then return false end
    return Target.Character:FindFirstChildOfClass('ForceField') ~= nil
end

local IsKnocked = function(Target)
    if not IsAlive(Target) then return false end
    return Target.Character.BodyEffects["K.O"].Value == true
end

local Fov = function()
    Fov.Visible = Drawing.Fov.Enabled
    Fov.Radius = Settings.SilentAim.Fov
    Fov.Color = Drawing.Fov.Color
    Fov.Position = InputService:GetMouseLocation() - Vector2.new(0, 35 * 3)
end

local Tracer = function(Target)
    Tracer.Visible = Drawing.Tracer.Enabled
    Tracer.Color = Drawing.Tracer.Color
    Tracer.From = InputService:GetMouseLocation() - Vector2.new(0, 35 * 3)
    if Target then
        Tracer.To = Vector2.new(Camera:WorldToViewportPoint(Target.Character.HumanoidRootPart.Position).X, Camera:WorldToViewportPoint(Target.Character.HumanoidRootPart.Position).Y) - Vector2.new(0, 35 * 3)
    else
        Tracer.Visible = false
    end
end 

local AutoBuy = function(selectedWeapon)
    if IsForceField(Client) then return end
    if Settings.AutoBuy.Enabled then
        for name, value in next, selectedWeapon do
            local GunName = Guns[name].Gun
            local AmmoName = Guns[name].Ammo
            if GunName then
                if not (backpack:FindFirstChild(GunName) or workspace.Players:WaitForChild(Client.Name):FindFirstChild(GunName)) then
                    Client.Character.HumanoidRootPart.CFrame = Shop[GunName].Head.CFrame
                    wait(1)
                    fireclickdetector(Shop[GunName].ClickDetector)
                end
            end
            if Settings.AutoBuy.Ammo > 0 then
                for i = 1, Settings.AutoBuy.Ammo + 1 do
                    Client.Character.HumanoidRootPart.CFrame = Shop[AmmoName].Head.CFrame
                    wait(1)
                    fireclickdetector(Shop[AmmoName].ClickDetector)
                end
            end
        end
    end
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
            if Settings.SilentAim.AimMethods == "ClosestToMouse" then
                Distance = Magnitude
                ClosestPlayer = v
            elseif Settings.SilentAim.AimMethods == "ClosestToPlayer" then
                local PlayerPosition = Camera:WorldToViewportPoint(Client.Character.HumanoidRootPart.Position)
                local TargetPosition = Camera:WorldToViewportPoint(RootPart.Position)
                local PlayerDistance = (Vector2.new(PlayerPosition.X, PlayerPosition.Y) - InputService:GetMouseLocation()).Magnitude
                local TargetDistance = (Vector2.new(TargetPosition.X, TargetPosition.Y) - InputService:GetMouseLocation()).Magnitude
                if TargetDistance < PlayerDistance then
                    Distance = Magnitude
                    ClosestPlayer = v
                end
            end
        end
    end 
    
    if ClosestPlayer then
        for name, value in next, Options.Checks.Value do
            if name == "Visible" and not IsVisible(ClosestPlayer) then return end
            if name == "ForceField" and IsForceField(ClosestPlayer) then return end
            if name == "Grabbed" and IsGrabbed(ClosestPlayer) then return end
            if name == "Knocked" and IsKnocked(ClosestPlayer) then return end
        end
    end

    return ClosestPlayer
end

local Update = function()
    Fov()
    Target = GetClosestPlayer(Settings.SilentAim.Fov)
    Tracer(Target)
end

local OnCharacterAdded = function()
    AutoBuy(Settings.AutoBuy.Weapons)
end

Client.CharacterAdded:Connect(OnCharacterAdded)

RunService.RenderStepped:connect(Update)
RunService.Heartbeat:Connect(function()
    CurrentPing = tonumber(string.format("%.3f", ping:GetValue()))
    if Settings.Desync.Enabled then 
        Desync["OldPos"] = Client.Character.HumanoidRootPart.CFrame
        local Desyncmodes = {
            Static = {math.random(Settings.Desync.X.Min, Settings.Desync.X.Max),math.random(Settings.Desync.Y.Min, Settings.Desync.Y.Max),math.random(Settings.Desync.Z.Min, Settings.Desync.Z.Max)},
            Dynamic = {math.sin(tick()) * Settings.Desync.Range, math.sin(tick()) * Settings.Desync.Range, math.cos(tick()) * Settings.Desync.Range},
            Jitter = {math.random(-Settings.Desync.Range, Settings.Desync.Range),math.random(-Settings.Desync.Range, Settings.Desync.Range),math.random(-Settings.Desync.Range, Settings.Desync.Range)},
            Spin = {math.sin(tick()) * Settings.Desync.Range, 0, math.cos(tick()) * Settings.Desync.Range}
        }

        if Desyncmodes[Settings.Desync.DesyncMode] then
            Desync["newPos"] = CFrame.new(
                Client.Character.HumanoidRootPart.Position + Vector3.new(
                    unpack(Desyncmodes[Settings.Desync.DesyncMode])
                )
            )
        else
            warn("Invalid desync mode:", Settings.Desync.DesyncMode)
            return
        end

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
        elseif Settings.Prediction.Enabled or (Settings.Prediction.AutoPrediction and Settings.Prediction.Resolver) then
            if Settings.Prediction.ResolveMethod == "Custom Prediction" then
                Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position + (Target.Character.HumanoidRootPart.Velocity * Settings.Prediction.Prediction)
            elseif Settings.Prediction.ResolveMethod == "Velocity" then
                Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position + (Target.Character.HumanoidRootPart.Velocity * (Settings.Prediction.Prediction / 100))
            elseif Settings.Prediction.ResolveMethod == "HumanoidMoveDirection" then
                Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position + Target.Character.Humanoid.MoveDirection * (Settings.Prediction.Prediction / 10)
            end
        else
            Arguments[2] = Target.Character[Settings.SilentAim.HitBone].Position
        end
        
        return namecall(self, unpack(Arguments))
    end
 
    return namecall(self, ...)
end)


local old; old = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() then
        if key == "CFrame" and Client.Character and self == Client.Character:FindFirstChild("HumanoidRootPart") and Settings.Desync.Enabled and Desync["OldPos"] ~= nil and Client.Character:FindFirstChild("Humanoid") and Client.Character:FindFirstChild("Humanoid").Health > 0 then
            return Desync["OldPos"]
        end
    end
    return old(self, key)
end)


Library:OnUnload(function()Library.Unloaded=true end)Library:SetWatermark(('Primordial v%s'):format(Settings.Version))local a=Tabs['UI Settings']:AddLeftGroupbox('Menu')local b=a:AddButton({Text='Unload',Func=function()Library:Unload()end,DoubleClick=true,Tooltip='Unload Script'})a:AddButton({Text='Rejoin',Func=function()game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,game.JobId,Client)end,DoubleClick=true,Tooltip='Rejoin game'})a:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind',{Default='End',NoUI=true,Text='Menu keybind'})Library.ToggleKeybind=Options.MenuKeybind;a:AddToggle('keybindframe',{Text='Keybind Frame',Default=false,Tooltip='Toggles KeybindFrame'})Toggles.keybindframe:OnChanged(function()Library.KeybindFrame.Visible=Toggles.keybindframe.Value end)a:AddToggle('Watermark',{Text='Watermark',Default=false,Tooltip='Toggles Watermark'})Toggles.Watermark:OnChanged(function()Library:SetWatermarkVisibility(Toggles.Watermark.Value)end)Library.ToggleKeybind=Options.MenuKeybind;ThemeManager:SetLibrary(Library)SaveManager:SetLibrary(Library)SaveManager:IgnoreThemeSettings()SaveManager:SetIgnoreIndexes({'MenuKeybind'})ThemeManager:SetFolder('Primordial')SaveManager:SetFolder('Primordial/Games')SaveManager:BuildConfigSection(Tabs['UI Settings'])ThemeManager:ApplyToTab(Tabs['UI Settings'])