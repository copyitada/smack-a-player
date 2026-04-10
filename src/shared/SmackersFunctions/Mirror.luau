local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")
local CombatServiceServer = require(ServerScriptService.Server.Services.CombatService.CombatServiceServer)

-- script update

local Default = {}

local SpecialAttackDebounces = {}

Default.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Animation = Instance.new("Animation")
    Animation.Name = "SpecialAttack"
    Animation.AnimationId = "rbxassetid://83138996215724"

    local Tool = Player.Backpack:FindFirstChild("Mirror") or Character:FindFirstChild("Mirror")

    if SpecialAttackDebounces[Humanoid] then return false end
    SpecialAttackDebounces[Humanoid] = true

    task.delay(10, function()
        SpecialAttackDebounces[Humanoid] = nil
    end)

    Tool.EvadeTaxes.Reflectance = 1
    CombatServiceServer.Stun(Character, 2)

    Humanoid.WalkSpeed = 2

    local Mirror = Instance.new("BoolValue")
    Mirror.Parent = Character

    Debris:AddItem(Mirror, 2)

    task.wait(2)
    Tool.EvadeTaxes.Reflectance = 0
    Humanoid.WalkSpeed = 16

    task.wait()
    return true
end

return Default