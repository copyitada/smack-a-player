local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local CombatServiceServer = require(ServerScriptService.Server.Services.CombatService.CombatServiceServer)
local RoundServiceUtils = require(ReplicatedStorage.Shared.Services.RoundService.RoundServiceUtils)
local DestroyType = require(ReplicatedStorage.Shared.Utilities.DestroyType)
local RoundServiceServer = {}

local Timer : IntValue = ReplicatedStorage.Value.Time
local Caption : StringValue = ReplicatedStorage.Value.Caption

local Podium = workspace.SpawnLocations.Lobby.Podium
local PodiumKills = workspace.SpawnLocations.Lobby.KillsPodium

local PodiumSmackersCharacters = {
    Podium.One,
    Podium.Two,
    Podium.Three
}
local PodiumKillsCharacters = {
    PodiumKills.One,
    PodiumKills.Two,
    PodiumKills.Three
}

local Settings = RoundServiceUtils.Settings
local ROUND_DURATION = RunService:IsStudio() and Settings.ROUND_DURATION.STUDIO or Settings.ROUND_DURATION.PUBLIC
local INTERMISSION_TIMER = RunService:IsStudio() and Settings.INTERMISSION_TIMER.STUDIO or Settings.INTERMISSION_TIMER.PUBLIC

local FirstIteration = true

function RoundServiceServer.DisplayWinners()
    local PlayerSmackerStats = {}
    local PlayerKillsStats = {}

    RoundServiceUtils.ActionToAllPlayers(function(Player : Player)
        Player.Team = Teams.Lobby
        Player:LoadCharacterAsync()

        local Values = Player:FindFirstChild("Values")
        local RoundStats = Values:FindFirstChild("RoundStats")

        if RoundStats then
            table.insert(PlayerSmackerStats, {key = Player, value = RoundStats.Smacks.Value})
            table.insert(PlayerKillsStats, {key = Player, value = RoundStats.Kills.Value})
        end
    end)

    table.sort(PlayerSmackerStats, function(a, b)
        return a.value > b.value
    end)
    table.sort(PlayerKillsStats, function(a, b)
        return a.value > b.value
    end)

    for i = 1, 3 do
        local CurrentItem = PlayerSmackerStats[i]
        local CurrentItemKills = PlayerKillsStats[i]
        if CurrentItem and CurrentItemKills then
            local Humanoid : Humanoid = PodiumSmackersCharacters[i].Humanoid
            local HumanoidKills : Humanoid = PodiumKillsCharacters[i].Humanoid
            if not Humanoid or not HumanoidKills then continue end

            if CurrentItem.key and CurrentItem.key:IsA("Player") then
                local NewRig = Players:CreateHumanoidModelFromUserIdAsync(CurrentItem.key.UserId)
                NewRig.Name = if i == 1 then "One" elseif i == 2 then "Two" else "Three"

                NewRig.Parent = PodiumSmackersCharacters[i].Parent
                NewRig:PivotTo(PodiumSmackersCharacters[i]:GetPivot() + Vector3.new(0, 3, 0))

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

                PodiumSmackersCharacters[i]:Destroy()
                PodiumSmackersCharacters[i] = NewRig
            else
                local NewRig = ServerStorage.Placeholder:Clone()
                NewRig.Name = if i == 1 then "One" elseif i == 2 then "Two" else "Three"
                NewRig.Parent = PodiumSmackersCharacters[i].Parent

                NewRig:PivotTo(PodiumSmackersCharacters[i]:GetPivot() + Vector3.new(0, 3, 0))

                PodiumSmackersCharacters[i]:Destroy()
                PodiumSmackersCharacters[i] = NewRig
            end

            if CurrentItemKills.key and CurrentItemKills.key:IsA("Player") then
                local NewRig = Players:CreateHumanoidModelFromUserIdAsync(CurrentItemKills.key.UserId)
                NewRig.Name = if i == 1 then "One" elseif i == 2 then "Two" else "Three"

                NewRig.Parent = PodiumKillsCharacters[i].Parent
                NewRig:PivotTo(PodiumKillsCharacters[i]:GetPivot() + Vector3.new(0, 3, 0))

                NewRig.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

                DestroyType("LocalScript", HumanoidKills.Parent)

                local Animate = ServerStorage.Animate:Clone()
                Animate.Parent = NewRig
                Animate.Disabled = false

                DestroyType("BillboardGui", HumanoidKills.Parent, true)

                local BillboardGui = ServerStorage.SmacksCount:Clone()
                BillboardGui.Parent = NewRig.Head
                BillboardGui.Adornee = NewRig.Head

                BillboardGui.TextLabel.Text = CurrentItemKills.value .. " Kills"

                PodiumKillsCharacters[i]:Destroy()
                PodiumKillsCharacters[i] = NewRig
            else
                local NewRig = ServerStorage.Placeholder:Clone()
                NewRig.Name = if i == 1 then "One" elseif i == 2 then "Two" else "Three"
                NewRig.Parent = PodiumKillsCharacters[i].Parent

                NewRig:PivotTo(PodiumKillsCharacters[i]:GetPivot() + Vector3.new(0, 3, 0))

                PodiumKillsCharacters[i]:Destroy()
                PodiumKillsCharacters[i] = NewRig
            end
        end
    end
