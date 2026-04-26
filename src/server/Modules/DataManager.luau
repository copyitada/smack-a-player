local DataManager = {}

DataManager.Profiles = {}

function DataManager.AddSmacks(Player, Amount: number?)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end

	if not Amount then
		Profile.Data.Smacks += 1
	else
		Profile.Data.Smacks += Amount
	end

	local leaderstats = Player:FindFirstChild("leaderstats")
	if leaderstats then
		if not Amount then
			leaderstats.Smacks.Value += 1
		else
			leaderstats.Smacks.Value += Amount
		end
	end
end

function DataManager.GetSmacks(Player)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end

	return Profile.Data.Smacks
end

function DataManager.UnlockSmacker(Player, SmackerName)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end

	table.insert(Profile.Data.BoughtSmackers, SmackerName)
end

function DataManager.GetUnlockedSmackers(Player)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end

	return Profile.Data.BoughtSmackers
end

function DataManager.ClearSmackers(Player)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end

	Profile.Data.BoughtSmackers = { "Default" }
end

function DataManager.SetSmacker(Player, SmackerName)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end

	Profile.Data.SmackerName = SmackerName
end

function DataManager.GetSmacker(Player)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end

	return Profile.Data.SmackerName
end

function DataManager.SetSettingsValue(Player, OptionName, Value)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end
    
    Profile.Data.Settings[OptionName] = Value
end

function DataManager.GetSettingsValue(Player, OptionName)
	local Profile = DataManager.Profiles[Player]
	if not Profile then
		return
	end

	return Profile.Data.Settings[OptionName] or false
end

return DataManager
