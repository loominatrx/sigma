local ReplicatedStorage = game:GetService("ReplicatedStorage")
--> Essentials
local React = require(ReplicatedStorage.Packages.React)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TweenService = game:GetService('TweenService')

--> Constants
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local THEME = require(ReplicatedStorage.Shared.theme)

local DEFAULTS = {
    ChangeOutlineOnly = false,
    UsePadding = true,

    BackgroundColor = THEME.main,
    Size = UDim2.fromOffset(200, 50),

    Position = UDim2.fromOffset(0, 0),
    AnchorPoint = Vector2.new(),
    Rotation = 0,
    Transparency = 0,

    Text = 'Sample Text',

    Enabled = true,
    Callback = function() end,

    Events = {}
}

--> Types
export type ButtonProperties = {
    Text: any,
    UsePadding: boolean?,

    BackgroundColor: Color3?,
    Position: UDim2?,

    Size: UDim2?,
    Rotation: number?,
    AnchorPoint: Vector2?,
    Transparency: number?,

    ChangeOutlineOnly: boolean?,

    Enabled: boolean?,
    Callback: () -> ()?,

    Events: {[string]: (Instance, ...any) -> any}?
}

-- Thank you to some strangers on StackOverflow:
-- https://stackoverflow.com/questions/11867545/change-text-color-based-on-brightness-of-the-covered-background-area
function isColorBright(Color3: Color3)
    local r, g, b = math.floor(Color3.R * 255), math.floor(Color3.G * 255), math.floor(Color3.B * 255)
    local brightness = math.floor(((r * 299) + (g * 587) + (b * 114)) / 1000)

    return brightness > 125
end

return function(props)
    props = TableUtil.Reconcile(props, DEFAULTS)
    local bgColor = (props.ChangeOutlineOnly and DEFAULTS.BackgroundColor) or props.BackgroundColor
    local buttonRef = React.useRef()
    local cleaner = Trove.new()

    React.useEffect(function()
        -- selene: allow(multiple_statements)
        while buttonRef.current == nil do task.wait() end
        local button: TextButton = buttonRef.current

        local tweens = {}
        tweens.hover = TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = bgColor:Lerp(BLACK, 0.2)
        })
        tweens.down = TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = bgColor:Lerp(WHITE, 0.5)
        })
        tweens.initial = TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = bgColor
        })

        local disabled = {}
        local disabledColor = bgColor:Lerp(BLACK, 0.6)
        disabled.hover = TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = disabledColor:Lerp(BLACK, 0.2)
        })
        disabled.down = TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = disabledColor:Lerp(WHITE, 0.5)
        })
        disabled.initial = TweenService:Create(button, TWEEN_INFO, {
            BackgroundColor3 = disabledColor
        })

        local function playTween(name)
            if button:GetAttribute('Enabled') == true then
                tweens[name]:Play()
            elseif button:GetAttribute('Enabled') == false then
                disabled[name]:Play()
            end
        end

        cleaner:Connect(button.MouseButton1Down, function()
            playTween('down')
        end)

        cleaner:Connect(button.MouseButton1Up, function()
            playTween('initial')
        end)

        cleaner:Connect(button.MouseEnter, function()
            playTween('hover')
        end)

        cleaner:Connect(button.MouseLeave, function()
            playTween('initial')
        end)

        for event, func in props.Events do
            cleaner:Connect(button[event], function(...)
                func(button, ...)
            end)
        end

        cleaner:Connect(button:GetAttributeChangedSignal('Enabled'), function()
            playTween('initial')
        end)
        button:SetAttribute('Enabled', props.Enabled)
    end)

    return React.createElement('TextButton', {
        AutoButtonColor = false,
        FontFace = THEME.font.semibold,

        Text = props.Text,
        RichText = true,
        TextColor3 = isColorBright(bgColor) and THEME.background or THEME.text,

        AnchorPoint = props.AnchorPoint,
        BackgroundColor3 = bgColor,
        BorderSizePixel = 0,

        BackgroundTransparency = props.Transparency,
        Position = props.Position,
        Size = props.Size,
        Rotation = props.Rotation,

        TextScaled = true,
        TextWrapped = true,
        TextStrokeColor3 = BLACK,
        TextStrokeTransparency = isColorBright(bgColor) and 1 or .8,
 
        ref = buttonRef,
        children = props.children,

        [React.Event.Activated] = function(self)
            if self:GetAttribute('Enabled') == true then
                props.Callback()
            end
        end,
    }, {
        React.createElement('UIPadding', {
            PaddingBottom = UDim.new(0.2, 0),
            PaddingLeft = UDim.new(0.05, 0),
            PaddingRight = UDim.new(0.05, 0),
            PaddingTop = UDim.new(0.2, 0),

            key = 'UIPadding'
        }),

        React.createElement('UIStroke', {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = THEME.border,
            Transparency = props.Transparency,

            key = 'UIStroke'
        }),

        React.createElement('UICorner', {
            CornerRadius = UDim.new(1, 0)
        }),
    })
end