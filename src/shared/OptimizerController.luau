local OptimizerController = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

local CONFIG = {
    StreamFolder   = workspace:WaitForChild("StreamParts"),
    LoadDistance   = 512,
    UnloadDistance = 1024,
    CheckInterval  = 0,
}

local PartCache = {}
local CacheFolder = ReplicatedStorage:FindFirstChild("PartCache")

local LastCheck = 0

local function IsPlayerOnOrNear(Part)
    local RayOrigin = RootPart.Position
    local RayDirection = Vector3.new(0, -5, 0)
    local RaycastResult = workspace:Raycast(RayOrigin, RayDirection, RaycastParams.new())
    if RaycastResult and RaycastResult.Instance == Part then
        return true
    end

    local LocalPos = Part.CFrame:PointToObjectSpace(RootPart.Position)
    local HalfSize = Part.Size / 2 + Vector3.new(2, 4, 2)
    if  math.abs(LocalPos.X) <= HalfSize.X
    and math.abs(LocalPos.Y) <= HalfSize.Y
    and math.abs(LocalPos.Z) <= HalfSize.Z then
        return true
    end

    return false
end

local function ShouldBeRendered(Part)
    local CamCFrame = Camera.CFrame
    local HalfSize = Part.Size / 2

    local Corners = {
        Vector3.new( HalfSize.X,  HalfSize.Y,  HalfSize.Z),
        Vector3.new(-HalfSize.X,  HalfSize.Y,  HalfSize.Z),
        Vector3.new( HalfSize.X, -HalfSize.Y,  HalfSize.Z),
        Vector3.new(-HalfSize.X, -HalfSize.Y,  HalfSize.Z),
        Vector3.new( HalfSize.X,  HalfSize.Y, -HalfSize.Z),
        Vector3.new(-HalfSize.X,  HalfSize.Y, -HalfSize.Z),
        Vector3.new( HalfSize.X, -HalfSize.Y, -HalfSize.Z),
        Vector3.new(-HalfSize.X, -HalfSize.Y, -HalfSize.Z),
    }

    for _, Offset in ipairs(Corners) do
        local WorldCorner = Part.CFrame * Offset
        local DirectionToCorner = (WorldCorner - CamCFrame.Position).Unit
        local Dot = CamCFrame.LookVector:Dot(DirectionToCorner)
        if Dot > 0.5 then
            return true
        end
    end

    if IsPlayerOnOrNear(Part) then
        return true
    end

    return false
end

local function RegisterPart(Part)
    if PartCache[Part] then return end
    Part.CastShadow = false
    PartCache[Part] = {
        Transparency = Part.Transparency,
        CanCollide   = Part.CanCollide,
        Parent       = Part.Parent,
    }
end

local function LoadPart(Part)
    local Cache = PartCache[Part]
    if not Cache then return end

    Part.CanCollide = Cache.CanCollide
    Part.Parent = ShouldBeRendered(Part) and Cache.Parent or CacheFolder
end

local function UnloadPart(Part)
    Part.CanCollide = false
    Part.Parent = CacheFolder
end

local function RestoreAllParts()
    for _, Part in ipairs(CacheFolder:GetChildren()) do
        local Cache = PartCache[Part]
        if Cache then
            Part.Parent = Cache.Parent
        end
    end

    -- then reload based on distance
    for Part in pairs(PartCache) do
        LoadPart(Part)
    end
end

function OptimizerController.Init()
    for _, Part in ipairs(CONFIG.StreamFolder:GetDescendants()) do
        if Part:IsA("BasePart") then
            RegisterPart(Part)
        end
    end

    CONFIG.StreamFolder.DescendantAdded:Connect(function(Part)
        if Part:IsA("BasePart") then
            RegisterPart(Part)
        end
    end)

    Player.CharacterAdded:Connect(function(NewCharacter)
        Character = NewCharacter
        RootPart = NewCharacter:WaitForChild("HumanoidRootPart")
        RestoreAllParts()
    end)

    RunService.Heartbeat:Connect(function()
        local Now = tick()
        if Now - LastCheck < CONFIG.CheckInterval then return end
        LastCheck = Now

        if not RootPart or not RootPart.Parent then return end
        local PlayerPosition = RootPart.Position

        for Part in pairs(PartCache) do
            if not Part.Parent then
                PartCache[Part] = nil
                continue
            end

            local Distance = (Part.Position - PlayerPosition).Magnitude

            if Distance <= CONFIG.LoadDistance then
                LoadPart(Part)
            elseif Distance >= CONFIG.UnloadDistance then
                UnloadPart(Part)
            end
        end
    end)
end

return OptimizerController