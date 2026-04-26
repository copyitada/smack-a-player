local ProfileHandler = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.Server.Modules.DataManager)
local ProfileStore = require(ReplicatedStorage.ServerPackages.ProfileStore)
local DataTemplate = require(ReplicatedStorage.Shared.DataTemplate)

-- The PROFILE_TEMPLATE table is what new Profile "Profile.Data" will default to:
local PROFILE_TEMPLATE = DataTemplate

local PlayerStore = ProfileStore.New("PlayerStore", PROFILE_TEMPLATE)
local Profiles: {[Player]: typeof(PlayerStore:StartSessionAsync())} = DataManager.Profiles

local function Initialize(Player : Player, Profile: typeof(PlayerStore:StartSessionAsync()))
   local leaderstats = Player:FindFirstChild("leaderstats")
   local Values = Player:FindFirstChild("Values")
   local SmackerName = Values:FindFirstChild("SmackerName")

   print(Profile.Data)

   if leaderstats then
      leaderstats.Smacks.Value = Profile.Data.Smacks
   end
   if SmackerName then
      SmackerName.Value = Profile.Data.SmackerName  
   end
   Values.Loaded.Value = true
end

local function PlayerAdded(Player)

   -- Start a Profile session for this player's data:

   local Profile = PlayerStore:StartSessionAsync(`{Player.UserId}`, {
      Cancel = function()
         return Player.Parent ~= Players
      end,
   })

   -- Handling new Profile session or failure to start it:

   if Profile ~= nil then

      Profile:AddUserId(Player.UserId) -- GDPR compliance
      Profile:Reconcile() -- Fill in missing variables from PROFILE_TEMPLATE (optional)

      Profile.OnSessionEnd:Connect(function()
         Profiles[Player] = nil
         Player:Kick(`Profile session end - Please rejoin`)
      end)

      if Player.Parent == Players then
         Profiles[Player] = Profile
         print(`Profile loaded for {Player.DisplayName}!`)
         
        Initialize(Player, Profile)
      else
         -- The player has left before the Profile session started
         Profile:EndSession()
      end

   else
      -- This condition should only happen when the Roblox server is shutting down
      Player:Kick(`Profile load fail - Please rejoin`)
   end

end

-- In case Players have joined the server earlier than this script ran:
for _, player in Players:GetPlayers() do
   task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
   local Profile = Profiles[player]
   if Profile ~= nil then
      Profile:EndSession()
   end
end)

return ProfileHandler