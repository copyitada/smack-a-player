local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local CombatServiceServer = require(ServerScriptService.Server.Services.CombatService.CombatServiceServer)

local PunchEffect = ServerStorage:FindFirstChild("HitFX").Punch
local TeleportSound = ServerStorage:FindFirstChild("teleportsound")

local SpecialAttackDebounces = {}
local Blink = {}

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

local function NearestPlayer(Character)
    local NearestCharacter
    local ClosestDistance = math.huge

    for _, Player in Players:GetPlayers() do
        local IterationCharacter = Player.Character
        if IterationCharacter == Character then continue end

        local Distance = (Character:GetPivot().Position - IterationCharacter:GetPivot().Position).Magnitude

        if Distance < ClosestDistance then
            NearestCharacter = IterationCharacter
            ClosestDistance = Distance
        end
    end

    for _, Dummy in workspace.Dummy:GetChildren() do
        if not Dummy:IsA("Model") then continue end

        local DummyHumanoid = Dummy:FindFirstChild("Humanoid")
        if not DummyHumanoid or DummyHumanoid.Health <= 0 then continue end

        local Distance = (Character:GetPivot().Position - Dummy:GetPivot().Position).Magnitude
        if Distance < ClosestDistance then
            NearestCharacter = Dummy
            ClosestDistance = Distance
        end
    end

    return NearestCharacter
end

local function TeleportFunction(Character)
    local NearestCharacter = NearestPlayer(Character)

    CombatServiceServer.Stun(Character, 1.75)
    Character:PivotTo(NearestCharacter:GetPivot() + NearestCharacter:GetPivot().LookVector * -4 + Vector3.new(0, 5, 0))
end

Blink.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Tool = Player.Backpack:FindFirstChild(script.Name) or Character:FindFirstChild(script.Name)

    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    for _, Trail in PrimaryPart:GetChildren() do
        if Trail:IsA("Trail") then
            Trail.Transparency = NumberSequence.new(.7, .7)
        end
    end

    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    task.delay(5, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    local Teleport = TeleportSound:Clone()
    Teleport.Parent = Character:FindFirstChild("HumanoidRootPart")
    Teleport:Play()

    ReplicatedStorage.Remotes.Blink:FireClient(Player)

    RootPartAction(Character.PrimaryPart)
    TeleportFunction(Character)

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

return Blink