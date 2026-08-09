-- =============================================================================
-- Nothrilo 🇧🇷 — Menu completo por Cafezl
-- Versão auditada: bugs corrigidos + novas funções
-- =============================================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local StarterGui     = game:GetService("StarterGui")

local LocalPlayer  = Players.LocalPlayer
local MENU_NAME    = "Nothrilo 🇧🇷"
local UI_TITLE     = MENU_NAME .. " | Feito por Cafezl"

-- Alguns ambientes bloqueiam GUI direto em CoreGui e outros usam gethui().
-- Escolher o pai aqui evita o menu morrer antes mesmo de aparecer.
local function getGuiParent()
    if type(gethui) == "function" then
        local ok, parent = pcall(gethui)
        if ok and parent then return parent end
    end

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if ok and coreGui then
        local probe = Instance.new("ScreenGui")
        local accepted = pcall(function() probe.Parent = coreGui end)
        if probe.Parent then probe:Destroy() end
        if accepted then return coreGui end
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local CoreGui      = getGuiParent()

-- A Kavo sempre cria a janela em game.CoreGui, enquanto alguns executores
-- retornam outro container em gethui(). Mantenha todos os locais possíveis
-- para localizar e limpar a interface completa sem perder as abas finais.
local guiRoots = {}
local guiRootSet = {}
local function addGuiRoot(root)
    if root and not guiRootSet[root] then
        guiRootSet[root] = true
        table.insert(guiRoots, root)
    end
end

addGuiRoot(CoreGui)
pcall(function() addGuiRoot(game:GetService("CoreGui")) end)
addGuiRoot(LocalPlayer:FindFirstChild("PlayerGui"))

local destroyNothrilo
local destroyed = false
local runtimeConnections = {}

local function trackConnection(connection)
    table.insert(runtimeConnections, connection)
    return connection
end

-- Encerra qualquer skin anterior da suíte. Assim Nothrilo e Cafezitos não
-- disputam os mesmos atalhos, movers e forças quando um é aberto após o outro.
for _, guiRoot in ipairs(guiRoots) do
    for _, runtimeName in ipairs({ "NothriloRuntime", "CafezitosRuntime" }) do
        local previousRuntime = guiRoot:FindFirstChild(runtimeName)
        if previousRuntime then
            local previousCleanup = previousRuntime:FindFirstChild("Cleanup")
            if previousCleanup and previousCleanup:IsA("BindableEvent") then
                previousCleanup:Fire()
            end
            previousRuntime:Destroy()
        end
    end
end

-- Só capture o valor original depois que a instância anterior se restaurou.
local originalGravity = workspace.Gravity

local runtime = Instance.new("Folder")
runtime.Name  = "NothriloRuntime"
runtime.Parent = CoreGui

local runtimeCleanup = Instance.new("BindableEvent")
runtimeCleanup.Name   = "Cleanup"
runtimeCleanup.Parent = runtime

-- O handler existe desde o começo da inicialização. Se uma execução nova
-- chegar durante o carregamento, a instância incompleta também é descartada.
trackConnection(runtimeCleanup.Event:Connect(function()
    if destroyNothrilo then
        destroyNothrilo()
        return
    end
    destroyed = true
    for index = #runtimeConnections, 1, -1 do
        local connection = runtimeConnections[index]
        pcall(function() connection:Disconnect() end)
        runtimeConnections[index] = nil
    end
    if runtime and runtime.Parent then runtime:Destroy() end
end))

-- Remove somente GUIs antigas do próprio Nothrilo.
for _, guiRoot in ipairs(guiRoots) do
    for _, gui in ipairs(guiRoot:GetChildren()) do
        if gui:IsA("ScreenGui") then
            if gui.Name == "NothriloLauncher"
                or gui.Name == "NothriloNotifications"
                or gui.Name == "NothriloLoading"
                or gui.Name == "NothriloMobileFly"
            then
                gui:Destroy()
            else
                local main   = gui:FindFirstChild("Main")
                local header = main and main:FindFirstChild("MainHeader")
                local title  = header and header:FindFirstChild("title")
                if title and title:IsA("TextLabel") and title.Text:find("Nothrilo", 1, true) then
                    gui:Destroy()
                end
            end
        end
    end
end

-- Tema escuro — só os detalhes passam pelo RGB
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
    card.Size            = UDim2.new(0.9, 0, 0, 108)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    card.BorderSizePixel = 0
    card.Parent          = gui
    local cardSize = Instance.new("UISizeConstraint")
    cardSize.MinSize = Vector2.new(260, 108)
    cardSize.MaxSize = Vector2.new(360, 108)
    cardSize.Parent = card

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
        startupStatus.Text      = "Não foi possível carregar. Tente de novo."
        startupStatus.TextColor3 = Color3.fromRGB(255, 100, 120)
    end
    warn(MENU_NAME .. ": falha ao carregar biblioteca: " .. tostring(LibraryOrError))
    task.wait(2.5)
    if startupGui and startupGui.Parent then startupGui:Destroy() end
    if runtime    and runtime.Parent    then runtime:Destroy()    end
    return
end

for _, message in ipairs({ "Preparando funções...", "Montando abas...", "Pronto!" }) do
    if startupStatus and startupStatus.Parent then startupStatus.Text = message end
    task.wait(0.25)
end
if startupGui and startupGui.Parent then startupGui:Destroy() end

local Library = LibraryOrError
local windowOk, WindowOrError = pcall(function()
    return Library.CreateLib(UI_TITLE, Theme)
end)
if not windowOk or not WindowOrError then
    warn(MENU_NAME .. ": falha ao criar a janela: " .. tostring(WindowOrError))
    if runtime and runtime.Parent then runtime:Destroy() end
    return
end
local Window = WindowOrError

-- =============================================================================
-- Sistema de notificações (toasts)
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
        notify("Teleporte", "HumanoidRootPart não encontrado.")
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

    local distance           = (localRoot.Position - targetRoot.Position).Magnitude
    local scaleStartDistance = 150
    objects.Billboard.Enabled = true

    local progress = math.clamp((distance - scaleStartDistance) / 450, 0, 1)
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

-- Estados declarados antes dos workers para que respawn, Killer e atalhos
-- sempre enxerguem a mesma fonte de verdade.
local flyEnabled = false
local flyToggleControl
local boostToggleControl
local panicToggleControl
local stopBoost
local setMenuVisible
local fakeLagActive = false
local fakeLagSession = 0
local fakeLagHumanoid
local desiredWalkSpeed
local desiredJumpPower
local desiredJumpHeight
local createdTools = {}

-- Fly, câmera livre, giro e spectate não podem escrever na câmera ao mesmo
-- tempo. Cada modo registra como parar e o próximo assume de forma atômica.
local activeCameraMode
local cameraModeStoppers = {}

local function restoreDefaultCamera()
    local camera = workspace.CurrentCamera
    if not camera then return end
    camera.CameraType = Enum.CameraType.Custom
    local humanoid = getHumanoid()
    if humanoid then camera.CameraSubject = humanoid end
end

local function claimCameraMode(mode)
    if activeCameraMode == mode then return end
    local previous = activeCameraMode
    activeCameraMode = mode
    local stopper = previous and cameraModeStoppers[previous]
    if stopper then pcall(stopper) end
end

local function releaseCameraMode(mode)
    if activeCameraMode ~= mode then return end
    activeCameraMode = nil
    restoreDefaultCamera()
end

local function resetCameraModes()
    local previous = activeCameraMode
    activeCameraMode = nil
    local stopper = previous and cameraModeStoppers[previous]
    if stopper then pcall(stopper) end
    restoreDefaultCamera()
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
local flySession   = 0

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
        btn.Text              = symbol
        btn.TextColor3        = Theme.SchemeColor
        btn.TextSize          = 22
        btn.Parent            = panel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setDir(1)
                btn.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
                setDir(0)
                btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
            end
        end)
    end

    makeBtn("▲", 30, function(v) flyTouchUp   = v end)
    makeBtn("▼", 74, function(v) flyTouchDown = v end)
end

