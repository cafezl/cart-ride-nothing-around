Exit code: 0
Wall time: 0.8 seconds
Total output lines: 2240
Output:
-- =============================================================================
-- Nothrilo ðŸ‡§ðŸ‡· â€” Menu completo por Cafezl
-- VersÃ£o auditada: bugs corrigidos + novas funÃ§Ãµes
-- =============================================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local StarterGui     = game:GetService("StarterGui")

local LocalPlayer  = Players.LocalPlayer
local MENU_NAME    = "Nothrilo ðŸ‡§ðŸ‡·"
local UI_TITLE     = MENU_NAME .. " | Feito por Cafezl"
local CoreGui      = game:GetService("CoreGui")
local originalGravity = workspace.Gravity
local destroyNothrilo
local destroyed = false

-- Encerra instÃ¢ncia anterior (evita menus duplicados)
local previousRuntime = CoreGui:FindFirstChild("NothriloRuntime")
if previousRuntime then
    local previousCleanup = previousRuntime:FindFirstChild("Cleanup")
    if previousCleanup and previousCleanup:IsA("BindableEvent") then
        previousCleanup:Fire()
    end
    previousRuntime:Destroy()
end

local runtime = Instance.new("Folder")
runtime.Name  = "NothriloRuntime"
runtime.Parent = CoreGui

local runtimeCleanup = Instance.new("BindableEvent")
runtimeCleanup.Name   = "Cleanup"
runtimeCleanup.Parent = runtime

-- Remove GUIs antigas do Rayfield ou versÃµes anteriores do Nothrilo
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        if gui.Name:lower():find("rayfield", 1, true) then
            gui:Destroy()
        elseif gui.Name == "NothriloLauncher"
            or gui.Name == "NothriloNotifications"
            or gui.Name == "NothriloLoading"
            or gui.Name == "NothriloMobileFly"
        then
            gui:Destroy()
        else
            local main   = gui:FindFirstChild("Main")
            local header = main and main:FindFirstChild("MainHeader")
            local title  = header and header:FindFirstChild("title")
            if title and title.Text:find("Nothrilo", 1, true) then
                gui:Destroy()
            end
        end
    end
end

-- Tema escuro â€” sÃ³ os detalhes passam pelo RGB
local Theme = {
    SchemeColor  = Color3.fromRGB(255, 0, 170),
    Background   = Color3.fromRGB(8, 8, 10),
    Header       = Color3.fromRGB(15, 15, 18),
    TextColor    = Color3.fromRGB(245, 245, 245),
    ElementColor = Color3.fromRGB(22, 22, 27),
}

-- =============================================================================
-- Tela de carregamento
-- =============================================================================
local function showStartupCard()
    local gui  = Instance.new("ScreenGui")
    gui.Name            = "NothriloLoading"
    gui.ResetOnSpawn    = false
    gui.IgnoreGuiInset  = true
    gui.DisplayOrder    = 10050
    gui.Parent          = CoreGui

    local card = Instance.new("Frame")
    card.Name            = "Card"
    card.AnchorPoint     = Vector2.new(0.5, 0.5)
    card.Position        = UDim2.fromScale(0.5, 0.5)
    card.Size            = UDim2.fromOffset(360, 108)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    card.BorderSizePixel = 0
    card.Parent          = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color     = Theme.SchemeColor
    stroke.Parent    = card

    local titleL = Instance.new("TextLabel")
    titleL.BackgroundTransparency = 1
    titleL.Position  = UDim2.fromOffset(24, 20)
    titleL.Size      = UDim2.new(1, -48, 0, 24)
    titleL.Font      = Enum.Font.GothamBold
    titleL.Text      = MENU_NAME
    titleL.TextColor3 = Color3.fromRGB(248, 248, 250)
    titleL.TextSize  = 18
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.Parent    = card

    local subtitleL = Instance.new("TextLabel")
    subtitleL.BackgroundTransparency = 1
    subtitleL.Position  = UDim2.fromOffset(24, 48)
    subtitleL.Size      = UDim2.new(1, -48, 0, 18)
    subtitleL.Font      = Enum.Font.Gotham
    subtitleL.Text      = "Feito por Cafezl"
    subtitleL.TextColor3 = Color3.fromRGB(205, 205, 214)
    subtitleL.TextSize  = 13
    subtitleL.TextXAlignment = Enum.TextXAlignment.Left
    subtitleL.Parent    = card

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position  = UDim2.fromOffset(24, 72)
    status.Size      = UDim2.new(1, -48, 0, 16)
    status.Font      = Enum.Font.Gotham
    status.Text      = "Carregando menu..."
    status.TextColor3 = Theme.SchemeColor
    status.TextSize  = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent    = card

    return gui, status
