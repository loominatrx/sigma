local ContentProvider = game:GetService("ContentProvider")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Packages = ReplicatedStorage:WaitForChild('Packages')

local Camera = workspace.CurrentCamera

local ui = ReplicatedStorage.Shared:WaitForChild('ui')
local textUtils = require(ReplicatedStorage.Shared.textUtils)
local theme = require(ReplicatedStorage.Shared.theme)

local initialScreen = require(ui:WaitForChild('menu'))
local resultScreen = require(ui:WaitForChild('result'))

local React = require(Packages.React)
local ReactRoblox = require(Packages.ReactRoblox)
local Knit = require(Packages.Knit)

local calculateSigma = require(ReplicatedStorage.Shared.calculateSigma)

local controller = Knit.CreateController {
    Name = 'controller'
}

-- ScreenGUI Handle for React
controller.handle = Instance.new('ScreenGui')

-- Configuration for beat calculation
controller.beatCalculationConfig = {
    -- The song's beat per minute (BPM)
    SongBPM = 170,

    -- Song's tempo (1/x). For example: if you assign the value to 4, it'll be 1/4.
    Tempo = 4,
}

controller.sound = {
    bass = SoundService.sound.bass,
    buttonClick = SoundService.sound.buttonClick,
    buttonHover = SoundService.sound.buttonHover,
}

controller.music = {
    menu = SoundService.music.menu_loop,
    reveal = SoundService.music.reveal,
    result = SoundService.music.result,
}

-- React's root
controller.root = nil

-- React components
controller.main = nil
controller.result = nil

controller.flashTween = nil

controller.fullyLoaded = false
controller.doingTheFunny = false

-- this one is used during the reveal section
controller.revealingEmoji = {'rbxassetid://18154928141'}

-- this one is used AFTER the reveal section (a.k.a. result screen)
controller.resultEmoji = {'rbxassetid://18154926664'}

