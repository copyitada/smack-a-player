local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SettingsServiceClient = require(ReplicatedStorage.Shared.Services.SettingsService.SettingsServiceClient)
local SettingsServiceUtils = require(ReplicatedStorage.Shared.Services.SettingsService.SettingsServiceUtils)
local SettingsController = {}

local Player = Players.LocalPlayer
local Interface = SettingsServiceClient.GetInterface(Player)

function SettingsController.Init()
    for _, Title in SettingsServiceUtils.Settings do
        SettingsServiceClient.AddTitle(Interface, Title.Name)
        for _, Option in Title.Options do
            SettingsServiceClient.AddOption(Interface, Option, Player)
        end
    end
end

return SettingsController