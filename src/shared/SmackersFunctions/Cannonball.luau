local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local KnockbackServiceServer = require(ServerScriptService.Server.Services.KnockbackService.KnockbackServiceServer)
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)

local Cannon = ServerStorage:FindFirstChild("Cannonball")

-- script update

local Cannonball = {}
local SwingSound = ServerStorage:FindFirstChild("swing")

local SpecialAttackDebounces = {}

Cannonball.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://83138996215724"

    local Tool = Player.Backpack:FindFirstChild("Cannonball") or Character:FindFirstChild("Cannonball")

    local TouchConnection
    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    local HumanoidDebounce = {}
    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    task.delay(10, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    local SwingCloneSound : Sound = SwingSound:Clone()
    SwingCloneSound.Parent = Character:FindFirstChild("HumanoidRootPart")
    SwingCloneSound:Play()

    local Clone = Cannon:Clone()
    Clone.CFrame = PrimaryPart.CFrame
    Clone.Parent = workspace

    PrimaryPart.Transparency = 1
    PrimaryPart.CanCollide = false

    local LinearVelocity = Instance.new("LinearVelocity")
    LinearVelocity.VectorVelocity = Character:GetPivot().LookVector * 100 + Vector3.new(0, 5, 0)
    LinearVelocity.MaxForce = math.huge
    LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    LinearVelocity.Attachment0 = Clone.Attachment
    LinearVelocity.Parent = Clone

    Debris:AddItem(LinearVelocity, .15)

    TouchConnection = Clone.Touched:Connect(function(Hit)
        local VictimHumanoid = Hit.Parent:FindFirstChild("Humanoid")
        if not VictimHumanoid then return end
        local VictimCharacter = VictimHumanoid.Parent

        if VictimCharacter.Name == Character.Name then return end
        VictimCharacter.RagdollTrigger.Value = true

        local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)

        if HumanoidDebounce[VictimHumanoid] then return end
        
        HumanoidDebounce[VictimHumanoid] = true
        ReplicatedStorage.Remotes.ShakeOnce:FireClient(Player, 10, 20, .4, 1.1)

        local Explosion = Instance.new("Explosion")
        Explosion.Parent = workspace
        Explosion.BlastRadius = 0
        Explosion.BlastPressure = 0
        Explosion.Position = Clone.Position

        local Radius = Instance.new("Part")
        Radius.Shape = Enum.PartType.Ball
        Radius.Position = Clone.Position
        Radius.Size = Vector3.new(20, 20, 20)
        Radius.CanCollide = false
        Radius.Transparency = 1
        Radius.BrickColor = BrickColor.Red()
        Radius.Anchored = true
        Radius.Parent = workspace

        local Parts = workspace:GetPartsInPart(Radius)

        for _, Part in pairs(Parts) do
            pcall(function()
                local RadiusHumanoid = Part.Parent:FindFirstChild("Humanoid")
                if not RadiusHumanoid then return end

                if HumanoidDebounce[RadiusHumanoid] then return end
                HumanoidDebounce[RadiusHumanoid] = true

                RadiusHumanoid:TakeDamage(10)
                RadiusHumanoid.Parent.RagdollTrigger.Value = true
                RadiusHumanoid.Parent.PrimaryPart:ApplyImpulse((Clone.Position - Character:GetPivot().Position).Unit * Part.Parent.PrimaryPart.AssemblyMass * 50)


                task.delay(2.5, function()
                    RadiusHumanoid.Parent.RagdollTrigger.Value = false
                end)
            end)
        end

        Debris:AddItem(Radius, .5)

        Clone:Destroy()

        VictimHumanoid:TakeDamage(35)

        if VictimPlayer then
            local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
            PlayerValues.Attacker.Value = Player.Name
        end

        KnockbackServiceServer.Apply(VictimCharacter:FindFirstChild("HumanoidRootPart"), Character, 10, 30)

        task.delay(2.5, function()
            VictimCharacter.RagdollTrigger.Value = false
        end)

        TouchConnection:Disconnect()
    end)

    task.wait(1)
    PrimaryPart.Transparency = 0
    PrimaryPart.CanCollide = true
    
    task.wait()
    return true
end

return Cannonball