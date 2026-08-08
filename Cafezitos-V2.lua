Exit code: 0
Wall time: 0.8 seconds
Total output lines: 2497
Output:
-- =============================================================================
-- Cafezitos V2 â˜• â€” Menu completo por Cafezl
-- VersÃ£o auditada: bugs corrigidos + novas funÃ§Ãµes
-- =============================================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local StarterGui     = game:GetService("StarterGui")

local LocalPlayer  = Players.LocalPlayer
local MENU_NAME    = "Cafezitos V2 â˜•"
local UI_TITLE     = MENU_NAME .. " | Feito por Cafezl"
-- PlayerGui funciona no Roblox Studio, no PC e no celular sem depender de executor.
local CoreGui      = LocalPlayer:WaitForChild("PlayerGui")
local originalGravity = workspace.Gravity
local destroyNothrilo

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
    SchemeColor  = Color3.fromRGB(239, 180, 112), -- caramelo cremoso
    Background   = Color3.fromRGB(66, 41, 33),    -- cappuccino
    Header       = Color3.fromRGB(108, 67, 49),   -- espuma de mocha
    TextColor    = Color3.fromRGB(255, 246, 232), -- leite quente
    ElementColor = Color3.fromRGB(121, 76, 56),   -- doce de leite
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
    card.Size            = UDim2.fromOffset(390, 150)
    card.BackgroundColor3 = Color3.fromRGB(43, 26, 19)
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
    titleL.Position  = UDim2.fromOffset(92, 27)
    titleL.Size      = UDim2.new(1, -116, 0, 24)
    titleL.Font      = Enum.Font.GothamBold
    titleL.Text      = MENU_NAME
    titleL.TextColor3 = Color3.fromRGB(248, 248, 250)
    titleL.TextSize  = 18
    titleL.TextXAlignment = Enum.TextXAlignment.Left
    titleL.Parent    = card

    local subtitleL = Instance.new("TextLabel")
    subtitleL.BackgroundTransparency = 1
    subtitleL.Position  = UDim2.fromOffset(92, 55)
    subtitleL.Size      = UDim2.new(1, -116, 0, 18)
    subtitleL.Font      = Enum.Font.Gotham
    subtitleL.Text      = "Feito por Cafezl"
    subtitleL.TextColor3 = Color3.fromRGB(205, 205, 214)
    subtitleL.TextSize  = 13
    subtitleL.TextXAlignment = Enum.TextXAlignment.Left
    subtitleL.Parent    = card

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Position  = UDim2.fromOffset(92, 82)
    status.Size      = UDim2.new(1, -116, 0, 16)
    status.Font      = Enum.Font.Gotham
    status.Text      = "Carregando menu..."
    status.TextColor3 = Theme.SchemeColor
    status.TextSize  = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent    = card

    local cup = Instance.new("TextLabel")
    cup.BackgroundTransparency = 1
    cup.Position = UDim2.fromOffset(26, 48)
    cup.Size = UDim2.fromOffset(50, 50)
    cup.Text = "â˜•"
    cup.Font = Enum.Font.GothamBlack
    cup.TextSize = 36
    cup.TextColor3 = Theme.SchemeColor
    cup.Parent = card

    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(92, 111)
    track.Size = UDim2.new(1, -122, 0, 7)
    track.BackgroundColor3 = Color3.fromRGB(79, 48, 34)
    track.BorderSizePixel = 0
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local crema = Instance.new("Frame")
    crema.Size = UDim2.new(0.14, 0, 1, 0)
    crema.BackgroundColor3 = Theme.SchemeColor
    crema.BorderSizePixel = 0
    crema.Parent = track
    Instance.new("UICorner", crema).CornerRadius = UDim.new(1, 0)

    for index = 1, 3 do
        local steam = Instance.new("Frame")
        steam.AnchorPoint = Vector2.new(0.5, 0.5)
        steam.Position = UDim2.fromOffset(39 + index * 10, 45)
        steam.Size = UDim2.fromOffset(5, 10)
        steam.BackgroundColor3 = Color3.fromRGB(255, 233, 204)
        steam.BackgroundTransparency = 0.4
        steam.BorderSizePixel = 0
        steam.Parent = card
        Instance.new("UICorner", steam).CornerRadius = UDim.new(1, 0)
        local animation = TweenService:Create(steam, TweenInfo.new(1.05 + index * 0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, -1, true), {
            Position = UDim2.fromOffset(36 + index * 12, 23), BackgroundTransparency = 1,
        })
        animation:Play()
    end
    TweenService:Create(crema, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Size = UDim2.new(0.92, 0, 1, 0),
    }):Play()

    return gui, status