end

local startupGui, startupStatus = showStartupCard()

local libraryOk, LibraryOrError = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"
    ))()
end)

if not libraryOk or type(LibraryOrError) ~= "table" then
    if startupStatus then
        startupStatus.Text      = "NÃ£o foi possÃ­vel carregar. Tente de novo."
        startupStatus.TextColor3 = Color3.fromRGB(255, 100, 120)
    end
    warn(MENU_NAME .. ": falha ao carregar biblioteca: " .. tostring(LibraryOrError))
    task.wait(2.5)
    if startupGui and startupGui.Parent then startupGui:Destroy() end
    if runtime    and runtime.Parent    then runtime:Destroy()    end
    return
end

for secondsLeft = 10, 1, -1 do
    if startupStatus and startupStatus.Parent then
        startupStatus.Text = "Carregando menu... " .. secondsLeft .. "s"
    end
    task.wait(1)
end
if startupGui and startupGui.Parent then startupGui:Destroy() end

local Library = LibraryOrError
local Window  = Library.CreateLib(UI_TITLE, Theme)

-- =============================================================================
-- Sistema de notificaÃ§Ãµes (toasts)
-- =============================================================================
local toastContainer
local toastStrokes = {}

local function notify(title, text)
    if not toastContainer or not toastContainer.Parent then
        warn((title or MENU_NAME) .. ": " .. (text or ""))
        return
    end

    local card = Instance.new("Frame")
    card.Name             = "NothriloToast"
    card.Size             = UDim2.new(1, 0, 0, 74)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
    card.BackgroundTransparency = 1
    card.BorderSizePixel  = 0
    card.Parent           = toastContainer

    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 15)

    local stroke = Instance.new("UIStroke")
    stroke.Name        = "RGBStroke"
    stroke.Thickness   = 1.5
    stroke.Transparency = 1
    stroke.Parent      = card
    table.insert(toastStrokes, stroke)

    local icon = Instance.new("TextLabel")
    icon.Size             = UDim2.fromOffset(42, 42)
    icon.Position         = UDim2.fromOffset(14, 16)
    icon.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
    icon.BackgroundTransparency = 1
    icon.Font             = Enum.Font.GothamBold
    icon.Text             = "N"
    icon.TextColor3       = Color3.fromRGB(255, 255, 255)
    icon.TextSize         = 18
    icon.TextTransparency = 1
    icon.Parent           = card
    Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size             = UDim2.new(1, -76, 0, 20)
    titleLabel.Position         = UDim2.fromOffset(68, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font             = Enum.Font.GothamBold
    titleLabel.Text             = title or MENU_NAME
    titleLabel.TextColor3       = Color3.fromRGB(250, 250, 252)
    titleLabel.TextSize         = 14
    titleLabel.TextTransparency = 1
    titleLabel.TextXAlignment   = Enum.TextXAlignment.Left
    titleLabel.Parent           = card

    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Size              = UDim2.new(1, -76, 0, 30)
    bodyLabel.Position          = UDim2.fromOffset(68, 34)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.Font              = Enum.Font.Gotham
    bodyLabel.Text              = text or ""
    bodyLabel.TextColor3        = Color3.fromRGB(185, 185, 195)
    bodyLabel.TextSize          = 12
    bodyLabel.TextTransparency  = 1
    bodyLabel.TextWrapped       = true
    bodyLabel.TextXAlignment    = Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment    = Enum.TextYAlignment.Top
    bodyLabel.Parent            = card

    local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(card,       ti, { BackgroundTransparency = 0 }):Play()
    TweenService:Create(stroke,     TweenInfo.new(0.22), { Transparency = 0.15 }):Play()
    TweenService:Create(icon,       TweenInfo.new(0.22), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.22), { TextTransparency = 0 }):Play()
    TweenService:Create(bodyLabel,  TweenInfo.new(0.22), { TextTransparency = 0 }):Play()

    task.delay(4, function()
        if not card.Parent then return end
        local tiOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(card,       tiOut, { BackgroundTransparency = 1 }):Play()
        TweenService:Create(stroke,     tiOut, { Transparency = 1 }):Play()
        TweenService:Create(icon,       tiOut, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
        TweenService:Create(titleLabel, tiOut, { TextTransparency = 1 }):Play()
        TweenService:Create(bodyLabel,  tiOut, { TextTransparency = 1 }):Play()
        task.wait(0.25)
        card:Destroy()
    end)
end

-- =============================================================================
-- Helpers de personagem
-- =============================================================================
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid(character)
    character = character or getCharacter()
    return character and (
        character:FindFirstChildOfClass("Humanoid")
        or character:WaitForChild("Humanoid", 5)
    )
end

local function getRoot(character)
    character = character or getCharacter()
    return character and (
        character:FindFirstChild("HumanoidRootPart")
        or character:WaitForChild("HumanoidRootPart", 5)
    )
end

local function teleportCharacter(cframe)
    local root = getRoot()
    if not root then
        notify("Teleporte", "HumanoidRootPart nÃ£o encontrado.")
        return false
    end
    root.CFrame = cframe
    return true
end

-- =============================================================================
-- ESP
-- =============================================================================
local ESP_TAG             = "NothriloESP"
local espEnabled          = false
local espObjects          = {}
local espPlayerConnections = {}
local espGlobalConnections = {}
local espSession          = 0

local function getESPColor(player)
    if player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return Color3.fromRGB(190, 130, 255)
end

local function removeESP(player)
    local objects = espObjects[player]
    if not objects then return end
    for _, object in pairs(objects) do
        if object and object.Parent then object:Destroy() end
    end
    espObjects[player] = nil
end

local function refreshESPColor(player)
    local objects = espObjects[player]
    if not objects then return end
    local color = getESPColor(player)
    if objects.Highlight and objects.Highlight.Parent then
        objects.Highlight.FillColor    = color
        objects.Highlight.OutlineColor = color
    end
    if objects.Label and objects.Label.Parent then
        objects.Label.TextColor3 = color
    end
end

local function refreshESPSize(player)
    local objects = espObjects[player]
    if not objects or not objects.Billboard or not objects.Billboard.Parent then return end
    local localCharacter = LocalPlayer.Character
    local localRoot      = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local targetRoot     = objects.Billboard.Adornee
    if not localRoot or not targetRoot or not targetRoot.Parent then return end

    local distance     = (localRoot.Position - targetRoot.Position).Magnitude
    local showDistance = 150
    objects.Billboard.Enabled = distance >= showDistance
    if not objects.Billboard.Enabled then return end

    local progress = math.clamp((distance - showDistance) / 450, 0, 1)
    objects.Billboard.Size = UDim2.fromOffset(
        math.floor(82  + (170 - 82)  * progress),
        math.floor(18  + (36  - 18)  * progress)
    )
end

local function addESP(player, character)
    if not espEnabled or player == LocalPlayer then return end
    character = character or player.Character
    if not character or not character.Parent then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    removeESP(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name          = ESP_TAG .. "Name"
    billboard.Size          = UDim2.fromOffset(78, 16)
    billboard.Enabled       = false
    billboard.Adornee       = root
    billboard.AlwaysOnTop   = true
    billboard.LightInfluence = 0
    billboard.MaxDistance   = math.huge
    billboard.StudsOffset   = Vector3.new(0, 3.2, 0)
    billboard.Parent        = root

    local label = Instance.new("TextLabel")
    label.Name                 = "NameLabel"
    label.Size                 = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font                 = Enum.Font.GothamBold
    label.Text                 = player.DisplayName ~= "" and player.DisplayName or player.Name
    label.TextScaled           = true
    label.TextStrokeColor3     = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Parent               = billboard

    local highlight = Instance.new("Highlight")
    highlight.Name             = ESP_TAG
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode        = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee          = character
    highlight.Parent           = character

    espObjects[player] = { Billboard = billboard, Label = label, Highlight = highlight }
    refreshESPColor(player)
    refreshESPSize(player)
end

local function disconnectESPPlayer(player)
    local connections = espPlayerConnections[player]
    if connections then
        for _, c in ipairs(connections) do c:Disconnect() end
    end
    espPlayerConnections[player] = nil
end

local function watchESPPlayer(player)
    if player == LocalPlayer then return end
    disconnectESPPlayer(player)
    local connections = {}
    espPlayerConnections[player] = connections

    table.insert(connections, player.CharacterAdded:Connect(function(character)
        task.wait(0.2)
        addESP(player, character)
    end))
    table.insert(connections, player.CharacterRemoving:Connect(function()
        removeESP(player)
    end))
    table.insert(connections, player:GetPropertyChangedSignal("Team"):Connect(function()
        refreshESPColor(player)
    end))
    addESP(player, player.Character)
end

local function clearESP()
    for _, c in ipairs(espGlobalConnections) do c:Disconnect() end
    table.clear(espGlobalConnections)
    for player in pairs(espPlayerConnections) do disconnectESPPlayer(player) end
    for player in pairs(espObjects) do removeESP(player) end
end

local function setESP(enabled)
    espEnabled = enabled
    espSession = espSession + 1
    clearESP()
    if not enabled then notify("ESP", "Desligado.") return end

    for _, player in ipairs(Players:GetPlayers()) do watchESPPlayer(player) end
    table.insert(espGlobalConnections, Players.PlayerAdded:Connect(watchESPPlayer))
    table.insert(espGlobalConnections, Players.PlayerRemoving:Connect(function(player)
        removeESP(player)
        disconnectESPPlayer(player)
    end))

    local session = espSession
    task.spawn(function()
        while espEnabled and session == espSession do
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local objects = espObjects[player]
                    local valid = objects
                        and objects.Billboard and objects.Billboard.Parent
                        and objects.Highlight and objects.Highlight.Parent
                    if not valid then
                        removeESP(player)
                        addESP(player, player.Character)
                    else
                        refreshESPSize(player)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
    notify("ESP", "Ligado: nomes e contornos ativos.")
end

-- =============================================================================
-- Voo (Vehicle Fly)
-- =============================================================================
local FLYING         = false
local vehicleFlySpeed = 1
local flyKeyDown
local flyKeyUp
local flyHumanoid
local flyAutoRotate
local flyPlatformStand
local mouse        = LocalPlayer:GetMouse()
local flyTouchUp   = 0
local flyTouchDown = 0
local flyMobileGui

local function showMobileFlyControls(visible)
    if not UserInputService.TouchEnabled then return end
    if flyMobileGui and flyMobileGui.Parent then
        flyMobileGui.Enabled = visible
        return
    end
    if not visible then return end

    local gui = Instance.new("ScreenGui")
    gui.Name           = "NothriloMobileFly"
    gui.ResetOnSpawn   = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder   = 10020
    gui.Parent         = CoreGui
    flyMobileGui       = gui

    local panel = Instance.new("Frame")
    panel.Name              = "ControlesDeVoo"
    panel.AnchorPoint       = Vector2.new(1, 0.5)
    panel.Position          = UDim2.new(1, -16, 0.5, 0)
    panel.Size              = UDim2.fromOffset(72, 124)
    panel.BackgroundColor3  = Color3.fromRGB(10, 10, 13)
    panel.BackgroundTransparency = 0.12
    panel.BorderSizePixel   = 0
    panel.Parent            = gui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    local ps = Instance.new("UIStroke", panel)
    ps.Color = Theme.SchemeColor
    ps.Thickness = 1

    local titleL = Instance.new("TextLabel")
    titleL.BackgroundTransparency = 1
    titleL.Position = UDim2.fromOffset(0, 6)
    titleL.Size     = UDim2.new(1, 0, 0, 18)
    titleL.Font     = Enum.Font.GothamBold
    titleL.Text     = "VOO"
    titleL.TextColor3 = Color3.fromRGB(245, 245, 245)
    titleL.TextSize = 11
    titleL.Parent   = panel

    local function makeBtn(symbol, y, setDir)
        local btn = Instance.new("TextButton")
        btn.Size              = UDim2.fromOffset(52, 38)
        btn.Position          = UDim2.new(0.5, -26, 0, y)
        btn.BackgroundColor3  = Color3.fromRGB(28, 28, 35)
        btn.BorderSizePixel   = 0
        btn.AutoButtonColor   = false
        btn.Font              = Enum.Font.GothamBold
        btn.Text            …12255 tokens truncated…ot menuGui then
    warn(MENU_NAME .. ": nÃ£o foi possÃ­vel localizar a janela Kavo.")
    return
end

-- Arredonda todos os UICorner
local function applyRoundedStyle(root)
    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("UICorner") then object.CornerRadius = UDim.new(0, 12) end
    end
end
applyRoundedStyle(menuGui)
menuGui.DescendantAdded:Connect(function(object)
    if object:IsA("UICorner") then object.CornerRadius = UDim.new(0, 12) end
end)

-- Textbox helper: encontra pela label ao lado
getKavoTextBoxByLabel = function(labelText)
    for _, element in ipairs(menuGui:GetDescendants()) do
        if element:IsA("TextButton") and element.Name == "textboxElement" then
            local title = element:FindFirstChild("togName")
            local input = element:FindFirstChildOfClass("TextBox")
            if title and title.Text == labelText and input then return input end
        end
    end
    return nil
end

restoreKavoTextBox = function(labelText, value)
    task.delay(0.22, function()
        local input = getKavoTextBoxByLabel(labelText)
        if input and input.Parent then input.Text = tostring(value) end
    end)
end

local function configureKavoTextBox(labelText, placeholder, value)
    local input = getKavoTextBoxByLabel(labelText)
    if not input then return end
    input.PlaceholderText = placeholder
    if value ~= nil then input.Text = tostring(value) end
end

-- Traduz placeholders para PT-BR
for _, object in ipairs(menuGui:GetDescendants()) do
    if object:IsA("TextBox") and object.PlaceholderText == "Type here!" then
        object.PlaceholderText = "Digite aqui..."
    end
end

configureKavoTextBox("Ir atÃ© Jogador",    "Nome ou comeÃ§o do nome", nil)
configureKavoTextBox("Velocidade do Voo", "Digite a velocidade",    nil)
configureKavoTextBox("Nome do Alvo",      "Nome ou comeÃ§o do nome", nil)
configureKavoTextBox("ForÃ§a Normal",      "2500", 2500)
configureKavoTextBox("ForÃ§a em Descidas", "800",  800)

-- Badges de atalho (quadrinhos com a tecla no canto direito de cada item)
local customKeybindIcons = {}

local function addShortcutBadge(labelText, keyText)
    for _, element in ipairs(menuGui:GetDescendants()) do
        if element:IsA("TextButton") then
            local title
            for _, child in ipairs(element:GetDescendants()) do
                if child:IsA("TextLabel") and child.Text == labelText then
                    title = child; break
                end
            end

            if title and not element:FindFirstChild("NothriloShortcut_" .. keyText) then
                local badgeWidth = keyText == "1/2/3" and 42 or 21
                local badge      = Instance.new("TextButton")
                badge.Name           = "NothriloShortcut_" .. keyText
                badge.Size           = UDim2.fromOffset(badgeWidth, 21)
                badge.Position       = UDim2.new(0.84, -(badgeWidth - 21), 0.18, 0)
                badge.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
                badge.BorderSizePixel = 0
                badge.AutoButtonColor = false
                badge.Font           = Enum.Font.GothamBold
                badge.Text           = keyText
                badge.TextColor3     = Theme.SchemeColor
                badge.TextSize       = keyText == "1/2/3" and 9 or 12
                badge.ZIndex         = 3
                badge.Parent         = element
                Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)
                table.insert(customKeybindIcons, badge)

                badge.Activated:Connect(function()
                    if     keyText == "V"     then flyToggleControl:UpdateToggle(nil, not flyEnabled)
                    elseif keyText == "L"     then espToggleControl:UpdateToggle(nil, not espEnabled)
                    elseif keyText == "P"     then infiniteJumpToggleControl:UpdateToggle(nil, not infiniteJump)
                    elseif keyText == "T"     then giveClickTeleportTool()
                    elseif keyText == "1"     then teleportToCheckpoint(1)
                    elseif keyText == "2"     then teleportToCheckpoint(2)
                    elseif keyText == "3"     then teleportToCheckpoint(3)
                    elseif keyText == "1/2/3" then notify("Checkpoints", "Use NumPad 1, 2 ou 3.")
                    elseif keyText == "B"     then boostToggleControl:UpdateToggle(nil, not boostActive)
                    elseif keyText == "K"     then setMenuVisible(false)
                    elseif keyText == "X" and destroyNothrilo then destroyNothrilo()
                    end
                end)
                return
            end
        end
    end
end

local function replaceKeybindLeftIcon(labelText, iconText)
    for _, element in ipairs(menuGui:GetDescendants()) do
        if element:IsA("TextButton") and element.Name == "keybindElement" then
            local titleLabel, keyLabel
            for _, child in ipairs(element:GetChildren()) do
                if child:IsA("TextLabel") and child.Name == "togName" then
                    if child.Position.X.Scale < 0.2 then titleLabel = child
                    else keyLabel = child end
                end
            end
            if titleLabel and titleLabel.Text == labelText then
                local oldIcon = element:FindFirstChild("touch")
                if oldIcon  then oldIcon.Visible  = false end
                if keyLabel then keyLabel.Visible = false end
                local icon = Instance.new("TextLabel")
                icon.Name             = "NothriloKeyIcon"
                icon.Size             = UDim2.fromOffset(21, 21)
                icon.Position         = UDim2.new(0.02, 0, 0.18, 0)
                icon.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
                icon.BorderSizePixel  = 0
                icon.Font             = Enum.Font.GothamBold
                icon.Text             = iconText
                icon.TextColor3       = Theme.SchemeColor
                icon.TextSize         = 12
                icon.Parent           = element
                Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 4)
                table.insert(customKeybindIcons, icon)
                return
            end
        end
    end
end

-- Badges das abas originais
addShortcutBadge("Voo do VeÃ­culo",      "V")
addShortcutBadge("ESP",                 "L")
addShortcutBadge("Pulo Infinito",       "P")
addShortcutBadge("Teleporte por Clique","T")
addShortcutBadge("Boost do Carrinho",   "B")
addShortcutBadge("Ir ao Checkpoint 1",  "1")
addShortcutBadge("Ir ao Checkpoint 2",  "2")
addShortcutBadge("Ir ao Checkpoint 3",  "3")

-- Sistema de toast
local toastGui = Instance.new("ScreenGui")
toastGui.Name           = "NothriloNotifications"
toastGui.ResetOnSpawn   = false
toastGui.IgnoreGuiInset = true
toastGui.DisplayOrder   = 10001
toastGui.Parent         = menuGui.Parent

toastContainer = Instance.new("Frame")
toastContainer.Name               = "ToastContainer"
toastContainer.AnchorPoint        = Vector2.new(1, 0)
toastContainer.Position           = UDim2.new(1, -18, 0, 20)
toastContainer.Size               = UDim2.fromOffset(300, 300)
toastContainer.BackgroundTransparency = 1
toastContainer.Parent             = toastGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding    = UDim.new(0, 8)
toastLayout.SortOrder  = Enum.SortOrder.LayoutOrder
toastLayout.Parent     = toastContainer

-- Drag helper (mouse e touch)
local function enableDrag(target, handle, onDragEnd)
    target.Active = true
    handle.Active = true
    local dragging, dragInput, dragStart, startPos, wasDragged = false, nil, nil, nil, false

    local function updatePos(input)
        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then wasDragged = true end
        target.Position = UDim2.new(
            startPos.X.Scale,  startPos.X.Offset + delta.X,
            startPos.Y.Scale,  startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging   = true
        wasDragged = false
        dragStart  = input.Position
        startPos   = target.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if onDragEnd then onDragEnd(wasDragged) end
            end
        end)
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then updatePos(input) end
    end)
