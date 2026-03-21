local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local Timer : IntValue = ReplicatedStorage.Value.Time
local Caption : StringValue = ReplicatedStorage.Value.Caption

local DestroyType = require(ReplicatedStorage.Shared.Utilities.DestroyType)

local Podium = workspace.SpawnLocations.Lobby.Podium
local PodiumCharacters = {
    Podium.One,
    Podium.Two,
    Podium.Three
}

local REQUIRED_PLAYERS = RunService:IsStudio() and 1 or 2
local INTERMISSION_TIMER = RunService:IsStudio() and 5 or 30
local ROUND_DURATION = RunService:IsStudio() and 15 or 150

local FirstIteration = true
local RoundSystem = {}

local function PlayerAdded(Player : Player)
    local PlayingTeam : Team = Teams.Playing
    if #PlayingTeam:GetPlayers() > 0 then
        Player.Team = Teams.Playing
    else
        Player.Team = Teams.Lobby
    end
end

local function ActionToAllPlayers(func)
    for _, Player in Players:GetPlayers() do
        func(Player)
    end
end

Players.PlayerAdded:Connect(PlayerAdded)

local function CheckPlayers()
    if #Players:GetPlayers() < REQUIRED_PLAYERS then
        Caption.Value = "Looks like we don't have enough players!? We need someone to join to start the game!"
        repeat task.wait(1)
            Timer.Value += 1
        until #Players:GetPlayers() >= REQUIRED_PLAYERS
    end
end

local function DisplayWinners()
    local PlayerSmackerStats = {}

    ActionToAllPlayers(function(Player : Player)
        Player.Team = Teams.Lobby
        Player:LoadCharacterAsync()

        local Values = Player:FindFirstChild("Values")
        local RoundStats = Values:FindFirstChild("RoundStats")

        if RoundStats then
            table.insert(PlayerSmackerStats, {key = Player, value = RoundStats.Smacks.Value})
        end
    end)

    table.sort(PlayerSmackerStats, function(a, b)
        return a.value > b.value
    end)

    print(PlayerSmackerStats)

    for i = 1, 3 do
        local CurrentItem = PlayerSmackerStats[i]
        if CurrentItem then
            local Humanoid : Humanoid = PodiumCharacters[i].Humanoid
            if not Humanoid then continue end

            if CurrentItem.key and CurrentItem.key:IsA("Player") then
                local NewRig = Players:CreateHumanoidModelFromUserIdAsync(CurrentItem.key.UserId)
                NewRig.Name = if i == 1 then "One" elseif i == 2 then "Two" else "Three"

                NewRig.Parent = PodiumCharacters[i].Parent
                NewRig:PivotTo(PodiumCharacters[i]:GetPivot())

                NewRig.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

                DestroyType("LocalScript", Humanoid.Parent)

                local Animate = ServerStorage.Animate:Clone()
                Animate.Parent = NewRig
                Animate.Disabled = false

                DestroyType("BillboardGui", Humanoid.Parent, true)

                local BillboardGui = ServerStorage.SmacksCount:Clone()
                BillboardGui.Parent = NewRig.Head
                BillboardGui.Adornee = NewRig.Head

                BillboardGui.TextLabel.Text = CurrentItem.value .. " Smacks"

                PodiumCharacters[i]:Destroy()
                PodiumCharacters[i] = NewRig
                
                --[[
                DestroyType("Shirt", Humanoid.Parent)
                DestroyType("Accessory", Humanoid.Parent)
                DestroyType("Body Colors", Humanoid.Parent)

                for _, Object in Humanoid.Parent:GetDescendants() do
                    if not Object:IsA("BillboardGui") then continue end

                    Object.TextLabel.Text = "?"
                end

                local BodyColors = ServerStorage["Body Colors"]:Clone()
                BodyColors.Parent = Humanoid.Parent
                ]]
            end
        end
    end
end

local function Initialize()
    if not FirstIteration then
        DisplayWinners() 
    end

    CheckPlayers()

    Caption.Value = "Intermission..."
    for i = INTERMISSION_TIMER, 0, -1 do
        task.wait(1)

        CheckPlayers()
        Timer.Value = i
    end

    Caption.Value = "..."

    for _, Object in workspace.StreamParts:GetChildren() do
        Object:Destroy()
    end

    local Maps = ServerStorage.Maps:GetChildren()
    local Map = Maps[math.random(1, #Maps)]:Clone()
    Map.Parent = workspace.StreamParts

    task.wait(1)

    ActionToAllPlayers(function(Player : Player)
        Player.Team = Teams.Playing
        Player:LoadCharacterAsync()

        local Values = Player:FindFirstChild("Values")
        local RoundStats = Values:FindFirstChild("RoundStats")

        if RoundStats then
            RoundStats.Smacks.Value = 0
            RoundStats.Deaths.Value = 0
        end

        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.WalkSpeed = 0
        end

        local Stunned = Instance.new("BoolValue")
        Stunned.Parent = Character
        Stunned.Name = "Stunned"

        Debris:AddItem(Stunned, 2)
    end)

    task.wait(2)

    Caption.Value = "Game ends in:"
    for i = ROUND_DURATION * 10, 1, -1 do
        task.wait(.1)
        Timer.Value = i/10
    end

    ActionToAllPlayers(function(Player : Player)
        local Character = Player.Character
        local RootPart = Character.PrimaryPart
        RootPart.Anchored = true

        local Stunned = Instance.new("BoolValue")
        Stunned.Parent = Character
        Stunned.Name = "Stunned"

        Debris:AddItem(Stunned, 5)
        ReplicatedStorage.Remotes.PlaySound:FireClient(Player, ReplicatedStorage["victory.wav"])
    end)

    Caption.Value = "Game ended!"
    for i = 5, 0, -1 do
        task.wait(1)
        Timer.Value = i
    end

    FirstIteration = false
end

function RoundSystem.Init()
    while true do
        Initialize()
    end
end

return RoundSystem