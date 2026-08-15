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
if not LocalPlayer then return end
local MENU_NAME    = "Nothrilo 🇧🇷"
local UI_TITLE     = MENU_NAME .. " | Feito por Cafezl"

-- Token compartilhado entre as skins. Uma execução nova invalida imediatamente
-- qualquer bootstrap antigo que ainda esteja esperando PlayerGui/GUI.
local suiteEnvironment = _G
if type(getgenv) == "function" then
    local ok, environment = pcall(getgenv)
    if ok and type(environment) == "table" then suiteEnvironment = environment end
end
local suiteGeneration = (tonumber(suiteEnvironment.__CafezlSuiteGeneration) or 0) + 1
do
    local storedGeneration = pcall(function()
        suiteEnvironment.__CafezlSuiteGeneration = suiteGeneration
    end)
    if not storedGeneration then
        suiteEnvironment = _G
        suiteGeneration = (tonumber(suiteEnvironment.__CafezlSuiteGeneration) or 0) + 1
        suiteEnvironment.__CafezlSuiteGeneration = suiteGeneration
    end
end

local function isCurrentSuiteGeneration()
    return suiteEnvironment.__CafezlSuiteGeneration == suiteGeneration
end

-- Alguns ambientes bloqueiam GUI direto em CoreGui e outros usam gethui().
-- Escolher o pai aqui evita o menu morrer antes mesmo de aparecer.
local CoreGui = (function()
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

    return LocalPlayer:FindFirstChildOfClass("PlayerGui")
        or LocalPlayer:FindFirstChild("PlayerGui")
end)()
if not isCurrentSuiteGeneration() then return end
if not CoreGui then
    warn(MENU_NAME .. ": PlayerGui/CoreGui ainda não está disponível.")
    return
end

-- A UI clássica local usa o pai escolhido acima. Os outros roots entram apenas
-- na descoberta/limpeza de versões antigas que ainda possam estar abertas.
local guiRoots = {}
do
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
end

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

do
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
        for _, guiRoot in ipairs(guiRoots) do
            local earlyGate = guiRoot:FindFirstChild("NothriloKeyGate")
            if earlyGate then pcall(function() earlyGate:Destroy() end) end
        end
        for index = #runtimeConnections, 1, -1 do
            local connection = runtimeConnections[index]
            pcall(function() connection:Disconnect() end)
            runtimeConnections[index] = nil
        end
        if runtime and runtime.Parent then runtime:Destroy() end
    end))
end

-- Remove somente GUIs antigas do próprio Nothrilo.
for _, guiRoot in ipairs(guiRoots) do
    for _, gui in ipairs(guiRoot:GetChildren()) do
        if gui:IsA("ScreenGui") then
            if gui.Name == "NothriloLauncher"
                or gui.Name == "NothriloNotifications"
                or gui.Name == "NothriloLoading"
                or gui.Name == "NothriloMobileFly"
                or gui.Name == "NothriloKeyGate"
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
-- Key grátis — todos os provedores liberam o menu inteiro por 24 horas
-- =============================================================================
-- A URL real é colocada na publicação final. O override facilita testar outra
-- implantação sem editar o arquivo:
-- Opcional: use getgenv().NothriloKeyServerUrl para apontar uma build de teste.
do
local HttpService = game:GetService("HttpService")
local keyGateGui
local function runFreeKeyGate()
local KEY_SERVER_PLACEHOLDER = "https://nothrilo-key.urielcafe01.workers.dev"
local keyServerUrl = tostring(suiteEnvironment.NothriloKeyServerUrl or KEY_SERVER_PLACEHOLDER)
    :match("^%s*(.-)%s*$")
    :gsub("/+$", "")
local keyServerReady = keyServerUrl:match("^https://") ~= nil
    and not keyServerUrl:find("__NOTHRILO_", 1, true)

local KEY_CACHE_PATH = "Nothrilo/key-cache-v1.json"
local KEY_CACHE_FOLDER = "Nothrilo"
local KEY_CACHE_MEMORY = "__NothriloFreeKeyCacheV1"
local KEY_MAX_TTL = 24 * 60 * 60

local function environmentFunction(name)
    local value
    pcall(function() value = rawget(suiteEnvironment, name) end)
    if type(value) == "function" then return value end
    pcall(function() value = rawget(_G, name) end)
    if type(value) == "function" then return value end
    return nil
end

local function nestedEnvironmentFunction(containerName, methodName)
    local container
    pcall(function() container = rawget(suiteEnvironment, containerName) end)
    if type(container) ~= "table" then
        pcall(function() container = rawget(_G, containerName) end)
    end
    local callback = type(container) == "table" and rawget(container, methodName) or nil
    return type(callback) == "function" and callback or nil
end

local function getRequestFunction()
    return environmentFunction("request")
        or environmentFunction("http_request")
        or nestedEnvironmentFunction("syn", "request")
        or nestedEnvironmentFunction("fluxus", "request")
        or nestedEnvironmentFunction("http", "request")
end

local function postKeyServer(payload)
    if not keyServerReady then
        return false, 0, nil, "server_not_configured"
    end

    local encodedOk, body = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    if not encodedOk then return false, 0, nil, "invalid_request" end

    local options = {
        Url = keyServerUrl .. "/v1/nothrilo/key/verify",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json",
        },
        Body = body,
    }

    local requestFunction = getRequestFunction()
    local ok, response
    if requestFunction then
        ok, response = pcall(requestFunction, options)
    else
        ok, response = pcall(function()
            return HttpService:RequestAsync(options)
        end)
    end
    if not ok then return false, 0, nil, "network_error" end

    local statusCode = 0
    local responseBody
    if type(response) == "table" then
        statusCode = tonumber(response.StatusCode or response.Status or response.status_code) or 0
        responseBody = response.Body or response.body
        if statusCode == 0 and response.Success == true then statusCode = 200 end
    elseif type(response) == "string" then
        statusCode = 200
        responseBody = response
    end
    if type(responseBody) ~= "string" or responseBody == "" then
        return false, statusCode, nil, "invalid_response"
    end

    local decodedOk, decoded = pcall(function()
        return HttpService:JSONDecode(responseBody)
    end)
    if not decodedOk or type(decoded) ~= "table" then
        return false, statusCode, nil, "invalid_response"
    end
    return statusCode >= 200 and statusCode < 300, statusCode, decoded, decoded.error
end

local function validLease(value)
    return type(value) == "string"
        and #value == 71
        and value:match("^NLEASE%-%x+$") ~= nil
end

local function clearKeyCache()
    pcall(function() suiteEnvironment[KEY_CACHE_MEMORY] = nil end)
    local deleteFile = environmentFunction("delfile")
    if deleteFile then pcall(deleteFile, KEY_CACHE_PATH) end
end

local function decodeCache(raw)
    if type(raw) == "table" then return raw end
    if type(raw) ~= "string" or raw == "" then return nil end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    return ok and type(decoded) == "table" and decoded or nil
end

local function validateCachedRecord(record)
    if type(record) ~= "table" then return nil end
    local now = os.time()
    local savedAt = tonumber(record.savedAt)
    local expiresAt = tonumber(record.expiresAt)
    if record.version ~= 1
        or record.product ~= "nothrilo"
        or tostring(record.userId or "") ~= tostring(LocalPlayer.UserId)
        or not validLease(record.lease)
        or not savedAt
        or not expiresAt
        or savedAt > now + 300
        or expiresAt <= now + 5
        or expiresAt - savedAt > KEY_MAX_TTL + 60
    then
        return nil
    end
    return record
end

local function readKeyCache()
    local isFile = environmentFunction("isfile")
    local readFile = environmentFunction("readfile")
    if readFile then
        local exists = true
        if isFile then
            local existsOk, result = pcall(isFile, KEY_CACHE_PATH)
            exists = existsOk and result == true
        end
        if exists then
            local ok, raw = pcall(readFile, KEY_CACHE_PATH)
            if ok then
                local record = validateCachedRecord(decodeCache(raw))
                if record then return record end
            end
        end
    end

    local memory
    pcall(function() memory = suiteEnvironment[KEY_CACHE_MEMORY] end)
    return validateCachedRecord(decodeCache(memory))
end

local function saveKeyCache(lease, ttlSeconds)
    if not validLease(lease) then return end
    local ttl = math.floor(math.clamp(tonumber(ttlSeconds) or 0, 1, KEY_MAX_TTL))
    if ttl <= 5 then return end
    local now = os.time()
    local record = {
        version = 1,
        product = "nothrilo",
        userId = tostring(LocalPlayer.UserId),
        lease = lease,
        savedAt = now,
        expiresAt = now + ttl,
    }
    pcall(function() suiteEnvironment[KEY_CACHE_MEMORY] = record end)

    local writeFile = environmentFunction("writefile")
    if not writeFile then return end
    local encodedOk, encoded = pcall(function() return HttpService:JSONEncode(record) end)
    if not encodedOk then return end
    local makeFolder = environmentFunction("makefolder")
    if makeFolder then pcall(makeFolder, KEY_CACHE_FOLDER) end
    pcall(writeFile, KEY_CACHE_PATH, encoded)