end

-- Launcher (botÃ£o para reabrir quando minimizado)
local launcherGui = Instance.new("ScreenGui")
launcherGui.Name           = "NothriloLauncher"
launcherGui.ResetOnSpawn   = false
launcherGui.IgnoreGuiInset = true
launcherGui.DisplayOrder   = 10000
launcherGui.Parent         = menuGui.Parent

local launcher = Instance.new("TextButton")
launcher.Name             = "OpenNothriloMenu"
launcher.Size             = UDim2.fromOffset(178, 50)
launcher.Position         = UDim2.new(0, 16, 0.5, -25)
launcher.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
launcher.BorderSizePixel  = 0
launcher.AutoButtonColor  = false
launcher.Font             = Enum.Font.GothamBold
launcher.Text             = "    " .. string.upper(MENU_NAME)
launcher.TextColor3       = Color3.fromRGB(255, 255, 255)
launcher.TextSize         = 16
launcher.TextXAlignment   = Enum.TextXAlignment.Left
launcher.Visible          = false
launcher.Parent           = launcherGui
Instance.new("UICorner", launcher).CornerRadius = UDim.new(0, 8)

local launcherStroke = Instance.new("UIStroke")
launcherStroke.Thickness = 2
launcherStroke.Parent    = launcher

local launcherIcon = Instance.new("TextLabel")
launcherIcon.BackgroundTransparency = 1
launcherIcon.Size     = UDim2.fromOffset(38, 50)
launcherIcon.Position = UDim2.fromOffset(6, 0)
launcherIcon.Font     = Enum.Font.GothamBold
launcherIcon.Text     = "N"
launcherIcon.TextSize = 20
launcherIcon.Parent   = launcher

