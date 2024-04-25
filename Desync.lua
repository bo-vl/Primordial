repeat wait() until game:IsLoaded()

local plr = game.Players.LocalPlayer

local Desync = {OldPos = nil, newPos = nil}

local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
    Desync["OldPos"] = plr.Character.HumanoidRootPart.CFrame

    Desync["newPos"] = CFrame.new(
        plr.Character.HumanoidRootPart.Position + Vector3.new(
            math.random(-180, 180),
            math.random(-180, 180),
            math.random(-180, 180)
        )
    ) * CFrame.Angles(
        math.rad(math.random(-180, 180)),
        math.rad(math.random(-180, 180)),
        math.rad(math.random(-180, 180))
    )

    plr.Character.HumanoidRootPart.CFrame = Desync["newPos"]

    RunService.RenderStepped:Wait()

    plr.Character.HumanoidRootPart.CFrame = Desync["OldPos"]
end)

local old
old = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and key == "CFrame" and self == plr.Character.HumanoidRootPart then
        return Desync["OldPos"]
    end
    return old(self, key)
end)
