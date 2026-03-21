type Smacker = {
    SmackerName: string,
    Attack: {
        AttackName: string,
        AttackDuration: number,
        AttackDebounce: number
    }
}

local InputController = {}

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

task.wait()

local Player = Players.LocalPlayer
local Character = Player.Character
local Camera = workspace.CurrentCamera

local LastTime = 0

local Humanoid = Character.Humanoid
local Head = Character.Head
local LastHeadCFrame = Head.CFrame
local RootPart = Character.HumanoidRootPart

local Loaded = Player:WaitForChild("Values"):WaitForChild("Loaded")
local ParryCooldown = Player:FindFirstChild("Values"):FindFirstChild("ParryCooldown")
local PlayerUI = Player.PlayerGui

local TimerValue : IntValue = ReplicatedStorage.Value.Time
local CaptionValue : StringValue = ReplicatedStorage.Value.Caption
local TickingSound = ReplicatedStorage["tick"]

local TimerUI = PlayerUI.ToolUI.Topbar.Timer
local CaptionUI = PlayerUI.ToolUI.Topbar.Caption

local MoneyUI = PlayerUI.ToolUI.Money

local MoneyUINewPosition = MoneyUI.Position + UDim2.fromScale(0, -0.05)
local MoneyUINewRotation = 10

local MoneyUIOldPosition = MoneyUI.Position
local MoneyUIOldRotation = 0

local Blocking = false
local Running = false

local Networker = require(ReplicatedStorage.Packages.Networker)
local SpecialAttackDebounce = false

local function GetSmackerInfo() : Smacker
    local Information = Networker.client.new("ToolInputs", InputController):fetch("Information")
    return Information
end

local function SpecialAttack()
    local CooldownList = PlayerUI.ToolUI.CooldownList
    local CooldownBarRaw = ReplicatedStorage:FindFirstChild("CooldownBar")

    local SmackerInformation = GetSmackerInfo()
    local Results = Networker.client.new("ToolInputs", InputController):fetch("SpecialAttack")
    if Results then
        local CooldownBar = CooldownBarRaw:Clone()
        CooldownBar.Parent = CooldownList

        CooldownBar.Visible = true
        SpecialAttackDebounce = true
        CooldownBar.Cooldown.Text = `{SmackerInformation.Attack.AttackName} <b>({SmackerInformation.Attack.AttackDebounce}s)</b>`
        CooldownBar.Bar.Size = UDim2.fromScale(1, 1)

        TweenService:Create(CooldownBar.Bar, TweenInfo.new(SmackerInformation.Attack.AttackDebounce + 1.5), {Size = UDim2.fromScale(0, 1)}):Play()
        for i = SmackerInformation.Attack.AttackDebounce * 10, 1, -1 do
            CooldownBar.Cooldown.Text = `{SmackerInformation.Attack.AttackName} <b>({i/10}s)</b>`
            task.wait(0.1)
        end

        CooldownBar:Destroy()

        print("here")
        Networker.client.new("ToolInputs", InputController):fire("Sparkle", Color3.fromRGB(255, 0, 0))

        SpecialAttackDebounce = false
    end
end

local function Block()
    local CooldownList = PlayerUI.ToolUI.CooldownList
    local CooldownBarRaw = ReplicatedStorage:FindFirstChild("CooldownBar")

    local Results = Networker.client.new("ToolInputs", InputController):fetch("Block", true)
    if Results then
        local CooldownBar = CooldownBarRaw:Clone()
        CooldownBar.Parent = CooldownList

        CooldownBar.Visible = true
        CooldownBar.Cooldown.Text = `Parry <b>(8s)</b>`
        CooldownBar.Bar.Size = UDim2.fromScale(1, 1)

        local ShowCooldown = coroutine.create(function()
            TweenService:Create(CooldownBar.Bar, TweenInfo.new(9.5), {Size = UDim2.fromScale(0, 1)}):Play()
            for i = 80, 1, -1 do
                CooldownBar.Cooldown.Text = `Parry <b>({i/10}s)</b>`
                task.wait(0.1)
            end

            Networker.client.new("ToolInputs", InputController):fire("Sparkle", Color3.fromRGB(255, 255, 255))
            CooldownBar:Destroy()
        end)

        coroutine.resume(ShowCooldown)

        ParryCooldown:GetAttributeChangedSignal("Value"):Connect(function()
            if not ParryCooldown.Value then
                coroutine.close(ShowCooldown)
                CooldownBar:Destroy()

                Networker.client.new("ToolInputs", InputController):fire("Sparkle", Color3.fromRGB(255, 255, 255))
            end
        end)
    end
