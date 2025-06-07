workspace.AnimationRigs:Destroy()

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local DataManager = require(ServerScriptService.Server.Modules.DataManager)
local DistributeTool = {}

local Networker = require(ReplicatedStorage.Packages.Networker)
local Smackers = require(ReplicatedStorage.Shared.Smackers)
local ToolDebounces = {}

local PunchEffect = ServerStorage:FindFirstChild("HitFX").Punch
local SmackSound = ServerStorage:FindFirstChild("snap.wav")
local SwingSound = ServerStorage:FindFirstChild("swing")

local function RootPartAction(RootPart, CFrame : CFrame, Velocity : Vector3?)
    local Vel = Velocity or Vector3.new(50, 0, 0)

    local LinearVelocity = Instance.new("LinearVelocity")
    LinearVelocity.Parent = RootPart
    LinearVelocity.Attachment0 = RootPart:FindFirstChild("RootAttachment")
    LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    LinearVelocity.MaxForce = math.huge
    LinearVelocity.VectorVelocity = CFrame.RightVector * Vel.X + CFrame.UpVector * Vel.Y + CFrame.LookVector * Vel.Z

    local EffectClone : Attachment = PunchEffect:Clone()
    EffectClone.Parent = RootPart
    EffectClone.WorldCFrame = RootPart.CFrame

    for _, Particle in EffectClone:GetChildren() do
        task.spawn(function()
            Particle:Emit(Particle:GetAttribute("EmitCount"))
        end)
    end

    local CloneSound : Sound = SmackSound:Clone()
    CloneSound.Parent = RootPart
    CloneSound:Play()

    Debris:AddItem(CloneSound, 1)
    Debris:AddItem(EffectClone, 1)
    Debris:AddItem(LinearVelocity, 0.2)
end

local function InitializeSmacker(Player : Player, Tool : Tool)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:FindFirstChild("Humanoid")
    local Animator : Animator = Humanoid:FindFirstChild("Animator")

    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    local SmackAnimation : Animation = Instance.new("Animation")
    SmackAnimation.Name = "SmackAnimation"
    SmackAnimation.Parent = Tool
    SmackAnimation.AnimationId = "rbxassetid://83279013883666"

    local AnimTrack = Animator:LoadAnimation(SmackAnimation)
    local TouchConnection

    Tool.Activated:Connect(function()
        for _, Trail in PrimaryPart:GetChildren() do
            if Trail:IsA("Trail") then
                Trail.Transparency = NumberSequence.new(.7, .7)
            end
        end

        local HumanoidDebounce = {}

        if ToolDebounces[Humanoid] then return end
        ToolDebounces[Humanoid] = true

        TouchConnection = PrimaryPart.Touched:Connect(function(Hit)
            local VictimHumanoid = Hit.Parent:FindFirstChild("Humanoid")
            if not VictimHumanoid then return end

            local VictimCharacter = VictimHumanoid.Parent
            if VictimCharacter.Name == Character.Name then return end

            if HumanoidDebounce[VictimHumanoid] then warn("------------ " .. VictimCharacter.Name .. " already hit! ---------------")
                return
            end

            local VictimToPlayer = (VictimCharacter:GetPivot().Position - Character:GetPivot().Position).Unit
            local DotProduct = VictimToPlayer:Dot(VictimCharacter:GetPivot().LookVector)

            print(DotProduct)
            if DotProduct < 0 and VictimCharacter:FindFirstChild("Blocking") then return end

            HumanoidDebounce[VictimHumanoid] = true
            ReplicatedStorage.Remotes.ShakeOnce:FireClient(Player, 5, 10, .1, .4)

            VictimCharacter.RagdollTrigger.Value = true
            VictimHumanoid:TakeDamage(5)

            DataManager.AddSmacks(Player)

            local Pivot : CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame
            RootPartAction(VictimCharacter:FindFirstChild("HumanoidRootPart"), Pivot)

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

local function PlayerAdded(Player : Player)
    Player.CharacterAdded:Connect(function(Character)
        task.wait()
        local Values = Player:FindFirstChild("Values")
        local SmackerName = Values:FindFirstChild("SmackerName")

        local SmackerInstance = ServerStorage.Smackers:FindFirstChild(SmackerName.Value) or ServerStorage.Smackers.Default

        local SmackerTool = SmackerInstance:Clone()
        SmackerTool.Parent = Character

        if Character:FindFirstChild("Humanoid") then
            Character.Humanoid:EquipTool(SmackerTool)
        end

        InitializeSmacker(Player, SmackerTool)
    end)
end

local function IsHoldingTool(Character)
    for _, Object in Character:GetChildren() do
        if Object:IsA("Tool") then return true, Object end
    end

    return false
end

function DistributeTool:Block(Player : Player, Block : boolean)
    local Character = Player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    if Humanoid.Health <= 0 then return end

    if not IsHoldingTool(Character) then return end

    if ToolDebounces[Humanoid] then return end

    if not Block then
        local LoadedAnimations = Humanoid.Animator:GetPlayingAnimationTracks()
        for _, Animation in LoadedAnimations do
            if Animation.Name == "Block" then
                Animation:Stop()
            end
        end

        if Character:FindFirstChild("Blocking") then
            Character.Blocking:Destroy()
        end
    else
        local Animation : Animation = Instance.new("Animation")
        Animation.AnimationId = "rbxassetid://130825021567561"
        Animation.Name = "Block"

        local BlockAnimation = Humanoid.Animator:LoadAnimation(Animation)
        BlockAnimation:Play()

        local Blocking = Instance.new("BoolValue")
        Blocking.Name = "Blocking"
        Blocking.Parent = Character
    end
end

function DistributeTool:SpecialAttack(Player)
    local Character = Player.Character
    if not Character then return end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return end
    if Humanoid.Health <= 0 then return end

    if not IsHoldingTool(Character) then return end
    if ToolDebounces[Humanoid] then return end

    local SmackerName = Player:FindFirstChild("Values"):FindFirstChild("SmackerName")

    local Result = require(ReplicatedStorage.Shared.SmackersFunctions[SmackerName.Value]).AttackFunction(Player)
    return Result
end

function DistributeTool:Information(Player)
    local SmackerName = Player:FindFirstChild("Values"):FindFirstChild("SmackerName").Value or "Default"

    for _, SmackerInformation in Smackers do
        if SmackerInformation.SmackerName == SmackerName then
            return SmackerInformation
        end
    end

    return Smackers[1]
end

function DistributeTool.Init()
   Players.PlayerAdded:Connect(PlayerAdded)

   Networker.server.new("ToolInputs", DistributeTool, {
        DistributeTool.Block,
        DistributeTool.SpecialAttack,
        DistributeTool.Information
    })

   for _, Player in Players:GetPlayers() do
     PlayerAdded(Player)
   end
end

return DistributeTool