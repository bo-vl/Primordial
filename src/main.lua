repeat wait() until game:IsLoaded()

local plrs, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local GetMouse = plr:GetMouse()
local MainEvent = game:GetService("ReplicatedStorage").MainEvent
local RunService = game:GetService("RunService")
local toolConnection = {nil, nil}
local ShootArgument = nil
local mt = getrawmetatable(game)
local backupnamecall = mt.__namecall
local Fov = Drawing.new("Circle")

local Drawing = {
    Fov = {
        Enabled = true,
        Color = Color3.new(255, 255, 255),
        Thickness = 1
    },
    Tracer = {
        Enabled = false,
        Color = Color3.new(255, 255, 255),
        Thickness = 1
    }
}

local Settings = {
    legit = {
        SilentAim = {
            Enabled = true,
            HitBone = "HumanoidRootPart",
            AimMethod = "NoCheck",
            FOV = 100,
        },
        Predication = {
            Enabled = false,
            Resolver = false,
            ResolverMethod = "HumanoidMoveDirection",
        },
    },
    Rage = {
        Misc = {
            AutoShoot = false,
            AutoReload = true
        },
    },
    Visuals = {
        BulletTracers = {
            Enabled = false,
            Color = Color3.new(255, 255, 255),
            Thickness = 1
        }
    }
}

local Fov = function()
    if Drawing.Fov.Enabled then
        Fov.Color = Drawing.Fov.Color
        Fov.Thickness = Drawing.Fov.Thickness
        Fov.Radius = Settings.legit.SilentAim.FOV
        Fov.Position = Vector2.new(GetMouse.X, GetMouse.Y - 36)
        Fov.Visible = true
    else
        Fov.Visible = false
    end
end

local IsGun = function(tool)
    return tool:IsA("Tool")
end

local OnScreen = function(pos)
    local vector, onScreen = Camera:WorldToScreenPoint(pos)
    return onScreen
end

local InFov = function(target)
    local vector = Camera:WorldToScreenPoint(target.Position)
    local x, y = vector.X, vector.Y
    local fov = Settings.legit.SilentAim.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local distance = Vector2.new(x, y) - center
    return distance.magnitude <= fov

end

local IsVisible = function(target)
    local ray = Ray.new(Camera.CFrame.Position, (target.Position - Camera.CFrame.Position).Unit * 3000)
    local part = workspace:FindPartOnRayWithIgnoreList(ray, {Camera, plr.Character})
    return part == target
end

local GetClosestPlayer = function()
    local closest, minAngle = nil, math.huge
    local playerPosition = Camera.CFrame.Position
    local playerLookVector = (Camera.CFrame * CFrame.new(0, 0, -1)).lookVector
    local fov = Settings.legit.SilentAim.FOV

    for _, player in pairs(plrs:GetPlayers()) do
        if player ~= plr and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hitBone = player.Character[Settings.legit.SilentAim.HitBone]
            if hitBone then
                local targetPosition = hitBone.Position
                local directionToTarget = (targetPosition - playerPosition).unit
                local angleToTarget = math.acos(playerLookVector:Dot(directionToTarget))

                if angleToTarget <= math.rad(fov / 2) then
                    if angleToTarget < minAngle then
                        if Settings.legit.SilentAim.AimMethod == "Visible" then
                            if IsVisible(hitBone) then
                                minAngle = angleToTarget
                                closest = player
                            end
                        else
                            minAngle = angleToTarget
                            closest = player
                        end
                    end
                end
            end
        end
    end
    return closest
end


plr.Character.ChildAdded:Connect(function(child)
    if IsGun(child) then
        if toolConnection[1] == nil then
            toolConnection[1] = child 
        end
        if toolConnection[1] ~= child and toolConnection[2] ~= nil then 
            toolConnection[2]:Disconnect()
            toolConnection[1] = child
        end

        toolConnection[2] = child.Activated:Connect(function()
            if Settings.legit.SilentAim.Enabled and not Settings.legit.Predication.Resolver then
                local target = GetClosestPlayer()
                if target then
                    if ShootArgument then
                        MainEvent:FireServer(ShootArgument, target.Character[Settings.legit.SilentAim.HitBone].Position)
                    end
                end
            elseif Settings.legit.SilentAim.Enabled and Settings.legit.Predication.Resolver then
                local target = GetClosestPlayer()
                if target then
                    local targetCharacter = target.Character
                    local targetHumanoid = targetCharacter:FindFirstChild("Humanoid")
                    if targetHumanoid then
                        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
                        if targetRootPart then
                            local targetVelocity = targetHumanoid.MoveDirection * targetHumanoid.WalkSpeed
                            local targetPredictedPosition = targetRootPart.Position + targetVelocity
                            MainEvent:FireServer(ShootArgument, targetPredictedPosition)
                        end
                    end
                end
            end

            if Settings.Rage.Misc.AutoReload then
                if child:FindFirstChild("Ammo") ~= nil then
                    if child.Ammo.Value == 0 then
                        MainEvent:FireServer("Reload", child)
                    end
                end
            end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    Fov()
end)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if typeof(args[2]) == "Vector3" then
        ShootArgument = args[1]
    end
    return backupnamecall(self, ...)
end)
