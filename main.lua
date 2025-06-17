-- XyloKitUI Library
local XyloKitUI = {}

-- Roblox Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Wait for game and player to load
local function waitForGameLoaded()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    local player = Players.LocalPlayer
    if not player then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        player = Players.LocalPlayer
    end
    return player
end

-- Initialize ScreenGui
local player = waitForGameLoaded()
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XyloKitUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Theme Configuration
local Themes = {
    Dark = {
        MainBackground = Color3.fromRGB(18, 18, 18),
        SidebarBackground = Color3.fromRGB(24, 24, 24),
        ContentBackground = Color3.fromRGB(28, 28, 28),
        AccentColor = Color3.fromRGB(255, 50, 50),
        TextColor = Color3.fromRGB(220, 220, 220),
        TextHoverColor = Color3.fromRGB(255, 255, 255),
        BorderColor = Color3.fromRGB(12, 12, 12),
        ButtonBackground = Color3.fromRGB(32, 32, 32),
        ButtonHoverBackground = Color3.fromRGB(48, 48, 48),
        SelectedTabBackground = Color3.fromRGB(36, 36, 36),
        ShadowColor = Color3.fromRGB(0, 0, 0, 0.5)
    }
}

local currentTheme = Themes.Dark

-- Configuration Management
local config = {}
local configFileName = "XyloKitUI_Config.json"

local function saveConfig()
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, config)
    if success then
        pcall(writefile, configFileName, encoded)
    end
end

local function loadConfig()
    if isfile(configFileName) then
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(configFileName))
        if success then
            config = decoded
        end
    end
end

loadConfig()

-- Executor Detection
local function detectExecutor()
    if isSolara then return "Solara" end
    if xeno or _G.XenoSineWave then return "Xeno" end
    if wearedevs or jjsploit then return "JJSploit" end
    if syn then return "Synapse X" end
    if Krnl then return "Krnl" end
    if http and queue_on_teleport then return "Swift (Approximated)" end
    return "Unknown Executor"
end

print("Detected Executor: " .. detectExecutor())

