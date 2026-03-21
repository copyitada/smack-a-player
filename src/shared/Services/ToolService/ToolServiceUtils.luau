local ToolService = {}

function ToolService.IsHoldingTool(Character)
    for _, Object in Character:GetChildren() do
        if Object:IsA("Tool") then return true, Object end
    end

    return false, nil
end

return ToolService