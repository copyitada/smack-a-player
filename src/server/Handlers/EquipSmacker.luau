local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EquipSmacker = {}

function EquipSmacker.Equip(Player, SmackerName)
    local Values = Player:FindFirstChild("Values")
    if not Values then return end

    local Smacker = Values:FindFirstChild("SmackerName")
    if not Smacker then return end

    Smacker.Value = SmackerName
end

function OnServerEvent(Player, SmackerName)
    local Humanoid = Player.Character:FindFirstChild("Humanoid")
    if Humanoid then
        Humanoid.Health = 0
    end

    EquipSmacker.Equip(Player, SmackerName)
end

function EquipSmacker.Init()
    ReplicatedStorage.Remotes.ChangeSmacker.OnServerEvent:Connect(OnServerEvent)
end

return EquipSmacker