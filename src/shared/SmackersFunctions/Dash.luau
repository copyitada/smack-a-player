local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")

local PunchEffect = ServerStorage:FindFirstChild("HitFX").Punch
local SwingSound = ServerStorage:FindFirstChild("dash")

local SpecialAttackDebounces = {}
local Dash = {}

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

    local Direction = Humanoid.MoveDirection

    -- if player isnt moving, dash forward instead
    if Direction.Magnitude < .1 then
        Direction = RootPart.CFrame.LookVector
    end

    local Attachment = RootPart:FindFirstChild("RootAttachment")

    local LinearVelocity = Instance.new("LinearVelocity")
    LinearVelocity.Attachment0 = Attachment
    LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    LinearVelocity.MaxForce = 1e5
    LinearVelocity.VectorVelocity = Direction * 100 -- dash speed
    LinearVelocity.Parent = RootPart

    Debris:AddItem(LinearVelocity, .15)
end

Dash.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://122032410120318"

    local Tool = Player.Backpack:FindFirstChild(script.Name) or Character:FindFirstChild(script.Name)

    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    for _, Trail in PrimaryPart:GetChildren() do
        if Trail:IsA("Trail") then
            Trail.Transparency = NumberSequence.new(.7, .7)
        end
    end

    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    task.delay(2, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    local DashSound = SwingSound:Clone()
    DashSound.Parent = Character:FindFirstChild("HumanoidRootPart")
    DashSound:Play()

    RootPartAction(Character.PrimaryPart)
    DashFunction(Character)

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

return Dash