-- Create Window Function
function XyloKitUI:CreateWindow(title)
    print("Creating window: " .. title)
    local XyloKitUIWindow = {}
    XyloKitUIWindow.Config = config

    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 900, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -300)
    mainFrame.BackgroundColor3 = currentTheme.MainBackground
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainFrameCorner = Instance.new("UICorner")
    mainFrameCorner.CornerRadius = UDim.new(0, 12)
    mainFrameCorner.Parent = mainFrame

    -- Subtle Shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = currentTheme.ShadowColor
    shadow.ImageTransparency = 0.8
    shadow.ZIndex = -1
    shadow.Parent = mainFrame

    -- Drag-and-Drop with Boundary Checks
    local dragging = false
    local dragInput, dragStart, startPos

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, math.clamp(startPos.X.Offset + delta.X, -screenGui.AbsoluteSize.X + 100, screenGui.AbsoluteSize.X - 100),
                startPos.Y.Scale, math.clamp(startPos.Y.Offset + delta.Y, -screenGui.AbsoluteSize.Y + 100, screenGui.AbsoluteSize.Y - 100)
            )
            mainFrame.Position = newPos
            config.WindowPosition = {X = newPos.X.Offset, Y = newPos.Y.Offset}
            saveConfig()
        end
    end)

    if config.WindowPosition then
        mainFrame.Position = UDim2.new(0.5, config.WindowPosition.X, 0.5, config.WindowPosition.Y)
    end

    -- Open Animation
    mainFrame.Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, 300)
    local tweenOpen = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, mainFrame.Position.Y.Offset)})
    tweenOpen:Play()

    -- Title Bar
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 0, 50)
    titleLabel.Position = UDim2.new(0, 200, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = currentTheme.TextColor
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 200, 1, 0)
    sidebar.BackgroundColor3 = currentTheme.SidebarBackground
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 12)
    sidebarCorner.Parent = sidebar

    -- User Profile
    local userId = player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size100x100
    local thumbnailContent, _ = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

    local profileFrame = Instance.new("Frame")
    profileFrame.Size = UDim2.new(1, -20, 0, 80)
    profileFrame.Position = UDim2.new(0, 10, 0, 10)
    profileFrame.BackgroundTransparency = 1
    profileFrame.Parent = sidebar

    local profileIcon = Instance.new("ImageLabel")
    profileIcon.Size = UDim2.new(0, 60, 0, 60)
    profileIcon.Position = UDim2.new(0, 10, 0, 10)
    profileIcon.BackgroundTransparency = 1
    profileIcon.Image = thumbnailContent or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    profileIcon.Parent = profileFrame

    local profileIconCorner = Instance.new("UICorner")
    profileIconCorner.CornerRadius = UDim.new(1, 0)
    profileIconCorner.Parent = profileIcon

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, -80, 0, 30)
    usernameLabel.Position = UDim2.new(0, 80, 0, 25)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = player.Name
    usernameLabel.TextColor3 = currentTheme.TextColor
    usernameLabel.TextSize = 18
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    usernameLabel.Parent = profileFrame

    -- Profile Hover Effect
    profileFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local tweenHover = TweenService:Create(usernameLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextColor3 = currentTheme.TextHoverColor})
            tweenHover:Play()
        end
    end)

    profileFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local tweenLeave = TweenService:Create(usernameLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextColor3 = currentTheme.TextColor})
            tweenLeave:Play()
        end
    end)

    -- Tab List
    local tabList = Instance.new("ScrollingFrame")
    tabList.Size = UDim2.new(1, -20, 1, -100)
    tabList.Position = UDim2.new(0, 10, 0, 90)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 4
    tabList.ScrollBarImageColor3 = currentTheme.BorderColor
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabList.Parent = sidebar

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 8)
    tabListLayout.Parent = tabList

    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y)
    end)

    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -200, 1, -50)
    contentFrame.Position = UDim2.new(0, 200, 0, 50)
    contentFrame.BackgroundColor3 = currentTheme.ContentBackground
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local contentFrameCorner = Instance.new("UICorner")
    contentFrameCorner.CornerRadius = UDim.new(0, 12)
    contentFrameCorner.Parent = contentFrame

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = currentTheme.ButtonBackground
    closeButton.Text = "✕"
    closeButton.TextColor3 = currentTheme.TextColor
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    closeButton.MouseEnter:Connect(function()
        local tweenHover = TweenService:Create(closeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
        tweenHover:Play()
    end)

    closeButton.MouseLeave:Connect(function()
        local tweenLeave = TweenService:Create(closeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonBackground})
        tweenLeave:Play()
    end)

    closeButton.MouseButton1Click:Connect(function()
        local tweenClose = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, 300)})
        tweenClose:Play()
        tweenClose.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)

    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 40, 0, 40)
    minimizeButton.Position = UDim2.new(1, -90, 0, 5)
    minimizeButton.BackgroundColor3 = currentTheme.ButtonBackground
    minimizeButton.Text = "─"
    minimizeButton.TextColor3 = currentTheme.TextColor
    minimizeButton.TextSize = 20
    minimizeButton.Font = Enum.Font.Gotham
    minimizeButton.Parent = mainFrame

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeButton

    minimizeButton.MouseEnter:Connect(function()
        local tweenHover = TweenService:Create(minimizeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
        tweenHover:Play()
    end)

    minimizeButton.MouseLeave:Connect(function()
        local tweenLeave = TweenService:Create(minimizeButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonBackground})
        tweenLeave:Play()
    end)

    local isMinimized = false
    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 900, 0, 50) or UDim2.new(0, 900, 0, 600)
        local tweenSize = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = targetSize})
        tweenSize:Play()
        sidebar.Visible = not isMinimized
        contentFrame.Visible = not isMinimized
    end)

    -- Right Shift Toggle
    local isMenuOpen = true
    local defaultPosition = mainFrame.Position
    local hiddenPosition = UDim2.new(0.5, mainFrame.Position.X.Offset, 1.5, 0)

    local function toggleMenu()
        isMenuOpen = not isMenuOpen
        local targetPos = isMenuOpen and defaultPosition or hiddenPosition
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Position = targetPos})
        tween:Play()
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleMenu()
        end
    end)

    -- Tab Management
    local tabs = {}
    local currentTab = nil

    function XyloKitUIWindow:CreateTab(name)
        print("Creating tab: " .. name)
        local tab = {}
        tab.Name = name

        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.BackgroundColor3 = currentTheme.ButtonBackground
        tabButton.Text = name
        tabButton.TextColor3 = currentTheme.TextColor
        tabButton.TextSize = 16
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.TextScaled = false
        tabButton.Parent = tabList

        local tabButtonPadding = Instance.new("UIPadding")
        tabButtonPadding.PaddingLeft = UDim.new(0, 15)
        tabButtonPadding.Parent = tabButton

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton

        -- Hover Effects
        tabButton.MouseEnter:Connect(function()
            if currentTab ~= tab then
                local tweenHover = TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
                tweenHover:Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if currentTab ~= tab then
                local tweenLeave = TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonBackground})
                tweenLeave:Play()
            end
        end)

        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, -20, 1, -20)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = currentTheme.BorderColor
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Parent = contentFrame

        local tabContentLayout = Instance.new("UIListLayout")
        tabContentLayout.FillDirection = Enum.FillDirection.Horizontal
        tabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabContentLayout.Padding = UDim.new(0, 15)
        tabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        tabContentLayout.Parent = tabContent

        tabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(tabContentLayout.AbsoluteContentSize.X / tabContent.AbsoluteSize.X, 0, 0, 0)
        end)

        tab.Button = tabButton
        tab.Content = tabContent
        tabs[name] = tab

        -- Tab Selection
        tabButton.MouseButton1Click:Connect(function()
            if currentTab ~= tab then
                if currentTab then
                    currentTab.Content.Visible = false
                    local tweenDeselect = TweenService:Create(currentTab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonBackground})
                    tweenDeselect:Play()
                end
                local tweenSelect = TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.SelectedTabBackground})
                tweenSelect:Play()
                tabContent.Visible = true
                currentTab = tab
            end
        end)

        -- Create Section
        function tab:CreateSection(name)
            print("Creating section: " .. name)
            local section = {}
            section.Name = name

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(0, 240, 1, -10)
            sectionFrame.BackgroundColor3 = currentTheme.ButtonBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent

            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 8)
            sectionCorner.Parent = sectionFrame

            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, -20, 0, 30)
            sectionLabel.Position = UDim2.new(0, 10, 0, 10)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = name
            sectionLabel.TextColor3 = currentTheme.TextColor
            sectionLabel.TextSize = 18
            sectionLabel.Font = Enum.Font.GothamBold
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionFrame

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 10)
            sectionLayout.Parent = sectionFrame

            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.PaddingLeft = UDim.new(0, 15)
            sectionPadding.PaddingTop = UDim.new(0, 50)
            sectionPadding.PaddingBottom = UDim.new(0, 15)
            sectionPadding.Parent = sectionFrame

            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(0, 240, 0, sectionLayout.AbsoluteContentSize.Y + 65)
            end)

            section.Frame = sectionFrame

            -- Create Toggle
            function section:CreateToggle(name, default, callback)
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, -20, 0, 35)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Parent = sectionFrame

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
                toggleLabel.Position = UDim2.new(0, 5, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = name
                toggleLabel.TextColor3 = currentTheme.TextColor
                toggleLabel.TextSize = 16
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame

                local toggleButton = Instance.new("TextButton")
                toggleButton.Size = UDim2.new(0, 30, 0, 30)
                toggleButton.Position = UDim2.new(1, -35, 0, 2)
                toggleButton.BackgroundColor3 = default and currentTheme.AccentColor or currentTheme.ButtonBackground
                toggleButton.Text = default and "✔" or ""
                toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleButton.TextSize = 14
                toggleButton.Font = Enum.Font.Code
                toggleButton.Parent = toggleFrame

                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 8)
                toggleCorner.Parent = toggleButton

                local state = default
                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Toggle"
                if config[configKey] ~= nil then
                    state = config[configKey]
                    toggleButton.BackgroundColor3 = state and currentTheme.AccentColor or currentTheme.ButtonBackground
                    toggleButton.Text = state and "✔" or ""
                end

                toggleButton.MouseEnter:Connect(function()
                    local tweenHover = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
                    tweenHover:Play()
                end)

                toggleButton.MouseLeave:Connect(function()
                    local tweenLeave = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and currentTheme.AccentColor or currentTheme.ButtonBackground})
                    tweenLeave:Play()
                end)

                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    local tween = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = state and currentTheme.AccentColor or currentTheme.ButtonBackground
                    })
                    tween:Play()
                    toggleButton.Text = state and "✔" or ""
                    config[configKey] = state
                    saveConfig()
                    callback(state)
                end)
            end

            -- Create Slider
            function section:CreateSlider(name, min, max, default, callback)
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, -20, 0, 50)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Parent = sectionFrame

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(0.5, 0, 0, 25)
                sliderLabel.Position = UDim2.new(0, 5, 0, 0)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = name .. ": " .. default
                sliderLabel.TextColor3 = currentTheme.TextColor
                sliderLabel.TextSize = 16
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame

                local sliderBar = Instance.new("Frame")
                sliderBar.Size = UDim2.new(1, -10, 0, 8)
                sliderBar.Position = UDim2.new(0, 5, 0, 30)
                sliderBar.BackgroundColor3 = currentTheme.ButtonBackground
                sliderBar.Parent = sliderFrame

                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(0, 4)
                sliderBarCorner.Parent = sliderBar

                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                sliderFill.BackgroundColor3 = currentTheme.AccentColor
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderBar

                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(0, 4)
                sliderFillCorner.Parent = sliderFill

                local sliderButton = Instance.new("TextButton")
                sliderButton.Size = UDim2.new(0, 16, 0, 16)
                sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, -4)
                sliderButton.BackgroundColor3 = currentTheme.AccentColor
                sliderButton.Text = ""
                sliderButton.Parent = sliderBar

                local sliderButtonCorner = Instance.new("UICorner")
                sliderButtonCorner.CornerRadius = UDim.new(1, 0)
                sliderButtonCorner.Parent = sliderButton

                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Slider"
                if config[configKey] ~= nil then
                    default = config[configKey]
                    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, -4)
                    sliderLabel.Text = name .. ": " .. default
                end

                local dragging = false
                sliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                    end
                end)

                sliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mousePos = UserInputService:GetMouseLocation()
                        local relativePos = (mousePos.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X
                        relativePos = math.clamp(relativePos, 0, 1)
                        local value = math.floor(min + (max - min) * relativePos)
                        local tweenFill = TweenService:Create(sliderFill, TweenInfo.new(0.1, Enum.EasingStyle), {Size = UDim2.new(relativePos, 0, 1, 0)})
                        local tweenButton = TweenService:Create(sliderButton, TweenInfo.new(0.1), {Position = UDim2.new(relativePos, -8, 0, -4)})
                        tweenFill:Play()
                        tweenButton:Play()
                        sliderLabel.Text = name .. ": " .. value
                        config[configKey] = value
                        saveConfig()
                        callback(value)
                    end
                end)
            end

            -- Create Dropdown
            function section:CreateDropdown(name, options, default, callback)
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Size = UDim2.new(1, -20, 0, 35)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Parent = sectionFrame

                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Size = UDim2.new(0.7, 0, 1, 0)
                dropdownLabel.Position = UDim2.new(0, 5, 0, 0)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Text = name .. ": " .. default
                dropdownLabel.TextColor3 = currentTheme.TextColor
                dropdownLabel.TextSize = 16
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame

                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Size = UDim2.new(0, 30, 0, 30)
                dropdownButton.Position = UDim2.new(1, -35, 0, 2)
                dropdownButton.BackgroundColor3 = currentTheme.ButtonBackground
                dropdownButton.Text = "▼"
                dropdownButton.TextColor3 = currentTheme.TextColor
                dropdownButton.TextSize = 16
                dropdownButton.Font = Enum.Font.Code
                dropdownButton.Parent = dropdownFrame

                local dropdownButtonCorner = Instance.new("UICorner")
                dropdownButtonCorner.CornerRadius = UDim.new(0, 8)
                dropdownButtonCorner.Parent = dropdownButton

                dropdownButton.MouseEnter:Connect(function()
                    local tweenHover = TweenService:Create(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3: currentTheme.ButtonHoverBackground})
                    tweenHover:Play()
                end)

                dropdownButton.MouseLeave:Connect(function()
                    local tweenLeave = TweenService:Create(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3: currentTheme.ButtonBackground})
                    tweenLeave:Play()
                end)

                local dropdownMenu = Instance.new("ScrollingFrame")
                dropdownMenu.Size = UDim2.new(0.5, 0, 0, 0)
                dropdownMenu.Position = UDim2.new(0.5, 0, 1, 5)
                dropdownMenu.BackgroundColor3 = currentTheme.ButtonBackground
                dropdownMenu.Visible = false
                dropdownMenu.ScrollBarThickness = 4
                dropdownMenu.ScrollBarImageColor3 = currentTheme.BorderColor
                dropdownMenu.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
                dropdownMenu.Parent = dropdownFrame

                local dropdownMenuCorner = Instance.new("UICorner")
                dropdownMenuCorner.CornerRadius = UDim.new(0, 8)
                local dropdownMenuLayout = Instance.new("UIListLayout")
                dropdownMenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownMenuLayout.Padding = UDim.new(0, 5)
                dropdownMenuLayout.Parent = dropdownMenu

                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Dropdown"
                if config[configKey] then
                    default = config[configKey]
                    dropdownLabel.Text = name .. ": " .. default
                end

                for _, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, -10, 0, 25)
                    optionButton.BackgroundColor3 = currentTheme.ButtonBackground
                    optionButton.Text = option
                    optionButton.TextColor3 = currentTheme.TextColor
                    optionButton.TextSize = 14
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Parent = dropdownMenu

                    local optionButtonCorner = Instance.new("UICorner")
                    optionButtonCorner.CornerRadius = UDim.new(0, 6)
                    optionButtonCorner.Parent = optionButton

                    optionButton.MouseEnter:Connect(function()
                        local tweenHover = TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3: currentTheme.ButtonHoverBackground})
                        tweenHover:Play()
                    end)

                    optionButton.MouseLeave:Connect(function()
                        local tweenLeave = TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3: currentTheme.ButtonBackground})
                        tweenLeave:Play()
                    end)

                    optionButton.MouseButton1Click:Connect(function()
                        dropdownLabel.Text = name .. ": " .. option
                        local tweenClose = TweenService:Create(dropdownMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.5, 0, 0, 0)})
                        tweenClose:Play()
                        dropdownMenu.Visible = false
                        config[configKey] = option
                        saveConfig()
                        callback(option)
                    end)
                end

                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownMenu.Visible = not dropdownMenu.Visible
                    local targetSize = dropdownMenu.Visible and UDim2.new(0.5, 0, 0, math.min(#options * 30, 120)) or UDim2.new(0.5, 0, 0, 0)
                    local tweenSize = TweenService:Create(dropdownMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = targetSize})
                    tweenSize:Play()
                end)
            end

            return section
        end

        return tab
    end

    return XyloKitUIWindow
end

return XyloKitUI
