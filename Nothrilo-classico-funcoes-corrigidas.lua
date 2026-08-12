-- =============================================================================
-- Nothrilo üáßüá∑ ‚Äî Menu completo por Cafezl
-- Vers√£o auditada: bugs corrigidos + novas fun√ß√µes
-- =============================================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local StarterGui     = game:GetService("StarterGui")

local LocalPlayer  = Players.LocalPlayer
if not LocalPlayer then return end
local MENU_NAME    = "Nothrilo üáßüá∑"
local UI_TITLE     = MENU_NAME .. " | Feito por Cafezl"

-- Token compartilhado entre as skins. Uma execu√ß√£o nova invalida imediatamente
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
    warn(MENU_NAME .. ": PlayerGui/CoreGui ainda n√£o est√° dispon√≠vel.")
    return
end

-- A UI cl√°ssica local usa o pai escolhido acima. Os outros roots entram apenas
-- na descoberta/limpeza de vers√µes antigas que ainda possam estar abertas.
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

-- Encerra qualquer skin anterior da su√≠te. Assim Nothrilo e Cafezitos n√£o
-- disputam os mesmos atalhos, movers e for√ßas quando um √© aberto ap√≥s o outro.
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

-- S√≥ capture o valor original depois que a inst√¢ncia anterior se restaurou.
local originalGravity = workspace.Gravity

local runtime = Instance.new("Folder")
runtime.Name  = "NothriloRuntime"
runtime.Parent = CoreGui

do
    local runtimeCleanup = Instance.new("BindableEvent")
    runtimeCleanup.Name   = "Cleanup"
    runtimeCleanup.Parent = runtime

    -- O handler existe desde o come√ßo da inicializa√ß√£o. Se uma execu√ß√£o nova
    -- chegar durante o carregamento, a inst√¢ncia incompleta tamb√©m √© descartada.
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
end

-- Remove somente GUIs antigas do pr√≥prio Nothrilo.
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

