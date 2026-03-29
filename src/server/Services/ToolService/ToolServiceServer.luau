local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ToolServiceUtils = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils)
local DataManager = require(ServerScriptService.Server.Modules.DataManager)
local CombatServiceServer = require(ServerScriptService.Server.Services.CombatService.CombatServiceServer)
local KnockbackServiceServer = require(ServerScriptService.Server.Services.KnockbackService.KnockbackServiceServer)
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)

local SwingSound = ServerStorage:FindFirstChild("swing")

local ToolDebounces = {}

local ToolService = {}

function ToolService.InitializeSmacker(Player : Player, Tool)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")
    local Animator : Animator = Humanoid:FindFirstChild("Animator")

    local Values = Player:FindFirstChild("Values")
    local Smacks = Values.RoundStats:FindFirstChild("Smacks")

    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    local SmackAnimation : Animation = Instance.new("Animation")
    SmackAnimation.Name = "SmackAnimation"
    SmackAnimation.Parent = Tool
    SmackAnimation.AnimationId = "rbxassetid://136511099213466"

    local AnimTrack = Animator:LoadAnimation(SmackAnimation)
    local TouchConnection

    local SmackerInformation = ToolServiceUtils.GetInformation(Player)

    Tool.Activated:Connect(function()
        if not ToolService.CheckEligibility(Player) then return end

        for _, Trail in Tool:GetDescendants() do
            if Trail:IsA("Trail") then
                Trail.Transparency = NumberSequence.new(.7, .7)
            end
        end

        Tool.EvadeTaxes.CanCollide = false
        task.delay(.5, function()
            Tool.EvadeTaxes.CanCollide = true
        end)   

        local HumanoidDebounce = {}

        if ToolDebounces[Humanoid] then return end
        ToolDebounces[Humanoid] = true

        TouchConnection = PrimaryPart.Touched:Connect(function(Hit)
            local VictimHumanoid = Hit.Parent:FindFirstChild("Humanoid")
            if not VictimHumanoid then return end

            local VictimCharacter = VictimHumanoid.Parent
            if VictimCharacter.Name == Character.Name then return end

            local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)

            if HumanoidDebounce[VictimHumanoid] then warn("------------ " .. VictimCharacter.Name .. " already hit! ---------------")
                return
            end
            HumanoidDebounce[VictimHumanoid] = true

            local Blocking = VictimCharacter:FindFirstChild("Blocking")
            
            if Blocking then
                CombatServiceServer.Parried(Player, Hit, AnimTrack)

                TouchConnection:Disconnect()
                return
            end
            
            ReplicatedStorage.Remotes.ShakeOnce:FireClient(Player, 5, 10, .1, .4)

            VictimCharacter.RagdollTrigger.Value = true
            VictimHumanoid:TakeDamage(SmackerInformation.Smack.Damage)

            Smacks.Value += 1
            DataManager.AddSmacks(Player)

            if VictimPlayer then
                local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
                PlayerValues.Attacker.Value = Player.Name
            end

            local Pivot : CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame

            local KnockbackSpeed = SmackerInformation.Smack.KnockbackSpeed
            local KnockbackUp = SmackerInformation.Smack.KnockbackUp
            KnockbackServiceServer.Apply(VictimCharacter:FindFirstChild("HumanoidRootPart"), Pivot, KnockbackSpeed, KnockbackUp)

            task.delay(1.5, function()
                VictimCharacter.RagdollTrigger.Value = false
            end)
        end)

        local SwingCloneSound : Sound = SwingSound:Clone()
        SwingCloneSound.Parent = Character:FindFirstChild("HumanoidRootPart")
        SwingCloneSound:Play()

        AnimTrack:Play()
        AnimTrack.Ended:Wait()

        TouchConnection:Disconnect()
        for _, Trail in PrimaryPart:GetChildren() do
            if Trail:IsA("Trail") then
                Trail.Lifetime = .1
            end
        end

        task.wait(.1)
        for _, Trail in PrimaryPart:GetChildren() do
            if Trail:IsA("Trail") then
                Trail.Transparency = NumberSequence.new(1, 1)
            end
        end

        ToolDebounces[Humanoid] = nil
    end)
end

function ToolService.EquipSmacker(Player, SmackerName)
    local Values = Player:FindFirstChild("Values")
    if not Values then return end

    local Smacker = Values:FindFirstChild("SmackerName")
    if not Smacker then return end

    DataManager.SetSmacker(Player, SmackerName)

    Smacker.Value = SmackerName
end

function ToolService.CheckEligibility(Player : Player)
    local Character = Player.Character
    if not Character then return end

    if Character:FindFirstChild("Stunned") then return end
    if Character:FindFirstChild("Blocking") then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    if Humanoid.Health <= 0 then return end

    if not ToolServiceUtils.IsHoldingTool(Character) then return end

    return true, Humanoid
end

function ToolService.IsHoldingTool(Character)
    for _, Object in Character:GetChildren() do
        if Object:IsA("Tool") then return true, Object end
    end

    return false, nil
end

return ToolService