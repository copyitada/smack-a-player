
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local CombatServiceServer = require(ServerScriptService.Server.Services.CombatService.CombatServiceServer)
local ToolServiceServer = require(ServerScriptService.Server.Services.ToolService.ToolServiceServer)

local BassdropSound = ServerStorage:FindFirstChild("bassdrop") 

local Magnet = {}

local SpecialAttackDebounces = {}

local function IsPlayerInfront(VictimCharacter, ThrowingCharacter)
    local Direction = (VictimCharacter:GetPivot().Position - ThrowingCharacter:GetPivot().Position).Unit
    return ThrowingCharacter:GetPivot().LookVector:Dot(Direction) > 0.8
end

local function MoveCharacter(Character, TargetCFrame, Duration)
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end

    RootPart.Anchored = true

    local CFrameValue = Instance.new("CFrameValue")
    CFrameValue.Value = RootPart.CFrame
    CFrameValue.Parent = RootPart

    CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
        RootPart.CFrame = CFrameValue.Value
    end)

    local Tween = TweenService:Create(CFrameValue, TweenInfo.new(
        Duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    ), {
        Value = TargetCFrame
    })

    Tween:Play()
    Tween.Completed:Connect(function()
        RootPart.Anchored = false
        CFrameValue:Destroy()
    end)
end

Magnet.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://125704677116331"

    local AnimTrack : AnimationTrack  = Humanoid.Animator:LoadAnimation(Animation)
    local Tool = Player.Backpack:FindFirstChild("Magnet") or Character:FindFirstChild("Magnet")

    local PrimaryPart = Tool:FindFirstChild("EvadeTaxes")

    for _, Trail in PrimaryPart:GetChildren() do
        if Trail:IsA("Trail") then
            Trail.Transparency = NumberSequence.new(.7, .7)
        end
    end

    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

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
        if Distance < 15 and Distance < ClosestDistance then
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
            if Distance < 15 and Distance < ClosestDistance then
                PlayerClosestInfront = Dummy
                ClosestDistance = Distance
            end
        end
    end

    local Bassdrop = BassdropSound:Clone()
    Bassdrop.Parent = RootPart
    Bassdrop:Play()

    task.wait(1)

    Debris:AddItem(Bassdrop, Bassdrop.TimeLength + .1)
    CombatServiceServer.Stun(PlayerClosestInfront, 2)

    if PlayerClosestInfront then
        local Blocking = PlayerClosestInfront:FindFirstChild("Blocking")

        if not Blocking then
            MoveCharacter(PlayerClosestInfront, Character:GetPivot() + Character:GetPivot().LookVector * 6, .5)
        else
            Blocking:Destroy()
        end
    end

    task.delay(10, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

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

return Magnet