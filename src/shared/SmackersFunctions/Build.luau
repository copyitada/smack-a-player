local ServerStorage = game:GetService("ServerStorage")

local Platform = ServerStorage:FindFirstChild("Platform")

-- script update

local Default = {}

local SpecialAttackDebounces = {}

Default.AttackFunction = function(Player : Player)
    local Character = Player.Character
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then return false end

    local Tool = Player.Backpack:FindFirstChild("Build") or Character:FindFirstChild("Build")

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
        
    local Clone = Platform:Clone()
    Clone.Parent = workspace
    Clone.Position = Character:GetPivot().Position + Vector3.new(0,-3,0)

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

return Default