end

local function InputBegan(Input)
    if Input.KeyCode == Enum.KeyCode.W then
        Running = true
	end

    if Input.KeyCode == Enum.KeyCode.F then
        Block()
    end

    if Input.KeyCode == Enum.KeyCode.R and not SpecialAttackDebounce then
        SpecialAttack()
    end
end

local function InputEnded(Input)
    if Input.KeyCode == Enum.KeyCode.W then
        Running = false
    end
end

local function RenderStepped()
	if Humanoid.Health > 0 then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = Humanoid

        Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp((RootPart.CFrame+Vector3.new(0,1.5,0)):pointToObjectSpace(Head.CFrame.p),0.5)
        LastHeadCFrame = Head.CFrame
    else
        Camera.CameraType = Enum.CameraType.Scriptable
        local TargetCFrame = CFrame.lookAt(
            Camera.CFrame.Position,
            LastHeadCFrame.Position                          -- looking at the head
        )
        Camera.CFrame = Camera.CFrame:Lerp(TargetCFrame, 0.1)

        if Head then LastHeadCFrame = Head.CFrame end
    end

    if not Humanoid.Parent:FindFirstChild("Blocking") and not Humanoid.Parent:FindFirstChild("Stunned") then
        if Running then
            Humanoid.WalkSpeed = 20
        else
            Humanoid.WalkSpeed = 16
        end
    end

    if TimerValue.Value <= 3 then
        TimerUI.TextColor3 = Color3.fromRGB(255,0,0)
    else
        TimerUI.TextColor3 = Color3.fromRGB(255,255,255)
    end

    if TimerValue.Value <= 10 then TickingSound.Volume = .5 else TickingSound.Volume = .1 end
    if TimerValue.Value ~= LastTime then
        TickingSound:Play()
        if TimerValue.Value <= 3 then
            ReplicatedStorage["electronicpingshort.wav"]:Play()
        end
    end
    LastTime = TimerValue.Value

    TimerUI.Text = string.format("[ %02d:%02d ]", TimerValue.Value/60, TimerValue.Value%60)
    CaptionUI.Text = CaptionValue.Value
end

function InputController.Init()
    UserInputService.InputBegan:Connect(InputBegan)
    UserInputService.InputEnded:Connect(InputEnded)

    ContextActionService:BindAction("Block", Block, true, Enum.KeyCode.NumLock)
    ContextActionService:SetTitle("Block", "Block")
    ContextActionService:SetPosition("Block", UDim2.fromScale(.1, .5))

    ContextActionService:BindAction("SpecialAttack", SpecialAttack, true, Enum.KeyCode.KeypadDivide)
    ContextActionService:SetTitle("SpecialAttack", "Ability")
    ContextActionService:SetPosition("SpecialAttack", UDim2.fromScale(.58, -.1))

    if not Loaded.Value then
        MoneyUI.Text = "Fetching profile..."
    end

    Player:WaitForChild("leaderstats").Smacks:GetPropertyChangedSignal("Value"):Connect(function()
        Loaded.Value = true

        MoneyUI.Position = MoneyUINewPosition
        MoneyUI.Rotation = MoneyUINewRotation
        MoneyUI.Text = "$" .. Player.leaderstats.Smacks.Value
        -- MoneyUI.TextColor3 = Color3.fromRGB(255, 255, 0)

        -- TweenService:Create(MoneyUI, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextColor3 = Color3.fromRGB(86, 255, 86) }):Play()
        TweenService:Create(MoneyUI, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = MoneyUIOldPosition, TextColor3 = Color3.fromRGB(86, 255, 86), Rotation = MoneyUIOldRotation }):Play()
    end)

    RunService.RenderStepped:Connect(RenderStepped)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end

return InputController