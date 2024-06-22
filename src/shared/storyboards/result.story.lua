local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild('Packages')

local shared = ReplicatedStorage:WaitForChild('Shared')
local coreUI = shared.ui

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)

local story = {
    summary = 'real sigma',

    react = React,
    reactRoblox = ReactRoblox,
    story = function(prop)
        return React.createElement(require(coreUI.result), prop)
    end,
}

return story