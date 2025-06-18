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
    mainFrame.Size = UDim2.new(0, 1000, 0, 700) -- Hauteur augmentée à 700
    mainFrame.Position = UDim2.new(0.5, -500, 0.5, -350) -- Ajusté pour centrer avec la nouvelle hauteur
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
    local tweenOpen = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, -350)})
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
    tabButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json") -- Police neutre et normale
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

    -- Effet de survol supprimé sur le texte
    tabButton.MouseEnter:Connect(function()
        if currentTab ~= tab then
            tabButton.BackgroundColor3 = currentTheme.ButtonHoverBackground
        end
    end)

    tabButton.MouseLeave:Connect(function()
        if currentTab ~= tab then
            tabButton.BackgroundColor3 = currentTheme.TabBackground
        end
    end)

    -- Gestion du clic
    tabButton.MouseButton1Click:Connect(function()
        if currentTab ~= tab then
            if currentTab then
                currentTab.Content.Visible = false
                currentTab.Indicator.Visible = false
                currentTab.Button.BackgroundColor3 = currentTheme.TabBackground
            end
            tabButton.BackgroundColor3 = currentTheme.SelectedTabBackground
            tabIndicator.Visible = true
            tabContent.Visible = true
            currentTab = tab
            updateContainerPositions() -- Mettre à jour les positions au changement d'onglet
        end
    end)

    -- Création d'une section (limité à 6 sections) avec barre de défilement
    local sectionCount = 0
    function tab:CreateSection(name)
        if sectionCount >= 6 then
            warn("Maximum de 6 sections atteint pour cet onglet.")
            return nil
        end
        print("Création de la section : " .. name)
        local section = {}
        section.Name = name

        local sectionFrame = Instance.new("Frame")
        sectionFrame.Size = UDim2.new(0, 250, 0, 300) -- Hauteur fixe avec défilement
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
        sectionLabel.TextXAlignment = Enum.TextXAlignment.Center
        sectionLabel.Parent = sectionFrame

        local scrollFrame = Instance.new("ScrollingFrame")
        scrollFrame.Size = UDim2.new(1, -20, 0, 260) -- Hauteur ajustée pour laisser de la place au titre
        scrollFrame.Position = UDim2.new(0, 10, 0, 40) -- Sous le titre
        scrollFrame.BackgroundTransparency = 1
        scrollFrame.BorderSizePixel = 0
        scrollFrame.ScrollBarThickness = 6
        scrollFrame.ScrollBarImageColor3 = currentTheme.BorderColor
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        scrollFrame.Parent = sectionFrame

        local scrollLayout = Instance.new("UIListLayout")
        scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        scrollLayout.Padding = UDim.new(0, 8)
        scrollLayout.Parent = scrollFrame

        local sectionPadding = Instance.new("UIPadding")
        sectionPadding.PaddingLeft = UDim.new(0, 10)
        sectionPadding.PaddingTop = UDim.new(0, 0)
        sectionPadding.PaddingBottom = UDim.new(0, 10)
        sectionPadding.Parent = scrollFrame

        scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y)
            updateContainerPositions() -- Mettre à jour les positions quand le contenu change
        end)

        section.Frame = sectionFrame
        sectionCount = sectionCount + 1

        -- Création d'un toggle
        function section:CreateToggle(name, default, callback)
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, -20, 0, 35)
            toggleFrame.BackgroundTransparency = 1
            toggleFrame.Parent = scrollFrame

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
            toggleButton.Size = UDim2.new(0, 30, 0, 30)
            toggleButton.Position = UDim2.new(1, -35, 0, 2)
            toggleButton.BackgroundColor3 = default and currentTheme.TextColor or currentTheme.ButtonBackground
            toggleButton.Text = default and "✔" or ""
            toggleButton.TextColor3 = Color3.fromRGB(0, 200, 0)
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
                local tweenHover = TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = state and currentTheme.TextHoverColor or currentTheme.ButtonHoverBackground})
                tweenHover:Play()
            end)

            toggleButton.MouseLeave:Connect(function()
                local tweenLeave = TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = state and currentTheme.TextColor or currentTheme.ButtonBackground})
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
            sliderFrame.Parent = scrollFrame

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
                    sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                    sliderButton.Position = UDim2.new(relativePos, -8, 0, -5)
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
            dropdownFrame.Parent = scrollFrame

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
            dropdownButton.Size = UDim2.new(0, 30, 0, 30)
            dropdownButton.Position = UDim2.new(1, -35, 0, 2)
            dropdownButton.BackgroundColor3 = currentTheme.ButtonBackground
            dropdownButton.Text = "▼"
            dropdownButton.TextColor3 = currentTheme.TextColor
            dropdownButton.TextSize = 14
            dropdownButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
            dropdownButton.BorderSizePixel = 0
            dropdownButton.Parent = dropdownFrame

            local dropdownButtonStroke = Instance.new("UIStroke")
            dropdownButtonStroke.Thickness = 2
            dropdownButtonStroke.Color = currentTheme.BorderColor
            dropdownButtonStroke.Parent = dropdownButton

            dropdownButton.MouseEnter:Connect(function()
                dropdownButton.BackgroundColor3 = currentTheme.ButtonHoverBackground
            end)

            dropdownButton.MouseLeave:Connect(function()
                dropdownButton.BackgroundColor3 = currentTheme.ButtonBackground
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
                optionButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
                optionButton.BorderSizePixel = 0
                optionButton.Parent = dropdownList

                optionButton.MouseEnter:Connect(function()
                    optionButton.BackgroundColor3 = currentTheme.ButtonHoverBackground
                end)

                optionButton.MouseLeave:Connect(function()
                    optionButton.BackgroundColor3 = currentTheme.ButtonBackground
                end)

                optionButton.MouseButton1Click:Connect(function()
                    dropdownLabel.Text = name .. ": " .. option
                    dropdownList.Size = UDim2.new(0.3, 0, 0, 0)
                    dropdownList.Visible = false
                    config[configKey] = option
                    saveConfig()
                    callback(option)
                end)
            end

            dropdownButton.MouseButton1Click:Connect(function()
                dropdownList.Visible = not dropdownList.Visible
                local targetSize = dropdownList.Visible and UDim2.new(0.3, 0, 0, math.min(#options * 30, 120)) or UDim2.new(0.3, 0, 0, 0)
                dropdownList.Size = targetSize
            end)
        end

        return section
    end

    -- Ajout du profil joueur avec un profil rond à droite
    local playerInfoFrame = Instance.new("Frame")
    playerInfoFrame.Size = UDim2.new(0, 250, 0, 60) -- Ajusté pour inclure le profil rond
    playerInfoFrame.Position = UDim2.new(0, 5, 1, -5) -- Légèrement décalé à droite et vers le haut
    playerInfoFrame.AnchorPoint = Vector2.new(0, 1)
    playerInfoFrame.BackgroundColor3 = currentTheme.TabBackground
    playerInfoFrame.BorderSizePixel = 0
    playerInfoFrame.Parent = mainFrame

    local playerInfoStroke = Instance.new("UIStroke")
    playerInfoStroke.Thickness = 2
    playerInfoStroke.Color = currentTheme.BorderColor
    playerInfoStroke.Parent = playerInfoFrame

    local playerIcon = Instance.new("ImageLabel")
    playerIcon.Size = UDim2.new(0, 40, 0, 40)
    playerIcon.Position = UDim2.new(0, 5, 0.5, -20)
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

    -- Profil rond à droite du nom
    local playerProfileImage = Instance.new("ImageLabel")
    playerProfileImage.Size = UDim2.new(0, 40, 0, 40) -- Taille du cercle
    playerProfileImage.Position = UDim2.new(1, -50, 0.5, -20) -- À droite du nom, centré verticalement
    playerProfileImage.BackgroundTransparency = 1
    playerProfileImage.Image = player and "rbxthumb://id=" .. player.UserId .. "?width=420&height=420" or "rbxassetid://0" -- Image par défaut si aucune photo
    playerProfileImage.Parent = playerInfoFrame

    -- Créer un effet de cercle (masquer les coins avec une forme ronde)
    playerProfileImage.ImageRectSize = Vector2.new(40, 40) -- Taille de l'image recadrée
    playerProfileImage.ImageRectOffset = Vector2.new(0, 0) -- Début de l'image
    playerProfileImage.ScaleType = Enum.ScaleType.Fit -- Ajuster l'image
    local circleMask = Instance.new("ImageLabel")
    circleMask.Size = UDim2.new(1, 0, 1, 0)
    circleMask.BackgroundTransparency = 1
    circleMask.Image = "rbxassetid://266543268" -- Cercle masque
    circleMask.ImageColor3 = Color3.new(1, 1, 1)
    circleMask.Parent = playerProfileImage

        return tab
    end

    return XyloKitUIWindow
end

-- Renvoyer la table XyloKitUI
return XyloKitUI
