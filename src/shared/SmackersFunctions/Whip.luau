local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)

-- script update

local Whip = {}

local PunchEffect = ServerStorage:FindFirstChild("HitFX").Punch
local SmackSound = ServerStorage:FindFirstChild("snap.wav")
local SwingSound = ServerStorage:FindFirstChild("swing")

local SpecialAttackDebounces = {}

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

Whip.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://72180999605010"
    -- Animation.AnimationId = "rbxassetid://110904704122106"

    local AnimTrack : AnimationTrack  = Humanoid.Animator:LoadAnimation(Animation)
    local Tool = Player.Backpack:FindFirstChild("Whip") or Character:FindFirstChild("Whip")

    local TouchConnection = {}

    local HumanoidDebounce = {}
    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    task.delay(5, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    local SwingCloneSound : Sound = SwingSound:Clone()
    SwingCloneSound.Parent = Character:FindFirstChild("HumanoidRootPart")
    SwingCloneSound:Play()

    AnimTrack:Play()
    AnimTrack:GetMarkerReachedSignal("Hit"):Wait()

    for _, Segment in Tool.Segment:GetChildren() do
        TouchConnection[Segment] = Segment.Touched:Connect(function(Hit)
            local VictimHumanoid = Hit.Parent:FindFirstChild("Humanoid")
            if not VictimHumanoid then return end
            local VictimCharacter = VictimHumanoid.Parent

            if VictimCharacter.Name == Character.Name then return end
            VictimCharacter.RagdollTrigger.Value = true

            local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)

            if HumanoidDebounce[VictimHumanoid] then return end
            
            HumanoidDebounce[VictimHumanoid] = true
            ReplicatedStorage.Remotes.ShakeOnce:FireClient(Player, 10, 20, .4, 1.1)

            local Params = RaycastParams.new()
            Params.FilterDescendantsInstances = {VictimCharacter}
            Params.FilterType = Enum.RaycastFilterType.Exclude

            VictimHumanoid:TakeDamage(35)

            if VictimPlayer then
                local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
                PlayerValues.Attacker.Value = Player.Name
            end

            local Pivot : CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame
            RootPartAction(VictimCharacter:FindFirstChild("HumanoidRootPart"), Pivot)

            task.delay(2.5, function()
                VictimCharacter.RagdollTrigger.Value = false
            end)
        end)
    end

    AnimTrack.Ended:Wait()

    for _, Connection in TouchConnection do
        Connection:Disconnect()
    end
    
    task.wait()
    return true
end

return Whip