local function stopFly()
    flySession = flySession + 1
    FLYING     = false
    flyTouchUp = 0
    flyTouchDown = 0
    showMobileFlyControls(false)

    if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
    if flyKeyUp   then flyKeyUp:Disconnect()   flyKeyUp   = nil end

    -- Remove os movers imediatamente; não espera o loop antigo chegar ao fim.
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local gyro = root:FindFirstChild("CafezlVehicleFlyGyro")
        local velocity = root:FindFirstChild("CafezlVehicleFlyVelocity")
        if gyro then gyro:Destroy() end
        if velocity then velocity:Destroy() end
    end

    local humanoid = flyHumanoid or getHumanoid()
    if humanoid then
        humanoid.PlatformStand = flyPlatformStand ~= nil and flyPlatformStand or false
        humanoid.AutoRotate    = flyAutoRotate    ~= nil and flyAutoRotate    or true
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,    true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end)
    end
    flyHumanoid     = nil
    flyAutoRotate   = nil
    flyPlatformStand = nil
    releaseCameraMode("fly")
end

local function startVehicleFly()
    stopFly()
    local session = flySession
    local character = getCharacter()
    local root      = getRoot(character)
    local humanoid  = getHumanoid(character)
    if not root or not humanoid then
        notify("Voo do Veículo", "Personagem não encontrado.")
        return false
    end

    claimCameraMode("fly")

    flyHumanoid      = humanoid
    flyAutoRotate    = humanoid.AutoRotate
    flyPlatformStand = humanoid.PlatformStand
    humanoid.AutoRotate = false
    if not humanoid.SeatPart and not UserInputService.TouchEnabled then
        humanoid.PlatformStand = true
    end
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,    false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end)

    local control     = { F=0, B=0, L=0, R=0, Q=0, E=0 }
    local lastControl = { F=0, B=0, L=0, R=0, Q=0, E=0 }
    FLYING = true
    showMobileFlyControls(true)

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name      = "CafezlVehicleFlyGyro"
    bodyGyro.P         = 90000
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame    = root.CFrame
    bodyGyro.Parent    = root

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name     = "CafezlVehicleFlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent   = root

    flyKeyDown = mouse.KeyDown:Connect(function(key)
        key = key:lower()
        if     key == "w" then control.F =  vehicleFlySpeed
        elseif key == "s" then control.B = -vehicleFlySpeed
        elseif key == "a" then control.L = -vehicleFlySpeed
        elseif key == "d" then control.R =  vehicleFlySpeed
        elseif key == "e" then control.Q =  vehicleFlySpeed * 2
        elseif key == "q" then control.E = -vehicleFlySpeed * 2
        end
    end)

    flyKeyUp = mouse.KeyUp:Connect(function(key)
        key = key:lower()
        if     key == "w" then control.F = 0
        elseif key == "s" then control.B = 0
        elseif key == "a" then control.L = 0
        elseif key == "d" then control.R = 0
        elseif key == "e" then control.Q = 0
        elseif key == "q" then control.E = 0
        end
    end)

    task.spawn(function()
        while FLYING and session == flySession and root.Parent and humanoid.Parent do
            task.wait()

            local keyboardMoving = (control.L + control.R ~= 0)
                or (control.F + control.B ~= 0)
                or (control.Q + control.E ~= 0)
            local mobileDir     = humanoid.MoveDirection
            local mobileMoving  = UserInputService.TouchEnabled and (
                Vector3.new(mobileDir.X, 0, mobileDir.Z).Magnitude > 0.05
                or flyTouchUp ~= 0 or flyTouchDown ~= 0
            )
            local moving = keyboardMoving or mobileMoving
            local spd    = moving and 50 or 0

            if keyboardMoving then
                lastControl = { F=control.F, B=control.B, L=control.L, R=control.R, Q=control.Q, E=control.E }
            end

            local cur = keyboardMoving and control or lastControl
            if keyboardMoving and spd > 0 then
                local cam = workspace.CurrentCamera
                bodyVelocity.Velocity = (
                    (cam.CFrame.LookVector * (cur.F + cur.B))
                    + ((cam.CFrame * CFrame.new(
                        cur.L + cur.R,
                        (cur.F + cur.B + cur.Q + cur.E) * 0.2,
                        0
                    )).Position - cam.CFrame.Position)
                ) * spd
            elseif mobileMoving and spd > 0 then
                bodyVelocity.Velocity =
                    Vector3.new(mobileDir.X, 0, mobileDir.Z) * (vehicleFlySpeed * spd)
                    + Vector3.new(0, (flyTouchUp - flyTouchDown) * vehicleFlySpeed * spd, 0)
            else
                bodyVelocity.Velocity = Vector3.zero
            end
            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        end
        if bodyGyro.Parent    then bodyGyro:Destroy()    end
        if bodyVelocity.Parent then bodyVelocity:Destroy() end

        -- Respawn/remoção do personagem encerra também o estado visual.
        if session == flySession and FLYING then
            if flyEnabled and flyToggleControl then
                flyToggleControl:UpdateToggle(nil, false)
            else
                stopFly()
            end
        end
    end)
    return true
end

cameraModeStoppers.fly = function()
    if flyEnabled and flyToggleControl then
        flyToggleControl:UpdateToggle(nil, false)
    else
        stopFly()
    end
end

-- =============================================================================
-- Carrinho: helpers, parada, checkpoints, estabilizador
-- =============================================================================
local function findCartFromSeat(seat)
    if not seat or not seat:IsA("BasePart") then return nil end
    local assemblyRoot = seat.AssemblyRootPart
    local current = seat.Parent
    local fallback
    while current and current ~= workspace do
        if current:IsA("Model") then
            fallback = fallback or current
            local assemblyParts = 0
            for _, object in ipairs(current:GetDescendants()) do
                if object:IsA("BasePart")
                    and (not assemblyRoot or object.AssemblyRootPart == assemblyRoot)
                then
                    assemblyParts = assemblyParts + 1
                    if assemblyParts >= 2 then
                        -- O primeiro Model compatível é o invólucro mais próximo
                        -- do assento, não um Model gigante do mapa.
                        return current
                    end
                end
            end
        end
        current = current.Parent
    end
    return fallback
end

local function getCurrentCart()
    local humanoid = getHumanoid()
    return humanoid and findCartFromSeat(humanoid.SeatPart) or nil
end