destroyed = false
-- BUG CORRIGIDO: setMenuVisible precisava ser declarada antes de ser referenciada
-- nos callbacks de badge. Agora Ã© local forward-declared corretamente.
local setMenuVisible
setMenuVisible = function(visible)
    if destroyed then return end
    menuGui.Enabled    = visible
    launcher.Visible   = not visible
end

local main   = menuGui:FindFirstChild("Main")
local header = main and main:FindFirstChild("MainHeader")
local originalClose = header and header:FindFirstChild("close")
if originalClose then
    originalClose.Visible = false
    originalClose.Active  = false
end

if header then
    local minimize = Instance.new("TextButton")
    minimize.Name             = "Minimize"
    minimize.Size             = UDim2.fromOffset(28, 24)
    minimize.Position         = UDim2.new(1, -34, 0, 2)
    minimize.BackgroundTransparency = 1
    minimize.AutoButtonColor  = false
    minimize.Font             = Enum.Font.GothamBold
    minimize.Text             = "â€”"
    minimize.TextColor3       = Color3.fromRGB(255, 255, 255)
    minimize.TextSize         = 20
    minimize.Parent           = header
    minimize.MouseButton1Click:Connect(function() setMenuVisible(false) end)
    enableDrag(main, header)
end

local launcherLastDrag = 0
enableDrag(launcher, launcher, function(wasDragged)
    if wasDragged then launcherLastDrag = os.clock() end
end)
launcher.Activated:Connect(function()
    if os.clock() - launcherLastDrag < 0.25 then return end
    setMenuVisible(true)
end)

