-- Bibliothèque XyloKitUI pour une interface utilisateur Roblox
local XyloKitUI = {}

-- Services Roblox nécessaires
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Attendre que le jeu et le joueur soient chargés
local function attendreJeuCharge()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    local joueur = Players.LocalPlayer
    if not joueur then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        joueur = Players.LocalPlayer
    end
    return joueur
end

-- Initialisation de l'interface
local joueur = attendreJeuCharge()
local interface = Instance.new("ScreenGui")
interface.Name = "XyloKitUI"
interface.Parent = joueur:WaitForChild("PlayerGui")
interface.ResetOnSpawn = false
interface.IgnoreGuiInset = true

-- Thème personnalisé
local Themes = {
    Sombre = {
        FondPrincipal = Color3.fromRGB(18, 18, 18), -- Fond sombre
        FondBarreLaterale = Color3.fromRGB(24, 24, 24), -- Barre latérale
        FondContenu = Color3.fromRGB(28, 28, 28), -- Contenu
        CouleurAccent = Color3.fromRGB(255, 50, 50), -- Rouge pour accent
        CouleurTexte = Color3.fromRGB(220, 220, 220), -- Texte clair
        CouleurTexteSurvol = Color3.fromRGB(255, 255, 255), -- Texte survol
        CouleurBordure = Color3.fromRGB(12, 12, 12), -- Bordure sombre
        FondBouton = Color3.fromRGB(32, 32, 32), -- Boutons
        FondBoutonSurvol = Color3.fromRGB(48, 48, 48), -- Boutons survol
        FondOngletSelectionne = Color3.fromRGB(36, 36, 36), -- Onglet actif
        CouleurOmbre = Color3.fromRGB(0, 0, 0) -- Ombre subtile
    }
}

local themeActuel = Themes.Sombre

-- Gestion de la configuration
local config = {}
local fichierConfig = "XyloKitUI_Config.json"

local function sauvegarderConfig()
    local succes, encode = pcall(function()
        return HttpService:JSONEncode(config)
    end)
    if succes then
        pcall(writefile, fichierConfig, encode)
    end
end

local function chargerConfig()
    if isfile(fichierConfig) then
        local succes, decode = pcall(function()
            return HttpService:JSONDecode(readfile(fichierConfig))
        end)
        if succes then
            config = decode
        end
    end
end

chargerConfig()

-- Détection de l'exécuteur
local function detecterExecutant()
    if isSolara then return "Solara" end
    if xeno or _G.XenoSineWave then return "Xeno" end
    if wearedevs or jjsploit then return "JJSploit" end
    if syn then return "Synapse X" end
    if Krnl then return "Krnl" end
    if http and queue_on_teleport then return "Swift (Approximatif)" end
    return "Exécuteur Inconnu"
end

print("Exécuteur détecté : " .. detecterExecutant())

