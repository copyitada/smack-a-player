local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local KnockbackServiceServer = require(ServerScriptService.Server.Services.KnockbackService.KnockbackServiceServer)
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)

local Extended = {}
local SwingSound = ServerStorage:FindFirstChild("swing")

local SpecialAttackDebounces = {}

Extended.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://83138996215724"

    local AnimTrack : AnimationTrack  = Humanoid.Animator:LoadAnimation(Animation)
    local Tool = Player.Backpack:FindFirstChild("Extended") or Character:FindFirstChild("Extended")

    local TouchConnection
    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    for _, Trail in PrimaryPart:GetChildren() do
        if Trail:IsA("Trail") then
            Trail.Transparency = NumberSequence.new(.7, .7)
        end
    end

    local HumanoidDebounce = {}
    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    task.delay(20, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    local SwingCloneSound : Sound = SwingSound:Clone()
    SwingCloneSound.Parent = Character:FindFirstChild("HumanoidRootPart")
    SwingCloneSound:Play()

    AnimTrack:Play()
    AnimTrack:AdjustSpeed(.5)

    AnimTrack:GetMarkerReachedSignal("Hit"):Wait()
    AnimTrack:AdjustSpeed(2)

    TouchConnection = PrimaryPart.Touched:Connect(function(Hit)
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

        local Results = workspace:Raycast(VictimCharacter:GetPivot().Position + Vector3.new(0, 10, 0), Vector3.new(0, -999999, 0), Params)

        for _ = 1, 50 do
            local Debree : BasePart = Instance.new("Part")
            Debree.Size = Vector3.new(.7, .7, .7)
            Debree.Rotation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
            Debree.Anchored = false
            Debree.Position = VictimCharacter:GetPivot().Position + Vector3.new(math.random(-2, 2), 10, math.random(-2, 2))
            Debree.Parent = workspace.VFX.Debris

            if Results then
                Debree.Material = Results.Material
                Debree.Color = Results.Instance.Color
            else
                Debree.Material = Enum.Material.Neon
                Debree.Color = Color3.fromRGB(255,255,255)
            end

            Debree:ApplyImpulse(Vector3.new(math.random(-5, 5), 20, math.random(-5, 5)))
            Debris:AddItem(Debree, 10)
        end

        if VictimPlayer then
            local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
            PlayerValues.Attacker.Value = Player.Name
        end

        VictimHumanoid:TakeDamage(35)

        KnockbackServiceServer.Apply(VictimCharacter:FindFirstChild("HumanoidRootPart"), Character, 10, 30)

        task.delay(2.5, function()
            VictimCharacter.RagdollTrigger.Value = false
        end)
    end)

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
    
    task.wait()
    return true
end

return Extended