-- =============================================================================
-- Atalhos de teclado globais
-- =============================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if destroyed or gameProcessed or UserInputService:GetFocusedTextBox() then return end

    if input.KeyCode == Enum.KeyCode.V then
        flyToggleControl:UpdateToggle(nil, not flyEnabled)
    elseif input.KeyCode == Enum.KeyCode.L then
        espToggleControl:UpdateToggle(nil, not espEnabled)
    elseif input.KeyCode == Enum.KeyCode.P then
        infiniteJumpToggleControl:UpdateToggle(nil, not infiniteJump)
    elseif input.KeyCode == Enum.KeyCode.T then
        giveClickTeleportTool()
    elseif input.KeyCode == Enum.KeyCode.B then
        boostToggleControl:UpdateToggle(nil, not boostActive)
    elseif input.KeyCode == Enum.KeyCode.KeypadOne then
        teleportToCheckpoint(1)
    elseif input.KeyCode == Enum.KeyCode.KeypadTwo then
        teleportToCheckpoint(2)
    elseif input.KeyCode == Enum.KeyCode.KeypadThree then
        teleportToCheckpoint(3)
    elseif input.KeyCode == Enum.KeyCode.K then
        setMenuVisible(not menuGui.Enabled)
    elseif input.KeyCode == Enum.KeyCode.X then
        destroyNothrilo()
    end
