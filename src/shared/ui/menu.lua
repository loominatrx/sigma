local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Packages = ReplicatedStorage:WaitForChild('Packages')

local React = require(Packages.React)
local Knit = require(Packages.Knit)
local Promise = require(Packages.Promise)
local theme = require(ReplicatedStorage.Shared.theme)

local components = ReplicatedStorage.Shared.ui.components
local textbox = require(components.textbox)
local button = require(components.button)

-- gui
return function()
    local ref = React.useRef()
    local activePromise

    local function displayError(str)
        local frame = ref.current
        if activePromise ~= nil then
            activePromise:cancel()
        end

        activePromise = Promise.new(function()
            frame.ErrorMsg.Visible = true
            frame.ErrorMsg.Text = str
            frame.ErrorMsg.TextTransparency = 0
            task.wait(2)
            for i = 0, 1, 0.1 do
                task.wait()
                frame.ErrorMsg.TextTransparency = i
            end
            frame.ErrorMsg.Visible = false
            activePromise = nil
        end)
    end

    local function callback()
        local frame = ref.current
        local name = frame.InputBox.TextBox.Text:match("^%s*(.-)%s*$")
        local isEditMode = pcall(RunService.IsEdit, RunService)
        if #name > 0 and not isEditMode then
            Knit.GetController('controller'):calculateSigma(name)
        elseif isEditMode then
            displayError('You aren\'t supposed to test this on edit environment!')
        else
            displayError('How am I supposed to know your sigma percentage if you didn\'t put your name?')
        end
        
    end

    return React.createElement('ImageLabel', {
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,

        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.one * 0.5,

        Image = 'rbxassetid://18143875481',
        ImageColor3 = theme.background,
        ImageTransparency = 0.85,

        key = 'Main',
        ref = ref
    }, {
        React.createElement('Frame', {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.3),
            Size = UDim2.fromScale(0.75, 0.25),
            AnchorPoint = Vector2.one * 0.5,

            key = 'Header'
        }, {
            React.createElement('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(-0.1,0)
            }),

            React.createElement('TextLabel', {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                
                FontFace = theme.font.regular,

                Text = 'How',
                TextScaled = true,
                RichText = true, -- to scale the text further
                TextYAlignment = Enum.TextYAlignment.Center,
                TextColor3 = theme.text,
            }),
            React.createElement('TextLabel', {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.8),
                
                FontFace = theme.font.semibold,

                Text = 'SIGMA',
                TextScaled = true,
                RichText = true, -- to scale the text further
                TextYAlignment = Enum.TextYAlignment.Center,
                TextColor3 = theme.text,
            }),
            React.createElement('TextLabel', {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                
                FontFace = theme.font.regular,

                Text = 'are you?',
                TextScaled = true,
                RichText = true, -- to scale the text further
                TextYAlignment = Enum.TextYAlignment.Center,
                TextColor3 = theme.text,
            })
        }),

        React.createElement(textbox, {
            Size = UDim2.new(0.4, 60, 0.05, 24),
            Position = UDim2.new(0.5, 0, 0.5, 36),
            AnchorPoint = Vector2.one * 0.5,

            TextXAlignment = Enum.TextXAlignment.Center,
            PlaceholderText = 'type your name (or friend\'s name) here...',

            key = 'InputBox'
        }, {
            React.createElement('UIScale', {key='UIScale'})
        }),

        React.createElement('TextLabel', {
            BackgroundTransparency = 1,

            Size = UDim2.new(0.4, 42, 0.025, 16),
            Position = UDim2.new(0.5, 0, 0.6, 28),
            AnchorPoint = Vector2.one * 0.5,
            
            FontFace = theme.font.regular,

            Text = '',
            TextScaled = true,
            RichText = true, -- to scale the text further
            TextYAlignment = Enum.TextYAlignment.Center,
            TextColor3 = theme.text,

            Visible = false,

            key = 'ErrorMsg'
        }),

        React.createElement(button, {
            Size = UDim2.new(0.25, 42, 0.05, 24),
            Position = UDim2.new(0.5, 0, 0.6, 78),
            AnchorPoint = Vector2.one * 0.5,

            TextXAlignment = Enum.TextXAlignment.Center,
            Text = 'see results',

            Callback = callback,

            key = 'Proceed'
        }),
    })
end