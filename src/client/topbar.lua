local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild('Packages')

local Knit = require(Packages.Knit)
local Icon = require(Packages.Icon)

local topbar = Knit.CreateController {
    Name = 'topbar'
}

function topbar:hide()
    Icon.setTopbarEnabled(false)
end

function topbar:show()
    Icon.setTopbarEnabled(true)
end

function topbar:KnitStart()
    local donate = Icon.new()
        :setImage('rbxassetid://18156892780')
        :setLabel('Donate')
        :oneClick()
    
    donate.deselected:Connect(function()
        MarketplaceService:PromptProductPurchase(Players.LocalPlayer, 1855524836)
    end)
end

return topbar