local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)

local PunchEffect = ServerStorage:FindFirstChild("HitFX").Punch
local SwingSound = ServerStorage:FindFirstChild("dash")
local ExplodeSound = ServerStorage:FindFirstChild("explode")

local SpecialAttackDebounces = {}
local Landmine = {}

local function RootPartAction(RootPart)
    local EffectClone : Attachment = PunchEffect:Clone()
    EffectClone.Parent = RootPart
    EffectClone.WorldCFrame = RootPart.CFrame

    for _, Particle in EffectClone:GetChildren() do
        task.spawn(function()
            Particle:Emit(Particle:GetAttribute("EmitCount"))
        end)
    end

    Debris:AddItem(EffectClone, 1)
end

local function DashFunction(Character)
    local Humanoid = Character:FindFirstChild("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart then return end

    local Direction = RootPart.CFrame.LookVector

    local Attachment = RootPart:FindFirstChild("RootAttachment")

    local LinearVelocity = Instance.new("LinearVelocity")
    LinearVelocity.Attachment0 = Attachment
    LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    LinearVelocity.MaxForce = 1e5
    LinearVelocity.VectorVelocity = Direction * 100 -- dash speed
    LinearVelocity.Parent = RootPart

    task.spawn(function()
        while LinearVelocity do
            task.wait()
            Direction = RootPart.CFrame.LookVector
            LinearVelocity.VectorVelocity = Direction * 100 -- dash speed
        end
    end)

    Debris:AddItem(LinearVelocity, .5)
end

Landmine.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://122032410120318"

    local Tool = Player.Backpack:FindFirstChild(script.Name) or Character:FindFirstChild(script.Name)

    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    local TouchConnection : RBXScriptConnection

    for _, Trail in PrimaryPart:GetChildren() do
        if Trail:IsA("Trail") then
            Trail.Transparency = NumberSequence.new(.7, .7)
        end
    end

    local HumanoidDebounces = {}

    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    task.delay(15, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    local DashSound = SwingSound:Clone()
    DashSound.Parent = Character:FindFirstChild("HumanoidRootPart")
    DashSound:Play()

    RootPartAction(Character.PrimaryPart)
    DashFunction(Character)

    TouchConnection = Tool.LandmineHitbox.Touched:Connect(function(Hit)
        if not Hit then return end
        if not Hit:IsA("BasePart") then return end
        if not Hit.Position then return end
        if Hit:IsDescendantOf(Character) then return end

        TouchConnection:Disconnect()

        local Explosion = Instance.new("Explosion")
        Explosion.BlastRadius = 20
        Explosion.BlastPressure = 0
        Explosion.DestroyJointRadiusPercent = 0

        Explosion.Parent = workspace
        Explosion.Position = Tool.Mine.Position

        local Explode = ExplodeSound:Clone()
        Explode.Parent = workspace
        Explode:Play()

        Debris:AddItem(Explode, Explode.TimeLength + .1)

        local VictimHumanoid = Hit.Parent:FindFirstChild("Humanoid")

        if VictimHumanoid and not HumanoidDebounces[VictimHumanoid] then
            HumanoidDebounces[VictimHumanoid] = true

            local VictimCharacter = VictimHumanoid.Parent
            local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)

            if VictimPlayer then
                local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
                PlayerValues.Attacker.Value = Player.Name
            end

            local RagdollTrigger = VictimCharacter:FindFirstChild("RagdollTrigger")
            if RagdollTrigger then
                RagdollTrigger.Value = true
                task.delay(2.5, function()
                    RagdollTrigger.Value = false
                end)
            end

            VictimHumanoid:TakeDamage(60)
        end

        VictimHumanoid = Hit.Parent.Parent:FindFirstChild("Humanoid")
        if VictimHumanoid and not HumanoidDebounces[VictimHumanoid] then
            HumanoidDebounces[VictimHumanoid] = true

            local VictimCharacter = VictimHumanoid.Parent
            local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)

            if VictimPlayer then
                local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
                PlayerValues.Attacker.Value = Player.Name
            end

            local RagdollTrigger = VictimCharacter:FindFirstChild("RagdollTrigger")
            if RagdollTrigger then
                RagdollTrigger.Value = true
                task.delay(2.5, function()
                    RagdollTrigger.Value = false
                end)
            end

            VictimHumanoid:TakeDamage(55)
        end

        if not HumanoidDebounces[Humanoid] then
            HumanoidDebounces[Humanoid] = true

            Humanoid:TakeDamage(40)
        end
    end)

    task.delay(.75, function()
        TouchConnection:Disconnect()
    end)

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
    
    task.wait()
    return true
end

return Landmine