-- Tema escuro ‚Äî s√≥ os detalhes passam pelo RGB
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
-- Loader compacto e procedural: n√£o depende de v√≠deo, GIF, arquivo local nem
-- APIs diferentes entre executores. Por isso abre igual no Roblox e no Xeno.
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
    shadow.Size                   = UDim2.new(0.88, 0, 0, 190)
    shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.38
    shadow.BorderSizePixel        = 0
    shadow.Parent                 = shade
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 24)

    local shadowSize = Instance.new("UISizeConstraint")
    shadowSize.MinSize = Vector2.new(278, 190)
    shadowSize.MaxSize = Vector2.new(390, 190)
    shadowSize.Parent  = shadow

    local card = Instance.new("Frame")
    card.Name            = "Card"
    card.AnchorPoint     = Vector2.new(0.5, 0.5)
    card.Position        = UDim2.fromScale(0.5, 0.5)
    card.Size            = UDim2.new(0.88, 0, 0, 190)
    card.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent          = shade
    local cardSize = Instance.new("UISizeConstraint")
    cardSize.MinSize = Vector2.new(278, 190)
    cardSize.MaxSize = Vector2.new(390, 190)
    cardSize.Parent = card

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color     = Theme.SchemeColor
    stroke.Parent    = card

    stroke.Transparency = 0.06

    local brandDot = Instance.new("Frame")
    brandDot.Name             = "BrandDot"
    brandDot.Position         = UDim2.fromOffset(18, 18)
    brandDot.Size             = UDim2.fromOffset(18, 18)
    brandDot.BackgroundColor3 = Theme.SchemeColor
    brandDot.BorderSizePixel  = 0
    brandDot.Parent           = card
    Instance.new("UICorner", brandDot).CornerRadius = UDim.new(1, 0)

    local titleL = Instance.new("TextLabel")
    titleL.BackgroundTransparency = 1
    titleL.Position  = UDim2.fromOffset(46, 14)
    titleL.Size      = UDim2.new(1, -64, 0, 26)
    titleL.Font      = Enum.Font.GothamBold
    titleL.Text      = MENU_NAME
    titleL.TextColor3 = Color3.fromRGB(248, 248, 250)
    titleL.TextSize  = 18
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.Parent    = card

    local subtitleL = Instance.new("TextLabel")
    subtitleL.BackgroundTransparency = 1
    subtitleL.Position  = UDim2.fromOffset(18, 43)
    subtitleL.Size      = UDim2.new(1, -36, 0, 17)
    subtitleL.Font      = Enum.Font.Gotham
    subtitleL.Text      = "Feito por Cafezl  ‚Ä¢  preparando tudo"
    subtitleL.TextColor3 = Color3.fromRGB(205, 205, 214)
    subtitleL.TextSize  = 12
    subtitleL.TextXAlignment = Enum.TextXAlignment.Left
    subtitleL.Parent    = card

    local emojiPanel = Instance.new("Frame")
    emojiPanel.Name             = "EmojiPanel"
    emojiPanel.Position         = UDim2.fromOffset(14, 66)
    emojiPanel.Size             = UDim2.new(1, -28, 0, 62)
    emojiPanel.BackgroundColor3 = Color3.fromRGB(17, 17, 23)
    emojiPanel.BorderSizePixel  = 0
    emojiPanel.ClipsDescendants = true
    emojiPanel.Parent           = card
    Instance.new("UICorner", emojiPanel).CornerRadius = UDim.new(0, 16)

    local emojiStroke = Instance.new("UIStroke")
    emojiStroke.Thickness    = 1
    emojiStroke.Transparency = 0.60
    emojiStroke.Color        = Theme.SchemeColor
    emojiStroke.Parent       = emojiPanel

    local emojiLabels = {}
    local emojis = { "üê±", "üò∏", "‚ú®", "‚ö°", "üöÄ", "üéÆ" }
    for index, emoji in ipairs(emojis) do
        local label = Instance.new("TextLabel")
        label.Name = "Emoji" .. index
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.Position = UDim2.new((index - 0.5) / #emojis, 0, 0.5, 0)
        label.Size = UDim2.fromOffset(42, 46)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = emoji
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 27
        label.Parent = emojiPanel
        table.insert(emojiLabels, label)
    end

    local statusDot = Instance.new("Frame")
    statusDot.Name             = "StatusDot"
    statusDot.AnchorPoint      = Vector2.new(0.5, 0.5)
    statusDot.Position         = UDim2.fromOffset(22, 148)
    statusDot.Size             = UDim2.fromOffset(8, 8)
    statusDot.BackgroundColor3 = Theme.SchemeColor
    statusDot.BorderSizePixel  = 0
    statusDot.Parent           = card
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position  = UDim2.fromOffset(34, 137)
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
    percent.Position = UDim2.new(1, -68, 0, 137)
    percent.Size = UDim2.fromOffset(50, 22)
    percent.Font = Enum.Font.GothamSemibold
    percent.Text = "0%"
    percent.TextColor3 = Theme.SchemeColor
    percent.TextSize = 12
    percent.TextXAlignment = Enum.TextXAlignment.Right
    percent.Parent = card

    local progressTrack = Instance.new("Frame")
    progressTrack.Name = "ProgressTrack"
    progressTrack.Position = UDim2.fromOffset(18, 166)
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

    task.spawn(function()
        local generatedStatus = status.Text
        while gui.Parent do
            local elapsed = os.clock() - startup.beganAt
            local alpha = math.clamp(elapsed / startup.seconds, 0, 1)
            progress.Size = UDim2.fromScale(alpha, 1)

            local rgb = Color3.fromHSV((elapsed * 0.20) % 1, 0.84, 1)
            progress.BackgroundColor3 = rgb
            stroke.Color = rgb
            emojiStroke.Color = rgb
            brandDot.BackgroundColor3 = rgb
            statusDot.BackgroundColor3 = rgb
            status.TextColor3 = rgb
            percent.TextColor3 = rgb
            percent.Text = ("%d%%"):format(math.floor(alpha * 100))

            local message
            if alpha < 0.24 then
                message = "Preparando interface..."
            elseif alpha < 0.50 then
                message = "Carregando fun√ß√µes..."
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
                label.Position = UDim2.new(
                    (index - 0.5) / #emojiLabels,
                    0,
                    0.5,
                    math.floor(math.sin(wave) * 4)
                )
                label.Rotation = math.sin(waﬂ›t÷⁄$z{-ÆÈ‹j◊ù‡¢ñbFóF∆RÂ&VÁB”“V∆V÷VÁBFÜV‡¢FóF∆RÂ6ó¶R“TFñ”"ÊÊWrÉ¬“Ü&FvUvñGFÇ≤sí¬¬ê¢VÊ@†–¢&FvR‰7FófFVC§6ˆÊÊV7BÜgVÊ7Fñˆ‚Çê–¢ñb∂WïFWáB”“%b"FÜV‚f«ïFˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜Bf«îVÊ&∆VBê–¢V«6Vñb∂WïFWáB”“$¬"FÜV‚W7Fˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜BW7VÊ&∆VBê–¢V«6Vñb∂WïFWáB”“%"FÜV‚ñÊfñÊóFTßV◊Fˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜BñÊfñÊóFTßV◊ê–¢V«6Vñb∂WïFWáB”“%B"FÜV‚vófT6∆ñ6µFV∆W˜'EFˆˆ¬Çê–¢V«6Vñb∂WïFWáB”“#"FÜV‚FV∆W˜'EFÙ6ÜV6∑ˆñÁBÉê–¢V«6Vñb∂WïFWáB”“#""FÜV‚FV∆W˜'EFÙ6ÜV6∑ˆñÁBÉ"ê–¢V«6Vñb∂WïFWáB”“#2"FÜV‚FV∆W˜'EFÙ6ÜV6∑ˆñÁBÉ2ê–¢V«6Vñb∂WïFWáB”“#Û"Û2"FÜV‚Ê˜FñgíÇ$6ÜV6∑ˆñÁG2"¬%W6RÁV’B¬"˜R2‚"ê–¢V«6Vñb∂WïFWáB”“$""FÜV‚&ˆ˜7EFˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜B&ˆ˜7D7FófRê–¢V«6Vñb∂WïFWáB”“$≤"FÜV‚6WD÷VÁUfó6ñ&∆RÜf«6Rê–¢V«6Vñb∂WïFWáB”“%Ç"ÊBFW7G&˜îÊ˜Fá&ñ∆ÚFÜV‚FW7G&˜îÊ˜Fá&ñ∆ÚÇê–¢VÊ@–¢VÊBê–¢&WGW&‡–¢VÊ@–¢VÊ@–¢VÊ@–¶VÊ@–†–¢““&FvW2F2&2˜&ñvñÊó0–¶FE6Ü˜'F7WD&FvRÇ%fˆÚFÚf\:÷7V∆Ú"¬%b"ê–¶FE6Ü˜'F7WD&FvRÇ$U5"¬$¬"ê–¶FE6Ü˜'F7WD&FvRÇ%V∆ÚñÊfñÊóFÚ"¬%"ê–¶FE6Ü˜'F7WD&FvRÇ%FV∆W˜'FR˜"6∆óVR"¬%B"ê–¶FE6Ü˜'F7WD&FvRÇ$&ˆ˜7BFÚ6'&ñÊÜÚ"¬$""ê–¶FE6Ü˜'F7WD&FvRÇ$ó"Ú6ÜV6∑ˆñÁB"¬#"ê–¶FE6Ü˜'F7WD&FvRÇ$ó"Ú6ÜV6∑ˆñÁB""¬#""ê–¶FE6Ü˜'F7WD&FvRÇ$ó"Ú6ÜV6∑ˆñÁB2"¬#2"ê–†–¢““6ó7FV÷FRFˆ7@–¶∆ˆ6¬Fˆ7DwVí“ñÁ7FÊ6RÊÊWrÇ%67&VV‰wVí"ê–ßFˆ7DwVí‰Ê÷R“$Ê˜Fá&ñ∆ÙÊ˜Fñfñ6FñˆÁ2 –ßFˆ7DwVíÂ&W6WDˆÂ7v‚“f«6P–ßFˆ7DwVí‰ñvÊ˜&TwVîñÁ6WB“G'VP–ßFˆ7DwVí‰Fó7∆î˜&FW"“–ßFˆ7DwVíÂ&VÁB“÷VÁTwVíÂ&VÁ@–†–ßFˆ7D6ˆÁFñÊW"“ñÁ7FÊ6RÊÊWrÇ$g&÷R"ê–ßFˆ7D6ˆÁFñÊW"‰Ê÷R“%Fˆ7D6ˆÁFñÊW" –ßFˆ7D6ˆÁFñÊW"‰Ê6Ü˜%ˆñÁB“fV7F˜#"ÊÊWrÉ¬ê–ßFˆ7D6ˆÁFñÊW"Â˜6óFñˆ‚“TFñ”"ÊÊWrÉ¬”Ç¬¬#ê–ßFˆ7D6ˆÁFñÊW"Â6ó¶R“TFñ”"Êg&ˆ‘ˆfg6WBÉ3¬3ê–ßFˆ7D6ˆÁFñÊW"‰&6∂w&˜VÊEG&Á7&VÊ7í“–ßFˆ7D6ˆÁFñÊW"Â&VÁB“Fˆ7DwVê–†–¶∆ˆ6¬Fˆ7D∆ñ˜WB“ñÁ7FÊ6RÊÊWrÇ%Tî∆ó7D∆ñ˜WB"ê–ßFˆ7D∆ñ˜WBÂFFñÊr“TFñ“ÊÊWrÉ¬Çê–ßFˆ7D∆ñ˜WBÂ6˜'D˜&FW"“VÁV“Â6˜'D˜&FW"‰∆ñ˜WD˜&FW –ßFˆ7D∆ñ˜WBÂ&VÁB“Fˆ7D6ˆÁFñÊW –†–¢““G&rÜV«W"Ü÷˜W6RRF˜V6Çê–¶∆ˆ6¬gVÊ7Fñˆ‚VÊ&∆TG&ráF&vWB¬ÜÊF∆R¬ˆ‰G&tVÊBê–¢F&vWB‰7FófR“G'VP–¢ÜÊF∆R‰7FófR“G'VP–¢∆ˆ6¬G&vvñÊr¬G&tñÁWB¬G&u7F'B¬7F'E˜2¬v4G&vvVB“f«6R¬Êñ¬¬Êñ¬¬Êñ¬¬f«6P–†–¢∆ˆ6¬gVÊ7Fñˆ‚WFFU˜2ÜñÁWBê–¢∆ˆ6¬FV«F“ñÁWBÂ˜6óFñˆ‚“G&u7F'@–¢ñbFV«F‰÷vÊóGVFR‚bFÜV‚v4G&vvVB“G'VRVÊ@–¢F&vWBÂ˜6óFñˆ‚“TFñ”"ÊÊWrÄ–¢7F'E˜2ÂÇÂ66∆R¬7F'E˜2ÂÇ‰ˆfg6WB≤FV«FÂÇ¿–¢7F'E˜2ÂíÂ66∆R¬7F'E˜2Âí‰ˆfg6WB≤FV«FÂê–¢ê–¢VÊ@–†–¢ÜÊF∆R‰ñÁWD&Vv„§6ˆÊÊV7BÜgVÊ7Fñˆ‚ÜñÁWBê–¢ñbñÁWBÂW6W$ñÁWEGóR„“VÁV“ÂW6W$ñÁWEGóR‰÷˜W6T'WGFˆ„–¢ÊBñÁWBÂW6W$ñÁWEGóR„“VÁV“ÂW6W$ñÁWEGóRÂF˜V6ÇFÜV‚&WGW&‚VÊ@–¢G&vvñÊr“G'VP–¢v4G&vvVB“f«6P–¢G&u7F'B“ñÁWBÂ˜6óFñˆ‡–¢7F'E˜2“F&vWBÂ˜6óFñˆ‡–¢ñÁWB‰6ÜÊvVC§6ˆÊÊV7BÜgVÊ7Fñˆ‚Çê–¢ñbñÁWBÂW6W$ñÁWE7FFR”“VÁV“ÂW6W$ñÁWE7FFR‰VÊBFÜV‡–¢G&vvñÊr“f«6P–¢ñbˆ‰G&tVÊBFÜV‚ˆ‰G&tVÊBáv4G&vvVBíVÊ@–¢VÊ@–¢VÊBê–¢VÊBê–†–¢ÜÊF∆R‰ñÁWD6ÜÊvVC§6ˆÊÊV7BÜgVÊ7Fñˆ‚ÜñÁWBê–¢ñbñÁWBÂW6W$ñÁWEGóR”“VÁV“ÂW6W$ñÁWEGóR‰÷˜W6T÷˜fV÷VÁ@–¢˜"ñÁWBÂW6W$ñÁWEGóR”“VÁV“ÂW6W$ñÁWEGóRÂF˜V6ÇFÜV‡–¢G&tñÁWB“ñÁW@–¢VÊ@–¢VÊBê–†–¢G&6¥6ˆÊÊV7Fñˆ‚ÖW6W$ñÁWE6W'fñ6R‰ñÁWD6ÜÊvVC§6ˆÊÊV7BÜgVÊ7Fñˆ‚ÜñÁWBê¢ñbG&vvñÊrÊBñÁWB”“G&tñÁWBFÜV‚WFFU˜2ÜñÁWBíVÊ@¢VÊBíê¶VÊ@–†–¢““∆VÊ6ÜW"Ü&˜L:6Ú&&V'&ó"VÊFÚ÷ñÊñ÷ó¶FÚê–¶∆ˆ6¬∆VÊ6ÜW$wVí“ñÁ7FÊ6RÊÊWrÇ%67&VV‰wVí"ê–¶∆VÊ6ÜW$wVí‰Ê÷R“$Ê˜Fá&ñ∆Ù∆VÊ6ÜW" –¶∆VÊ6ÜW$wVíÂ&W6WDˆÂ7v‚“f«6P–¶∆VÊ6ÜW$wVí‰ñvÊ˜&TwVîñÁ6WB“G'VP–¶∆VÊ6ÜW$wVí‰Fó7∆î˜&FW"“ –¶∆VÊ6ÜW$wVíÂ&VÁB“÷VÁTwVíÂ&VÁ@–†–¶∆ˆ6¬∆VÊ6ÜW"“ñÁ7FÊ6RÊÊWrÇ%FWáD'WGFˆ‚"ê–¶∆VÊ6ÜW"‰Ê÷R“$˜V‰Ê˜Fá&ñ∆Ù÷VÁR –¶∆VÊ6ÜW"Â6ó¶R“TFñ”"Êg&ˆ‘ˆfg6WBÉsÇ¬Sê–¶∆VÊ6ÜW"Â˜6óFñˆ‚“TFñ”"ÊÊWrÉ¬b¬„R¬”#Rê–¶∆VÊ6ÜW"‰&6∂w&˜VÊD6ˆ∆˜#2“6ˆ∆˜#2Êg&ˆ’$t"É¬¬"ê–¶∆VÊ6ÜW"‰&˜&FW%6ó¶UóÜV¬“ –¶∆VÊ6ÜW"‰WFÙ'WGFˆ‰6ˆ∆˜"“f«6P–¶∆VÊ6ÜW"‰fˆÁB“VÁV“‰fˆÁB‰v˜FÜ‘&ˆ∆@–¶∆VÊ6ÜW"ÂFWáB“""‚‚7G&ñÊrÁWW"Ñ‘TÂUÙ‰‘Rê–¶∆VÊ6ÜW"ÂFWáD6ˆ∆˜#2“6ˆ∆˜#2Êg&ˆ’$t"É#SR¬#SR¬#SRê–¶∆VÊ6ÜW"ÂFWáE6ó¶R“`–¶∆VÊ6ÜW"ÂFWáEÑ∆ñvÊ÷VÁB“VÁV“ÂFWáEÑ∆ñvÊ÷VÁB‰∆Vg@–¶∆VÊ6ÜW"Âfó6ñ&∆R“f«6P–¶∆VÊ6ÜW"Â&VÁB“∆VÊ6ÜW$wVê–§ñÁ7FÊ6RÊÊWrÇ%Tî6˜&ÊW""¬∆VÊ6ÜW"í‰6˜&ÊW%&FóW2“TFñ“ÊÊWrÉ¬Çê–†–¶∆ˆ6¬∆VÊ6ÜW%7G&ˆ∂R“ñÁ7FÊ6RÊÊWrÇ%Tï7G&ˆ∂R"ê–¶∆VÊ6ÜW%7G&ˆ∂RÂFÜñ6∂ÊW72“ –¶∆VÊ6ÜW%7G&ˆ∂RÂ&VÁB“∆VÊ6ÜW –†–¶∆ˆ6¬∆VÊ6ÜW$ñ6ˆ‚“ñÁ7FÊ6RÊÊWrÇ%FWáD∆&V¬"ê–¶∆VÊ6ÜW$ñ6ˆ‚‰&6∂w&˜VÊEG&Á7&VÊ7í“–¶∆VÊ6ÜW$ñ6ˆ‚Â6ó¶R“TFñ”"Êg&ˆ‘ˆfg6WBÉ3Ç¬Sê–¶∆VÊ6ÜW$ñ6ˆ‚Â˜6óFñˆ‚“TFñ”"Êg&ˆ‘ˆfg6WBÉb¬ê–¶∆VÊ6ÜW$ñ6ˆ‚‰fˆÁB“VÁV“‰fˆÁB‰v˜FÜ‘&ˆ∆@–¶∆VÊ6ÜW$ñ6ˆ‚ÂFWáB“$‚ –¶∆VÊ6ÜW$ñ6ˆ‚ÂFWáE6ó¶R“# –¶∆VÊ6ÜW$ñ6ˆ‚Â&VÁB“∆VÊ6ÜW –†–ß6WD÷VÁUfó6ñ&∆R“gVÊ7Fñˆ‚áfó6ñ&∆Rê¢ñbFW7G&˜ñVBFÜV‚&WGW&‚VÊ@–¢÷VÁTwVí‰VÊ&∆VB“fó6ñ&∆P–¢∆VÊ6ÜW"Âfó6ñ&∆R“Ê˜Bfó6ñ&∆P–¶VÊ@–†–¶∆ˆ6¬÷ñ‚“÷VÁTwVì§fñÊDfó'7D6Üñ∆BÇ$÷ñ‚"ê–¶∆ˆ6¬ÜVFW"“÷ñ‚ÊB÷ñ„§fñÊDfó'7D6Üñ∆BÇ$÷ñ‰ÜVFW""ê–¶∆ˆ6¬˜&ñvñÊƒ6∆˜6R“ÜVFW"ÊBÜVFW#§fñÊDfó'7D6Üñ∆BÇ&6∆˜6R"ê–¶ñb˜&ñvñÊƒ6∆˜6RFÜV‡–¢˜&ñvñÊƒ6∆˜6RÂfó6ñ&∆R“f«6P–¢˜&ñvñÊƒ6∆˜6R‰7FófR“f«6P–¶VÊ@–†–¢ñbÜVFW"FÜV‡¢∆ˆ6¬÷ñÊñ÷ó¶R“ñÁ7FÊ6RÊÊWrÇ%FWáD'WGFˆ‚"ê¢÷ñÊñ÷ó¶R‰Ê÷R“$÷ñÊñ÷ó¶R ¢÷ñÊñ÷ó¶RÂ6ó¶R“TFñ”"Êg&ˆ‘ˆfg6WBÉ3B¬3Bê¢÷ñÊñ÷ó¶RÂ˜6óFñˆ‚“TFñ”"ÊÊWrÉ¬”3B¬¬ê¢÷ñÊñ÷ó¶R‰&6∂w&˜VÊEG&Á7&VÊ7í“¢÷ñÊñ÷ó¶R‰WFÙ'WGFˆ‰6ˆ∆˜"“f«6P¢÷ñÊñ÷ó¶R‰fˆÁB“VÁV“‰fˆÁB‰v˜FÜ‘&ˆ∆@¢÷ñÊñ÷ó¶RÂFWáB“.(	B ¢÷ñÊñ÷ó¶RÂFWáD6ˆ∆˜#2“6ˆ∆˜#2Êg&ˆ’$t"É#SR¬#SR¬#SRê¢÷ñÊñ÷ó¶RÂFWáE6ó¶R“Ä¢÷ñÊñ÷ó¶RÂ&VÁB“ÜVFW –¢÷ñÊñ÷ó¶R‰÷˜W6T'WGFˆ„6∆ñ6≥§6ˆÊÊV7BÜgVÊ7Fñˆ‚Çí6WD÷VÁUfó6ñ&∆RÜf«6RíVÊBê–¢VÊ&∆TG&rÜ÷ñ‚¬ÜVFW"ê–¶VÊ@–†–¶∆ˆ6¬∆VÊ6ÜW$∆7DG&r“ –¶VÊ&∆TG&rÜ∆VÊ6ÜW"¬∆VÊ6ÜW"¬gVÊ7Fñˆ‚áv4G&vvVBê–¢ñbv4G&vvVBFÜV‚∆VÊ6ÜW$∆7DG&r“˜2Ê6∆ˆ6≤ÇíVÊ@–¶VÊBê–¶∆VÊ6ÜW"‰7FófFVC§6ˆÊÊV7BÜgVÊ7Fñˆ‚Çê–¢ñb˜2Ê6∆ˆ6≤Çí“∆VÊ6ÜW$∆7DG&r¬„#RFÜV‚&WGW&‚VÊ@–¢6WD÷VÁUfó6ñ&∆RáG'VRê–¶VÊBê–†–¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””––¢““F∆Ü˜2FRFV6∆FÚv∆ˆ&ó0–¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””––ßG&6¥6ˆÊÊV7Fñˆ‚ÖW6W$ñÁWE6W'fñ6R‰ñÁWD&Vv„§6ˆÊÊV7BÜgVÊ7Fñˆ‚ÜñÁWB¬v÷U&ˆ6W76VBê¢ñbFW7G&˜ñVB˜"v÷U&ˆ6W76VB˜"W6W$ñÁWE6W'fñ6S§vWDfˆ7W6VEFWáD&˜ÇÇíFÜV‚&WGW&‚VÊ@–†–¢ñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFRÂbFÜV‡–¢f«ïFˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜Bf«îVÊ&∆VBê–¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFR‰¬FÜV‡–¢W7Fˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜BW7VÊ&∆VBê–¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFRÂFÜV‡–¢ñÊfñÊóFTßV◊Fˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜BñÊfñÊóFTßV◊ê–¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFRÂBFÜV‡–¢vófT6∆ñ6µFV∆W˜'EFˆˆ¬Çê–¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFR‰"FÜV‡–¢&ˆ˜7EFˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜B&ˆ˜7D7FófRê–¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFR‰∂WóDˆÊRFÜV‡–¢FV∆W˜'EFÙ6ÜV6∑ˆñÁBÉê–¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFR‰∂WóEGvÚFÜV‡–¢FV∆W˜'EFÙ6ÜV6∑ˆñÁBÉ"ê–¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFR‰∂WóEFá&VRFÜV‡–¢FV∆W˜'EFÙ6ÜV6∑ˆñÁBÉ2ê–¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFR‰≤FÜV‡¢6WD÷VÁUfó6ñ&∆RÜÊ˜B÷VÁTwVí‰VÊ&∆VBê¢V«6VñbñÁWB‰∂Wî6ˆFR”“VÁV“‰∂Wî6ˆFRÂÇFÜV‡¢FW7G&˜îÊ˜Fá&ñ∆ÚÇê¢VÊ@¶VÊBíê†–¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””––¢““FW7G'Vú:|:6Ú∆ñ◊–¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””––¶∆ˆ6¬'VÊÊñÊr“G'VP–¶FW7G&˜îÊ˜Fá&ñ∆Ú“gVÊ7Fñˆ‚Çê–¢ñbFW7G&˜ñVBFÜV‚&WGW&‚VÊ@–¢FW7G&˜ñVB“G'VP¢'VÊÊñÊr“f«6P¢∂ñ∆∆W$7FófR“f«6P¢∂ñ∆∆W%6W76ñˆ‚“∂ñ∆∆W%6W76ñˆ‚≤¢ñÊfñÊóFTßV◊“f«6P†¢f∂T∆u6W76ñˆ‚“f∂T∆u6W76ñˆ‚≤¢&W7F˜&Tf∂T∆rÇê¢7F˜7ñ‚áG'VRê¢7F˜7V7FFRáG'VRê¢7F˜g&VV6“Çê†¢Êˆ6∆óVÊ&∆VB“f«6P¢&W7F˜&TÊˆ6∆óÇê¢ñÁfó4VÊ&∆VB“f«6P¢6WD∆ˆ6ƒñÁfó6ñ&∆RÜf«6Rê†¢vˆDVÊ&∆VB“f«6P¢ñbvˆE&W7v‰6ˆÊ‚FÜV‚vˆE&W7v‰6ˆÊ„§Fó66ˆÊÊV7BÇì≤vˆE&W7v‰6ˆÊ‚“Êñ¬VÊ@¢&W7F˜&TvˆDáV÷ÊˆñBÇê†¢ÁFîf¥VÊ&∆VB“f«6P¢ñbÁFîf¥6ˆÊ‚FÜV‚ÁFîf¥6ˆÊ„§Fó66ˆÊÊV7BÇì≤ÁFîf¥6ˆÊ‚“Êñ¬VÊ@†¢7F˜f«íÇê¢7F˜&ˆ˜7BÇê–¢W7VÊ&∆VB“f«6P–¢W76W76ñˆ‚“W76W76ñˆ‚≤–¢6∆V$U5Çê–¢7F&ñ∆ó¶W"ÊVÊ&∆VB“f«6P–¢6∆VÁW7F&ñ∆ó¶W"Çê–¢&W7F˜&UÊñ57F˜Çê–¢v˜&∑76R‰w&fóGí“˜&ñvñÊƒw&fóGê†–¢ñbÁFîf∆ó6ˆÊ‚FÜV‚ÁFîf∆ó6ˆÊ„§Fó66ˆÊÊV7BÇíÁFîf∆ó6ˆÊ‚“Êñ¬VÊ@–¢ñbWFˆ'&∂T6ˆÊ‚FÜV‚WFˆ'&∂T6ˆÊ„§Fó66ˆÊÊV7BÇíWFˆ'&∂T6ˆÊ‚“Êñ¬VÊ@–¢7FófT6÷W&÷ˆFR“Êñ¿¢&W7F˜&TFVfV«D6÷W&Çê†¢f˜"ñÊFWÇ“7'VÁFñ÷T6ˆÊÊV7FñˆÁ2¬¬”F¢∆ˆ6¬6ˆÊÊV7Fñˆ‚“'VÁFñ÷T6ˆÊÊV7FñˆÁ5∂ñÊFWÖ–¢6∆¬ÜgVÊ7Fñˆ‚Çí6ˆÊÊV7Fñˆ„§Fó66ˆÊÊV7BÇíVÊBê¢'VÁFñ÷T6ˆÊÊV7FñˆÁ5∂ñÊFWÖ““Êñ¿¢VÊ@†¢f˜"ñÊFWÇ“67&VFVEFˆˆ«2¬¬”F¢∆ˆ6¬Fˆˆ¬“7&VFVEFˆˆ«5∂ñÊFWÖ–¢ñbFˆˆ¬ÊBFˆˆ¬Â&VÁBFÜV‚Fˆˆ√§FW7G&˜íÇíVÊ@¢7&VFVEFˆˆ«5∂ñÊFWÖ““Êñ¿¢VÊ@†¢ñbf«î÷ˆ&ñ∆TwVíÊBf«î÷ˆ&ñ∆TwVíÂ&VÁBFÜV‚f«î÷ˆ&ñ∆TwVì§FW7G&˜íÇíVÊ@¢ñbFˆ7DwVíÊBFˆ7DwVíÂ&VÁBFÜV‚Fˆ7DwVì§FW7G&˜íÇíVÊ@–¢ñb∆VÊ6ÜW$wVíÊB∆VÊ6ÜW$wVíÂ&VÁBFÜV‚∆VÊ6ÜW$wVì§FW7G&˜íÇíVÊ@–¢ñb÷VÁTwVíÊB÷VÁTwVíÂ&VÁBFÜV‚÷VÁTwVì§FW7G&˜íÇíVÊ@–¢ñb'VÁFñ÷RÊB'VÁFñ÷RÂ&VÁBFÜV‚'VÁFñ÷S§FW7G&˜íÇíVÊ@–¶VÊ@–†–¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””–¢““$¢6ˆ÷ÊF˜2ÜF∆Ü˜2∆ó7FF˜2ê–¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””––¶∆ˆ6¬6ˆ÷÷ÊG56V7Fñˆ‚“vñÊF˜s§ÊWuF"Ç$6ˆ÷ÊF˜2"ì§ÊWu6V7Fñˆ‚Ç$F∆Ü˜2"ê¶6ˆ÷÷ÊG5F$'WGFˆ‚“÷VÁTwVì§fñÊDfó'7D6Üñ∆BÇ$6ˆ÷ÊF˜5F$'WGFˆ‚"¬G'VRê†–§6ˆ÷÷ÊG56V7Fñˆ„§ÊWt'WGFˆ‚Ç%b(
"fˆÚFÚf\:÷7V∆Ú"¬%FV6∆b"¬gVÊ7Fñˆ‚Çíf«ïFˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜Bf«îVÊ&∆VBíVÊBê–§6ˆ÷÷ÊG56V7Fñˆ„§ÊWt'WGFˆ‚Ç$¬(
"U5"¬%FV6∆¬"¬gVÊ7Fñˆ‚ÇíW7Fˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜BW7VÊ&∆VBíVÊBê–§6ˆ÷÷ÊG56V7Fñˆ„§ÊWt'WGFˆ‚Ç%(
"V∆ÚñÊfñÊóFÚ"¬%FV6∆"¬gVÊ7Fñˆ‚ÇíñÊfñÊóFTßV◊Fˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜BñÊfñÊóFTßV◊íVÊBê–§6ˆ÷÷ÊG56V7Fñˆ„§ÊWt'WGFˆ‚Ç%B(
"FV∆W˜'FR˜"6∆óVR"¬%FV6∆B"¬vófT6∆ñ6µFV∆W˜'EFˆˆ¬ê–§6ˆ÷÷ÊG56V7Fñˆ„§ÊWt'WGFˆ‚Ç$"(
"&ˆ˜7BFÚ6'&ñÊÜÚ"¬%FV6∆""¬gVÊ7Fñˆ‚Çí&ˆ˜7EFˆvv∆T6ˆÁG&ˆ√•WFFUFˆvv∆RÜÊñ¬¬Ê˜B&ˆ˜7D7FófRíVÊBê–§6ˆ÷÷ÊG56V7Fñˆ„§ÊWt'WGFˆ‚Ç$ÁV’BÛ"Û2(
"6ÜV6∑ˆñÁG2"¬%FV6∆FÚÁV‹:ó&ñ6Ú"¬gVÊ7Fñˆ‚Çê–¢Ê˜FñgíÇ$6ÜV6∑ˆñÁG2"¬%W6RÁV’B¬"˜R2‚"ê–¶VÊBê–§6ˆ÷÷ÊG56V7Fñˆ„§ÊWt'WGFˆ‚Ç$≤(
"÷ñÊñ÷ó¶"Ú'&ó""¬%FV6∆≤"¬gVÊ7Fñˆ‚Çí6WD÷VÁUfó6ñ&∆RÜf«6RíVÊBê–§6ˆ÷÷ÊG56V7Fñˆ„§ÊWt'WGFˆ‚Ç%Ç(
"fV6Ü"ÚÊ˜Fá&ñ∆Ú"¬%FV6∆Ç"¬FW7G&˜îÊ˜Fá&ñ∆Úê–†–¶FE6Ü˜'F7WD&FvRÇ%b(
"fˆÚFÚf\:÷7V∆Ú"¬%b"ê–¶FE6Ü˜'F7WD&FvRÇ$¬(
"U5"¬$¬"ê–¶FE6Ü˜'F7WD&FvRÇ%(
"V∆ÚñÊfñÊóFÚ"¬%"ê–¶FE6Ü˜'F7WD&FvRÇ%B(
"FV∆W˜'FR˜"6∆óVR"¬%B"ê–¶FE6Ü˜'F7WD&FvRÇ$"(
"&ˆ˜7BFÚ6'&ñÊÜÚ"¬$""ê–¶FE6Ü˜'F7WD&FvRÇ$ÁV’BÛ"Û2(
"6ÜV6∑ˆñÁG2"¬#Û"Û2"ê–¶FE6Ü˜'F7WD&FvRÇ$≤(
"÷ñÊñ÷ó¶"Ú'&ó""¬$≤"ê–¶FE6Ü˜'F7WD&FvRÇ%Ç(
"fV6Ü"ÚÊ˜Fá&ñ∆Ú"¬%Ç"ê–†–ßF6≤ÊFV∆íÉ„2¬gVÊ7Fñˆ‚Çê–¢ñbÊ˜B÷VÁTwVí˜"Ê˜B÷VÁTwVíÂ&VÁBFÜV‚&WGW&‚VÊ@–¢FE6Ü˜'F7WD&FvRÇ%b(
"fˆÚFÚf\:÷7V∆Ú"¬%b"ê–¢FE6Ü˜'F7WD&FvRÇ$¬(
"U5"¬$¬"ê–¢FE6Ü˜'F7WD&FvRÇ%(
"V∆ÚñÊfñÊóFÚ"¬%"ê–¢FE6Ü˜'F7WD&FvRÇ%B(
"FV∆W˜'FR˜"6∆óVR"¬%B"ê–¢FE6Ü˜'F7WD&FvRÇ$"(
"&ˆ˜7BFÚ6'&ñÊÜÚ"¬$""ê–¢FE6Ü˜'F7WD&FvRÇ$ÁV’BÛ"Û2(
"6ÜV6∑ˆñÁG2"¬#Û"Û2"ê–¢FE6Ü˜'F7WD&FvRÇ$≤(
"÷ñÊñ÷ó¶"Ú'&ó""¬$≤"ê–¢FE6Ü˜'F7WD&FvRÇ%Ç(
"fV6Ü"ÚÊ˜Fá&ñ∆Ú"¬%Ç"ê–¶VÊBê–†–¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””––¢““$¢ñÁFW&f6P–¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””––¶∆ˆ6¬wVï6V7Fñˆ‚“vñÊF˜s§ÊWuF"Ç$ñÁFW&f6R"ì§ÊWu6V7Fñˆ‚Ç$ñÁFW&f6R"ê†–§wVï6V7Fñˆ„§ÊWt'WGFˆ‚Ç$fV6Ü"÷VÁR"¬$fV6Üv˜&≤FV6∆ÇF÷,:ñ“gVÊ6ñˆÊ‚"¬FW7G&˜îÊ˜Fá&ñ∆Úê¶FE6Ü˜'F7WD&FvRÇ$fV6Ü"÷VÁR"¬%Ç"ê†¢““V&∆ñ6:|:6ÚL;F÷ñ6¢¶ÊV∆<;2&V6RFWˆó2VRFˆF22&2¬6ˆ÷ÊF˜2P¢““∆ó7FVÊW'2W'FVÊ6VÁFW2W7FvW&:|:6ÚFW&÷ñÊ&“FR6W"÷ˆÁFF˜2‡¶ñbÊ˜B&ˆ˜G7G&∆ófRÇíFÜV‡¢&˜'D&ˆ˜G7G&Çê¢&WGW&‡¶VÊ@¶÷VÁTwVí‰VÊ&∆VB“f«6P¶ñb˜2Ê6∆ˆ6≤Çí¬7F'GWÊ&Vv‰B≤7F'GWÁ6V6ˆÊG2FÜV‡¢ñb7F'GWÁ7FGW2FÜV‚7F'GWÁ7FGW2ÂFWáB“$gVÏ:|;VW2&ˆÁF2(
"FW&÷ñÊÊFÚ6'&Vv÷VÁFÚ6VwW&Ú‚‚‚"VÊ@¢&WV@¢'VÂ6W'fñ6RÂ&VÊFW%7FWVC•vóBÇê¢ñbÊ˜B&ˆ˜G7G&∆ófRÇíFÜV‡¢&˜'D&ˆ˜G7G&Çê¢&WGW&‡¢VÊ@¢VÁFñ¬˜2Ê6∆ˆ6≤Çí„“7F'GWÊ&Vv‰B≤7F'GWÁ6V6ˆÊG0¶VÊ@¶ñb7F'GWÊwVíÊB7F'GWÊwVíÂ&VÁBFÜV‚7F'GWÊwVì§FW7G&˜íÇíVÊ@¶÷VÁTwVí‰VÊ&∆VB“G'VP†¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””–¢““∆ˆ˜$t ¢““””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””””––ßF6≤Á7v‚ÜgVÊ7Fñˆ‚Çê–¢vÜñ∆R'VÊÊñÊrÊBÊ˜BFW7G&˜ñVBÊB÷VÁTwVíÂ&VÁBÊB∆VÊ6ÜW$wVíÂ&VÁBF–¢∆ˆ6¬&v"“6ˆ∆˜#2Êg&ˆ‘Ö5bÇÜ˜2Ê6∆ˆ6≤Çí¢„"íR¬„ÉR¬ê–¢6∆76ñ5Tì§6ÜÊvT6ˆ∆˜"Ç%66ÜV÷T6ˆ∆˜""¬&v"ê¢ñb6ˆ÷÷ÊG5F$'WGFˆ‚ÊB6ˆ÷÷ÊG5F$'WGFˆ‚Â&VÁBFÜV‡–¢6ˆ÷÷ÊG5F$'WGFˆ‚‰&6∂w&˜VÊD6ˆ∆˜#2“&v –¢VÊ@–¢∆VÊ6ÜW%7G&ˆ∂R‰6ˆ∆˜"“&v –¢∆VÊ6ÜW$ñ6ˆ‚ÂFWáD6ˆ∆˜#2“&v –¢f˜"í“67W7Fˆ‘∂Wñ&ñÊDñ6ˆÁ2¬¬”F–¢∆ˆ6¬ñ6ˆ‚“7W7Fˆ‘∂Wñ&ñÊDñ6ˆÁ5∂ï––¢ñbñ6ˆ‚ÊBñ6ˆ‚Â&VÁBFÜV‚ñ6ˆ‚ÂFWáD6ˆ∆˜#2“&v –¢V«6RF&∆RÁ&V÷˜fRÜ7W7Fˆ‘∂Wñ&ñÊDñ6ˆÁ2¬ííVÊ@–¢VÊ@–¢f˜"í“7Fˆ7E7G&ˆ∂W2¬¬”F–¢∆ˆ6¬7G&ˆ∂R“Fˆ7E7G&ˆ∂W5∂ï––¢ñb7G&ˆ∂RÊB7G&ˆ∂RÂ&VÁBFÜV‚7G&ˆ∂R‰6ˆ∆˜"“&v –¢V«6RF&∆RÁ&V÷˜fRáFˆ7E7G&ˆ∂W2¬ííVÊ@–¢VÊ@–¢F6≤ÁvóBÉ„3ê–¢VÊ@–¶VÊBê–†–¶Ê˜FñgíÑ‘TÂUÙ‰‘R¬$fVóFÚ˜"6fW¶¬(
"≤÷ñÊñ÷ó¶R&V'&RÚ÷VÁR‚"ê†