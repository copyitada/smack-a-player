local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local DataManager = require(ServerScriptService.Server.Modules.DataManager)
local KnockbackServiceServer = require(ServerScriptService.Server.Services.KnockbackService.KnockbackServiceServer)
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)
local ToolServiceUtils = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils)

local ParryBillboard = ServerStorage:FindFirstChild("Parry")
local ParryEffect = ServerStorage:FindFirstChild("ParryFX").Sparks

local BlockDebounces = {}

local CombatServiceServer = {}

local function OnHit(Player, VictimCharacter, Hit, AnimTrack, Smacks)
    local VictimHumanoid = Hit.Parent:FindFirstChild("Humanoid")
    if not VictimHumanoid then return end

    if VictimCharacter.Name == Player.Character.Name then return end

    local VictimPlayer = Players:GetPlayerFromCharacter(VictimCharacter)

    local SmackerInformation = ToolServiceUtils.GetInformation(Player)
    local Blocking = VictimCharacter:FindFirstChild("Blocking")
                
    if Blocking then
        CombatServiceServer.Parried(Player, Hit, AnimTrack)

        return
    end

    if SmackerInformation.Smack.Hit then
        SmackerInformation.Smack.Hit(Player, VictimCharacter)
    end
                
    ReplicatedStorage.Remotes.ShakeOnce:FireClient(Player, 5, 10, .1, .4)

    VictimCharacter.RagdollTrigger.Value = true

    local Damage = SmackerInformation.Smack.Damage
    if typeof(Damage) == "function" then
        Damage = SmackerInformation.Smack.Damage()
    end
    VictimHumanoid:TakeDamage(Damage)

    Smacks.Value += 1
    DataManager.AddSmacks(Player)

    if VictimPlayer then
        local PlayerValues = ValueServiceServer.GetValues(VictimPlayer)
        PlayerValues.Attacker.Value = Player.Name
    end

    local KnockbackSpeed = SmackerInformation.Smack.KnockbackSpeed
    local KnockbackUp = SmackerInformation.Smack.KnockbackUp
                
    if typeof(KnockbackSpeed) == "function" then
        KnockbackSpeed = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils).GetInformation(Player).Smack.KnockbackSpeed()
    end
    if typeof(KnockbackUp) == "function" then
        KnockbackUp = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils).GetInformation(Player).Smack.KnockbackUp()
    end

    KnockbackServiceServer.Apply(VictimCharacter:FindFirstChild("HumanoidRootPart"), Player.Character, KnockbackSpeed, KnockbackUp)

    task.delay(1.5, function()
        VictimCharacter.RagdollTrigger.Value = false
    end)
end

function CombatServiceServer.HitDetected(Player : Player, VictimCharacter, Timestamp)
    if not Player.Character then return end

    local AttackerRoot = Player.Character:FindFirstChild("HumanoidRootPart")
    local VictimRoot = VictimCharacter:FindFirstChild("HumanoidRootPart")
    local VictimHumanoid = VictimCharacter:FindFirstChild("Humanoid")

    if not AttackerRoot or not VictimRoot or not VictimHumanoid then return end
    if VictimHumanoid.Health <= 0 then return end

    local Latency = tick() - Timestamp
    if Latency > 0.5 then return end

    local Distance = (AttackerRoot.Position - VictimRoot.Position).Magnitude

    local MaxDistance = 25 + 5 * Player:GetNetworkPing() * 20 + 5
    if Distance > MaxDistance then
        Player:Kick("We have detected abnormal activity; distance towards victim exceeded maximum limit.")
        return
    end

    local Values = Player:FindFirstChild("Values")
    local Smacks = Values and Values.RoundStats:FindFirstChild("Smacks")

    task.spawn(OnHit, Player, VictimCharacter, VictimRoot, nil, Smacks)
end

