Exit code: 0
Wall time: 0.8 seconds
Output:
-- Cafezitos V2
-- Interface local, leve e feita para PC e celular.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("Cafezitos: rode este menu depois de entrar no jogo.")
    return
end

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, parent = pcall(gethui)
        if ok and parent then
            return parent
        end
    end

    local ok, coreGui = pcall(function()
        return game:GetService("CoreGui")
    end)
    if ok and coreGui then
        local probe = Instance.new("ScreenGui")
        local accepted = pcall(function()
            probe.Parent = coreGui
        end)
        if probe.Parent then
            probe:Destroy()
        end
        if accepted then
            return coreGui
        end
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = getGuiParent()
local oldGui = GuiParent:FindFirstChild("CafezitosV2")
if oldGui then
    oldGui:Destroy()
end

local function make(className, properties, parent)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    object.Parent = parent
    return object
end

local function round(object, radius)
    return make("UICorner", { CornerRadius = UDim.new(0, radius) }, object)
end

local function outline(object, color, thickness, transparency)
    return make("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, object)
end

local coffee = "CAFE"
pcall(function()
    coffee = utf8.char(0x2615)
end)

local colors = {
    cream = Color3.fromRGB(255, 238, 216),
    caramel = Color3.fromRGB(241, 177, 99),
    cocoa = Color3.fromRGB(66, 39, 30),
    mocha = Color3.fromRGB(91, 52, 38),
    dark = Color3.fromRGB(42, 24, 19),
    soft = Color3.fromRGB(255, 214, 170),
}

local gui = make("ScreenGui", {
    Name = "CafezitosV2",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 10000,
}, GuiParent)

local shade = make("Frame", {
    Name = "Shade",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(30, 16, 12),
    BackgroundTransparency = 0.35,
    BorderSizePixel = 0,
}, gui)

local isMobile = UserInputService.TouchEnabled
local main = make("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = isMobile and UDim2.fromScale(0.92, 0.70) or UDim2.fromScale(0.58, 0.62),
    BackgroundColor3 = colors.cocoa,
    BorderSizePixel = 0,
}, gui)
round(main, 22)
outline(main, colors.caramel, 2, 0.05)
make("UISizeConstraint", {
    MinSize = Vector2.new(280, 330),
    MaxSize = Vector2.new(760, 560),
}, main)

local header = make("Frame", {
    Name = "Header",
    Size = UDim2.new(1, 0, 0, 72),
    BackgroundColor3 = colors.mocha,
    BorderSizePixel = 0,
}, main)
round(header, 22)
make("Frame", {
    Size = UDim2.new(1, 0, 0, 22),
    Position = UDim2.new(0, 0, 1, -22),
    BackgroundColor3 = colors.mocha,
    BorderSizePixel = 0,
}, header)

make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(16, 10),
    Size = UDim2.fromOffset(44, 44),
    Font = Enum.Font.GothamBlack,
    Text = coffee,
    TextColor3 = colors.caramel,
    TextSize = 31,
}, header)

make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(66, 12),
    Size = UDim2.new(1, -150, 0, 25),
    Font = Enum.Font.GothamBold,
    Text = "Cafezitos V2",
    TextColor3 = colors.cream,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

make("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.fromOffset(67, 39),
    Size = UDim2.new(1, -150, 0, 17),
    Font = Enum.Font.Gotham,
    Text = "Cappuccino doce - PC e celular",
    TextColor3 = colors.soft,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local function headerButton(text, x)
    local button = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, x, 0.5, 0),
        Size = UDim2.fromOffset(34, 34),
        BackgroundColor3 = colors.dark,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = text,
        TextColor3 = colors.cream,
        TextSize = 21,
    }, header)
    round(button, 10)
    return button
end

local minimize = headerButton("-", -54)
local close = headerButton("x", -15)

local tabs = make("Frame", {
    Name = "Tabs",
    Position = UDim2.fromOffset(12, 84),
    Size = UDim2.new(1, -24, 0, 42),
    BackgroundTransparency = 1,
}, main)
make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, tabs)

local pages = make("Frame", {
    Name = "Pages",
    Position = UDim2.fromOffset(12, 137),
    Size = UDim2.new(1, -24, 1, -149),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
}, main)

