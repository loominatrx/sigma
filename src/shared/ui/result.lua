local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild('Packages')

local React = require(Packages.React)
local theme = require(ReplicatedStorage.Shared.theme)

return function()
    return React.createElement('ImageLabel', {
        BackgroundColor3 = theme.background,
        BorderSizePixel = 0,

        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.one * 0.5,

        Image = 'rbxassetid://18143875481',
        ImageColor3 = theme.background,
        ImageTransparency = 0.85,

        ZIndex = 0,
        Visible = false,

        key = 'Result'
    }, {
        React.createElement('Frame', {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(0.75, 0.4),
            AnchorPoint = Vector2.one * 0.5,

            key = 'Container'
        }, {
            React.createElement('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDim.new(-0.1, 0)
            }),

            React.createElement('TextLabel', {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                
                FontFace = theme.font.regular,

                Text = '{player1} is',
                TextScaled = true,
                RichText = true, -- to scale the text further
                TextYAlignment = Enum.TextYAlignment.Center,
                TextColor3 = theme.text,

                key = 'Header'
            }),
            React.createElement('TextLabel', {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.7),
                
                FontFace = theme.font.semibold,

                Text = '100%',
                TextScaled = true,
                RichText = true, -- to scale the text further
                TextYAlignment = Enum.TextYAlignment.Center,
                TextColor3 = theme.text,

                key = 'Percentage'
            }),
            React.createElement('TextLabel', {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0.15),
                
                FontFace = theme.font.regular,

                Text = 'sigma!',
                TextScaled = true,
                RichText = true, -- to scale the text further
                TextYAlignment = Enum.TextYAlignment.Center,
                TextColor3 = theme.text,

                key = 'Sigma'
            }),
            React.createElement('UIScale', {Scale=0, key='UIScale'})
        }),
    })
end