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
        MainBackground = Color3.fromRGB(17, 17, 17), -- #111111
        TabBackground = Color3.fromRGB(10, 10, 10), -- #0A0A0A
        SectionBackground = Color3.fromRGB(26, 26, 26), -- #1A1A1A
        TextColor = Color3.fromRGB(255, 0, 0), -- #FF0000
        BorderColor = Color3.fromRGB(51, 51, 51), -- #333333
        ButtonBackground = Color3.fromRGB(20, 20, 20), -- #141414
        GlowColor = Color3.fromRGB(255, 0, 0) -- Rouge pour effet glow
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
    print("Creating window: " .. title) -- Débogage
    local XyloKitUIWindow = {}
    XyloKitUIWindow.Config = config

    -- Fond principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 800, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -400, 0.5, -250)
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

    -- Effet de glow
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857472"
    glow.ImageColor3 = currentTheme.GlowColor
    glow.ImageTransparency = 0.8
    glow.ZIndex = -1
    glow.Parent = mainFrame

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
    mainFrame.Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, 200)
    local tweenOpen = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, mainFrame.Position.Y.Offset)})
    tweenOpen:Play()

    -- Titre
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.BackgroundColor3 = currentTheme.TabBackground
    titleLabel.Text = title
    titleLabel.TextColor3 = currentTheme.TextColor
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.Roboto
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel

    -- Barre d'onglets (à gauche)
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(0, 130, 1, -80)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundColor3 = currentTheme.TabBackground
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection = Enum.FillDirection.Vertical
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding = UDim.new(0, 5)
    tabBarLayout.Parent = tabBar

    -- Profil du joueur (en bas de la barre d'onglets)
    local playerProfileFrame = Instance.new("Frame")
    playerProfileFrame.Size = UDim2.new(1, -10, 0, 40)
    playerProfileFrame.Position = UDim2.new(0, 5, 1, -50)
    playerProfileFrame.BackgroundTransparency = 1
    playerProfileFrame.Parent = tabBar

    local userId = player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size100x100
    local thumbnailContent, _ = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

    local profileIcon = Instance.new("ImageLabel")
    profileIcon.Size = UDim2.new(0, 30, 0, 30)
    profileIcon.Position = UDim2.new(0, 5, 0, 5)
    profileIcon.BackgroundTransparency = 1
    profileIcon.Image = thumbnailContent or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    profileIcon.Parent = playerProfileFrame

    local profileIconCorner = Instance.new("UICorner")
    profileIconCorner.CornerRadius = UDim.new(0, 15)
    profileIconCorner.Parent = profileIcon

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(0, 80, 0, 30)
    usernameLabel.Position = UDim2.new(0, 40, 0, 5)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = player.Name
    usernameLabel.TextColor3 = currentTheme.TextColor
    usernameLabel.TextSize = 14
    usernameLabel.Font = Enum.Font.Roboto
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    usernameLabel.Parent = playerProfileFrame

    -- Zone de contenu des onglets avec défilement
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -130, 1, -80)
    contentFrame.Position = UDim2.new(0, 130, 0, 40)
    contentFrame.BackgroundColor3 = currentTheme.SectionBackground
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.ScrollBarImageColor3 = currentTheme.BorderColor
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = mainFrame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentFrame

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 20)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.Parent = contentFrame

    -- Mettre à jour la taille du Canvas dynamiquement
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, contentLayout.AbsoluteContentSize.X, 0, math.max(contentLayout.AbsoluteContentSize.Y, 420))
    end)

    -- Bouton de fermeture
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = currentTheme.ButtonBackground
    closeButton.Text = "X"
    closeButton.TextColor3 = currentTheme.TextColor
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.Roboto
    closeButton.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        local tweenClose = TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, 200)})
        tweenClose:Play()
        tweenClose.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)

    -- Gestion des onglets
    local tabs = {}
    local currentTab = nil

    -- Fonction pour créer un onglet
    function XyloKitUIWindow:CreateTab(name)
        print("Creating tab: " .. name) -- Débogage
        local tab = {}
        tab.Name = name

        -- Bouton de l'onglet
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.BackgroundColor3 = currentTheme.TabBackground
        tabButton.Text = name
        tabButton.TextColor3 = currentTheme.TextColor
        tabButton.TextSize = 16
        tabButton.Font = Enum.Font.Roboto
        tabButton.BorderSizePixel = 0
        tabButton.Parent = tabBar

        -- Contenu de l'onglet
        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(0, 0, 0, 0) -- Taille initiale, ajustée dynamiquement
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = contentFrame

        local tabContentLayout = Instance.new("UIListLayout")
        tabContentLayout.FillDirection = Enum.FillDirection.Horizontal
        tabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabContentLayout.Padding = UDim.new(0, 10)
        tabContentLayout.Parent = tabContent

        local tabPadding = Instance.new("UIPadding")
        tabPadding.PaddingTop = UDim.new(0, 0)
        tabPadding.Parent = tabContent

        tab.Button = tabButton
        tab.Content = tabContent
        tabs[name] = tab

        -- Gestion du clic sur l'onglet
        tabButton.MouseButton1Click:Connect(function()
            if currentTab ~= tab then
                if currentTab then
                    currentTab.Content.Visible = false
                end
                tabContent.Visible = true
                currentTab = tab
                print("Tab selected: " .. name) -- Débogage
            end
        end)

        -- Fonction pour créer une section dans l'onglet
        function tab:CreateSection(name)
            print("Creating section: " .. name) -- Débogage
            local section = {}
            section.Name = name

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(0, 220, 0, 350)
            sectionFrame.BackgroundColor3 = currentTheme.SectionBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent

            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 6)
            sectionCorner.Parent = sectionFrame

            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Thickness = 1
            sectionStroke.Color = currentTheme.BorderColor
            sectionStroke.Parent = sectionFrame

            -- Effet d'ombre
            local sectionShadow = Instance.new("ImageLabel")
            sectionShadow.Size = UDim2.new(1, 10, 1, 10)
            sectionShadow.Position = UDim2.new(0, -5, 0, -5)
            sectionShadow.BackgroundTransparency = 1
            sectionShadow.Image = "rbxassetid://5028857472"
            sectionShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
            sectionShadow.ImageTransparency = 0.7
            sectionShadow.ZIndex = -1
            sectionShadow.Parent = sectionFrame

            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, -10, 0, 25)
            sectionLabel.Position = UDim2.new(0, 5, 0, 5)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = name
            sectionLabel.TextColor3 = currentTheme.TextColor
            sectionLabel.TextSize = 18
            sectionLabel.Font = Enum.Font.Roboto
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionFrame

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 8)
            sectionLayout.Parent = sectionFrame

            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.PaddingLeft = UDim.new(0, 10)
            sectionPadding.PaddingTop = UDim.new(0, 35)
            sectionPadding.PaddingBottom = UDim.new(0, 10)
            sectionPadding.Parent = sectionFrame

            -- Ajuster dynamiquement la taille de la section
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local contentHeight = sectionLayout.AbsoluteContentSize.Y + 45
                sectionFrame.Size = UDim2.new(0, 220, 0, math.max(350, contentHeight))
            end)

            section.Frame = sectionFrame

            -- Fonction pour créer un toggle
            function section:CreateToggle(name, default, callback)
                print("Creating toggle: " .. name) -- Débogage
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, -20, 0, 30)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Parent = sectionFrame

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
                toggleLabel.Position = UDim2.new(0, 5, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = name
                toggleLabel.TextColor3 = currentTheme.TextColor
                toggleLabel.TextSize = 16
                toggleLabel.Font = Enum.Font.Roboto
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame

                local toggleButton = Instance.new("TextButton")
                toggleButton.Size = UDim2.new(0, 25, 0, 25)
                toggleButton.Position = UDim2.new(1, -30, 0, 2.5)
                toggleButton.BackgroundColor3 = default and currentTheme.TextColor or currentTheme.ButtonBackground
                toggleButton.Text = default and "✔" or ""
                toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                toggleButton.TextSize = 12
                toggleButton.Font = Enum.Font.Roboto
                toggleButton.Parent = toggleFrame

                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 4)
                toggleCorner.Parent = toggleButton

                local state = default
                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Toggle"
                if config[configKey] ~= nil then
                    state = config[configKey]
                    toggleButton.BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground
                    toggleButton.Text = state and "✔" or ""
                end

                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    toggleButton.BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground
                    toggleButton.Text = state and "✔" or ""
                    config[configKey] = state
                    saveConfig()
                    callback(state)
                end)
            end

            -- Fonction pour créer un slider
            function section:CreateSlider(name, min, max, default, callback)
                print("Creating slider: " .. name) -- Débogage
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, -20, 0, 45)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Parent = sectionFrame

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(0.5, 0, 0, 20)
                sliderLabel.Position = UDim2.new(0, 5, 0, 0)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = name .. ": " .. default
                sliderLabel.TextColor3 = currentTheme.TextColor
                sliderLabel.TextSize = 16
                sliderLabel.Font = Enum.Font.Roboto
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame

                local sliderBar = Instance.new("Frame")
                sliderBar.Size = UDim2.new(1, -10, 0, 6)
                sliderBar.Position = UDim2.new(0, 5, 0, 25)
                sliderBar.BackgroundColor3 = currentTheme.ButtonBackground
                sliderBar.Parent = sliderFrame

                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(0, 3)
                sliderBarCorner.Parent = sliderBar

                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                sliderFill.BackgroundColor3 = currentTheme.TextColor
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderBar

                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(0, 3)
                sliderFillCorner.Parent = sliderFill

                local sliderButton = Instance.new("TextButton")
                sliderButton.Size = UDim2.new(0, 12, 0, 12)
                sliderButton.Position = UDim2.new((default - min) / (max - min), -6, 0, -3)
                sliderButton.BackgroundColor3 = currentTheme.TextColor
                sliderButton.Text = ""
                sliderButton.Parent = sliderBar

                local sliderButtonCorner = Instance.new("UICorner")
                sliderButtonCorner.CornerRadius = UDim.new(0, 6)
                sliderButtonCorner.Parent = sliderButton

                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Slider"
                if config[configKey] ~= nil then
                    default = config[configKey]
                    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    sliderButton.Position = UDim2.new((default - min) / (max - min), -6, 0, -3)
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
                        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                        sliderButton.Position = UDim2.new(relativePos, -6, 0, -3)
                        sliderLabel.Text = name .. ": " .. value
                        config[configKey] = value
                        saveConfig()
                        callback(value)
                    end
                end)
            end

            -- Fonction pour créer un dropdown
            function section:CreateDropdown(name, options, default, callback)
                print("Creating dropdown: " .. name) -- Débogage
                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Size = UDim2.new(1, -20, 0, 30)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.Parent = sectionFrame

                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Size = UDim2.new(0.6, 0, 1, 0)
                dropdownLabel.Position = UDim2.new(0, 5, 0, 0)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Text = name .. ": " .. default
                dropdownLabel.TextColor3 = currentTheme.TextColor
                dropdownLabel.TextSize = 16
                dropdownLabel.Font = Enum.Font.Roboto
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame

                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Size = UDim2.new(0, 25, 0, 25)
                dropdownButton.Position = UDim2.new(1, -30, 0, 2.5)
                dropdownButton.BackgroundColor3 = currentTheme.ButtonBackground
                dropdownButton.Text = "▼"
                dropdownButton.TextColor3 = currentTheme.TextColor
                dropdownButton.TextSize = 12
                dropdownButton.Font = Enum.Font.Roboto
                dropdownButton.Parent = dropdownFrame

                local dropdownButtonCorner = Instance.new("UICorner")
                dropdownButtonCorner.CornerRadius = UDim.new(0, 4)
                dropdownButtonCorner.Parent = dropdownButton

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
                dropdownListCorner.CornerRadius = UDim.new(0, 4)
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
                    optionButton.Font = Enum.Font.Roboto
                    optionButton.Parent = dropdownList

                    local optionButtonCorner = Instance.new("UICorner")
                    optionButtonCorner.CornerRadius = UDim.new(0, 4)
                    optionButtonCorner.Parent = optionButton

                    optionButton.MouseButton1Click:Connect(function()
                        dropdownLabel.Text = name .. ": " .. option
                        dropdownList.Visible = false
                        dropdownList.Size = UDim2.new(0.4, 0, 0, 0)
                        config[configKey] = option
                        saveConfig()
                        callback(option)
                    end)
                end

                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                    local targetSize = dropdownList.Visible and UDim2.new(0.4, 0, 0, math.min(#options * 25, 100)) or UDim2.new(0.4, 0, 0, 0)
                    dropdownList.Size = targetSize
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