end

    local gateFinished = false
    local gateAuthorized = false
    local gateConnections = {}
    local requestSerial = 0
    local gateSession = {}

    local function gateAlive()
        return not destroyed
            and isCurrentSuiteGeneration()
            and keyGateGui
            and keyGateGui.Parent ~= nil
            and gateSession ~= nil
    end

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(gateConnections, connection)
        return connection
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "NothriloKeyGate"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 10100
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = CoreGui
    keyGateGui = gui

    local shade = Instance.new("Frame")
    shade.Name = "Shade"
    shade.Size = UDim2.fromScale(1, 1)
    shade.BackgroundColor3 = Color3.fromRGB(3, 3, 5)
    shade.BackgroundTransparency = 0.06
    shade.BorderSizePixel = 0
    shade.Parent = gui

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.fromScale(0.5, 0.5)
    card.BackgroundColor3 = Theme.Background
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = shade
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 22)
    cardCorner.Parent = card
    local cardStroke = Instance.new("UIStroke")
    cardStroke.Thickness = 2
    cardStroke.Color = Theme.SchemeColor
    cardStroke.Parent = card

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 62)
    header.BackgroundColor3 = Theme.Header
    header.BorderSizePixel = 0
    header.Parent = card

    local brandDot = Instance.new("Frame")
    brandDot.AnchorPoint = Vector2.new(0, 0.5)
    brandDot.Position = UDim2.new(0, 18, 0.5, 0)
    brandDot.Size = UDim2.fromOffset(12, 12)
    brandDot.BackgroundColor3 = Theme.SchemeColor
    brandDot.BorderSizePixel = 0
    brandDot.Parent = header
    Instance.new("UICorner", brandDot).CornerRadius = UDim.new(1, 0)

    local title = Instance.new("TextLabel")
    title.Position = UDim2.new(0, 40, 0, 10)
    title.Size = UDim2.new(1, -88, 0, 23)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "Nothrilo • Key grátis"
    title.TextColor3 = Theme.TextColor
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local headerSub = Instance.new("TextLabel")
    headerSub.Position = UDim2.new(0, 40, 0, 33)
    headerSub.Size = UDim2.new(1, -88, 0, 17)
    headerSub.BackgroundTransparency = 1
    headerSub.Font = Enum.Font.Gotham
    headerSub.Text = "1 anúncio • menu completo por 24 horas"
    headerSub.TextColor3 = Color3.fromRGB(170, 170, 181)
    headerSub.TextSize = 11
    headerSub.TextXAlignment = Enum.TextXAlignment.Left
    headerSub.Parent = header

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.Position = UDim2.new(1, -10, 0.5, 0)
    close.Size = UDim2.fromOffset(42, 42)
    close.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    close.BorderSizePixel = 0
    close.AutoButtonColor = true
    close.Font = Enum.Font.GothamBold
    close.Text = "×"
    close.TextColor3 = Theme.TextColor
    close.TextSize = 23
    close.Parent = header
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 13)

    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(0, 62)
    content.Size = UDim2.new(1, 0, 1, -62)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = Theme.SchemeColor
    content.ScrollingDirection = Enum.ScrollingDirection.Y
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new()
    content.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 18)
    padding.PaddingRight = UDim.new(0, 18)
    padding.PaddingTop = UDim.new(0, 16)
    padding.PaddingBottom = UDim.new(0, 18)
    padding.Parent = content

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 9)
    layout.Parent = content

    local function label(text, height, font, size, color)
        local object = Instance.new("TextLabel")
        object.Size = UDim2.new(1, 0, 0, height)
        object.BackgroundTransparency = 1
        object.Font = font or Enum.Font.Gotham
        object.Text = text
        object.TextColor3 = color or Theme.TextColor
        object.TextSize = size or 13
        object.TextWrapped = true
        object.TextXAlignment = Enum.TextXAlignment.Left
        object.TextYAlignment = Enum.TextYAlignment.Center
        object.Parent = content
        return object
    end

    local intro = label(
        "Escolha uma opção, conclua as etapas no navegador e cole a key aqui. Work.ink, LootLabs e Linkvertise liberam exatamente as mesmas funções.",
        58,
        Enum.Font.Gotham,
        13,
        Color3.fromRGB(210, 210, 220)
    )
    intro.LayoutOrder = 1

    local providerTitle = label("ESCOLHA ONDE PEGAR A KEY", 18, Enum.Font.GothamBold, 11, Color3.fromRGB(160, 160, 174))
    providerTitle.LayoutOrder = 2

    local providerRow = Instance.new("Frame")
    providerRow.Size = UDim2.new(1, 0, 0, 50)
    providerRow.BackgroundTransparency = 1
    providerRow.LayoutOrder = 3
    providerRow.Parent = content
    local providerLayout = Instance.new("UIListLayout")
    providerLayout.FillDirection = Enum.FillDirection.Horizontal
    providerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    providerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    providerLayout.Padding = UDim.new(0, 8)
    providerLayout.Parent = providerRow

    local linkBox = Instance.new("TextBox")
    linkBox.Name = "KeyLink"
    linkBox.Size = UDim2.new(1, 0, 0, 42)
    linkBox.BackgroundColor3 = Theme.ElementColor
    linkBox.BorderSizePixel = 0
    linkBox.ClearTextOnFocus = false
    linkBox.Font = Enum.Font.Code
    linkBox.PlaceholderText = "O link escolhido aparece aqui"
    linkBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 133)
    linkBox.Text = ""
    linkBox.TextColor3 = Color3.fromRGB(220, 220, 230)
    linkBox.TextSize = 11
    linkBox.TextTruncate = Enum.TextTruncate.AtEnd
    linkBox.TextXAlignment = Enum.TextXAlignment.Left
    linkBox.LayoutOrder = 4
    linkBox.Parent = content
    Instance.new("UICorner", linkBox).CornerRadius = UDim.new(0, 11)
    local linkPadding = Instance.new("UIPadding")
    linkPadding.PaddingLeft = UDim.new(0, 12)
    linkPadding.PaddingRight = UDim.new(0, 12)
    linkPadding.Parent = linkBox

    local keyBox = Instance.new("TextBox")
    keyBox.Name = "KeyInput"
    keyBox.Size = UDim2.new(1, 0, 0, 48)
    keyBox.BackgroundColor3 = Theme.ElementColor
    keyBox.BorderSizePixel = 0
    keyBox.ClearTextOnFocus = false
    keyBox.Font = Enum.Font.Code
    keyBox.PlaceholderText = "Cole sua key: NOTH-XXXX-XXXX-XXXX-XXXX-XXXX"
    keyBox.PlaceholderColor3 = Color3.fromRGB(126, 126, 140)
    keyBox.Text = ""
    keyBox.TextColor3 = Theme.TextColor
    keyBox.TextSize = 13
    keyBox.TextXAlignment = Enum.TextXAlignment.Left
    keyBox.LayoutOrder = 5
    keyBox.Parent = content
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 12)
    local keyPadding = Instance.new("UIPadding")
    keyPadding.PaddingLeft = UDim.new(0, 14)
    keyPadding.PaddingRight = UDim.new(0, 14)
    keyPadding.Parent = keyBox
    local keyStroke = Instance.new("UIStroke")
    keyStroke.Color = Color3.fromRGB(50, 50, 62)
    keyStroke.Thickness = 1
    keyStroke.Parent = keyBox

    local verifyButton = Instance.new("TextButton")
    verifyButton.Name = "Verify"
    verifyButton.Size = UDim2.new(1, 0, 0, 48)
    verifyButton.BackgroundColor3 = Theme.SchemeColor
    verifyButton.BorderSizePixel = 0
    verifyButton.AutoButtonColor = true
    verifyButton.Font = Enum.Font.GothamBold
    verifyButton.Text = "VALIDAR E ABRIR O NOTHRILO"
    verifyButton.TextColor3 = Color3.fromRGB(8, 8, 10)
    verifyButton.TextSize = 13
    verifyButton.LayoutOrder = 6
    verifyButton.Parent = content
    Instance.new("UICorner", verifyButton).CornerRadius = UDim.new(0, 13)

    local statusPanel = Instance.new("Frame")
    statusPanel.Size = UDim2.new(1, 0, 0, 56)
    statusPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    statusPanel.BorderSizePixel = 0
    statusPanel.LayoutOrder = 7
    statusPanel.Parent = content
    Instance.new("UICorner", statusPanel).CornerRadius = UDim.new(0, 12)

    local statusDot = Instance.new("Frame")
    statusDot.AnchorPoint = Vector2.new(0, 0.5)
    statusDot.Position = UDim2.new(0, 13, 0.5, 0)
    statusDot.Size = UDim2.fromOffset(9, 9)
    statusDot.BackgroundColor3 = Theme.SchemeColor
    statusDot.BorderSizePixel = 0
    statusDot.Parent = statusPanel
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    local statusText = Instance.new("TextLabel")
    statusText.Position = UDim2.new(0, 32, 0, 6)
    statusText.Size = UDim2.new(1, -44, 1, -12)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.Gotham
    statusText.Text = keyServerReady
        and "Escolha uma opção para gerar sua key grátis."
        or "O servidor de keys ainda não foi conectado nesta build."
    statusText.TextColor3 = Color3.fromRGB(205, 205, 216)
    statusText.TextSize = 12
    statusText.TextWrapped = true
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Center
    statusText.Parent = statusPanel

    local privacy = label(
        "🔐 Todas as funções são grátis após a key. Nenhuma senha é pedida.",
        36,
        Enum.Font.Gotham,
        11,
        Color3.fromRGB(145, 145, 158)
    )
    privacy.LayoutOrder = 8

    local providerStrokes = {}
    local providers = {
        { id = "workink", text = "Work.ink" },
        { id = "lootlabs", text = "LootLabs" },
        { id = "linkvertise", text = "Linkvertise" },
    }

    local function setStatus(message, state)
        statusText.Text = message
        if state == "good" then
            statusText.TextColor3 = Color3.fromRGB(116, 255, 158)
        elseif state == "bad" then
            statusText.TextColor3 = Color3.fromRGB(255, 116, 148)
        else
            statusText.TextColor3 = Color3.fromRGB(205, 205, 216)
        end
    end

    local function copyText(value)
        for _, name in ipairs({ "setclipboard", "toclipboard" }) do
            local callback = environmentFunction(name)
            if callback then
                local ok = pcall(callback, value)
                if ok then return true end
            end
        end
        return false
    end

    for _, provider in ipairs(providers) do
        local button = Instance.new("TextButton")
        button.Name = provider.id
        button.Size = UDim2.new(1 / 3, -6, 1, 0)
        button.BackgroundColor3 = Color3.fromRGB(24, 24, 31)
        button.BorderSizePixel = 0
        button.AutoButtonColor = true
        button.Font = Enum.Font.GothamBold
        button.Text = provider.text
        button.TextColor3 = Theme.TextColor
        button.TextSize = provider.id == "linkvertise" and 11 or 12
        button.Parent = providerRow
        Instance.new("UICorner", button).CornerRadius = UDim.new(0, 12)
        local stroke = Instance.new("UIStroke")
        stroke.Color = Theme.SchemeColor
        stroke.Transparency = 0.18
        stroke.Thickness = 1
        stroke.Parent = button
        table.insert(providerStrokes, stroke)

        connect(button.Activated, function()
            if not gateAlive() then return end
            if not keyServerReady then
                setStatus("O servidor ainda não foi publicado. Esta build é apenas de preparação.", "bad")
                return
            end
            local url = keyServerUrl
                .. "/v1/nothrilo/key/start?provider=" .. HttpService:UrlEncode(provider.id)
                .. "&userId=" .. HttpService:UrlEncode(tostring(LocalPlayer.UserId))
            linkBox.Text = url
            if copyText(url) then
                setStatus("Link do " .. provider.text .. " copiado. Cole no navegador, conclua e volte com a key.", "good")
            else
                setStatus("Copie o link do campo acima, abra no navegador, conclua e volte com a key.", nil)
                pcall(function()
                    linkBox:CaptureFocus()
                    linkBox.CursorPosition = #linkBox.Text + 1
                    linkBox.SelectionStart = 1
                end)
            end
        end)
    end

    local function setBusy(busy)
        verifyButton.Active = not busy
        verifyButton.AutoButtonColor = not busy
        verifyButton.Text = busy and "VERIFICANDO..." or "VALIDAR E ABRIR O NOTHRILO"
        verifyButton.BackgroundTransparency = busy and 0.35 or 0
        pcall(function() keyBox.TextEditable = not busy end)
    end

    local function friendlyError(code, statusCode)
        if code == "server_not_configured" then return "O servidor de keys ainda não foi conectado nesta build." end
        if code == "network_error" then return "Não consegui falar com o servidor. Confira a internet e tente novamente." end
        if code == "invalid_key" or code == "invalid_lease" or statusCode == 401 or statusCode == 403 then
            return "Key inválida, expirada ou criada para outro usuário."
        end
        if statusCode == 429 then return "Muitas tentativas. Aguarde um pouco e tente novamente." end
        return "O servidor respondeu de um jeito inesperado. Tente novamente em instantes."
    end

    local function beginVerification(kind, credential, automatic)
        if not gateAlive() then return end
        credential = tostring(credential or ""):match("^%s*(.-)%s*$")
        if kind == "key" then credential = credential:upper() end
        if (kind == "key" and not credential:match("^NOTH%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w$"))
            or (kind == "lease" and not validLease(credential))
        then
            if automatic then clearKeyCache() else setStatus("Cole uma key Nothrilo completa antes de validar.", "bad") end
            return
        end

        requestSerial += 1
        local thisRequest = requestSerial
        setBusy(true)
        setStatus(automatic and "Verificando seu acesso salvo..." or "Validando sua key com segurança...", nil)

        task.delay(20, function()
            if gateAlive() and requestSerial == thisRequest and not gateFinished then
                requestSerial += 1
                setBusy(false)
                setStatus("A verificação demorou demais. Tente novamente.", "bad")
            end
        end)

        task.spawn(function()
            local nonce = tostring(os.clock())
            pcall(function() nonce = HttpService:GenerateGUID(false) end)
            local payload = {
                product = "nothrilo",
                clientVersion = "free-key-v1",
                userId = tostring(LocalPlayer.UserId),
                placeId = tostring(game.PlaceId),
                nonce = nonce,
            }
            payload[kind] = credential
            local ok, statusCode, data, errorCode = postKeyServer(payload)
            if not gateAlive() or requestSerial ~= thisRequest or gateFinished then return end

            if ok
                and type(data) == "table"
                and data.ok == true
                and validLease(data.lease)
                and tonumber(data.ttlSeconds)
                and tonumber(data.ttlSeconds) > 5
            then
                saveKeyCache(data.lease, data.ttlSeconds)
                setStatus("Acesso liberado! Abrindo o Nothrilo completo...", "good")
                task.wait(0.45)
                if gateAlive() and requestSerial == thisRequest then
                    gateAuthorized = true
                    gateFinished = true
                end
                return
            end

            if automatic then clearKeyCache() end
            setBusy(false)
            setStatus(friendlyError(errorCode or (data and data.error), statusCode), "bad")
        end)
    end

    connect(verifyButton.Activated, function()
        beginVerification("key", keyBox.Text, false)
    end)
    connect(keyBox.FocusLost, function(enterPressed)
        if enterPressed then beginVerification("key", keyBox.Text, false) end
    end)
    connect(close.Activated, function()
        requestSerial += 1
        gateFinished = true
        gateAuthorized = false
    end)

    local lastViewport = Vector2.new()
    local function resizeGate()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        if viewport == lastViewport then return end
        lastViewport = viewport
        local width = math.max(284, math.min(530, viewport.X - 24))
        local height = math.max(350, math.min(510, viewport.Y - 24))
        card.Size = UDim2.fromOffset(width, height)
        title.TextSize = width < 360 and 15 or 17
        headerSub.TextSize = width < 360 and 10 or 11
        intro.TextSize = width < 360 and 12 or 13
    end
    resizeGate()

    task.spawn(function()
        while gateAlive() and not gateFinished do
            resizeGate()
            local color = Color3.fromHSV((os.clock() * 0.075) % 1, 0.86, 1)
            cardStroke.Color = color
            brandDot.BackgroundColor3 = color
            verifyButton.BackgroundColor3 = color
            content.ScrollBarImageColor3 = color
            statusDot.BackgroundColor3 = color
            for _, stroke in ipairs(providerStrokes) do stroke.Color = color end
            task.wait(0.08)
        end
    end)

    local cached = readKeyCache()
    if cached then
        beginVerification("lease", cached.lease, true)
    elseif keyServerReady then
        setStatus("Escolha uma opção para gerar sua key grátis.", nil)
    end

    repeat task.wait(0.05) until gateFinished or not gateAlive()
    requestSerial += 1
    gateSession = nil
    for index = #gateConnections, 1, -1 do
        pcall(function() gateConnections[index]:Disconnect() end)
        gateConnections[index] = nil
    end
    if keyGateGui and keyGateGui.Parent then pcall(function() keyGateGui:Destroy() end) end
    keyGateGui = nil
    return gateAuthorized and not destroyed and isCurrentSuiteGeneration()
