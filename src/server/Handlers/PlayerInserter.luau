local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local PlayerInserter = {}

local Values = ServerStorage:FindFirstChild("Values")

local function PlayerAdded(Player : Player)
    for _, Value in Values:GetChildren() do
        local Clone = Value:Clone()
        Clone.Parent = Player
    end
end

function PlayerInserter.Init()
    Players.PlayerAdded:Connect(PlayerAdded)

    for _, Player in Players:GetPlayers() do
        PlayerAdded(Player)
    end
end

return PlayerInserter