-- Création de la fenêtre principale
function XyloKitUI:CreerFenetre(titre)
    print("Création de la fenêtre : " .. titre)
    local FenetreUI = {}
    FenetreUI.Config = config

    -- Cadre principal
    local cadrePrincipal = Instance.new("Frame")
    cadrePrincipal.Size = UDim2.new(0, 900, 0, 600) -- Fenêtre agrandie
    cadrePrincipal.Position = UDim2.new(0.5, -450, 0.5, -300)
    cadrePrincipal.BackgroundColor3 = themeActuel.FondPrincipal
    cadrePrincipal.BorderSizePixel = 0
    cadrePrincipal.ClipsDescendants = true
    cadrePrincipal.Parent = interface

    local coinsCadre = Instance.new("UICorner")
    coinsCadre.CornerRadius = UDim.new(0, 12)
    coinsCadre.Parent = cadrePrincipal

    -- Ombre subtile
    local ombre = Instance.new("ImageLabel")
    ombre.Size = UDim2.new(1, 20, 1, 20)
    ombre.Position = UDim2.new(0, -10, 0, -10)
    ombre.BackgroundTransparency = 1
    ombre.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    ombre.ImageColor3 = themeActuel.CouleurOmbre
    ombre.ImageTransparency = 0.8
    ombre.ZIndex = -1
    ombre.Parent = cadrePrincipal

    -- Glisser-déposer avec limites
    local glisse = false
    local entreeGlisse, debutGlisse, positionDebut

    cadrePrincipal.InputBegan:Connect(function(entree)
        if entree.UserInputType == Enum.UserInputType.MouseButton1 then
            glisse = true
            debutGlisse = entree.Position
            positionDebut = cadrePrincipal.Position
            entree.Changed:Connect(function()
                if entree.UserInputState == Enum.UserInputState.End then
                    glisse = false
                end
            end)
        end
    end)

    cadrePrincipal.InputChanged:Connect(function(entree)
        if entree.UserInputType == Enum.UserInputType.MouseMovement and glisse then
            local delta = entree.Position - debutGlisse
            local nouvellePos = UDim2.new(
                positionDebut.X.Scale,
                math.clamp(positionDebut.X.Offset + delta.X, -interface.AbsoluteSize.X + 100, interface.AbsoluteSize.X - 100),
                positionDebut.Y.Scale,
                math.clamp(positionDebut.Y.Offset + delta.Y, -interface.AbsoluteSize.Y + 100, interface.AbsoluteSize.Y - 100)
            )
            cadrePrincipal.Position = nouvellePos
            config.PositionFenetre = {X = nouvellePos.X.Offset, Y = nouvellePos.Y.Offset}
            sauvegarderConfig()
        end
    end)

    if config.PositionFenetre then
        cadrePrincipal.Position = UDim2.new(0.5, config.PositionFenetre.X, 0.5, config.PositionFenetre.Y)
    end

    -- Animation d'ouverture
    cadrePrincipal.Position = UDim2.new(0.5, cadrePrincipal.Position.X.Offset, 0.5, 300)
    local animationOuverture = TweenService:Create(cadrePrincipal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, cadrePrincipal.Position.X.Offset, 0.5, cadrePrincipal.Position.Y.Offset)})
    animationOuverture:Play()

    -- Titre
    local etiquetteTitre = Instance.new("TextLabel")
    etiquetteTitre.Size = UDim2.new(1, -100, 0, 50)
    etiquetteTitre.Position = UDim2.new(0, 200, 0, 0)
    etiquetteTitre.BackgroundTransparency = 1
    etiquetteTitre.Text = titre
    etiquetteTitre.TextColor3 = themeActuel.CouleurTexte
    etiquetteTitre.TextSize = 24
    etiquetteTitre.Font = Enum.Font.GothamBold
    etiquetteTitre.TextXAlignment = Enum.TextXAlignment.Left
    etiquetteTitre.Parent = cadrePrincipal

    -- Barre latérale
    local barreLaterale = Instance.new("Frame")
    barreLaterale.Size = UDim2.new(0, 220, 1, 0) -- Barre latérale agrandie
    barreLaterale.BackgroundColor3 = themeActuel.FondBarreLaterale
    barreLaterale.BorderSizePixel = 0
    barreLaterale.Parent = cadrePrincipal

    local coinsBarreLaterale = Instance.new("UICorner")
    coinsBarreLaterale.CornerRadius = UDim.new(0, 12)
    coinsBarreLaterale.Parent = barreLaterale

    -- Profil du joueur
    local idJoueur = joueur.UserId
    local typeMiniature = Enum.ThumbnailType.HeadShot
    local tailleMiniature = Enum.ThumbnailSize.Size100x100
    local contenuMiniature, _ = Players:GetUserThumbnailAsync(idJoueur, typeMiniature, tailleMiniature)

    local cadreProfil = Instance.new("Frame")
    cadreProfil.Size = UDim2.new(1, -20, 0, 80)
    cadreProfil.Position = UDim2.new(0, 10, 0, 10)
    cadreProfil.BackgroundTransparency = 1
    cadre마nProfil.Parent = barreLaterale

    local iconeProfil = Instance.new("ImageLabel")
    iconeProfil.Size = UDim2.new(0, 60, 0, 60)
    iconeProfil.Position = UDim2.new(0, 10, 0, 10)
    iconeProfil.BackgroundTransparency = 1
    iconeProfil.Image = contenuMiniature or "rbxasset://textures/ui/GuiImagePlaceholder.png"
    iconeProfil.Parent = cadreProfil

    local coinsIconeProfil = Instance.new("UICorner")
    coinsIconeProfil.CornerRadius = UDim.new(1, 0)
    coinsIconeProfil.Parent = iconeProfil

    local etiquetteNom = Instance.new("TextLabel")
    etiquetteNom.Size = UDim2.new(1, -80, 0, 30)
    etiquetteNom.Position = UDim2.new(0, 80, 0, 25)
    etiquetteNom.BackgroundTransparency = 1
    etiquetteNom.Text = joueur.Name
    etiquetteNom.TextColor3 = themeActuel.CouleurTexte
    etiquetteNom.TextSize = 18
    etiquetteNom.Font = Enum.Font.Gotham
    etiquetteNom.TextXAlignment = Enum.TextXAlignment.Left
    etiquetteNom.TextTruncate = Enum.TextTruncate.AtEnd
    etiquetteNom.Parent = cadreProfil

    -- Effet de survol du profil
    cadreProfil.InputBegan:Connect(function(entree)
        if entree.UserInputType == Enum.UserInputType.MouseMovement then
            local animationSurvol = TweenService:Create(etiquetteNom, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextColor3 = themeActuel.CouleurTexteSurvol})
            animationSurvol:Play()
        end
    end)

    cadreProfil.InputEnded:Connect(function(entree)
        if entree.UserInputType == Enum.UserInputType.MouseMovement then
            local animationSortie = TweenService:Create(etiquetteNom, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {TextColor3 = themeActuel.CouleurTexte})
            animationSortie:Play()
        end
    end)

    -- Liste des onglets
    local listeOnglets = Instance.new("ScrollingFrame")
    listeOnglets.Size = UDim2.new(1, -20, 1, -100)
    listeOnglets.Position = UDim2.new(0, 10, 0, 90)
    listeOnglets.BackgroundTransparency = 1
    listeOnglets.ScrollBarThickness = 4
    listeOnglets.ScrollBarImageColor3 = themeActuel.CouleurBordure
    listeOnglets.CanvasSize = UDim2.new(0, 0, 0, 0)
    listeOnglets.Parent = barreLaterale

    local dispositionOnglets = Instance.new("UIListLayout")
    dispositionOnglets.SortOrder = Enum.SortOrder.LayoutOrder
    dispositionOnglets.Padding = UDim.new(0, 8)
    dispositionOnglets.Parent = listeOnglets

    dispositionOnglets:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listeOnglets.CanvasSize = UDim2.new(0, 0, 0, dispositionOnglets.AbsoluteContentSize.Y)
    end)

    -- Zone de contenu
    local cadreContenu = Instance.new("Frame")
    cadreContenu.Size = UDim2.new(1, -220, 1, -50)
    cadreContenu.Position = UDim2.new(0, 220, 0, 50)
    cadreContenu.BackgroundColor3 = themeActuel.FondContenu
    cadreContenu.BorderSizePixel = 0
    cadreContenu.Parent = cadrePrincipal

    local coinsContenu = Instance.new("UICorner")
    coinsContenu.CornerRadius = UDim.new(0, 12)
    coinsContenu.Parent = cadreContenu

    -- Bouton de fermeture
    local boutonFermer = Instance.new("TextButton")
    boutonFermer.Size = UDim2.new(0, 40, 0, 40)
    boutonFermer.Position = UDim2.new(1, -45, 0, 5)
    boutonFermer.BackgroundColor3 = themeActuel.FondBouton
    boutonFermer.Text = "✕"
    boutonFermer.TextColor3 = themeActuel.CouleurTexte
    boutonFermer.TextSize = 20
    boutonFermer.Font = Enum.Font.Gotham
    boutonFermer.Parent = cadrePrincipal

    local coinsFermer = Instance.new("UICorner")
    coinsFermer.CornerRadius = UDim.new(0, 8)
    coinsFermer.Parent = boutonFermer

    boutonFermer.MouseEnter:Connect(function()
        local animationSurvol = TweenService:Create(boutonFermer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBoutonSurvol})
        animationSurvol:Play()
    end)

    boutonFermer.MouseLeave:Connect(function()
        local animationSortie = TweenService:Create(boutonFermer, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBouton})
        animationSortie:Play()
    end)

    boutonFermer.MouseButton1Click:Connect(function()
        local animationFermeture = TweenService:Create(cadrePrincipal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {Position = UDim2.new(0.5, cadrePrincipal.Position.X.Offset, 0.5, 300)})
        animationFermeture:Play()
        animationFermeture.Completed:Connect(function()
            interface:Destroy()
        end)
    end)

    -- Bouton de réduction
    local boutonReduire = Instance.new("TextButton")
    boutonReduire.Size = UDim2.new(0, 40, 0, 40)
    boutonReduire.Position = UDim2.new(1, -90, 0, 5)
    boutonReduire.BackgroundColor3 = themeActuel.FondBouton
    boutonReduire.Text = "─"
    boutonReduire.TextColor3 = themeActuel.CouleurTexte
    boutonReduire.TextSize = 20
    boutonReduire.Font = Enum.Font.Gotham
    boutonReduire.Parent = cadrePrincipal

    local coinsReduire = Instance.new("UICorner")
    coinsReduire.CornerRadius = UDim.new(0, 8)
    coinsReduire.Parent = boutonReduire

    boutonReduire.MouseEnter:Connect(function()
        local animationSurvol = TweenService:Create(boutonReduire, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBoutonSurvol})
        animationSurvol:Play()
    end)

    boutonReduire.MouseLeave:Connect(function()
        local animationSortie = TweenService:Create(boutonReduire, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBouton})
        animationSortie:Play()
    end)

    local estReduit = false
    boutonReduire.MouseButton1Click:Connect(function()
        estReduit = not estReduit
        local tailleCible = estReduit and UDim2.new(0, 900, 0, 50) or UDim2.new(0, 900, 0, 600)
        local animationTaille = TweenService:Create(cadrePrincipal, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Size = tailleCible})
        animationTaille:Play()
        barreLaterale.Visible = not estReduit
        cadreContenu.Visible = not estReduit
    end)

    -- Bascule avec RightShift
    local estOuvert = true
    local positionDefaut = cadrePrincipal.Position
    local positionCachee = UDim2.new(0.5, cadrePrincipal.Position.X.Offset, 1.5, 0)

    local function basculerMenu()
        estOuvert = not estOuvert
        local positionCible = estOuvert and positionDefaut or positionCachee
        local animation = TweenService:Create(cadrePrincipal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Position = positionCible})
        animation:Play()
    end

    UserInputService.InputBegan:Connect(function(entree, jeuTraite)
        if jeuTraite then return end
        if entree.KeyCode == Enum.KeyCode.RightShift then
            basculerMenu()
        end
    end)

    -- Gestion des onglets
    local onglets = {}
    local ongletActuel = nil

    function FenetreUI:CreerOnglet(nom)
        print("Création de l'onglet : " .. nom)
        local onglet = {}
        onglet.Nom = nom

        -- Bouton de l'onglet
        local boutonOnglet = Instance.new("TextButton")
        boutonOnglet.Size = UDim2.new(1, -10, 0, 40)
        boutonOnglet.BackgroundColor3 = themeActuel.FondBouton
        boutonOnglet.Text = nom
        boutonOnglet.TextColor3 = themeActuel.CouleurTexte
        boutonOnglet.TextSize = 16
        boutonOnglet.Font = Enum.Font.Gotham
        boutonOnglet.TextXAlignment = Enum.TextXAlignment.Left
        boutonOnglet.TextScaled = false
        boutonOnglet.Parent = listeOnglets

        local margeBouton = Instance.new("UIPadding")
        margeBouton.PaddingLeft = UDim.new(0, 15)
        margeBouton.Parent = boutonOnglet

        local coinsBouton = Instance.new("UICorner")
        coinsBouton.CornerRadius = UDim.new(0, 8)
        coinsBouton.Parent = boutonOnglet

        -- Effets de survol
        boutonOnglet.MouseEnter:Connect(function()
            if ongletActuel ~= onglet then
                local animationSurvol = TweenService:Create(boutonOnglet, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBoutonSurvol})
                animationSurvol:Play()
            end
        end)

        boutonOnglet.MouseLeave:Connect(function()
            if ongletActuel ~= onglet then
                local animationSortie = TweenService:Create(boutonOnglet, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBouton})
                animationSortie:Play()
            end
        end)

        -- Contenu de l'onglet
        local contenuOnglet = Instance.new("ScrollingFrame")
        contenuOnglet.Size = UDim2.new(1, -20, 1, -20)
        contenuOnglet.Position = UDim2.new(0, 10, 0, 10)
        contenuOnglet.BackgroundTransparency = 1
        contenuOnglet.Visible = false
        contenuOnglet.ScrollBarThickness = 4
        contenuOnglet.ScrollBarImageColor3 = themeActuel.CouleurBordure
        contenuOnglet.CanvasSize = UDim2.new(0, 0, 0, 0)
        contenuOnglet.Parent = cadreContenu

        local dispositionContenu = Instance.new("UIListLayout")
        dispositionContenu.FillDirection = Enum.FillDirection.Horizontal
        dispositionContenu.SortOrder = Enum.SortOrder.LayoutOrder
        dispositionContenu.Padding = UDim.new(0, 15)
        dispositionContenu.HorizontalAlignment = Enum.HorizontalAlignment.Left
        dispositionContenu.Parent = contenuOnglet

        dispositionContenu:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contenuOnglet.CanvasSize = UDim2.new(dispositionContenu.AbsoluteContentSize.X / contenuOnglet.AbsoluteSize.X, 0, 0, 0)
        end)

        onglet.Bouton = boutonOnglet
        onglet.Contenu = contenuOnglet
        onglets[nom] = onglet

        -- Sélection de l'onglet
        boutonOnglet.MouseButton1Click:Connect(function()
            if ongletActuel ~= onglet then
                if ongletActuel then
                    ongletActuel.Contenu.Visible = false
                    local animationDeselection = TweenService:Create(ongletActuel.Bouton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBouton})
                    animationDeselection:Play()
                end
                local animationSelection = TweenService:Create(boutonOnglet, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondOngletSelectionne})
                animationSelection:Play()
                contenuOnglet.Visible = true
                ongletActuel = onglet
            end
        end)

        -- Création d'une section
        function onglet:CreerSection(nom)
            print("Création de la section : " .. nom)
            local section = {}
            section.Nom = nom

            local cadreSection = Instance.new("Frame")
            cadreSection.Size = UDim2.new(0, 240, 1, -10)
            cadreSection.BackgroundColor3 = themeActuel.FondBouton
            cadreSection.BorderSizePixel = 0
            cadreSection.Parent = contenuOnglet

            local coinsSection = Instance.new("UICorner")
            coinsSection.CornerRadius = UDim.new(0, 8)
            coinsSection.Parent = cadreSection

            local etiquetteSection = Instance.new("TextLabel")
            etiquetteSection.Size = UDim2.new(1, -20, 0, 30)
            etiquetteSection.Position = UDim2.new(0, 10, 0, 10)
            etiquetteSection.BackgroundTransparency = 1
            etiquetteSection.Text = nom
            etiquetteSection.TextColor3 = themeActuel.CouleurTexte
            etiquetteSection.TextSize = 18
            etiquetteSection.Font = Enum.Font.GothamBold
            etiquetteSection.TextXAlignment = Enum.TextXAlignment.Left
            etiquetteSection.Parent = cadreSection

            local dispositionSection = Instance.new("UIListLayout")
            dispositionSection.SortOrder = Enum.SortOrder.LayoutOrder
            dispositionSection.Padding = UDim.new(0, 10)
            dispositionSection.Parent = cadreSection

            local margeSection = Instance.new("UIPadding")
            margeSection.PaddingLeft = UDim.new(0, 15)
            margeSection.PaddingTop = UDim.new(0, 50)
            margeSection.PaddingBottom = UDim.new(0, 15)
            margeSection.Parent = cadreSection

            dispositionSection:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                cadreSection.Size = UDim2.new(0, 240, 0, dispositionSection.AbsoluteContentSize.Y + 65)
            end)

            section.Cadre = cadreSection

            -- Création d'un interrupteur
            function section:CreerInterrupteur(nom, defaut, rappel)
                local cadreInterrupteur = Instance.new("Frame")
                cadreInterrupteur.Size = UDim2.new(1, -20, 0, 35)
                cadreInterrupteur.BackgroundTransparency = 1
                cadreInterrupteur.Parent = cadreSection

                local etiquetteInterrupteur = Instance.new("TextLabel")
                etiquetteInterrupteur.Size = UDim2.new(0.7, 0, 1, 0)
                etiquetteInterrupteur.Position = UDim2.new(0, 5, 0, 0)
                etiquetteInterrupteur.BackgroundTransparency = 1
                etiquetteInterrupteur.Text = nom
                etiquetteInterrupteur.TextColor3 = themeActuel.CouleurTexte
                etiquetteInterrupteur.TextSize = 16
                etiquetteInterrupteur.Font = Enum.Font.Gotham
                etiquetteInterrupteur.TextXAlignment = Enum.TextXAlignment.Left
                etiquetteInterrupteur.Parent = cadreInterrupteur

                local boutonInterrupteur = Instance.new("TextButton")
                boutonInterrupteur.Size = UDim2.new(0, 30, 0, 30)
                boutonInterrupteur.Position = UDim2.new(1, -35, 0, 2)
                boutonInterrupteur.BackgroundColor3 = defaut and themeActuel.CouleurAccent or themeActuel.FondBouton
                boutonInterrupteur.Text = defaut and "✔" or ""
                boutonInterrupteur.TextColor3 = Color3.fromRGB(255, 255, 255)
                boutonInterrupteur.TextSize = 14
                boutonInterrupteur.Font = Enum.Font.Code
                boutonInterrupteur.Parent = cadreInterrupteur

                local coinsInterrupteur = Instance.new("UICorner")
                coinsInterrupteur.CornerRadius = UDim.new(0, 8)
                coinsInterrupteur.Parent = boutonInterrupteur

                local etat = defaut
                local cleConfig = onglet.Nom .. "_" .. section.Nom .. "_" .. nom .. "_Interrupteur"
                if config[cleConfig] ~= nil then
                    etat = config[cleConfig]
                    boutonInterrupteur.BackgroundColor3 = etat and themeActuel.CouleurAccent or themeActuel.FondBouton
                    boutonInterrupteur.Text = etat and "✔" or ""
                end

                boutonInterrupteur.MouseEnter:Connect(function()
                    local animationSurvol = TweenService:Create(boutonInterrupteur, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBoutonSurvol})
                    animationSurvol:Play()
                end)

                boutonInterrupteur.MouseLeave:Connect(function()
                    local animationSortie = TweenService:Create(boutonInterrupteur, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = etat and themeActuel.CouleurAccent or themeActuel.FondBouton})
                    animationSortie:Play()
                end)

                boutonInterrupteur.MouseButton1Click:Connect(function()
                    etat = not etat
                    local animation = TweenService:Create(boutonInterrupteur, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = etat and themeActuel.CouleurAccent or themeActuel.FondBouton
                    })
                    animation:Play()
                    boutonInterrupteur.Text = etat and "✔" or ""
                    config[cleConfig] = etat
                    sauvegarderConfig()
                    rappel(etat)
                end)
            end

            -- Création d'un curseur
            function section:CreerCurseur(nom, min, max, defaut, rappel)
                local cadreCurseur = Instance.new("Frame")
                cadreCurseur.Size = UDim2.new(1, -20, 0, 50)
                cadreCurseur.BackgroundTransparency = 1
                cadreCurseur.Parent = cadreSection

                local etiquetteCurseur = Instance.new("TextLabel")
                etiquetteCurseur.Size = UDim2.new(0.5, 0, 0, 25)
                etiquetteCurseur.Position = UDim2.new(0, 5, 0, 0)
                etiquetteCurseur.BackgroundTransparency = 1
                etiquetteCurseur.Text = nom .. ": " .. defaut
                etiquetteCurseur.TextColor3 = themeActuel.CouleurTexte
                etiquetteCurseur.TextSize = 16
                etiquetteCurseur.Font = Enum.Font.Gotham
                etiquetteCurseur.TextXAlignment = Enum.TextXAlignment.Left
                etiquetteCurseur.Parent = cadreCurseur

                local barreCurseur = Instance.new("Frame")
                barreCurseur.Size = UDim2.new(1, -10, 0, 8)
                barreCurseur.Position = UDim2.new(0, 5, 0, 30)
                barreCurseur.BackgroundColor3 = themeActuel.FondBouton
                barreCurseur.Parent = cadreCurseur

                local coinsBarreCurseur = Instance.new("UICorner")
                coinsBarreCurseur.CornerRadius = UDim.new(0, 4)
                coinsBarreCurseur.Parent = barreCurseur

                local remplissageCurseur = Instance.new("Frame")
                remplissageCurseur.Size = UDim2.new((defaut - min) / (max - min), 0, 1, 0)
                remplissageCurseur.BackgroundColor3 = themeActuel.CouleurAccent
                remplissageCurseur.BorderSizePixel = 0
                remplissageCurseur.Parent = barreCurseur

                local coinsRemplissage = Instance.new("UICorner")
                coinsRemplissage.CornerRadius = UDim.new(0, 4)
                coinsRemplissage.Parent = remplissageCurseur

                local boutonCurseur = Instance.new("TextButton")
                boutonCurseur.Size = UDim2.new(0, 16, 0, 16)
                boutonCurseur.Position = UDim2.new((defaut - min) / (max - min), -8, 0, -4)
                boutonCurseur.BackgroundColor3 = themeActuel.CouleurAccent
                boutonCurseur.Text = ""
                boutonCurseur.Parent = barreCurseur

                local coinsBoutonCurseur = Instance.new("UICorner")
                coinsBoutonCurseur.CornerRadius = UDim.new(1, 0)
                coinsBoutonCurseur.Parent = boutonCurseur

                local cleConfig = onglet.Nom .. "_" .. section.Nom .. "_" .. nom .. "_Curseur"
                if config[cleConfig] ~= nil then
                    defaut = config[cleConfig]
                    remplissageCurseur.Size = UDim2.new((defaut - min) / (max - min), 0, 1, 0)
                    boutonCurseur.Position = UDim2.new((defaut - min) / (max - min), -8, 0, -4)
                    etiquetteCurseur.Text = nom .. ": " .. defaut
                end

                local glisse = false
                boutonCurseur.InputBegan:Connect(function(entree)
                    if entree.UserInputType == Enum.UserInputType.MouseButton1 then
                        glisse = true
                    end
                end)

                boutonCurseur.InputEnded:Connect(function(entree)
                    if entree.UserInputType == Enum.UserInputType.MouseButton1 then
                        glisse = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(entree)
                    if glisse and entree.UserInputType == Enum.UserInputType.MouseMovement then
                        local positionSouris = UserInputService:GetMouseLocation()
                        local positionRelative = (positionSouris.X - barreCurseur.AbsolutePosition.X) / barreCurseur.AbsoluteSize.X
                        positionRelative = math.clamp(positionRelative, 0, 1)
                        local valeur = math.floor(min + (max - min) * positionRelative)
                        local animationRemplissage = TweenService:Create(remplissageCurseur, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(positionRelative, 0, 1, 0)})
                        local animationBouton = TweenService:Create(boutonCurseur, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = UDim2.new(positionRelative, -8, 0, -4)})
                        animationRemplissage:Play()
                        animationBouton:Play()
                        etiquetteCurseur.Text = nom .. ": " .. valeur
                        config[cleConfig] = valeur
                        sauvegarderConfig()
                        rappel(valeur)
                    end
                end)
            end

            -- Création d'une liste déroulante
            function section:CreerListeDeroulante(nom, options, defaut, rappel)
                local cadreListe = Instance.new("Frame")
                cadreListe.Size = UDim2.new(1, -20, 0, 35)
                cadreListe.BackgroundTransparency = 1
                cadreListe.Parent = cadreSection

                local etiquetteListe = Instance.new("TextLabel")
                etiquetteListe.Size = UDim2.new(0.7, 0, 1, 0)
                etiquetteListe.Position = UDim2.new(0, 5, 0, 0)
                etiquetteListe.BackgroundTransparency = 1
                etiquetteListe.Text = nom .. ": " .. defaut
                etiquetteListe.TextColor3 = themeActuel.CouleurTexte
                etiquetteListe.TextSize = 16
                etiquetteListe.Font = Enum.Font.Gotham
                etiquetteListe.TextXAlignment = Enum.TextXAlignment.Left
                etiquetteListe.Parent = cadreListe

                local boutonListe = Instance.new("TextButton")
                boutonListe.Size = UDim2.new(0, 30, 0, 30)
                boutonListe.Position = UDim2.new(1, -35, 0, 2)
                boutonListe.BackgroundColor3 = themeActuel.FondBouton
                boutonListe.Text = "▼"
                boutonListe.TextColor3 = themeActuel.CouleurTexte
                boutonListe.TextSize = 16
                boutonListe.Font = Enum.Font.Code
                boutonListe.Parent = cadreListe

                local coinsBoutonListe = Instance.new("UICorner")
                coinsBoutonListe.CornerRadius = UDim.new(0, 8)
                coinsBoutonListe.Parent = boutonListe

                boutonListe.MouseEnter:Connect(function()
                    local animationSurvol = TweenService:Create(boutonListe, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBoutonSurvol})
                    animationSurvol:Play()
                end)

                boutonListe.MouseLeave:Connect(function()
                    local animationSortie = TweenService:Create(boutonListe, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBouton})
                    animationSortie:Play()
                end)

                local menuListe = Instance.new("ScrollingFrame")
                menuListe.Size = UDim2.new(0.5, 0, 0, 0)
                menuListe.Position = UDim2.new(0.5, 0, 1, 5)
                menuListe.BackgroundColor3 = themeActuel.FondBouton
                menuListe.Visible = false
                menuListe.ScrollBarThickness = 4
                menuListe.ScrollBarImageColor3 = themeActuel.CouleurBordure
                menuListe.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
                menuListe.Parent = cadreListe

                local coinsMenuListe = Instance.new("UICorner")
                coinsMenuListe.CornerRadius = UDim.new(0, 8)
                coinsMenuListe.Parent = menuListe

                local dispositionMenuListe = Instance.new("UIListLayout")
                dispositionMenuListe.SortOrder = Enum.SortOrder.LayoutOrder
                dispositionMenuListe.Padding = UDim.new(0, 5)
                dispositionMenuListe.Parent = menuListe

                local cleConfig = onglet.Nom .. "_" .. section.Nom .. "_" .. nom .. "_ListeDeroulante"
                if config[cleConfig] ~= nil then
                    defaut = config[cleConfig]
                    etiquetteListe.Text = nom .. ": " .. defaut
                end

                for _, option in ipairs(options) do
                    local boutonOption = Instance.new("TextButton")
                    boutonOption.Size = UDim2.new(1, -10, 0, 25)
                    boutonOption.BackgroundColor3 = themeActuel.FondBouton
                    boutonOption.Text = option
                    boutonOption.TextColor3 = themeActuel.CouleurTexte
                    boutonOption.TextSize = 14
                    boutonOption.Font = Enum.Font.Gotham
                    boutonOption.Parent = menuListe

                    local coinsOption = Instance.new("UICorner")
                    coinsOption.CornerRadius = UDim.new(0, 6)
                    coinsOption.Parent = boutonOption

                    boutonOption.MouseEnter:Connect(function()
                        local animationSurvol = TweenService:Create(boutonOption, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBoutonSurvol})
                        animationSurvol:Play()
                    end)

                    boutonOption.MouseLeave:Connect(function()
                        local animationSortie = TweenService:Create(boutonOption, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = themeActuel.FondBouton})
                        animationSortie:Play()
                    end)

                    boutonOption.MouseButton1Click:Connect(function()
                        etiquetteListe.Text = nom .. ": " .. option
                        local animationFermeture = TweenService:Create(menuListe, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0.5, 0, 0, 0)})
                        animationFermeture:Play()
                        menuListe.Visible = false
                        config[cleConfig] = option
                        sauvegarderConfig()
                        rappel(option)
                    end)
                end

                boutonListe.MouseButton1Click:Connect(function()
                    menuListe.Visible = not menuListe.Visible
                    local tailleCible = menuListe.Visible and UDim2.new(0.5, 0, 0, math.min(#options * 30, 120)) or UDim2.new(0.5, 0, 0, 0)
                    local animationTaille = TweenService:Create(menuListe, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = tailleCible})
                    animationTaille:Play()
                end)
            end

            return section
        end

        return onglet
    end

    return FenetreUI
end

return XyloKitUI