end

if not runFreeKeyGate() then
    destroyed = true
    for index = #runtimeConnections, 1, -1 do
        pcall(function() runtimeConnections[index]:Disconnect() end)
        runtimeConnections[index] = nil
    end
    if runtime and runtime.Parent then runtime:Destroy() end
    return
end
end

-- =============================================================================
-- Tela de carregamento
-- =============================================================================
-- O vídeo é best-effort: quando o executor suporta arquivo/custom asset ele é
-- baixado e tocado; caso contrário o mesmo espaço recebe gatos animados. O
-- download nunca segura o prazo do loader nem impede o menu de abrir.
local startup = {
    seconds = 5,
    beganAt = os.clock(),
}
startup.gui, startup.status, startup.progress = (function()
    local gui = Instance.new("ScreenGui")
    gui.Name            = "NothriloLoading"
    gui.ResetOnSpawn    = false
    gui.IgnoreGuiInset  = true
    gui.DisplayOrder    = 10050
    gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    gui.Parent          = CoreGui

    local shade = Instance.new("Frame")
    shade.Name                   = "Shade"
    shade.Size                   = UDim2.fromScale(1, 1)
    shade.BackgroundColor3       = Color3.fromRGB(3, 3, 5)
    shade.BackgroundTransparency = 0.08
    shade.BorderSizePixel        = 0
    shade.Parent                 = gui

    local shadow = Instance.new("Frame")
    shadow.Name                   = "Shadow"
    shadow.AnchorPoint            = Vector2.new(0.5, 0.5)
    shadow.Position               = UDim2.new(0.5, 0, 0.5, 6)
    shadow.Size                   = UDim2.fromOffset(344, 500)
    shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.38
    shadow.BorderSizePixel        = 0
    shadow.Parent                 = shade
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 24)

    local card = Instance.new("Frame")
    card.Name            = "Card"
    card.AnchorPoint     = Vector2.new(0.5, 0.5)
    card.Position        = UDim2.fromScale(0.5, 0.5)
    card.Size            = UDim2.fromOffset(344, 500)
    card.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent          = shade

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color     = Theme.SchemeColor
    stroke.Parent    = card

    stroke.Transparency = 0.06

    local mediaPanel = Instance.new("Frame")
    mediaPanel.Name             = "MediaPanel"
    mediaPanel.Position         = UDim2.fromOffset(14, 14)
    mediaPanel.Size             = UDim2.new(1, -28, 1, -142)
    mediaPanel.BackgroundColor3 = Color3.fromRGB(17, 17, 23)
    mediaPanel.BorderSizePixel  = 0
    mediaPanel.ClipsDescendants = true
    mediaPanel.Parent           = card
    Instance.new("UICorner", mediaPanel).CornerRadius = UDim.new(0, 18)

    local mediaStroke = Instance.new("UIStroke")
    mediaStroke.Thickness    = 1
    mediaStroke.Transparency = 0.55
    mediaStroke.Color        = Theme.SchemeColor
    mediaStroke.Parent       = mediaPanel

    local videoFrame = Instance.new("VideoFrame")
    videoFrame.Name = "CatVideo"
    videoFrame.Size = UDim2.fromScale(1, 1)
    videoFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
    videoFrame.BorderSizePixel = 0
    videoFrame.Looped = true
    videoFrame.Volume = 0
    videoFrame.Visible = false
    videoFrame.ZIndex = 1
    videoFrame.Parent = mediaPanel

    local fallback = Instance.new("Frame")
    fallback.Name = "EmojiFallback"
    fallback.Size = UDim2.fromScale(1, 1)
    fallback.BackgroundColor3 = Color3.fromRGB(17, 17, 23)
    fallback.BorderSizePixel = 0
    fallback.ZIndex = 2
    fallback.Parent = mediaPanel

    local fallbackTitle = Instance.new("TextLabel")
    fallbackTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    fallbackTitle.Position = UDim2.fromScale(0.5, 0.42)
    fallbackTitle.Size = UDim2.new(1, -30, 0, 44)
    fallbackTitle.BackgroundTransparency = 1
    fallbackTitle.Font = Enum.Font.GothamBold
    fallbackTitle.Text = "preparando a bagunça..."
    fallbackTitle.TextColor3 = Color3.fromRGB(244, 244, 248)
    fallbackTitle.TextSize = 17
    fallbackTitle.TextWrapped = true
    fallbackTitle.ZIndex = 3
    fallbackTitle.Parent = fallback

    local brandDot = Instance.new("Frame")
    brandDot.Name             = "BrandDot"
    brandDot.Position         = UDim2.new(0, 18, 1, -110)
    brandDot.Size             = UDim2.fromOffset(18, 18)
    brandDot.BackgroundColor3 = Theme.SchemeColor
    brandDot.BorderSizePixel  = 0
    brandDot.Parent           = card
    Instance.new("UICorner", brandDot).CornerRadius = UDim.new(1, 0)

    local titleL = Instance.new("TextLabel")
    titleL.BackgroundTransparency = 1
    titleL.Position  = UDim2.new(0, 46, 1, -122)
    titleL.Size      = UDim2.new(1, -64, 0, 26)
    titleL.Font      = Enum.Font.GothamBold
    titleL.Text      = MENU_NAME
    titleL.TextColor3 = Color3.fromRGB(248, 248, 250)
    titleL.TextSize  = 18
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.Parent    = card

    local subtitleL = Instance.new("TextLabel")
    subtitleL.BackgroundTransparency = 1
    subtitleL.Position  = UDim2.new(0, 18, 1, -90)
    subtitleL.Size      = UDim2.new(1, -36, 0, 17)
    subtitleL.Font      = Enum.Font.Gotham
    subtitleL.Text      = "Feito por Cafezl  •  preparando tudo"
    subtitleL.TextColor3 = Color3.fromRGB(205, 205, 214)
    subtitleL.TextSize  = 12
    subtitleL.TextXAlignment = Enum.TextXAlignment.Left
    subtitleL.Parent    = card

    local emojiLabels = {}
    local emojis = { "🐱", "😸", "✨", "☕", "⚡", "🎮" }
    for index, emoji in ipairs(emojis) do
        local label = Instance.new("TextLabel")
        label.Name = "Emoji" .. index
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        local column = (index - 1) % 3
        local row = math.floor((index - 1) / 3)
        label.Position = UDim2.new(0.23 + column * 0.27, 0, 0.58 + row * 0.15, 0)
        label.Size = UDim2.fromOffset(52, 52)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = emoji
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 30
        label.ZIndex = 3
        label.Parent = fallback
        table.insert(emojiLabels, label)
    end

    local statusDot = Instance.new("Frame")
    statusDot.Name             = "StatusDot"
    statusDot.AnchorPoint      = Vector2.new(0.5, 0.5)
    statusDot.Position         = UDim2.new(0, 22, 1, -52)
    statusDot.Size             = UDim2.fromOffset(8, 8)
    statusDot.BackgroundColor3 = Theme.SchemeColor
    statusDot.BorderSizePixel  = 0
    statusDot.Parent           = card
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position  = UDim2.new(0, 34, 1, -63)
    status.Size      = UDim2.new(1, -100, 0, 22)
    status.Font      = Enum.Font.Gotham
    status.Text      = "Preparando interface..."
    status.TextColor3 = Theme.SchemeColor
    status.TextSize  = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent    = card

    local percent = Instance.new("TextLabel")
    percent.Name = "Percent"
    percent.BackgroundTransparency = 1
    percent.Position = UDim2.new(1, -68, 1, -63)
    percent.Size = UDim2.fromOffset(50, 22)
    percent.Font = Enum.Font.GothamSemibold
    percent.Text = "0%"
    percent.TextColor3 = Theme.SchemeColor
    percent.TextSize = 12
    percent.TextXAlignment = Enum.TextXAlignment.Right
    percent.Parent = card

    local progressTrack = Instance.new("Frame")
    progressTrack.Name = "ProgressTrack"
    progressTrack.Position = UDim2.new(0, 18, 1, -24)
    progressTrack.Size = UDim2.new(1, -36, 0, 8)
    progressTrack.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
    progressTrack.BorderSizePixel = 0
    progressTrack.Parent = card
    Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(1, 0)

    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.Size = UDim2.fromScale(0, 1)
    progress.BackgroundColor3 = Theme.SchemeColor
    progress.BorderSizePixel = 0
    progress.Parent = progressTrack
    Instance.new("UICorner", progress).CornerRadius = UDim.new(1, 0)

    local LOADER_VIDEO_PATH = "Nothrilo/loader-cat-v1.mp4"
    local LOADER_VIDEO_URL = tostring(
        suiteEnvironment.NothriloLoaderVideoUrl
        or "https://raw.githubusercontent.com/cafezl/cart-ride-nothing-around/main/assets/nothrilo-loader.mp4"
    )

    local function loaderFunction(name)
        local value
        pcall(function() value = rawget(suiteEnvironment, name) end)
        if type(value) == "function" then return value end
        pcall(function() value = rawget(_G, name) end)
        return type(value) == "function" and value or nil
    end

    local function nestedLoaderFunction(containerName, methodName)
        local container
        pcall(function() container = rawget(suiteEnvironment, containerName) end)
        if type(container) ~= "table" then
            pcall(function() container = rawget(_G, containerName) end)
        end
        local callback = type(container) == "table" and rawget(container, methodName) or nil
        return type(callback) == "function" and callback or nil
    end

    local function loaderAlive()
        return gui.Parent ~= nil
            and not destroyed
            and isCurrentSuiteGeneration()
            and os.clock() < startup.beganAt + startup.seconds
    end

    local function showLoadedVideo()
        if not loaderAlive() then return end
        local loadedOk, loaded = pcall(function() return videoFrame.IsLoaded end)
        if loadedOk and loaded then
            pcall(function()
                videoFrame.Visible = true
                videoFrame.TimePosition = 0
                videoFrame:Play()
                fallback.Visible = false
            end)
        end
    end
    videoFrame.Loaded:Connect(showLoadedVideo)

    local customAsset = loaderFunction("getcustomasset") or loaderFunction("getsynasset")
    local writeFile = loaderFunction("writefile")
    local readFile = loaderFunction("readfile")
    local isFile = loaderFunction("isfile")
    local makeFolder = loaderFunction("makefolder")
    local deleteFile = loaderFunction("delfile")
    local requestFunction = loaderFunction("request")
        or loaderFunction("http_request")
        or nestedLoaderFunction("syn", "request")
        or nestedLoaderFunction("fluxus", "request")
        or nestedLoaderFunction("http", "request")

    local function validMp4(body)
        return type(body) == "string"
            and #body >= 4096
            and #body <= 12 * 1024 * 1024
            and body:sub(5, 8) == "ftyp"
    end

    local function attachVideoFile()
        if not customAsset or not loaderAlive() then return false end
        local assetOk, asset = pcall(customAsset, LOADER_VIDEO_PATH)
        if not assetOk or type(asset) ~= "string" or asset == "" then return false end
        local setOk = pcall(function() videoFrame.Video = asset end)
        if setOk then task.defer(showLoadedVideo) end
        return setOk
    end

    local function downloadVideo()
        if requestFunction then
            local ok, response = pcall(requestFunction, {
                Url = LOADER_VIDEO_URL,
                Method = "GET",
            })
            if ok and type(response) == "table" then
                local statusCode = tonumber(response.StatusCode or response.Status or response.status_code) or 0
                local body = response.Body or response.body
                if statusCode >= 200 and statusCode < 300 then return body end
            elseif ok and type(response) == "string" then
                return response
            end
        end
        local ok, body = pcall(function() return game:HttpGet(LOADER_VIDEO_URL, true) end)
        return ok and body or nil
    end

    task.spawn(function()
        if not customAsset then return end
        local cached = false
        if isFile then
            local ok, exists = pcall(isFile, LOADER_VIDEO_PATH)
            cached = ok and exists == true
        end
        if cached and readFile then
            local ok, body = pcall(readFile, LOADER_VIDEO_PATH)
            if not ok or not validMp4(body) then
                cached = false
                if deleteFile then pcall(deleteFile, LOADER_VIDEO_PATH) end
            end
        end
        if cached and attachVideoFile() then return end
        if not writeFile or not LOADER_VIDEO_URL:match("^https://") then return end
        local body = downloadVideo()
        if not validMp4(body) then return end
        if makeFolder then pcall(makeFolder, "Nothrilo") end
        local wrote = pcall(writeFile, LOADER_VIDEO_PATH, body)
        if wrote and loaderAlive() then attachVideoFile() end
    end)

    local lastViewport = Vector2.new()
    local function resizeLoader()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
        if viewport == lastViewport then return end
        lastViewport = viewport
        local width = math.max(276, math.min(356, viewport.X - 24))
        local height = math.max(330, math.min(552, viewport.Y - 24))
        card.Size = UDim2.fromOffset(width, height)
        shadow.Size = UDim2.fromOffset(width, height)
    end
    resizeLoader()

    task.spawn(function()
        local generatedStatus = status.Text
        while gui.Parent do
            resizeLoader()
            local elapsed = os.clock() - startup.beganAt
            local alpha = math.clamp(elapsed / startup.seconds, 0, 1)
            progress.Size = UDim2.fromScale(alpha, 1)

            local rgb = Color3.fromHSV((elapsed * 0.20) % 1, 0.84, 1)
            progress.BackgroundColor3 = rgb
            stroke.Color = rgb
            mediaStroke.Color = rgb
            brandDot.BackgroundColor3 = rgb
            statusDot.BackgroundColor3 = rgb
            status.TextColor3 = rgb
            percent.TextColor3 = rgb
            percent.Text = ("%d%%"):format(math.floor(alpha * 100))

            local message
            if alpha < 0.24 then
                message = "Preparando interface..."
            elseif alpha < 0.50 then
                message = "Carregando funções..."
            elseif alpha < 0.76 then
                message = "Organizando atalhos..."
            elseif alpha < 0.98 then
                message = "Aplicando acabamento..."
            else
                message = "Tudo pronto!"
            end
            if status.Text == generatedStatus then
                generatedStatus = message
                status.Text = generatedStatus
            end

            for index, label in ipairs(emojiLabels) do
                local wave = elapsed * 5.2 + index * 0.78
                local column = (index - 1) % 3
                local row = math.floor((index - 1) / 3)
                label.Position = UDim2.new(0.23 + column * 0.27, 0, 0.58 + row * 0.15, math.floor(math.sin(wave) * 5))
                label.Rotation = math.sin(wave * 0.82) * 7
                label.TextSize = 30 + math.floor((math.sin(wave) + 1) * 1.5)
            end

            RunService.RenderStepped:Wait()
        end
    end)

    return gui, status, progress
