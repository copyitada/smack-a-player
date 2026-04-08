local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ValueServiceServer = require(ServerScriptService.Server.Services.ValueService.ValueServiceServer)
local RoundServiceUtils = {}

RoundServiceUtils.Settings = {
    INTERMISSION_TIMER = {
        STUDIO = 30,
        PUBLIC = 30
    },
    REQUIRED_PLAYERS = {
        STUDIO = 1,
        PUBLIC = 2
    },
    ROUND_DURATION = {
        STUDIO = 30,
        PUBLIC = 150
    },
}

local SettingsRequiredPlayers = RoundServiceUtils.Settings.REQUIRED_PLAYERS
local RequiredPlayers = RunService:IsStudio() and SettingsRequiredPlayers.STUDIO or SettingsRequiredPlayers.PUBLIC

function RoundServiceUtils.ActionToAllPlayers(func)
    for _, Player in Players:GetPlayers() do
        if ValueServiceServer.GetValues(Player).AFK.Value then continue end

        pcall(function()
            func(Player)  
        end)
    end
end

function RoundServiceUtils.CheckPlayers()
    local PlayingPlayers = Players:GetPlayers()
    local NotAFK = {}

    for _, Player in PlayingPlayers do
        if ValueServiceServer.GetValues(Player).AFK.Value then continue end
        table.insert(NotAFK, Player)
    end

    if #NotAFK < RequiredPlayers then
        return false
    else
        return true
    end
end

return RoundServiceUtils