local imageLifetime = 1.42
local forceStopImageSpam = false
local function spamImages(doingTheFunnyCondition: boolean)
    controller.handle.Frame.Effects:ClearAllChildren()
    task.spawn(function()
        while controller.doingTheFunny == doingTheFunnyCondition and forceStopImageSpam == false do
            task.wait( doingTheFunnyCondition == true and 0.05 or 0)
            local emote = Instance.new('ImageLabel')
            local randomPos = UDim2.fromScale((math.random() - 0.5) * 2, (math.random() - 0.5) * 2)
            local centerPos = UDim2.fromScale(0.5, 0.5)

            local starting = controller.doingTheFunny == true and randomPos or centerPos
            local ending = controller.doingTheFunny == true and centerPos or randomPos

            emote.BackgroundTransparency = 1
            emote.BorderSizePixel = 0
            emote.Position = starting
            emote.Size = UDim2.fromScale(0.25, 0.25)
            emote.AnchorPoint = Vector2.one * 0.5
            emote.Image = controller.doingTheFunny == true and controller.revealingEmoji[math.random(#controller.revealingEmoji)]
                or controller.resultEmoji[math.random(#controller.resultEmoji)]
            emote.ImageTransparency = 1
            emote.Parent = controller.handle.Frame.Effects

            Instance.new('UIAspectRatioConstraint').Parent = emote

            task.spawn(function()
                for i = 0, 1, 0.1 do
                    task.wait(controller.doingTheFunny == true and 0.05 or 0.0125)
                    emote.ImageTransparency = (i <= 0.5 and 1 - i) or i
                end
            end)

            TweenService:Create(
                emote, 
                TweenInfo.new(controller.doingTheFunny == true and imageLifetime or imageLifetime / 4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                {
                    Position = ending,
                }
            ):Play()

            Debris:AddItem(emote, imageLifetime)
        end

        forceStopImageSpam = false
    end)
end

function controller:getAspectRatio()
    return Camera.ViewportSize.X / Camera.ViewportSize.Y
end

function controller:setup()
    local container = React.createElement('Frame', {
        BackgroundTransparency = 1,

        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.one * 0.5,
    }, {
        React.createElement(initialScreen), 
        React.createElement(resultScreen),
        React.createElement('Frame', {
            key = 'Flash',

            BackgroundTransparency = 1,
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            AnchorPoint = Vector2.one * 0.5,
            Visible = true,
            ZIndex = 0,
        }),
        React.createElement('Frame', {
            BackgroundTransparency = 1,

            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            AnchorPoint = Vector2.one * 0.5,

            key = 'Effects'
        }),
        React.createElement('ImageLabel', {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
    
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromScale(1, 1),
            AnchorPoint = Vector2.one * 0.5,
    
            Image = 'rbxassetid://18149561618',
            ImageTransparency = 1,

            ZIndex = 10,
    
            key = 'Vignette',
        })
    })

    controller.root:render(container)

    for _, music in controller.music do
        if music.IsPlaying then
            music:Stop()
        end
    end

    if controller.fullyLoaded == false then
        controller.main = controller.handle:WaitForChild('Frame').Main
        controller.result = controller.handle:WaitForChild('Frame').Result
        Instance.new('UIScale').Parent = controller.main.InputBox
        controller.fullyLoaded = true
    else
        -- reset everything
        forceStopImageSpam = true
        controller.main.Visible = true
        controller.result.Visible = false

        -- main
        controller.main.InputBox.UIScale.Scale = 1
        controller.main.InputBox.TextBox.TextEditable = true
        controller.main.Header.Position = UDim2.fromScale(0.5, 0.3)
        controller.main.Proceed.Position = UDim2.new(0.5, 0, 0.6, 78)
        controller.main.InputBox.Position = UDim2.new(0.5, 0, 0.5, 36)
        controller.main.InputBox.Size = UDim2.new(0.4, 60, 0.05, 24)

        -- result
        controller.result.Container.UIScale.Scale = 0

        if controller.flashTween.PlaybackState == Enum.PlaybackState.Playing then
            controller.flashTween:Cancel()
            controller.handle.Frame.Flash.BackgroundTransparency = 1
        end
    end

    controller.music.menu:Play()
end

function controller:calculateSigma(name)
    if controller.doingTheFunny == false then
        controller.doingTheFunny = true
        local sigmaPercent = calculateSigma(name)
        local container = self.handle.Frame.Result.Container

        container.Header.Text = ('%s is'):format(name)
        container.Percentage.Text = tostring(sigmaPercent) .. '%'
        controller.main.InputBox.TextBox.TextEditable = false

        -- the JUICY part.
        controller.music.reveal.Played:Once(function()
            controller.main.Header:TweenPosition(UDim2.fromScale(0.5, -1), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 1.42)
            controller.main.Proceed:TweenPosition(UDim2.fromScale(0.5, 1.5), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 1.42)

            task.delay(4.928, function()
                TweenService:Create(
                    controller.main.InputBox, 
                    TweenInfo.new(1.42, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
                    {
                        Position = UDim2.fromScale(0.5, 0.5)
                    }
                ):Play()
                TweenService:Create(
                    controller.main.InputBox.UIScale, 
                    TweenInfo.new(17.278, Enum.EasingStyle.Linear, Enum.EasingDirection.In),
                    {
                        Scale = 2
                    }
                ):Play()
                TweenService:Create(
                    controller.handle.Frame.Vignette, 
                    TweenInfo.new(17.278, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    {
                        ImageTransparency = 0
                    }
                ):Play()

                task.wait(2)

                spamImages(true)
            end)

            task.delay(10.773, function()
                local size do
                    local aspectRatio = controller:getAspectRatio()
                    local addition = ((aspectRatio >= 0.75 and aspectRatio) or (2 + (8 * aspectRatio))) / 20
                    size = textUtils:GetStringTextBounds(
                        name,
                        theme.font.regular,
                        controller.main.InputBox.TextBox.TextSize
                    )
                    size = UDim2.new(
                        size.X / Camera.ViewportSize.X + addition, 16,
                        size.Y / Camera.ViewportSize.Y + 0.05, 4
                    )
                end

                TweenService:Create(
                    controller.main.InputBox, 
                    TweenInfo.new(0.710, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
                    {
                        Size = size
                    }
                ):Play()
            end)

            task.delay(22.206, function()
                TweenService:Create(
                    controller.main.InputBox.UIScale, 
                    TweenInfo.new(0.381, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    {
                        Scale = 0
                    }
                ):Play()
                TweenService:Create(
                    controller.handle.Frame.Vignette, 
                    TweenInfo.new(0.381, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    {
                        ImageTransparency = 1
                    }
                ):Play()
            end)

            controller.music.reveal.Ended:Once(function()
                controller.music.result:Play()

                controller.main.Visible = false
                controller.result.Visible = true

                controller.handle.Frame.Flash.BackgroundTransparency = 0
                controller.flashTween:Play()

                TweenService:Create(
                    container.UIScale, 
                    TweenInfo.new(0.710, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
                    {
                        Scale = 1
                    }
                ):Play()
                
                controller.doingTheFunny = false
                spamImages(false)
            end)
        end)

        controller.sound.bass:Play()
        controller.music.reveal:Play()
        controller.music.menu:Stop()

    end
end

function controller:KnitInit()
    do
        local success
        while not success do
            success = pcall(StarterGui.SetCoreGuiEnabled, StarterGui, 'All', false)
            if success then
                break
            else
                task.wait(0.2)
            end
        end
    end
    
    local handle = controller.handle
    handle.Name = 'Main'
    handle.ClipToDeviceSafeArea = true
    handle.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension
    handle.ScreenInsets = Enum.ScreenInsets.None
    handle.DisplayOrder = 727 -- WHEN YOU SEE IT
    handle.Parent = Players.LocalPlayer:WaitForChild('PlayerGui')
end

function controller:KnitStart()
    ContentProvider:PreloadAsync({
        table.unpack(controller.music),
        table.unpack(controller.sound),
    })

    ContentProvider:PreloadAsync({
        table.unpack(controller.revealingEmoji),
        table.unpack(controller.resultEmoji)
    })

    controller.root = ReactRoblox.createRoot(controller.handle)
    controller:setup()

    controller.flashTween = TweenService:Create(
        controller.handle:WaitForChild('Frame').Flash :: Frame, 
        TweenInfo.new(0.355, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), 
        {
            BackgroundTransparency = 1
        }
    )
    controller.flashTween.Completed:Connect(function()
        controller.handle.Frame.Flash.BackgroundTransparency = 0.5
    end)

    task.delay(5, function()
        local resetBindable = Instance.new('BindableEvent')
        resetBindable.Event:Connect(function()
            if controller.doingTheFunny then return end
            controller:setup()
        end)
        StarterGui:SetCore('ResetButtonCallback', resetBindable)
    end)
end

return controller