local function notify(message)
    local notice = make("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -12),
        Size = UDim2.new(1, -38, 0, 36),
        BackgroundColor3 = colors.dark,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = message,
        TextColor3 = colors.cream,
        TextSize = 13,
        TextWrapped = true,
        TextTransparency = 1,
        ZIndex = 10,
    }, gui)
    round(notice, 11)
    TweenService:Create(notice, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
    task.delay(2.2, function()
        if notice.Parent then
            TweenService:Create(notice, TweenInfo.new(0.18), { TextTransparency = 1 }):Play()
            task.wait(0.2)
            if notice.Parent then notice:Destroy() end
        end
    end)
end

local pageList = {}
local function selectPage(selected)
    for _, other in ipairs(pageList) do
        local active = other == selected
        other.page.Visible = active
        other.tab.BackgroundColor3 = active and colors.caramel or colors.dark
        other.tab.TextColor3 = active and colors.dark or colors.cream
    end
end

local function createPage(name)
    local tab = make("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.fromOffset(105, 42),
        BackgroundColor3 = colors.dark,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = colors.cream,
        TextSize = 13,
    }, tabs)
    round(tab, 12)

    local page = make("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = colors.caramel,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false,
    }, pages)
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 2),
    }, page)
    make("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)

    local entry = { tab = tab, page = page }
    table.insert(pageList, entry)
    tab.Activated:Connect(function()
        selectPage(entry)
    end)
    return page
end

local function addCard(page, title, text, callback)
    local button = make("TextButton", {
        Size = UDim2.new(1, -4, 0, 66),
        BackgroundColor3 = colors.mocha,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.Gotham,
        Text = "",
    }, page)
    round(button, 14)
    outline(button, Color3.fromRGB(133, 78, 54), 1, 0.35)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -61, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = colors.cream,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, button)
    make("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(13, 31),
        Size = UDim2.new(1, -61, 0, 19),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = colors.soft,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, button)
    local arrow = make("TextLabel", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(33, 33),
        BackgroundColor3 = colors.caramel,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Text = ">",
        TextColor3 = colors.dark,
        TextSize = 20,
    }, button)
    round(arrow, 10)
    button.Activated:Connect(function()
        if callback then callback() end
    end)
end

local home = createPage("Inicio")
local playerPage = createPage("Jogador")
local travel = createPage("Mapa")

local welcome = make("TextLabel", {
    Size = UDim2.new(1, -4, 0, 105),
    BackgroundColor3 = colors.mocha,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBold,
    Text = coffee .. "  Bem-vindo ao Cafezitos\n\nUse as abas acima. A bolinha de cafe minimiza e abre o menu.",
    TextColor3 = colors.cream,
    TextSize = 15,
    TextWrapped = true,
}, home)
round(welcome, 16)
outline(welcome, colors.caramel, 1, 0.3)
addCard(home, "Menu leve", "Feito para abrir sem biblioteca externa.", function()
    notify("Cafezitos esta funcionando.")
end)

local function getHumanoid()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Humanoid")
end

addCard(playerPage, "Velocidade normal", "Volta a velocidade para 16.", function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = 16
        notify("Velocidade redefinida.")
    end
end)
addCard(playerPage, "Velocidade 32", "Aumenta a caminhada localmente.", function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = 32
        notify("Velocidade: 32")
    end
end)
addCard(playerPage, "Pular", "Faz o personagem pular uma vez.", function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

addCard(travel, "Ir para o spawn", "Procura um SpawnLocation no mapa.", function()
    local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if spawn and root then
        root.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
        notify("Teleportado para o spawn.")
    else
        notify("Nao achei um SpawnLocation neste mapa.")
    end
end)
addCard(travel, "Resetar personagem", "Volta para o ponto inicial do jogo.", function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.Health = 0
    end
end)

selectPage(pageList[1])

local launcher = make("TextButton", {
    Name = "CoffeeLauncher",
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 18, 0.5, 0),
    Size = UDim2.fromOffset(58, 58),
    BackgroundColor3 = colors.mocha,
    BorderSizePixel = 0,
    Font = Enum.Font.GothamBlack,
    Text = coffee,
    TextColor3 = colors.caramel,
    TextSize = 31,
    Visible = false,
}, gui)
round(launcher, 29)
outline(launcher, colors.caramel, 2, 0)

local function setVisible(visible)
    main.Visible = visible
    shade.Visible = visible
    launcher.Visible = not visible
end

minimize.Activated:Connect(function()
    setVisible(false)
end)
close.Activated:Connect(function()
    setVisible(false)
end)
launcher.Activated:Connect(function()
    setVisible(true)
end)

local dragging = false
local dragInput
local dragStart
local startPosition
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

notify("Cafezitos pronto. Use o botao de cafe para minimizar.")

