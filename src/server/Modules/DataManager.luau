local DataManager = {}

DataManager.Profiles = {}

function DataManager.AddSmacks(Player)
    local Profile = DataManager.Profiles[Player]
    if not Profile then return end

    Profile.Data.Smacks += 1
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats.Smacks.Value += 1
    end
end

function DataManager.SetSmacker(Player, SmackerName)
    local Profile = DataManager.Profiles[Player]
    if not Profile then return end

    Profile.Data.SmackerName = SmackerName
end

function DataManager.GetSmacker(Player)
    local Profile = DataManager.Profiles[Player]
    if not Profile then return end

    return Profile.Data.SmackerName
end

return DataManager