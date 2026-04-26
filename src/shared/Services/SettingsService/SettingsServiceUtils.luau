local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local SettingsServiceUtils = {}

local Player = Players.LocalPlayer

-- local SettingsRemote = Networker.client.new("Settings", SettingsServiceUtils)

local TimeTweening = {}
local PreviousCameraCFrame = workspace.CurrentCamera.CFrame

RunService.Heartbeat:Connect(function()
	if not Player then return end
	if not Player.Values:FindFirstChild("Settings") then return end

    if Player.Values.Settings:FindFirstChild("Motion Blur") and Player.Values.Settings["Motion Blur"].Value then
        local Distance = (workspace.CurrentCamera.CFrame.Position - PreviousCameraCFrame.Position).Magnitude
        if Distance > 1 then
            Lighting.Blur.Size = Distance * 5
        else
            Lighting.Blur.Size = 0
        end
    end
    
	if not TimeTweening[Player] and Player.Values.Settings:FindFirstChild("Night Mode") and Player.Values.Settings["Night Mode"].Value then
		Lighting.ClockTime = 0
	elseif not TimeTweening[Player] then
		Lighting.ClockTime = 14.5
	end

	PreviousCameraCFrame = workspace.CurrentCamera.CFrame
end)

SettingsServiceUtils.Settings = {
	{
		Name = "Lighting",
		Options = {
			{
				Name = "Global Shadows",
				Description = "Toggles GlobalShadows",
				Default = true,
				Function = {
					On = function()
						Lighting.GlobalShadows = true
					end,
					Off = function()
						Lighting.GlobalShadows = false
					end,
				},
			},
			{
				Name = "Night Mode",
				Description = "Sets ClockTime to 0",
				Function = {
					On = function()
						TimeTweening[Player] = true

						TweenService:Create(Lighting, TweenInfo.new(0.2), {
							ClockTime = 0,
						}):Play()

						task.wait(0.2)
						TimeTweening[Player] = nil
					end,
					Off = function()
						TimeTweening[Player] = true

						TweenService:Create(Lighting, TweenInfo.new(0.2), {
							ClockTime = 14.5,
						}):Play()

						task.wait(0.2)
						TimeTweening[Player] = nil
					end,
				},
			},
		},
	},
	{
		Name = "Visual",
		Options = {
			{
				Name = "Camera Shake",
				Description = "Removes camera shake when you smack or get smacked",
				Default = true,
				Function = {
					On = function()
						
					end,
					Off = function()
						
					end,
				},
			},
			{
				Name = "Attack Hitboxes",
				Description = "Shows hitboxes when you smack, only shows for a default smack",
				Function = {
					On = function()
						
					end,
					Off = function()
						
					end,
				},
			},
			{
				Name = "Motion Blur",
				Description = "Adds blur when travelling in high speeds",
				Function = {
					On = function()
						
					end,
					Off = function()
						
					end,
				},
			},
		},
	},
	{
		Name = "Audio",
		Options = {
			{
				Name = "Master Volume",
				Description = "Reduce or increase the volume of everything",
				Function = {
					Minimum = 0,
					Maximum = 200,
					Default = 100,
					Slide = function(Value)
						SoundService.Master.Volume = Value / 100
					end,
				},
			},
			{
				Name = "Music Volume",
				Description = "Reduce or increase the volume of the Music",
				Function = {
					Minimum = 0,
					Maximum = 200,
					Default = 100,
					Slide = function(Value)
						SoundService.Master.Music.Volume = Value / 100
					end,
				},
			},
			{
				Name = "SFX Volume",
				Description = "Reduce or increase the volume of sound effects.",
				Function = {
					Minimum = 0,
					Maximum = 200,
					Default = 100,
					Slide = function(Value)
						SoundService.Master.SFX.Volume = Value / 100
					end,
				},
			},
		},
	},
	{
		Name = "Misc",
		Options = {
			{
				Name = "AFK Mode",
				Description = "If enabled, you will not be playing in rounds.",
				Function = {
					On = function()
						ReplicatedStorage.Remotes.ToggleAFK:FireServer(true)
					end,
					Off = function()
						ReplicatedStorage.Remotes.ToggleAFK:FireServer(false)
					end,
				},
			},
		},
	},
}

return SettingsServiceUtils
