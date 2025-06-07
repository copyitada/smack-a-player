local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local Networker = require(ReplicatedStorage.Packages.Networker)
local NetworkerController = {}

local Camera = workspace.CurrentCamera
local RenderPriority = Enum.RenderPriority.Camera.Value + 1

local function ShakeCamera(ShakeCFrame)
    Camera.CFrame = Camera.CFrame * ShakeCFrame
end

local CameraShake = CameraShaker.new(RenderPriority, ShakeCamera)
CameraShake:Start()

function NetworkerController.Init()
    ReplicatedStorage.Remotes.ShakeOnce.OnClientEvent:Connect(function(magnitude, roughness, fadeInTime, fadeOutTime, posInfluence, rotInfluence)
        CameraShake:ShakeOnce(magnitude, roughness, fadeInTime, fadeOutTime, posInfluence, rotInfluence)
    end)

    Networker.client.new("ToolInputs", NetworkerController)
end

return NetworkerController