end)

-- =============================================================================
-- DestruiÃ§Ã£o limpa
-- =============================================================================
local running = true
destroyNothrilo = function()
    if destroyed then return end
    destroyed    = true
    running      = false
    killerActive = false
    infiniteJump = false

    fakeLagSession = fakeLagSession + 1
    if fakeLagHumanoid and fakeLagHumanoid.Parent then
        fakeLagHumanoid.WalkSpeed = fakeLagWalkSpeed
        fakeLagHumanoid.JumpPower = fakeLagJumpPower
    end
    fakeLagHumanoid, fakeLagWalkSpeed, fakeLagJumpPower = nil, nil, nil

    if spinConn then spinConn:Disconnect() spinConn = nil end

    noclipEnabled = false
    restoreNoclip()
    invisEnabled = false
    setLocalInvisible(false)

    godEnabled = false
    if godRespawnConn then godRespawnConn:Disconnect(); godRespawnConn = nil end
    if godConn then godConn:Disconnect(); godConn = nil end

    antiAfkEnabled = false
    if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end

    stopFly()
    stopBoost()
    espEnabled   = false
    espSession   = espSession + 1
    clearESP()
    stabilizer.enabled = false
    cleanupStabilizer()
    restorePanicStop()
    workspace.Gravity = originalGravity

    if antiFlipConn    then antiFlipConn:Disconnect()    antiFlipConn    = nil end
    if autobrakeConn   then autobrakeConn:Disconnect()   autobrakeConn   = nil end
    if freecamConn     then freecamConn:Disconnect()     freecamConn     = nil end
    if spectateConn    then spectateConn:Disconnect()    spectateConn    = nil end
    workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

    if flyMobileGui and flyMobileGui.Parent then flyMobileGui:Destroy() end
    if toastGui     and toastGui.Parent     then toastGui:Destroy()     end
    if launcherGui  and launcherGui.Parent  then launcherGui:Destroy()  end
    if menuGui      and menuGui.Parent      then menuGui:Destroy()      end
    if runtime      and runtime.Parent      then runtime:Destroy()      end
