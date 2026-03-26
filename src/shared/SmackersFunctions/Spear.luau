local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ToolServiceServer = require(ServerScriptService.Server.Services.ToolService.ToolServiceServer)

local JavelinCopy = ServerStorage.Javelin

local LIFETIME = 5

-- script update
local Javelin = {}

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

Javelin.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://105482004904095"

    local AnimTrack : AnimationTrack  = Humanoid.Animator:LoadAnimation(Animation)
    local Tool = Player.Backpack:FindFirstChild("Spear") or Character:FindFirstChild("Spear")

    local TouchConnection
    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    local Moving = true

    for _, Trail in PrimaryPart:GetChildren() do
        if Trail:IsA("Trail") then
            Trail.Transparency = NumberSequence.new(.7, .7)
        end
    end

    local HumanoidDebounces = {}

    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    AnimTrack:Play()
    AnimTrack:GetMarkerReachedSignal("Hit"):Wait()

    local ToolCFrame : CFrame = Tool:GetPivot()
    Tool:Destroy()

    local Values = Player:WaitForChild("Values")
    local SmackerName : StringValue = Values:WaitForChild("SmackerName")

    task.delay(1, function()
        local SmackerInstance = ServerStorage.Smackers:FindFirstChild(SmackerName.Value) or ServerStorage.Smackers.Default

        local SmackerTool = SmackerInstance:Clone()
        SmackerTool.Parent = Character

        if Character:FindFirstChild("Humanoid") then
            Humanoid:EquipTool(SmackerTool)
        end

        ToolServiceServer.InitializeSmacker(Player, SmackerTool)
    end)

    local NewJavelin : Model = JavelinCopy:Clone()
    NewJavelin.Parent = workspace

    local Tip = NewJavelin.PrimaryPart

    local Sound = Tip:FindFirstChild("whoosh")
    if Sound then
        Sound:Play()
    end

    NewJavelin:PivotTo(ToolCFrame)

    local StartTime = tick()
    local ThrownCFrame = RootPart.CFrame

    -- hit detection
    TouchConnection = Tip.Touched:Connect(function(Hit)
        print(Hit:GetFullName())

        if Hit:IsDescendantOf(Character) then return end
        if Hit:IsDescendantOf(NewJavelin) then return end
        if not Hit.CanCollide then return end

        -- damage hit player
        local VictimCharacter = Hit:FindFirstAncestorOfClass("Model")
        if VictimCharacter then
            local VictimHumanoid = VictimCharacter:FindFirstChild("Humanoid")
            if VictimHumanoid and VictimHumanoid ~= Humanoid and not HumanoidDebounces[Humanoid] then
                HumanoidDebounces[Humanoid] = true
                VictimCharacter.RagdollTrigger.Value = true

                RootPartAction(VictimCharacter:FindFirstChild("HumanoidRootPart"), ThrownCFrame, Vector3.new(0, 0, 60))
                VictimHumanoid:TakeDamage(20)

                task.delay(2, function()
                    HumanoidDebounces[Humanoid] = nil
                    
                    task.wait(.5)
                    VictimCharacter.RagdollTrigger.Value = false
                end)
            end
        end

        -- disappear after 2 seconds of being stuck
        task.delay(5, function()
            if NewJavelin and NewJavelin.Parent then
                NewJavelin:Destroy()
            end
        end)
    end)

    -- slow down over lifetime then disappear
    task.spawn(function()
        while Moving do
            if not NewJavelin or not NewJavelin.Parent then
                Moving = false
                return
            end

            NewJavelin:PivotTo(NewJavelin:GetPivot() + NewJavelin:GetPivot().LookVector)

            task.wait()

            local Elapsed = tick() - StartTime
            if Elapsed >= LIFETIME then
                Moving = false
                TouchConnection:Disconnect()
                if NewJavelin and NewJavelin.Parent then
                    NewJavelin:Destroy()
                end
                return
            end
        end
    end)

    task.delay(5, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    local SwingCloneSound : Sound = SwingSound:Clone()
    SwingCloneSound.Parent = Character:FindFirstChild("HumanoidRootPart")
    SwingCloneSound:Play()

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

return Javelin