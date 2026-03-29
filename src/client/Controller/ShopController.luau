local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShopServiceClient = require(ReplicatedStorage.Shared.Services.ShopService.ShopServiceClient)
local Smackers = require(ReplicatedStorage.Shared.Smackers)

local Player = Players.LocalPlayer
local Interface : Frame = ShopServiceClient.GetInterface(Player)

local ShopController = {}

function ShopController.Init()
    for _, Smacker in Smackers do
        ShopServiceClient.DisplayButton(Player, Interface, Smacker.SmackerName)
    end
end

return ShopController