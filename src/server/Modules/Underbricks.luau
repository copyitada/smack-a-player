local TweenService = game:GetService("TweenService")
local Underbricks = {}

function Underbricks.CreateBricks(Position, Size, ExcludeList)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.RespectCanCollide = false
    RayParams.FilterDescendantsInstances = ExcludeList

    local Ray = workspace:Raycast(Position + Vector3.new(0, 5), Vector3.new(-90, 0, 0), RayParams)

    if Ray and Ray.Instance then
        local Debree : Part = Instance.new("Part")
        Debree.Color = Ray.Instance.Color
        Debree.Material = Ray.Material
        Debree.Size = Size
        Debree.Position = Ray.Position

        Debree.Rotation = Vector3.new(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180))
        task.delay(8, function()
            TweenService:Create(Debree, TweenInfo.new(2), {Position = Debree.Position + Vector3.new(0, -Size.Y * 2, 0)}):Play()
            task.wait(2)
            Debree:Destroy()
        end)
    end
end

return Underbricks