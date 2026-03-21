local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local AppendSound = require(ReplicatedStorage.Shared.Utilities.AppendSound)
local DestroyType = require(ReplicatedStorage.Shared.Utilities.DestroyType)
local EffectService = {}

function EffectService.Sparkle(Player : Player, Color)
    local SparkleCharacter = Player.Character

    DestroyType("Highlight", SparkleCharacter)
    task.spawn(function()
        AppendSound(ServerStorage["sparkle"], SparkleCharacter)
    end)

    local Highlight = Instance.new("Highlight")
    Highlight.Parent = Player.Character
    Highlight.OutlineTransparency = 1
    Highlight.FillColor = Color
    Highlight.FillTransparency = .5

    local SparkleAttachment = ServerStorage["Sparkle"]:Clone()
    SparkleAttachment.Parent = SparkleCharacter:FindFirstChild("HumanoidRootPart")

    local SparkleEffect = SparkleAttachment.ParticleEmitter
    SparkleEffect.Color = ColorSequence.new(Color, Color)
    SparkleEffect:Emit(5)

    Debris:AddItem(SparkleAttachment, 3)
    
    for _ = 1, 0, -.1 do
        task.wait(.1)
        Highlight.FillTransparency += .05
    end

    Highlight:Destroy()
end

return EffectService