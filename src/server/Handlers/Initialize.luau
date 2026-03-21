workspace.AnimationRigs:Destroy()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local CombatServiceServer = require(ServerScriptService.Server.Services.CombatService.CombatServiceServer)
local EffectServiceServer = require(ServerScriptService.Server.Services.EffectService.EffectServiceServer)
local ToolServiceServer = require(ServerScriptService.Server.Services.ToolService.ToolServiceServer)
local DistributeTool = {}
local Networker = require(ReplicatedStorage.Packages.Networker)
local ToolServiceUtils = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils)
local ToolDebounces = {}

local RawValues = ServerStorage:FindFirstChild("Values")

local BlockDebounces = {}

local function PlayerAdded(Player : Player)
    for _, Value in RawValues:GetChildren() do
        local Clone = Value:Clone()
        Clone.Parent = Player
    end

    local Values = Player:WaitForChild("Values")
    local SmackerName : StringValue = Values:WaitForChild("SmackerName")

    Player.CharacterAdded:Connect(function(Character)
        task.wait()
        local ToolUI = Player.PlayerGui:FindFirstChild("ToolUI")
        for _, Frame in ToolUI.CooldownList:GetChildren() do
            Frame:Destroy()
        end

        if Player.Team.Name == "Lobby" then return end
        local SmackerInstance = ServerStorage.Smackers:FindFirstChild(SmackerName.Value) or ServerStorage.Smackers.Default

        local SmackerTool = SmackerInstance:Clone()
        SmackerTool.Parent = Character

        if Character:FindFirstChild("Humanoid") then
            Character.Humanoid:EquipTool(SmackerTool)
        end

        ToolServiceServer.InitializeSmacker(Player, SmackerTool)
    end)
end

function OnServerInvoke(Player : Player, SmackerName)
    if Player.Team.Name == "Playing" then return false end

    ToolServiceServer.EquipSmacker(Player, SmackerName)
    return true
end

function DistributeTool:Block(Player : Player)
    local Character = Player.Character
    if not Character then return end

    if Character:FindFirstChild("Stunned") then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    if Humanoid.Health <= 0 then return end

    if not ToolServiceUtils.IsHoldingTool(Character) then return end

    if BlockDebounces[Humanoid] then return end

    CombatServiceServer.Parry(Player)
    return true
end

function DistributeTool:SpecialAttack(Player)
    local Character = Player.Character
    if not Character then return end

    if Character:FindFirstChild("Stunned") then return end
    if Character:FindFirstChild("Blocking") then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    if Humanoid.Health <= 0 then return end

    if not ToolServiceUtils.IsHoldingTool(Character) then return end
    if ToolDebounces[Humanoid] then return end

    local SmackerName = Player:FindFirstChild("Values"):FindFirstChild("SmackerName")

    local Result = require(ReplicatedStorage.Shared.SmackersFunctions[SmackerName.Value]).AttackFunction(Player)
    return Result
end

function DistributeTool:Information(Player)
    return ToolServiceServer.GetInformation(Player)
end

function DistributeTool:Sparkle(Player : Player, Color : Color3)
    EffectServiceServer.Sparkle(Player, Color)
end

function DistributeTool.Init()
    ReplicatedStorage.Remotes.ChangeSmacker.OnServerInvoke = OnServerInvoke
    Players.PlayerAdded:Connect(PlayerAdded)

    Networker.server.new("ToolInputs", DistributeTool, {
        DistributeTool.Block,
        DistributeTool.SpecialAttack,
        DistributeTool.Information,
        DistributeTool.Sparkle
    })

    for _, Player in Players:GetPlayers() do
        PlayerAdded(Player)
    end
end

return DistributeTool