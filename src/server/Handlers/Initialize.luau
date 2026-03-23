workspace.AnimationRigs:Destroy()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")
local CombatServiceServer = require(ServerScriptService.Server.Services.CombatService.CombatServiceServer)
local EffectServiceServer = require(ServerScriptService.Server.Services.EffectService.EffectServiceServer)
local RoundServiceServer = require(ServerScriptService.Server.Services.RoundService.RoundServiceServer)
local ToolServiceServer = require(ServerScriptService.Server.Services.ToolService.ToolServiceServer)
local DistributeTool = {}
local Networker = require(ReplicatedStorage.Packages.Networker)
local ToolDebounces = {}

local RawValues = ServerStorage:FindFirstChild("Values")

local function PlayerAdded(Player : Player)
    for _, Value in RawValues:GetChildren() do
        local Clone = Value:Clone()
        Clone.Parent = Player
    end

    local Values = Player:WaitForChild("Values")
    local SmackerName : StringValue = Values:WaitForChild("SmackerName")

    Player.Team = Teams.Lobby

    Player.CharacterAdded:Connect(function(Character)
        task.wait()

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
    local Success, _Humanoid = ToolServiceServer.CheckEligibility(Player)

    if not Success then return end

    local CanBlock = CombatServiceServer.Parry(Player)
    return CanBlock
end

function DistributeTool:SpecialAttack(Player)
    local Success, Humanoid = ToolServiceServer.CheckEligibility(Player)

    if not Success then return end
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

    task.spawn(function()
        while true do
            RoundServiceServer.Start()
        end
    end)
end

return DistributeTool