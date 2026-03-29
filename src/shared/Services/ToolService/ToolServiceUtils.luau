local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Smackers = require(ReplicatedStorage.Shared.Smackers)
local ToolService = {}

function ToolService.IsHoldingTool(Character)
    for _, Object in Character:GetChildren() do
        if Object:IsA("Tool") then return true, Object end
    end

    return false, nil
end

function ToolService.GetInformation(Player, SelectedSmackerName : string?)
    local SmackerName = "Default"

    if not SelectedSmackerName then
        SmackerName = Player:FindFirstChild("Values"):FindFirstChild("SmackerName").Value or "Default"
    else
        SmackerName = SelectedSmackerName
    end

    for _, SmackerInformation in Smackers do
        if SmackerInformation.SmackerName == SmackerName then
            return SmackerInformation
        end
    end

    return Smackers[1]
end

return ToolService