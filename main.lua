-- Table principale de la bibliothèque
local XyloKitUI = {}

-- Services Roblox nécessaires
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Attendre que le jeu et le joueur soient chargés
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

-- Configuration initiale
local player = waitForGameLoaded()
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XyloKitUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Thème personnalisé
local Themes = {
    Dark = {
        MainBackground = Color3.fromRGB(20, 20, 20), -- #141414
        TabBackground = Color3.fromRGB(30, 30, 30), -- #1E1E1E
        SectionBackground = Color3.fromRGB(35, 35, 35), -- #232323
        TextColor = Color3.fromRGB(255, 40, 40), -- #FF2828
        TextHoverColor = Color3.fromRGB(255, 40, 40), -- Same as TextColor to avoid red intensification
        BorderColor = Color3.fromRGB(15, 15, 15), -- #0F0F0F (very dark gray for borders)
        SelectedTabColor = Color3.fromRGB(15, 15, 15), -- #0F0F0F (very dark gray for selected tab outline)
        ButtonBackground = Color3.fromRGB(30, 30, 30), -- #1E1E1E
        ButtonHoverBackground = Color3.fromRGB(45, 45, 45), -- #2D2D2D
        SelectedTabBackground = Color3.fromRGB(40, 40, 40), -- #282828
        ShadowColor = Color3.fromRGB(0, 0, 0) -- For subtle shadow effect
    }
}

local currentTheme = Themes.Dark

-- Gestion de la configuration
local config = {}
local configFileName = "XyloKitUI_Config.json"

local function saveConfig()
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, config)
    if success then
        writefile(configFileName, encoded)
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

-- Détection de l'exécuteur
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

