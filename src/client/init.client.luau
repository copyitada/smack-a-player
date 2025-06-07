local LoadedModules = require(script.LoadedModules)

for _, Module in script:GetDescendants() do
    if not Module:IsA("ModuleScript") then continue end
    LoadedModules[Module.Name] = require(Module)
end

for _, Module in LoadedModules do
    if Module.Init and typeof(Module.Init) == "function" then
        task.spawn(Module.Init)
    end
end