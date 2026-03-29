local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ToolServiceUtils = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils)
local DataManager = require(ServerScriptService.Server.Modules.DataManager)
local ShopServiceServer = {}

function ShopServiceServer.UnlockSmacker(Player, SmackerName)
    local Smacks = DataManager.GetSmacks(Player)
    if not Smacks then return end

    local SmackerInformation = ToolServiceUtils.GetInformation(nil, SmackerName)
    
    if Smacks >= SmackerInformation.Shop.Price then
        DataManager.UnlockSmacker(Player, SmackerName)
        return true
    else
        return false
    end
end

function ShopServiceServer.HasUnlockedSmacker(Player, SmackerName) : boolean
    local UnlockedSmackers = DataManager.GetUnlockedSmackers(Player)
    if not UnlockedSmackers then return false end

    if table.find(UnlockedSmackers, SmackerName) then
        return true
    else
        return false
    end
end

return ShopServiceServer