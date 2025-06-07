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
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

local Humanoid = Player.Character.Humanoid
local Head = Player.Character.Head
local RootPart = Player.Character.HumanoidRootPart

local PlayerUI = Player.PlayerGui

local MoneyUI = PlayerUI.ToolUI.Money

local MoneyUINewPosition = MoneyUI.Position + UDim2.fromScale(0, -0.05)
local MoneyUINewRotation = 10

local MoneyUIOldPosition = MoneyUI.Position
local MoneyUIOldRotation = 0

local Blocking = false

local Networker = require(ReplicatedStorage.Packages.Networker)
local SpecialAttackDebounce = false

local function GetSmackerInfo() : Smacker
    local Information = Networker.client.new("ToolInputs", InputController):fetch("Information")
    return Information
end

local function InputBegan(Input)
    --[[
    if Input.KeyCode == Enum.KeyCode.LeftControl then
        Running = not Running
        TweenFOV(90)

        repeat task.wait()
            print("running!")
            Humanoid.WalkSpeed = 24
        until not Running

        StopRunning()
	end
    ]]

    if Input.KeyCode == Enum.KeyCode.F then
        Networker.client.new("ToolInputs", InputController):fire("Block", true)
    end

    if Input.KeyCode == Enum.KeyCode.R and not SpecialAttackDebounce then
        local CooldownBar = PlayerUI.ToolUI.CooldownBar

        local SmackerInformation = GetSmackerInfo()
        local Results = Networker.client.new("ToolInputs", InputController):fetch("SpecialAttack")

        if Results then
            CooldownBar.Visible = true

            SpecialAttackDebounce = true
            CooldownBar.Cooldown.Text = `{SmackerInformation.Attack.AttackName} <b>({SmackerInformation.Attack.AttackDebounce}s)</b>`
            CooldownBar.Bar.Size = UDim2.fromScale(1, 1)

            TweenService:Create(CooldownBar.Bar, TweenInfo.new(SmackerInformation.Attack.AttackDebounce + 1.5), {Size = UDim2.fromScale(0, 1)}):Play()
            for i = SmackerInformation.Attack.AttackDebounce * 10, 1, -1 do
                CooldownBar.Cooldown.Text = `{SmackerInformation.Attack.AttackName} <b>({i/10}s)</b>`
                task.wait(0.1)
            end

            CooldownBar.Visible = false

            SpecialAttackDebounce = false
            CooldownBar.Cooldown.Text = "Smash <b>(R)</b>"
        end
    end
end

local function InputEnded(Input)
    --[[
    if Input.KeyCode == Enum.KeyCode.LeftControl then
        Running = false
    end
    ]]
    if Input.KeyCode == Enum.KeyCode.F then
        Networker.client.new("ToolInputs", InputController):fire("Block", false)
    end
end

local function RenderStepped()
	Humanoid.CameraOffset = Humanoid.CameraOffset:Lerp((RootPart.CFrame+Vector3.new(0,1.5,0)):pointToObjectSpace(Head.CFrame.p),0.5)
end

function InputController.Init()
    UserInputService.InputBegan:Connect(InputBegan)
    UserInputService.InputEnded:Connect(InputEnded)

    ContextActionService:BindAction("Block", function()
        Blocking = not Blocking
        Networker.client.new("ToolInputs", InputController):fire("Block", Blocking)
    end, true, Enum.KeyCode.NumLock)

    Player:WaitForChild("leaderstats").Smacks:GetPropertyChangedSignal("Value"):Connect(function()
        MoneyUI.Position = MoneyUINewPosition
        MoneyUI.Rotation = MoneyUINewRotation
        MoneyUI.Text = Player.leaderstats.Smacks.Value .. " Smacks"
        MoneyUI.TextColor3 = Color3.fromRGB(255, 255, 0)

        TweenService:Create(MoneyUI, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = MoneyUIOldPosition, TextColor3 = Color3.fromRGB(255, 255, 255), Rotation = MoneyUIOldRotation }):Play()
    end)

    RunService.RenderStepped:Connect(RenderStepped)
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end

return InputController