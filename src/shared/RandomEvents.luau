return {
    Revert = function()
        workspace.Gravity = 196.2 
    end,
    Events = {
        EventName = "Low Gravity",
        EventFunction = function()
            workspace.Gravity /= 2
        end
    },
}