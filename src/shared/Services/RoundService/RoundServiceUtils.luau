local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RoundServiceUtils = {}

RoundServiceUtils.Settings = {
    INTERMISSION_TIMER = {
        STUDIO = 15,
        PUBLIC = 30
    },
    REQUIRED_PLAYERS = {
        STUDIO = 1,
        PUBLIC = 2
    },
    ROUND_DURATION = {
        STUDIO = 15,
        PUBLIC = 150
    },
}

local SettingsRequiredPlayers = RoundServiceUtils.Settings.REQUIRED_PLAYERS
local RequiredPlayers = RunService:IsStudio() and SettingsRequiredPlayers.STUDIO or SettingsRequiredPlayers.PUBLIC

function RoundServiceUtils.ActionToAllPlayers(func)
    for _, Player in Players:GetPlayers() do
        pcall(function()
            func(Player)  
        end)
    end
end

function RoundServiceUtils.CheckPlayers()
    if #Players:GetPlayers() < RequiredPlayers then
        return false
    else
        return true
    end
end

return RoundServiceUtils