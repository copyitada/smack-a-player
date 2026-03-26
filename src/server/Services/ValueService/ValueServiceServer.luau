local ValueServiceServer = {}

function ValueServiceServer.GetValues(Player : Player)
    local Values = Player:FindFirstChild("Values")
    return Values
end

return ValueServiceServer