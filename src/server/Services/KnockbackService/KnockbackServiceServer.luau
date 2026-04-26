local ServerStorage = game:GetService("ServerStorage")

local PunchEffect = ServerStorage:FindFirstChild("HitFX").Punch
local SmackSound = ServerStorage:FindFirstChild("snap.wav")

local KnockbackService = {}

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local ToolServiceUtils = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils)

function KnockbackService.Apply(RootPart, AttackerCharacter : Model, KnockbackSpeed : number?, KnockbackUp: number?)
    local Humanoid = RootPart.Parent:FindFirstChild("Humanoid")
    assert(Humanoid, "Humanoid is nonexistent.")

    local Tool = RootPart.Parent:FindFirstChildWhichIsA("Tool")

    local ConfirmedKnockbackSpeed = Humanoid.Health <= 7 and 999 or KnockbackSpeed or 15
    local ConfirmedKnockbackUp = Humanoid.Health <= 7 and 999 or KnockbackUp or 30

    if Tool then
        local SmackerInformation = ToolServiceUtils.GetInformation(nil, Tool.Name)

        ConfirmedKnockbackSpeed *= SmackerInformation.Smack.KnockbackVulnerability or 1
        ConfirmedKnockbackUp *= SmackerInformation.Smack.KnockbackVulnerability or 1
    end

    local KnockbackVelocity = AttackerCharacter:GetPivot().LookVector * ConfirmedKnockbackSpeed + Vector3.new(0, ConfirmedKnockbackUp, 0)

    local Parent = RootPart
    if RootPart.Parent:FindFirstChild("Mirror") then
        Parent = AttackerCharacter:FindFirstChild("HumanoidRootPart")
        KnockbackVelocity = -AttackerCharacter:GetPivot().LookVector * ConfirmedKnockbackSpeed + Vector3.new(0, ConfirmedKnockbackUp, 0)
    end

    assert(Parent, "Nonexistent")

    local LinearVelocity = Instance.new("LinearVelocity")
    LinearVelocity.Parent     = Parent
    LinearVelocity.Attachment0 = Parent:FindFirstChild("RootAttachment")
    LinearVelocity.RelativeTo  = Enum.ActuatorRelativeTo.World  -- world-space so LookVector maps directly
    LinearVelocity.MaxForce    = math.huge
    LinearVelocity.VectorVelocity = KnockbackVelocity

    local EffectClone : Attachment = PunchEffect:Clone()
    EffectClone.Parent = Parent
    EffectClone.WorldCFrame = Parent.CFrame

    for _, Particle in EffectClone:GetChildren() do
        task.spawn(function()
            Particle:Emit(Particle:GetAttribute("EmitCount"))
        end)
    end

    local CloneSound : Sound = SmackSound:Clone()
    CloneSound.Parent = Parent
    CloneSound.SoundGroup = SoundService.Master.SFX
    CloneSound:Play()

    Debris:AddItem(CloneSound, 1)
    Debris:AddItem(EffectClone, 1)
    Debris:AddItem(LinearVelocity, 0.2)
end

return KnockbackService