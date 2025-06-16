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
print("ScreenGui created and parented to PlayerGui: " .. tostring(screenGui.Parent)) -- Débogage

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
    mainFrame.ClipsDescendants = false -- Désactiver pour éviter de couper le contenu
    mainFrame.Parent = screenGui
    print("MainFrame created and parented to ScreenGui: " .. tostring(mainFrame.Parent)) -- Débogage

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
    print("TitleLabel created and visible: " .. tostring(titleLabel.Visible)) -- Débogage

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = titleLabel

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
    print("CloseButton created and visible: " .. tostring(closeButton.Visible)) -- Débogage

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton

    closeButton.MouseButton1Click:Connect(function()
        mainFrame:Destroy() -- Simplifier la fermeture sans animation pour tester
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
        tabButton.Parent = mainFrame -- Parent temporaire pour tester
        print("TabButton created and parented to MainFrame: " .. tostring(tabButton.Parent)) -- Débogage

        -- Contenu de l'onglet
        local tabContent = Instance.new("Frame")
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.Parent = mainFrame -- Parent temporaire pour tester
        print("TabContent created and parented to MainFrame: " .. tostring(tabContent.Parent)) -- Débogage

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
                print("Tab selected: " .. name .. ", Content Visible: " .. tostring(tabContent.Visible)) -- Débogage
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
            sectionFrame.ClipsDescendants = false
            sectionFrame.Parent = tabContent
            print("SectionFrame created and parented to TabContent: " .. tostring(sectionFrame.Parent)) -- Débogage

            local sectionStroke = Instance.new("UIStroke")
            sectionStroke.Thickness = 2
            sectionStroke.Color = currentTheme.BorderColor
            sectionStroke.Parent = sectionFrame

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

            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local contentHeight = sectionLayout.AbsoluteContentSize.Y + 45
                sectionFrame.Size = UDim2.new(0, 220, 0, math.max(350, contentHeight))
                print("Section " .. name .. " adjusted to height: " .. math.max(350, contentHeight)) -- Débogage
            end)

            section.Frame = sectionFrame

            function section:CreateToggle(name, default, callback)
                print("Creating toggle: " .. name .. " in section " .. section.Name)
                local toggleFrame = Instance.new("Frame")
                toggleFrame.Size = UDim2.new(1, -20, 0, 30)
                toggleFrame.BackgroundTransparency = 1
                toggleFrame.Parent = sectionFrame
                print("ToggleFrame parented to: " .. tostring(sectionFrame))

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

            return section
        end

        return tab
    end

    return XyloKitUIWindow
end

-- Renvoyer la table XyloKitUI pour loadstring
return XyloKitUI
