local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.Server.Modules.DataManager)
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)
local SettingsServiceServer = {}

function SettingsServiceServer.AddValue(Player: Player, Option)
	local Values = ValueServiceServer.GetValues(Player)
	if not Values then
		return
	end

	local Settings = Values:FindFirstChild("Settings")
	if not Settings then
		Settings = Instance.new("Folder")

        Settings.Parent = Values
        Settings.Name = "Settings"
	end

	if Settings:FindFirstChild(Option.Name) then return end
    local OptionValue = Option.Function.Slide and Instance.new("IntValue") or Instance.new("BoolValue")
    OptionValue.Name = Option.Name
    OptionValue.Parent = Settings
end

function SettingsServiceServer.GetSettingsValues(Player : Player)
    local Values = ValueServiceServer.GetValues(Player)
	if not Values then
		return
	end

	local Settings = Values:FindFirstChild("Settings")
	if not Settings then
		Settings = Instance.new("Folder")

        Settings.Parent = Values
        Settings.Name = "Settings"
	end

    return Settings
end

function SettingsServiceServer.GetInstanceValue(Player : Player, OptionName)
    local Settings = SettingsServiceServer.GetSettingsValues(Player)
    return Settings[OptionName] or nil
end

function SettingsServiceServer.SetValue(Player : Player, OptionName, Value)
    local SettingsValue = SettingsServiceServer.GetInstanceValue(Player, OptionName)
    SettingsValue.Value = Value

	DataManager.SetSettingsValue(Player, OptionName, Value)
end

return SettingsServiceServer
