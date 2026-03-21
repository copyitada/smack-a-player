local Debris = game:GetService("Debris")

return function (SoundObject : Sound, Target)
    local Clone = SoundObject:Clone()
    Clone.Parent = Target

    Clone:Play()
    Debris:AddItem(Clone, Clone.TimeLength + .1)
end