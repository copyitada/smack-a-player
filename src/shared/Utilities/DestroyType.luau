return function (ObjectType : string, Target, Descendant : boolean?)

    if Descendant then
        for _, Object in Target:GetDescendants() do
            if Object:IsA(ObjectType) then Object:Destroy() end
        end
    else
        for _, Object in Target:GetChildren() do
            if Object:IsA(ObjectType) then Object:Destroy() end
        end
    end
end