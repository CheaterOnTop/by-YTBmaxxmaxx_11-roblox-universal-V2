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

-- Thème modernisé (noir et gris-rouge atténué)
local Themes = {
    Dark = {
        MainBackground = Color3.fromRGB(18, 18, 18),
        TabBackground = Color3.fromRGB(24, 24, 24),
        SectionBackground = Color3.fromRGB(30, 30, 30),
        TextColor = Color3.fromRGB(200, 50, 50), -- Rouge atténué
        TextHoverColor = Color3.fromRGB(220, 80, 80), -- Rouge atténué au survol
        BorderColor = Color3.fromRGB(200, 50, 50), -- Rouge atténué pour les bordures
        SelectedTabColor = Color3.fromRGB(200, 50, 50), -- Rouge atténué pour l'indicateur
        ButtonBackground = Color3.fromRGB(28, 28, 28),
        ButtonHoverBackground = Color3.fromRGB(40, 40, 40),
        SelectedTabBackground = Color3.fromRGB(36, 36, 36),
        ShadowColor = Color3.fromRGB(0, 0, 0)
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
    if xeno or _G_Xeno then return "Xeno" end
    if wearedevs or jjsploit then return "JJSploit" end
    if syn then return "Synapse X" end
    if Krnl then return "Krnl" end
    if http and queue_on_teleport then return "Swift" end
    return "Unknown Executor"
end

print("Exécuteur détecté : " .. detectExecutor())

-- Création de la fenêtre principale
function XyloKitUI:CreateWindow(title)
    print("Création de la fenêtre : " .. title)
    local XyloKitUIWindow = {}
    XyloKitUIWindow.Configuration = config

    -- Fond principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 1000, 0, 600) -- Taille agrandie
    mainFrame.Position = UDim2.new(0.5, -500, 0.5, -300)
    mainFrame.BackgroundColor3 = currentTheme.MainBackground
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainFrameStroke = Instance.new("UIStroke")
    mainFrameStroke.Thickness = 2
    mainFrameStroke.Color = currentTheme.BorderColor
    mainFrameStroke.Parent = mainFrame

    -- Drag-and-drop
    local dragging = false
    local dragStart, startPos

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
    mainFrame.Position = UDim2.new(0.5, mainFrame.Position.X.Offset, -0.5, 0)
    local tweenOpen = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, -300)})
    tweenOpen:Play()

    -- Titre
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -180, 0, 50)
    titleLabel.Position = UDim2.new(0, 180, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = currentTheme.TextColor
    titleLabel.TextSize = 24
    titleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame

    -- Barre latérale pour les onglets
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(0, 200, 1, -50)
    tabBar.Position = UDim2.new(0, 0, 0, 50)
    tabBar.BackgroundColor3 = currentTheme.TabBackground
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame

    local tabBarStroke = Instance.new("UIStroke")
    tabBarStroke.Thickness = 2
    tabBarStroke.Color = currentTheme.BorderColor
    tabBarStroke.Parent = tabBar

    local tabBarLayout = Instance.new("UIListLayout")
    tabBarLayout.FillDirection = Enum.FillDirection.Vertical
    tabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBarLayout.Padding = UDim.new(0, 8)
    tabBarLayout.Parent = tabBar

    -- Zone de contenu
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -200, 1, -50)
    contentFrame.Position = UDim2.new(0, 200, 0, 50)
    contentFrame.BackgroundColor3 = currentTheme.MainBackground
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local contentFrameStroke = Instance.new("UIStroke")
    contentFrameStroke.Thickness = 2
    contentFrameStroke.Color = currentTheme.BorderColor
    contentFrameStroke.Parent = contentFrame

    -- Bouton de fermeture
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 5)
    closeButton.BackgroundColor3 = currentTheme.ButtonBackground
    closeButton.Text = "✕"
    closeButton.TextColor3 = currentTheme.TextColor
    closeButton.TextSize = 20
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame

    local closeStroke = Instance.new("UIStroke")
    closeStroke.Thickness = 2
    closeStroke.Color = currentTheme.BorderColor
    closeStroke.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        local tweenClose = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, -0.5, 0)})
        tweenClose:Play()
        tweenClose.Completed:Connect(function()
            screenGui:Destroy()
        end)
    end)

    -- Toggle avec RightShift
    local isMenuOpen = true
    local defaultPosition = mainFrame.Position
    local hiddenPosition = UDim2.new(0.5, mainFrame.Position.X.Offset, 2, 0)

    local function toggleMenu()
        isMenuOpen = not isMenuOpen
        local targetPos = isMenuOpen and defaultPosition or hiddenPosition
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {Position = targetPos})
        tween:Play()
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleMenu()
        end
    end)

    -- Gestion des onglets
    local tabs = {}
    local currentTab = nil

    -- Création d'un onglet
    function XyloKitUIWindow:CreateTab(name)
        print("Création de l'onglet : " .. name)
        local tab = {}
        tab.Name = name

        -- Bouton de l'onglet
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, -10, 0, 40)
        tabButton.BackgroundColor3 = currentTheme.TabBackground
        tabButton.Text = name
        tabButton.TextColor3 = currentTheme.TextColor
        tabButton.TextSize = 16
        tabButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
        tabButton.BorderSizePixel = 0
        tabButton.Parent = tabBar

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Thickness = 2
        tabStroke.Color = currentTheme.BorderColor
        tabStroke.Parent = tabButton

        -- Indicateur de sélection
        local tabIndicator = Instance.new("Frame")
        tabIndicator.Size = UDim2.new(0, 4, 1, 0)
        tabIndicator.Position = UDim2.new(0, 0, 0, 0)
        tabIndicator.BackgroundColor3 = currentTheme.SelectedTabColor
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Visible = false
        tabIndicator.Parent = tabButton

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

        -- Contenu de l'onglet avec deux conteneurs
        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, -20, 1, -110) -- Ajusté pour inclure le profil (70 + padding)
        tabContent.Position = UDim2.new(0, 10, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.Parent = contentFrame

        -- Conteneur principal pour les 3 premières sections
        local topContainer = Instance.new("Frame")
        topContainer.Size = UDim2.new(1, 0, 0, 200) -- Hauteur fixe pour les 3 premières sections
        topContainer.Position = UDim2.new(0, 0, 0, 0)
        topContainer.BackgroundTransparency = 1
        topContainer.Parent = tabContent

        local topContainerLayout = Instance.new("UIListLayout")
        topContainerLayout.FillDirection = Enum.FillDirection.Horizontal
        topContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        topContainerLayout.Padding = UDim.new(0, 15)
        topContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        topContainerLayout.Parent = topContainer

        -- Conteneur inférieur pour les sections supplémentaires
        local bottomContainer = Instance.new("Frame")
        bottomContainer.Size = UDim2.new(1, 0, 0, 0) -- Hauteur dynamique
        bottomContainer.Position = UDim2.new(0, 0, 0, 210) -- Rapproché vers le haut
        bottomContainer.BackgroundTransparency = 1
        bottomContainer.Parent = tabContent

        local bottomContainerLayout = Instance.new("UIListLayout")
        bottomContainerLayout.FillDirection = Enum.FillDirection.Horizontal
        bottomContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
        bottomContainerLayout.Padding = UDim.new(0, 15)
        bottomContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        bottomContainerLayout.Parent = bottomContainer

        tab.Button = tabButton
        tab.Content = tabContent
        tab.TopContainer = topContainer
        tab.BottomContainer = bottomContainer
        tab.Indicator = tabIndicator
        tabs[name] = tab

        -- Gestion du clic
        tabButton.MouseButton1Click:Connect(function()
            if currentTab ~= tab then
                if currentTab then
                    currentTab.Content.Visible = false
                    currentTab.Indicator.Visible = false
                    local tweenDeselect = TweenService:Create(currentTab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.TabBackground})
                    tweenDeselect:Play()
                end
                local tweenSelect = TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.SelectedTabBackground})
                tweenSelect:Play()
                tabIndicator.Visible = true
                tabContent.Visible = true
                currentTab = tab
            end
        end)

        -- Création d'une section
        local sectionCount = 0
        function tab:CreateSection(name)
            print("Création de la section : " .. name)
            local section = {}
            section.Name = name

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(0, 250, 0, 0)
            sectionFrame.BackgroundColor3 = currentTheme.SectionBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = (sectionCount < 3 and topContainer or bottomContainer)

            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Thickness = 2
            sectionStroke.Color = currentTheme.BorderColor
            sectionStroke.Parent = sectionFrame

            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, -20, 0, 30)
            sectionLabel.Position = UDim2.new(0, 10, 0, 10)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = name
            sectionLabel.TextColor3 = currentTheme.TextColor
            sectionLabel.TextSize = 18
            sectionLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionFrame

            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 8)
            sectionLayout.Parent = sectionFrame

            local sectionPadding = Instance.new("UIPadding")
            sectionPadding.PaddingLeft = UDim.new(0, 10)
            sectionPadding.PaddingTop = UDim.new(0, 45)
            sectionPadding.PaddingBottom = UDim.new(0, 10)
            sectionPadding.Parent = sectionFrame

            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionFrame.Size = UDim2.new(0, 250, 0, sectionLayout.AbsoluteContentSize.Y + 60)
            end)

            if sectionCount >= 3 then
                bottomContainer.Size = UDim2.new(1, 0, 0, math.max(bottomContainer.Size.Y.Offset, sectionLayout.AbsoluteContentSize.Y + 60))
            end

            section.Frame = sectionFrame
            sectionCount = sectionCount + 1

            -- Création d'un toggle
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
                toggleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleFrame

                local toggleButton = Instance.new("TextButton")
                toggleButton.Size = UDim2.new(0, 30, 0, 30) -- Bouton carré
                toggleButton.Position = UDim2.new(1, -35, 0, 2)
                toggleButton.BackgroundColor3 = default and currentTheme.TextColor or currentTheme.ButtonBackground
                toggleButton.Text = default and "✔" or ""
                toggleButton.TextColor3 = Color3.fromRGB(0, 200, 0) -- Vert atténué
                toggleButton.TextSize = 18
                toggleButton.Font = Enum.Font.GothamBold
                toggleButton.BorderSizePixel = 0
                toggleButton.Parent = toggleFrame

                local toggleStroke = Instance.new("UIStroke")
                toggleStroke.Thickness = 2
                toggleStroke.Color = currentTheme.BorderColor
                toggleStroke.Parent = toggleButton

                local state = default
                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Toggle"
                if config[configKey] ~= nil then
                    state = config[configKey]
                    toggleButton.BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground
                    toggleButton.Text = state and "✔" or ""
                end

                toggleButton.MouseEnter:Connect(function()
                    local tweenHover = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and currentTheme.TextHoverColor or currentTheme.ButtonHoverBackground})
                    tweenHover:Play()
                end)

                toggleButton.MouseLeave:Connect(function()
                    local tweenLeave = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground})
                    tweenLeave:Play()
                end)

                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    toggleButton.BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground
                    toggleButton.Text = state and "✔" or ""
                    config[configKey] = state
                    saveConfig()
                    callback(state)
                end)
            end

            -- Création d'un slider
            function section:CreateSlider(name, min, max, default, callback)
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, -20, 0, 50)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Parent = sectionFrame

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(0.6, 0, 0, 20)
                sliderLabel.Position = UDim2.new(0, 5, 0, 0)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = name .. ": " .. default
                sliderLabel.TextColor3 = currentTheme.TextColor
                sliderLabel.TextSize = 16
                sliderLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame

                local sliderBar = Instance.new("Frame")
                sliderBar.Size = UDim2.new(1, -10, 0, 6)
                sliderBar.Position = UDim2.new(0, 5, 0, 30)
                sliderBar.BackgroundColor3 = currentTheme.ButtonBackground
                sliderBar.Parent = sliderFrame

                local sliderBarStroke = Instance.new("UIStroke")
                sliderBarStroke.Thickness = 2
                sliderBarStroke.Color = currentTheme.BorderColor
                sliderBarStroke.Parent = sliderBar

                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                sliderFill.BackgroundColor3 = currentTheme.TextColor
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderBar

                local sliderFillStroke = Instance.new("UIStroke")
                sliderFillStroke.Thickness = 2
                sliderFillStroke.Color = currentTheme.BorderColor
                sliderFillStroke.Parent = sliderFill

                local sliderButton = Instance.new("TextButton")
                sliderButton.Size = UDim2.new(0, 16, 0, 16)
                sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, -5)
                sliderButton.BackgroundColor3 = currentTheme.TextColor
                sliderButton.Text = ""
                sliderButton.Parent = sliderBar

                local sliderButtonStroke = Instance.new("UIStroke")
                sliderButtonStroke.Thickness = 2
                sliderButtonStroke.Color = currentTheme.BorderColor
                sliderButtonStroke.Parent = sliderButton

                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Slider"
                if config[configKey] ~= nil then
                    default = config[configKey]
                    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    sliderButton.Position = UDim2.new((default - min) / (max - min), -8, 0, -5)
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
                        local tweenButton = TweenService:Create(sliderButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(relativePos, -8, 0, -5)})
                        tweenFill:Play()
                        tweenButton:Play()
                        sliderLabel.Text = name .. ": " .. value
                        config[configKey] = value
                        saveConfig()
                        callback(value)
                    end
                end)
            end

            -- Création d'un dropdown
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
                dropdownLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame

                local dropdownButton = Instance.new("TextButton")
                dropdownButton.Size = UDim2.new(0, 30, 0, 30) -- Bouton carré
                dropdownButton.Position = UDim2.new(1, -35, 0, 2)
                dropdownButton.BackgroundColor3 = currentTheme.ButtonBackground
                dropdownButton.Text = "▼"
                dropdownButton.TextColor3 = currentTheme.TextColor
                dropdownButton.TextSize = 14
                dropdownButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json") -- Même police
                dropdownButton.BorderSizePixel = 0
                dropdownButton.Parent = dropdownFrame

                local dropdownButtonStroke = Instance.new("UIStroke")
                dropdownButtonStroke.Thickness = 2
                dropdownButtonStroke.Color = currentTheme.BorderColor
                dropdownButtonStroke.Parent = dropdownButton

                dropdownButton.MouseEnter:Connect(function()
                    local tweenHover = TweenService:Create(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonHoverBackground})
                    tweenHover:Play()
                end)

                dropdownButton.MouseLeave:Connect(function()
                    local tweenLeave = TweenService:Create(dropdownButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.ButtonBackground})
                    tweenLeave:Play()
                end)

                local dropdownList = Instance.new("ScrollingFrame")
                dropdownList.Size = UDim2.new(0.3, 0, 0, 0)
                dropdownList.Position = UDim2.new(0.7, 0, 1, 5)
                dropdownList.BackgroundColor3 = currentTheme.ButtonBackground
                dropdownList.Visible = false
                dropdownList.ScrollBarThickness = 4
                dropdownList.ScrollBarImageColor3 = currentTheme.BorderColor
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
                dropdownList.Parent = dropdownFrame

                local dropdownListStroke = Instance.new("UIStroke")
                dropdownListStroke.Thickness = 2
                dropdownListStroke.Color = currentTheme.BorderColor
                dropdownListStroke.Parent = dropdownList

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
                    optionButton.Size = UDim2.new(1, -10, 0, 25)
                    optionButton.BackgroundColor3 = currentTheme.ButtonBackground
                    optionButton.Text = option
                    optionButton.TextColor3 = currentTheme.TextColor
                    optionButton.TextSize = 14
                    optionButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json") -- Même police
                    optionButton.Parent = dropdownList

                    local optionButtonStroke = Instance.new("UIStroke")
                    optionButtonStroke.Thickness = 2
                    optionButtonStroke.Color = currentTheme.BorderColor
                    optionButtonStroke.Parent = optionButton

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
                        local tweenClose = TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.3, 0, 0, 0)})
                        tweenClose:Play()
                        dropdownList.Visible = false
                        config[configKey] = option
                        saveConfig()
                        callback(option)
                    end)
                end

                dropdownButton.MouseButton1Click:Connect(function()
                    dropdownList.Visible = not dropdownList.Visible
                    local targetSize = dropdownList.Visible and UDim2.new(0.3, 0, 0, math.min(#options * 30, 120)) or UDim2.new(0.3, 0, 0, 0)
                    local tweenSize = TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = targetSize})
                    tweenSize:Play()
                end)
            end

            return section
        end

