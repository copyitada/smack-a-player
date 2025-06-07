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

return DataManager