end

-- =============================================================================
-- CAFÃ‰ UI â€” interface prÃ³pria, responsiva para PC e celular
-- =============================================================================
local CafeUI = { accent = Theme.SchemeColor, accentObjects = {} }

local function ui(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties or {}) do object[property] = value end
    object.Parent = parent
    return object
end

local function corner(parent, radius)
    return ui("UICorner", { CornerRadius = UDim.new(0, radius or 12) }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return ui("UIStroke", {
        Color = color or Color3.fromRGB(111, 72, 47),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, parent)
end

local function addPadding(parent, pixels)
    return ui("UIPadding", {
        PaddingLeft = UDim.new(0, pixels), PaddingRight = UDim.new(0, pixels),
        PaddingTop = UDim.new(0, pixels), PaddingBottom = UDim.new(0, pixels),
    }, parent)
end

local function tween(object, duration, properties)
    return TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
end

function CafeUI:trackAccent(object, property)
    table.insert(self.accentObjects, { object = object, property = property })
    object[property] = self.accent
end

function CafeUI:ChangeColor(_, color)
    self.accent = color
    for index = #self.accentObjects, 1, -1 do
        local item = self.accentObjects[index]
        if item.object and item.object.Parent then item.object[item.property] = color
        else table.remove(self.accentObjects, index) end
    end
end

function CafeUI.CreateLib(title)
    local gui = ui("ScreenGui", {
        Name = "CafezitosV2UI", ResetOnSpawn = false, IgnoreGuiInset = true,
        DisplayOrder = 10000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, CoreGui)

    local shade = ui("Frame", {
        Name = "CoffeeShade", Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(48, 26, 20), BackgroundTransparency = 0.48,
        BorderSizePixel = 0,
    }, gui)

    local viewport = workspace.CurrentCamera.ViewportSize
    local mobileLayout = UserInputService.TouchEnabled or viewport.X < 700
    local normalSize = mobileLayout and UDim2.fromScale(0.92, 0.72) or UDim2.fromScale(0.64, 0.66)
    local miniSize = mobileLayout and UDim2.fromScale(0.84, 0.54) or UDim2.fromScale(0.48, 0.48)

    local main = ui("Frame", {
        Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = normalSize,
        BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
    }, gui)
    corner(main, 22)
    local mainStroke = stroke(main, Color3.fromRGB(120, 74, 46), 1.5, 0.1)
    CafeUI:trackAccent(mainStroke, "Color")
    ui("UISizeConstraint", {
        MinSize = Vector2.new(285, 330), MaxSize = Vector2.new(780, 570),
    }, main)

    local header = ui("Frame", {
        Name = "MainHeader", Size = UDim2.new(1, 0, 0, 78),
        BackgroundColor3 = Theme.Header, BorderSizePixel = 0,
    }, main)
    corner(header, 22)
    local headerMask = ui("Frame", {
        Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 1, -28),
        BackgroundColor3 = Theme.Header, BorderSizePixel = 0,
    }, header)

    local cup = ui("TextLabel", {
        Name = "Cup", BackgroundTransparency = 1, Position = UDim2.fromOffset(18, 10),
        Size = UDim2.fromOffset(50, 50), Font = Enum.Font.GothamBlack,
        Text = "â˜•", TextSize = 31, TextColor3 = Theme.SchemeColor,
    }, header)
    CafeUI:trackAccent(cup, "TextColor3")
    local titleLabel = ui("TextLabel", {
        Name = "title", BackgroundTransparency = 1, Position = UDim2.fromOffset(72, 12),
        Size = UDim2.new(1, -145, 0, 27), Font = Enum.Font.GothamBold,
        Text = title, TextColor3 = Theme.TextColor, TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    ui("TextLabel", {
        BackgroundTransparency = 1, Position = UDim2.fromOffset(74, 39),
        Size = UDim2.new(1, -145, 0, 18), Font = Enum.Font.Gotham,
        Text = "Cappuccino doce â€¢ simples de usar", TextColor3 = Color3.fromRGB(255, 223, 188),
        TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
    local close = ui("TextButton", {
        Name = "close", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
        Size = UDim2.fromOffset(38, 38), BackgroundColor3 = Color3.fromRGB(94, 48, 34),
        BorderSizePixel = 0, Text = "Ã—", Font = Enum.Font.GothamBold,
        TextColor3 = Theme.TextColor, TextSize = 25,
    }, header)
    corner(close, 12)
    close.Activated:Connect(function() gui:Destroy() end)

    local compact = false
    local resize = ui("TextButton", {
        Name = "CoffeeResize", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -64, 0.5, 0),
        Size = UDim2.fromOffset(38, 38), BackgroundColor3 = Color3.fromRGB(255, 222, 181),
        BorderSizePixel = 0, Text = "â†™", Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(89, 51, 37), TextSize = 20,
    }, header)
    corner(resize, 12)
    resize.Activated:Connect(function()
        compact = not compact
        resize.Text = compact and "â†—" or "â†™"
        tween(main, 0.25, { Size = compact and miniSize or normalSize }):Play()
    end)

    local tabBar = ui("ScrollingFrame", {
        Name = "TabBar", Position = UDim2.fromOffset(12, 90), Size = UDim2.new(1, -24, 0, 45),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.X,
    }, main)
    local tabLayout = ui("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder,
    }, tabBar)

    local pages = ui("Frame", {
        Name = "Pages", Position = UDim2.fromOffset(12, 143), Size = UDim2.new(1, -24, 1, -155),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, main)

    ui("TextLabel", {
        Name = "CoffeeWatermark", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.56),
        Size = UDim2.fromScale(0.9, 0.55), BackgroundTransparency = 1,
        Text = "â˜•  C A F E Z I T O S  â˜•", Font = Enum.Font.GothamBlack,
        TextColor3 = Color3.fromRGB(255, 226, 193), TextTransparency = 0.91,
        TextSize = mobileLayout and 32 or 48, ZIndex = 0,
    }, pages)

    local window = { tabs = {}, activeTab = nil, gui = gui }
    local tabEmoji = {
        ["Jogador"] = "ðŸ§‘", ["Teleporte"] = "ðŸ—ºï¸", ["Carrinho"] = "ðŸš‹",
        ["Cart+"] = "âš¡", ["Extras"] = "âœ¨", ["Mapa"] = "ðŸ§­",
        ["Eliminador"] = "ðŸŽ¯", ["Troll"] = "ðŸŽ­", ["Comandos"] = "â˜•",
        ["Interface"] = "ðŸŽ¨",
    }
    local function showTab(tab)
        for _, other in ipairs(window.tabs) do
            other.page.Visible = other == tab
            other.button.BackgroundColor3 = other == tab and Theme.SchemeColor or Color3.fromRGB(67, 42, 31)
            other.button.TextColor3 = other == tab and Color3.fromRGB(33, 20, 13) or Theme.TextColor
        end
        window.activeTab = tab
    end

    function window:NewTab(name)
        local button = ui("TextButton", {
            Name = name .. "TabButton", Size = UDim2.fromOffset(math.max(96, #name * 9 + 34), 44),
            BackgroundColor3 = Color3.fromRGB(67, 42, 31), BorderSizePixel = 0,
            Text = (tabEmoji[name] or "â˜•") .. " " .. name, Font = Enum.Font.GothamBold, TextColor3 = Theme.TextColor, TextSize = 13,
        }, tabBar)
        corner(button, 12)
        local page = ui("ScrollingFrame", {
            Name = name .. "Page", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.SchemeColor,
            AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false,
        }, pages)
        addPadding(page, 2)
        ui("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, page)
        local tab = { button = button, page = page }
        table.insert(self.tabs, tab)
        button.Activated:Connect(function() showTab(tab) end)
        if #self.tabs == 1 then showTab(tab) end

        function tab:NewSection(sectionName)
            local section = ui("Frame", {
                Name = sectionName .. "Section", Size = UDim2.new(1, -5, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(47, 28, 21), BorderSizePixel = 0,
            }, page)
            corner(section, 16); stroke(section, Color3.fromRGB(112, 70, 46), 1, 0.25); addPadding(section, 10)
            ui("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, section)
            ui("TextLabel", {
                Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = sectionName:upper(),
                Font = Enum.Font.GothamBold, TextColor3 = Theme.SchemeColor, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            }, section)

            local api = {}
            local function card(height, name)
                local frame = ui("Frame", { Name = name or "CafeCard", Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0 }, section)
                corner(frame, 12)
                return frame
            end
            local function labels(frame, label, description)
                local title = ui("TextLabel", { Name = "togName", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, -28, 0, 20), Text = label, Font = Enum.Font.GothamBold, TextColor3 = Theme.TextColor, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left }, frame)
                ui("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 30), Size = UDim2.new(1, -28, 0, 17), Text = description or "", Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255, 220, 185), TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left }, frame)
                return title
            end

            function api:NewButton(label, description, callback)
                local frame = ui("TextButton", { Name = "buttonElement", Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
                corner(frame, 12); labels(frame, label, description)
                local action = ui("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(37, 37), BackgroundColor3 = Theme.SchemeColor, BorderSizePixel = 0, Text = "â€º", Font = Enum.Font.GothamBold, TextColor3 = Theme.Background, TextSize = 26 }, frame)
                corner(action, 10); CafeUI:trackAccent(action, "BackgroundColor3")
                frame.Activated:Connect(function() if callback then callback() end end)
                return frame
            end

            function api:NewToggle(label, description, callback)
                local frame = ui("TextButton", { Name = "toggleElement", Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
                corner(frame, 12); labels(frame, label, description)
                local knob = ui("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(49, 30), BackgroundColor3 = Color3.fromRGB(72, 44, 33), BorderSizePixel = 0 }, frame)
                corner(knob, 14)
                local dot = ui("Frame", { Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(22, 22), BackgroundColor3 = Color3.fromRGB(180, 154, 132), BorderSizePixel = 0 }, knob); corner(dot, 11)
                local state = false
                local control = {}
                function control:UpdateToggle(_, enabled)
                    state = enabled and true or false
                    tween(knob, 0.16, { BackgroundColor3 = state and CafeUI.accent or Color3.fromRGB(38, 24, 18) }):Play()
                    tween(dot, 0.16, { Position = UDim2.fromOffset(state and 20 or 3, 3), BackgroundColor3 = state and Theme.Background or Color3.fromRGB(180, 154, 132) }):Play()
                    if callback then callback(state) end
                end
                frame.Activated:Connect(function() control:UpdateToggle(nil, not state) end)
                return control
            end

            function api:NewTextBox(label, description, callback)
                local frame = ui("TextButton", { Name = "textbox…16411 tokens truncated…n return gui end
        end
    end
    return nil
end

local menuGui = findMenuGui()
local commandsTabButton
if not menuGui then
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
    -- Os badges antigos eram feitos para a Kavo e sobrepunham letras na Cafezitos.
    if menuGui.Name == "CafezitosV2UI" then return end
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
    if menuGui.Name == "CafezitosV2UI" then return end
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
launcher.Name             = "OpenCafezitosMenu"
launcher.Size             = UDim2.fromOffset(62, 62)
launcher.Position         = UDim2.new(0, 18, 0.5, -31)
launcher.BackgroundColor3 = Color3.fromRGB(104, 61, 43)
launcher.BorderSizePixel  = 0
launcher.AutoButtonColor  = false
launcher.Font             = Enum.Font.GothamBold
launcher.Text             = ""
launcher.Visible          = false
launcher.Parent           = launcherGui
Instance.new("UICorner", launcher).CornerRadius = UDim.new(1, 0)

local launcherStroke = Instance.new("UIStroke")
launcherStroke.Thickness = 2.5
launcherStroke.Parent    = launcher

local launcherIcon = Instance.new("TextLabel")
launcherIcon.BackgroundTransparency = 1
launcherIcon.Size     = UDim2.fromScale(1, 1)
launcherIcon.Position = UDim2.fromOffset(0, 0)
launcherIcon.Font     = Enum.Font.GothamBold
launcherIcon.Text     = "â˜•"
launcherIcon.TextSize = 32
launcherIcon.Parent   = launcher

local destroyed = false
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
CommandsSection:NewButton("X  â€¢  Fechar o Cafezitos",   "Tecla X", destroyNothrilo)

addShortcutBadge("V  â€¢  Voo do VeÃ­culo",        "V")
addShortcutBadge("L  â€¢  ESP",                   "L")
addShortcutBadge("P  â€¢  Pulo Infinito",         "P")
addShortcutBadge("T  â€¢  Teleporte por Clique",  "T")
addShortcutBadge("B  â€¢  Boost do Carrinho",     "B")
addShortcutBadge("NumPad 1/2/3  â€¢  Checkpoints","1/2/3")
addShortcutBadge("K  â€¢  Minimizar / Abrir",     "K")
addShortcutBadge("X  â€¢  Fechar o Cafezitos",    "X")

task.delay(0.3, function()
    if not menuGui or not menuGui.Parent then return end
    addShortcutBadge("V  â€¢  Voo do VeÃ­culo",        "V")
    addShortcutBadge("L  â€¢  ESP",                   "L")
    addShortcutBadge("P  â€¢  Pulo Infinito",         "P")
    addShortcutBadge("T  â€¢  Teleporte por Clique",  "T")
    addShortcutBadge("B  â€¢  Boost do Carrinho",     "B")
    addShortcutBadge("NumPad 1/2/3  â€¢  Checkpoints","1/2/3")
    addShortcutBadge("K  â€¢  Minimizar / Abrir",     "K")
    addShortcutBadge("X  â€¢  Fechar o Cafezitos",    "X")
end)

-- =============================================================================
-- ABA: Interface
-- =============================================================================
local GuiTab     = Window:NewTab("Interface")
local GuiSection = GuiTab:NewSection("Interface")

GuiSection:NewKeybind("Fechar Menu", "Tecla X fecha o Cafezitos.", Enum.KeyCode.X, destroyNothrilo)
replaceKeybindLeftIcon("Fechar Menu", "X")
addShortcutBadge("Fechar Menu", "X")

-- =============================================================================
-- Loop RGB
-- =============================================================================
task.spawn(function()
    while running and not destroyed and menuGui.Parent and launcherGui.Parent do
        -- Pulso caramelo: mantÃ©m o tema cafÃ© sem virar arco-Ã­ris.
        local pulse = (math.sin(os.clock() * 1.2) + 1) * 0.5
        local rgb = Color3.fromRGB(
            math.floor(188 + 38 * pulse),
            math.floor(112 + 42 * pulse),
            math.floor(57 + 27 * pulse)
        )
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

