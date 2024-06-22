
--> Essentials
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TweenService = game:GetService('TweenService')

--> Constants
local TWEEN_INFO = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new()
local THEME = require(ReplicatedStorage.Shared.theme)
local DEFAULTS = {
    ChangeOutlineOnly = false,
    BackgroundColor = THEME.background:Lerp(BLACK, 0.1),
    Size = UDim2.fromOffset(250, 36),

    Position = UDim2.fromOffset(0, 0),
    AnchorPoint = Vector2.new(),

    PlaceholderText = 'Type anything here...',
    DefaultText = '',

    HighlightedColor = THEME.border,
    TextXAlignment = Enum.TextXAlignment.Left,

    OnTextChange = function() end,
    OnFocusLost = function() end
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
    local frameRef = React.useRef()
    local cleaner = Trove.new()

    React.useEffect(function()
        -- selene: allow(multiple_statements)
        while frameRef.current == nil do task.wait() end

        local frame: Frame = frameRef.current
        local outline: UIStroke = frame.UIStroke
        local textBox: TextBox = frame.TextBox

        local outlineInitColor = outline.Color

        local outlineFocused = TweenService:Create(
            outline, TWEEN_INFO, { Color = props.HighlightedColor }
        )

        local outlineFocusLost = TweenService:Create(
            outline, TWEEN_INFO, { Color = outlineInitColor }
        )

        local function textChanged()
            if textBox.ContentText:gsub('%s+', '') == '' then
                textBox.FontFace = THEME.font.regularItalic
            else
                textBox.FontFace = THEME.font.regular
            end
            props.OnTextChange(textBox.ContentText, textBox.Text)
        end

        local function focused()
            outlineFocused:Play()
        end

        local function focusLost()
            outlineFocusLost:Play()
            props.OnFocusLost(textBox.ContentText, textBox.Text)
        end

        local function adaptToScreen()
            textBox.TextSize = textBox.AbsoluteSize.Y * 0.5
        end

        cleaner:Connect(textBox.Focused, focused)
        cleaner:Connect(textBox.FocusLost, focusLost)

        cleaner:Connect(textBox:GetPropertyChangedSignal('Text'), textChanged)
        textChanged()

        cleaner:Connect(textBox:GetPropertyChangedSignal('AbsoluteSize'), adaptToScreen)
        adaptToScreen()

        return function()
            cleaner:Destroy()
        end
    end)

    return React.createElement('Frame', {
        AnchorPoint = props.AnchorPoint,
        BackgroundColor3 = bgColor,
        Position = props.Position,
        Size = props.Size,

        children = props.children,

        ref = frameRef,
    }, {
        React.createElement('UIStroke', {
            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            Color = props.BackgroundColor:Lerp(WHITE, 0.2),

            key = 'UIStroke',
        }),

        React.createElement('UIPadding', {
            PaddingBottom = UDim.new(0.025, 4),
            PaddingLeft = UDim.new(0.02, 4),
            PaddingRight = UDim.new(0.02, 4),
            PaddingTop = UDim.new(0.025, 4),

            key = 'UIPadding',
        }),

        React.createElement('UICorner', {
            CornerRadius = UDim.new(1, 0)
        }),

        React.createElement('TextBox', {
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            AnchorPoint = Vector2.new(0.5, 0.5),

            FontFace = THEME.font.regularItalic,

            Text = props.DefaultText,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextColor3 = isColorBright(bgColor) and THEME.background or THEME.text,
            TextXAlignment = props.TextXAlignment,

            ClearTextOnFocus = false,
            PlaceholderText = props.PlaceholderText,

            key = 'TextBox',
        })
    })
end