end

runtimeCleanup.Event:Connect(destroyNothrilo)

-- =============================================================================
-- ABA: Comandos (atalhos listados)
-- =============================================================================
local CommandsTab     = Window:NewTab("Comandos")
commandsTabButton     = menuGui:FindFirstChild("ComandosTabButton", true)
local CommandsSection = CommandsTab:NewSection("Atalhos")

local function addCmd(label, desc, fn)
    CommandsSection:NewButton(label, desc, fn)
    addShortcutBadge(label, label:sub(1, 1))
end

CommandsSection:NewButton("V  â€¢  Voo do VeÃ­culo",       "Tecla V", function() flyToggleControl:UpdateToggle(nil, not flyEnabled) end)
CommandsSection:NewButton("L  â€¢  ESP",                  "Tecla L", function() espToggleControl:UpdateToggle(nil, not espEnabled) end)
CommandsSection:NewButton("P  â€¢  Pulo Infinito",        "Tecla P", function() infiniteJumpToggleControl:UpdateToggle(nil, not infiniteJump) end)
CommandsSection:NewButton("T  â€¢  Teleporte por Clique", "Tecla T", giveClickTeleportTool)
CommandsSection:NewButton("B  â€¢  Boost do Carrinho",    "Tecla B", function() boostToggleControl:UpdateToggle(nil, not boostActive) end)
CommandsSection:NewButton("NumPad 1/2/3  â€¢  Checkpoints","Teclado numÃ©rico", function()
    notify("Checkpoints", "Use NumPad 1, 2 ou 3.")
end)
CommandsSection:NewButton("K  â€¢  Minimizar / Abrir",    "Tecla K", function() setMenuVisible(false) end)
CommandsSection:NewButton("X  â€¢  Fechar o Nothrilo",    "Tecla X", destroyNothrilo)

