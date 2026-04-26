local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CameraShaker = require(ReplicatedStorage.Packages.CameraShaker)
local Networker = require(ReplicatedStorage.Packages.Networker)
local NetworkerController = {}

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local _FX = PlayerGui:FindFirstChild("FX")

local Camera = workspace.CurrentCamera
local RenderPriority = Enum.RenderPriority.Camera.Value + 1

local function ShakeCamera(ShakeCFrame)
    Camera.CFrame = Camera.CFrame * ShakeCFrame
end

local CameraShake = CameraShaker.new(RenderPriority, ShakeCamera)
CameraShake:Start()

function NetworkerController.Init()
    ReplicatedStorage.Remotes.ShakeOnce.OnClientEvent:Connect(function(magnitude, roughness, fadeInTime, fadeOutTime, posInfluence, rotInfluence)
        if not Player.Values.Settings["Camera Shake"].Value then return end
        CameraShake:ShakeOnce(magnitude, roughness, fadeInTime, fadeOutTime, posInfluence, rotInfluence)
    end)

    ReplicatedStorage.Remotes.ParriedEffect.OnClientEvent:Connect(function()
        local ColorCorrection : ColorCorrectionEffect = Lighting:FindFirstChild("ColorCorrection")
        ColorCorrection.TintColor = Color3.fromRGB(255,100,0)

        TweenService:Create(ColorCorrection, TweenInfo.new(1), { TintColor = Color3.fromRGB(255, 255, 255) }):Play()
    end)

    ReplicatedStorage.Remotes.PlaySound.OnClientEvent:Connect(function(Sound : Sound)
        local SoundClone = Sound:Clone()
        SoundClone.Parent = ReplicatedStorage

        SoundClone:Play()
        Debris:AddItem(SoundClone, SoundClone.TimeLength + .1)
    end)

    ReplicatedStorage.Remotes.Blink.OnClientEvent:Connect(function()
        local ColorCorrection : ColorCorrectionEffect = game.Lighting.ColorCorrection
        ColorCorrection.TintColor = Color3.fromRGB(0,0,0)

        task.wait(.1)

        ColorCorrection.TintColor = Color3.fromRGB(255,0,0)
        ColorCorrection.Brightness = -.5

        task.wait(.05)

        ColorCorrection.TintColor = Color3.fromRGB(255,255,255)
        ColorCorrection.Brightness = 0
    end)

    Networker.client.new("ToolInputs", NetworkerController)
end

return NetworkerController