local theme = {}

theme.fontId = 'rbxassetid://11702779409'

theme.background = Color3.fromHex('#1F282E')
theme.text = Color3.fromHex('#F1F1F1')
theme.main = theme.background:Lerp(theme.text, 0.25)
theme.secondary = theme.background:Lerp(theme.text, 0.15)
theme.border = theme.background:Lerp(theme.text, 0.5)

theme.font = {
    regular = Font.new(theme.fontId),
    regularItalic = Font.new(theme.fontId, Enum.FontWeight.Regular, Enum.FontStyle.Italic),
    semibold = Font.new(theme.fontId, Enum.FontWeight.SemiBold)
}

return theme