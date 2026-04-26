type Option = {
	Name: string,
	Options: {
		{
			Name: string,
			Description: string,
			Default: boolean,
		}
	},
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Networker = require(ReplicatedStorage.Packages.Networker)
local TemplateButton: TextButton = ReplicatedStorage.Option
local TemplateTitle: Frame = ReplicatedStorage.Title

local SettingsServiceClient = {}
local SettingsRemote = Networker.client.new("Settings", SettingsServiceClient)

local SquareConnection = {}

function SettingsServiceClient.GetInterface(Player: Player)
	local PlayerGui = Player.PlayerGui
	local Settings = PlayerGui:FindFirstChild("Settings")

	if not Settings then
		return
	end
	return Settings
end

function SettingsServiceClient.ToggleInterface(Player: Player)
	local PlayerGui = Player.PlayerGui
	local Settings = PlayerGui:FindFirstChild("Settings")

	if not Settings then
		return
	end
	Settings.Enabled = not Settings.Enabled
end

function SettingsServiceClient.AddTitle(Interface, Title)
	local Clone = TemplateTitle:Clone()
	Clone.Parent = Interface.MainFrame.Master

	Clone:FindFirstChild("Text").Text = Title
end

function SettingsServiceClient.AddOption(Interface, Option, Player : Player)
	local Clone = TemplateButton:Clone()
	Clone.Parent = Interface.MainFrame.Master

	Clone:FindFirstChild("Text").Text = Option.Name
	Clone:FindFirstChild("Description").Text = Option.Description

	if not Option.Function.Slide then
		SettingsServiceClient.InitializeToggle(Clone.Toggle, Option, Player)
	else
		SettingsServiceClient.InitializeSlider(Clone.Slider, Option)
	end
end

function SettingsServiceClient.InitializeToggle(ToggleFrame, Option, Player)
	ToggleFrame.Visible = true

	local Toggle = ToggleFrame:FindFirstChild("Toggle")
	local Square = Toggle:FindFirstChild("TextButton")

	local IsTweening = false
	local TweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local Info = { Position = UDim2.fromScale(0.5, 0), BackgroundColor3 = Color3.fromRGB(13, 238, 18) }
	local Info2 = { Position = UDim2.fromScale(0, 0), BackgroundColor3 = Color3.fromRGB(255, 50, 0) }

	local Values = Player:WaitForChild("Values")
	local Settings = Values:WaitForChild("Settings")

	--[[
	if Option.Default and Option.Default ~= Settings:WaitForChild(Option.Name).Value then
		Square.Position = UDim2.fromScale(0.5, 0)
		Square.BackgroundColor3 = Color3.fromRGB(13, 238, 18)
	end
	Option.Function[Option.Default and "On" or "Off"]()
	]]
	local Value = Settings[Option.Name].Value
	Option.Function[Value and "On" or "Off"]()

	if Value then
		Square.Position = UDim2.fromScale(0.5, 0)
		Square.BackgroundColor3 = Color3.fromRGB(13, 238, 18)
	end
	SettingsRemote:fire("SetValue", Option.Name, Value)

	if SquareConnection[Square] then
		SquareConnection[Square]:Disconnect()
	end
	SquareConnection[Square] = Square.MouseButton1Click:Connect(function()
		if IsTweening then
			return
		end

		IsTweening = true
		if Square.Position == UDim2.fromScale(0.5, 0) then
			SettingsRemote:fire("SetValue", Option.Name, false)

			task.spawn(Option.Function["Off"])
			TweenService:Create(Square, TweenInfo, Info2):Play()
		else
			SettingsRemote:fire("SetValue", Option.Name, true)

			task.spawn(Option.Function["On"])
			TweenService:Create(Square, TweenInfo, Info):Play()
		end

		task.wait(0.2)
		IsTweening = false
	end)
end

function SettingsServiceClient.InitializeSlider(SliderFrame, Option)
	SliderFrame.Visible = true
	local Slider = SliderFrame.Slider

	local Player = game.Players.LocalPlayer
	local Mouse = Player:GetMouse()

	local IsDragging = false

	local Values = Player:WaitForChild("Values")
	local Settings = Values:WaitForChild("Settings")

	local MinimumValue = Option.Function.Minimum
	local MaximumValue = Option.Function.Maximum
	local DefaultValue = Settings[Option.Name].Value

	Slider.Line.TextButton.Position = UDim2.fromScale(DefaultValue / (MaximumValue - MinimumValue), 0.5)
	Option.Function.Slide(DefaultValue)

	Slider.Line.TextButton.MouseButton1Down:Connect(function()
		IsDragging = true
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			IsDragging = false
		end
	end)

	RunService.RenderStepped:Connect(function()
		if IsDragging then
			local FrameAbsolutePosition = Slider.Line.AbsolutePosition.X
			local FrameAbsoluteSize = Slider.Line.AbsoluteSize.X
			local X = Mouse.X

			local Percentage = math.clamp((X - FrameAbsolutePosition) / FrameAbsoluteSize, 0, 1)

			Slider.Line.TextButton.Position = UDim2.fromScale(Percentage, 0.5)
			local FinalValue = math.floor(MinimumValue + (MaximumValue - MinimumValue) * Percentage)

			Slider.Line.TextButton.Text = FinalValue

			SettingsRemote:fire("SetValue", Option.Name, FinalValue)
			Option.Function.Slide(FinalValue)
		end
	end)
end

return SettingsServiceClient