end

function RoundServiceServer.Start() 
    if not FirstIteration then
        RoundServiceServer.DisplayWinners() 
    end

    if not RoundServiceUtils.CheckPlayers() then
        repeat task.wait(1)
            Caption.Value = "Oof! One more person to start the game!"
            Timer.Value += 1
        until RoundServiceUtils.CheckPlayers()
    end

    Caption.Value = "Intermission..."

    for i = INTERMISSION_TIMER, 0, -1 do
        if not RoundServiceUtils.CheckPlayers() then return end

        task.wait(1)
        Timer.Value = i
    end

    if not RoundServiceUtils.CheckPlayers() then return end

    Caption.Value = "..."

    for _, Object in workspace.StreamParts:GetChildren() do
        Object:Destroy()
    end

    local Maps = ServerStorage.Maps:GetChildren()
    local Map = Maps[math.random(1, #Maps)]:Clone()
    Map.Parent = workspace.StreamParts

    task.wait(1)

    RoundServiceUtils.ActionToAllPlayers(function(Player : Player)
        Player.Team = Teams.Playing
        Player:LoadCharacterAsync()

        local Values = Player:FindFirstChild("Values")
        local RoundStats = Values:FindFirstChild("RoundStats")

        if RoundStats then
            RoundStats.Smacks.Value = 0
            RoundStats.Kills.Value = 0
        end

        local Character = Player.Character or Player.CharacterAdded:Wait()
        task.wait()

        local Humanoid = Character:FindFirstChild("Humanoid")

        if Humanoid then
            Humanoid.WalkSpeed = 0
        end

        CombatServiceServer.Stun(Character, 2)
    end)

    task.wait(2)

    Caption.Value = "Game ends in:"
    for i = ROUND_DURATION * 10, 1, -1 do
        if not RoundServiceUtils.CheckPlayers() then return end

        task.wait(.1)
        Timer.Value = i/10
    end

    if not RoundServiceUtils.CheckPlayers() then return end

    RoundServiceUtils.ActionToAllPlayers(function(Player : Player)
        local Character = Player.Character
        local RootPart = Character.PrimaryPart
        RootPart.Anchored = true

        CombatServiceServer.Stun(Character, 5)
        ReplicatedStorage.Remotes.PlaySound:FireClient(Player, ReplicatedStorage["victory.wav"])
    end)

    Caption.Value = "Game ended!"
    for i = 5, 0, -1 do
        task.wait(1)
        Timer.Value = i
    end

    FirstIteration = false
end

return RoundServiceServer