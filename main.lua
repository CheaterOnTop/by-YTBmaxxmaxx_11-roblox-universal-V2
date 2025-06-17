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

-- Thème modernisé (noir et rouge)
local Themes = {
    Dark = {
        MainBackground = Color3.fromRGB(18, 18, 18),
        TabBackground = Color3.fromRGB(24, 24, 24),
        SectionBackground = Color3.fromRGB(30, 30, 30),
        TextColor = Color3.fromRGB(255, 60, 60),
        TextHoverColor = Color3.fromRGB(255, 100, 100),
        BorderColor = Color3.fromRGB(255, 30, 30),
        SelectedTabColor = Color3.fromRGB(255, 30, 30),
        ButtonBackground = Color3.fromRGB(28, 28, 28),
        ButtonHoverBackground = Color3.fromRGB(40, 40, 40),
        SelectedTabBackground = Color3.fromRGB(36, 36, 36),
        ShadowColor = Color3.fromRGB(0, 0, 0),
        GradientColor1 = Color3.fromRGB(255, 80, 80),
        GradientColor2 = Color3.fromRGB(200, 40, 40)
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
    if http and queue_on_teleport then return "Swift" end
    return "Unknown Executor"
end

print("Exécuteur détecté : " .. detectExecutor())

-- Création de la fenêtre principale
function XyloKitUI:CreateWindow(title)
    print("Création de la fenêtre : " .. title)
    local XyloKitUIWindow = {}
    XyloKitUIWindow.Configuration = config

    -- Fond principal (format rectangulaire, hauteur augmentée)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 900, 0, 800) -- Hauteur augmentée à 800px
    mainFrame.Position = UDim2.new(0.5, -450, 0.5, -400)
    mainFrame.BackgroundColor3 = currentTheme.MainBackground
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainFrameCorner = Instance.new("UICorner")
    mainFrameCorner.CornerRadius = UDim.new(0, 12)
    mainFrameCorner.Parent = mainFrame

    local mainFrameStroke = Instance.new("UIStroke")
    mainFrameStroke.Thickness = 2
    mainFrameStroke.Color = currentTheme.BorderColor
    mainFrameStroke.Parent = mainFrame

    -- Effet d'ombre
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    shadow.ImageColor3 = currentTheme.ShadowColor
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = 0
    shadow.Parent = mainFrame

    -- Drag-and-drop
    local dragging = false
    local dragInput, startPos

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
    local tweenOpen = TweenService:Create(mainFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, mainFrame.Position.X.Offset, 0.5, -400)})
    tweenOpen:Play()

    -- Titre
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -180, 0, 50)
    titleLabel.Position = UDim2.new(0, 150, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = currentTheme.TextColor
    titleLabel.TextSize = 24
    titleLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = mainFrame

    -- Barre latérale pour les onglets
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(0, 150, 1, -50)
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

    -- Zone de contenu avec grille de sections
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -150, 1, -50)
    contentFrame.Position = UDim2.new(0, 150, 0, 50)
    contentFrame.BackgroundColor3 = currentTheme.MainBackground
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local contentFrameCorner = Instance.new("UICorner")
    contentFrameCorner.CornerRadius = UDim.new(0, 10)
    contentFrameCorner.Parent = contentFrame

    -- Bouton de fermeture
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 50, 0, 50)
    closeButton.Position = UDim2.new(1, -60, 0, 0)
    closeButton.BackgroundColor3 = currentTheme.ButtonBackground
    closeButton.Text = "✕"
    closeButton.TextColor3 = currentTheme.TextColor
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 10)
    closeCorner.Parent = closeButton

    local closeGradient = Instance.new("UIGradient")
    closeGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, currentTheme.GradientColor1), ColorSequenceKeypoint.new(1, currentTheme.GradientColor2)}
    closeGradient.Rotation = 45
    closeGradient.Parent = closeButton

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

        -- Bouton de l'onglet (style amélioré)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, -10, 0, 60)
        tabButton.BackgroundColor3 = currentTheme.TabBackground
        tabButton.Text = name
        tabButton.TextColor3 = currentTheme.TextColor
        tabButton.TextSize = 20
        tabButton.FontFace = Font.new("rbxasset://fonts/families/GothamBold.json")
        tabButton.BorderSizePixel = 0
        tabButton.Parent = tabBar

        local tabStroke = Instance.new("UIStroke")
        tabStroke.Thickness = 2
        tabStroke.Color = currentTheme.BorderColor
        tabStroke.Parent = tabButton

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 12)
        tabCorner.Parent = tabButton

        local tabGradient = Instance.new("UIGradient")
        tabGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, currentTheme.GradientColor1), ColorSequenceKeypoint.new(1, currentTheme.GradientColor2)}
        tabGradient.Rotation = 90
        tabGradient.Parent = tabButton

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

        -- Contenu de l'onglet
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, -160, 1, -60)
        tabContent.Position = UDim2.new(0, 160, 0, 50)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = currentTheme.BorderColor
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Parent = mainFrame

        local tabContentLayout = Instance.new("UIGridLayout")
        tabContentLayout.FillDirection = Enum.FillDirection.Vertical
        tabContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabContentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
        tabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabContentLayout.CellSize = UDim2.new(0, 280, 0, 200) -- 3 sections par rangée
        tabContentLayout.CellPadding = UDim2.new(0, 10, 0, 10)
        tabContentLayout.Parent = tabContent

        tabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, tabContentLayout.AbsoluteContentSize.X, 0, tabContentLayout.AbsoluteContentSize.Y)
        end)

        tab.Button = tabButton
        tab.Content = tabContent
        tab.Indicator = tabIndicator
        tabs[name] = tab

        -- Gestion du clic
        tabButton.MouseButton1Click:Connect(function()
            if currentTab and currentTab.Content then
                currentTab.Content.Visible = false
                currentTab.Indicator.Visible = false
                local tweenDeselect = TweenService:Create(currentTab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.TabBackground})
                tweenDeselect:Play()
                currentTab.Button.UIStroke.Color = currentTheme.BorderColor
            end
            local tweenSelect = TweenService:Create(tabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = currentTheme.SelectedTabBackground})
            tweenSelect:Play()
            tabIndicator.Visible = true
            tabContent.Visible = true
            currentTab = tab
        end)

        if not currentTab then
            tabContent.Visible = true
            tabIndicator.Visible = true
            tabButton.BackgroundColor3 = currentTheme.SelectedTabBackground
            tabButton.UIStroke.Color = currentTheme.SelectedTabColor
            currentTab = tab
        end

        -- Création d'une section
        function tab:CreateSection(name)
            print("Création de la section : " .. name)
            local section = {}
            section.Name = name

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(0, 260, 0, 180) -- Ajusté pour 3 rangées
            sectionFrame.BackgroundColor3 = currentTheme.SectionBackground
            sectionFrame.BorderSizePixel = 0
            sectionFrame.Parent = tabContent

            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Thickness = 2
            sectionStroke.Color = currentTheme.BorderColor
            sectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            sectionStroke.Parent = sectionFrame

            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 10)
            sectionCorner.Parent = sectionFrame

            local sectionGradient = Instance.new("UIGradient")
            sectionGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, currentTheme.GradientColor1), ColorSequenceKeypoint.new(1, currentTheme.GradientColor2)}
            sectionGradient.Rotation = 45
            sectionGradient.Parent = sectionFrame

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

            section.Frame = sectionFrame

            -- Création d'un toggle
            function section:CreateToggle(name, default, callback)
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, -20, 0, 40)
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
                toggleButton.Size = UDim2.new(0, 50, 0, 30)
                toggleButton.Position = UDim2.new(1, -55, 0, 5)
                toggleButton.BackgroundColor3 = default and currentTheme.GradientColor1 or currentTheme.ButtonBackground
                toggleButton.Text = ""
                toggleButton.Parent = toggleFrame

                local toggleCorner = Instance.new("UICorner")
                toggleCorner.CornerRadius = UDim.new(0, 15)
                toggleCorner.Parent = toggleButton

                local toggleGradient = Instance.new("UIGradient")
                toggleGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, currentTheme.GradientColor1), ColorSequenceKeypoint.new(1, currentTheme.GradientColor2)}
                toggleGradient.Rotation = 90
                toggleGradient.Parent = toggleButton

                local toggleInner = Instance.new("Frame")
                toggleInner.Size = UDim2.new(0, 20, 0, 20)
                toggleInner.Position = UDim2.new(default and 0.55 or 0.1, 0, 0.15, 0)
                toggleInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggleInner.Parent = toggleButton

                local toggleInnerCorner = Instance.new("UICorner")
                toggleInnerCorner.CornerRadius = UDim.new(0, 10)
                toggleInnerCorner.Parent = toggleInner

                local state = default
                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Toggle"
                if config[configKey] ~= nil then
                    state = config[configKey]
                    toggleButton.BackgroundColor3 = state and currentTheme.GradientColor1 or currentTheme.ButtonBackground
                    toggleInner.Position = UDim2.new(state and 0.55 or 0.1, 0, 0.15, 0)
                end

                toggleButton.MouseEnter:Connect(function()
                    local tweenHover = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and currentTheme.TextHoverColor or currentTheme.ButtonHoverBackground})
                    tweenHover:Play()
                end)

                toggleButton.MouseLeave:Connect(function()
                    local tweenLeave = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and currentTheme.GradientColor1 or currentTheme.ButtonBackground})
                    tweenLeave:Play()
                end)

                toggleButton.MouseButton1Click:Connect(function()
                    state = not state
                    local tween = TweenService:Create(toggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = state and currentTheme.GradientColor1 or currentTheme.ButtonBackground})
                    local tweenInner = TweenService:Create(toggleInner, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = UDim2.new(state and 0.55 or 0.1, 0, 0.15, 0)})
                    tween:Play()
                    tweenInner:Play()
                    config[configKey] = state
                    saveConfig()
                    callback(state)
                end)
            end

            -- Création d'un slider
            function section:CreateSlider(name, min, max, default, callback)
                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, -20, 0, 60)
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
                sliderBar.Size = UDim2.new(1, -10, 0, 8)
                sliderBar.Position = UDim2.new(0, 5, 0, 30)
                sliderBar.BackgroundColor3 = currentTheme.ButtonBackground
                sliderBar.Parent = sliderFrame

                local sliderBarCorner = Instance.new("UICorner")
                sliderBarCorner.CornerRadius = UDim.new(0, 4)
                sliderBarCorner.Parent = sliderBar

                local sliderFill = Instance.new("Frame")
                sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                sliderFill.BackgroundColor3 = currentTheme.GradientColor1
                sliderFill.BorderSizePixel = 0
                sliderFill.Parent = sliderBar

                local sliderFillGradient = Instance.new("UIGradient")
                sliderFillGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, currentTheme.GradientColor1), ColorSequenceKeypoint.new(1, currentTheme.GradientColor2)}
                sliderFillGradient.Rotation = 90
                sliderFillGradient.Parent = sliderFill

                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(0, 4)
                sliderFillCorner.Parent = sliderFill

                local sliderButton = Instance.new("TextButton")
                sliderButton.Size = UDim2.new(0, 20, 0, 20)
                sliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0, -6)
                sliderButton.BackgroundColor3 = currentTheme.GradientColor1
                sliderButton.Text = ""
                sliderButton.Parent = sliderBar

                local sliderButtonCorner = Instance.new("UICorner")
                sliderButtonCorner.CornerRadius = UDim.new(0, 10)
                sliderButtonCorner.Parent = sliderButton

                local sliderButtonGradient = Instance.new("UIGradient")
                sliderButtonGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, currentTheme.GradientColor1), ColorSequenceKeypoint.new(1, currentTheme.GradientColor2)}
                sliderButtonGradient.Rotation = 45
                sliderButtonGradient.Parent = sliderButton

                local configKey = tab.Name .. "_" .. section.Name .. "_" .. name .. "_Slider"
                if config[configKey] ~= nil then
                    default = config[configKey]
                    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    sliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0, -6)
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
                        local tweenButton = TweenService:Create(sliderButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(relativePos, -10, 0, -6)})
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
                dropdownFrame.Size = UDim2.new(1, -20, 0, 50)
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
                dropdownButton.Size = UDim2.new(0, 50, 0, 30)
                dropdownButton.Position = UDim2.new(1, -55, 0, 10)
                dropdownButton.BackgroundColor3 = currentTheme.ButtonBackground
                dropdownButton.Text = "▼"
                dropdownButton.TextColor3 = currentTheme.TextColor
                dropdownButton.TextSize = 18
                dropdownButton.Font = Enum.Font.Code
                dropdownButton.Parent = dropdownFrame

                local dropdownButtonCorner = Instance.new("UICorner")
                dropdownButtonCorner.CornerRadius = UDim.new(0, 10)
                dropdownButtonCorner.Parent = dropdownButton

                local dropdownButtonGradient = Instance.new("UIGradient")
                dropdownButtonGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, currentTheme.GradientColor1), ColorSequenceKeypoint.new(1, currentTheme.GradientColor2)}
                dropdownButtonGradient.Rotation = 90
                dropdownButtonGradient.Parent = dropdownButton

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
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 35)
                dropdownList.Parent = dropdownFrame

                local dropdownListCorner = Instance.new("UICorner")
                dropdownListCorner.CornerRadius = UDim.new(0, 10)
                dropdownListCorner.Parent = dropdownList

                local dropdownListStroke = Instance.new("UIStroke")
                dropdownListStroke.Thickness = 1
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
                    optionButton.Size = UDim2.new(1, -10, 0, 30)
                    optionButton.BackgroundColor3 = currentTheme.ButtonBackground
                    optionButton.Text = option
                    optionButton.TextColor3 = currentTheme.TextColor
                    optionButton.TextSize = 14
                    optionButton.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
                    optionButton.Parent = dropdownList

                    local optionButtonCorner = Instance.new("UICorner")
                    optionButtonCorner.CornerRadius = UDim.new(0, 6)
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
                    local targetSize = dropdownList.Visible and UDim2.new(0.3, 0, 0, math.min(#options * 35, 140)) or UDim2.new(0.3, 0, 0, 0)
                    local tweenSize = TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = targetSize})
                    tweenSize:Play()
                end)
            end

            return section
        end

        return tab
    end

    -- Profil du joueur en bas à gauche
    local playerProfileFrame = Instance.new("Frame")
    playerProfileFrame.Size = UDim2.new(0, 180, 0, 50)
    playerProfileFrame.Position = UDim2.new(0, 10, 1, -60)
    playerProfileFrame.BackgroundColor3 = currentTheme.TabBackground
    playerProfileFrame.BorderSizePixel = 0
    playerProfileFrame.Parent = mainFrame

    local profileStroke = Instance.new("UIStroke")
    profileStroke.Thickness = 2
    profileStroke.Color = currentTheme.BorderColor
    profileStroke.Parent = playerProfileFrame

    local profileCorner = Instance.new("UICorner")
    profileCorner.CornerRadius = UDim.new(0, 8)
    profileCorner.Parent = playerProfileFrame

    local userId = player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size48x48
    local thumbnailContent, _ = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

    local profileIcon = Instance.new("ImageLabel")
    profileIcon.Size = UDim2.new(0, 40, 0, 40)
    profileIcon.Position = UDim2.new(0, 5, 0, 5)
    profileIcon.BackgroundTransparency = 1
    profileIcon.Image = thumbnailContent or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    profileIcon.Parent = playerProfileFrame

    local profileIconCorner = Instance.new("UICorner")
    profileIconCorner.CornerRadius = UDim.new(0, 20)
    profileIconCorner.Parent = profileIcon

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(0, 130, 0, 40)
    usernameLabel.Position = UDim2.new(0, 50, 0, 5)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = player.Name
    usernameLabel.TextColor3 = currentTheme.TextColor
    usernameLabel.TextSize = 16
    usernameLabel.FontFace = Font.new("rbxasset://fonts/families/GothamSSM.json")
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    usernameLabel.Parent = playerProfileFrame

    return XyloKitUIWindow
end

-- Renvoyer la table XyloKitUI
return XyloKitUI
