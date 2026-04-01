type SmackerInformation = {
    SmackerName : string,
    Shop : {
        Price : number
    },
    Attack : {
        AttackName : string,
        AttackDuration : number,
        AttackDeboucne : number
    }
}

task.wait()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Networker = require(ReplicatedStorage.Packages.Networker)
local ToolServiceUtils = require(ReplicatedStorage.Shared.Services.ToolService.ToolServiceUtils)

local Hover = ReplicatedStorage.hover
local Click = ReplicatedStorage.click
local Buy = ReplicatedStorage.buy
local Fail = ReplicatedStorage.fail

local ShopServiceClient = {}

local function Notification(NTitle, NDescription)
	StarterGui:SetCore("SendNotification", {
		Title = NTitle,
		Text = NDescription .. "\n",
		Icon = "http://www.roblox.com/asset/?id=109683743467986"
	})
	ReplicatedStorage["notification_ping"]:Play()
end

function ShopServiceClient.GetInterface(Player : Player)
    local ShopUI = Player.PlayerGui:FindFirstChild("Shop")
    if not ShopUI then return nil end

    local MainFrame = ShopUI:FindFirstChild("MainFrame")
    if not MainFrame then return end

    return MainFrame
end

function ShopServiceClient.ClickEffect(Button : TextButton, ClickSound : boolean, Color : Color3?)
    if ClickSound then
        Click:Play()
    end
    
    Button.BackgroundColor3 = Color or Color3.fromRGB(255,255,255)

    TweenService:Create(Button, TweenInfo.new(.2), {
        BackgroundColor3 = Color3.fromRGB(0,0,0)
    }):Play()
end

function ShopServiceClient.HoverLeave(Button : TextButton)
    local OriginSize = Button.Size
    local NewSize = OriginSize + UDim2.fromScale(.02, .02)

    Button.MouseEnter:Connect(function()
        Hover:Play()

        TweenService:Create(Button, TweenInfo.new(.2), {
            Size = NewSize
        }):Play()
    end)

    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(.2), {
            Size = OriginSize
        }):Play()
    end)
end

function ShopServiceClient.ButtonTrigger(Player : Player, Button : TextButton, Description : Frame)
    ShopServiceClient.ClickEffect(Button, true)
    local Unlock = Description:FindFirstChild("Unlock")
    local Price = Description:FindFirstChild("Price")

    local SmackerName = Button.Name
    -- local ViewportFrame = Description:FindFirstChild("ViewportFrame")

    Unlock.BuyButton.Text = "..."

    local SmackerInformation : SmackerInformation = ToolServiceUtils.GetInformation(nil, SmackerName)
    Price.Text = SmackerInformation.Shop.Price .. " Smacks"

    local ViewportFrame = Description:FindFirstChild("ViewportFrame")

    ShopServiceClient.HideEveryItem(ViewportFrame)
    Networker.client.new("Shop", ShopServiceClient):fire("DisplayItem", SmackerName)

    local ItemUnlocked = Networker.client.new("Shop", ShopServiceClient):fetch("HasUnlockedSmacker", SmackerName)
    print(ItemUnlocked)

    if ItemUnlocked then
        print("item is unlocked")
        Unlock.BuyButton.Text = "Equip"
    else
        Unlock.BuyButton.Text = "Unlock"
    end

    local Values = Player:FindFirstChild("Values")
    local ValuesSmackerName = Values.SmackerName

    if ValuesSmackerName.Value == Button.Name then
        Unlock.BuyButton.Text = "Equipped"
    end

    Unlock.MouseButton1Click:Connect(function()
        if Unlock.BuyButton.Text == "Unlock" then
            local Eligible = Networker.client.new("Shop", ShopServiceClient):fetch("UnlockSmacker", Button.Name)
            if Eligible then
                Buy:Play()
                ShopServiceClient.ClickEffect(Unlock, false, Color3.fromRGB(0, 255, 0))

                Unlock.BuyButton.Text = "Equip"
            else
                Fail:Play()
                ShopServiceClient.ClickEffect(Unlock, false, Color3.fromRGB(255, 0, 0))
            end
        else
            ShopServiceClient.ClickEffect(Unlock, true)

            local Result = ReplicatedStorage.Remotes.ChangeSmacker:InvokeServer(Button.Name)
			if not Result then
				Notification("NOTIFICATION", "CANNOT CHANGE SMACKERS IN-GAME, TRY AGAIN LATER")
			else
                Unlock.BuyButton.Text = "Equipped"
				Notification("NOTIFICATION", "YOU ARE CURRENTLY USING THIS SMACKER")
			end
        end
    end)

    ShopServiceClient.RotateEveryItem(ViewportFrame)
end

function ShopServiceClient.DisplayButton(Player : Player, MainFrame : Frame, SmackerName : string) : TextButton
    local Master = MainFrame:FindFirstChild("Master")
    local Description = MainFrame:FindFirstChild("Description")

    local Button : TextButton = ReplicatedStorage.DefaultButton:Clone()
    Button.Parent = Master
    Button.Name = SmackerName

    local SmackerNameText = Button:FindFirstChild("SmackerName")
    SmackerNameText.Text = SmackerName

    ShopServiceClient.HoverLeave(Button)

    Button.MouseButton1Click:Connect(function()
        ShopServiceClient.ButtonTrigger(Player, Button, Description)
    end)

    return Button
end

function ShopServiceClient.DisplayItem(ViewportFrame : ViewportFrame, Tool : Tool) : Tool
    local ToolClone = Tool:Clone()
    ToolClone.Parent = ViewportFrame
    
    Tool:PivotTo(ReplicatedStorage.Default:GetPivot())

    return ToolClone
end

function ShopServiceClient.HideEveryItem(ViewportFrame : ViewportFrame)
    for _, Tool in ViewportFrame:GetChildren() do
        if not Tool:IsA("Tool") then continue end

        Tool:Destroy()
    end
end

function ShopServiceClient.RotateEveryItem(ViewportFrame : ViewportFrame)
    for _, Tool in ViewportFrame:GetChildren() do
        if not Tool:IsA("Tool") then continue end

        Tool:PivotTo(ReplicatedStorage.Default:GetPivot())

        task.spawn(function()
            print("initiate rotate")

            local Angle = 0
            local BaseCFrame = Tool:GetPivot()

            while Tool and Tool.Parent do
                task.wait()

                Angle += 1
                Tool:PivotTo(BaseCFrame * CFrame.Angles(0, math.rad(Angle), 0))
            end
        end)
    end
end

return ShopServiceClient