addShortcutBadge("V  â€¢  Voo do VeÃ­culo",        "V")
addShortcutBadge("L  â€¢  ESP",                   "L")
addShortcutBadge("P  â€¢  Pulo Infinito",         "P")
addShortcutBadge("T  â€¢  Teleporte por Clique",  "T")
addShortcutBadge("B  â€¢  Boost do Carrinho",     "B")
addShortcutBadge("NumPad 1/2/3  â€¢  Checkpoints","1/2/3")
addShortcutBadge("K  â€¢  Minimizar / Abrir",     "K")
addShortcutBadge("X  â€¢  Fechar o Nothrilo",     "X")

task.delay(0.3, function()
    if not menuGui or not menuGui.Parent then return end
    addShortcutBadge("V  â€¢  Voo do VeÃ­culo",        "V")
    addShortcutBadge("L  â€¢  ESP",                   "L")
    addShortcutBadge("P  â€¢  Pulo Infinito",         "P")
    addShortcutBadge("T  â€¢  Teleporte por Clique",  "T")
    addShortcutBadge("B  â€¢  Boost do Carrinho",     "B")
    addShortcutBadge("NumPad 1/2/3  â€¢  Checkpoints","1/2/3")
    addShortcutBadge("K  â€¢  Minimizar / Abrir",     "K")
    addShortcutBadge("X  â€¢  Fechar o Nothrilo",     "X")
end)

-- =============================================================================
-- ABA: Interface
-- =============================================================================
local GuiTab     = Window:NewTab("Interface")
local GuiSection = GuiTab:NewSection("Interface")

GuiSection:NewKeybind("Fechar Menu", "Tecla X fecha o Nothrilo.", Enum.KeyCode.X, destroyNothrilo)
replaceKeybindLeftIcon("Fechar Menu", "X")
addShortcutBadge("Fechar Menu", "X")

-- =============================================================================
-- Loop RGB
-- =============================================================================
task.spawn(function()
    while running and not destroyed and menuGui.Parent and launcherGui.Parent do
        local rgb = Color3.fromHSV((os.clock() * 0.12) % 1, 0.85, 1)
        Library:ChangeColor("SchemeColor", rgb)
        if commandsTabButton and commandsTabButton.Parent then
            commandsTabButton.BackgroundColor3 = rgb
        end
        launcherStroke.Color = rgb
        launcherIcon.TextColor3 = rgb
        for i = #customKeybindIcons, 1, -1 do
            local icon = customKeybindIcons[i]
            if icon and icon.Parent then icon.TextColor3 = rgb
            else table.remove(customKeybindIcons, i) end
        end
        for i = #toastStrokes, 1, -1 do
            local stroke = toastStrokes[i]
            if stroke and stroke.Parent then stroke.Color = rgb
            else table.remove(toastStrokes, i) end
        end
        task.wait(0.30)
    end
end)

notify(MENU_NAME, "Feito por Cafezl  â€¢  K minimiza e reabre o menu.")

