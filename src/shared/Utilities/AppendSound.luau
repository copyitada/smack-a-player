local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")

return function (SoundObject : Sound, Target)
    local Clone = SoundObject:Clone()
    Clone.Parent = Target
    Clone.SoundGroup = SoundService.Master.SFX

    Clone:Play()
    Debris:AddItem(Clone, Clone.TimeLength + .1)
end