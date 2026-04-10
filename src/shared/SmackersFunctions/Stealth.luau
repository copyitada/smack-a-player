local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")

-- script update

local Stealth = {}

local PunchEffect = ServerStorage:FindFirstChild("HitFX").Punch
local StealthSound = ServerStorage:FindFirstChild("snap.wav")

local SpecialAttackDebounces = {}

local function RootPartAction(RootPart)
    local EffectClone : Attachment = PunchEffect:Clone()
    EffectClone.Parent = RootPart
    EffectClone.WorldCFrame = RootPart.CFrame

    local StealthSFX = StealthSound:Clone()
    StealthSFX.Parent = RootPart
    StealthSFX:Play()

    for _, Particle in EffectClone:GetChildren() do
        task.spawn(function()
            Particle:Emit(Particle:GetAttribute("EmitCount"))
        end)
    end

    Debris:AddItem(StealthSFX, StealthSFX.TimeLength + .1)
    Debris:AddItem(EffectClone, 1)
end

Stealth.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid : Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://83138996215724"

    local Tool = Player.Backpack:FindFirstChild("Stealth") or Character:FindFirstChild("Stealth")
    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    for _, Trail in PrimaryPart:GetChildren() do
        if Trail:IsA("Trail") then
            Trail.Transparency = NumberSequence.new(.7, .7)
        end
    end

    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    RootPartAction(Character.PrimaryPart)

    local TransparencyLists = {}

    Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

    for _, BasePart in Character:GetChildren() do
        if BasePart:IsA("Accessory") then
            BasePart.Parent = ServerStorage
            task.delay(10, function()
                BasePart.Parent = Character
            end)
        end

        if not BasePart:IsA("BasePart") then continue end
        if BasePart.Transparency >= 1 then continue end
        table.insert(TransparencyLists, {
            key = BasePart,
            value = BasePart.Transparency
        })

        BasePart.Transparency = .95
    end

    task.delay(10, function()
        for _, BasePart in TransparencyLists do
            BasePart.key.Transparency = BasePart.value
        end

        Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
    end)

    task.delay(15, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)
    
    task.wait()
    return true
end

return Stealth