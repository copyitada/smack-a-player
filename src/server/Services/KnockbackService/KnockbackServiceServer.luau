local ServerStorage = game:GetService("ServerStorage")

local PunchEffect = ServerStorage:FindFirstChild("HitFX").Punch
local SmackSound = ServerStorage:FindFirstChild("snap.wav")

local KnockbackService = {}

local Debris = game:GetService("Debris")
function KnockbackService.Apply(RootPart, RootPartCFrame : CFrame, KnockbackSpeed : number?, KnockbackUp: number?)
    local Humanoid = RootPart.Parent:FindFirstChild("Humanoid")
    assert(Humanoid, "Humanoid is nonexistent.")

    local ConfirmedKnockbackSpeed = Humanoid.Health <= 7 and 999 or KnockbackSpeed or 15
    local ConfirmedKnockbackUp = Humanoid.Health <= 7 and 999 or KnockbackUp or 30

    local KnockbackVelocity = RootPartCFrame.LookVector * ConfirmedKnockbackSpeed + Vector3.new(0, ConfirmedKnockbackUp, 0)

    local LinearVelocity = Instance.new("LinearVelocity")
    LinearVelocity.Parent     = RootPart
    LinearVelocity.Attachment0 = RootPart:FindFirstChild("RootAttachment")
    LinearVelocity.RelativeTo  = Enum.ActuatorRelativeTo.World  -- world-space so LookVector maps directly
    LinearVelocity.MaxForce    = math.huge
    LinearVelocity.VectorVelocity = KnockbackVelocity

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

return KnockbackService