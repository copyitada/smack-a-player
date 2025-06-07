local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networker = require(ReplicatedStorage.Packages.Networker)

local NetworkerHandler = {}


function NetworkerHandler.Init()
    Networker.server.new("Network", NetworkerHandler, {
        -- NetworkerHandler.ShiftLock
    })
end

function NetworkerHandler:ShiftLock(Player)
    print(Player.Name)
    Player.DevEnableMouseLock = not Player.DevEnableMouseLock
end

return NetworkerHandler