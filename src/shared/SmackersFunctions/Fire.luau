local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)

local OuchSound = ServerStorage:FindFirstChild("ouch")
local ThunderSound = ServerStorage:FindFirstChild("thunder")
local Windup = ServerStorage:FindFirstChild("windup")

local SpecialAttackDebounces = {}
local Firish = {}

local function RootPartAction(RootPart, CFrame : CFrame, Velocity : Vector3?)
    local Vel = Velocity or Vector3.new(50, 0, 0)

    local LinearVelocity = Instance.new("LinearVelocity")
    LinearVelocity.Parent = RootPart
    LinearVelocity.Attachment0 = RootPart:FindFirstChild("RootAttachment")
    LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    LinearVelocity.MaxForce = math.huge
    LinearVelocity.VectorVelocity = CFrame.RightVector * Vel.X + CFrame.UpVector * Vel.Y + CFrame.LookVector * Vel.Z

    --[[
    local CloneSound : Sound = SmackSound:Clone()
    CloneSound.Parent = RootPart
    CloneSound:Play()
    ]]

    -- Debris:AddItem(CloneSound, 1)
    Debris:AddItem(LinearVelocity, 0.2)
end

Firish.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://115612258137561"

    local AnimTrack : AnimationTrack  = Humanoid.Animator:LoadAnimation(Animation)
    local Tool = Player.Backpack:FindFirstChild(script.Name) or Character:FindFirstChild(script.Name)

    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    local _FirishParticle : ParticleEmitter = PrimaryPart:FindFirstChild("ParticleEmitter")

    for _, Trail in PrimaryPart:GetChildren() do
        if Trail:IsA("Trail") then
            Trail.Transparency = NumberSequence.new(.7, .7)
        end
    end

    local HumanoidDebounce = {}
    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    task.delay(15, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    local Thunder : Sound = ThunderSound:Clone()
    Thunder.Parent = Character:FindFirstChild("HumanoidRootPart")   

    local Ouch : Sound = OuchSound:Clone()
    Ouch.Parent = Character:FindFirstChild("HumanoidRootPart")   

    local WindupSound : Sound = Windup:Clone()
    WindupSound.Parent = Character:FindFirstChild("HumanoidRootPart")
    WindupSound:Play()

    AnimTrack:Play()
    AnimTrack:GetMarkerReachedSignal("Fire"):Wait()
    Thunder:Play()

    local AreaOfFire = ServerStorage.FirePlace:Clone()
    AreaOfFire.Parent = workspace
    
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {Character}
    Params.FilterType = Enum.RaycastFilterType.Exclude

    local Results = workspace:Raycast(Character:GetPivot().Position + Vector3.new(0, 10, 0), Vector3.new(0, -999999, 0), Params)
    if Results and Results.Instance then
        local TouchConnection

        local Explosion = Instance.new("Explosion")
        Explosion.BlastRadius = 20
        Explosion.BlastPressure = 0
        Explosion.DestroyJointRadiusPercent = 0

        Explosion.Parent = workspace
        Explosion.Position = Results.Position

        AreaOfFire.Position = Results.Position
        Debris:AddItem(AreaOfFire, 10)

        TouchConnection = AreaOfFire.Touched:Connect(function(Hit)
            local VictimHumanoid = Hit.Parent:FindFirstChild("Humanoid")
            if not VictimHumanoid then return end
            local VictimCharacter = VictimHumanoid.Parent
            if VictimCharacter.Name == Character.Name then return end

            local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)

            if HumanoidDebounce[VictimHumanoid] then
                warn("------------ " .. VictimCharacter.Name .. " already hit! ---------------")
                return
            end
            
            HumanoidDebounce[VictimHumanoid] = true
            ReplicatedStorage.Remotes.ShakeOnce:FireClient(Player, 10, 20, .4, 1.1)

            if VictimPlayer then
                local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
                PlayerValues.Attacker.Value = Player.Name
            end

            task.spawn(function()
                VictimHumanoid:TakeDamage(15)
                VictimCharacter.RagdollTrigger.Value = true
                print("ragdolled!")

                local Highlight : Highlight = Instance.new("Highlight")
                Highlight.OutlineTransparency = 1
                Highlight.FillColor = Color3.fromRGB(255, 115, 0)
                Highlight.FillTransparency = 0.3

                Highlight.Parent = VictimCharacter
                Highlight.Adornee = VictimCharacter
                
                --local Particle = FirishParticle:Clone()
                --Particle.Parent = VictimCharacter.HumanoidRootPart.RootAttachment

                for _ = 1, 8 do
                    task.wait(1)
                    Ouch:Play()
                    VictimHumanoid:TakeDamage(4)
                end

                --Particle:Destroy()
                HumanoidDebounce[VictimHumanoid] = nil
                Highlight:Destroy()
            end)

            task.delay(1, function()
                TouchConnection:Disconnect()
            end)

            local Pivot : CFrame = Character:FindFirstChild("HumanoidRootPart").CFrame
            RootPartAction(VictimCharacter:FindFirstChild("HumanoidRootPart"), Pivot)

            task.delay(2.5, function()
                VictimCharacter.RagdollTrigger.Value = false
                print("unragdolled")
            end)
        end)

        task.delay(10, function()
            TouchConnection:Disconnect()
        end)
    else
        AreaOfFire.Position = Vector3.new(math.huge, math.huge, math.huge)
    end

    AnimTrack.Ended:Wait()
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

return Firish