-- Ajout du profil joueur tout en bas à gauche
local playerInfoFrame = Instance.new("Frame")
playerInfoFrame.Size = UDim2.new(0, 200, 0, 60)
playerInfoFrame.Position = UDim2.new(0, 9, 1, -7) -- Positionné à 10 pixels du bas et de la gauche
playerInfoFrame.AnchorPoint = Vector2.new(0, 1) -- Ancrage au coin inférieur gauche
playerInfoFrame.BackgroundColor3 = currentTheme.TabBackground
playerInfoFrame.BorderSizePixel = 0
playerInfoFrame.Parent = mainFrame -- Parent à mainFrame pour une position fixe

local playerInfoStroke = Instance.new("UIStroke")
playerInfoStroke.Thickness = 2
playerInfoStroke.Color = currentTheme.BorderColor
playerInfoStroke.Parent = playerInfoFrame

local playerIcon = Instance.new("ImageLabel")
playerIcon.Size = UDim2.new(0, 40, 0, 40)
playerIcon.Position = UDim2.new(0, 5, 0.5, -20) -- Centré verticalement dans le cadre
playerIcon.BackgroundTransparency = 1
playerIcon.Image = player and "rbxthumb://id=" .. player.UserId .. "?width=420&height=420" or ""
playerIcon.Parent = playerInfoFrame

local playerName = Instance.new("TextLabel")
playerName.Size = UDim2.new(0.7, 0, 1, 0)
playerName.Position = UDim2.new(0, 50, 0, 0)
playerName.BackgroundTransparency = 1
playerName.Text = player and player.Name or "Loading..."
playerName.TextColor3 = currentTheme.TextColor
playerName.TextSize = 16
playerName.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
playerName.TextXAlignment = Enum.TextXAlignment.Left
playerName.Parent = playerInfoFrame

        return tab
    end

    return XyloKitUIWindow
end

-- Renvoyer la table XyloKitUI
return XyloKitUI
