repeat wait() until game:IsLoaded()

local plrs, plr = game:GetService("Players"), game:GetService("Players").LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local GetMouse = plr:GetMouse()
local MainEvent = game:GetService("ReplicatedStorage").MainEvent
local mt = getrawmetatable(game)
local backupnamecall = mt.__namecall
local toolConnection = {nil, nil}
local shootArgument = nil


local Settings = {
    legit = {
        SilentAim = {
            Enabled = true,
            HitBone = "HumanoidRootPart",
            AimMethod = "Visible",
            FOV = 1000,
        },
        Predication = {
            Enabled = false,
            Resolver = false,
            ResolverMethod = "HumanoidMoveDirection",

        }
    }
    Rage = {
        Misc = {
            AutoShoot = true,
            AutoReload = true,
        },
    }
    Visuals = {
        BulletTracers = {
            Enabled = true,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1,
        }
    }
}

local IsGun = function(tool)
    return tool:IsA("Tool")
end

local OnScreen = function(pos)
    local vector, onScreen = Camera:WorldToScreenPoint(pos)
    return onScreen
end

local InFov = function(target)
    local vector, onScreen = OnScreen(target.Position)
    if onScreen then
        local distance = (Vector2.new(vector.X, vector.Y) - Vector2.new(GetMouse.X, GetMouse.Y)).Magnitude
        return distance <= Settings.legit.SilentAim.FOV
    end
    return false
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

    for _, player in pairs(plrs:GetPlayers()) do
        if player ~= plr and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hitBone = player.Character[Settings.legit.SilentAim.HitBone]
            if hitBone then
                local targetPosition = hitBone.Position
                local directionToTarget = (targetPosition - playerPosition).unit
                local angleToTarget = math.acos(playerLookVector:Dot(directionToTarget))

                if angleToTarget <= math.rad(Settings.legit.SilentAim.FOV / 2) then
                    if angleToTarget < minAngle then
                        if Settings.legit.SilentAim.VisibleCheck == "Visible" then
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
            if Settings.SilentAim.Enabled then
                local target = GetClosestPlayer()
                if target then
                    if shootArgument then
                        MainEvent:FireServer(shootArgument, target.Character[Settings.SilentAim.HitBone].Position)
                    end
                end
            end
        end)
    end
end)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if typeof(args[2]) == "Vector3" then
        shootArgument = args[1]
    end

    return backupnamecall(self, ...)
end)
