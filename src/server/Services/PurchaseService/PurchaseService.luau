local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.Server.Modules.DataManager)

local ProductFunction = {}
local PurchaseService = {}

ProductFunction[3570432394] = function(_ReceiptInfo, Player : Player)
    DataManager.AddSmacks(Player, 2500)
end

ProductFunction[3570431984] = function(_ReceiptInfo, Player : Player)
    DataManager.AddSmacks(Player, 1000)
end

ProductFunction[3570432152] = function(_ReceiptInfo, Player : Player)
    DataManager.AddSmacks(Player, 500)
end

ProductFunction[3570432062] = function(_ReceiptInfo, Player : Player)
    DataManager.AddSmacks(Player, 250)
end

ProductFunction[3570431984] = function(_ReceiptInfo, Player : Player)
    DataManager.AddSmacks(Player, 100)
end

ProductFunction[3570431870] = function(_ReceiptInfo, Player : Player)
    DataManager.AddSmacks(Player, 50)
end

function PurchaseService.ProcessReceipt(ReceiptInfo)
    local UserId = ReceiptInfo.PlayerId
    local ProductId = ReceiptInfo.ProductId

    local Player = Players:GetPlayerByUserId(UserId)
    if Player then
        local Handler = ProductFunction[ProductId]

        local Success, _Result = pcall(Handler, ReceiptInfo, Player)
        if Success then
            ReplicatedStorage.Remotes.Purchased:FireClient(Player)

            return Enum.ProductPurchaseDecision.PurchaseGranted
        else
            warn("Failed to make purchase:", ReceiptInfo)
        end
    end

    return Enum.ProductPurchaseDecision.NotProcessedYet
end

return PurchaseService