end)()

-- =============================================================================
-- Classic UI local — API compatível com Kavo sem polling por controle
-- =============================================================================
-- A Kavo upstream abre um `while wait()` permanente para praticamente cada
-- aba, seção e elemento. Neste menu isso passava de 80 loops simultâneos e
-- continuava mesmo após destruir a ScreenGui. Esta implementação preserva a
-- API e a estrutura visual usadas abaixo, mas atualiza cores apenas por evento.
local ClassicUI = (function()
local ClassicUI = {
    gui = nil,
    theme = Theme,
    themeBindings = {},
}

local function classicCreate(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do object[property] = value end
    object.Parent = parent
    return object
end

local function classicCorner(parent, radius)
    return classicCreate("UICorner", { CornerRadius = UDim.new(0, radius or 4) }, parent)
end

local function classicBindTheme(object, property, themeKey)
    table.insert(ClassicUI.themeBindings, {
        object = object,
        property = property,
        themeKey = themeKey,
    })
    object[property] = ClassicUI.theme[themeKey]
    return object
end

local function classicInvoke(name, callback, ...)
    if not callback then return end
    local args = table.pack(...)
    local ok, err = xpcall(function()
        callback(table.unpack(args, 1, args.n))
    end, function(message)
        if debug and type(debug.traceback) == "function" then
            return debug.traceback(tostring(message), 2)
        end
        return tostring(message)
    end)
    if not ok then warn(("[%s/%s] %s"):format(MENU_NAME, name, tostring(err))) end
end

function ClassicUI:ChangeColor(themeKey, color)
    if not self.theme[themeKey] then return end
    self.theme[themeKey] = color
    for index = #self.themeBindings, 1, -1 do
        local binding = self.themeBindings[index]
        if not binding.object or not binding.object.Parent then
            table.remove(self.themeBindings, index)
        elseif binding.themeKey == themeKey then
            binding.object[binding.property] = color
        end
    end
end

function ClassicUI:ToggleUI()
    if self.gui and self.gui.Parent then self.gui.Enabled = not self.gui.Enabled end
end

function ClassicUI.CreateLib(title, suppliedTheme)
    ClassicUI.theme = suppliedTheme or Theme
    table.clear(ClassicUI.themeBindings)

    local gui = classicCreate("ScreenGui", {
        Name = "NothriloClassicUI",
        Enabled = false,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 10000,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, CoreGui)
    ClassicUI.gui = gui

    local main = classicCreate("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        -- Geometria da Kavo clássica usada no roteiro de referência.
        Size = UDim2.fromOffset(525, 318),
        BackgroundColor3 = ClassicUI.theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, gui)
    classicCorner(main, 18)

    local header = classicCreate("Frame", {
        Name = "MainHeader",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = ClassicUI.theme.Header,
        BorderSizePixel = 0,
    }, main)
    -- O header arredonda os dois cantos de cima. O preenchimento inferior
    -- mantém a junção com o conteúdo reta sem encobrir o contorno externo.
    classicCorner(header, 18)
    local headerSquareBottom = classicCreate("Frame", {
        Name = "SquareBottom",
        Position = UDim2.new(0, 0, 1, -18),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundColor3 = ClassicUI.theme.Header,
        BorderSizePixel = 0,
    }, header)
    classicBindTheme(headerSquareBottom, "BackgroundColor3", "Header")
    local titleLabel = classicCreate("TextLabel", {
        Name = "title",
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -46, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = title,
        TextColor3 = ClassicUI.theme.TextColor,
        TextSize = 16,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true,
    }, header)
    classicBindTheme(titleLabel, "TextColor3", "TextColor")
    local close = classicCreate("TextButton", {
        Name = "close",
        Position = UDim2.new(1, -34, 0, 0),
        Size = UDim2.fromOffset(34, 34),
        BackgroundTransparency = 1,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextColor3 = ClassicUI.theme.TextColor,
        TextSize = 20,
    }, header)
    close.Activated:Connect(function()
        if destroyNothrilo then destroyNothrilo() elseif gui.Parent then gui:Destroy() end
    end)

    local side = classicCreate("Frame", {
        Name = "MainSide",
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(0, 145, 1, -34),
        BackgroundColor3 = ClassicUI.theme.Header,
        BorderSizePixel = 0,
    }, main)
    -- Só o canto inferior esquerdo da lateral é externo. Os preenchimentos
    -- deixam os outros três cantos retos e preservam a união entre painéis.
    classicCorner(side, 18)
    local sideSquareTop = classicCreate("Frame", {
        Name = "SquareTop",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundColor3 = ClassicUI.theme.Header,
        BorderSizePixel = 0,
    }, side)
    classicBindTheme(sideSquareTop, "BackgroundColor3", "Header")
    local sideSquareRight = classicCreate("Frame", {
        Name = "SquareRight",
        Position = UDim2.new(1, -18, 0, 0),
        Size = UDim2.new(0, 18, 1, 0),
        BackgroundColor3 = ClassicUI.theme.Header,
        BorderSizePixel = 0,
    }, side)
    classicBindTheme(sideSquareRight, "BackgroundColor3", "Header")
    local tabFrames = classicCreate("ScrollingFrame", {
        Name = "tabFrames",
        Position = UDim2.fromOffset(6, 3),
        Size = UDim2.new(0, 133, 1, -6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, side)
    classicBindTheme(tabFrames, "ScrollBarImageColor3", "SchemeColor")
    classicCreate("UIListLayout", {
        Name = "tabListing",
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabFrames)

    local pages = classicCreate("Frame", {
        Name = "pages",
        Position = UDim2.fromOffset(153, 42),
        Size = UDim2.fromOffset(364, 268),
        BackgroundColor3 = ClassicUI.theme.Background,
        BorderSizePixel = 0,
    }, main)
    local pageFolder = classicCreate("Folder", { Name = "Pages" }, pages)

    -- A Kavo mostra a descrição em uma faixa inferior, não espremida embaixo
    -- do nome do controle. Um único tooltip atende todos os itens sem workers.
    local hintBar = classicCreate("TextLabel", {
        Name = "infoContainer",
        Position = UDim2.fromOffset(153, 268),
        Size = UDim2.fromOffset(364, 42),
        BackgroundColor3 = ClassicUI.theme.ElementColor,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamSemibold,
        Text = "",
        TextColor3 = ClassicUI.theme.TextColor,
        TextSize = 12,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = false,
        ZIndex = 60,
    }, main)
    classicCorner(hintBar, 12)
    classicCreate("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, hintBar)
    classicBindTheme(hintBar, "BackgroundColor3", "ElementColor")
    classicBindTheme(hintBar, "TextColor3", "TextColor")
    local hintStroke = classicCreate("UIStroke", { Thickness = 1, Transparency = 0.1 }, hintBar)
    classicBindTheme(hintStroke, "Color", "SchemeColor")
    local hintSession = 0
    local function showHint(label, description)
        if not description or description == "" then return end
        hintSession = hintSession + 1
        local session = hintSession
        hintBar.Text = tostring(label) .. "  •  " .. tostring(description)
        hintBar.Visible = true
        task.delay(4, function()
            if session == hintSession and hintBar.Parent then hintBar.Visible = false end
        end)
    end

    -- A referência usa 525x318 sem UIScale. Em telas menores só a geometria
    -- disponível é reduzida; as fontes continuam com o mesmo tamanho.
    local viewportConnection
    local responsiveCallbacks = {}
    local function updateResponsiveLayout()
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
        local width = math.clamp(viewport.X - 16, 300, 525)
        local height = math.clamp(viewport.Y - 16, 260, 318)
        local sideWidth = width < 420 and 96 or 145
        local contentX = sideWidth + 8
        local contentY = 42

        main.Size = UDim2.fromOffset(width, height)
        side.Position = UDim2.fromOffset(0, 34)
        side.Size = UDim2.new(0, sideWidth, 1, -34)
        tabFrames.Size = UDim2.new(1, -12, 1, -6)
        pages.Position = UDim2.fromOffset(contentX, contentY)
        pages.Size = UDim2.new(1, -(contentX + 8), 1, -(contentY + 8))
        hintBar.Position = UDim2.fromOffset(contentX, height - 50)
        hintBar.Size = UDim2.new(1, -(contentX + 8), 0, 42)
        local compact = width < 420
        for _, callback in ipairs(responsiveCallbacks) do
            callback(compact)
        end
    end
    local function bindViewportCamera()
        if viewportConnection then
            viewportConnection:Disconnect()
            viewportConnection = nil
        end
        local camera = workspace.CurrentCamera
        if camera then
            viewportConnection = trackConnection(
                camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveLayout)
            )
        end
        updateResponsiveLayout()
    end
    bindViewportCamera()
    trackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewportCamera))

    local window = { tabs = {}, gui = gui }
    local function showTab(selected)
        for _, tab in ipairs(window.tabs) do
            local active = tab == selected
            tab.page.Visible = active
            tab.button.BackgroundTransparency = active and 0 or 1
            tab.button.Font = active and Enum.Font.GothamSemibold or Enum.Font.GothamMedium
            tab.button.TextColor3 = active and Color3.fromRGB(7, 7, 9)
                or ClassicUI.theme.TextColor
            if active then tab.page.CanvasPosition = Vector2.zero end
        end
    end

    function window:NewTab(name)
        local tabButton = classicCreate("TextButton", {
            Name = name .. "TabButton",
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = ClassicUI.theme.TextColor,
            TextSize = 13,
        }, tabFrames)
        classicCorner(tabButton, 10)
        classicBindTheme(tabButton, "BackgroundColor3", "SchemeColor")
        classicBindTheme(tabButton, "TextColor3", "TextColor")

        local page = classicCreate("ScrollingFrame", {
            Name = "Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = ClassicUI.theme.Background,
            BorderSizePixel = 0,
            ScrollBarThickness = 5,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Visible = false,
        }, pageFolder)
        classicBindTheme(page, "ScrollBarImageColor3", "SchemeColor")
        classicCreate("UIPadding", {
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 50),
        }, page)
        classicCreate("UIListLayout", {
            Name = "pageListing",
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, page)

        local tab = { button = tabButton, page = page }
        table.insert(self.tabs, tab)
        tabButton.Activated:Connect(function() showTab(tab) end)
        if #self.tabs == 1 then showTab(tab) end

        function tab:NewSection(sectionName, hidden)
            local sectionFrame = classicCreate("Frame", {
                Name = "sectionFrame",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, page)
            classicCreate("UIListLayout", {
                Name = "sectionlistoknvm",
                Padding = UDim.new(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, sectionFrame)

            local sectionHead = classicCreate("Frame", {
                Name = "sectionHead",
                Size = UDim2.new(1, 0, 0, hidden and 0 or 33),
                Visible = not hidden,
                BackgroundColor3 = ClassicUI.theme.SchemeColor,
                BorderSizePixel = 0,
            }, sectionFrame)
            classicCorner(sectionHead, 12)
            classicBindTheme(sectionHead, "BackgroundColor3", "SchemeColor")
            local sectionNameLabel = classicCreate("TextLabel", {
                Name = "sectionName",
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Color3.fromRGB(7, 7, 9),
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, sectionHead)
            table.insert(responsiveCallbacks, function(compact)
                sectionNameLabel.TextSize = compact and 12 or 14
            end)

            local sectionInners = classicCreate("Frame", {
                Name = "sectionInners",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
            }, sectionFrame)
            classicCreate("UIListLayout", {
                Name = "sectionElListing",
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }, sectionInners)

            local api = {}
            local function makeElement(name, height, label, description, rightInset)
                local rowHeight = UserInputService.TouchEnabled and math.max(height, 44) or height
                local element = classicCreate("TextButton", {
                    Name = name,
                    Size = UDim2.new(1, 0, 0, rowHeight),
                    BackgroundColor3 = ClassicUI.theme.ElementColor,
                    BorderSizePixel = 0,
                    AutoButtonColor = false,
                    ClipsDescendants = true,
                    Text = "",
                }, sectionInners)
                classicCorner(element, 12)
                local elementStroke = classicCreate("UIStroke", {
                    Thickness = 1,
                    Transparency = 0.82,
                    Color = Color3.fromRGB(80, 80, 92),
                }, element)
                local accentIcon = classicCreate("TextLabel", {
                    Name = "touch",
                    Position = UDim2.new(0, 7, 0.5, -11),
                    Size = UDim2.fromOffset(22, 22),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "•",
                    TextColor3 = ClassicUI.theme.SchemeColor,
                    TextSize = 17,
                }, element)
                classicBindTheme(accentIcon, "TextColor3", "SchemeColor")
                local title = classicCreate("TextLabel", {
                    Name = "togName",
                    Position = UDim2.fromOffset(34, 0),
                    Size = UDim2.new(1, -(62 + (rightInset or 0)), 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = label,
                    TextColor3 = ClassicUI.theme.TextColor,
                    TextSize = 14,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, element)
                classicBindTheme(title, "TextColor3", "TextColor")
                table.insert(responsiveCallbacks, function(compact)
                    title.TextSize = compact and 13 or 14
                end)
                local info = classicCreate("TextButton", {
                    Name = "viewInfo",
                    Position = UDim2.new(1, -30, 0, 0),
                    Size = UDim2.new(0, 30, 1, 0),
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Font = Enum.Font.GothamBold,
                    Text = "i",
                    TextColor3 = ClassicUI.theme.SchemeColor,
                    TextSize = 14,
                    Visible = description ~= nil and description ~= "",
                    ZIndex = 4,
                }, element)
                classicBindTheme(info, "TextColor3", "SchemeColor")
                info.Activated:Connect(function() showHint(label, description) end)
                info.MouseEnter:Connect(function() showHint(label, description) end)
                element.MouseEnter:Connect(function()
                    element.BackgroundColor3 = ClassicUI.theme.ElementColor:Lerp(Color3.new(1, 1, 1), 0.08)
                end)
                element.MouseLeave:Connect(function()
                    element.BackgroundColor3 = ClassicUI.theme.ElementColor
                end)
                return element, title, accentIcon, info
            end

            function api:NewButton(label, description, callback)
                local element, _, accentIcon = makeElement("buttonElement", 33, label, description, 0)
                accentIcon.Text = "›"
                accentIcon.TextSize = 20
                element.Activated:Connect(function() classicInvoke(label, callback) end)
                local control = {}
                function control:UpdateButton(newTitle)
                    local titleObject = element:FindFirstChild("togName")
                    if titleObject and newTitle ~= nil then titleObject.Text = tostring(newTitle) end
                end
                return control
            end

            function api:NewToggle(label, description, callback)
                local element, title, accentIcon = makeElement("toggleElement", 33, label, description, 0)
                accentIcon.Visible = false
                local toggleVisualY = UserInputService.TouchEnabled and 11 or 6
                local switch = classicCreate("Frame", {
                    Name = "toggleDisabled",
                    Position = UDim2.fromOffset(7, toggleVisualY),
                    Size = UDim2.fromOffset(21, 21),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                }, element)
                classicCorner(switch, 8)
                local switchStroke = classicCreate("UIStroke", { Thickness = 2 }, switch)
                classicBindTheme(switchStroke, "Color", "SchemeColor")
                local dot = classicCreate("Frame", {
                    Name = "toggleEnabled",
                    Position = UDim2.fromOffset(5, 5),
                    Size = UDim2.fromOffset(11, 11),
                    BackgroundColor3 = ClassicUI.theme.SchemeColor,
                    BorderSizePixel = 0,
                    Visible = false,
                }, switch)
                classicCorner(dot, 6)
                classicBindTheme(dot, "BackgroundColor3", "SchemeColor")
                local state = false
                local control = {}
                function control:UpdateToggle(newText, enabled)
                    if newText ~= nil then title.Text = tostring(newText) end
                    state = enabled == true
                    dot.Visible = state
                    classicInvoke(label, callback, state)
                end
                element.Activated:Connect(function() control:UpdateToggle(nil, not state) end)
                return control
            end

            function api:NewTextBox(label, description, callback)
                local element, title, accentIcon = makeElement("textboxElement", 33, label, description, 0)
                local normalHeight = UserInputService.TouchEnabled and 44 or 33
                accentIcon.Text = "T"
                accentIcon.TextSize = 13
                title.Size = UDim2.new(0.49, -34, 1, 0)
                local input = classicCreate("TextBox", {
                    Name = "TextBox",
                    Position = UDim2.new(0.49, 0, 0.5, -9),
                    Size = UDim2.new(0.43, -2, 0, 18),
                    BackgroundColor3 = Color3.fromRGB(14, 14, 18),
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    PlaceholderText = "Type here!",
                    Text = "",
                    Font = Enum.Font.Gotham,
                    TextColor3 = ClassicUI.theme.TextColor,
                    PlaceholderColor3 = Color3.fromRGB(135, 135, 145),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, element)
                classicCorner(input, 9)
                classicCreate("UIPadding", {
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                }, input)
                local function layoutTextBox(compact)
                    if compact then
                        element.Size = UDim2.new(1, 0, 0, 64)
                        accentIcon.Position = UDim2.fromOffset(7, 4)
                        title.Position = UDim2.fromOffset(34, 0)
                        title.Size = UDim2.new(1, -70, 0, 30)
                        input.Position = UDim2.fromOffset(34, 32)
                        input.Size = UDim2.new(1, -72, 0, 24)
                    else
                        element.Size = UDim2.new(1, 0, 0, normalHeight)
                        accentIcon.Position = UDim2.new(0, 7, 0.5, -11)
                        title.Position = UDim2.fromOffset(34, 0)
                        title.Size = UDim2.new(0.49, -34, 1, 0)
                        input.Position = UDim2.new(0.49, 0, 0.5, -9)
                        input.Size = UDim2.new(0.43, -2, 0, 18)
                    end
                end
                table.insert(responsiveCallbacks, layoutTextBox)
                layoutTextBox(main.Size.X.Offset < 420)
                input.FocusLost:Connect(function(enterPressed)
                    if enterPressed then classicInvoke(label, callback, input.Text) end
                end)
                return input
            end

            function api:NewSlider(label, description, maximum, minimum, defaultValue, callback)
                if type(defaultValue) == "function" then
                    callback = defaultValue
                    defaultValue = minimum
                end
                maximum = tonumber(maximum) or 100
                minimum = tonumber(minimum) or 0
                local element, title, accentIcon = makeElement("sliderElement", 33, label, description, 0)
                local normalHeight = UserInputService.TouchEnabled and 44 or 33
                accentIcon.Text = "◉"
                accentIcon.TextSize = 13
                title.Size = UDim2.new(0.49, -34, 1, 0)
                local value = math.clamp(tonumber(defaultValue) or minimum, minimum, maximum)
                local valueLabel = classicCreate("TextLabel", {
                    Name = "value",
                    Position = UDim2.new(1, -58, 0, 0),
                    Size = UDim2.fromOffset(31, 33),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = tostring(value),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, element)
                classicBindTheme(valueLabel, "TextColor3", "SchemeColor")
                local bar = classicCreate("TextButton", {
                    Name = "sliderBtn",
                    Position = UDim2.new(0.49, 0, 0.5, -12),
                    Size = UDim2.new(0.34, 0, 0, 23),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Text = "",
                }, element)
                local track = classicCreate("Frame", {
                    Name = "track",
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.fromScale(0, 0.5),
                    Size = UDim2.new(1, 0, 0, 6),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 52),
                    BorderSizePixel = 0,
                }, bar)
                classicCorner(track, 3)
                local fill = classicCreate("Frame", {
                    Name = "sliderDrag",
                    Size = UDim2.new(
                        maximum ~= minimum and ((value - minimum) / (maximum - minimum)) or 0,
                        0,
                        1,
                        0
                    ),
                    BorderSizePixel = 0,
                }, track)
                classicCorner(fill, 3)
                classicBindTheme(fill, "BackgroundColor3", "SchemeColor")
                local function layoutSlider(compact)
                    if compact then
                        element.Size = UDim2.new(1, 0, 0, 60)
                        accentIcon.Position = UDim2.fromOffset(7, 4)
                        title.Position = UDim2.fromOffset(34, 0)
                        title.Size = UDim2.new(1, -70, 0, 30)
                        bar.Position = UDim2.fromOffset(34, 30)
                        bar.Size = UDim2.new(1, -136, 0, 28)
                        valueLabel.Position = UDim2.new(1, -100, 0, 30)
                        valueLabel.Size = UDim2.fromOffset(70, 28)
                    else
                        element.Size = UDim2.new(1, 0, 0, normalHeight)
                        accentIcon.Position = UDim2.new(0, 7, 0.5, -11)
                        title.Position = UDim2.fromOffset(34, 0)
                        title.Size = UDim2.new(0.49, -34, 1, 0)
                        bar.Position = UDim2.new(0.49, 0, 0.5, -12)
                        bar.Size = UDim2.new(0.34, 0, 0, 23)
                        valueLabel.Position = UDim2.new(1, -58, 0, 0)
                        valueLabel.Size = UDim2.new(0, 31, 1, 0)
                    end
                end
                table.insert(responsiveCallbacks, layoutSlider)
                layoutSlider(main.Size.X.Offset < 420)
                local dragging = false
                local range = maximum - minimum
                local control = {}
                function control:SetValue(nextValue, invokeCallback)
                    value = math.clamp(tonumber(nextValue) or minimum, minimum, maximum)
                    local percent = range ~= 0 and ((value - minimum) / range) or 0
                    fill.Size = UDim2.new(percent, 0, 1, 0)
                    valueLabel.Text = tostring(value)
                    if invokeCallback ~= false then classicInvoke(label, callback, value) end
                end
                function control:GetValue() return value end
                local function setFromInput(input)
                    if bar.AbsoluteSize.X <= 0 then return end
                    local percent = math.clamp(
                        (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
                        0,
                        1
                    )
                    control:SetValue(math.floor(minimum + (range * percent) + 0.5), true)
                end
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        setFromInput(input)
                    end
                end)
                trackConnection(UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                        setFromInput(input)
                    end
                end))
                trackConnection(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end))
                return control
            end

            function api:NewKeybind(label, description, keyCode, callback)
                local element, title, accentIcon = makeElement("keybindElement", 33, label, description, 70)
                accentIcon.Text = "K"
                accentIcon.TextSize = 12
                local activeKey = keyCode or Enum.KeyCode.Unknown
                local listening = false
                local keyLabel = classicCreate("TextLabel", {
                    Name = "togName",
                    Position = UDim2.new(1, -96, 0, 0),
                    Size = UDim2.fromOffset(70, 33),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamSemibold,
                    Text = activeKey.Name,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, element)
                classicBindTheme(keyLabel, "TextColor3", "SchemeColor")
                element.Activated:Connect(function()
                    listening = true
                    keyLabel.Text = "..."
                end)
                trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
                    if destroyed then return end
                    if listening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown then
                            activeKey = input.KeyCode
                            keyLabel.Text = activeKey.Name
                            listening = false
                        end
                        return
                    end
                    if not processed and not UserInputService:GetFocusedTextBox()
                    and input.KeyCode == activeKey then
                        classicInvoke(label, callback)
                    end
                end))
                local control = {}
                function control:UpdateKeybind(newText, newKey)
                    if newText ~= nil then title.Text = tostring(newText) end
                    if newKey then activeKey = newKey; keyLabel.Text = activeKey.Name end
                end
                return control
            end

            return api
        end

        return tab
    end

    -- Contorno desenhado por último e um pixel para dentro: permanece visível
    -- sobre header/lateral e fecha os quatro cantos sem bloquear os controles.
    local outline = classicCreate("Frame", {
        Name = "MainOutline",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Active = false,
        ZIndex = 100,
    }, main)
    classicCorner(outline, 17)
    local outlineStroke = classicCreate("UIStroke", {
        Thickness = 1,
        Transparency = 0.08,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, outline)
    classicBindTheme(outlineStroke, "Color", "SchemeColor")

    return window
end

return ClassicUI
end)()

local function bootstrapAlive()
    return not destroyed
        and isCurrentSuiteGeneration()
        and runtime
        and runtime.Parent ~= nil
end

local function abortBootstrap()
    destroyed = true
    for index = #runtimeConnections, 1, -1 do
        local connection = runtimeConnections[index]
        pcall(function() connection:Disconnect() end)
        runtimeConnections[index] = nil
    end
    if ClassicUI.gui and ClassicUI.gui.Parent then ClassicUI.gui:Destroy() end
    if startup.gui and startup.gui.Parent then startup.gui:Destroy() end
    if runtime and runtime.Parent then runtime:Destroy() end
end

if startup.status then startup.status.Text = "Montando interface clássica local..." end
if not bootstrapAlive() then
    abortBootstrap()
    return
end

local Window
do
    local windowOk, windowOrError = pcall(function()
        return ClassicUI.CreateLib(UI_TITLE, Theme)
    end)
    if not windowOk or not windowOrError or not bootstrapAlive() then
        warn(MENU_NAME .. ": falha ao criar a janela local: " .. tostring(windowOrError))
        abortBootstrap()
        return
    end
    Window = windowOrError
end

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
    return LocalPlayer.Character
end

local function getHumanoid(character)
    character = character or getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot(character)
    character = character or getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function teleportCharacter(cframe)
    local character = getCharacter()
    local root = getRoot(character)
    local humanoid = getHumanoid(character)
    if not character or not root then
        notify("Teleporte", "HumanoidRootPart não encontrado.")
        return false
    end

    -- Teleportar o HRP enquanto ele está soldado ao assento pode mover o
    -- carrinho inteiro ou causar snapback. Solte o assento primeiro.
    if humanoid and humanoid.SeatPart then
        humanoid.Sit = false
        pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        local deadline = os.clock() + 0.6
        repeat
            RunService.Heartbeat:Wait()
        until not humanoid.Parent or not humanoid.SeatPart or os.clock() >= deadline
    end

    root = getRoot(character)
    if not root then return false end
    local ok = pcall(function()
        local rootOffset = character:GetPivot():ToObjectSpace(root.CFrame)
        character:PivotTo(cframe * rootOffset:Inverse())
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
    if not ok then notify("Teleporte", "Não foi possível mover o personagem.") end
    return ok
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
local killerActive = false
local killerSession = 0
local cartMotionPauseUntil = 0

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
local flySavedState = { freefall = nil, fallingDown = nil, inputEnabled = true }
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
            local freefall = flySavedState.freefall
            local fallingDown = flySavedState.fallingDown
            humanoid:SetStateEnabled(
                Enum.HumanoidStateType.Freefall,
                freefall == nil and true or freefall
            )
            humanoid:SetStateEnabled(
                Enum.HumanoidStateType.FallingDown,
                fallingDown == nil and true or fallingDown
            )
        end)
    end
    flyHumanoid     = nil
    flyAutoRotate   = nil
    flyPlatformStand = nil
    flySavedState.freefall = nil
    flySavedState.fallingDown = nil
    flySavedState.inputEnabled = true
    releaseCameraMode("fly")
end

local function startVehicleFly(inputEnabled)
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
    pcall(function()
        if workspace.CurrentCamera then
            workspace.CurrentCamera.CameraType = Enum.CameraType.Track
        end
    end)

    flyHumanoid      = humanoid
    flyAutoRotate    = humanoid.AutoRotate
    flyPlatformStand = humanoid.PlatformStand
    flySavedState.inputEnabled = inputEnabled ~= false
    pcall(function()
        flySavedState.freefall = humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall)
        flySavedState.fallingDown = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
    end)
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
    showMobileFlyControls(flySavedState.inputEnabled)

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
        if not flySavedState.inputEnabled then return end
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
        if not flySavedState.inputEnabled then return end
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
            local mobileMoving  = flySavedState.inputEnabled and UserInputService.TouchEnabled and (
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
                if not cam then break end
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
            local currentCamera = workspace.CurrentCamera
            if not currentCamera then break end
            bodyGyro.CFrame = currentCamera.CFrame
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

local cachedCartSeat
local cachedCart
local cachedCartAssemblyRoot

local function cacheCartFromSeat(seat)
    cachedCartSeat = seat
    cachedCartAssemblyRoot = seat and seat.AssemblyRootPart or nil
    cachedCart = seat and findCartFromSeat(seat) or nil
    return cachedCart
end

local function getCurrentCart()
    local humanoid = getHumanoid()
    local seat = humanoid and humanoid.SeatPart
    if not seat then
        cachedCartSeat = nil
        cachedCart = nil
        cachedCartAssemblyRoot = nil
        return nil
    end
    if seat ~= cachedCartSeat
        or not cachedCart
        or not cachedCart.Parent
        or not cachedCart:IsAncestorOf(seat)
        or seat.AssemblyRootPart ~= cachedCartAssemblyRoot
    then
        return cacheCartFromSeat(seat)
    end
    return cachedCart
end

-- Retorna a parte principal do carrinho de forma robusta
local function getCartPrimary(cart)
    if not cart then return nil end
    if cart.PrimaryPart then return cart.PrimaryPart end
    local seat = cachedCartSeat
    if not seat or not seat.Parent then
        local humanoid = getHumanoid()
        seat = humanoid and humanoid.SeatPart
    end
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
        return true
    end

    local cart = getCurrentCart()
    if not cart then
        notify("Carrinho", "Sente em um carrinho primeiro.")
        return false
    end

    if killerActive then
        killerSession = killerSession + 1
        killerActive = false
    end
    if flyEnabled and flyToggleControl then
        flyToggleControl:UpdateToggle(nil, false)
    else
        stopFly()
    end
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
    return true
end

local function pivotCartByReference(cart, desiredReferenceCFrame)
    local reference = getCartPrimary(cart)
    if not cart or not reference then return false end
    return pcall(function()
        local referenceOffset = cart:GetPivot():ToObjectSpace(reference.CFrame)
        for _, part in ipairs(cart:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
        cart:PivotTo(desiredReferenceCFrame * referenceOffset:Inverse())
        for _, part in ipairs(cart:GetDescendants()) do
            if part:IsA("BasePart") then
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

local function stopCartControllersForTeleport()
    cartMotionPauseUntil = os.clock() + 0.25
    if killerActive then
        killerSession = killerSession + 1
        killerActive = false
    end
    if flyEnabled and flyToggleControl then
        flyToggleControl:UpdateToggle(nil, false)
    else
        stopFly()
    end
    if stopBoost then stopBoost() end
    restorePanicStop()
    if boostToggleControl then
        task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
    end
    if panicToggleControl then
        task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
    end
end

local function teleportCart(cframe)
    local cart = getCurrentCart()
    if not cart then notify("Carrinho", "Sente em um carrinho primeiro.") return false end
    stopCartControllersForTeleport()
    local ok = pivotCartByReference(cart, cframe)
    if ok then
        notify("Carrinho", "Carrinho movido para o checkpoint.")
    else
        notify("Carrinho", "Não foi possível mover este carrinho.")
    end
    return ok
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
    local keywords = { "wheel", "tire", "tyre", "roda", "pneu", "axle", "roue" }
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
        if stabilizer.enabled and not FLYING and not panicActive
            and os.clock() >= cartMotionPauseUntil
        then
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
local function watchSeat(character, readyHumanoid)
    local humanoid = readyHumanoid or getHumanoid(character)
    if not humanoid then return end
    if seatConnection then
        seatConnection:Disconnect()
        seatConnection = nil
    end
    cacheCartFromSeat(humanoid.SeatPart)
    seatConnection = trackConnection(humanoid.Seated:Connect(function(isSeated, seat)
        if not isSeated then
            cacheCartFromSeat(nil)
            cleanupStabilizer()
            restorePanicStop()
            if stopBoost then stopBoost() end
            if boostToggleControl then
                task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
            end
            if panicToggleControl then
                task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
            end
        else
            local cart = cacheCartFromSeat(seat)
            if stabilizer.enabled then applyStabilizer(cart) end
        end
    end))
end

local function watchSeatWhenReady(character, restoreDesiredSettings)
    if not character then return end
    task.spawn(function()
        local humanoid = character:FindFirstChildOfClass("Humanoid")
            or character:WaitForChild("Humanoid", 5)
        if destroyed or not isCurrentSuiteGeneration()
            or not character.Parent or not humanoid or not humanoid:IsA("Humanoid")
        then
            return
        end
        watchSeat(character, humanoid)
        if restoreDesiredSettings and not fakeLagActive then
            if desiredWalkSpeed then humanoid.WalkSpeed = desiredWalkSpeed end
            if humanoid.UseJumpPower and desiredJumpPower then
                humanoid.JumpPower = desiredJumpPower
            elseif not humanoid.UseJumpPower and desiredJumpHeight then
                humanoid.JumpHeight = desiredJumpHeight
            end
        end
    end)
end

watchSeatWhenReady(LocalPlayer.Character, false)
trackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
    cacheCartFromSeat(nil)
    cleanupStabilizer()
    restorePanicStop()
    if panicToggleControl then
        task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
    end
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
    watchSeatWhenReady(character, true)
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

    -- O Eliminador controla o CFrame até o alvo; bloqueie WASD temporariamente
    -- para não deixar dois escritores moverem o mesmo carrinho.
    if not startVehicleFly(false) then finishKiller("Não foi possível iniciar o voo.", session) return end
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
        stopCartControllersForTeleport()
        return pivotCartByReference(cart, cframe)
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
local PlayerSection = Window:NewTab("Jogador"):NewSection("Configurações do Jogador")

PlayerSection:NewSlider("Velocidade", "Velocidade de caminhada (padrão 16).", 500, 0, 16, function(value)
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
    if backpack:FindFirstChild("NothriloClickTP")
        or (character and character:FindFirstChild("NothriloClickTP")) then
        notify("Teleporte por Clique", "A ferramenta já está na mochila.")
        return
    end
    local tool = Instance.new("Tool")
    tool.Name            = "NothriloClickTP"
    tool.RequiresHandle  = false
    tool:SetAttribute("CafezlOwner", "Nothrilo")
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
        if killerActive then
            flyEnabled = false
            notify("Voo do Veículo", "Indisponível durante o Eliminador.")
            task.defer(function()
                if flyToggleControl then flyToggleControl:UpdateToggle(nil, false) end
            end)
            return
        end
        if panicActive then
            restorePanicStop()
            if panicToggleControl then
                task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
            end
        end
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
local TeleportSection = Window:NewTab("Teleporte"):NewSection("Teleportes")

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
    if teleportCharacter(CFrame.new(
        -416.844727, 163.402969, 171.087555,
        0.0174489655, 5.45878223e-08, 0.99984777,
        -4.55684486e-08, 1, -5.38008926e-08,
        -0.99984777, -4.46227411e-08, 0.0174489655
    )) then
        notify("Teleporte", "Teleportado para Suffering.")
    end
end)

TeleportSection:NewButton("Insígnia Secreta", "Teleporta para a Secret Badge da referência.", function()
    if teleportCharacter(CFrame.new(234.500259, 2.28650475, 296.495483)) then
        notify("Teleporte", "Teleportado para a insígnia secreta.")
    end
end)

TeleportSection:NewButton("Sala Secreta", "Procura Workspace.Misc.Giver.", function()
    local misc  = workspace:FindFirstChild("Misc")
    local giver = misc and misc:FindFirstChild("Giver")
    local part  = giver and (giver:IsA("BasePart") and giver or giver:FindFirstChildWhichIsA("BasePart", true))
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
    function(state)
        local applied = setPanicStop(state)
        if state and not applied then
            task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
        end
    end
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
local BoostSection  = Window:NewTab("Cart+"):NewSection("Boost e Física")

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

BoostSection:NewSlider("Força do Boost", "Intensidade (padrão 500).", 3000, 0, 500, function(value)
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
    if antiFlipConn then antiFlipConn:Disconnect() antiFlipConn = nil end
    if not state then
        notify("Anti-Flip", "Desligado.")
        return
    end

    antiFlipConn = RunService.Heartbeat:Connect(function()
        if not antiFlipEnabled or antiFlipCooldown or panicActive or FLYING or killerActive
            or os.clock() < cartMotionPauseUntil
        then return end
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
            pivotCartByReference(
                cart,
                CFrame.new(pos + Vector3.new(0, 2, 0), pos + Vector3.new(0, 2, 0) + look)
            )
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
    if autobrakeConn then autobrakeConn:Disconnect() autobrakeConn = nil end
    if not state then
        notify("Freio Automático", "Desligado.")
        return
    end

    autobrakeConn = RunService.Heartbeat:Connect(function()
        if not autobrakeEnabled or autobrakeCooldown or panicActive or FLYING or killerActive
            or os.clock() < cartMotionPauseUntil
        then return end
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
local ExtrasSection = Window:NewTab("Extras"):NewSection("Movimento e Física")

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

ExtrasSection:NewSlider("Jump Power", "Altura do pulo (padrão 50).", 300, 0, 50, function(value)
    desiredJumpPower = value
    desiredJumpHeight = 7.2 * (value / 50)
    local h = getHumanoid()
    if h and not fakeLagActive then
        if h.UseJumpPower then h.JumpPower = desiredJumpPower
        else h.JumpHeight = desiredJumpHeight end
    end
end)

ExtrasSection:NewButton("Redefinir Jump Power", "Volta para 50.", function()
    desiredJumpPower = 50
    desiredJumpHeight = 7.2
    local h = getHumanoid()
    if h and not fakeLagActive then
        if h.UseJumpPower then h.JumpPower = desiredJumpPower
        else h.JumpHeight = desiredJumpHeight end
    end
    notify("Jump Power", "Redefinido.")
end)

ExtrasSection:NewSlider("Gravidade", "Gravidade global (padrão 196.2).", 400, 0, originalGravity, function(value)
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
local MapSection = Window:NewTab("Mapa"):NewSection("Exploração")

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

MapSection:NewSlider("Velocidade da Câmera Livre", "Velocidade de movimento (1–10).", 10, 1, freecamSpeed, function(value)
    freecamSpeed = value
end)

-- =============================================================================
-- ABA: Eliminador
-- =============================================================================
local KillerSection = Window:NewTab("Eliminador"):NewSection("Killer • GRÁTIS ✓")
local targetName    = ""

KillerSection:NewTextBox("Nome do Alvo", "Digite parte do nome e pressione Enter.", function(value)
    targetName = value
end)

KillerSection:NewButton(
    "Alcançar Alvo",
    "Usa o carrinho livre mais próximo contra o alvo.",
    function()
        if not targetName or targetName:match("^%s*$") then
            notify("Eliminador", "Digite parte do nome e pressione Enter.")
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
local TrollSection = Window:NewTab("Troll"):NewSection("Diversão")

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

TrollSection:NewSlider("Duração Câmera (s)", "Segundos de giro.", 30, 1, spinDuration, function(value)
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

TrollSection:NewSlider("Duração Fake Lag (s)", "Duração em segundos.", 15, 1, fakeLagDuration, function(value)
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

local menuGui = Window and Window.gui or findMenuGui()
if not bootstrapAlive() then
    abortBootstrap()
    return
end

local commandsTabButton
if not menuGui then
    warn(MENU_NAME .. ": não foi possível localizar a janela clássica local.")
    menuGui = Instance.new("ScreenGui")
    menuGui.Name = "NothriloFallbackHost"
    menuGui.ResetOnSpawn = false
    menuGui.Parent = CoreGui
end

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
    -- No toque a linha inteira já é o controle; esconder teclas libera espaço
    -- para nomes maiores e evita colisão com o ícone de informação.
    if UserInputService.TouchEnabled then return end
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
                badge.Position       = UDim2.new(1, -(badgeWidth + 31), 0, 6)
                badge.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
                badge.BorderSizePixel = 0
                badge.AutoButtonColor = false
                badge.Font           = Enum.Font.GothamBold
                badge.Text           = keyText
                badge.TextColor3     = Theme.SchemeColor
                badge.TextSize       = keyText == "1/2/3" and 9 or 12
                badge.ZIndex         = 3
                badge.Parent         = element
                Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 7)
                table.insert(customKeybindIcons, badge)

                -- Reserve espaço real: a Kavo original deixava textos longos
                -- passarem por baixo do atalho e do ícone de informação.
                if title.Parent == element then
                    title.Size = UDim2.new(1, -(badgeWidth + 70), 1, 0)
                end

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
launcher.Text             = string.upper(MENU_NAME)
launcher.TextColor3       = Color3.fromRGB(255, 255, 255)
launcher.TextSize         = 15
launcher.TextXAlignment   = Enum.TextXAlignment.Left
launcher.Visible          = false
launcher.Parent           = launcherGui
Instance.new("UICorner", launcher).CornerRadius = UDim.new(0, 18)
local launcherPadding = Instance.new("UIPadding")
launcherPadding.PaddingLeft = UDim.new(0, 52)
launcherPadding.PaddingRight = UDim.new(0, 10)
launcherPadding.Parent = launcher

local launcherStroke = Instance.new("UIStroke")
launcherStroke.Thickness = 1.5
launcherStroke.Parent    = launcher

local launcherIcon = Instance.new("TextLabel")
launcherIcon.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
launcherIcon.BackgroundTransparency = 0
launcherIcon.Size     = UDim2.fromOffset(36, 36)
launcherIcon.Position = UDim2.fromOffset(7, 7)
launcherIcon.Font     = Enum.Font.GothamBold
launcherIcon.Text     = "N"
launcherIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
launcherIcon.TextSize = 18
launcherIcon.Parent   = launcher
Instance.new("UICorner", launcherIcon).CornerRadius = UDim.new(1, 0)

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
        minimize.Size             = UDim2.fromOffset(30, 30)
        minimize.Position         = UDim2.new(1, -32, 0, 2)
        minimize.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        minimize.BackgroundTransparency = 0.20
        minimize.AutoButtonColor  = false
        minimize.Font             = Enum.Font.GothamBold
        minimize.Text             = "—"
        minimize.TextColor3       = Color3.fromRGB(255, 255, 255)
        minimize.TextSize         = 17
    minimize.Parent           = header
    Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 10)
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
local CommandsSection = Window:NewTab("Comandos"):NewSection("Atalhos")
commandsTabButton     = menuGui:FindFirstChild("ComandosTabButton", true)

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
local GuiSection = Window:NewTab("Interface"):NewSection("Interface")

GuiSection:NewButton("Fechar Menu", "Fecha agora; a tecla X também funciona.", destroyNothrilo)
addShortcutBadge("Fechar Menu", "X")

-- Publicação atômica: a janela só aparece depois que todas as abas, comandos e
-- listeners pertencentes a esta geração terminaram de ser montados.
if not bootstrapAlive() then
    abortBootstrap()
    return
end
menuGui.Enabled = false
if os.clock() < startup.beganAt + startup.seconds then
    if startup.status then startup.status.Text = "Funções prontas • terminando carregamento seguro..." end
    repeat
        RunService.RenderStepped:Wait()
        if not bootstrapAlive() then
            abortBootstrap()
            return
        end
    until os.clock() >= startup.beganAt + startup.seconds
end
if startup.gui and startup.gui.Parent then startup.gui:Destroy() end
menuGui.Enabled = true

-- =============================================================================
-- Loop RGB
-- =============================================================================
task.spawn(function()
    while running and not destroyed and menuGui.Parent and launcherGui.Parent do
        local rgb = Color3.fromHSV((os.clock() * 0.12) % 1, 0.85, 1)
        ClassicUI:ChangeColor("SchemeColor", rgb)
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
