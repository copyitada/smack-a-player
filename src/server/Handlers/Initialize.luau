workspace.AnimationRigs:Destroy()

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")
local CombatServiceServer = require(ServerScriptService.Server.Services.CombatService.CombatServiceServer)
local EffectServiceServer = require(ServerScriptService.Server.Services.EffectService.EffectServiceServer)
local PurchaseService = require(ServerScriptService.Server.Services.PurchaseService.PurchaseService)
local RoundServiceServer = require(ServerScriptService.Server.Services.RoundService.RoundServiceServer)
local ShopServiceServer = require(ServerScriptService.Server.Services.ShopService.ShopServiceServer)
local ToolServiceServer = require(ServerScriptService.Server.Services.ToolService.ToolServiceServer)
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)
local Initialize = {}
local Networker = require(ReplicatedStorage.Packages.Networker)
local ShopServiceClient = require(ReplicatedStorage.Shared.Services.ShopService.ShopServiceClient)
local ToolServiceUtils = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils)
local ToolDebounces = {}
local DeathDebounce = {}

local RawValues = ServerStorage:FindFirstChild("Values")

local function PlayerAdded(Player : Player)
    for _, Value in RawValues:GetChildren() do
        local Clone = Value:Clone()
        Clone.Parent = Player
    end

    local Values = Player:WaitForChild("Values")
    local Attacker : StringValue = Values:WaitForChild("Attacker")
    local SmackerName : StringValue = Values:WaitForChild("SmackerName")

    Player.Team = Teams.Lobby

    Player.CharacterAdded:Connect(function(Character)
        task.wait()
        Attacker.Value = ""

        if not RunService:IsStudio() and Player.Team.Name == "Lobby" then return end
        local SmackerInstance = ServerStorage.Smackers:FindFirstChild(SmackerName.Value)

        local Humanoid : Humanoid = Character:WaitForChild("Humanoid")

        local SmackerTool
        if SmackerInstance then
            SmackerTool = SmackerInstance:Clone()
            SmackerTool.Parent = Character

            if Humanoid then
                Humanoid:EquipTool(SmackerTool)
            end
        end

        if Humanoid then
            Humanoid.Died:Connect(function()
                local AttackerPlayer
                local AttackerValues

                for _, IterationPlayer in Players:GetPlayers() do
                    if IterationPlayer.Name ~= Attacker.Value then continue end
                    AttackerPlayer = IterationPlayer
                end

                if not AttackerPlayer then
                    AttackerPlayer = Player
                end

                AttackerValues = ValueServiceServer.GetValues(AttackerPlayer)
                if not AttackerValues then return end

                local AttackerRoundStats = AttackerValues:FindFirstChild("RoundStats")
                if not AttackerRoundStats then return end

                local AttackerKills = AttackerRoundStats:FindFirstChild("Kills")
                if not AttackerKills then return end

                if DeathDebounce[Player] then return end

                DeathDebounce[Player] = true
                task.delay(2.5, function()
                    DeathDebounce[Player] = nil
                end)

                if AttackerPlayer.Team == Teams.Playing and Player.Team == Teams.Playing then
                    ReplicatedStorage.Remotes.ShowKilled:FireAllClients(AttackerPlayer, Player)
                end

                if AttackerPlayer ~= Player then
                    AttackerKills.Value += 1
                end
            end)
            
            if SmackerTool and SmackerTool.Name == "Whip" then
                for _, Segment in SmackerTool.Segment:GetChildren() do
                    Segment.CFrame = Character:GetPivot()

                    Segment.Massless = true
                    Segment.CustomPhysicalProperties = PhysicalProperties.new(
                        .5,
                        .8,
                        .1,
                        0,
                        0
                    )
                end
                for _, RopeConstraint in SmackerTool:GetDescendants() do
                    if not RopeConstraint:IsA("RopeConstraint") then continue end

                    RopeConstraint.Enabled = true
                end
            end
        end

        ToolServiceServer.InitializeSmacker(Player, SmackerTool)
    end)
end

function OnServerInvoke(Player : Player, SmackerName)
    if Player.Team.Name == "Playing" then return false end

    ToolServiceServer.EquipSmacker(Player, SmackerName)
    return true
end

function OnServerEvent(Player : Player, Enable)
    if Player.Team.Name == "Playing" then return end

    local Values = ValueServiceServer.GetValues(Player)
    Values.AFK.Value = Enable or not Values.AFK.Value
end

function Initialize:Block(Player : Player)
    local Success, _Humanoid = ToolServiceServer.CheckEligibility(Player)

    if not Success then return end

    local CanBlock = CombatServiceServer.Parry(Player)
    return CanBlock
end

function Initialize:UpdatePosition(Player : Player, CFrame)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    if not Character then return end

    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end

    if (HumanoidRootPart.Position - CFrame.Posiiton).Magnitude > 10 then return end

    
end

function Initialize:SpecialAttack(Player)
    local Success, Humanoid = ToolServiceServer.CheckEligibility(Player)

    if not Success then return end
    if ToolDebounces[Humanoid] then return end

    local SmackerName = Player:FindFirstChild("Values"):FindFirstChild("SmackerName")
    if not ReplicatedStorage.Shared.SmackersFunctions:FindFirstChild(SmackerName.Value) then return end 

    local Result = require(ReplicatedStorage.Shared.SmackersFunctions[SmackerName.Value]).AttackFunction(Player)
    return Result
end

function Initialize:Information(Player)
    return ToolServiceUtils.GetInformation(Player)
end

function Initialize:Sparkle(Player : Player, Color : Color3)
    EffectServiceServer.Sparkle(Player, Color)
end

function Initialize:DisplayItem(Player : Player, SmackerName)
    local Tool : Tool = ServerStorage.Smackers:FindFirstChild(SmackerName)
    if not Tool then return end

    local PlayerGui = Player.PlayerGui
    local Shop = PlayerGui.Shop
    local MainFrame = Shop.MainFrame
    local Description = MainFrame.Description
    local ViewportFrame = Description.ViewportFrame

    ShopServiceClient.DisplayItem(ViewportFrame, Tool)
end

function Initialize:UnlockSmacker(Player : Player, SmackerName)
    return ShopServiceServer.UnlockSmacker(Player, SmackerName)
end

function Initialize:HasUnlockedSmacker(Player : Player, SmackerName)
    return ShopServiceServer.HasUnlockedSmacker(Player, SmackerName)
end

function Initialize.Init()
    ReplicatedStorage.Remotes.ChangeSmacker.OnServerInvoke = OnServerInvoke
    ReplicatedStorage.Remotes.ToggleAFK.OnServerEvent:Connect(OnServerEvent)
    Players.PlayerAdded:Connect(PlayerAdded)

    MarketplaceService.ProcessReceipt = PurchaseService.ProcessReceipt

    Networker.server.new("ToolInputs", Initialize, {
        Initialize.Block,
        Initialize.SpecialAttack,
        Initialize.Information,
        Initialize.Sparkle
    })

    Networker.server.new("Shop", Initialize, {
        Initialize.DisplayItem,
        Initialize.UnlockSmacker,
        Initialize.HasUnlockedSmacker
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

return Initialize