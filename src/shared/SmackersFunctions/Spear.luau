local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ToolServiceServer = require(ServerScriptService.Server.Services.ToolService.ToolServiceServer)
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)

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

local function IsPlayerInfront(VictimCharacter, ThrowingCharacter)
    local Direction = (VictimCharacter:GetPivot().Position - ThrowingCharacter:GetPivot().Position).Unit
    return ThrowingCharacter:GetPivot().LookVector:Dot(Direction) > 0.45
end

local function OnHit(Player, Humanoid, Hit, ThrownCFrame)
    local VictimCharacter = Hit:FindFirstAncestorOfClass("Model")
    if VictimCharacter then
        local VictimHumanoid = VictimCharacter:FindFirstChild("Humanoid")
        if VictimHumanoid and VictimHumanoid ~= Humanoid then
            local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)
            VictimCharacter.RagdollTrigger.Value = true

            RootPartAction(VictimCharacter:FindFirstChild("HumanoidRootPart"), ThrownCFrame, Vector3.new(0, 0, 60))
            VictimHumanoid:TakeDamage(20)

            if VictimPlayer then
                local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
                PlayerValues.Attacker.Value = Player.Name
            end

            task.delay(2.5, function()
                VictimCharacter.RagdollTrigger.Value = false
            end)
        end
    end
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

    local HumanoidDebounce = {}
    local PreviousCFrames = {}

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

    local PlayerClosestInfront : Model
    local ClosestDistance = math.huge

    for _, VictimPlayer in Players:GetPlayers() do
        local VictimCharacter = VictimPlayer.Character
        if not VictimCharacter then continue end
        if VictimCharacter == Character then continue end

        local VictimHumanoid = VictimCharacter:FindFirstChild("Humanoid")
        if not VictimHumanoid or VictimHumanoid.Health <= 0 then continue end

        if not IsPlayerInfront(VictimCharacter, Character) then continue end

        local Distance = (Character:GetPivot().Position - VictimCharacter:GetPivot().Position).Magnitude
        if Distance < ClosestDistance then
            PlayerClosestInfront = VictimCharacter
            ClosestDistance = Distance
        end
    end

    if workspace:FindFirstChild("Dummy") then
        for _, Dummy in workspace.Dummy:GetChildren() do
            if not Dummy:IsA("Model") then continue end

            local DummyHumanoid = Dummy:FindFirstChild("Humanoid")
            if not DummyHumanoid or DummyHumanoid.Health <= 0 then continue end

            if not IsPlayerInfront(Dummy, Character) then continue end

            local Distance = (Character:GetPivot().Position - Dummy:GetPivot().Position).Magnitude
            if Distance < ClosestDistance then
                PlayerClosestInfront = Dummy
                ClosestDistance = Distance
            end
        end
    end

    local NewJavelin : Model = JavelinCopy:Clone()
    NewJavelin.Parent = workspace

    if PlayerClosestInfront then
        NewJavelin:PivotTo(ToolCFrame)

        local Torso = PlayerClosestInfront:FindFirstChild("Torso")
        if not Torso then return end

        NewJavelin:PivotTo(CFrame.lookAt(ToolCFrame.Position, Torso.Position))
    else
        NewJavelin:PivotTo(ToolCFrame)
    end

    local Tip = NewJavelin.PrimaryPart

    local Sound = Tip:FindFirstChild("whoosh")
    if Sound then
        Sound:Play()
    end

    local StartTime = tick()
    local ThrownCFrame = RootPart.CFrame

    local function DoHitScan()
        local Parts = {Tip}

        for _, Part in Parts do
            local Hitbox = Instance.new("Part")
            Hitbox.Color = Color3.fromRGB(255, 0, 0)
            Hitbox.CanCollide = false
            Hitbox.Anchored = true
            Hitbox.Material = Enum.Material.ForceField
            Hitbox.Transparency = RunService:IsStudio() and .5 or 1
            Hitbox.CFrame = Part.CFrame
            Hitbox.Size = Part.Size + Vector3.new(1.5, 1.5, 1.5)
            Hitbox.Parent = workspace

            Debris:AddItem(Hitbox, 1)

            local CurrentCFrame = Part.CFrame
            local PreviousCFrame = PreviousCFrames[Part]

            if PreviousCFrame then
                local RaycastParams = RaycastParams.new()
                RaycastParams.FilterDescendantsInstances = {Tool, Character}
                RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    
                local Direction = (CurrentCFrame.Position - PreviousCFrame.Position)

                if Direction.Magnitude > .01 then
                    local Result = workspace:Shapecast(Part, Direction, RaycastParams)

                    if Result then
                        local HitCharacter = Result.Instance.Parent
                        local VictimHumanoid = HitCharacter:FindFirstChild("Humanoid")

                        if VictimHumanoid and HitCharacter ~= Character and not HumanoidDebounce[VictimHumanoid] then
                            Hitbox.Color = Color3.fromRGB(0,255,0)

                            HumanoidDebounce[VictimHumanoid] = true
                            OnHit(Player, Humanoid, Result.Instance, ThrownCFrame)
                        end
                    end
                end
            end

            PreviousCFrames[Part] = CurrentCFrame
        end
    end

    task.spawn(function()
        while Moving do
            if not NewJavelin or not NewJavelin.Parent then
                Moving = false
                return
            end

            RunService.Heartbeat:Wait()
            DoHitScan()

            NewJavelin:PivotTo(NewJavelin:GetPivot() + NewJavelin:GetPivot().LookVector)

            local Elapsed = tick() - StartTime
            if Elapsed >= LIFETIME then
                Moving = false
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