-- Retorna a parte principal do carrinho de forma robusta
local function getCartPrimary(cart)
    if not cart then return nil end
    if cart.PrimaryPart then return cart.PrimaryPart end
    local humanoid = getHumanoid()
    local seat = humanoid and humanoid.SeatPart
    if seat and cart:IsAncestorOf(seat) and seat.AssemblyRootPart then
        return seat.AssemblyRootPart
    end
    local firstUnanchored
    for _, part in ipairs(cart:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored then
            firstUnanchored = firstUnanchored or part
            if part.AssemblyRootPart == part then return part end
        end
    end
    return firstUnanchored
end

local panicParts = {}
local panicActive = false
local function restorePanicStop()
    for part, wasAnchored in pairs(panicParts) do
        if part and part.Parent then part.Anchored = wasAnchored end
    end
    panicParts = {}
    panicActive = false
end

local function setPanicStop(enabled)
    if not enabled then
        restorePanicStop()
        notify("Carrinho", "Parada de emergência desligada.")
        return
    end

    local cart = getCurrentCart()
    if not cart then notify("Carrinho", "Sente em um carrinho primeiro.") return end

    if stopBoost then stopBoost() end
    if boostToggleControl then
        task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
    end

    -- Repor um bloqueio anterior antes de capturar o estado do carrinho atual.
    restorePanicStop()
    panicActive = true
    for _, part in ipairs(cart:GetDescendants()) do
        if part:IsA("BasePart") then
            panicParts[part]             = part.Anchored
            part.Anchored                = true
            part.AssemblyLinearVelocity  = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
        end
    end
    notify("Carrinho", "Parada de emergência ligada.")
end

local function teleportCart(cframe)
    local cart = getCurrentCart()
    if not cart then notify("Carrinho", "Sente em um carrinho primeiro.") return end
    local ok = pcall(function() cart:PivotTo(cframe) end)
    if ok then
        notify("Carrinho", "Carrinho movido para o checkpoint.")
    else
        notify("Carrinho", "Não foi possível mover este carrinho.")
    end
end

local STABILIZER_CONFIG = { NORMAL_FORCE = 2500, DOWNHILL_FORCE = 800 }
local stabilizer = {
    enabled = false,
    cart = nil,
    forces = {},
    attachments = {},
    heartbeat = nil,
}

local function cleanupStabilizer()
    if stabilizer.heartbeat then stabilizer.heartbeat:Disconnect() stabilizer.heartbeat = nil end
    for _, force in ipairs(stabilizer.forces) do
        if force and force.Parent then force:Destroy() end
    end
    for _, attachment in ipairs(stabilizer.attachments) do
        if attachment and attachment.Parent then attachment:Destroy() end
    end
    stabilizer.forces = {}
    stabilizer.attachments = {}
    stabilizer.cart   = nil
end

local function getWheels(cart)
    local wheels   = {}
    local keywords = { "wheel", "tire", "tyre", "roda", "pneu", "axle" }
    for _, part in ipairs(cart:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored then
            local name = part.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw, 1, true) then
                    table.insert(wheels, part)
                    break
                end
            end
        end
    end
    if #wheels == 0 then
        local parts = {}
        for _, part in ipairs(cart:GetDescendants()) do
            if part:IsA("BasePart") and not part.Anchored then
                table.insert(parts, part)
            end
        end
        table.sort(parts, function(a, b) return a.Position.Y < b.Position.Y end)
        local count = math.max(1, math.floor(#parts / 3))
        for i = 1, math.min(count, #parts) do table.insert(wheels, parts[i]) end
    end
    return wheels
end

local function applyStabilizer(cart)
    if not cart or not cart.Parent then return end
    cleanupStabilizer()

    local wheels = getWheels(cart)
    if #wheels == 0 then notify("Estabilizador", "Nenhuma roda encontrada.") return end

    stabilizer.cart = cart
    for _, part in ipairs(wheels) do
        local att = part:FindFirstChild("_CafezlStabilizer")
        if not att then
            att        = Instance.new("Attachment")
            att.Name   = "_CafezlStabilizer"
            att.Parent = part
            table.insert(stabilizer.attachments, att)
        end
        local force = Instance.new("VectorForce")
        force.Name       = "CafezlStabilizerForce"
        force.Attachment0 = att
        force.RelativeTo = Enum.ActuatorRelativeTo.World
        force.Force      = Vector3.zero
        force.Parent     = part
        table.insert(stabilizer.forces, force)
    end

    local reference = cart.PrimaryPart or wheels[1]
    stabilizer.heartbeat = RunService.Heartbeat:Connect(function()
        if not reference or not reference.Parent then cleanupStabilizer() return end
        local mag = 0
        if stabilizer.enabled and not FLYING and not panicActive then
            mag = math.abs(reference.AssemblyLinearVelocity.Y) > 5
                and STABILIZER_CONFIG.DOWNHILL_FORCE
                or  STABILIZER_CONFIG.NORMAL_FORCE
        end
        local forceCount = math.max(#stabilizer.forces, 1)
        for _, force in ipairs(stabilizer.forces) do
            if force and force.Parent then
                force.Force = Vector3.new(
                    0,
                    -(mag * force.Parent.AssemblyMass) / forceCount,
                    0
                )
            end
        end
    end)
end

local function refreshStabilizer()
    if stabilizer.enabled then
        local cart = getCurrentCart()
        if cart then applyStabilizer(cart)
        else notify("Estabilizador", "Sente em um carrinho primeiro.") end
    else
        cleanupStabilizer()
    end
end

local seatConnection
local function watchSeat(character)
    local humanoid = getHumanoid(character)
    if not humanoid then return end
    if seatConnection then
        seatConnection:Disconnect()
        seatConnection = nil
    end
    seatConnection = trackConnection(humanoid.Seated:Connect(function(isSeated, seat)
        if not isSeated then
            cleanupStabilizer()
            restorePanicStop()
            if stopBoost then stopBoost() end
            if boostToggleControl then
                task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
            end
            if panicToggleControl then
                task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
            end
        elseif stabilizer.enabled then
            applyStabilizer(findCartFromSeat(seat))
        end
    end))
end
watchSeat()
trackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
    cleanupStabilizer()
    restorePanicStop()
    fakeLagSession = fakeLagSession + 1
    fakeLagActive = false
    fakeLagHumanoid = nil
    if stopBoost then stopBoost() end
    if flyEnabled and flyToggleControl then
        flyToggleControl:UpdateToggle(nil, false)
    else
        stopFly()
    end
    task.defer(resetCameraModes)
    task.defer(watchSeat, character)
    task.delay(0.25, function()
        if destroyed or fakeLagActive then return end
        local humanoid = getHumanoid(character)
        if not humanoid then return end
        if desiredWalkSpeed then humanoid.WalkSpeed = desiredWalkSpeed end
        if humanoid.UseJumpPower and desiredJumpPower then
            humanoid.JumpPower = desiredJumpPower
        elseif not humanoid.UseJumpPower and desiredJumpHeight then
            humanoid.JumpHeight = desiredJumpHeight
        end
    end)
end))

-- =============================================================================
-- Eliminador (Killer)
-- =============================================================================
local function findNearestFreeVehicleSeat()
    local root = getRoot()
    if not root then return nil end
    local bestVS, bestVD = nil, math.huge
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("VehicleSeat") and not inst.Occupant then
            local dist = (root.Position - inst.Position).Magnitude
            if dist < bestVD then bestVS = inst; bestVD = dist end
        end
    end
    return bestVS
end

local function findPlayerByPartialName(value)
    value = (value or ""):match("^%s*(.-)%s*$"):lower()
    if value == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == value or p.DisplayName:lower() == value then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local n = p.Name:lower(); local d = p.DisplayName:lower()
        if n:sub(1, #value) == value or d:sub(1, #value) == value then return p end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(value, 1, true) or p.DisplayName:lower():find(value, 1, true) then return p end
    end
    return nil
end

local function sitOnVehicleSeat(seat)
    local root     = getRoot()
    local humanoid = getHumanoid()
    if not seat or not root or not humanoid or seat.Occupant then return false end
    for _ = 1, 3 do
        if not seat.Parent or seat.Occupant then break end
        root.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
        task.wait(0.12)
        pcall(function() seat:Sit(humanoid) end)
        task.wait(0.2)
        if humanoid.SeatPart == seat or seat.Occupant == humanoid then return true end
        humanoid.Sit = true
        task.wait(0.12)
        if humanoid.SeatPart == seat or seat.Occupant == humanoid then return true end
    end
    return false
end

local killerActive = false
local killerSession = 0

local function moveToTarget(targetRoot, duration, session)
    local root    = getRoot()
    local started = os.clock()
    while os.clock() - started < duration do
        if destroyed or not killerActive or session ~= killerSession then return false end
        if not root or not root.Parent or not targetRoot or not targetRoot.Parent then return false end
        local pos = targetRoot.Position - targetRoot.CFrame.LookVector * 1.2 + Vector3.new(0, 1.5, 0)
        root.CFrame = CFrame.lookAt(pos, targetRoot.Position)
        task.wait()
    end
    return true
end

local function finishKiller(message, session)
    if session and session ~= killerSession then return end
    killerSession = killerSession + 1
    local humanoid = getHumanoid()
    if humanoid then humanoid.Sit = false end
    if flyEnabled and flyToggleControl then
        flyToggleControl:UpdateToggle(nil, false)
    else
        stopFly()
    end
    killerActive = false
    if message then notify("Eliminador", message) end
end

local function executeKiller(partialName)
    if killerActive then notify("Eliminador", "Aguarde a tentativa atual terminar.") return end
    local target = findPlayerByPartialName(partialName)
    if not target or target == LocalPlayer then
        notify("Eliminador", target == LocalPlayer and "Escolha outro jogador." or "Jogador não encontrado.")
        return
    end

    killerSession = killerSession + 1
    local session = killerSession
    killerActive = true
    if flyEnabled and flyToggleControl then
        flyToggleControl:UpdateToggle(nil, false)
    else
        stopFly()
    end
    if stopBoost then stopBoost() end
    if boostToggleControl then
        task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
    end

    local seat = findNearestFreeVehicleSeat()
    if not seat then finishKiller("Não há carrinho livre por perto.", session) return end
    if not sitOnVehicleSeat(seat) then finishKiller("Não foi possível sentar no carrinho.", session) return end
    if destroyed or session ~= killerSession then return end

    if not startVehicleFly() then finishKiller("Não foi possível iniciar o voo.", session) return end
    task.wait(0.15)
    if destroyed or session ~= killerSession then return end

    local targetRoot
    local deadline = os.clock() + 2
    repeat
        local char = target.Character
        targetRoot = char and char:FindFirstChild("HumanoidRootPart")
        if targetRoot then break end
        task.wait(0.2)
    until os.clock() >= deadline or destroyed or session ~= killerSession

    if not targetRoot then finishKiller("Personagem do alvo não carregou.", session) return end
    local reached = moveToTarget(targetRoot, 3, session)
    if session == killerSession then
        finishKiller(reached and "Carrinho levado ao alvo." or "Tentativa cancelada.", session)
    end
end

local function teleportPlayerOrCart(cframe)
    local cart = getCurrentCart()
    if cart then
        return pcall(function() cart:PivotTo(cframe) end)
    end
    return teleportCharacter(cframe)
end

trackConnection(LocalPlayer.CharacterAdded:Connect(function()
    killerSession = killerSession + 1
    killerActive = false
end))

-- =============================================================================
-- Variáveis adiantadas (usadas nos callbacks de atalho)
-- =============================================================================
local getKavoTextBoxByLabel
local restoreKavoTextBox
local infiniteJump = false
local espToggleControl
local infiniteJumpToggleControl

-- =============================================================================
-- ABA: Jogador
-- =============================================================================
local PlayerTab     = Window:NewTab("Jogador")
local PlayerSection = PlayerTab:NewSection("Configurações do Jogador")

PlayerSection:NewSlider("Velocidade", "Velocidade de caminhada (padrão 16).", 500, 0, function(value)
    desiredWalkSpeed = value
    local h = getHumanoid()
    if h and not fakeLagActive then h.WalkSpeed = value end
end)

PlayerSection:NewButton("Redefinir Velocidade", "Volta para 16.", function()
    desiredWalkSpeed = 16
    local h = getHumanoid()
    if h and not fakeLagActive then h.WalkSpeed = 16 end
    notify("Velocidade", "Redefinida para 16.")
end)

infiniteJumpToggleControl = PlayerSection:NewToggle(
    "Pulo Infinito", "Pula no ar. Tecla P.", function(state)
        infiniteJump = state
        notify("Pulo Infinito", state and "Ligado." or "Desligado.")
    end
)

-- BUG CORRIGIDO: JumpRequest dispara bem, mas não estava verificando se
-- o humanoid existia antes de chamar ChangeState
trackConnection(UserInputService.JumpRequest:Connect(function()
    if destroyed or not infiniteJump then return end
    local h = getHumanoid()
    if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

local function giveClickTeleportTool()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    local character = LocalPlayer.Character
    if backpack:FindFirstChild("ClickTP")
        or (character and character:FindFirstChild("ClickTP")) then
        notify("Teleporte por Clique", "A ferramenta já está na mochila.")
        return
    end
    local tool = Instance.new("Tool")
    tool.Name            = "ClickTP"
    tool.RequiresHandle  = false
    tool.Activated:Connect(function()
        teleportCharacter(CFrame.new(mouse.Hit.Position + Vector3.new(0, 2.5, 0)))
    end)
    tool.Parent = backpack
    table.insert(createdTools, tool)
    notify("Teleporte por Clique", "Ferramenta criada. Clique no mapa para teleportar.")
end

PlayerSection:NewButton("Teleporte por Clique", "Cria ferramenta na mochila. Tecla T.", giveClickTeleportTool)

PlayerSection:NewTextBox("Ir até Jogador", "Nome do jogador. Enter.", function(name)
    local player = findPlayerByPartialName(name)
    if not player then notify("Ir até Jogador", "Jogador não encontrado.") return end
    local targetRoot
    local deadline = os.clock() + 2
    repeat
        local char = player.Character
        targetRoot = char and char:FindFirstChild("HumanoidRootPart")
        if targetRoot then break end
        task.wait(0.2)
    until os.clock() >= deadline
    if not targetRoot then notify("Ir até Jogador", "Personagem não carregou.") return end
    teleportCharacter(targetRoot.CFrame * CFrame.new(0, 2, 0))
    notify("Ir até Jogador", "Teleportado para " .. player.DisplayName .. ".")
end)

local function setVehicleFlyEnabled(enabled)
    flyEnabled = enabled
    if enabled then
        if stopBoost then stopBoost() end
        if boostToggleControl then
            task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
        end
        if startVehicleFly() then
            notify("Voo do Veículo", "Ligado.")
        else
            flyEnabled = false
            task.defer(function()
                if flyToggleControl then flyToggleControl:UpdateToggle(nil, false) end
            end)
        end
    else
        stopFly()
        notify("Voo do Veículo", "Desligado.")
    end
end

flyToggleControl = PlayerSection:NewToggle(
    "Voo do Veículo", "Tecla V liga/desliga.", setVehicleFlyEnabled
)

espToggleControl = PlayerSection:NewToggle(
    "ESP", "Destaca jogadores. Tecla L.", setESP
)

PlayerSection:NewTextBox("Velocidade do Voo", "Digite e aperte Enter.", function(value)
    local n = tonumber(value)
    if n and n > 0 then vehicleFlySpeed = n; notify("Voo", "Velocidade: " .. n)
    else notify("Voo", "Digite um número maior que zero.") end
end)

PlayerSection:NewButton("Redefinir Velocidade do Voo", "Volta para 1.", function()
    vehicleFlySpeed = 1
    restoreKavoTextBox("Velocidade do Voo", 1)
    notify("Voo", "Velocidade redefinida para 1.")
end)

-- Novo: God Mode local (impede a morte localmente via Humanoid.Health)
-- BUG CORRIGIDO: usar HealthChanged em vez de loop — mais limpo e sem
-- lag acumulado quando o personagem respawna
local godEnabled = false
local godConn
local godRespawnConn
local godHumanoid
local godOriginalMaxHealth
local godOriginalHealth

local function restoreGodHumanoid()
    if godConn then godConn:Disconnect() godConn = nil end
    local h = godHumanoid
    if h and h.Parent and godOriginalMaxHealth then
        h.MaxHealth = godOriginalMaxHealth
        h.Health = math.clamp(godOriginalHealth or godOriginalMaxHealth, 1, godOriginalMaxHealth)
    end
    godHumanoid, godOriginalMaxHealth, godOriginalHealth = nil, nil, nil
end

local function connectGod()
    restoreGodHumanoid()
    local h = getHumanoid()
    if not h then return end
    godHumanoid = h
    godOriginalMaxHealth = h.MaxHealth
    godOriginalHealth = h.Health
    h.MaxHealth = math.huge
    h.Health = math.huge
    godConn = h.HealthChanged:Connect(function()
        if godEnabled and h.Parent and h.Health < 1 then h.Health = h.MaxHealth end
    end)
end

local function setGodMode(state)
    godEnabled = state
    if not state then
        restoreGodHumanoid()
        notify("God Mode", "Desligado.")
        return
    end
    connectGod()
    if not godRespawnConn then
        godRespawnConn = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.3)
            if godEnabled then connectGod() end
        end)
    end
    notify("God Mode", "Ligado (só funciona localmente).")
end

PlayerSection:NewToggle(
    "God Mode (local)",
    "Impede que sua vida caia abaixo de 1 localmente.",
    setGodMode
)

-- Novo: Anti-AFK — previne kick por inatividade
local antiAfkEnabled = false
local antiAfkConn
PlayerSection:NewToggle("Anti-AFK", "Mantém a sessão de teste ativa.", function(enabled)
    antiAfkEnabled = enabled

    if antiAfkConn then
        antiAfkConn:Disconnect()
        antiAfkConn = nil
    end

    if not enabled then
        notify("Anti-AFK", "Desligado.")
        return
    end

    antiAfkConn = LocalPlayer.Idled:Connect(function()
        if not antiAfkEnabled then return end
        pcall(function()
            local virtualUser = game:GetService("VirtualUser")
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.zero, workspace.CurrentCamera.CFrame)
        end)
    end)

    notify("Anti-AFK", "Ligado.")
end)

-- =============================================================================
-- ABA: Teleporte
-- =============================================================================
local TeleportTab     = Window:NewTab("Teleporte")
local TeleportSection = TeleportTab:NewSection("Teleportes")

TeleportSection:NewButton("Início", "Teleporta para o início da trilha.", function()
    if teleportCharacter(CFrame.new(1, 3.11, 38)) then
        notify("Teleporte", "Teleportado para o início.")
    end
end)

TeleportSection:NewButton("Botão de Carrinho", "Teleporta para o botão do carrinho.", function()
    if teleportCharacter(CFrame.new(-33, 3.11, 21.5) * CFrame.Angles(0, math.rad(180), 0)) then
        notify("Teleporte", "Teleportado para o botão.")
    end
end)

TeleportSection:NewButton("Equipe Suffering", "Teleporta para a área Suffering.", function()
    if teleportCharacter(CFrame.new(-416.844727, 163.402969, 171.087555)) then
        notify("Teleporte", "Teleportado para Suffering.")
    end
end)

TeleportSection:NewButton("Sala Secreta", "Procura Workspace.Misc.Giver.", function()
    local misc  = workspace:FindFirstChild("Misc")
    local giver = misc and misc:FindFirstChild("Giver")
    local part  = giver and (giver:IsA("BasePart") and giver or giver:FindFirstChildWhichIsA("BasePart"))
    if not part then notify("Teleporte", "Misc.Giver não encontrado.") return end
    if teleportPlayerOrCart(part.CFrame * CFrame.new(0, 3, 0)) then
        notify("Teleporte", "Teleportado para a sala secreta.")
    end
end)

local CHECKPOINTS = {
    [1] = CFrame.new(-430.898926, 164.75, 101.645676) * CFrame.Angles(0, math.rad(90),  0),
    [2] = CFrame.new(511.88,       3.69,  306.59)     * CFrame.Angles(0, math.rad(270), 0),
    [3] = CFrame.new(171.09,       2.78, -410.31)     * CFrame.Angles(0, math.rad(90),  0),
}

local function teleportToCheckpoint(number)
    local dest = CHECKPOINTS[number]
    if dest then teleportCart(dest) end
end

-- =============================================================================
-- ABA: Carrinho
-- =============================================================================
local CartTab     = Window:NewTab("Carrinho")
local CartSection = CartTab:NewSection("Controle do Carrinho")

panicToggleControl = CartSection:NewToggle(
    "Parada de Emergência",
    "Para e trava o carrinho.",
    setPanicStop
)

CartSection:NewButton("Ir ao Checkpoint 1", "NumPad 1.", function() teleportToCheckpoint(1) end)
CartSection:NewButton("Ir ao Checkpoint 2", "NumPad 2.", function() teleportToCheckpoint(2) end)
CartSection:NewButton("Ir ao Checkpoint 3", "NumPad 3.", function() teleportToCheckpoint(3) end)

-- Novo: Velocidade do carrinho em tempo real
CartSection:NewButton("Ver Velocidade do Carrinho", "Mostra studs/s na notificação.", function()
    local cart = getCurrentCart()
    if not cart then notify("Velocidade", "Sente em um carrinho primeiro.") return end
    local primary = getCartPrimary(cart)
    if not primary then notify("Velocidade", "Estrutura não reconhecida.") return end
    local vel = primary.AssemblyLinearVelocity.Magnitude
    notify("Velocidade do Cart", string.format("%.1f studs/s", vel))
end)

-- Novo: Ejetar do carrinho
CartSection:NewButton("Ejetar do Carrinho", "Sai do assento atual.", function()
    local h = getHumanoid()
    if h then
        h.Sit = false
        notify("Carrinho", "Ejetado.")
    else
        notify("Carrinho", "Personagem não encontrado.")
    end
end)

local StabilizerSection = CartTab:NewSection("Estabilizador")

StabilizerSection:NewToggle("Estabilizador do Carrinho", "Mantém estável enquanto sentado.", function(state)
    stabilizer.enabled = state
    refreshStabilizer()
    if state and getCurrentCart() then notify("Estabilizador", "Ligado.")
    elseif not state then notify("Estabilizador", "Desligado.") end
end)

StabilizerSection:NewTextBox("Força Normal", "Padrão 2500. Enter.", function(value)
    local n = tonumber(value)
    if n and n > 0 then
        STABILIZER_CONFIG.NORMAL_FORCE = n
        restoreKavoTextBox("Força Normal", n)
        notify("Estabilizador", "Força normal: " .. n)
    else
        notify("Estabilizador", "Digite um número maior que zero.")
    end
end)

StabilizerSection:NewTextBox("Força em Descidas", "Padrão 800. Enter.", function(value)
    local n = tonumber(value)
    if n and n > 0 then
        STABILIZER_CONFIG.DOWNHILL_FORCE = n
        restoreKavoTextBox("Força em Descidas", n)
        notify("Estabilizador", "Força descida: " .. n)
    else
        notify("Estabilizador", "Digite um número maior que zero.")
    end
end)

StabilizerSection:NewButton("Redefinir Forças", "Volta para 2500 e 800.", function()
    STABILIZER_CONFIG.NORMAL_FORCE    = 2500
    STABILIZER_CONFIG.DOWNHILL_FORCE  = 800
    restoreKavoTextBox("Força Normal", 2500)
    restoreKavoTextBox("Força em Descidas", 800)
    refreshStabilizer()
    notify("Estabilizador", "Forças redefinidas.")
end)

-- =============================================================================
-- ABA: Cart+ (boost, anti-flip, freio automático)
-- =============================================================================
local CartExtraTab  = Window:NewTab("Cart+")
local BoostSection  = CartExtraTab:NewSection("Boost e Física")

local boostActive     = false
local boostForce      = 500
local boostConnection
local boostBodyForce  = nil
local boostAttachment
local boostAttachmentCreated = false
local boostCartRoot

stopBoost = function()
    boostActive = false
    if boostConnection then boostConnection:Disconnect() boostConnection = nil end
    if boostBodyForce and boostBodyForce.Parent then
        boostBodyForce:Destroy()
    end
    if boostAttachmentCreated and boostAttachment and boostAttachment.Parent then
        boostAttachment:Destroy()
    end
    boostBodyForce = nil
    boostAttachment = nil
    boostAttachmentCreated = false
    boostCartRoot = nil
end

local function startBoost()
    stopBoost()
    if panicActive or FLYING or killerActive then
        notify("Boost", "Indisponível durante parada, voo ou Eliminador.")
        return false
    end
    local cart = getCurrentCart()
    if not cart then notify("Boost", "Sente em um carrinho primeiro.") return false end
    local primary = getCartPrimary(cart)
    if not primary then notify("Boost", "Estrutura do carrinho não reconhecida.") return false end
    boostCartRoot = primary.AssemblyRootPart or primary

    -- VectorForce substitui BodyForce, que é uma API legada do Roblox.
    local attachment = primary:FindFirstChild("NothriloBoostAttachment")
    if not attachment then
        attachment = Instance.new("Attachment")
        attachment.Name = "NothriloBoostAttachment"
        attachment.Parent = primary
        boostAttachmentCreated = true
    end
    boostAttachment = attachment

    local bf = Instance.new("VectorForce")
    bf.Name = "NothriloBoost"
    bf.Attachment0 = attachment
    bf.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    bf.ApplyAtCenterOfMass = true
    bf.Force = Vector3.zero
    bf.Parent = primary
    boostBodyForce = bf

    boostActive = true
    boostConnection = RunService.Heartbeat:Connect(function()
        local currentCart = getCurrentCart()
        local currentPrimary = currentCart and getCartPrimary(currentCart)
        local currentRoot = currentPrimary and (currentPrimary.AssemblyRootPart or currentPrimary)
        if not boostActive or panicActive or FLYING or killerActive
            or not primary.Parent or not bf.Parent
            or currentCart ~= cart or currentRoot ~= boostCartRoot
        then
            stopBoost()
            if boostToggleControl then
                task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
            end
            return
        end
        -- No espaço da Attachment0, frente é o eixo Z negativo.
        bf.Force = Vector3.new(0, 0, -boostForce * primary.AssemblyMass * 60)
    end)
    notify("Boost", "Ligado — força " .. boostForce .. ".")
    return true
end

boostToggleControl = BoostSection:NewToggle(
    "Boost do Carrinho", "Empurra pra frente. Tecla B.", function(state)
        if state then
            if not startBoost() then
                task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
            end
        else
            stopBoost()
            notify("Boost", "Desligado.")
        end
    end
)

BoostSection:NewSlider("Força do Boost", "Intensidade (padrão 500).", 3000, 0, function(value)
    boostForce = value
    if boostActive and not startBoost() then
        task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
    end
end)

-- Anti-Flip com cooldown correto
local antiFlipEnabled  = false
local antiFlipCooldown = false
local antiFlipConn

BoostSection:NewToggle("Anti-Flip", "Endireita o carrinho ao tombar automaticamente.", function(state)
    antiFlipEnabled = state
    if not state then
        if antiFlipConn then antiFlipConn:Disconnect() antiFlipConn = nil end
        notify("Anti-Flip", "Desligado.")
        return
    end

    antiFlipConn = RunService.Heartbeat:Connect(function()
        if not antiFlipEnabled or antiFlipCooldown or panicActive or FLYING or killerActive then return end
        local cart = getCurrentCart()
        if not cart then return end
        local primary = getCartPrimary(cart)
        if not primary or not primary.Parent then return end

        local dot = primary.CFrame.UpVector:Dot(Vector3.new(0, 1, 0))
        if dot < 0.5 then
            antiFlipCooldown = true
            local pos  = primary.CFrame.Position
            local look = Vector3.new(primary.CFrame.LookVector.X, 0, primary.CFrame.LookVector.Z)
            look = look.Magnitude > 0.01 and look.Unit or Vector3.new(1, 0, 0)
            cart:PivotTo(CFrame.new(pos + Vector3.new(0, 2, 0), pos + Vector3.new(0, 2, 0) + look))
            notify("Anti-Flip", "Carrinho endireitado.")
            task.wait(1.5)
            antiFlipCooldown = false
        end
    end)
    notify("Anti-Flip", "Ligado.")
end)

-- Freio automático ao detectar queda livre
local autobrakeEnabled  = false
local autobrakeCooldown = false
local autobrakeConn

BoostSection:NewToggle("Freio Automático", "Trava ao detectar queda livre.", function(state)
    autobrakeEnabled = state
    if not state then
        if autobrakeConn then autobrakeConn:Disconnect() autobrakeConn = nil end
        notify("Freio Automático", "Desligado.")
        return
    end

    autobrakeConn = RunService.Heartbeat:Connect(function()
        if not autobrakeEnabled or autobrakeCooldown or panicActive or FLYING or killerActive then return end
        local cart = getCurrentCart()
        if not cart then return end
        local primary = getCartPrimary(cart)
        if not primary then return end

        if primary.AssemblyLinearVelocity.Y < -35 then
            autobrakeCooldown = true
            if boostActive then
                stopBoost()
                if boostToggleControl then
                    task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
                end
            end
            for _, part in ipairs(cart:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.AssemblyLinearVelocity  = Vector3.zero
                    part.AssemblyAngularVelocity = Vector3.zero
                end
            end
            notify("Freio Automático", "Queda detectada — travado.")
            task.wait(1)
            autobrakeCooldown = false
        end
    end)
    notify("Freio Automático", "Ligado.")
end)

-- =============================================================================
-- ABA: Extras (jogador)
-- =============================================================================
local ExtrasTab    = Window:NewTab("Extras")
local ExtrasSection = ExtrasTab:NewSection("Movimento e Física")

-- Noclip corrigido: CanCollide precisa ser reposto a cada Stepped
-- porque o motor físico reseta automaticamente
local noclipEnabled = false
local noclipOriginal = {}

local function restoreNoclip()
    for part, canCollide in pairs(noclipOriginal) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end
    table.clear(noclipOriginal)
end

trackConnection(RunService.Stepped:Connect(function()
    if not noclipEnabled then return end
    local character = LocalPlayer.Character
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if noclipOriginal[part] == nil then
                noclipOriginal[part] = part.CanCollide
            end
            part.CanCollide = false
        end
    end
end))

ExtrasSection:NewToggle("Noclip", "Atravessa paredes durante o teste.", function(enabled)
    noclipEnabled = enabled
    if not enabled then restoreNoclip() end
    notify("Noclip", enabled and "Ligado." or "Desligado.")
end)

-- Invisível local: LocalTransparencyModifier só afeta o cliente local
local invisEnabled = false
local invisOriginal = {}

local function setLocalInvisible(enabled)
    local character = LocalPlayer.Character
    if not character then return end

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") or object:IsA("Decal") then
            if enabled and invisOriginal[object] == nil then
                invisOriginal[object] = object.LocalTransparencyModifier
            end
            object.LocalTransparencyModifier = enabled and 1 or (invisOriginal[object] or 0)
        end
    end

    if not enabled then table.clear(invisOriginal) end
end

ExtrasSection:NewToggle("Invisível (local)", "Só você se vê transparente.", function(enabled)
    invisEnabled = enabled
    setLocalInvisible(enabled)
    notify("Invisível", enabled and "Ligado (só você vê)." or "Desligado.")
end)

trackConnection(LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.25)
    if invisEnabled and not destroyed then setLocalInvisible(true) end
end))

ExtrasSection:NewSlider("Jump Power", "Altura do pulo (padrão 50).", 300, 0, function(value)
    local h = getHumanoid()
    if h then
        if h.UseJumpPower then desiredJumpPower = value
        else desiredJumpHeight = value end
        if not fakeLagActive then
            if h.UseJumpPower then h.JumpPower = value else h.JumpHeight = value end
        end
    end
end)

ExtrasSection:NewButton("Redefinir Jump Power", "Volta para 50.", function()
    local h = getHumanoid()
    if h then
        if h.UseJumpPower then desiredJumpPower = 50
        else desiredJumpHeight = 7.2 end
        if not fakeLagActive then
            if h.UseJumpPower then h.JumpPower = 50 else h.JumpHeight = 7.2 end
        end
    end
    notify("Jump Power", "Redefinido.")
end)

ExtrasSection:NewSlider("Gravidade", "Gravidade global (padrão 196.2).", 400, 0, function(value)
    workspace.Gravity = value
end)

ExtrasSection:NewButton("Redefinir Gravidade", "Volta ao valor original do jogo.", function()
    workspace.Gravity = originalGravity
    notify("Gravidade", "Valor original restaurado.")
end)

-- Salvar / restaurar posição (funciona pra jogador e carrinho)
local savedPosition = nil
ExtrasSection:NewButton("Salvar Posição Atual", "Salva onde você está.", function()
    local root = getRoot()
    if not root then notify("Posição", "Personagem não encontrado.") return end
    savedPosition = root.CFrame
    local p = root.Position
    notify("Posição", string.format("Salva em %.0f, %.0f, %.0f", p.X, p.Y, p.Z))
end)

ExtrasSection:NewButton("Voltar à Posição Salva", "Teleporta de volta.", function()
    if not savedPosition then notify("Posição", "Nenhuma posição salva ainda.") return end
    teleportCharacter(savedPosition)
    notify("Posição", "Teleportado.")
end)

-- =============================================================================
-- ABA: Mapa
-- =============================================================================
local MapTab     = Window:NewTab("Mapa")
local MapSection = MapTab:NewSection("Exploração")

-- Ir até parte por nome — busca com prioridade (exato > começo > contém)
MapSection:NewTextBox("Ir até Parte", "Nome da parte no workspace. Enter.", function(value)
    value = value:match("^%s*(.-)%s*$"):lower()
    if value == "" then return end

    local best, bestPriority = nil, 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            local priority = 0
            if name == value then priority = 3
            elseif name:sub(1, #value) == value then priority = 2
            elseif name:find(value, 1, true) then priority = 1
            end
            if priority > bestPriority then best = obj; bestPriority = priority end
        end
    end

    if not best then notify("Mapa", "Parte '" .. value .. "' não encontrada.") return end
    teleportCharacter(best.CFrame * CFrame.new(0, 4, 0))
    notify("Mapa", "Teleportado para: " .. best.Name)
end)

-- Listar partes no output (F9 pra ver)
MapSection:NewButton("Listar Partes no Output (F9)", "Imprime 30 BaseParts no console.", function()
    print("[Nothrilo] === BaseParts no Workspace ===")
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and count < 30 then
            print(("[Nothrilo] %s  pos: %s"):format(obj:GetFullName(), tostring(obj.Position)))
            count = count + 1
        end
    end
    print(("[Nothrilo] %d partes listadas. Abra F9 para ver."):format(count))
    notify("Mapa", count .. " partes no output (F9).")
end)

-- Carrinho: encontra pelo assento, não pelo nome do Model nem por SpawnLocation.
local function findNearestCartSeat()
    local root = getRoot()
    if not root then return nil end

    for _, wantedClass in ipairs({ "VehicleSeat", "Seat" }) do
        local nearest, nearestDistance = nil, math.huge
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA(wantedClass) then
                local distance = (root.Position - object.Position).Magnitude
                if distance < nearestDistance then
                    nearest = object
                    nearestDistance = distance
                end
            end
        end
        if nearest then return nearest end
    end

    return nil
end

MapSection:NewButton("Ir ao Carrinho", "Procura o assento do carrinho mais próximo.", function()
    local seat = findNearestCartSeat()
    if not seat then
        notify("Carrinho", "Nenhum assento de carrinho foi encontrado.")
        return
    end

    if teleportCharacter(seat.CFrame * CFrame.new(0, 4, 0)) then
        notify("Carrinho", "Teleportado para o carrinho.")
    end
end)

-- Câmera livre — WASD + Q/E, desacoplada do personagem
local freecamActive = false
local freecamConn
local freecamSpeed  = 1
local freecamToggleControl

local function stopFreecam()
    freecamActive = false
    if freecamConn then freecamConn:Disconnect() freecamConn = nil end
    releaseCameraMode("freecam")
end

cameraModeStoppers.freecam = function()
    if freecamToggleControl then
        freecamToggleControl:UpdateToggle(nil, false)
    else
        stopFreecam()
    end
end

freecamToggleControl = MapSection:NewToggle("Câmera Livre", "WASD move, Q/E sobe e desce.", function(state)
    if not state then
        stopFreecam()
        notify("Câmera Livre", "Desligada.")
        return
    end

    claimCameraMode("freecam")
    freecamActive = true
    local camera = workspace.CurrentCamera
    if not camera then
        stopFreecam()
        task.defer(function() freecamToggleControl:UpdateToggle(nil, false) end)
        return
    end

    camera.CameraType = Enum.CameraType.Scriptable
    local cf = camera.CFrame

    freecamConn = RunService.RenderStepped:Connect(function()
        if not freecamActive then return end
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then
            cf = CFrame.new(cf.Position + move * freecamSpeed) * (cf - cf.Position)
        end
        camera.CFrame = cf
        camera.Focus = cf * CFrame.new(0, 0, -12)
    end)

    notify("Câmera Livre", "WASD move, Q/E sobe e desce. Desative para voltar.")
end)

MapSection:NewSlider("Velocidade da Câmera Livre", "Velocidade de movimento (1–10).", 10, 1, function(value)
    freecamSpeed = value
end)

-- =============================================================================
-- ABA: Eliminador
-- =============================================================================
local KillerTab     = Window:NewTab("Eliminador")
local KillerSection = KillerTab:NewSection("Controle de Alvo")
local targetName    = ""

KillerSection:NewTextBox("Nome do Alvo", "Parte do nome. Enter.", function(value)
    targetName = value
end)

KillerSection:NewButton("Alcançar Alvo", "Usa o carrinho livre mais próximo.", function()
    if not targetName or targetName:match("^%s*$") then
        notify("Eliminador", "Digite uma parte do nome primeiro.")
        return
    end
    local requested = targetName
    task.spawn(function()
        local ok, err = xpcall(function()
            executeKiller(requested)
        end, debug.traceback)
        if not ok then
            warn(MENU_NAME .. " Killer: " .. err)
            if killerActive then finishKiller("Erro na tentativa. Tente de novo.") end
        end
    end)
end)

-- =============================================================================
-- ABA: Troll
-- =============================================================================
local TrollTab     = Window:NewTab("Troll")
local TrollSection = TrollTab:NewSection("Diversão")

-- Câmera giratória com duração ajustável
local spinDuration = 5
local spinConn

local function stopSpin(silent)
    if spinConn then spinConn:Disconnect() spinConn = nil end
    releaseCameraMode("spin")
    if not silent then notify("Troll", "Câmera voltou ao normal.") end
end

cameraModeStoppers.spin = function() stopSpin(true) end

TrollSection:NewButton("Câmera Giratória", "Gira a câmera por alguns segundos.", function()
    stopSpin(true)
    claimCameraMode("spin")
    local camera = workspace.CurrentCamera
    if not camera then releaseCameraMode("spin") return end
    camera.CameraType = Enum.CameraType.Scriptable
    local startTime  = os.clock()
    local origin     = camera.CFrame

    spinConn = RunService.RenderStepped:Connect(function()
        local elapsed = os.clock() - startTime
        if elapsed >= spinDuration then
            stopSpin(false)
            return
        end
        local angle = elapsed * math.pi * 2
        camera.CFrame = CFrame.new(origin.Position)
            * CFrame.Angles(0, angle, 0)
            * CFrame.new(0, 0, -10)
        camera.Focus = CFrame.new(origin.Position)
    end)
    notify("Troll", "Câmera girando por " .. spinDuration .. "s.")
end)

TrollSection:NewSlider("Duração Câmera (s)", "Segundos de giro.", 30, 1, function(value)
    spinDuration = value
end)

-- Fake Lag ajustável
local fakeLagDuration = 2

local function restoreFakeLag()
    local h = fakeLagHumanoid
    fakeLagActive = false
    if h and h.Parent then
        h.WalkSpeed = desiredWalkSpeed or 16
        if h.UseJumpPower then h.JumpPower = desiredJumpPower or 50
        else h.JumpHeight = desiredJumpHeight or 7.2 end
    end
    fakeLagHumanoid = nil
end

TrollSection:NewButton("Fake Lag", "Congela você por alguns segundos.", function()
    local h = getHumanoid()
    if not h then return end
    if not fakeLagActive then
        desiredWalkSpeed = desiredWalkSpeed or h.WalkSpeed
        desiredJumpPower = desiredJumpPower or h.JumpPower
        desiredJumpHeight = desiredJumpHeight or h.JumpHeight
    elseif fakeLagHumanoid ~= h then
        restoreFakeLag()
    end
    fakeLagSession = fakeLagSession + 1
    local session = fakeLagSession
    fakeLagActive = true
    fakeLagHumanoid = h
    h.WalkSpeed = 0
    if h.UseJumpPower then h.JumpPower = 0 else h.JumpHeight = 0 end
    notify("Troll", "Fake lag por " .. fakeLagDuration .. "s.")
    task.spawn(function()
        task.wait(fakeLagDuration)
        if session ~= fakeLagSession or destroyed then return end
        restoreFakeLag()
        notify("Troll", "Fake lag encerrado.")
    end)
end)

TrollSection:NewSlider("Duração Fake Lag (s)", "Duração em segundos.", 15, 1, function(value)
    fakeLagDuration = value
end)

-- Spectate — segue outro jogador com a câmera
local spectating  = false
local spectateConn

local function stopSpectate(silent)
    spectating = false
    if spectateConn then spectateConn:Disconnect() spectateConn = nil end
    releaseCameraMode("spectate")
    if not silent then notify("Spectate", "Parado.") end
end

cameraModeStoppers.spectate = function() stopSpectate(true) end

TrollSection:NewTextBox("Spectate Jogador", "Nome do jogador. Enter para seguir.", function(value)
    local player = findPlayerByPartialName(value)
    if not player or player == LocalPlayer then notify("Spectate", "Escolha outro jogador.") return end
    stopSpectate(true)
    claimCameraMode("spectate")
    spectating = true
    local camera = workspace.CurrentCamera
    if not camera then stopSpectate(true) return end
    camera.CameraType = Enum.CameraType.Scriptable

    spectateConn = RunService.RenderStepped:Connect(function()
        if not spectating then return end
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then stopSpectate(false) return end
        camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 8, -14), root.Position)
        camera.Focus = CFrame.new(root.Position)
    end)
    notify("Spectate", "Seguindo " .. player.DisplayName .. ".")
end)

TrollSection:NewButton("Parar Spectate", "Para de seguir.", function()
    stopSpectate(false)
end)

-- Teleporte aleatório — filtra partes visíveis e grandes
TrollSection:NewButton("Teleporte Aleatório", "Te joga em uma parte aleatória.", function()
    local parts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart")
            and obj.Transparency < 0.9
            and obj.Size.Magnitude > 2
            and obj ~= workspace.Terrain
        then
            table.insert(parts, obj)
        end
    end
    if #parts == 0 then notify("Troll", "Nenhuma parte útil encontrada.") return end
    local target = parts[math.random(1, #parts)]
    teleportCharacter(target.CFrame * CFrame.new(0, 5, 0))
    notify("Troll", "Caiu em: " .. target.Name)
end)

-- =============================================================================
-- Minimizar / reabrir + drag
-- =============================================================================
local function findMenuGui()
    local fallback
    for _, guiRoot in ipairs(guiRoots) do
        for _, gui in ipairs(guiRoot:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local main   = gui:FindFirstChild("Main", true)
                local header = main and main:FindFirstChild("MainHeader")
                local title  = header and header:FindFirstChild("title")
                if title and title:IsA("TextLabel") and title.Text == UI_TITLE then
                    return gui
                end
                if main and header then fallback = gui end
                for _, descendant in ipairs(gui:GetDescendants()) do
                    if descendant:IsA("TextLabel") and descendant.Text == UI_TITLE then
                        return gui
                    end
                end
            end
        end
    end
    return fallback
end

local menuGui
local findDeadline = os.clock() + 3
repeat
    menuGui = findMenuGui()
    if not menuGui then task.wait() end
until menuGui or os.clock() >= findDeadline

local commandsTabButton
if not menuGui then
    warn(MENU_NAME .. ": não foi possível localizar a janela Kavo.")
    -- Não abandone o restante das funções/atalhos por causa de uma mudança
    -- cosmética da Kavo. O host mantém cleanup e comandos funcionais.
    menuGui = Instance.new("ScreenGui")
    menuGui.Name = "NothriloFallbackHost"
    menuGui.ResetOnSpawn = false
    menuGui.Parent = CoreGui
end

-- Arredonda todos os UICorner
local function applyRoundedStyle(root)
    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("UICorner") then object.CornerRadius = UDim.new(0, 12) end
    end
end
applyRoundedStyle(menuGui)
trackConnection(menuGui.DescendantAdded:Connect(function(object)
    if object:IsA("UICorner") then object.CornerRadius = UDim.new(0, 12) end
end))

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

configureKavoTextBox("Ir até Jogador",    "Nome ou começo do nome", nil)
configureKavoTextBox("Velocidade do Voo", "Digite a velocidade",    nil)
configureKavoTextBox("Nome do Alvo",      "Nome ou começo do nome", nil)
configureKavoTextBox("Força Normal",      "2500", 2500)
configureKavoTextBox("Força em Descidas", "800",  800)

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
addShortcutBadge("Voo do Veículo",      "V")
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

    trackConnection(UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then updatePos(input) end
    end))
end

-- Launcher (botão para reabrir quando minimizado)
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
    minimize.Text             = "—"
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
trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
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
end))

-- =============================================================================
-- Destruição limpa
-- =============================================================================
local running = true
destroyNothrilo = function()
    if destroyed then return end
    destroyed    = true
    running      = false
    killerActive = false
    killerSession = killerSession + 1
    infiniteJump = false

    fakeLagSession = fakeLagSession + 1
    restoreFakeLag()
    stopSpin(true)
    stopSpectate(true)
    stopFreecam()

    noclipEnabled = false
    restoreNoclip()
    invisEnabled = false
    setLocalInvisible(false)

    godEnabled = false
    if godRespawnConn then godRespawnConn:Disconnect(); godRespawnConn = nil end
    restoreGodHumanoid()

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
    activeCameraMode = nil
    restoreDefaultCamera()

    for index = #runtimeConnections, 1, -1 do
        local connection = runtimeConnections[index]
        pcall(function() connection:Disconnect() end)
        runtimeConnections[index] = nil
    end

    for index = #createdTools, 1, -1 do
        local tool = createdTools[index]
        if tool and tool.Parent then tool:Destroy() end
        createdTools[index] = nil
    end

    if flyMobileGui and flyMobileGui.Parent then flyMobileGui:Destroy() end
    if toastGui     and toastGui.Parent     then toastGui:Destroy()     end
    if launcherGui  and launcherGui.Parent  then launcherGui:Destroy()  end
    if menuGui      and menuGui.Parent      then menuGui:Destroy()      end
    if runtime      and runtime.Parent      then runtime:Destroy()      end
end

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

CommandsSection:NewButton("V  •  Voo do Veículo",       "Tecla V", function() flyToggleControl:UpdateToggle(nil, not flyEnabled) end)
CommandsSection:NewButton("L  •  ESP",                  "Tecla L", function() espToggleControl:UpdateToggle(nil, not espEnabled) end)
CommandsSection:NewButton("P  •  Pulo Infinito",        "Tecla P", function() infiniteJumpToggleControl:UpdateToggle(nil, not infiniteJump) end)
CommandsSection:NewButton("T  •  Teleporte por Clique", "Tecla T", giveClickTeleportTool)
CommandsSection:NewButton("B  •  Boost do Carrinho",    "Tecla B", function() boostToggleControl:UpdateToggle(nil, not boostActive) end)
CommandsSection:NewButton("NumPad 1/2/3  •  Checkpoints","Teclado numérico", function()
    notify("Checkpoints", "Use NumPad 1, 2 ou 3.")
end)
CommandsSection:NewButton("K  •  Minimizar / Abrir",    "Tecla K", function() setMenuVisible(false) end)
CommandsSection:NewButton("X  •  Fechar o Nothrilo",    "Tecla X", destroyNothrilo)

addShortcutBadge("V  •  Voo do Veículo",        "V")
addShortcutBadge("L  •  ESP",                   "L")
addShortcutBadge("P  •  Pulo Infinito",         "P")
addShortcutBadge("T  •  Teleporte por Clique",  "T")
addShortcutBadge("B  •  Boost do Carrinho",     "B")
addShortcutBadge("NumPad 1/2/3  •  Checkpoints","1/2/3")
addShortcutBadge("K  •  Minimizar / Abrir",     "K")
addShortcutBadge("X  •  Fechar o Nothrilo",     "X")

task.delay(0.3, function()
    if not menuGui or not menuGui.Parent then return end
    addShortcutBadge("V  •  Voo do Veículo",        "V")
    addShortcutBadge("L  •  ESP",                   "L")
    addShortcutBadge("P  •  Pulo Infinito",         "P")
    addShortcutBadge("T  •  Teleporte por Clique",  "T")
    addShortcutBadge("B  •  Boost do Carrinho",     "B")
    addShortcutBadge("NumPad 1/2/3  •  Checkpoints","1/2/3")
    addShortcutBadge("K  •  Minimizar / Abrir",     "K")
    addShortcutBadge("X  •  Fechar o Nothrilo",     "X")
end)

-- =============================================================================
-- ABA: Interface
-- =============================================================================
local GuiTab     = Window:NewTab("Interface")
local GuiSection = GuiTab:NewSection("Interface")

GuiSection:NewButton("Fechar Menu", "Fecha agora; a tecla X também funciona.", destroyNothrilo)
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

notify(MENU_NAME, "Feito por Cafezl  •  K minimiza e reabre o menu.")