-- Création de la fenêtre principale
function XyloKitUI:CreateWindow(title)
    print("Creating window: " .. title)
    local XyloKitUIWindow = {}
    XyloKitUIWindow.Config = config

    -- Fond principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 800, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -200) -- Centered, lowered
    mainFrame.BackgroundColor3 = currentTheme.MainBackground
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainFrameCorner = Instance.new("UICorner")
    mainFrameCorner.CornerRadius = UDim.new(0, 10)
    mainFrameCorner.Parent = mainFrame

    local mainFrameStroke = Instance.new("UIStroke")
    mainFrameStroke.Thickness = 1
    mainFrameStroke.Color = currentTheme.BorderColor
    mainFrameStroke.Parent = mainFrame

    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = currentTheme.ShadowColor
    shadow.ImageTransparency = 0.7
    shadow.ZIndex = -1
    shadow.Parent = mainFrame

    -- Drag-and-drop
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
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            mainFrame.Position = newPos
            config.WindowPosition = {X = newPos.X.Offset, Y = newPos.Y.Offset}
            saveConfig()
        end
    end)

    if config.WindowPosition then
        mainFrame.Position = UDim2.new(0.5, config.WindowPosition.X, 0.5, config.WindowPosition.Y)
    end

    -- Animation d'ouverture
    mainFrame.Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, 220)
    local tweenOpen = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, mainFrame.Position.Y.Offset)})
    tweenOpen:Play()

    -- Titre
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = currentTheme.TabBackground
    titleLabel.Text = title
    titleLabel.TextColor3 = currentTheme.TextColor
    titleLabel.TextSize = 20
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel

    -- Barre d'onglets
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -160, 0, 40)
    tabBar.Position = UDim2.new(0, 160, 0, 40)
    tabBar.BackgroundColor3 = currentTheme.TabBackground
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding = UDim.new(0, 8)
    tabBarLayout.Parent = tabBar

    -- Barre latérale pour le profil utilisateur
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 160, 1, -40)
    sidebar.Position = UDim2.new(0, 0, 0, 40)
    sidebar.BackgroundColor3 = currentTheme.TabBackground
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    -- Profil du joueur et nom d'utilisateur
    local playerProfileFrame = Instance.new("Frame")
    playerProfileFrame.Size = UDim2.new(1, -10, 0, 40)
    playerProfileFrame.Position = UDim2.new(0, 5, 1, -50)
    playerProfileFrame.BackgroundTransparency = 1
    playerProfileFrame.Parent = sidebar

    local userId = player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size100x100
    local thumbnailContent, _ = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

    local profileIcon = Instance.new("ImageLabel")
    profileIcon.Size = UDim2.new(0, 32, 0, 32)
    profileIcon.Position = UDim2.new(0, 5, 0, 4)
    profileIcon.BackgroundTransparency = 1
    profileIcon.Image = thumbnailContent or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    profileIcon.Parent = playerProfileFrame

    local profileIconCorner = Instance.new("UICorner")
    profileIconCorner.CornerRadius = UDim.new(0, 16)
    profileIconCorner.Parent = profileIcon

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(0, 110, 0, 30)
    usernameLabel.Position = UDim2.new(0, 42, 0, 5)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = player.Name
    usernameLabel.TextColor3 = currentTheme.TextColor
    usernameLabel.TextSize = 15
    usernameLabel.Font = Enum.Font.Gotham
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    usernameLabel.Parent = playerProfileFrame

    -- Zone de contenu des onglets
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -160, 1, -80)
    contentFrame.Position = UDim2.new(0, 160, 0, 80)
    contentFrame.BackgroundColor3 = currentTheme.SectionBackground
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local contentFrameCorner = Instance.new("UICorner")
    contentFrameCorner.CornerRadius = UDim.new(0, 8)
    contentFrameCorner.Parent = contentFrame

    -- Bouton de fermeture
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 34, 0, 34)
    closeButton.Position = UDim2.new(1, -44, 0, 3)
    closeButton.BackgroundColor3 = currentTheme.ButtonBackground
    closeButton.Text = "X"
    closeButton.TextColor3 = currentTheme.TextColor
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.Gotham
    closeButton.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        local tweenClose = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, 220)})
        tweenClose:Play()
        tweenClose.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)

    -- Right Shift toggle
    local isMenuOpen = true
    local defaultPosition = mainFrame.Position
    local hiddenPosition = UDim2.new(0.5, mainFrame.Position.X.Offset, 1.5, 0) -- Off-screen bottom

    local function toggleMenu()
        isMenuOpen = not isMenuOpen
        local targetPos = isMenuOpen and defaultPosition or hiddenPosition
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = targetPos})
        tween:Play()
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleMenu()
        end
    end)

    -- Gestion des onglets
    local tabs = {}
    local currentTab = nil

    -- Fonction pour créer un onglet
    function XyloKitUIWindow:CreateTab(name)
        print("Creating tab: " .. name)
        local tab = {}
        tab.Name = name

        -- Bouton de l'onglet
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 120, 1, 0)
        tabButton.BackgroundColor3 = currentTheme.TabBackground
        tabButton.Text = name
        tabButton.TextColor3 = currentTheme.TextColor
        tabButton.TextSize = 16
        tabButton.Font = Enum.Font.Gotham
        tabButton.BorderSizePixel = 0
        tabButton.Parent = tabBar

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Thickness = 1
        tabStroke.Color = currentTheme.BorderColor
        tabStroke.Parent = tabButton

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 6)
        tabCorner.Parent = tabButton

        -- Effet de survol
        tabButton.MouseEnter:Connect(function()
            if currentTab ~= tab then
                local tweenHover = TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
                tweenHover:Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if currentTab ~= tab then
                local tweenLeave = TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.TabBackground})
                tweenLeave:Play()
            end
        end)

        -- Contenu de l'onglet
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
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
        tabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabContentLayout.Parent = tabContent

        tabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if tabContent.AbsoluteSize.X and tabContent.AbsoluteSize.X > 0 then
                tabContent.CanvasSize = UDim2.new(tabContentLayout.AbsoluteContentSize.X / tabContent.AbsoluteSize.X, 0, 0, 0)
            end
        end)

        tab.Button = tabButton
        tab.Content = tabContent
        tabs[name] = tab

        -- Gestion du clic sur l'onglet
        tabButton.MouseButton1Click:Connect(function()
            if currentTab ~= tab then
                if currentTab then
                    currentTab.Content.Visible = false
                    local tweenDeselect = TweenService:Create(currentTab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.TabBackground})
                    tweenDeselect:Play()
                    currentTab.Button.UIStroke.Color = currentTheme.BorderColor
                end
                local tweenSelect = TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.SelectedTabBackground})
                tweenSelect:Play()
                tabButton.UIStroke.Color = currentTheme.SelectedTabColor
                tabContent.Visible = true
                currentTab = tab
            end
        end)

        -- Fonction pour créer une section dans l'onglet
        function tab:CreateSection(name)
            print("Creating section: " .. name)
            local section = {}
            section.Name = name

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(0, 220, 1, -10)
            sectionFrame.BackgroundColor3 = currentTheme.SectionBackground -- Fixed typo: SectionBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent

            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = sectionFrame

            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Thickness = 1
            sectionStroke.Color = currentTheme.BorderColor
            sectionStroke.Parent = sectionFrame

            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, -10, 0, 25)
            sectionLabel.Position = UDim2.new(0, 5, 0, 5)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = name
            sectionLabel.TextColor3 = currentTheme.TextColor
            sectionLabel.TextSize = 18
            sectionLabel.Font = Enum.Font.Gotham
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionFrame

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 10)
            sectionLayout.Parent = sectionFrame

            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.PaddingLeft = UDim.new(0, 12)
            sectionPadding.PaddingTop = UDim.new(0, 35)
            sectionPadding.PaddingBottom = UDim.new(0, 12)
            sectionPadding.Parent = sectionFrame

            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(0, 220, 0, sectionLayout.AbsoluteContentSize.Y + 50)
            end)

            section.Frame = sectionFrame

            -- Fonction pour créer un toggle
            function section:CreateToggle(name, default, callback)
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, -10, 0, 30)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Parent = sectionFrame

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
                toggleLabel.Position = UDim2.new(0, 5, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = name
                toggleLabel.TextColor3 = currentTheme.TextColor
                toggleLabel.TextSize = 16
                toggleLabel.Font = Enum.Font.Gotham
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame

                local toggleButton = Instance.new("TextButton")
                toggleButton.Size = UDim2.new(0, 28, 0, 28)
                toggleButton.Position = UDim2.new(1, -33, 0, 1)
                toggleButton.BackgroundColor3 = default and currentTheme.TextColor or currentTheme.ButtonBackground
                toggleButton.Text = default and "✔" or ""
                toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleButton.TextSize = 14
                toggleButton.Font = Enum.Font.Code
                toggleButton.Parent = toggleFrame

                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 6)
                toggleCorner.Parent = toggleButton

                local state = default
                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Toggle"
                if config[configKey] ~= nil then
                    state = config[configKey]
                    toggleButton.BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground
                    toggleButton.Text = state and "✔" or ""
                end

                toggleButton.MouseEnter:Connect(function()
                    local tweenHover = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
                    tweenHover:Play()
                end)

                toggleButton.MouseLeave:Connect(function()
                    local tweenLeave = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground})
                    tweenLeave:Play()
                end)

                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    local tween = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground
                    })
                    tween:Play()
                    toggleButton.Text = state and "✔" or ""
                    config[configKey] = state
                    saveConfig()
                    callback(state)
                end)
            end

            -- Fonction pour créer un slider
            function section:CreateSlider(name, min, max, default, callback)
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, -10, 0, 45)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Parent = sectionFrame

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(0.5, 0, 0, 20)
                sliderLabel.Position = UDim2.new(0, 5, 0, 0)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = name .. ": " .. default
                sliderLabel.TextColor3 = currentTheme.TextColor
                sliderLabel.TextSize = 16
                sliderLabel.Font = Enum.Font.Gotham
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame

                local sliderBar = Instance.new("Frame")
                sliderBar.Size = UDim2.new(0.95, -20, 0, 8)
                sliderBar.Position = UDim2.new(0, 10, 0, 25)
                sliderBar.BackgroundColor3 = currentTheme.ButtonBackground
                sliderBar.Parent = sliderFrame

                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(0, 4)
                sliderBarCorner.Parent = sliderBar

                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                sliderFill.BackgroundColor3 = currentTheme.TextColor
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderBar

                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(0, 4)
                sliderFillCorner.Parent = sliderFill

                local sliderButton = Instance.new("TextButton")
                sliderButton.Size = UDim2.new(0, 14, 0, 14)
                sliderButton.Position = UDim2.new((default - min) / (max - min), -7, 0, -3)
                sliderButton.BackgroundColor3 = currentTheme.TextColor
                sliderButton.Text = ""
                sliderButton.Parent = sliderBar

                local sliderButtonCorner = Instance.new("UICorner")
                sliderButtonCorner.CornerRadius = UDim.new(0, 7)
                sliderButtonCorner.Parent = sliderButton

                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Slider"
                if config[configKey] ~= nil then
                    default = config[configKey]
                    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    sliderButton.Position = UDim2.new((default - min) / (max - min), -7, 0, -3)
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
                        local tweenFill = TweenService:Create(sliderFill, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(relativePos, 0, 1, 0)})
                        local tweenButton = TweenService:Create(sliderButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(relativePos, -7, 0, -3)})
                        tweenFill:Play()
                        tweenButton:Play()
                        sliderLabel.Text = name .. ": " .. value
                        config[configKey] = value
                        saveConfig()
                        callback(value)
                    end
                end)
            end

            -- Fonction pour créer un dropdown
            function section:CreateDropdown(name, options, default, callback)
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Size = UDim2.new(1, -10, 0, 30)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Parent = sectionFrame

                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Size = UDim2.new(0.6, 0, 1, 0)
                dropdownLabel.Position = UDim2.new(0, 5, 0, 0)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Text = name .. ": " .. default
                dropdownLabel.TextColor3 = currentTheme.TextColor
                dropdownLabel.TextSize = 16
                dropdownLabel.Font = Enum.Font.Gotham
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame

                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Size = UDim2.new(0, 28, 0, 28)
                dropdownButton.Position = UDim2.new(1, -33, 0, 1)
                dropdownButton.BackgroundColor3 = currentTheme.ButtonBackground
                dropdownButton.Text = "▼"
                dropdownButton.TextColor3 = currentTheme.TextColor
                dropdownButton.TextSize = 14
                dropdownButton.Font = Enum.Font.Code
                dropdownButton.Parent = dropdownFrame

                local dropdownButtonCorner = Instance.new("UICorner")
                dropdownButtonCorner.CornerRadius = UDim.new(0, 6)
                dropdownButtonCorner.Parent = dropdownButton

                dropdownButton.MouseEnter:Connect(function()
                    local tweenHover = TweenService:Create(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
                    tweenHover:Play()
                end)

                dropdownButton.MouseLeave:Connect(function()
                    local tweenLeave = TweenService:Create(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonBackground})
                    tweenLeave:Play()
                end)

                local dropdownList = Instance.new("ScrollingFrame")
                dropdownList.Size = UDim2.new(0.4, 0, 0, 0)
                dropdownList.Position = UDim2.new(0.6, 0, 1, 5)
                dropdownList.BackgroundColor3 = currentTheme.ButtonBackground
                dropdownList.Visible = false
                dropdownList.ScrollBarThickness = 4
                dropdownList.ScrollBarImageColor3 = currentTheme.BorderColor
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 25)
                dropdownList.Parent = dropdownFrame

                local dropdownListCorner = Instance.new("UICorner")
                dropdownListCorner.CornerRadius = UDim.new(0, 6)
                dropdownListCorner.Parent = dropdownList

                local dropdownListLayout = Instance.new("UIListLayout")
                dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownListLayout.Padding = UDim.new(0, 5)
                dropdownListLayout.Parent = dropdownList

                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Dropdown"
                if config[configKey] ~= nil then
                    default = config[configKey]
                    dropdownLabel.Text = name .. ": " .. default
                end

                for _, option in pairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, -8, 0, 20)
                    optionButton.BackgroundColor3 = currentTheme.ButtonBackground
                    optionButton.Text = option
                    optionButton.TextColor3 = currentTheme.TextColor
                    optionButton.TextSize = 14
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Parent = dropdownList

                    local optionButtonCorner = Instance.new("UICorner")
                    optionButtonCorner.CornerRadius = UDim.new(0, 4)
                    optionButtonCorner.Parent = optionButton

                    optionButton.MouseEnter:Connect(function()
                        local tweenHover = TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
                        tweenHover:Play()
                    end)

                    optionButton.MouseLeave:Connect(function()
                        local tweenLeave = TweenService:Create(optionButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonBackground})
                        tweenLeave:Play()
                    end)

                    optionButton.MouseButton1Click:Connect(function()
                        dropdownLabel.Text = name .. ": " .. option
                        local tweenClose = TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.4, 0, 0, 0)})
                        tweenClose:Play()
                        dropdownList.Visible = false
                        config[configKey] = option
                        saveConfig()
                        callback(option)
                    end)
                end

                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                    local targetSize = dropdownList.Visible and UDim2.new(0.4, 0, 0, math.min(#options * 25, 100)) or UDim2.new(0.4, 0, 0, 0)
                    local tweenSize = TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = targetSize})
                    tweenSize:Play()
                end)
            end

            return section
        end

        return tab
    end

    return XyloKitUIWindow
end

-- Renvoyer la table XyloKitUI pour loadstring
return XyloKitUI