function CombatServiceServer.Parry(Player : Player, Block : boolean?)
    Block = true 

    local Character = Player.Character

    local Humanoid = Character:FindFirstChild("Humanoid")

    if BlockDebounces[Humanoid] then return end

    task.spawn(function()
        if not Block then
            --[[
            local LoadedAnimations = Humanoid.Animator:GetPlayingAnimationTracks()
            for _, Animation in LoadedAnimations do
                if Animation.Name == "Block" then
                    Animation:Stop()
                end
            end

            if Character:FindFirstChild("Blocking") then
                Character.Blocking:Destroy()
            end
            ]]
            print("not blocking")
        else
            local Passed = false
            BlockDebounces[Humanoid] = true

            local Values = Player:FindFirstChild("Values")
            local ParryCooldown = Values:FindFirstChild("ParryCooldown")
            ParryCooldown.Value = true


            local BlockSound : Sound = Instance.new("Sound")
            BlockSound.SoundId = "rbxassetid://5763723309"
            BlockSound.Parent = Character.PrimaryPart

            BlockSound:Play()

            local Animation : Animation = Instance.new("Animation")
            Animation.AnimationId = "rbxassetid://130825021567561"
            Animation.Name = "Block"

            local BlockAnimation = Humanoid.Animator:LoadAnimation(Animation)
            BlockAnimation:Play()

            local Blocking = Instance.new("BoolValue")
            Blocking.Name = "Blocking"
            Blocking.Parent = Character

            local _, Tool = ToolServiceUtils.IsHoldingTool(Character)

            local BlockBillboard = ParryBillboard:Clone()
            BlockBillboard.Parent = Tool

            Humanoid.WalkSpeed = 2

            Character.ChildRemoved:Connect(function(Child)
                if Child.Name ~= "Blocking" then return end

                BlockAnimation:Stop()
                BlockBillboard:Destroy()

                print("passed?", Passed)

                if not Passed then
                    if Blocking then
                        Blocking:Destroy()
                    end

                    Humanoid.WalkSpeed = 16
                    BlockDebounces[Humanoid] = nil

                    ParryCooldown.Value = false
                    return true
                else
                    Blocking:Destroy()

                    CombatServiceServer.Stun(Character, 2)

                    task.wait(2)
                    Humanoid.WalkSpeed = 16

                    task.delay(5, function()
                        BlockDebounces[Humanoid] = nil
                        ParryCooldown.Value = false
                    end)
                    return true
                end
            end)

            print("i am here")
            task.wait(2)

            Passed = true
            task.wait()
            if Blocking then
                Blocking:Destroy()
            end
        end
    end)
end

function CombatServiceServer.Parried(Player : Player, Hit, SmackAnimationTrack)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")

    local VictimCharacter = Hit.Parent 
    local VictimHumanoid = VictimCharacter:FindFirstChild("Humanoid")

    local Blocking = VictimCharacter:FindFirstChild("Blocking")

    local ParrySound : Sound = Instance.new("Sound")
    ParrySound.SoundId = "rbxassetid://7058511852"
    ParrySound.Parent = Character.PrimaryPart
    ParrySound.SoundGroup = SoundService.Master.SFX

    ParrySound:Play()

    local ParryAnimation : Animation = Instance.new("Animation")
    ParryAnimation.AnimationId = "rbxassetid://115959595126522"
    ParryAnimation.Name = "Block"

    local ParryTrack = Humanoid.Animator:LoadAnimation(ParryAnimation)
    ParryTrack:Play()

    local ParryFX = ParryEffect:Clone()
    ParryFX.Parent = Hit

    ReplicatedStorage.Remotes.ShakeOnce:FireClient(Player, 15, 10, .1, .4)
                
    for _, Particle in ParryFX:GetChildren() do
        if Particle:IsA("ParticleEmitter") then
            Particle:Emit()
        end
    end

    local Animator = VictimHumanoid:FindFirstChild("Animator")
    if Animator then
        local LoadedAnimations = VictimHumanoid.Animator:GetPlayingAnimationTracks()
        for _, Animation in LoadedAnimations do
            if Animation.Name == "Block" then
                Animation:Stop()
            end
        end
    end

    for _, Object in VictimCharacter:GetDescendants() do
        if Object:IsA("BillboardGui") and Object.Name == "Parry" then
            local Text : TextLabel = Object.Text
            Text.Text = "PARRIED!"
            Text.TextColor3 = Color3.fromRGB(255, 0, 0)

            Object.StudsOffset = Vector3.new(0, 0, 0)
            TweenService:Create(Object, TweenInfo.new(), { StudsOffset = Vector3.new(0, 1, 0) }):Play()

            coroutine.wrap(function()
                task.wait(2)
                if VictimCharacter.Name == "Blocking Nemmy" then
                    if Text.Text == "PARRIED!" then
                        Text.Text = "ooh parry"
                    end
                    if Object.StudsOffset == Vector3.new(0,1,0) then
                        Object.StudsOffset = Vector3.new(0, 0, 0)
                    end

                    TweenService:Create(Text, TweenInfo.new(), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
                else
                    Object:Destroy()
                end
            end)()
        end
    end

    ReplicatedStorage.Remotes.ParriedEffect:FireClient(Player)
    Blocking:Destroy()

    if SmackAnimationTrack then
        SmackAnimationTrack:Stop()
    end

    CombatServiceServer.Stun(Character, 4)
    task.wait()
    Humanoid.WalkSpeed = 0

    task.delay(4, function()
        ParryTrack:Stop()
        Humanoid.WalkSpeed = 16
    end)

    return
end

function CombatServiceServer.Stun(Character : Model, Duration : number)
    local Stunned = Instance.new("BoolValue") :: BoolValue
    Stunned.Name = "Stunned"
    Stunned.Parent = Character

    Debris:AddItem(Stunned, Duration)
end

return CombatServiceServer