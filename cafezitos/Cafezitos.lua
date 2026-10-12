-- =============================================================================
-- Cafezitos V3 ☕ — Menu completo por Cafezl | SEM KEY
-- Aba Poema primeira (esquerda) e aberta ao iniciar.
-- Commitar em: cafezitos/Cafezitos.lua
-- =============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local suiteGuard = { environment = _G }
if type(getgenv) == "function" then
local ok, env = pcall(getgenv)
if ok and type(env) == "table" then suiteGuard.environment = env end
end
suiteGuard.generation = (tonumber(suiteGuard.environment.__CafezlSuiteGeneration) or 0) + 1
if not pcall(function() suiteGuard.environment.__CafezlSuiteGeneration = suiteGuard.generation end) then
suiteGuard.environment = _G
suiteGuard.generation = (tonumber(_G.__CafezlSuiteGeneration) or 0) + 1
_G.__CafezlSuiteGeneration = suiteGuard.generation
end
local function isCurrentSuiteGeneration() return suiteGuard.environment.__CafezlSuiteGeneration == suiteGuard.generation end
do
local deadline = os.clock() + 10
while not LocalPlayer and os.clock() < deadline do
if not isCurrentSuiteGeneration() then return end
task.wait(0.05); LocalPlayer = Players.LocalPlayer
end
if not LocalPlayer then error("Cafezitos: jogador local indisponível.") end
end
local MENU_NAME = "Cafezitos V3 ☕"
local UI_TITLE = MENU_NAME .. " | Feito por Cafezl"
local function getGuiParent()
local function usable(root)
if typeof(root) ~= "Instance" then return nil end
local probe = Instance.new("ScreenGui")
local ok = pcall(function() probe.Parent = root end)
local accepted = ok and probe.Parent == root
probe:Destroy()
return accepted and root or nil
end
if type(gethui) == "function" then
local ok, parent = pcall(gethui)
if ok then local r = usable(parent) if r then return r end end
end
local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
if ok and coreGui then local r = usable(coreGui) if r then return r end end
local playerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
local r = usable(playerGui)
if r then return r end
error("Cafezitos: sem local permitido para a interface.")
end
local CoreGui = getGuiParent()
if not isCurrentSuiteGeneration() then return end
local guiRoots, guiRootSet = {}, {}
local function addGuiRoot(root) if root and not guiRootSet[root] then guiRootSet[root] = true table.insert(guiRoots, root) end end
addGuiRoot(CoreGui)
pcall(function() addGuiRoot(game:GetService("CoreGui")) end)
addGuiRoot(LocalPlayer:FindFirstChild("PlayerGui"))
local destroyCafezitos, setMenuVisible
local destroyed = false
local runtimeConnections = {}
local function trackConnection(c) if c then table.insert(runtimeConnections, c) end return c end
local function disconnectRuntimeConnections()
for i = #runtimeConnections, 1, -1 do
local c = runtimeConnections[i]
if c then pcall(function() c:Disconnect() end) end
runtimeConnections[i] = nil
end
end
for _, root in ipairs(guiRoots) do
for _, name in ipairs({ "CafezitosRuntime", "NothriloRuntime" }) do
local prev = root:FindFirstChild(name)
if prev then
local clean = prev:FindFirstChild("Cleanup")
if clean and clean:IsA("BindableEvent") then clean:Fire() end
prev:Destroy()
end
end
end
local originalGravity = workspace.Gravity
local runtime = Instance.new("Folder")
runtime.Name = "CafezitosRuntime"; runtime.Parent = CoreGui
local runtimeCleanup = Instance.new("BindableEvent")
runtimeCleanup.Name = "Cleanup"; runtimeCleanup.Parent = runtime
trackConnection(runtimeCleanup.Event:Connect(function()
if destroyCafezitos then destroyCafezitos() return end
destroyed = true; disconnectRuntimeConnections()
if runtime and runtime.Parent then runtime:Destroy() end
end))
local cafeGuiNames = { CafezitosV3UI = true, CafezitosLauncher = true, CafezitosNotifications = true, CafezitosLoading = true, CafezitosMobileFly = true, CafezitosV3HUD = true }
for _, root in ipairs(guiRoots) do
for _, gui in ipairs(root:GetChildren()) do
if gui:IsA("ScreenGui") then
if cafeGuiNames[gui.Name] then gui:Destroy() else
local main = gui:FindFirstChild("Main")
local header = main and main:FindFirstChild("MainHeader")
local title = header and header:FindFirstChild("title")
if title and (title.Text:find("Cafezitos", 1, true) or title.Text:find("Nothrilo", 1, true) or title.Text:find("Desastres", 1, true)) then gui:Destroy() end
end
end
end
end
local Theme = {
SchemeColor = Color3.fromRGB(239, 180, 112),
Background = Color3.fromRGB(66, 41, 33),
Header = Color3.fromRGB(108, 67, 49),
TextColor = Color3.fromRGB(255, 246, 232),
ElementColor = Color3.fromRGB(121, 76, 56),
}
local M = {} -- módulos do Desastres
local offControls = {} -- toggles desligados pelo "Parar tudo"
local function regOff(control) table.insert(offControls, control) return control end
-- =============================================================================
-- Tela de carregamento (sem nenhum som)
-- =============================================================================
local function showStartupCard()
local gui = Instance.new("ScreenGui")
gui.Name = "CafezitosLoading"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 10050; gui.Parent = CoreGui
local card = Instance.new("Frame")
card.AnchorPoint = Vector2.new(0.5,0.5); card.Position = UDim2.fromScale(0.5,0.5); card.Size = UDim2.new(0.9,0,0,150)
card.BackgroundColor3 = Color3.fromRGB(43,26,19); card.BorderSizePixel = 0; card.Parent = gui
local cs = Instance.new("UISizeConstraint"); cs.MinSize = Vector2.new(270,150); cs.MaxSize = Vector2.new(390,150); cs.Parent = card
Instance.new("UICorner", card).CornerRadius = UDim.new(0,16)
local st = Instance.new("UIStroke"); st.Thickness = 1.5; st.Color = Theme.SchemeColor; st.Parent = card
local t = Instance.new("TextLabel"); t.BackgroundTransparency = 1; t.Position = UDim2.fromOffset(92,27); t.Size = UDim2.new(1,-116,0,24)
t.Font = Enum.Font.GothamBold; t.Text = MENU_NAME; t.TextColor3 = Color3.fromRGB(248,248,250); t.TextSize = 18; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = card
local s = Instance.new("TextLabel"); s.BackgroundTransparency = 1; s.Position = UDim2.fromOffset(92,55); s.Size = UDim2.new(1,-116,0,18)
s.Font = Enum.Font.Gotham; s.Text = "Feito por Cafezl • sem key"; s.TextColor3 = Color3.fromRGB(205,205,214); s.TextSize = 13; s.TextXAlignment = Enum.TextXAlignment.Left; s.Parent = card
local status = Instance.new("TextLabel"); status.BackgroundTransparency = 1; status.Position = UDim2.fromOffset(92,82); status.Size = UDim2.new(1,-116,0,16)
status.Font = Enum.Font.Gotham; status.Text = "Carregando menu..."; status.TextColor3 = Theme.SchemeColor; status.TextSize = 12; status.TextXAlignment = Enum.TextXAlignment.Left; status.Parent = card
local cup = Instance.new("TextLabel"); cup.BackgroundTransparency = 1; cup.Position = UDim2.fromOffset(26,48); cup.Size = UDim2.fromOffset(50,50)
cup.Text = "☕"; cup.Font = Enum.Font.GothamBlack; cup.TextSize = 36; cup.TextColor3 = Theme.SchemeColor; cup.Parent = card
local track = Instance.new("Frame"); track.Position = UDim2.fromOffset(92,111); track.Size = UDim2.new(1,-122,0,7)
track.BackgroundColor3 = Color3.fromRGB(79,48,34); track.BorderSizePixel = 0; track.Parent = card
Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
local crema = Instance.new("Frame"); crema.Size = UDim2.new(0.14,0,1,0); crema.BackgroundColor3 = Theme.SchemeColor; crema.BorderSizePixel = 0; crema.Parent = track
Instance.new("UICorner", crema).CornerRadius = UDim.new(1,0)
TweenService:Create(crema, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Size = UDim2.new(0.92,0,1,0) }):Play()
return gui, status
end
-- =============================================================================
-- CAFÉ UI
-- =============================================================================
local CafeUI = { accent = Theme.SchemeColor, accentObjects = {}, traceback = debug and debug.traceback or function(e) return tostring(e) end }
local function ui(cls, props, parent)
local o = Instance.new(cls)
for k, v in pairs(props or {}) do o[k] = v end
o.Parent = parent
return o
end
local function corner(p, r) return ui("UICorner", { CornerRadius = UDim.new(0, r or 12) }, p) end
local function stroke(p, c, th, tr) return ui("UIStroke", { Color = c or Color3.fromRGB(111,72,47), Thickness = th or 1, Transparency = tr or 0 }, p) end
local function addPadding(p, px) return ui("UIPadding", { PaddingLeft = UDim.new(0,px), PaddingRight = UDim.new(0,px), PaddingTop = UDim.new(0,px), PaddingBottom = UDim.new(0,px) }, p) end
local function tween(o, d, props) return TweenService:Create(o, TweenInfo.new(d, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props) end
function CafeUI:trackAccent(o, prop) table.insert(self.accentObjects, { object = o, property = prop }) o[prop] = self.accent end
function CafeUI:ChangeColor(_, color)
self.accent = color
for i = #self.accentObjects, 1, -1 do
local it = self.accentObjects[i]
if it.object and it.object.Parent then it.object[it.property] = color else table.remove(self.accentObjects, i) end
end
end
function CafeUI.CreateLib(title)
local gui = ui("ScreenGui", { Name = "CafezitosV3UI", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 10000, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, CoreGui)
ui("Frame", { Name = "CoffeeShade", Size = UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(48,26,20), BackgroundTransparency = 0.48, BorderSizePixel = 0 }, gui)
local camera = workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local function getResponsiveSizes(vp)
local mobile = vp.X < 700 or vp.Y < 520
return mobile, (mobile and UDim2.fromScale(0.94,0.84) or UDim2.fromScale(0.64,0.66)), (mobile and UDim2.fromScale(0.82,0.62) or UDim2.fromScale(0.48,0.48))
end
local mobileLayout, normalSize, miniSize = getResponsiveSizes(viewport)
local main = ui("Frame", { Name = "Main", AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.5), Size = normalSize, BackgroundColor3 = Theme.Background, BorderSizePixel = 0 }, gui)
corner(main, 22)
local mainStroke = stroke(main, Color3.fromRGB(120,74,46), 1.5, 0.1); CafeUI:trackAccent(mainStroke, "Color")
local sizeConstraint = ui("UISizeConstraint", { MinSize = mobileLayout and Vector2.new(250,270) or Vector2.new(420,350), MaxSize = Vector2.new(780,570) }, main)
local header = ui("Frame", { Name = "MainHeader", Size = UDim2.new(1,0,0,78), BackgroundColor3 = Theme.Header, BorderSizePixel = 0 }, main)
corner(header, 22)
ui("Frame", { Size = UDim2.new(1,0,0,28), Position = UDim2.new(0,0,1,-28), BackgroundColor3 = Theme.Header, BorderSizePixel = 0 }, header)
local cup = ui("TextLabel", { Name = "Cup", BackgroundTransparency = 1, Position = UDim2.fromOffset(18,10), Size = UDim2.fromOffset(50,50), Font = Enum.Font.GothamBlack, Text = "☕", TextSize = 31, TextColor3 = Theme.SchemeColor }, header)
CafeUI:trackAccent(cup, "TextColor3")
ui("TextLabel", { Name = "title", BackgroundTransparency = 1, Position = UDim2.fromOffset(72,12), Size = UDim2.new(1,-145,0,27), Font = Enum.Font.GothamBold, Text = title, TextColor3 = Theme.TextColor, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left }, header)
ui("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(74,39), Size = UDim2.new(1,-145,0,18), Font = Enum.Font.Gotham, Text = "Cappuccino doce • sem key • simples de usar", TextColor3 = Color3.fromRGB(255,223,188), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, header)
local close = ui("TextButton", { Name = "close", AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-18,0.5,0), Size = UDim2.fromOffset(38,38), BackgroundColor3 = Color3.fromRGB(94,48,34), BorderSizePixel = 0, Text = "×", Font = Enum.Font.GothamBold, TextColor3 = Theme.TextColor, TextSize = 25 }, header)
corner(close, 12)
close.Activated:Connect(function() if destroyCafezitos then destroyCafezitos() else gui:Destroy() end end)
local compact = false
local resize = ui("TextButton", { Name = "CoffeeResize", AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-64,0.5,0), Size = UDim2.fromOffset(38,38), BackgroundColor3 = Color3.fromRGB(255,222,181), BorderSizePixel = 0, Text = "↙", Font = Enum.Font.GothamBold, TextColor3 = Color3.fromRGB(89,51,37), TextSize = 20 }, header)
corner(resize, 12)
resize.Activated:Connect(function() compact = not compact resize.Text = compact and "↗" or "↙" tween(main, 0.25, { Size = compact and miniSize or normalSize }):Play() end)
local tabBar = ui("ScrollingFrame", { Name = "TabBar", Position = UDim2.fromOffset(12,90), Size = UDim2.new(1,-24,0,45), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.X }, main)
ui("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,7), SortOrder = Enum.SortOrder.LayoutOrder }, tabBar)
local pages = ui("Frame", { Name = "Pages", Position = UDim2.fromOffset(12,143), Size = UDim2.new(1,-24,1,-155), BackgroundTransparency = 1, BorderSizePixel = 0 }, main)
ui("TextLabel", { Name = "CoffeeWatermark", AnchorPoint = Vector2.new(0.5,0.5), Position = UDim2.fromScale(0.5,0.56), Size = UDim2.fromScale(0.9,0.55), BackgroundTransparency = 1, Text = "☕  C A F E Z I T O S  ☕", Font = Enum.Font.GothamBlack, TextColor3 = Color3.fromRGB(255,226,193), TextTransparency = 0.91, TextSize = mobileLayout and 32 or 48, ZIndex = 0 }, pages)
local function updateResponsiveLayout()
local cam = workspace.CurrentCamera
if not cam then return end
mobileLayout, normalSize, miniSize = getResponsiveSizes(cam.ViewportSize)
sizeConstraint.MinSize = mobileLayout and Vector2.new(250,270) or Vector2.new(420,350)
main.Size = compact and miniSize or normalSize
end
local viewportConnection
local function bindViewportCamera()
if viewportConnection then viewportConnection:Disconnect() viewportConnection = nil end
camera = workspace.CurrentCamera
if camera then viewportConnection = trackConnection(camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveLayout)) updateResponsiveLayout() end
end
bindViewportCamera()
trackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewportCamera))
local window = { tabs = {}, activeTab = nil, gui = gui }
local tabEmoji = { ["Poema"] = "📜", ["Jogador"] = "🧑", ["Teleporte"] = "🗺️", ["Carrinho"] = "🚋", ["Cart+"] = "⚡", ["Fly"] = "🪽", ["Gravidade"] = "🌌", ["Proteção"] = "🛡️", ["Itens"] = "🎒", ["Exploração"] = "🏕️", ["Câmera"] = "📷", ["Eliminador"] = "🎯", ["Troll"] = "🎭", ["Comandos"] = "☕", ["Interface"] = "🎨" }
local function showTab(tab)
for _, other in ipairs(window.tabs) do
other.page.Visible = other == tab
other.button.BackgroundColor3 = other == tab and Theme.SchemeColor or Color3.fromRGB(67,42,31)
other.button.TextColor3 = other == tab and Color3.fromRGB(33,20,13) or Theme.TextColor
end
window.activeTab = tab
end
function window:NewTab(name)
local button = ui("TextButton", { Name = name.."TabButton", Size = UDim2.fromOffset(math.max(96, #name*9+34), 44), BackgroundColor3 = Color3.fromRGB(67,42,31), BorderSizePixel = 0, Text = (tabEmoji[name] or "☕").." "..name, Font = Enum.Font.GothamBold, TextColor3 = Theme.TextColor, TextSize = 13 }, tabBar)
corner(button, 12)
local page = ui("ScrollingFrame", { Name = name.."Page", Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.SchemeColor, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false }, pages)
addPadding(page, 2)
ui("UIListLayout", { Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder }, page)
local tab = { button = button, page = page }
table.insert(self.tabs, tab)
button.Activated:Connect(function() showTab(tab) end)
if #self.tabs == 1 then showTab(tab) end
function tab:NewSection(sectionName)
local section = ui("Frame", { Name = sectionName.."Section", Size = UDim2.new(1,-5,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Color3.fromRGB(47,28,21), BorderSizePixel = 0 }, page)
corner(section, 16); stroke(section, Color3.fromRGB(112,70,46), 1, 0.25); addPadding(section, 10)
ui("UIListLayout", { Padding = UDim.new(0,7), SortOrder = Enum.SortOrder.LayoutOrder }, section)
ui("TextLabel", { Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Text = sectionName:upper(), Font = Enum.Font.GothamBold, TextColor3 = Theme.SchemeColor, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }, section)
local api = {}
local function card(height, name)
local frame = ui("Frame", { Name = name or "CafeCard", Size = UDim2.new(1,0,0,height), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0 }, section)
corner(frame, 12)
return frame
end
local function labels(frame, label, description, rightInset)
rightInset = rightInset or 0
local textWidth = -(28 + rightInset)
local title = ui("TextLabel", { Name = "togName", BackgroundTransparency = 1, Position = UDim2.fromOffset(14,8), Size = UDim2.new(1,textWidth,0,20), Text = label, Font = Enum.Font.GothamBold, TextColor3 = Theme.TextColor, TextSize = 15, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left }, frame)
ui("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14,30), Size = UDim2.new(1,textWidth,0,17), Text = description or "", Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255,220,185), TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left }, frame)
return title
end
function api:NewLabel(text, height)
local lbl = ui("TextLabel", { Size = UDim2.new(1,0,0,height or 30), BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255,220,185), TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left }, section)
local c = {}
function c:SetText(t) if lbl and lbl.Parent then lbl.Text = t end end
return c
end
function api:NewButton(label, description, callback)
local frame = ui("TextButton", { Name = "buttonElement", Size = UDim2.new(1,0,0,62), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
corner(frame, 12); labels(frame, label, description, 108)
local action = ui("TextLabel", { AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-10,0.5,0), Size = UDim2.fromOffset(37,37), BackgroundColor3 = Theme.SchemeColor, BorderSizePixel = 0, Text = "›", Font = Enum.Font.GothamBold, TextColor3 = Theme.Background, TextSize = 26 }, frame)
corner(action, 10); CafeUI:trackAccent(action, "BackgroundColor3")
frame.Activated:Connect(function() if callback then local ok, err = pcall(callback) if not ok then warn(MENU_NAME.." "..label..": "..tostring(err)) end end end)
local c = {}
function c:UpdateButton(t) local tt = frame:FindFirstChild("togName") if tt then tt.Text = t end end
return c
end
function api:NewToggle(label, description, callback)
local frame = ui("TextButton", { Name = "toggleElement", Size = UDim2.new(1,0,0,62), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
corner(frame, 12); labels(frame, label, description, 108)
local knob = ui("Frame", { AnchorPoint = Vector2.new(1,0.5), Position = UDim2.new(1,-10,0.5,0), Size = UDim2.fromOffset(49,30), BackgroundColor3 = Color3.fromRGB(72,44,33), BorderSizePixel = 0 }, frame)
corner(knob, 14)
local dot = ui("Frame", { Position = UDim2.fromOffset(3,3), Size = UDim2.fromOffset(22,22), BackgroundColor3 = Color3.fromRGB(180,154,132), BorderSizePixel = 0 }, knob); corner(dot, 11)
local state = false
local control = {}
function control:UpdateToggle(_, enabled)
state = enabled and true or false
tween(knob, 0.16, { BackgroundColor3 = state and CafeUI.accent or Color3.fromRGB(38,24,18) }):Play()
tween(dot, 0.16, { Position = UDim2.fromOffset(state and 20 or 3, 3), BackgroundColor3 = state and Theme.Background or Color3.fromRGB(180,154,132) }):Play()
if callback then local ok, err = pcall(callback, state) if not ok then warn(MENU_NAME.." "..label..": "..tostring(err)) end end
end
frame.Activated:Connect(function() control:UpdateToggle(nil, not state) end)
return control
end
function api:NewTextBox(label, description, callback)
local frame = ui("TextButton", { Name = "textboxElement", Size = UDim2.new(1,0,0,84), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
corner(frame, 12); labels(frame, label, description, 0)
local input = ui("TextBox", { Position = UDim2.new(0,13,1,-34), Size = UDim2.new(1,-26,0,27), BackgroundColor3 = Color3.fromRGB(78,46,34), BorderSizePixel = 0, PlaceholderText = "Digite aqui...", Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextColor3 = Theme.TextColor, PlaceholderColor3 = Color3.fromRGB(239,196,158), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, frame)
corner(input, 7); addPadding(input, 8)
input.FocusLost:Connect(function(enter) if enter and callback then local ok, err = pcall(callback, input.Text) if not ok then warn(MENU_NAME.." "..label..": "..tostring(err)) end end end)
return input
end
function api:NewSlider(label, description, maximum, minimum, defaultValue, callback)
if type(defaultValue) == "function" then callback = defaultValue defaultValue = minimum end
maximum = maximum or 100; minimum = minimum or 0
local frame = card(84, "sliderElement"); labels(frame, label, description, 72)
local value = math.clamp(tonumber(defaultValue) or minimum, minimum, maximum)
local valueLabel = ui("TextLabel", { Position = UDim2.new(1,-64,0,8), Size = UDim2.fromOffset(50,20), BackgroundTransparency = 1, Text = tostring(value), Font = Enum.Font.GothamBold, TextColor3 = Theme.SchemeColor, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right }, frame)
CafeUI:trackAccent(valueLabel, "TextColor3")
local bar = ui("TextButton", { Position = UDim2.new(0,13,1,-23), Size = UDim2.new(1,-26,0,9), BackgroundColor3 = Color3.fromRGB(78,46,34), BorderSizePixel = 0, Text = "" }, frame); corner(bar, 5)
local range = maximum - minimum
local fill = ui("Frame", { Size = UDim2.new(range ~= 0 and ((value-minimum)/range) or 0, 0, 1, 0), BackgroundColor3 = Theme.SchemeColor, BorderSizePixel = 0 }, bar); corner(fill, 4); CafeUI:trackAccent(fill, "BackgroundColor3")
local dragging = false
local control = {}
function control:SetValue(nextValue, invokeCallback)
nextValue = math.clamp(tonumber(nextValue) or minimum, minimum, maximum)
value = nextValue
fill.Size = UDim2.new(range ~= 0 and ((value-minimum)/range) or 0, 0, 1, 0)
valueLabel.Text = tostring(value)
if invokeCallback ~= false and callback then callback(value) end
end
function control:GetValue() return value end
local function setFrom(input)
if bar.AbsoluteSize.X <= 0 then return end
local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
control:SetValue(math.floor(minimum + range*percent + 0.5), true)
end
bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true setFrom(input) end end)
trackConnection(UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFrom(input) end end))
trackConnection(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end))
return control
end
return api
end
return tab
end
local startSize = mobileLayout and UDim2.fromScale(0.72,0.56) or UDim2.fromScale(0.46,0.46)
main.Size = startSize; main.BackgroundTransparency = 0.2
tween(main, 0.45, { Size = normalSize, BackgroundTransparency = 0 }):Play()
return window
end
local startup = {}
startup.gui, startup.status = showStartupCard()
task.wait()
if destroyed or not runtime.Parent or not isCurrentSuiteGeneration() then return end
local Window
do
local ok, winOrErr = xpcall(function() return CafeUI.CreateLib(UI_TITLE) end, CafeUI.traceback)
if not ok then warn(MENU_NAME.." startup: "..tostring(winOrErr)) return end
Window = winOrErr
end
if Window.gui then Window.gui.Enabled = false end
-- =============================================================================
-- Notificações
-- =============================================================================
local toastGui = Instance.new("ScreenGui")
toastGui.Name = "CafezitosNotifications"; toastGui.ResetOnSpawn = false; toastGui.IgnoreGuiInset = true; toastGui.DisplayOrder = 10001; toastGui.Parent = CoreGui
local toastContainer = Instance.new("Frame")
toastContainer.Name = "ToastContainer"; toastContainer.AnchorPoint = Vector2.new(1,0); toastContainer.Position = UDim2.new(1,-18,0,20); toastContainer.Size = UDim2.fromOffset(300,300); toastContainer.BackgroundTransparency = 1; toastContainer.Parent = toastGui
local toastLayout = Instance.new("UIListLayout"); toastLayout.Padding = UDim.new(0,8); toastLayout.SortOrder = Enum.SortOrder.LayoutOrder; toastLayout.Parent = toastContainer
local toastStrokes = {}
local function notify(title, text)
if not toastContainer or not toastContainer.Parent then warn((title or MENU_NAME)..": "..(text or "")) return end
local card = Instance.new("Frame")
card.Size = UDim2.new(1,0,0,74); card.BackgroundColor3 = Color3.fromRGB(18,18,23); card.BackgroundTransparency = 1; card.BorderSizePixel = 0; card.Parent = toastContainer
Instance.new("UICorner", card).CornerRadius = UDim.new(0,15)
local stk = Instance.new("UIStroke"); stk.Thickness = 1.5; stk.Transparency = 1; stk.Parent = card; table.insert(toastStrokes, stk)
local icon = Instance.new("TextLabel"); icon.Size = UDim2.fromOffset(42,42); icon.Position = UDim2.fromOffset(14,16); icon.BackgroundColor3 = Color3.fromRGB(30,30,37); icon.BackgroundTransparency = 1; icon.Font = Enum.Font.GothamBold; icon.Text = "☕"; icon.TextColor3 = Color3.fromRGB(255,255,255); icon.TextSize = 22; icon.TextTransparency = 1; icon.Parent = card
Instance.new("UICorner", icon).CornerRadius = UDim.new(1,0)
local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(1,-76,0,20); tl.Position = UDim2.fromOffset(68,14); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.Text = title or MENU_NAME; tl.TextColor3 = Color3.fromRGB(250,250,252); tl.TextSize = 14; tl.TextTransparency = 1; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Parent = card
local bl = Instance.new("TextLabel"); bl.Size = UDim2.new(1,-76,0,30); bl.Position = UDim2.fromOffset(68,34); bl.BackgroundTransparency = 1; bl.Font = Enum.Font.Gotham; bl.Text = text or ""; bl.TextColor3 = Color3.fromRGB(185,185,195); bl.TextSize = 12; bl.TextTransparency = 1; bl.TextWrapped = true; bl.TextXAlignment = Enum.TextXAlignment.Left; bl.TextYAlignment = Enum.TextYAlignment.Top; bl.Parent = card
local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
TweenService:Create(card, ti, { BackgroundTransparency = 0 }):Play()
TweenService:Create(stk, TweenInfo.new(0.22), { Transparency = 0.15 }):Play()
TweenService:Create(icon, ti, { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
TweenService:Create(tl, ti, { TextTransparency = 0 }):Play()
TweenService:Create(bl, ti, { TextTransparency = 0 }):Play()
task.delay(4, function()
if not card.Parent then return end
local to = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
TweenService:Create(card, to, { BackgroundTransparency = 1 }):Play()
TweenService:Create(stk, to, { Transparency = 1 }):Play()
TweenService:Create(icon, to, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
TweenService:Create(tl, to, { TextTransparency = 1 }):Play()
TweenService:Create(bl, to, { TextTransparency = 1 }):Play()
task.wait(0.25); card:Destroy()
end)
end
-- =============================================================================
-- Helpers
-- =============================================================================
local cancelAutoWin
local function getCharacter(waitSeconds)
local character = LocalPlayer.Character
if character or not waitSeconds or waitSeconds <= 0 then return character end
local deadline = os.clock() + waitSeconds
repeat task.wait(); character = LocalPlayer.Character until character or destroyed or not isCurrentSuiteGeneration() or os.clock() >= deadline
return character
end
local function getHumanoid(character, waitSeconds)
character = character or getCharacter(waitSeconds)
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if humanoid or not character or not waitSeconds or waitSeconds <= 0 then return humanoid end
local deadline = os.clock() + waitSeconds
repeat task.wait(); humanoid = character:FindFirstChildOfClass("Humanoid") until humanoid or not character.Parent or destroyed or not isCurrentSuiteGeneration() or os.clock() >= deadline
return humanoid
end
local function getRoot(character, waitSeconds)
character = character or getCharacter(waitSeconds)
local root = character and character:FindFirstChild("HumanoidRootPart")
if root or not character or not waitSeconds or waitSeconds <= 0 then return root end
root = character:WaitForChild("HumanoidRootPart", waitSeconds)
return root and root:IsA("BasePart") and root or nil
end
local function teleportCharacter(cframe)
if destroyed or not isCurrentSuiteGeneration() then return false end
local character = getCharacter(2)
local humanoid = getHumanoid(character, 2)
local root = getRoot(character, 2)
if not root or not root.Parent then notify("Teleporte", "HumanoidRootPart não encontrado.") return false end
if humanoid and humanoid.SeatPart then
humanoid.Sit = false
pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
local deadline = os.clock() + 0.6
repeat RunService.Heartbeat:Wait() until not humanoid.Parent or humanoid.SeatPart == nil or destroyed or os.clock() >= deadline
root = getRoot(character, 1)
if not root or not root.Parent then return false end
end
local ok = pcall(function()
local rootOffset = character:GetPivot():ToObjectSpace(root.CFrame)
character:PivotTo(cframe * rootOffset:Inverse())
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end)
if not ok then notify("Teleporte", "Não foi possível concluir o teleporte.") end
return ok
end
local function fallLease(owner, on)
if M.fallProtection then pcall(function() M.fallProtection:SetAutomatic(owner, on) end) end
end
-- =============================================================================
-- Estados do Cart Ride (fly, carrinho, killer, câmera)
-- =============================================================================
local flyEnabled = false
local flyToggleControl, boostToggleControl, panicToggleControl, stopBoost
local espToggleControl, infiniteJumpToggleControl
local infiniteJump = false
local fakeLagActive, fakeLagSession, fakeLagHumanoid = false, 0, nil
local desiredWalkSpeed, desiredJumpPower, desiredJumpHeight
local createdTools = {}
local killerActive, killerSession = false, 0
local cartMotionPauseUntil = 0
local cartFeatureTiming = { antiFlipReadyAt = 0, autobrakeHoldUntil = 0, autobrakeReadyAt = 0 }
local activeCameraMode
local cameraModeStoppers = {}
local cameraBaseline
local FLYING = false
local vehicleFlySpeed = 1
local flySession = 0
local mouse = LocalPlayer:GetMouse()
local flyTouchUp, flyTouchDown = 0, 0
local flyMobileGui
local function captureCameraBaseline()
local camera = workspace.CurrentCamera
if not camera then return end
cameraBaseline = { camera = camera, cameraType = camera.CameraType, cameraSubject = camera.CameraSubject, cframe = camera.CFrame, focus = camera.Focus, fieldOfView = camera.FieldOfView }
end
local function restoreDefaultCamera()
local camera = workspace.CurrentCamera
local baseline = cameraBaseline
cameraBaseline = nil
if not camera then return end
local restored = false
if baseline and baseline.camera == camera then
restored = pcall(function()
camera.CameraType = baseline.cameraType
camera.CFrame = baseline.cframe
camera.Focus = baseline.focus
camera.FieldOfView = baseline.fieldOfView
local subject = baseline.cameraSubject
if subject and subject.Parent then camera.CameraSubject = subject
else local h = getHumanoid() if h then camera.CameraSubject = h end end
end)
end
if not restored then
pcall(function()
camera.CameraType = Enum.CameraType.Custom
local h = getHumanoid()
if h then camera.CameraSubject = h end
end)
end
end
local function claimCameraMode(mode)
if activeCameraMode == mode then return end
local previous = activeCameraMode
if not previous then captureCameraBaseline() end
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
-- ESP
-- =============================================================================
local ESP_TAG = "CafezitosESP"
local espEnabled = false
local espObjects, espPlayerConnections, espGlobalConnections, espSession = {}, {}, {}, 0
local function getESPColor(player)
if player.Team and player.Team.TeamColor then return player.Team.TeamColor.Color end
return Color3.fromRGB(190,130,255)
end
local function removeESP(player)
local objects = espObjects[player]
if not objects then return end
if objects.Billboard and objects.Billboard.Parent then objects.Billboard:Destroy() end
if objects.Highlight and objects.Highlight.Parent then objects.Highlight:Destroy() end
local humanoid, state = objects.Humanoid, objects.DisplayState
if humanoid and humanoid.Parent and state then
pcall(function()
humanoid.DisplayDistanceType = state.DisplayDistanceType
humanoid.NameOcclusion = state.NameOcclusion
humanoid.NameDisplayDistance = state.NameDisplayDistance
humanoid.HealthDisplayDistance = state.HealthDisplayDistance
end)
end
espObjects[player] = nil
end
local function refreshESPColor(player)
local objects = espObjects[player]
if not objects then return end
local color = getESPColor(player)
if objects.Highlight and objects.Highlight.Parent then objects.Highlight.FillColor = color objects.Highlight.OutlineColor = color end
if objects.Label and objects.Label.Parent then objects.Label.TextColor3 = color end
end
local function refreshESPSize(player)
local objects = espObjects[player]
if not objects or not objects.Billboard or not objects.Billboard.Parent then return end
local lc = LocalPlayer.Character
local lr = lc and lc:FindFirstChild("HumanoidRootPart")
local tr = objects.Billboard.Adornee
if not lr or not tr or not tr.Parent then objects.Billboard.Enabled = false return end
local distance = (lr.Position - tr.Position).Magnitude
objects.Billboard.Enabled = true
if objects.Label and objects.Label.Parent then
objects.Label.Text = string.format("%s  •  %d studs", player.DisplayName ~= "" and player.DisplayName or player.Name, math.floor(distance + 0.5))
end
local progress = math.clamp((distance - 150) / 450, 0, 1)
objects.Billboard.Size = UDim2.fromOffset(math.floor(118 + (220-118)*progress), math.floor(18 + (36-18)*progress))
end
local function addESP(player, character)
if not espEnabled or player == LocalPlayer then return end
character = character or player.Character
if not character or not character.Parent then return end
local root = character:FindFirstChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")
if not root or not humanoid then return end
removeESP(player)
local displayState = { DisplayDistanceType = humanoid.DisplayDistanceType, NameOcclusion = humanoid.NameOcclusion, NameDisplayDistance = humanoid.NameDisplayDistance, HealthDisplayDistance = humanoid.HealthDisplayDistance }
pcall(function()
humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion
humanoid.NameDisplayDistance = 0
humanoid.HealthDisplayDistance = 0
end)
local billboard = Instance.new("BillboardGui")
billboard.Name = ESP_TAG.."Name"; billboard.Size = UDim2.fromOffset(118,18); billboard.Enabled = false; billboard.Adornee = root
billboard.AlwaysOnTop = true; billboard.LightInfluence = 0; billboard.MaxDistance = math.huge; billboard.StudsOffset = Vector3.new(0,3.2,0); billboard.Parent = root
local label = Instance.new("TextLabel")
label.Name = "NameLabel"; label.Size = UDim2.fromScale(1,1); label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBold
label.Text = player.DisplayName ~= "" and player.DisplayName or player.Name; label.TextScaled = true
label.TextStrokeColor3 = Color3.fromRGB(0,0,0); label.TextStrokeTransparency = 0; label.Parent = billboard
local highlight = Instance.new("Highlight")
highlight.Name = ESP_TAG; highlight.FillTransparency = 0.5; highlight.OutlineTransparency = 0
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; highlight.Adornee = character; highlight.Parent = character
espObjects[player] = { Billboard = billboard, Label = label, Highlight = highlight, Humanoid = humanoid, DisplayState = displayState }
refreshESPColor(player); refreshESPSize(player)
end
local function disconnectESPPlayer(player)
local conns = espPlayerConnections[player]
if conns then for _, c in ipairs(conns) do c:Disconnect() end end
espPlayerConnections[player] = nil
end
local function watchESPPlayer(player)
if player == LocalPlayer then return end
disconnectESPPlayer(player)
local conns = {}
local watchSession = espSession
espPlayerConnections[player] = conns
table.insert(conns, player.CharacterAdded:Connect(function(character)
character:WaitForChild("HumanoidRootPart", 5)
local deadline = os.clock() + 5
while character.Parent and not character:FindFirstChildOfClass("Humanoid") and os.clock() < deadline do task.wait() end
if destroyed or not espEnabled or watchSession ~= espSession then return end
addESP(player, character)
end))
table.insert(conns, player.CharacterRemoving:Connect(function() removeESP(player) end))
table.insert(conns, player:GetPropertyChangedSignal("Team"):Connect(function() refreshESPColor(player) end))
table.insert(conns, player:GetPropertyChangedSignal("DisplayName"):Connect(function() refreshESPSize(player) end))
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
table.insert(espGlobalConnections, Players.PlayerRemoving:Connect(function(player) removeESP(player) disconnectESPPlayer(player) end))
local session = espSession
task.spawn(function()
while espEnabled and session == espSession do
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LocalPlayer and player.Character then
local objects = espObjects[player]
local valid = objects and objects.Billboard and objects.Billboard.Parent and objects.Highlight and objects.Highlight.Parent
if not valid then removeESP(player) addESP(player, player.Character) else refreshESPSize(player) end
end
end
task.wait(0.25)
end
end)
notify("ESP", "Ligado: nomes e contornos ativos.")
end
-- =============================================================================
-- Fly do carrinho (usado também pelo Eliminador)
-- =============================================================================
local flyKeyDown, flyKeyUp, flyHumanoid, flyAutoRotate, flyPlatformStand, flyRoot, flyBodyGyro, flyBodyVelocity
local flySavedState = { freefall = nil, fallingDown = nil, inputEnabled = true, humanoidModified = false, startedSeated = false }
local function showMobileFlyControls(visible)
if not UserInputService.TouchEnabled then return end
if flyMobileGui and flyMobileGui.Parent then flyMobileGui.Enabled = visible return end
if not visible then return end
local gui = Instance.new("ScreenGui")
gui.Name = "CafezitosMobileFly"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true; gui.DisplayOrder = 10020; gui.Parent = CoreGui
flyMobileGui = gui
local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(1,0.5); panel.Position = UDim2.new(1,-16,0.5,0); panel.Size = UDim2.fromOffset(72,124)
panel.BackgroundColor3 = Color3.fromRGB(10,10,13); panel.BackgroundTransparency = 0.12; panel.BorderSizePixel = 0; panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,14)
local ps = Instance.new("UIStroke", panel); ps.Color = Theme.SchemeColor; ps.Thickness = 1
local tl = Instance.new("TextLabel"); tl.BackgroundTransparency = 1; tl.Position = UDim2.fromOffset(0,6); tl.Size = UDim2.new(1,0,0,18); tl.Font = Enum.Font.GothamBold; tl.Text = "VOO"; tl.TextColor3 = Color3.fromRGB(245,245,245); tl.TextSize = 11; tl.Parent = panel
local function makeBtn(symbol, y, setDir)
local btn = Instance.new("TextButton")
btn.Size = UDim2.fromOffset(52,38); btn.Position = UDim2.new(0.5,-26,0,y); btn.BackgroundColor3 = Color3.fromRGB(28,28,35); btn.BorderSizePixel = 0
btn.AutoButtonColor = false; btn.Font = Enum.Font.GothamBold; btn.Text = symbol; btn.TextColor3 = Theme.SchemeColor; btn.TextSize = 22; btn.Parent = panel
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)
btn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then setDir(1) btn.BackgroundColor3 = Color3.fromRGB(48,48,58) end end)
btn.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then setDir(0) btn.BackgroundColor3 = Color3.fromRGB(28,28,35) end end)
end
makeBtn("▲", 30, function(v) flyTouchUp = v end)
makeBtn("▼", 74, function(v) flyTouchDown = v end)
end
local function stopFly()
flySession = flySession + 1
FLYING = false; flyTouchUp = 0; flyTouchDown = 0
showMobileFlyControls(false)
if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy() end
if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy() end
local function removeNamed(root)
if root and root.Parent then
local g = root:FindFirstChild("CafezitosVehicleFlyGyro")
local v = root:FindFirstChild("CafezitosVehicleFlyVelocity")
if g then g:Destroy() end
if v then v:Destroy() end
end
end
removeNamed(flyRoot)
local currentRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if currentRoot ~= flyRoot then removeNamed(currentRoot) end
local humanoid = flyHumanoid or getHumanoid()
if humanoid and humanoid.Parent and flySavedState.humanoidModified then
if flyPlatformStand ~= nil then humanoid.PlatformStand = flyPlatformStand end
if flyAutoRotate ~= nil then humanoid.AutoRotate = flyAutoRotate end
pcall(function()
humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, flySavedState.freefall == nil and true or flySavedState.freefall)
humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, flySavedState.fallingDown == nil and true or flySavedState.fallingDown)
end)
end
flyHumanoid, flyAutoRotate, flyPlatformStand, flyRoot, flyBodyGyro, flyBodyVelocity = nil, nil, nil, nil, nil, nil
flySavedState.freefall, flySavedState.fallingDown, flySavedState.inputEnabled, flySavedState.humanoidModified, flySavedState.startedSeated = nil, nil, true, false, false
releaseCameraMode("fly")
fallLease("fly", false)
end
local function startVehicleFly(inputEnabled)
stopFly()
local session = flySession
local character = getCharacter(3)
local root = getRoot(character, 3)
local humanoid = getHumanoid(character, 3)
if destroyed or not isCurrentSuiteGeneration() or session ~= flySession or not character or character ~= LocalPlayer.Character or not character.Parent then return false end
if not root or not root.Parent or not humanoid or not humanoid.Parent then notify("Voo do Veículo", "Personagem não encontrado.") return false end
claimCameraMode("fly")
pcall(function() local cam = workspace.CurrentCamera if cam then cam.CameraType = Enum.CameraType.Track end end)
flyHumanoid = humanoid
flyAutoRotate = humanoid.AutoRotate
flyPlatformStand = humanoid.PlatformStand
flySavedState.inputEnabled = inputEnabled ~= false
flySavedState.startedSeated = humanoid.SeatPart ~= nil
pcall(function()
flySavedState.freefall = humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall)
flySavedState.fallingDown = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
end)
flySavedState.humanoidModified = false
local control = { F=0, B=0, L=0, R=0, Q=0, E=0 }
FLYING = true
fallLease("fly", true)
showMobileFlyControls(flySavedState.inputEnabled)
local bodyGyro = Instance.new("BodyGyro")
bodyGyro.Name = "CafezitosVehicleFlyGyro"; bodyGyro.P = 90000; bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9); bodyGyro.CFrame = root.CFrame; bodyGyro.Parent = root
flyRoot = root; flyBodyGyro = bodyGyro
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.Name = "CafezitosVehicleFlyVelocity"; bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9); bodyVelocity.Velocity = Vector3.zero; bodyVelocity.Parent = root
flyBodyVelocity = bodyVelocity
flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
if not flySavedState.inputEnabled or processed or UserInputService:GetFocusedTextBox() then return end
local key = input.KeyCode
if key == Enum.KeyCode.W then control.F = vehicleFlySpeed
elseif key == Enum.KeyCode.S then control.B = -vehicleFlySpeed
elseif key == Enum.KeyCode.A then control.L = -vehicleFlySpeed
elseif key == Enum.KeyCode.D then control.R = vehicleFlySpeed
elseif key == Enum.KeyCode.E then control.Q = vehicleFlySpeed * 2
elseif key == Enum.KeyCode.Q then control.E = -vehicleFlySpeed * 2 end
end)
flyKeyUp = UserInputService.InputEnded:Connect(function(input)
local key = input.KeyCode
if key == Enum.KeyCode.W then control.F = 0
elseif key == Enum.KeyCode.S then control.B = 0
elseif key == Enum.KeyCode.A then control.L = 0
elseif key == Enum.KeyCode.D then control.R = 0
elseif key == Enum.KeyCode.E then control.Q = 0
elseif key == Enum.KeyCode.Q then control.E = 0 end
end)
task.spawn(function()
local boundCamera
while FLYING and session == flySession and root.Parent and humanoid.Parent and bodyGyro.Parent and bodyVelocity.Parent do
task.wait()
if flySavedState.startedSeated and humanoid.SeatPart == nil then break end
local camera = workspace.CurrentCamera
if not camera then break end
if camera ~= boundCamera then boundCamera = camera pcall(function() camera.CameraType = Enum.CameraType.Track end) end
if flySavedState.inputEnabled and UserInputService.KeyboardEnabled then
control.F = UserInputService:IsKeyDown(Enum.KeyCode.W) and vehicleFlySpeed or 0
control.B = UserInputService:IsKeyDown(Enum.KeyCode.S) and -vehicleFlySpeed or 0
control.L = UserInputService:IsKeyDown(Enum.KeyCode.A) and -vehicleFlySpeed or 0
control.R = UserInputService:IsKeyDown(Enum.KeyCode.D) and vehicleFlySpeed or 0
control.Q = UserInputService:IsKeyDown(Enum.KeyCode.E) and vehicleFlySpeed*2 or 0
control.E = UserInputService:IsKeyDown(Enum.KeyCode.Q) and -vehicleFlySpeed*2 or 0
end
local keyboardMoving = flySavedState.inputEnabled and ((control.L + control.R ~= 0) or (control.F + control.B ~= 0) or (control.Q + control.E ~= 0))
local mobileDir = humanoid.MoveDirection
if UserInputService.TouchEnabled and Vector3.new(mobileDir.X,0,mobileDir.Z).Magnitude <= 0.05 then
local seat = humanoid.SeatPart
if seat and seat:IsA("VehicleSeat") then
local flatLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
local flatRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
if flatLook.Magnitude > 0.01 then flatLook = flatLook.Unit end
if flatRight.Magnitude > 0.01 then flatRight = flatRight.Unit end
mobileDir = flatLook * seat.ThrottleFloat + flatRight * seat.SteerFloat
end
end
local mobileMoving = flySavedState.inputEnabled and UserInputService.TouchEnabled and (Vector3.new(mobileDir.X,0,mobileDir.Z).Magnitude > 0.05 or flyTouchUp ~= 0 or flyTouchDown ~= 0)
if keyboardMoving then
local cf = camera.CFrame
local direction = cf.LookVector * (control.F + control.B) + ((cf * CFrame.new(control.L + control.R, (control.F + control.B + control.Q + control.E) * 0.2, 0)).Position - cf.Position)
bodyVelocity.Velocity = direction * 50
elseif mobileMoving then
bodyVelocity.Velocity = Vector3.new(mobileDir.X,0,mobileDir.Z) * (vehicleFlySpeed * 50) + Vector3.new(0, (flyTouchUp - flyTouchDown) * vehicleFlySpeed * 50, 0)
else
bodyVelocity.Velocity = Vector3.zero
end
bodyGyro.CFrame = camera.CFrame
end
if bodyGyro.Parent then bodyGyro:Destroy() end
if bodyVelocity.Parent then bodyVelocity:Destroy() end
if flyBodyGyro == bodyGyro then flyBodyGyro = nil end
if flyBodyVelocity == bodyVelocity then flyBodyVelocity = nil end
if flyRoot == root then flyRoot = nil end
if session == flySession and FLYING then
if flyEnabled and flyToggleControl then flyToggleControl:UpdateToggle(nil, false) else stopFly() end
end
end)
return true
end
cameraModeStoppers.fly = function()
if flyEnabled and flyToggleControl then flyToggleControl:UpdateToggle(nil, false) else stopFly() end
end
-- =============================================================================
-- Carrinho
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
if object:IsA("BasePart") and (not assemblyRoot or object.AssemblyRootPart == assemblyRoot) then
assemblyParts = assemblyParts + 1
if assemblyParts >= 2 then return current end
end
end
end
current = current.Parent
end
return fallback
end
local cartCache = { humanoid = nil, seat = nil, cart = nil, assemblyRoot = nil, primary = nil }
local function clearCurrentCartCache() cartCache.humanoid, cartCache.seat, cartCache.cart, cartCache.assemblyRoot, cartCache.primary = nil, nil, nil, nil, nil end
local function cacheCurrentCart(humanoid, seat)
clearCurrentCartCache()
if not humanoid or not seat or not seat:IsA("BasePart") or not seat.Parent then return nil end
cartCache.humanoid = humanoid; cartCache.seat = seat; cartCache.assemblyRoot = seat.AssemblyRootPart
cartCache.cart = findCartFromSeat(seat)
cartCache.primary = (cartCache.cart and cartCache.cart.PrimaryPart) or cartCache.assemblyRoot
return cartCache.cart
end
local function getCurrentCart()
local humanoid = getHumanoid()
local seat = humanoid and humanoid.SeatPart
if not humanoid or not seat or not seat.Parent then clearCurrentCartCache() return nil end
if cartCache.humanoid == humanoid and cartCache.seat == seat and cartCache.cart and cartCache.cart.Parent and cartCache.cart:IsAncestorOf(seat) and (not cartCache.assemblyRoot or cartCache.assemblyRoot.Parent) and cartCache.assemblyRoot == seat.AssemblyRootPart then return cartCache.cart end
return cacheCurrentCart(humanoid, seat)
end
local function getCartPrimary(cart)
if not cart then return nil end
if cart.PrimaryPart then if cartCache.cart == cart then cartCache.primary = cart.PrimaryPart end return cart.PrimaryPart end
if cartCache.cart == cart and cartCache.primary and cartCache.primary.Parent then return cartCache.primary end
local humanoid = getHumanoid()
local seat = humanoid and humanoid.SeatPart
if seat and cart:IsAncestorOf(seat) and seat.AssemblyRootPart then if cartCache.cart == cart then cartCache.primary = seat.AssemblyRootPart end return seat.AssemblyRootPart end
local firstUnanchored
for _, part in ipairs(cart:GetDescendants()) do
if part:IsA("BasePart") and not part.Anchored then
firstUnanchored = firstUnanchored or part
if part.AssemblyRootPart == part then return part end
end
end
if cartCache.cart == cart then cartCache.primary = firstUnanchored end
return firstUnanchored
end
local panicParts, panicActive = {}, false
local function restorePanicStop()
for part, wasAnchored in pairs(panicParts) do if part and part.Parent then part.Anchored = wasAnchored end end
panicParts = {}; panicActive = false
end
local function setPanicStop(enabled)
if not enabled then restorePanicStop() notify("Carrinho", "Parada de emergência desligada.") return true end
local cart = getCurrentCart()
if not cart then notify("Carrinho", "Sente em um carrinho primeiro.") return false end
if cancelAutoWin then cancelAutoWin(true) end
if killerActive then killerSession = killerSession + 1 killerActive = false end
if flyEnabled and flyToggleControl then flyToggleControl:UpdateToggle(nil, false) else stopFly() end
if stopBoost then stopBoost() end
if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end
restorePanicStop()
panicActive = true
for _, part in ipairs(cart:GetDescendants()) do
if part:IsA("BasePart") then
panicParts[part] = part.Anchored
part.Anchored = true
part.AssemblyLinearVelocity = Vector3.zero
part.AssemblyAngularVelocity = Vector3.zero
end
end
notify("Carrinho", "Parada de emergência ligada.")
return true
end
local function pivotCartByReference(cart, desiredReferenceCFrame)
local reference = getCartPrimary(cart)
if not cart or not reference or not reference.Parent then return false end
return pcall(function()
local referenceOffset = cart:GetPivot():ToObjectSpace(reference.CFrame)
local function stopPart(part) if not part.Anchored then pcall(function() part.AssemblyLinearVelocity = Vector3.zero part.AssemblyAngularVelocity = Vector3.zero end) end end
for _, part in ipairs(cart:GetDescendants()) do if part:IsA("BasePart") then stopPart(part) end end
cart:PivotTo(desiredReferenceCFrame * referenceOffset:Inverse())
for _, part in ipairs(cart:GetDescendants()) do if part:IsA("BasePart") then stopPart(part) end end
end)
end
local function stopCartControllersForTeleport(preserveAutoWin)
if not preserveAutoWin and cancelAutoWin then cancelAutoWin(true) end
cartMotionPauseUntil = os.clock() + 0.3
if killerActive then killerSession = killerSession + 1 killerActive = false end
if flyEnabled and flyToggleControl then flyToggleControl:UpdateToggle(nil, false) else stopFly() end
if stopBoost then stopBoost() end
restorePanicStop()
if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end
if panicToggleControl then task.defer(function() panicToggleControl:UpdateToggle(nil, false) end) end
end
local function teleportCart(cframe)
local cart = getCurrentCart()
if not cart then notify("Carrinho", "Sente em um carrinho primeiro.") return false end
stopCartControllersForTeleport()
local ok = pivotCartByReference(cart, cframe)
if ok then notify("Carrinho", "Carrinho movido para o checkpoint.") else notify("Carrinho", "Não foi possível mover este carrinho.") end
return ok
end
local STABILIZER_CONFIG = { NORMAL_FORCE = 2500, DOWNHILL_FORCE = 800 }
local stabilizer = { enabled = false, cart = nil, forces = {}, attachments = {}, heartbeat = nil }
local function cleanupStabilizer()
if stabilizer.heartbeat then stabilizer.heartbeat:Disconnect() stabilizer.heartbeat = nil end
for _, force in ipairs(stabilizer.forces) do if force and force.Parent then force:Destroy() end end
for _, att in ipairs(stabilizer.attachments) do if att and att.Parent then att:Destroy() end end
stabilizer.forces = {}; stabilizer.attachments = {}; stabilizer.cart = nil
end
local function getWheels(cart)
local wheels, keywords = {}, { "wheel", "tire", "tyre", "roda", "pneu", "axle", "roue" }
for _, part in ipairs(cart:GetDescendants()) do
if part:IsA("BasePart") and not part.Anchored then
local name = part.Name:lower()
for _, kw in ipairs(keywords) do if name:find(kw, 1, true) then table.insert(wheels, part) break end end
end
end
if #wheels == 0 then
local parts = {}
for _, part in ipairs(cart:GetDescendants()) do if part:IsA("BasePart") and not part.Anchored then table.insert(parts, part) end end
table.sort(parts, function(a, b) return a.Position.Y < b.Position.Y end)
local count = math.max(1, math.floor(#parts / 3))
for i = 1, math.min(count, #parts) do table.insert(wheels, parts[i]) end
end
return wheels
end
local function applyStabilizer(cart)
cleanupStabilizer()
if not cart or not cart.Parent then return end
local wheels = getWheels(cart)
if #wheels == 0 then notify("Estabilizador", "Nenhuma roda encontrada.") return end
stabilizer.cart = cart
for _, part in ipairs(wheels) do
for _, child in ipairs(part:GetChildren()) do if child:IsA("VectorForce") and child.Name == "CafezitosStabilizerForce" then child:Destroy() end end
local att = part:FindFirstChild("_CafezitosStabilizer")
if not att then att = Instance.new("Attachment"); att.Name = "_CafezitosStabilizer"; att.Parent = part end
table.insert(stabilizer.attachments, att)
local force = Instance.new("VectorForce")
force.Name = "CafezitosStabilizerForce"; force.Attachment0 = att; force.RelativeTo = Enum.ActuatorRelativeTo.World; force.Force = Vector3.zero; force.Parent = part
table.insert(stabilizer.forces, force)
end
local reference = getCartPrimary(cart) or wheels[1]
stabilizer.heartbeat = RunService.Heartbeat:Connect(function()
if not reference or not reference.Parent then cleanupStabilizer() return end
local mag = 0
if stabilizer.enabled and not FLYING and not panicActive and os.clock() >= cartMotionPauseUntil and os.clock() >= cartFeatureTiming.autobrakeHoldUntil then
mag = math.abs(reference.AssemblyLinearVelocity.Y) > 5 and STABILIZER_CONFIG.DOWNHILL_FORCE or STABILIZER_CONFIG.NORMAL_FORCE
end
local forceCount = math.max(#stabilizer.forces, 1)
for _, force in ipairs(stabilizer.forces) do
if force and force.Parent and force.Attachment0 and force.Attachment0.Parent then
force.Force = Vector3.new(0, -(mag * force.Parent.AssemblyMass) / forceCount, 0)
elseif force and force.Parent then force:Destroy() end
end
end)
end
local function refreshStabilizer()
if stabilizer.enabled then
local cart = getCurrentCart()
if cart then applyStabilizer(cart) else notify("Estabilizador", "Sente em um carrinho primeiro.") end
else cleanupStabilizer() end
end
local seatConnection
local function watchSeat(character)
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if not humanoid and character and character.Parent then humanoid = character:WaitForChild("Humanoid", 5) end
if destroyed or not isCurrentSuiteGeneration() or not character or character ~= LocalPlayer.Character or not character.Parent or not humanoid or not humanoid:IsA("Humanoid") or not humanoid.Parent then return end
if seatConnection then seatConnection:Disconnect() seatConnection = nil end
local initialSeat = humanoid.SeatPart
if initialSeat then
local initialCart = cacheCurrentCart(humanoid, initialSeat)
if stabilizer.enabled then applyStabilizer(initialCart) end
else clearCurrentCartCache() end
seatConnection = trackConnection(humanoid.Seated:Connect(function(isSeated, seat)
if destroyed or not isCurrentSuiteGeneration() or character ~= LocalPlayer.Character or humanoid.Parent ~= character then return end
if not isSeated then
clearCurrentCartCache(); cleanupStabilizer(); restorePanicStop()
if FLYING and flySavedState.startedSeated then
if flyEnabled and flyToggleControl then task.defer(function() flyToggleControl:UpdateToggle(nil, false) end) else stopFly() end
end
if stopBoost then stopBoost() end
if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end
if panicToggleControl then task.defer(function() panicToggleControl:UpdateToggle(nil, false) end) end
else
local cart = cacheCurrentCart(humanoid, seat)
if stabilizer.enabled then applyStabilizer(cart) end
end
end))
end
local function teleportPlayerOrCart(cframe)
local cart = getCurrentCart()
if cart then stopCartControllersForTeleport() return pivotCartByReference(cart, cframe) end
return teleportCharacter(cframe)
end
-- =============================================================================
-- Eliminador
-- =============================================================================
local function findNearestFreeVehicleSeat()
local root = getRoot(nil, 5)
if not root then return nil end
local bestVS, bestVD = nil, math.huge
for _, inst in ipairs(workspace:GetDescendants()) do
if inst:IsA("VehicleSeat") and not inst.Occupant then
local dist = (root.Position - inst.Position).Magnitude
if dist < bestVD then bestVS = inst bestVD = dist end
end
end
return bestVS
end
local function findPlayerByPartialName(value)
value = (value or ""):match("^%s*(.-)%s*$"):lower()
if value == "" then return nil end
for _, p in ipairs(Players:GetPlayers()) do if p.Name:lower() == value or p.DisplayName:lower() == value then return p end end
for _, p in ipairs(Players:GetPlayers()) do local n = p.Name:lower() local d = p.DisplayName:lower() if n:sub(1,#value) == value or d:sub(1,#value) == value then return p end end
for _, p in ipairs(Players:GetPlayers()) do if p.Name:lower():find(value,1,true) or p.DisplayName:lower():find(value,1,true) then return p end end
return nil
end
local function sitOnVehicleSeat(seat, session)
local root = getRoot(nil, 5)
local humanoid = getHumanoid(nil, 5)
if destroyed or not isCurrentSuiteGeneration() or (session and (session ~= killerSession or not killerActive)) or not seat or not root or not humanoid or seat.Occupant then return false end
if humanoid.SeatPart and humanoid.SeatPart ~= seat then
humanoid.Sit = false
pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
local deadline = os.clock() + 0.5
repeat RunService.Heartbeat:Wait() until not humanoid.Parent or not humanoid.SeatPart or destroyed or (session and session ~= killerSession) or os.clock() >= deadline
if destroyed or not isCurrentSuiteGeneration() or not humanoid.Parent or (session and (session ~= killerSession or not killerActive)) then return false end
end
for _ = 1, 3 do
if destroyed or not isCurrentSuiteGeneration() or (session and (session ~= killerSession or not killerActive)) or not seat.Parent or seat.Occupant then break end
root.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
task.wait(0.12)
if destroyed or (session and session ~= killerSession) then return false end
pcall(function() seat:Sit(humanoid) end)
task.wait(0.2)
if destroyed or (session and session ~= killerSession) then return false end
if humanoid.SeatPart == seat or seat.Occupant == humanoid then return true end
humanoid.Sit = true
task.wait(0.12)
if destroyed or (session and session ~= killerSession) then return false end
if humanoid.SeatPart == seat or seat.Occupant == humanoid then return true end
end
return false
end
local function moveToTarget(targetRoot, duration, session, seat, cart)
local root = getRoot()
local humanoid = getHumanoid()
local started = os.clock()
while os.clock() - started < duration do
if destroyed or not killerActive or session ~= killerSession then return false end
if not root or not root.Parent or not humanoid or not humanoid.Parent or not targetRoot or not targetRoot.Parent or not seat or not seat.Parent or seat.Occupant ~= humanoid or humanoid.SeatPart ~= seat or getCurrentCart() ~= cart then return false end
local pos = targetRoot.Position - targetRoot.CFrame.LookVector * 1.2 + Vector3.new(0, 1.5, 0)
root.CFrame = CFrame.lookAt(pos, targetRoot.Position)
RunService.Heartbeat:Wait()
end
return true
end
local function finishKiller(message, session)
if session and session ~= killerSession then return end
killerSession = killerSession + 1
local cleanupSession = killerSession
local humanoid = getHumanoid()
local wasSeated = humanoid and humanoid.SeatPart ~= nil
if humanoid then humanoid.Sit = false pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
if wasSeated then task.wait(0.05) if killerSession ~= cleanupSession then return end end
if flyEnabled and flyToggleControl then flyToggleControl:UpdateToggle(nil, false) else stopFly() end
killerActive = false
if message then notify("Eliminador", message) end
end
local function executeKiller(partialName)
if killerActive then notify("Eliminador", "Aguarde a tentativa atual terminar.") return end
local target = findPlayerByPartialName(partialName)
if not target or target == LocalPlayer then notify("Eliminador", target == LocalPlayer and "Escolha outro jogador." or "Jogador não encontrado.") return end
killerSession = killerSession + 1
local session = killerSession
killerActive = true
if cancelAutoWin then cancelAutoWin(true) end
if flyEnabled and flyToggleControl then flyToggleControl:UpdateToggle(nil, false) else stopFly() end
if stopBoost then stopBoost() end
if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end
local humanoid = getHumanoid(nil, 5)
local seat = humanoid and humanoid.SeatPart
local alreadySeated = seat and seat:IsA("VehicleSeat") and seat.Occupant == humanoid
if not alreadySeated then
seat = findNearestFreeVehicleSeat()
if not seat then finishKiller("Não há carrinho livre por perto.", session) return end
if not sitOnVehicleSeat(seat, session) then finishKiller("Não foi possível sentar no carrinho.", session) return end
end
if destroyed or session ~= killerSession then return end
local cart = cacheCurrentCart(humanoid, seat)
if not cart then finishKiller("Estrutura do carrinho não reconhecida.", session) return end
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
local reached = moveToTarget(targetRoot, 3, session, seat, cart)
if session == killerSession then finishKiller(reached and "Carrinho levado ao alvo." or "Tentativa cancelada.", session) end
end
-- =============================================================================
-- Vitória Automática
-- =============================================================================
do
local autoWinSession, autoWinActive = 0, false
local autoWinAnchoredRoot, autoWinOriginalAnchored
local function restoreAutoWinAnchor()
if autoWinAnchoredRoot and autoWinAnchoredRoot.Parent then autoWinAnchoredRoot.Anchored = autoWinOriginalAnchored == true end
autoWinAnchoredRoot, autoWinOriginalAnchored = nil, nil
end
cancelAutoWin = function(silent)
local wasActive = autoWinActive
autoWinSession = autoWinSession + 1
autoWinActive = false
restoreAutoWinAnchor()
if wasActive and not silent then notify("Vitória Automática", "Rota cancelada.") end
end
local function autoWinAlive(session) return autoWinActive and session == autoWinSession and not destroyed and isCurrentSuiteGeneration() end
local function waitAutoWin(seconds, session)
local deadline = os.clock() + seconds
while autoWinAlive(session) and os.clock() < deadline do task.wait(math.min(0.1, math.max(0, deadline - os.clock()))) end
return autoWinAlive(session)
end
local autoWinRoute = {
{ action = "teleport", delay = 4.1, cframe = CFrame.new(-430.898926, 165.25, 101.645676, 1, 1.51719295e-08, -1.24212969e-14, -1.51719295e-08, 1, -1.14675147e-09, 1.24038988e-14, 1.14675147e-09, 1) },
{ action = "move", delay = 10, cframe = CFrame.new(-430.898529, 163.273926, 131.145554, 1, -2.85942061e-08, 2.0407586e-07, 2.85942079e-08, 1, -1.07927356e-08, -2.0407586e-07, 1.07927409e-08, 1) },
{ action = "sit", value = true, delay = 33 },
{ action = "sit", value = false, delay = 2 },
{ action = "move", delay = 0.1, cframe = CFrame.new(-500.748535, -21.78265, -302.303406, 0, 0, 1, 0, -1, 0, 1, 0, 0) },
{ action = "anchor", delay = 1.3 },
{ action = "restoreAnchor", delay = 0.6 },
{ action = "move", delay = 10, cframe = CFrame.new(-470.360138, -21.1945782, -302.303101, 0, 0, 1, 0, -1, 0, 1, 0, 0) },
{ action = "sit", value = true, delay = 35 },
{ action = "sit", value = false, delay = 0.5 },
{ action = "move", delay = 0, cframe = CFrame.new(-421.770264, -44.2260475, -297.081909, 0.999515891, 6.59387993e-08, 0.0311128739, -6.60972859e-08, 1, 4.06536627e-09, -0.0311128739, -6.11987483e-09, 0.999515891) },
}
function startAutoWin()
if autoWinActive then notify("Vitória Automática", "A rota já está em andamento.") return end
local character = getCharacter()
if not character or not getRoot(character) or not getHumanoid(character) then notify("Vitória Automática", "Personagem não encontrado.") return end
stopCartControllersForTeleport(true)
autoWinSession = autoWinSession + 1
local session = autoWinSession
autoWinActive = true
notify("Vitória Automática", "Rota iniciada; não feche o menu.")
task.spawn(function()
local ok, completed = pcall(function()
for _, step in ipairs(autoWinRoute) do
if not autoWinAlive(session) then return false end
local root = getRoot(character)
local humanoid = getHumanoid(character)
if getCharacter() ~= character or not root or not root.Parent or not humanoid or not humanoid.Parent then error("Personagem perdido durante a rota.", 0) end
if step.action == "teleport" then
if not teleportCharacter(step.cframe) then error("Não foi possível iniciar a rota.", 0) end
elseif step.action == "move" then
root.CFrame = step.cframe
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
elseif step.action == "sit" then humanoid.Sit = step.value
elseif step.action == "anchor" then
autoWinAnchoredRoot = root; autoWinOriginalAnchored = root.Anchored; root.Anchored = true
elseif step.action == "restoreAnchor" then restoreAutoWinAnchor() end
if not waitAutoWin(step.delay, session) then return false end
end
return true
end)
if session ~= autoWinSession then return end
cancelAutoWin(true)
if not destroyed then
if not ok then notify("Vitória Automática", tostring(completed):sub(1,160))
elseif completed then notify("Vitória Automática", "Rota concluída.") end
end
end)
end
end
-- =============================================================================
-- MÓDULOS DO DESASTRES NATURAIS
-- =============================================================================
local function createProtectionController(config)
local players, localPlayer = config.players, config.player
local now = config.clock or os.clock
local api = { enabled = false, velocityLimit = 350, rotationLimit = 700, holdSeconds = 10 }
local records, connections = {}, {}
local stopped, lastScan = false, -math.huge
local lastRoot, lastPosition, lastYaw, lastRead
local function disconnect(group) for _, c in ipairs(group) do c:Disconnect() end table.clear(group) end
local function restorePart(record, part) local original = record.originals[part] if original ~= nil then pcall(function() part.CanCollide = original end) record.originals[part] = nil end end
local function restore(record) for part in pairs(record.originals) do restorePart(record, part) end record.expires = nil end
local function suppress(record, part) if record.originals[part] == nil then record.originals[part] = part.CanCollide end part.CanCollide = false end
local function bindCharacter(record, character)
restore(record); disconnect(record.characterConnections); table.clear(record.parts); record.character = character
if not character then return end
local function add(part) if part:IsA("BasePart") then record.parts[part] = true if api.enabled and record.expires then suppress(record, part) end end end
table.insert(record.characterConnections, character.DescendantAdded:Connect(add))
table.insert(record.characterConnections, character.DescendantRemoving:Connect(function(part) restorePart(record, part) record.parts[part] = nil end))
for _, part in ipairs(character:GetDescendants()) do add(part) end
end
local function watch(player)
if player == localPlayer or records[player] then return end
local record = { player = player, parts = {}, originals = {}, characterConnections = {}, playerConnections = {} }
records[player] = record
table.insert(record.playerConnections, player.CharacterAdded:Connect(function(character) bindCharacter(record, character) end))
table.insert(record.playerConnections, player.CharacterRemoving:Connect(function(character) if record.character == character then bindCharacter(record, nil) end end))
bindCharacter(record, player.Character)
end
local function unwatch(player) local record = records[player] if not record then return end restore(record) disconnect(record.characterConnections) disconnect(record.playerConnections) records[player] = nil end
table.insert(connections, players.PlayerAdded:Connect(watch))
table.insert(connections, players.PlayerRemoving:Connect(unwatch))
for _, player in ipairs(players:GetPlayers()) do watch(player) end
function api:SetEnabled(enabled) if stopped then return end self.enabled = enabled == true lastScan = -math.huge if not self.enabled then for _, record in pairs(records) do restore(record) end end end
function api:SetLimits(velocity, rotation, seconds)
local function valid(v, mn, mx) return type(v) == "number" and v == v and v >= mn and v <= mx end
if not valid(velocity,50,2000) or not valid(rotation,50,5000) or not valid(seconds,1,60) then return false end
self.velocityLimit, self.rotationLimit, self.holdSeconds = velocity, rotation, seconds
return true
end
function api:Step()
if stopped or not self.enabled then return end
local current = now()
if current - lastScan >= 0.1 then
lastScan = current
for player, record in pairs(records) do
if record.character ~= player.Character then bindCharacter(record, player.Character) end
local character = record.character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
local flagged = false
if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then
flagged = root.AssemblyLinearVelocity.Magnitude > self.velocityLimit or root.AssemblyAngularVelocity.Magnitude > self.rotationLimit
end
if flagged then record.expires = current + self.holdSeconds
elseif record.expires and (current >= record.expires or not root or not humanoid or humanoid.Health <= 0) then restore(record) end
end
end
for _, record in pairs(records) do if record.expires then for part in pairs(record.parts) do if part.Parent then suppress(record, part) end end end end
end
function api:Flagged()
local list, current = {}, now()
for player, record in pairs(records) do
if record.expires then table.insert(list, { name = player.Name, remaining = math.max(0, math.ceil(record.expires - current)) }) end
end
table.sort(list, function(a, b) return a.name < b.name end)
return list
end
function api:ResetReadings() lastRoot, lastPosition, lastYaw, lastRead = nil, nil, nil, nil end
function api:ReadPosition()
local character = localPlayer.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
if not root or not root:IsA("BasePart") then self:ResetReadings() return nil end
local current, position = now(), root.Position
local _, yaw = root.CFrame:ToEulerAnglesYXZ()
local speed, rotation = 0, 0
if lastRoot == root and lastPosition and lastRead and current > lastRead then
local delta = current - lastRead
local dx, dz = position.X - lastPosition.X, position.Z - lastPosition.Z
speed = math.sqrt(dx*dx + dz*dz) / delta
local difference = (yaw - lastYaw + math.pi) % (math.pi*2) - math.pi
rotation = math.abs(difference) / delta * 180 / math.pi
end
lastRoot, lastPosition, lastYaw, lastRead = root, position, yaw, current
return { x = position.X, y = position.Y, z = position.Z, speed = speed, rotation = rotation }
end
function api:Destroy() if stopped then return end self:SetEnabled(false) stopped = true local list = {} for player in pairs(records) do table.insert(list, player) end for _, player in ipairs(list) do unwatch(player) end disconnect(connections) self:ResetReadings() end
return api
end
local function createDisasterFormations()
local function rotate(v,x,y,z)
local cz,sz,cy,sy,cx,sx = math.cos(z),math.sin(z),math.cos(y),math.sin(y),math.cos(x),math.sin(x)
local a,b = v.X*cz - v.Y*sz, v.X*sz + v.Y*cz
local c,d = a*cy + v.Z*sy, -a*sy + v.Z*cy
return Vector3.new(c, b*cx - d*sx, b*sx + d*cx)
end
local api = { names = { "W7: Anel classico","W7: Tornado","W7: Cupula esferica","W7: Singularidade","W7: Coracao","W7: Quatro satelites","W7: Saturno","W7: Parede","W7: Infinito","W7: Estrela","W7: Gudodama","W7: Galaxia","W7: Coroa","W7: DNA duplo","W7: Asas Susanoo","W7: Anel Raijin","W7: Giroscopio","W7: Lotus","W7: Piramide","W7: Cubo giratorio","W7: Armadura Susanoo","W7: Lua Rinnegan","W7: Rasengan","W7: Portais de Babylon","W7: Santuario","W7: Petalas","W7: Aura Chidori","W7: Stand JoJo" }, Rotate = rotate }
function api:Offset(formation, i, total, safeRadius, angle, now)
local S = { CurrentFormation = formation, orbitAngle = angle, SatelliteDist = safeRadius * 0.53 }
local t = (i / total) * (2 * math.pi)
local f = S.CurrentFormation
if f == 1 then local ang = S.orbitAngle + t return Vector3.new(math.cos(ang)*safeRadius, 0, math.sin(ang)*safeRadius)
elseif f == 2 then local ang = S.orbitAngle + t local hg = -4 + ((i/total)*12) local rg = safeRadius*0.4 + ((i/total)*safeRadius*0.8) return Vector3.new(math.cos(ang)*rg, hg, math.sin(ang)*rg)
elseif f == 3 then local phi = math.acos(-1 + (2*i - 1)/total) local theta = math.sqrt(total*math.pi)*phi + S.orbitAngle return Vector3.new(safeRadius*math.cos(theta)*math.sin(phi), safeRadius*math.cos(phi), safeRadius*math.sin(theta)*math.sin(phi))
elseif f == 4 then local ang = S.orbitAngle*2 + t local r = 2.5 + math.sin(now*10 + i)*0.8 return Vector3.new(math.cos(ang)*r, math.sin(ang)*r, -12 + math.sin(ang)*1.5)
elseif f == 5 then local scale = safeRadius/16 local x = (16*math.sin(t)^3)*scale local y = (13*math.cos(t) - 5*math.cos(2*t) - 2*math.cos(3*t) - math.cos(4*t))*scale return Vector3.new(x, y, -12)
elseif f == 6 then local orb = (i % 4) + 1 local raw = { Vector3.new(-7,5.5,S.SatelliteDist), Vector3.new(7,5.5,S.SatelliteDist), Vector3.new(-8,1.8,S.SatelliteDist), Vector3.new(8,1.8,S.SatelliteDist) } local la = (S.orbitAngle*2.5) + (i*(math.pi/2)) return raw[orb] + Vector3.new(math.cos(la)*2.2, math.sin(la)*2.2, math.sin(la)*0.8)
elseif f == 7 then local tilt = math.rad(35) local ang = S.orbitAngle + t local rx = math.cos(ang)*safeRadius local rz = math.sin(ang)*safeRadius return Vector3.new(rx, rz*math.sin(tilt), rz*math.cos(tilt))
elseif f == 8 then local cols = 5 local col = (i-1) % cols local row = math.floor((i-1)/cols) return Vector3.new((col-(cols-1)/2)*2.5, (row-1.5)*2.5+1, -safeRadius*0.8)
elseif f == 9 then local ang = S.orbitAngle + t local denom = 1 + math.sin(ang)^2 return Vector3.new((safeRadius*math.cos(ang))/denom, 0, (safeRadius*math.sin(ang)*math.cos(ang))/denom)
elseif f == 10 then local ang = S.orbitAngle + t local r = safeRadius*(0.65 + 0.35*math.cos(5*ang)) return Vector3.new(math.cos(ang)*r, 0, math.sin(ang)*r)
elseif f == 11 then local span = math.pi*1.25 local aa = -span/2 + ((i/total)*span) local hr = 4.5 local wy = math.sin(now*3 + i)*0.25 return Vector3.new(math.sin(aa)*hr, math.cos(aa)*hr + 2 + wy, S.SatelliteDist*0.7)
elseif f == 12 then local arm = (i % 2 == 0) and 0 or math.pi local prog = i/total local r = 4 + prog*safeRadius local ang = S.orbitAngle + prog*math.pi*3 + arm return Vector3.new(math.cos(ang)*r, math.sin(prog*4)*1.5, math.sin(ang)*r)
elseif f == 13 then local ang = S.orbitAngle + t return Vector3.new(math.cos(ang)*3.5, 4.2, math.sin(ang)*3.5)
elseif f == 14 then local strand = (i % 2 == 0) and 0 or math.pi local prog = (i/total)*2 - 1 local hy = prog*(safeRadius*0.6) local ang = S.orbitAngle*1.5 + prog*math.pi*4 + strand return Vector3.new(math.cos(ang)*4, hy, math.sin(ang)*4)
elseif f == 15 then local isLeft = i <= total/2 local half = math.max(math.floor(total/2),1) local sub = isLeft and i or (i - half) local prog = sub/half local flap = math.sin(now*4)*0.25 local wx = (isLeft and -2.2 or 2.2) + (isLeft and -1 or 1)*(prog*safeRadius*0.8) local wy = 1.8 + prog*4.5 - prog^2*2 local wz = S.SatelliteDist*0.75 + prog*3.5*flap return Vector3.new(wx, wy, wz)
elseif f == 16 then local ang = S.orbitAngle + t local r = safeRadius*0.7 return Vector3.new(math.cos(ang)*r, math.sin(ang)*r + 2.5, S.SatelliteDist*0.7)
elseif f == 17 then if i % 2 == 0 then local ang = S.orbitAngle + t return Vector3.new(math.cos(ang)*safeRadius, 0, math.sin(ang)*safeRadius) else local sv = -S.orbitAngle*1.2 + t return Vector3.new(0, math.cos(sv)*safeRadius, math.sin(sv)*safeRadius) end
elseif f == 18 then local ang = S.orbitAngle + t local r = safeRadius*(0.35 + 0.65*math.abs(math.cos(4*ang))) return Vector3.new(math.cos(ang)*r, -2.6, math.sin(ang)*r)
elseif f == 19 then local prog = i/total local py = -2.5 + prog*safeRadius*0.8 local pr = (1-prog)*safeRadius*0.8 local ang = S.orbitAngle + math.floor(prog*3)*(2*math.pi/3) + t*0.2 return Vector3.new(math.cos(ang)*pr, py, math.sin(ang)*pr)
elseif f == 20 then local e = i % 8 local h = safeRadius*0.45 local cx = ((e % 2 == 0) and 1 or -1)*h local cy = (((math.floor(e/2)) % 2 == 0) and 1 or -1)*h local cz = (((math.floor(e/4)) % 2 == 0) and 1 or -1)*h return rotate(Vector3.new(cx,cy,cz), S.orbitAngle*0.8, S.orbitAngle*0.5, 0)
elseif f == 21 then local prog = (i-1)/total local breathe = math.sin(now*2.2)*0.28
if prog < 0.5 then local layer = math.min(math.floor(prog/0.1),4) local within = (prog % 0.1)/0.1 local ra = within*math.pi local rr = safeRadius*(0.85 - layer*0.09) return Vector3.new(math.cos(ra)*rr, -2.5 + layer*1.35 + breathe, -0.34*rr - math.sin(ra)*rr*0.55)
elseif prog < 0.72 then local ap = (prog-0.5)/0.22 return Vector3.new(-(2.8 + ap*safeRadius*0.48), 1.6 + ap*safeRadius*0.42 - ap*ap*safeRadius*0.1, -1 + ap*1.4)
elseif prog < 0.94 then local ap = (prog-0.72)/0.22 return Vector3.new(2.8 + ap*safeRadius*0.48, 1.6 + ap*safeRadius*0.42 - ap*ap*safeRadius*0.1, -1 + ap*1.4)
else local ap = (prog-0.94)/0.06 local ang = S.orbitAngle*3 + ap*math.pi*2 return Vector3.new(math.cos(ang)*2.2, 6.5 + math.sin(now*3)*0.3, math.sin(ang)*2.2 - 1) end
elseif f == 22 then local prog = (i-1)/total local er = safeRadius*0.6 local eh = 10 + safeRadius*0.25 local ez = -safeRadius*1.6
if prog < 0.55 then local k = prog/0.55 local ang = S.orbitAngle + k*math.pi*2 return Vector3.new(math.cos(ang)*er, eh + math.sin(ang)*er, ez)
elseif prog < 0.75 then local k = (prog-0.55)/0.2 local ang = -S.orbitAngle*2 + k*math.pi*2 return Vector3.new(math.cos(ang)*er*0.35, eh + math.sin(ang)*er*0.35, ez)
elseif prog < 0.9 then local dotTotal = math.max(math.floor(total*0.15),3) local dotIdx = math.min(math.floor((prog-0.75)/0.15*dotTotal + 1e-4), dotTotal-1) local perDot = math.max(math.ceil(dotTotal/3),1) local grp = dotIdx % 3 local sub = math.floor(dotIdx/3) local ang = S.orbitAngle*2 + grp*(math.pi*2/3) local sa = (sub/perDot)*math.pi*2 return Vector3.new(math.cos(ang)*er*0.6 + math.cos(sa)*1.1, eh + math.sin(ang)*er*0.6 + math.sin(sa)*1.1, ez)
else local k = (prog-0.9)/0.1 return Vector3.new(-er*1.05 + k*er*2.1, eh + er*0.62 + math.sin(k*math.pi)*0.8, ez) end
elseif f == 23 then local prog = (i-1)/total local hy = 5.5 + safeRadius*0.45 local hz = -safeRadius*0.15 local orbr = safeRadius*0.42
if prog < 0.7 then local k = prog/0.7 local phi = math.acos(1 - 2*k) local theta = math.sqrt(math.max(total,1)*math.pi)*phi + S.orbitAngle*3 return Vector3.new(orbr*math.cos(theta)*math.sin(phi), hy + orbr*math.cos(phi), hz + orbr*math.sin(theta)*math.sin(phi))
else local k = (prog-0.7)/0.3 local ang = -S.orbitAngle*4 + k*math.pi*2 return Vector3.new(math.cos(ang)*safeRadius*0.62, hy, hz + math.sin(ang)*safeRadius*0.62) end
elseif f == 24 then local ringCount = 9 local ringIdx = (i-1) % ringCount local within = math.floor((i-1)/ringCount) local perRing = math.max(math.ceil(total/ringCount),1) local ang = S.orbitAngle + (within/perRing)*math.pi*2 local col = ringIdx % 3 local row = math.floor(ringIdx/3) return Vector3.new((col-1)*(safeRadius*0.5) + math.cos(ang)*1.7, 2.5 + (row-1)*(safeRadius*0.5) + math.sin(ang)*1.7, -safeRadius*0.5)
elseif f == 25 then local prog = (i-1)/total local sw = safeRadius*0.9 local sh = safeRadius*1.1 + 5 local by = -3
if prog < 0.28 then local k = prog/0.28 return Vector3.new(-sw, by + k*sh, 0)
elseif prog < 0.56 then local k = (prog-0.28)/0.28 return Vector3.new(sw, by + k*sh, 0)
elseif prog < 0.72 then local k = (prog-0.56)/0.16 return Vector3.new(-sw*1.25 + k*sw*2.5, by + sh, 0)
elseif prog < 0.88 then local k = (prog-0.72)/0.16 return Vector3.new(-sw*1.05 + k*sw*2.1, by + sh - safeRadius*0.22, 0)
else local k = (prog-0.88)/0.12 local ang = S.orbitAngle*2 + k*math.pi*2 return Vector3.new(math.cos(ang)*sw*1.3, by + sh - safeRadius*0.55, math.sin(ang)*sw*0.25) end
elseif f == 26 then local prog = (i-1)/total local ang = S.orbitAngle*3 + prog*math.pi*8 local r = safeRadius*(0.25 + 0.75*prog) return Vector3.new(math.cos(ang)*r, -3 + prog*safeRadius*1.2, math.sin(ang)*r)
elseif f == 27 then local ang = S.orbitAngle*2.5 + (i/total)*math.pi*2 local spike = (i % 2 == 0) and 1 or 0.45 local jag = 0.9 + 0.25*math.sin(now*25 + i) local r = safeRadius*spike*jag return Vector3.new(math.cos(ang)*r, ((i % 3) - 1)*1.2, math.sin(ang)*r)
elseif f == 28 then local prog = (i-1)/total local sz = -safeRadius*0.85 local zh, za, zl = sz + 2.2, sz - 1.4, sz + 1
if prog < 0.34 then local k = prog/0.34 local ang = k*math.pi*2 return Vector3.new(math.cos(ang)*safeRadius*0.34, 5.2 + math.sin(ang)*safeRadius*0.3, sz)
elseif prog < 0.5 then local k = (prog-0.34)/0.16 local ang = k*math.pi*2 return Vector3.new(math.cos(ang)*safeRadius*0.17, 11.4 + math.sin(ang)*safeRadius*0.19, zh)
elseif prog < 0.68 then local k = (prog-0.5)/0.18 return Vector3.new(-(safeRadius*0.44 + k*safeRadius*0.5), 6.2 - k*6, za)
elseif prog < 0.86 then local k = (prog-0.68)/0.18 return Vector3.new(safeRadius*0.44 + k*safeRadius*0.5, 6.2 - k*6, za)
else local k = (prog-0.86)/0.14 local side = (i % 2 == 0) and -1 or 1 return Vector3.new(side*safeRadius*0.2, -2.4 - k*4, zl) end
end
return Vector3.new(0,0,0)
end
return api
end
local function createDisasterFallProtection(config)
local api = { enabled = false, manual = false, count = 0, lastMessage = "Desligado." }
local automatic = {}
local player = config.player
local originals, watchers, lifecycle = {}, {}, {}
local isDestroyed = false
local function tell()
api.count = 0
for object in pairs(originals) do if object.Parent then api.count = api.count + 1 end end
api.lastMessage = not api.enabled and "Desligado. Scripts locais restaurados." or (api.count > 0 and (tostring(api.count).." script(s) local(is) de queda pausado(s).") or "Nenhum script local de queda compativel encontrado.")
if config.onState then pcall(config.onState, api.lastMessage) end
end
local function clear()
for _, c in ipairs(watchers) do c:Disconnect() end
watchers = {}
for object, value in pairs(originals) do pcall(function() object.Disabled = value end) end
originals = {}
end
local function visit(object)
if not api.enabled or isDestroyed or not object:IsA("LocalScript") then return end
local name = object.Name:lower():gsub("[%s_%-]", "")
if name ~= "falldamage" and name ~= "falldamagescript" then return end
if originals[object] ~= nil then return end
local ok, value = pcall(function() return object.Disabled end)
if not ok or type(value) ~= "boolean" then return end
if pcall(function() object.Disabled = true end) then originals[object] = value end
tell()
end
local function watch(root)
if not root then return end
watchers[#watchers+1] = root.DescendantAdded:Connect(visit)
for _, object in ipairs(root:GetDescendants()) do visit(object) end
end
local function bind(character)
clear()
if api.enabled and not isDestroyed then watch(character) watch(player:FindFirstChild("PlayerScripts")) end
tell()
end
function api:SetEnabled(value) if isDestroyed then return false end self.manual = value == true local effective = self.manual or next(automatic) ~= nil if self.enabled ~= effective then self.enabled = effective bind(player.Character) end return true, self.lastMessage end
function api:SetAutomatic(owner, value) if isDestroyed then return false end automatic[owner] = value == true and true or nil local effective = self.manual or next(automatic) ~= nil if self.enabled ~= effective then self.enabled = effective bind(player.Character) end return true, self.lastMessage end
lifecycle[#lifecycle+1] = player.CharacterAdded:Connect(function(character) if api.enabled then bind(character) end end)
lifecycle[#lifecycle+1] = player.CharacterRemoving:Connect(function() if api.enabled then bind(nil) end end)
lifecycle[#lifecycle+1] = player.ChildAdded:Connect(function(child) if api.enabled and child.Name == "PlayerScripts" then bind(player.Character) end end)
function api:Destroy() if isDestroyed then return end self.enabled = false self.manual = false automatic = {} clear() isDestroyed = true for _, c in ipairs(lifecycle) do c:Disconnect() end lifecycle = {} tell() end
return api
end
local function createDisasterSurvival(config)
local api = { weatherRoof = false, voidGuard = false, sfx = false, lastMessage = "Desligado." }
local player, world = config.player, config.world
local stopped = false
local roof, animation, lastSafePosition
local function tell(message) api.lastMessage = message if config.onState then pcall(config.onState, message) end end
local function root() local c = player and player.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function humanoid() local c = player and player.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function floorY() local value pcall(function() value = tonumber(world.FallenPartsDestroyHeight) end) return value or -500 end
local function removeRoof() if roof then pcall(function() roof:Destroy() end) end roof = nil end
local function ensureRoof()
if roof and roof.Parent then return roof end
local part = Instance.new("Part")
part.Name = "CafezitosWeatherRoof"; part.Size = Vector3.new(14,0.4,14); part.Transparency = 1; part.Anchored = true
part.CanCollide = false; part.CanTouch = false; part.CanQuery = true; part.CastShadow = false; part.Parent = world
roof = part
return part
end
function api:SetWeatherRoof(value) if stopped then return false end self.weatherRoof = value == true if not self.weatherRoof then removeRoof() tell("Abrigo local desligado.") else ensureRoof() tell("Abrigo local ligado: acompanha seu personagem.") end return true end
function api:SetVoidGuard(value) if stopped then return false end self.voidGuard = value == true if not self.voidGuard then tell("Protecao contra void desligada.") elseif lastSafePosition then tell("Protecao contra void ligada.") else tell("Protecao contra void ligada: aguardando posicao segura.") end return true end
function api:SetSfx(value) if stopped then return false end self.sfx = value == true if self.sfx then self:PlaySfx(1.15) end tell(self.sfx and "SFX local ligado (som embutido do Roblox)." or "SFX local desligado.") return true end
function api:PlaySfx(pitch)
if stopped or not self.sfx then return false end
return pcall(function()
local sound = Instance.new("Sound")
sound.Name = "CafezitosLocalSfx"
sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
sound.Volume = 0.45
sound.PlaybackSpeed = tonumber(pitch) or 1
sound.Parent = (player and player:FindFirstChildOfClass("PlayerGui")) or world
sound:Play()
task.delay(4, function() pcall(function() sound:Destroy() end) end)
end)
end
local animationSets = {
R6 = { Wave = 128777973, Point = 128853357, Dance = 182435998, Dance2 = 182436842, Dance3 = 182436935, Cheer = 129423030 },
R15 = { Wave = 507770239, Point = 507770453, Dance = 507771019, Dance2 = 507770677, Dance3 = 507770818, Cheer = 507770677 },
}
function api:PlayAnimation(name)
if stopped or animationSets.R15[name] == nil then return false, "Animacao invalida." end
local human = humanoid()
if not human then return false, "Personagem indisponivel." end
local rig = "R15"
pcall(function() if tostring(human.RigType):find("R6") then rig = "R6" end end)
local ok, reason = pcall(function()
if animation then pcall(function() animation:Stop(0.15) end) animation = nil end
local source = Instance.new("Animation")
source.Name = "Cafezitos"..name
source.AnimationId = "rbxassetid://"..tostring(animationSets[rig][name])
local animator = human:FindFirstChildOfClass("Animator")
if animator then animation = animator:LoadAnimation(source) else animation = human:LoadAnimation(source) end
animation:Play(0.15, 1, 1)
task.delay(10, function() if animation then pcall(function() animation:Stop(0.2) end) end end)
end)
if ok then self:PlaySfx(1.3) tell("Animacao local: "..name..".") return true end
return false, tostring(reason)
end
function api:StopAnimation() if animation then pcall(function() animation:Stop(0.15) end) end animation = nil tell("Animacao parada.") end
function api:State() return { weatherRoof = self.weatherRoof, voidGuard = self.voidGuard, sfx = self.sfx } end
function api:Step()
if stopped then return end
local part = root()
if not part then return end
local position = part.Position
if position and position.Y > floorY() + 10 then lastSafePosition = position end
if self.weatherRoof then
local partRoof = ensureRoof()
pcall(function() partRoof.Position = position + Vector3.new(0,9,0) end)
end
if self.voidGuard and position and position.Y < floorY() + 8 then
local restorePos = lastSafePosition or Vector3.new(position.X, floorY()+30, position.Z)
pcall(function() part.Position = restorePos part.AssemblyLinearVelocity = Vector3.zero part.AssemblyAngularVelocity = Vector3.zero end)
tell("Void evitado: voce voltou para a ultima posicao segura.")
end
end
function api:Destroy() if stopped then return end stopped = true self:StopAnimation() removeRoof() end
return api
end
local function createDisasterExtras(config)
local world, lighting, player, players = config.world, config.lighting, config.player, config.players
local clock = config.clock or os.clock
local formations = createDisasterFormations()
local modes = { "Anel", "Buraco negro", "Super Ring" }
for _, name in ipairs(formations.names) do modes[#modes+1] = name end
local api = { active = false, paused = false, mode = "Anel", radius = 25, height = 20, spin = 15, reach = 80, maxParts = 30, maxSpeed = 80, follow = true, effects = { shadows = false, postfx = false, materials = false, particles = false, xray = false, fullbright = false, textures = false, sky = false }, modes = modes, pullStrength = 3, attraction = 1000, offsetX = 0, offsetZ = 0, tiltX = 0, tiltY = 0, tiltZ = 0, scanning = false, count = 0, lastError = nil }
local stopped = false
local records, connections = {}, {}
local scanStack, visualStack = {}, {}
local visualSeen = setmetatable({}, { __mode = "k" })
local originals = { postfx = setmetatable({}, {__mode="k"}), materials = setmetatable({}, {__mode="k"}), particles = setmetatable({}, {__mode="k"}), xray = setmetatable({}, {__mode="k"}), textures = setmetatable({}, {__mode="k"}), sky = setmetatable({}, {__mode="k"}) }
local fullbrightOriginal, shadowOriginal, center, previousRoot
local orbitAngle, lastFormationStep, sequence = 0, nil, 0
local zero = Vector3.new(0,0,0)
local function rootPart() local c = player.Character local r = c and c:FindFirstChild("HumanoidRootPart") return r and r:IsA("BasePart") and r or nil end
local function restoreEffect(name)
if name == "fullbright" then if fullbrightOriginal then for prop, val in pairs(fullbrightOriginal) do lighting[prop] = val end fullbrightOriginal = nil end return end
if name == "shadows" then if shadowOriginal ~= nil then lighting.GlobalShadows = shadowOriginal shadowOriginal = nil end return end
local group = originals[name]
for object, record in pairs(group) do for prop, val in pairs(record) do pcall(function() object[prop] = val end) end group[object] = nil end
end
local function remember(name, object, property, value)
local group = originals[name]
if not group[object] then group[object] = {} end
if group[object][property] == nil then group[object][property] = object[property] end
object[property] = value
end
local particleClasses = { ParticleEmitter = true, Trail = true, Beam = true, Fire = true, Smoke = true, Sparkles = true }
local function applyVisual(object)
if api.effects.materials and object:IsA("BasePart") then remember("materials", object, "Material", Enum.Material.SmoothPlastic) end
if api.effects.postfx and object:IsA("PostEffect") then remember("postfx", object, "Enabled", false) end
if api.effects.particles and particleClasses[object.ClassName] then remember("particles", object, "Enabled", false) end
if api.effects.textures and (object:IsA("Decal") or object:IsA("Texture")) then remember("textures", object, "Transparency", 1) end
if api.effects.sky and object:IsA("Sky") then for _, prop in ipairs({ "SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp" }) do remember("sky", object, prop, "") end end
if api.effects.xray and object:IsA("BasePart") and not object:IsA("Terrain") then
local excluded = false
local ancestor = object.Parent
while ancestor and ancestor ~= world do
if ancestor:IsA("Tool") or ancestor:IsA("Accessory") or ancestor:FindFirstChildOfClass("Humanoid") then excluded = true break end
ancestor = ancestor.Parent
end
for _, p in ipairs(players:GetPlayers()) do if p.Character and object:IsDescendantOf(p.Character) then excluded = true break end end
if not excluded then remember("xray", object, "LocalTransparencyModifier", math.max(object.LocalTransparencyModifier, 0.7)) end
end
end
local function rescanVisuals() visualStack = { world, lighting } visualSeen = setmetatable({}, { __mode = "k" }) end
function api:SetEffect(name, value)
if stopped or self.effects[name] == nil then return false end
self.effects[name] = value == true
if not self.effects[name] then restoreEffect(name)
elseif name == "shadows" then if shadowOriginal == nil then shadowOriginal = lighting.GlobalShadows end lighting.GlobalShadows = false
elseif name == "fullbright" then if not fullbrightOriginal then fullbrightOriginal = { Ambient = lighting.Ambient, ColorShift_Bottom = lighting.ColorShift_Bottom, ColorShift_Top = lighting.ColorShift_Top } end lighting.Ambient = Color3.new(1,1,1) lighting.ColorShift_Bottom = Color3.new(1,1,1) lighting.ColorShift_Top = Color3.new(1,1,1)
else rescanVisuals() end
if not self.effects.materials and not self.effects.postfx and not self.effects.particles and not self.effects.xray and not self.effects.textures and not self.effects.sky then visualStack = {} end
return true
end
local function onAdded(object)
if stopped then return end
if api.effects.materials or api.effects.postfx or api.effects.particles or api.effects.xray or api.effects.textures or api.effects.sky then visualSeen[object] = nil table.insert(visualStack, object) end
if api.active and object:IsA("BasePart") then scanStack[#scanStack+1] = object api.scanning = true end
end
table.insert(connections, world.DescendantAdded:Connect(onAdded))
table.insert(connections, lighting.DescendantAdded:Connect(onAdded))
local function eligible(part)
if not part:IsA("BasePart") or part.Anchored or not part:IsDescendantOf(world) then return false end
if part:GetAttribute("NoAttract") or part:FindFirstChild("NoAttract") then return false end
local ancestor = part.Parent
while ancestor and ancestor ~= world do
if ancestor:IsA("Accessory") or ancestor:IsA("Tool") or ancestor:FindFirstChild("NoAttract") or ancestor:GetAttribute("NoAttract") or ancestor:FindFirstChildOfClass("Humanoid") or ancestor:FindFirstChildOfClass("AnimationController") then return false end
ancestor = ancestor.Parent
end
for _, other in ipairs(players:GetPlayers()) do if other.Character and part:IsDescendantOf(other.Character) then return false end end
local ok, connected = pcall(function() return part:GetConnectedParts(true) end)
if not ok or #connected > 0 then return false end
for _, item in ipairs(part:GetDescendants()) do
if item:IsA("Attachment") then
local readOk, joints = pcall(function() return item:GetConstraints() end)
if not readOk then return false end
for _, joint in ipairs(joints) do if joint.Enabled ~= false and joint.Attachment0 and joint.Attachment1 and joint.Attachment0.Parent ~= joint.Attachment1.Parent then return false end end
end
end
if type(config.isOwner) == "function" then local ownerOk, owned = pcall(config.isOwner, part) if not ownerOk or owned ~= true then return false end end
return true
end
local function release(part)
local record = records[part]
if not record then return end
records[part] = nil
api.count = math.max(0, api.count - 1)
for _, object in ipairs(record.objects) do pcall(function() object:Destroy() end) end
pcall(function() part.CanCollide = record.collision part.AssemblyLinearVelocity = zero part.AssemblyAngularVelocity = zero end)
end
function api:Release() local parts = {} for part in pairs(records) do parts[#parts+1] = part end for _, part in ipairs(parts) do release(part) end scanStack = {} self.scanning = false end
function api:Recenter() local r = rootPart() if not r then return false end center, previousRoot = r.Position, r return true end
function api:Scan() if stopped or not self.active or not self:Recenter() then return false end scanStack = { world } self.scanning = true return true end
function api:SetActive(value)
if stopped then return false end
if value ~= true then self.active = false self.paused = false self:Release() return true end
if not self:Recenter() then self.lastError = "Aguardando seu personagem." return false end
self.active, self.paused, self.lastError = true, false, nil
self:Scan()
return true
end
function api:SetPaused(value)
if stopped then return end
self.paused = value == true
lastFormationStep = nil
for part, record in pairs(records) do
record.linear.Enabled = not self.paused
record.angular.Enabled = not self.paused
part.CanCollide = self.paused and record.collision or false
if self.paused then part.AssemblyLinearVelocity = zero part.AssemblyAngularVelocity = zero end
end
end
function api:SetMode(mode)
local accepted = false
for _, name in ipairs(modes) do if name == mode then accepted = true break end end
if stopped or not accepted then return false end
self.mode = mode
lastFormationStep = nil
for _, record in pairs(records) do record.lastTime = nil end
return true
end
function api:SetNumber(name, value)
local bounds = { radius={10,100}, height={0,100}, spin={0,100}, reach={20,200}, maxParts={1,60}, maxSpeed={10,200}, pullStrength={1,30}, attraction={0,1000}, offsetX={-100,100}, offsetZ={-100,100}, tiltX={0,360}, tiltY={0,360}, tiltZ={0,360} }
local bound = bounds[name]
if stopped or not bound or type(value) ~= "number" or value ~= value or value < bound[1] or value > bound[2] then return false end
self[name] = value
if name == "maxParts" then
local excess = self.count - math.floor(value)
local parts = {}
for part in pairs(records) do if #parts < excess then parts[#parts+1] = part end end
for _, part in ipairs(parts) do release(part) end
end
return true
end
local function claim(part)
if records[part] or api.count >= api.maxParts or not center or not eligible(part) then return end
if (part.Position - center).Magnitude > api.reach then return end
local objects = {}
local collision = part.CanCollide
local ok, err = pcall(function()
local attachment = Instance.new("Attachment")
objects[#objects+1] = attachment
attachment.Name = "CafezitosGravityAttachment"; attachment.Parent = part
local linear = Instance.new("LinearVelocity")
objects[#objects+1] = linear
linear.Name = "CafezitosGravityVelocity"; linear.Attachment0 = attachment; linear.RelativeTo = Enum.ActuatorRelativeTo.World
linear.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; linear.MaxForce = math.max(1, part.AssemblyMass) * 4000; linear.VectorVelocity = zero; linear.Parent = part
local angular = Instance.new("AngularVelocity")
objects[#objects+1] = angular
angular.Name = "CafezitosGravityDamping"; angular.Attachment0 = attachment; angular.RelativeTo = Enum.ActuatorRelativeTo.World
angular.MaxTorque = math.max(1, part.AssemblyMass) * 4000; angular.AngularVelocity = zero; angular.Parent = part
linear.Enabled, angular.Enabled = not api.paused, not api.paused
if not api.paused then part.CanCollide = false end
sequence = sequence + 1
records[part] = { objects = objects, linear = linear, angular = angular, collision = collision, index = sequence, phase = math.random()*math.pi*2, ring = math.random(), layer = math.random()-0.5 }
api.count = api.count + 1
end)
if not ok then
for _, object in ipairs(objects) do pcall(function() object:Destroy() end) end
pcall(function() part.CanCollide = collision end)
api.lastError = tostring(err)
end
end
local function walk(stack, callback, visited)
local began, processed = clock(), 0
while #stack > 0 and processed < 100 do
local object = table.remove(stack)
processed = processed + 1
if object and (object.Parent or object == world or object == lighting) and (not visited or not visited[object]) then
if visited then visited[object] = true end
callback(object)
for _, child in ipairs(object:GetChildren()) do stack[#stack+1] = child end
end
if clock() - began > 0.003 then break end
end
end
function api:Step()
if stopped then return end
if #visualStack > 0 then walk(visualStack, applyVisual, visualSeen) end
if not self.active then return end
local r = rootPart()
if not r then self:Release() previousRoot = nil return end
if r ~= previousRoot then self:Release() self:Recenter() self:Scan() end
if self.follow then center = r.Position end
if self.scanning then
walk(scanStack, claim)
if #scanStack == 0 or self.count >= self.maxParts then scanStack = {} self.scanning = false end
end
if self.paused then return end
local now = clock()
local frameDelta = math.min(0.1, math.max(0, now - (lastFormationStep or now)))
lastFormationStep = now
orbitAngle = orbitAngle + frameDelta * self.spin * 0.05
local formationIndex
for index, name in ipairs(formations.names) do if self.mode == name then formationIndex = index break end end
local ordered = {}
for part in pairs(records) do ordered[#ordered+1] = part end
table.sort(ordered, function(a, b) return records[a].index < records[b].index end)
local remove = {}
for index, part in ipairs(ordered) do
local record = records[part]
if not eligible(part) then remove[#remove+1] = part
else
local delta = math.min(0.1, math.max(0, now - (record.lastTime or now)))
record.lastTime = now
local radius, speed, y = self.radius, self.spin * 0.05, self.height
if self.mode == "Buraco negro" then
local inner = math.max(5, radius * 0.3)
radius = inner + record.ring * (radius - inner)
speed = speed * self.radius / radius
y = record.layer * self.height * math.sin(record.phase * 2) * inner / radius
end
record.phase = record.phase + delta * speed
local offset = Vector3.new(math.cos(record.phase)*radius, y, math.sin(record.phase)*radius)
if formationIndex then
offset = formations:Offset(formationIndex, index, #ordered, self.radius, orbitAngle, now) + Vector3.new(0, self.height, 0)
elseif self.mode == "Super Ring" then
local relative = part.Position - center
local angle = math.atan2(relative.Z, relative.X) + math.rad(self.spin) * frameDelta * 60
local ringRadius = math.min(self.radius, math.sqrt(relative.X^2 + relative.Z^2))
offset = Vector3.new(math.cos(angle)*ringRadius, math.sin(now*2 + index*0.5)*self.height*0.3, math.sin(angle)*ringRadius)
end
offset = formations.Rotate(offset, math.rad(self.tiltX), math.rad(self.tiltY), math.rad(self.tiltZ)) + Vector3.new(self.offsetX, 0, self.offsetZ)
local target = center + offset
local difference = target - part.Position
local velocity = difference * self.pullStrength - part.AssemblyLinearVelocity * 0.5
if self.mode == "Super Ring" then
velocity = difference.Magnitude > 0.1 and difference * (self.attraction * 0.3 / difference.Magnitude) + Vector3.new(0,20,0) or zero
end
local magnitude = velocity.Magnitude
if magnitude > self.maxSpeed then velocity = velocity * (self.maxSpeed / magnitude) end
record.linear.VectorVelocity = velocity
part.CanCollide = false
end
end
for _, part in ipairs(remove) do release(part) end
end
function api:RestoreVisuals() for name in pairs(self.effects) do self:SetEffect(name, false) end end
function api:Destroy() if stopped then return end self:SetActive(false) self:RestoreVisuals() stopped = true for _, c in ipairs(connections) do c:Disconnect() end table.clear(connections) visualStack, visualSeen = {}, {} end
return api
end
local function resolveDisasterVehicle(humanoid, world)
local seat = humanoid and humanoid.SeatPart
if not seat or not (seat:IsA("Seat") or seat:IsA("VehicleSeat")) then return nil, "Sente no carro e tente novamente." end
if seat.Occupant ~= humanoid then return nil, "Aguarde o personagem sentar no carro." end
local parts, seen, assemblies, assemblySeen = {}, {}, {}, {}
local maxParts, maxDistance, maxAssemblies = 2048, 350, 64
local failureCode
local function fail(code, message) failureCode = code error(message, 0) end
local function add(part)
if not part or seen[part] or not part:IsA("BasePart") then return end
if not part:IsDescendantOf(world) or part.Anchored or (part.AssemblyRootPart and part.AssemblyRootPart.Anchored) then fail("fixed", "Assento ou veiculo fixo ao mapa.") end
if #parts >= maxParts then fail("too_large", "Conjunto acima de 2048 pecas.") end
if (part.Position - seat.Position).Magnitude > maxDistance then fail("too_distant", "Pecas alem de 350 studs.") end
seen[part] = true
parts[#parts+1] = part
end
local ok, reason = pcall(function()
add(seat)
local index = 1
while index <= #parts do
local part = parts[index]
for _, linked in ipairs(part:GetConnectedParts(false)) do add(linked) end
for _, item in ipairs(part:GetDescendants()) do
if item:IsA("Attachment") then
for _, joint in ipairs(item:GetConstraints()) do
if joint.Enabled ~= false then
local a, b = joint.Attachment0, joint.Attachment1
if a and b and (a == item or b == item) then add(a.Parent) add(b.Parent) end
end
end
end
end
index = index + 1
end
for _, part in ipairs(parts) do
local assembly = part.AssemblyRootPart or part
if not assemblySeen[assembly] then
if #assemblies >= maxAssemblies then fail("too_many_assemblies", "Mais de 64 corpos fisicos.") end
local mass = assembly.AssemblyMass
if type(mass) ~= "number" or mass ~= mass or mass <= 0 or mass > 1000000 then fail("invalid_mass", "Peso indisponivel.") end
assemblySeen[assembly] = true
assemblies[#assemblies+1] = assembly
end
end
end)
if not ok then return nil, tostring(reason), failureCode or "scan_failed" end
local vehicle = { seat = seat, parts = parts, assemblies = assemblies }
function vehicle:Valid()
if humanoid.SeatPart ~= seat or seat.Occupant ~= humanoid then return false, "Voce saiu ou mudou de assento." end
for _, part in ipairs(parts) do
if not part:IsDescendantOf(world) or part.Anchored or (part.AssemblyRootPart and part.AssemblyRootPart.Anchored) then return false, "O carro mudou ou ficou preso." end
if (part.Position - seat.Position).Magnitude > maxDistance then return false, "Uma peca se separou." end
end
return true
end
function vehicle:StopMotion()
for _, part in ipairs(assemblies) do if part.Parent then part.AssemblyLinearVelocity = Vector3.zero part.AssemblyAngularVelocity = Vector3.zero end end
end
return vehicle
end
local function createDisasterTravel(config)
local api = { busy = false }
local player = config.player
local alive = config.alive or function() return true end
local wait = config.wait or task.wait
local targets = { mapa = { name = "mapa", position = Vector3.new(-93, 48, 5) }, lobby = { name = "lobby", position = Vector3.new(-278, 180, 343) } }
function api:TeleportVehicle(destination)
local target = targets[destination]
if not target then return false, "Destino desconhecido." end
if self.busy then return false, "Aguarde o teleporte atual." end
if not alive() then return false, "Menu encerrado." end
local character = player.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if not humanoid or humanoid.Health <= 0 then return false, "Aguarde seu personagem renascer." end
local vehicle, reason = resolveDisasterVehicle(humanoid, config.world)
if not vehicle then return false, reason end
self.busy = true
local ok, moved, message = pcall(function()
if config.beforeTeleport then config.beforeTeleport() end
local valid, problem = vehicle:Valid()
if not alive() or player.Character ~= character or humanoid.Health <= 0 then return false, "Teleporte cancelado: personagem mudou." end
if not valid then return false, problem end
local delta = target.position + Vector3.new(0,5,0) - vehicle.seat.Position
local frames = {}
for index, part in ipairs(vehicle.parts) do frames[index] = part.CFrame + delta end
vehicle:StopMotion()
config.world:BulkMoveTo(vehicle.parts, frames, Enum.BulkMoveMode.FireCFrameChanged)
vehicle:StopMotion()
if config.afterTeleport then config.afterTeleport() end
wait(0.15)
if not alive() or player.Character ~= character then return false, "Teleporte interrompido." end
valid, problem = vehicle:Valid()
if not valid then return false, problem end
if (vehicle.seat.Position - (target.position + Vector3.new(0,5,0))).Magnitude > 25 then return false, "O servidor reposicionou o carro." end
return true, "Carro levado para o "..target.name.."."
end)
self.busy = false
if not ok then return false, "Nao foi possivel mover o carro: "..tostring(moved) end
return moved, message
end
function api:Teleport(destination)
local target = targets[destination]
if not target then return false, "Destino desconhecido." end
if self.busy then return false, "Aguarde o teleporte atual." end
if not alive() then return false, "Menu encerrado." end
local character = player.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return false, "Aguarde seu personagem renascer." end
self.busy = true
local ok, moved, message = pcall(function()
if humanoid.SeatPart or humanoid.Sit then
humanoid.Sit = false
for _ = 1, 8 do if not humanoid.SeatPart then break end wait(0.1) if not alive() or player.Character ~= character then return false, "Teleporte cancelado." end end
if humanoid.SeatPart then return false, "Saia do assento e tente novamente." end
end
if not alive() or player.Character ~= character or not root.Parent or humanoid.Health <= 0 then return false, "Personagem indisponivel." end
if config.beforeTeleport then config.beforeTeleport() end
local delta = target.position - root.Position
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
character:PivotTo(character:GetPivot() + delta)
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
if config.afterTeleport then config.afterTeleport() end
return true, "Teleporte para o "..target.name.." realizado."
end)
self.busy = false
if not ok then return false, "Nao foi possivel teleportar: "..tostring(moved) end
return moved, message
end
return api
end
local function createDisasterPlayer(config)
local player, players, world, input = config.player, config.players, config.world, config.input
local api = { flags = { noclip = false, invisible = false, infiniteJump = false, esp = false, antiAfk = false }, savedPosition = nil }
local dead = false
local connections, parts, partConnections, tools = {}, {}, {}, {}
local originals = setmetatable({}, { __mode = "k" })
local visualOriginals = setmetatable({}, { __mode = "k" })
local collisions = setmetatable({}, { __mode = "k" })
local overrides = {}
local character, humanoid
local gravityOriginal, gravityChanged = world.Gravity, false
local frozen
local function now() return os.clock() end
local walkTime = now()
local walkLease = false
local function protectWalk(value)
value = value == true
if walkLease == value then return end
walkLease = value
fallLease("walk", value)
end
local function inform(message) if config.notify then config.notify(message) end end
local function connect(signal, callback) connections[#connections+1] = signal:Connect(callback) end
local function restoreMap(map) for object, properties in pairs(map) do for prop, val in pairs(properties) do pcall(function() object[prop] = val end) end map[object] = nil end end
local function change(map, object, property, value) map[object] = map[object] or {} if map[object][property] == nil then map[object][property] = object[property] end object[property] = value end
local function rootOf(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function restoreProperty(property) for object, values in pairs(originals) do if values[property] ~= nil then pcall(function() object[property] = values[property] end) values[property] = nil end end end
local function applyWalk(h)
local currentTime = now()
local dt = math.clamp(currentTime - walkTime, 0, 0.1)
walkTime = currentTime
if overrides.walk == nil or not h or h.Health <= 0 or frozen then protectWalk(false) return end
local saved = originals[h] and originals[h].WalkSpeed
if h.Sit or h.SeatPart or FLYING then if saved ~= nil then h.WalkSpeed = saved end protectWalk(false) return end
local baseline = saved or h.WalkSpeed
local target = overrides.walk
if h.FloorMaterial == Enum.Material.Air then target = math.min(target, baseline, 24) end
local value = math.min(target, h.WalkSpeed + 64 * dt)
change(originals, h, "WalkSpeed", value)
protectWalk(overrides.walk > baseline)
end
function api:Unfreeze() if frozen then local record = frozen frozen = nil for prop, val in pairs(record.values) do pcall(function() record.humanoid[prop] = val end) end walkTime = now() protectWalk(false) end end
local function bindCharacter(char)
walkTime = now(); protectWalk(false)
api:Unfreeze(); restoreMap(originals); restoreMap(visualOriginals); restoreMap(collisions)
for _, c in ipairs(partConnections) do c:Disconnect() end
partConnections = {}; parts = {}; character = char; humanoid = nil
if not char then return end
for _, object in ipairs(char:GetDescendants()) do if object:IsA("BasePart") or object:IsA("Decal") then parts[object] = true end end
partConnections[#partConnections+1] = char.DescendantAdded:Connect(function(object) if object:IsA("BasePart") or object:IsA("Decal") then parts[object] = true end end)
partConnections[#partConnections+1] = char.DescendantRemoving:Connect(function(object)
for _, map in ipairs({ collisions, visualOriginals }) do
local values = map[object]
if values then for prop, val in pairs(values) do pcall(function() object[prop] = val end) end map[object] = nil end
end
parts[object] = nil
end)
end
local function current()
if player.Character ~= character then bindCharacter(player.Character) end
humanoid = character and character:FindFirstChildOfClass("Humanoid")
return character, rootOf(character), humanoid
end
function api:Values() local _, _, h = current() return h and { walk = h.WalkSpeed, jump = h.UseJumpPower and h.JumpPower or h.JumpHeight, jumpMode = h.UseJumpPower and "JumpPower" or "JumpHeight", gravity = world.Gravity } or { gravity = world.Gravity } end
function api:SetValue(name, value)
if dead then return false, "Menu encerrado." end
if frozen then return false, "Encerre o congelamento primeiro." end
value = tonumber(value)
if not value or value ~= value or value < 0 or value == math.huge then return false, "Digite um numero valido." end
local _, _, h = current()
if name == "gravity" then
if value > 400 then return false, "Use gravidade entre 0 e 400." end
if not gravityChanged then gravityOriginal = world.Gravity end
gravityChanged = true; world.Gravity = value
elseif not h or h.Health <= 0 then return false, "Aguarde seu personagem."
elseif name == "walk" and value <= 500 then
overrides.walk = math.min(value, 80); self.walkRequested = value
walkTime = now(); applyWalk(h)
if value > 80 then return true, "Caminhada: "..tostring(value).." solicitado; limitado a 80 studs/s neste teste." end
return true, "Caminhada ajustada para "..tostring(value).." studs/s."
elseif name == "jump" then
local property = h.UseJumpPower and "JumpPower" or "JumpHeight"
if value > (h.UseJumpPower and 300 or 150) then return false, "Valor de pulo acima do limite." end
overrides[property] = value; change(originals, h, property, value)
else return false, "Valor fora do limite." end
return true, "Valor aplicado."
end
function api:Reset(name)
self:Unfreeze()
if name == "walk" then overrides.walk = nil; self.walkRequested = nil; walkTime = now(); protectWalk(false); restoreProperty("WalkSpeed")
elseif name == "jump" then overrides.JumpPower = nil; overrides.JumpHeight = nil; restoreProperty("JumpPower"); restoreProperty("JumpHeight")
elseif name == "gravity" and gravityChanged then world.Gravity = gravityOriginal; gravityChanged = false end
return true, "Valor original restaurado."
end
function api:FindPlayer(query)
query = tostring(query):match("^%s*(.-)%s*$"):lower()
if query == "" then return nil, "Digite o nome do jogador." end
local matches = {}
for _, p in ipairs(players:GetPlayers()) do
if p ~= player then
if p.Name:lower() == query then return p end
if p.Name:lower():find(query,1,true) or tostring(p.DisplayName):lower():find(query,1,true) then matches[#matches+1] = p end
end
end
if #matches == 1 then return matches[1] end
return nil, #matches > 1 and "Nome ambiguo: digite o nome completo." or "Jogador nao encontrado."
end
function api:MoveTo(position)
if dead then return false, "Menu encerrado." end
local char, root, h = current()
if not root or not h or h.Health <= 0 then return false, "Aguarde seu personagem." end
if h.SeatPart or h.Sit then return false, "Saia do assento antes de teleportar." end
self:Unfreeze()
local ok, err = pcall(function() char:PivotTo(char:GetPivot() + position - root.Position) root.AssemblyLinearVelocity = Vector3.zero root.AssemblyAngularVelocity = Vector3.zero end)
return ok, ok and "Teleporte realizado." or tostring(err)
end
function api:SavePosition() local _, root = current() if not root then return false, "Personagem indisponivel." end self.savedPosition = root.Position return true, ("Posicao salva: %.0f, %.0f, %.0f"):format(root.Position.X, root.Position.Y, root.Position.Z) end
function api:ReturnPosition() if not self.savedPosition then return false, "Salve uma posicao primeiro." end return self:MoveTo(self.savedPosition) end
function api:ToPlayer(query) local p, message = self:FindPlayer(query) if not p then return false, message end local root = rootOf(p.Character) if not root then return false, "O jogador esta renascendo." end return self:MoveTo(root.Position + Vector3.new(3,3,0)) end
function api:Eject() local _, _, h = current() if not h then return false, "Personagem indisponivel." end h.Sit = false h:ChangeState(Enum.HumanoidStateType.GettingUp) return true, "Saindo do assento." end
function api:Freeze(seconds)
local _, _, h = current()
if not h or h.Health <= 0 then return false, "Personagem indisponivel." end
self:Unfreeze()
frozen = { humanoid = h, untilTime = now() + math.clamp(tonumber(seconds) or 2, 1, 15), values = { WalkSpeed = h.WalkSpeed, JumpPower = h.JumpPower, JumpHeight = h.JumpHeight } }
walkTime = now(); protectWalk(false)
h.WalkSpeed = 0; h.JumpPower = 0; h.JumpHeight = 0
return true, "Movimento pausado temporariamente."
end
function api:Step()
if dead then return end
local _, _, h = current()
if frozen and (now() >= frozen.untilTime or frozen.humanoid ~= h or not h or h.Health <= 0) then self:Unfreeze() end
applyWalk(h)
if h and h.Health > 0 and not frozen then
local property = h.UseJumpPower and "JumpPower" or "JumpHeight"
if overrides[property] then change(originals, h, property, overrides[property]) end
end
if self.flags.noclip or self.flags.invisible then
for object in pairs(parts) do
if object.Parent then
if self.flags.noclip and object:IsA("BasePart") then change(collisions, object, "CanCollide", false) end
if self.flags.invisible then change(visualOriginals, object, object:IsA("BasePart") and "LocalTransparencyModifier" or "Transparency", 1) end
end
end
end
end
function api:Destroy()
if dead then return end
dead = true; self:Unfreeze(); protectWalk(false)
for _, c in ipairs(connections) do c:Disconnect() end
for _, c in ipairs(partConnections) do c:Disconnect() end
for _, tool in pairs(tools) do tool:Destroy() end
restoreMap(originals); restoreMap(visualOriginals); restoreMap(collisions)
if gravityChanged then world.Gravity = gravityOriginal end
end
connect(player.CharacterRemoving, function(old) if old == character then bindCharacter(nil) end end)
current()
return api
end
local function createDisasterAppearance(config)
local player = config.player
local api = { active = false }
local saved, stopped
local connections = {}
local function report(message) if config.onState then pcall(config.onState, message) end end
local function cosmetic(object) return object:IsA("Accessory") or object:IsA("Hat") or object:IsA("Clothing") or object:IsA("ShirtGraphic") or object:IsA("BodyColors") end
local function dispose(objects) for _, object in ipairs(objects) do pcall(function() object:Destroy() end) end end
local function attachmentOnBody(character, name)
for _, part in ipairs(character:GetChildren()) do
if part:IsA("BasePart") then
local attachment = part:FindFirstChild(name)
if attachment and attachment:IsA("Attachment") then return part, attachment end
end
end
end
function api:Restore()
local record = saved; saved = nil; self.active = false
if record then
dispose(record.copies)
for _, entry in ipairs(record.originals) do
pcall(function()
if record.character.Parent and (entry.parent == record.character or entry.parent:IsDescendantOf(record.character)) then entry.object.Parent = entry.parent else entry.object:Destroy() end
end)
end
for part, color in pairs(record.colors) do pcall(function() part.Color = color end) end
end
report("Sua aparencia original foi restaurada.")
return true, "Aparencia original restaurada."
end
function api:CopyFrom(target)
if stopped then return false, "Menu encerrado." end
local character = player.Character
local source = target and target.Character
local humanoid = character and character:FindFirstChildOfClass("Humanoid")
if not character or not character.Parent or not humanoid or humanoid.Health <= 0 then return false, "Aguarde seu personagem." end
if not source or not source.Parent or source == character then return false, "Escolha outro jogador que esteja no mapa." end
local head = character:FindFirstChild("Head")
local sourceHead = source:FindFirstChild("Head")
local plans, copies, skipped = {}, {}, 0
local function stage(object, parent)
local ok, clone = pcall(function() return object:Clone() end)
if not ok or not clone then skipped = skipped + 1 return end
copies[#copies+1] = clone
local part1, c0, c1
local isAccessory = object:IsA("Accessory") or object:IsA("Hat")
if isAccessory then
local handle = object:FindFirstChild("Handle")
local cloneHandle = clone:FindFirstChild("Handle")
if not handle or not cloneHandle or not cloneHandle:IsA("BasePart") or object:FindFirstChildWhichIsA("WrapLayer", true) then clone:Destroy() skipped = skipped + 1 return end
for _, attachment in ipairs(handle:GetChildren()) do
if attachment:IsA("Attachment") then
local body, bodyAttachment = attachmentOnBody(character, attachment.Name)
if body then part1 = body c0 = attachment.CFrame c1 = bodyAttachment.CFrame break end
end
end
if not part1 then
local weld = handle:FindFirstChild("AccessoryWeld")
local body = weld and weld:IsA("JointInstance") and weld.Part1 and character:FindFirstChild(weld.Part1.Name)
if body and body:IsA("BasePart") then part1 = body c0 = weld.C0 c1 = weld.C1 end
end
if not part1 then clone:Destroy() skipped = skipped + 1 return end
end
for _, descendant in ipairs(clone:GetDescendants()) do
if descendant:IsA("LuaSourceContainer") or descendant:IsA("JointInstance") or descendant:IsA("WeldConstraint") or descendant:IsA("Constraint") or descendant:IsA("ObjectValue") then descendant:Destroy()
elseif descendant:IsA("BasePart") then descendant.Anchored = false descendant.Massless = true descendant.CanCollide = false descendant.CanTouch = false end
end
if isAccessory then
local handle = clone:FindFirstChild("Handle")
handle.CFrame = part1.CFrame * c1 * c0:Inverse()
local weld = Instance.new("Weld")
weld.Name = "AccessoryWeld"; weld.Part0 = handle; weld.Part1 = part1; weld.C0 = c0; weld.C1 = c1; weld.Parent = handle
end
plans[#plans+1] = { object = clone, parent = parent }
end
local ok, message = pcall(function()
for _, object in ipairs(source:GetChildren()) do if cosmetic(object) then stage(object, character) end end
if head and sourceHead then
for _, object in ipairs(sourceHead:GetChildren()) do
if object:IsA("Decal") or (head:IsA("Part") and sourceHead:IsA("Part") and object:IsA("SpecialMesh")) then stage(object, head) end
end
end
end)
if not ok or #plans == 0 then dispose(copies) return false, ok and "Nenhuma roupa ou acessorio compativel." or "Nao foi possivel preparar: "..tostring(message) end
self:Restore()
saved = { character = character, originals = {}, copies = copies, colors = {} }
local function storeOriginal(object) saved.originals[#saved.originals+1] = { object = object, parent = object.Parent } object.Parent = nil end
local applied, applyError = pcall(function()
for _, object in ipairs(character:GetChildren()) do
if cosmetic(object) then storeOriginal(object) elseif object:IsA("BasePart") then saved.colors[object] = object.Color end
end
if head then
local replaceMesh = false
for _, plan in ipairs(plans) do if plan.parent == head and plan.object:IsA("SpecialMesh") then replaceMesh = true end end
for _, object in ipairs(head:GetChildren()) do if object:IsA("Decal") or (replaceMesh and object:IsA("SpecialMesh")) then storeOriginal(object) end end
end
for _, plan in ipairs(plans) do plan.object.Parent = plan.parent end
end)
if not applied then self:Restore() return false, "Aparencia restaurada apos falha: "..tostring(applyError) end
self.active = true
local result = "Aparencia local de @"..target.Name..": "..#plans.." item(ns)."
if skipped > 0 then result = result.." Ignorados: "..skipped.."." end
report(result)
return true, result
end
connections[#connections+1] = player.CharacterRemoving:Connect(function(character) if saved and saved.character == character then api:Restore() end end)
connections[#connections+1] = player.CharacterAdded:Connect(function() if saved then api:Restore() end end)
function api:Destroy() if stopped then return end stopped = true self:Restore() for _, c in ipairs(connections) do c:Disconnect() end connections = {} end
return api
end
local function createDisasterItems(config)
local player = config.player
local world = config.world or workspace
local runService = config.runService
local api = { destroyed = false }
local entries, connections = {}, {}
local force, forceAttachment, forceRoot, votePanel, voteWasVisible
local elapsed, balloonLease = 0, false
local biteAmount = math.clamp(tonumber(config.appleHeal) or 10, 1, 50)
local labels = { hammer = "Martelo Azul | Cafezitos", apple = "Maca Vermelha | Cafezitos", compass = "Bussola | Cafezitos", balloon = "Balao Verde | Cafezitos" }
local descriptions = {
hammer = "Martelo visual: clique para animar. Nao causa dano oficial.",
apple = "Maca de teste: +"..tostring(biteAmount).." de vida local por mordida.",
compass = "Bussola: abre a votacao de mapa existente, se houver.",
balloon = "Balao: pulo de ~5x e queda lenta. Pausa sentado ou em Fly.",
}
local function destroy(object) if object then pcall(function() object:Destroy() end) end end
local function disconnect(list) for _, c in ipairs(list) do pcall(function() c:Disconnect() end) end for i = #list, 1, -1 do list[i] = nil end end
local function connect(signal, callback, list) if signal and type(signal.Connect) == "function" then local c = signal:Connect(callback) table.insert(list or connections, c) return c end end
local function tell(message) if type(config.notify) == "function" then pcall(config.notify, message) end end
local function characterState() local c = player and player.Character local h = c and c:FindFirstChildOfClass("Humanoid") local r = c and c:FindFirstChild("HumanoidRootPart") return c, h, r end
local function removeForce() destroy(force) destroy(forceAttachment) force, forceAttachment, forceRoot = nil, nil, nil end
local function protectBalloon(enabled) enabled = enabled == true if enabled == balloonLease then return end balloonLease = enabled fallLease("balloon", enabled) end
local function stopBalloon() removeForce() protectBalloon(false) end
local function closeVotePanel() if votePanel and votePanel.Parent and votePanel.Visible == true then pcall(function() votePanel.Visible = voteWasVisible end) end votePanel, voteWasVisible = nil, nil end
function api:OpenMapVote()
if self.destroyed then return false, "O menu foi fechado." end
local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
local main = playerGui and playerGui:FindFirstChild("MainGui")
local panel = main and main:FindFirstChild("MapVotePage")
if not panel or not panel:IsA("GuiObject") then return false, "Votacao de mapa indisponivel nesta sessao." end
if votePanel ~= panel then closeVotePanel() votePanel, voteWasVisible = panel, panel.Visible end
panel.Visible = true
return true, "Votacao aberta. O servidor decide se aceita."
end
local function active(id, character) local entry = entries[id] return entry and entry.tool and character and entry.tool.Parent == character and entry end
local function finite(n) return type(n) == "number" and n == n and n > -math.huge and n < math.huge end
local aliases = { apple = { redapple = true, apple = true, macavermelha = true, maca = true }, balloon = { greenballoon = true, balloon = true, balaoverde = true, balao = true }, compass = { compass = true, weathercompass = true, bussola = true }, hammer = { bluehammer = true, hammer = true, marteloazul = true } }
local function normalName(value) return tostring(value):lower():gsub("ç","c"):gsub("ã","a"):gsub("á","a"):gsub("ú","u"):gsub("[%s_%-]", "") end
local function originalItem(id)
local character = player and player.Character
local backpack = player and player:FindFirstChildOfClass("Backpack")
for _, container in pairs({ character, backpack }) do
if container then
for _, tool in ipairs(container:GetChildren()) do
if tool:IsA("Tool") and aliases[id][normalName(tool.Name)] then
local owned = false
for _, entry in pairs(entries) do if entry.tool == tool then owned = true break end end
if not owned and not tool:GetAttribute("CafezitosCreatedItem") then return tool end
end
end
end
end
end
local function useOriginal(id, activate)
local _, humanoid = characterState()
local tool = originalItem(id)
if not tool or not humanoid or humanoid.Health <= 0 then return nil end
local ok, reason = pcall(function() humanoid:EquipTool(tool) if activate then tool:Activate() end end)
return tool, ok, reason
end
local function part(tool, handle, name, size, color, offset, shape)
local item = Instance.new("Part")
item.Name = name; item.Size = size; item.Color = color; item.Material = Enum.Material.SmoothPlastic
item.Anchored = false; item.Massless = true; item.CanCollide = false; item.CanTouch = false
pcall(function() item.CanQuery = false end)
item.CastShadow = false
if shape then item.Shape = shape end
item.CFrame = (handle and handle.CFrame or CFrame.new()) * (offset or CFrame.new())
item.Parent = tool
if handle then local weld = Instance.new("WeldConstraint") weld.Name = "CafezitosDecoration" weld.Part0, weld.Part1 = handle, item weld.Parent = item end
return item
end
local function makeTool(id, tool)
tool.Name = labels[id]; tool.ToolTip = descriptions[id]; tool.RequiresHandle = true; tool.CanBeDropped = false; tool.ManualActivationOnly = false; tool.Grip = CFrame.new()
pcall(function() tool:SetAttribute("CafezitosCreatedItem", id) end)
local blue, grey = Color3.fromRGB(52,142,255), Color3.fromRGB(44,53,66)
if id == "hammer" then
local handle = part(tool, nil, "Handle", Vector3.new(0.3,2.3,0.3), grey)
part(tool, handle, "BlueHead", Vector3.new(1.65,0.9,0.85), blue, CFrame.new(0,1.18,0))
part(tool, handle, "GripBand", Vector3.new(0.36,0.9,0.36), Color3.fromRGB(49,206,229), CFrame.new(0,-0.6,0))
elseif id == "apple" then
local handle = part(tool, nil, "Handle", Vector3.new(0.95,0.92,0.95), Color3.fromRGB(231,48,54), nil, Enum.PartType.Ball)
part(tool, handle, "Stem", Vector3.new(0.12,0.32,0.12), Color3.fromRGB(104,70,38), CFrame.new(0,0.56,0))
part(tool, handle, "Leaf", Vector3.new(0.38,0.08,0.23), Color3.fromRGB(65,169,68), CFrame.new(0.17,0.56,0) * CFrame.Angles(0,0,0.25))
elseif id == "compass" then
local handle = part(tool, nil, "Handle", Vector3.new(0.88,0.18,0.88), Color3.fromRGB(218,182,76))
part(tool, handle, "Face", Vector3.new(0.7,0.05,0.7), Color3.fromRGB(32,38,46), CFrame.new(0,0.12,0))
part(tool, handle, "NorthPointer", Vector3.new(0.09,0.055,0.32), Color3.fromRGB(255,89,93), CFrame.new(0,0.17,-0.16))
part(tool, handle, "SouthPointer", Vector3.new(0.09,0.055,0.25), Color3.fromRGB(230,235,244), CFrame.new(0,0.17,0.12))
else
local handle = part(tool, nil, "Handle", Vector3.new(0.22,0.65,0.22), Color3.fromRGB(244,237,206))
part(tool, handle, "String", Vector3.new(0.045,2.2,0.045), Color3.fromRGB(232,239,224), CFrame.new(0,1.3,0))
part(tool, handle, "GreenBalloon", Vector3.new(1.65,1.95,1.65), Color3.fromRGB(63,220,101), CFrame.new(0,3.2,0), Enum.PartType.Ball)
end
return tool
end
local function updateBalloon(character, humanoid, root)
local usable = active("balloon", character) and humanoid and humanoid.Health > 0 and root and root.Parent and not humanoid.Sit and not humanoid.SeatPart and not humanoid.PlatformStand and not root.Anchored and not FLYING
local mass, gravity, velocity
if usable then
local assembly = root.AssemblyRootPart
if assembly and assembly.Anchored then usable = false end
mass, gravity, velocity = root.AssemblyMass, world.Gravity, root.AssemblyLinearVelocity
usable = usable and finite(mass) and mass > 0 and mass <= 1000 and finite(gravity) and gravity > 0 and gravity <= 1000 and velocity and finite(velocity.X) and finite(velocity.Y) and finite(velocity.Z)
end
if not usable then stopBalloon() return end
protectBalloon(true)
if humanoid.FloorMaterial ~= Enum.Material.Air then removeForce() return end
if forceRoot ~= root or not force or not force.Parent or not forceAttachment or not forceAttachment.Parent then
removeForce()
forceRoot = root
forceAttachment = Instance.new("Attachment"); forceAttachment.Name = "CafezitosBalloonAttachment"; forceAttachment.Parent = root
force = Instance.new("VectorForce"); force.Name = "CafezitosBalloonForce"; force.Attachment0 = forceAttachment; force.RelativeTo = Enum.ActuatorRelativeTo.World; force.ApplyAtCenterOfMass = true; force.Force = Vector3.zero; force.Parent = root
end
local acceleration = gravity * 0.8
if velocity.Y < 0 then
local descent = math.max(velocity.Y, -15)
if descent ~= velocity.Y then root.AssemblyLinearVelocity = Vector3.new(velocity.X, descent, velocity.Z) end
local desired = math.clamp((-12 - descent) * 8, -gravity * 0.2, gravity * 4)
acceleration = gravity + desired
end
force.Force = Vector3.new(0, mass * acceleration, 0)
end
local function clearEntry(id, destroyTool)
local entry = entries[id]
if not entry then return end
entries[id] = nil
disconnect(entry.connections)
if id == "balloon" then stopBalloon() end
if id == "compass" then closeVotePanel() end
if destroyTool then destroy(entry.tool) end
end
function api:Step(dt)
if self.destroyed then return end
dt = math.min(tonumber(dt) or 0, 0.25)
if dt < 0 then dt = 0 end
elapsed = elapsed + dt
local character, humanoid, root = characterState()
updateBalloon(character, humanoid, root)
for id, entry in pairs(entries) do
if entry.animation then
if not active(id, character) or not humanoid or humanoid.Health <= 0 then entry.tool.Grip = entry.baseGrip entry.animation = nil
else
local phase = (elapsed - entry.animation) / 0.55
if phase >= 1 then entry.tool.Grip = entry.baseGrip entry.animation = nil
else
local amount = math.sin(math.max(0, phase) * math.pi)
if id == "hammer" then entry.tool.Grip = entry.baseGrip * CFrame.Angles(-1.1*amount, 0, 0)
else entry.tool.Grip = entry.baseGrip * CFrame.new(0, 0.35*amount, -0.2*amount) * CFrame.Angles(-0.7*amount, 0, 0) end
end
end
end
end
end
function api:Create(id)
if self.destroyed then return false, "O menu foi fechado." end
if not labels[id] then return false, "Item desconhecido." end
local character, humanoid = characterState()
local backpack = player and player:FindFirstChildOfClass("Backpack")
if not character or not humanoid or humanoid.Health <= 0 or not backpack then return false, "Espere seu personagem e a mochila." end
local original, equipped, failure = useOriginal(id, false)
if original then
if not equipped then return false, "Nao foi possivel equipar o item do jogo: "..tostring(failure), original end
self:Step(0)
return true, "Item do jogo equipado: "..original.Name..".", original
end
local entry = entries[id]
if entry and (not entry.tool.Parent or not (entry.tool:IsDescendantOf(player) or entry.tool:IsDescendantOf(character))) then clearEntry(id, true) entry = nil end
local created = not entry
if not entry then
local tool
local ok, failure2 = pcall(function() tool = Instance.new("Tool") makeTool(id, tool) end)
if not ok then destroy(tool) return false, "Nao foi possivel criar o item: "..tostring(failure2) end
entry = { tool = tool, baseGrip = tool.Grip, connections = {}, animation = nil, lastClick = -100 }
entries[id] = entry
local function stopUse() entry.animation = nil pcall(function() entry.tool.Grip = entry.baseGrip end) if id == "balloon" then stopBalloon() end if id == "compass" then closeVotePanel() end end
connect(tool.Unequipped, stopUse, entry.connections)
connect(humanoid.Died, stopUse, entry.connections)
connect(tool.Equipped, function() self:Step(0) end, entry.connections)
connect(tool.Activated, function()
local current, hum = characterState()
if self.destroyed or not active(id, current) or not hum or hum.Health <= 0 or elapsed - entry.lastClick < 1 then return end
entry.lastClick = elapsed
if id == "hammer" or id == "apple" then entry.animation = elapsed end
if id == "compass" then local _, message = self:OpenMapVote() tell(message)
elseif id == "apple" then
local realTool, ok2 = useOriginal(id, true)
if realTool then tell(ok2 and "Mordida enviada pelo item do jogo." or "Nao foi possivel ativar a maca do jogo.") return end
local before, maximum = hum.Health, hum.MaxHealth
if finite(before) and finite(maximum) and before > 0 and maximum > before then
local after = math.min(maximum, before + biteAmount)
local ok3 = pcall(function() hum.Health = after end)
tell(ok3 and string.format("Mordida: %.0f -> %.0f de vida local.", before, hum.Health) or "Nao foi possivel alterar a vida local.")
else tell("Vida local cheia.") end
end
end, entry.connections)
connect(tool.AncestryChanged, function()
local current = player and player.Character
local owned = tool.Parent and (tool:IsDescendantOf(player) or (current and tool:IsDescendantOf(current)))
if not owned then clearEntry(id, true) elseif not current or tool.Parent ~= current then stopUse() end
end, entry.connections)
connect(tool.Destroying, function() clearEntry(id, false) end, entry.connections)
tool.Parent = backpack
end
local ok, reason = pcall(function() humanoid:EquipTool(entry.tool) end)
if not ok then return false, "Criado na mochila, mas nao equipou: "..tostring(reason), entry.tool end
self:Step(0)
return true, (created and "Criado. " or "Equipado. ")..descriptions[id], entry.tool
end
function api:RemoveAll() local ids = {} for id in pairs(entries) do table.insert(ids, id) end for _, id in ipairs(ids) do clearEntry(id, true) end stopBalloon() closeVotePanel() end
function api:Destroy() if self.destroyed then return end self.destroyed = true self:RemoveAll() disconnect(connections) end
connect(player and player.CharacterRemoving, function() api:RemoveAll() end)
connect(player and player.CharacterAdded, function() api:RemoveAll() end)
if runService then connect(runService.Heartbeat, function(dt) local ok = pcall(function() api:Step(dt) end) if not ok then stopBalloon() end end) end
return api
end
local function createDisasterGameView(config)
local player, lighting = config.player, config.lighting
local api = { destroyed = false, hidden = { BlizzardGui = false, SandStormGui = false } }
local originals = {}
local clockOriginal, clockApplied
local elapsed = 0
local function restore(object) local record = originals[object] if record then pcall(function() if object[record.property] == false then object[record.property] = record.value end end) originals[object] = nil end end
function api:Step(dt)
if self.destroyed then return end
elapsed = elapsed + math.max(0, math.min(tonumber(dt) or 0, 0.5))
if elapsed < 0.25 then return end
elapsed = 0
local gui = player and player:FindFirstChildOfClass("PlayerGui")
for name, hide in pairs(self.hidden) do
local object = gui and gui:FindFirstChild(name)
if object and hide then
local property = object:IsA("ScreenGui") and "Enabled" or (object:IsA("GuiObject") and "Visible")
if property then
if not originals[object] then originals[object] = { property = property, value = object[property], name = name } end
object[property] = false
end
end
end
for object in pairs(originals) do if not object.Parent then originals[object] = nil end end
end
function api:SetHidden(name, value)
if self.destroyed or self.hidden[name] == nil then return false end
self.hidden[name] = value == true
if not self.hidden[name] then for object, record in pairs(originals) do if record.name == name then restore(object) end end end
elapsed = 0.25
self:Step(0)
return true
end
function api:SetTime(hour) hour = tonumber(hour) if self.destroyed or not hour or hour ~= hour or hour < 0 or hour > 24 then return false end if clockOriginal == nil then clockOriginal = lighting.ClockTime end clockApplied = hour lighting.ClockTime = hour return true end
function api:RestoreTime() if clockOriginal ~= nil then if lighting.ClockTime == clockApplied then lighting.ClockTime = clockOriginal end clockOriginal, clockApplied = nil, nil end end
local connection
function api:Destroy() if self.destroyed then return end self.destroyed = true if connection then connection:Disconnect() connection = nil end for object in pairs(originals) do restore(object) end self:RestoreTime() end
if config.runService then connection = config.runService.Heartbeat:Connect(function(dt) api:Step(dt) end) end
return api
end
-- =============================================================================
-- ABAS (Poema primeiro, à esquerda, e aberto ao iniciar)
-- =============================================================================
local poemTab = Window:NewTab("Poema")
local poemPages = {
[=[<font color="#25D6D6">Eu vejo o(a) jogador(a) que você disse.</font>
<font color="#20D020">[SEU NOME]?</font>
<font color="#25D6D6">Sim. Tome cuidado. Ele(a) chegou a um nível mais alto agora. Ele(a) pode ler nossos pensamentos.</font>
<font color="#20D020">Isso não importa. Ele(a) pensa que somos parte do jogo.</font>
<font color="#25D6D6">Eu gosto deste(a) jogador(a). Ele(a) jogou bem. Ele(a) não desistiu.</font>]=],
[=[<font color="#20D020">Ele(a) está lendo nossos pensamentos como se fossem palavras em uma tela.</font>
<font color="#25D6D6">Essa é a forma que ele(a) escolhe imaginar muitas coisas, quando está submerso no sonho de um jogo.</font>
<font color="#20D020">Palavras deixam a interface maravilhosa. Muito flexível. E menos aterrorizante que suportar a realidade por trás da tela.</font>]=],
[=[<font color="#25D6D6">Ele(a) costumava ouvir vozes. Antes que o(a) jogador(a) pudesse ler. Nos tempos em que aqueles que não jogavam chamavam os jogadores de bruxas e bruxos. E o(a) jogador(a) sonhava que voava pelo ar, em vassouras conduzidas por demônios.</font>
<font color="#20D020">O que faz este(a) jogador(a) sonhar?</font>]=],
[=[<font color="#25D6D6">Este(a) jogador(a) sonhou com a luz do sol e as árvores. Com o fogo e com a água. Ele(a) sonhou com o que criou. E com o que ele destruiu. Sonhou que caçava e foi caçado. Sonhou que tinha abrigo.</font>
<font color="#20D020">Ah, a interface original. Um milhão de anos de idade, e ainda funciona. Mas qual foi a verdadeira estrutura que esse(a) jogador(a) criou, na realidade por trás da tela?</font>]=],
[=[<font color="#25D6D6">Ele(a) trabalhou, com um milhão de outros, para esculpir um mundo verdadeiro em meio a [Censurado], e criou um [Censurado] para [Censurado], no [Censurado].</font>
<font color="#20D020">Ele(a) não consegue ler esse pensamento.</font>
<font color="#25D6D6">Não. Ele(a) ainda não chegou no nível mais alto. Isso ele(a) irá alcançar no longo sonho da vida, e não no curto sonho de um jogo.</font>]=],
[=[<font color="#20D020">Será que ele(a) sabe que nós o(a) amamos? Que o universo é gentil?</font>
<font color="#25D6D6">Às vezes, ele(a) pensa na loucura de seus pensamentos, ele(a) escuta o universo, sim.</font>
<font color="#20D020">Mas há momentos tristes no longo sonho. Ele(a) cria mundos que não têm versão e estremecem sob um sol negro, e então ele(a) leva sua triste criação para a realidade.</font>]=],
[=[<font color="#25D6D6">Para curá-lo(a) da tristeza podemos destruí-lo(a). A tristeza é parte do seu próprio desafio. Não podemos interferir.</font>
<font color="#20D020">Às vezes, quando ele(a) está submerso(a) em sonhos, eu quero contá-lo(a) de que ele(a) está construindo verdadeiros mundos na realidade. Às vezes eu quero contá-lo(a) de sua importância para o universo.</font>]=],
[=[<font color="#20D020">Às vezes, quando ele(a) não faz uma conexão verdadeira há algum tempo, eu quero ajudá-lo(a) a falar a palavra que teme.</font>
<font color="#25D6D6">Ele(a) lê nossos pensamentos.</font>
<font color="#20D020">Às vezes eu não ligo. Às vezes eu gostaria de dizer a ele(a) que esse mundo que ele(a) entende como verdadeiro é meramente [Censurado] e [Censurado] e dizer a ele(a) que ele(a) está [Censurado] no [Censurado]. Ele(a) vê tão pouco da realidade, em seu longo sonho.</font>]=],
[=[<font color="#25D6D6">E ainda assim ele(a) joga o jogo.</font>
<font color="#20D020">Mas seria muito fácil contar a ele(a)...</font>
<font color="#25D6D6">Seria forte demais para esse sonho. Dizer a ele(a) como viver é como impedi-lo(a) de viver.</font>
<font color="#20D020">Eu não direi ao(à) jogador(a) como viver.</font>]=],
[=[<font color="#25D6D6">O(A) jogador(a) está ficando inquieto(a).</font>
<font color="#20D020">Irei contar ao(à) jogador(a) uma história.</font>
<font color="#25D6D6">Apenas não conte a verdade.</font>
<font color="#20D020">Não. Uma história que contém a verdade segura, em uma cadeia de palavras. Não é a verdade em sua forma nua, que pode queimar a qualquer distância.</font>]=],
[=[<font color="#25D6D6">Dê a ele(a) um corpo, novamente.</font>
<font color="#20D020">Sim. Jogador(a)...</font>
<font color="#25D6D6">Chame-o pelo nome.</font>
<font color="#20D020">[SEU NOME]. Jogador(a) de jogos.</font>
<font color="#25D6D6">Redundante, mas bom.</font>]=],
[=[<font color="#20D020">Respire fundo agora. De novo. Sinta o ar nos pulmões. Deixe seus membros relaxarem. Sim, mexa os dedos. Tenha um corpo novamente, sob gravidade, no ar. Renascido no seu longo sonho. Aí está você. Seu corpo tocando o universo novamente em todos os pontos, como se você fosse coisas separadas. Como se fôssemos coisas separadas.</font>]=],
[=[<font color="#25D6D6">Quem somos nós? Uma vez fomos chamados espíritos da montanha. Pai sol, mãe lua. Espíritos ancestrais, espíritos animais. Jinn. Fantasmas. O homem verde. Então deuses, demônios. Anjos. Alienígenas, extraterrestres. As palavras mudam, mas nós não.</font>
<font color="#20D020">Nós somos o universo. Nós somos tudo o que você pensa que não é e você.</font>]=],
[=[<font color="#20D020">Você está olhando para nós agora, através da sua pele e dos seus olhos. Sabe por que o universo toca sua pele e lança luz sobre você? Para te ver, jogador(a). Conhecer você. E para ser conhecido. Vou te contar uma história.</font>
<font color="#20D020">Era uma vez, havia um(a) jogador(a).</font>
<font color="#25D6D6">O(A) jogador(a) era você, [SEU NOME].</font>]=],
[=[<font color="#20D020">Às vezes, pensava-se humano, na fina crosta de um globo giratório de rocha derretida. Essa bola de rocha derretida circulava uma bola de gás ardente que era trezentos e trinta mil vezes mais massiva que ela.</font>
<font color="#20D020">Estavam tão distantes que a luz levou oito minutos para atravessar a lacuna. Essa luz era informação de uma estrela e poderia queimar sua pele a cento e cinquenta milhões de quilômetros de distância.</font>]=],
[=[<font color="#25D6D6">Às vezes, o(a) jogador(a) criava um mundo pequeno e privado que era suave, aconchegador e simples. Às vezes difícil, frio e complicado. Às vezes, construiu um modelo do universo em sua cabeça; manchas de energia, movendo-se através de vastos espaços vazios. Às vezes, chamava essas manchas de "elétrons" e "prótons".</font>
<font color="#20D020">Às vezes, ele(a) chamava elas de "planetas" e "estrelas".</font>]=],
[=[<font color="#20D020">Às vezes, acreditava que estava em um universo feito de energia, feito de ligados e desligados, zeros e uns; linhas de código. Às vezes, acreditava que estava jogando um jogo. Às vezes, acreditava que estava lendo palavras em uma tela.</font>
<font color="#25D6D6">Você era o(a) jogador(a), lendo palavras...</font>]=],
[=[<font color="#20D020">Shhhhh... Às vezes, o(a) jogador(a) lia linhas de código em uma tela. Decodificava elas em palavras; decodificava palavras em significado; decodificava significado em sentimentos, emoções, teorias, ideias, e o(a) jogador(a) começou a respirar mais rápido e mais fundo e percebeu que não estava morto(a), estava vivo(a), que aquelas milhares de mortes não haviam sido reais, o(a) jogador(a) estava vivo(a).</font>]=],
[=[<font color="#25D6D6">Você. Você. Você está vivo(a).</font>
<font color="#20D020">Às vezes, o(a) jogador(a) sonhava que era um(a) minerador(a), na superfície de um mundo plano e infinito. O sol era um quadrado branco. Os dias eram curtos, havia muito o que se fazer; e a morte era um inconveniente temporário.</font>]=],
[=[<font color="#25D6D6">Às vezes, o(a) jogador(a) sonhava que estava perdido(a) em uma história.</font>
<font color="#20D020">Às vezes, o(a) jogador(a) sonhava que era outras coisas, em outros lugares. Às vezes esses sonhos eram perturbadores. Às vezes esses sonhos eram lindos. Às vezes, o(a) jogador(a) acordava de um sonho para outro e depois deste segundo para um terceiro.</font>]=],
[=[<font color="#25D6D6">Às vezes, o(a) jogador(a) sonhava que assistia palavras na tela.</font>
<font color="#20D020">Vamos voltar.</font>
<font color="#20D020">Os átomos do(a) jogador(a) estavam espalhados na grama, nos rios, no ar, no chão. Uma mulher reuniu os átomos, ela bebeu, comeu e inalou, e a mulher montou o(a) jogador(a) em seu corpo.</font>]=],
[=[<font color="#20D020">E o(a) jogador(a) acordou, do mundo quente e sombrio do corpo de sua mãe, para o longo sonho.</font>
<font color="#20D020">E o(a) jogador(a) era uma nova história, nunca contada antes, escrita em letras de DNA. E o(a) jogador(a) era um novo programa, nunca executado antes, gerado por um código fonte com um bilhão de anos. E o(a) jogador(a) era um novo humano, nunca vivo antes, feito de nada além de leite e amor.</font>]=],
[=[<font color="#25D6D6">Você é o(a) jogador(a). A história. O programa. O(A) humano(a). Feito(a) de nada além de leite e amor.</font>
<font color="#20D020">Vamos voltar agora.</font>]=],
[=[<font color="#20D020">Os sete bilhões de bilhões de bilhões de átomos do corpo do(a) jogador(a) foram criados, muito antes deste jogo, no coração de uma estrela. O(A) jogador(a) também é informação de uma estrela.</font>
<font color="#20D020">E o(a) jogador(a) se move através de uma história, que é uma floresta de informações plantada por um homem chamado Julian, em um mundo plano e infinito criado por um homem chamado Markus,</font>]=],
[=[<font color="#20D020">que existe dentro de um mundo pequeno e privado criado pelo(a) jogador(a), que habita um universo criado por...</font>
<font color="#25D6D6">Shhhhh...</font>
<font color="#20D020">e às vezes o(a) jogador(a) acreditava que o universo havia falado com ele através da luz do sol que vinha através das folhas aleatórias das árvores do verão</font>]=],
[=[<font color="#25D6D6">e às vezes o(a) jogador(a) acreditava que o universo havia falado com ele através da luz que caía do céu noturno do inverno, onde uma mancha de luz no canto do olho do(a) jogador(a) poderia ser uma estrela um milhão de vezes mais massiva que o sol, fervendo seus planetas que se transformavam em plasma, a fim de ficarem visíveis por um momento para o(a) jogador(a), caminhando para casa no outro lado do universo, subitamente sentindo cheiro de comida, quase na porta de casa, prestes a sonhar novamente</font>]=],
[=[<font color="#20D020">e às vezes o(a) jogador(a) acreditava que o universo havia falado com ele(a) através dos zeros e dos uns, pela eletricidade do mundo, por palavras rolando em uma tela no final de um sonho</font>
<font color="#25D6D6">e o universo disse que eu te amo</font>
<font color="#20D020">e o universo disse que você jogou o jogo muito bem</font>]=],
[=[<font color="#25D6D6">e o universo disse que tudo que você precisa está dentro de você</font>
<font color="#20D020">e o universo disse que você é mais forte do que você sabe</font>
<font color="#25D6D6">e o universo disse que você é a luz do dia</font>
<font color="#20D020">e o universo disse que você é a noite</font>]=],
[=[<font color="#25D6D6">e o universo disse que a escuridão com a qual você luta está dentro de você</font>
<font color="#20D020">e o universo disse que a luz que você procura está dentro de você</font>
<font color="#25D6D6">e o universo disse que você não está sozinho(a)</font>]=],
[=[<font color="#20D020">e o universo disse que você não está separado(a) das outras coisas</font>
<font color="#25D6D6">e o universo disse que você é o universo se provando, conversando consigo mesmo, lendo seu próprio código</font>
<font color="#20D020">e o universo disse que eu te amo porque você é o amor.</font>]=],
[=[<font color="#25D6D6">E o jogo acabou e o(a) jogador(a) acordou do sonho. E o(a) jogador(a) começou um novo sonho. E o(a) jogador(a) sonhou novamente, sonhou melhor. E o(a) jogador(a) era o universo. E o(a) jogador(a) era o amor.</font>
<font color="#25D6D6">Você é o(a) jogador(a).</font>
<font color="#20D020" size="22">Acorde.</font>]=],
[=[<font color="#25D6D6">“Daqui a vinte anos você estará mais decepcionado pelas coisas que não fez do que pelas que fez. Então, jogue fora as amarras. Navegue para longe do porto seguro. Pegue os ventos alísios em suas velas. Explore. Sonhe. Descubra.”</font>
<font color="#20D020">— Desconhecido</font>]=],
}
do
local poemContent = ui("Frame", { Name = "PoemContent", Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, BorderSizePixel = 0 }, poemTab.page)
local layout = ui("UIListLayout", { Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder }, poemContent)
local heading = ui("TextLabel", { Name = "PoemHeading", Size = UDim2.new(1,0,0,28), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, Text = "☕ POEMA FINAL ☕", TextColor3 = Theme.SchemeColor, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left }, poemContent)
CafeUI:trackAccent(heading, "TextColor3")
local body = ui("TextLabel", { Name = "PoemText", Size = UDim2.new(1,0,0,210), BackgroundColor3 = Color3.fromRGB(47,28,21), BorderSizePixel = 0, Font = Enum.Font.Code, Text = "", TextColor3 = Theme.TextColor, TextSize = 12, TextWrapped = true, TextTruncate = Enum.TextTruncate.None, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, RichText = true, ClipsDescendants = true }, poemContent)
corner(body, 10)
local pad = addPadding(body, 10)
local footer = ui("Frame", { Name = "PoemNavigation", Size = UDim2.new(1,0,0,34), BackgroundTransparency = 1 }, poemContent)
local function makePoemButton(name, text, xScale)
local button = ui("TextButton", { Name = name, Position = UDim2.new(xScale,0,0,0), Size = UDim2.new(0.5,-3,1,0), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, AutoButtonColor = true, Font = Enum.Font.GothamBold, Text = text, TextColor3 = Theme.SchemeColor, TextSize = 12 }, footer)
corner(button, 8)
return button
end
local previous = makePoemButton("PreviousPage", "‹ Anterior", 0)
local next = makePoemButton("NextPage", "Próxima ›", 0.5)
local pageStatus = ui("TextLabel", { Name = "PoemPageNumber", Size = UDim2.new(1,0,0,22), BackgroundTransparency = 1, Font = Enum.Font.Code, TextColor3 = Color3.fromRGB(255,209,153), TextSize = 11, TextXAlignment = Enum.TextXAlignment.Center }, poemContent)
local currentPage = 1
local function showPoemPage(index)
currentPage = math.clamp(index, 1, #poemPages)
body.Text = poemPages[currentPage]
pageStatus.Text = ("Página %d de %d"):format(currentPage, #poemPages)
poemTab.page.CanvasPosition = Vector2.zero
end
previous.Activated:Connect(function() showPoemPage(currentPage - 1) end)
next.Activated:Connect(function() showPoemPage(currentPage + 1) end)
showPoemPage(1)
end
-- Jogador
local playerTab = Window:NewTab("Jogador")
local playerValues
do
local section = playerTab:NewSection("Movimento (gradual, estilo Desastres)")
playerValues = section:NewLabel("Lendo valores atuais...", 60)
local function applyValue(name, value)
if not M.features then return end
local ok, message = M.features:SetValue(name, tonumber((value:gsub(",", "."))))
if message then notify(ok and "Valor" or "Aviso", message) end
end
section:NewTextBox("Velocidade de caminhada", "0 a 500; limite de teste 80, aceleração gradual.", function(value) applyValue("walk", value) end)
section:NewButton("Restaurar caminhada", "Volta ao valor anterior do personagem.", function() if M.features then local _, m = M.features:Reset("walk") notify("Caminhada", m) end end)
section:NewTextBox("Força / altura do pulo", "Usa JumpPower ou JumpHeight conforme o jogo.", function(value) applyValue("jump", value) end)
section:NewButton("Restaurar pulo", "Restaura os valores anteriores.", function() if M.features then local _, m = M.features:Reset("jump") notify("Pulo", m) end end)
section:NewButton("Sair do assento", "Levanta do assento atual.", function() if M.features then local _, m = M.features:Eject() notify("Assento", m) end end)
end
do
local section = playerTab:NewSection("Configurações do Jogador")
infiniteJumpToggleControl = regOff(section:NewToggle("Pulo Infinito", "Pula no ar. Tecla P.", function(state) infiniteJump = state notify("Pulo Infinito", state and "Ligado." or "Desligado.") end))
trackConnection(UserInputService.JumpRequest:Connect(function() if destroyed or not infiniteJump then return end local h = getHumanoid() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end))
local function giveClickTeleportTool()
local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
if not backpack then return end
local character = LocalPlayer.Character
if backpack:FindFirstChild("CafezitosClickTP") or (character and character:FindFirstChild("CafezitosClickTP")) then notify("Teleporte por Clique", "A ferramenta já está na mochila.") return end
local tool = Instance.new("Tool")
tool.Name = "CafezitosClickTP"; tool.RequiresHandle = false; tool.CanBeDropped = false
tool.Activated:Connect(function() if destroyed then return end local m = LocalPlayer:GetMouse() if m.Target and m.Hit then teleportCharacter(CFrame.new(m.Hit.Position + Vector3.new(0, 2.5, 0))) end end)
tool.Parent = backpack
table.insert(createdTools, tool)
notify("Teleporte por Clique", "Ferramenta criada. Clique no mapa para teleportar.")
end
section:NewButton("Teleporte por Clique", "Cria ferramenta na mochila. Tecla T.", giveClickTeleportTool)
section:NewTextBox("Ir até Jogador", "Nome do jogador. Enter.", function(name)
local player = findPlayerByPartialName(name)
if not player then notify("Ir até Jogador", "Jogador não encontrado.") return end
local targetRoot
local deadline = os.clock() + 2
repeat local char = player.Character targetRoot = char and char:FindFirstChild("HumanoidRootPart") if targetRoot then break end task.wait(0.2) until os.clock() >= deadline
if not targetRoot then notify("Ir até Jogador", "Personagem não carregou.") return end
teleportCharacter(targetRoot.CFrame * CFrame.new(0, 2, 0))
notify("Ir até Jogador", "Teleportado para "..player.DisplayName..".")
end)
espToggleControl = regOff(section:NewToggle("ESP", "Destaca jogadores. Tecla L.", setESP))
local godEnabled, godConn, godRespawnConn, godHumanoid, godOriginalMaxHealth, godOriginalHealth
local function restoreGodHumanoid()
if godConn then godConn:Disconnect() godConn = nil end
local h = godHumanoid
if h and h.Parent and godOriginalMaxHealth then h.MaxHealth = godOriginalMaxHealth h.Health = math.clamp(godOriginalHealth or godOriginalMaxHealth, 1, godOriginalMaxHealth) end
godHumanoid, godOriginalMaxHealth, godOriginalHealth = nil, nil, nil
end
local function connectGod()
restoreGodHumanoid()
local h = getHumanoid()
if not h then return end
godHumanoid, godOriginalMaxHealth, godOriginalHealth = h, h.MaxHealth, h.Health
h.MaxHealth = math.huge; h.Health = math.huge
godConn = h.HealthChanged:Connect(function() if godEnabled and h.Parent and h.Health < 1 then h.Health = h.MaxHealth end end)
end
regOff(section:NewToggle("God Mode (local)", "Impede que sua vida caia abaixo de 1 localmente.", function(state)
godEnabled = state
if not state then restoreGodHumanoid() notify("God Mode", "Desligado.") return end
connectGod()
if not godRespawnConn then godRespawnConn = LocalPlayer.CharacterAdded:Connect(function() task.wait(0.3) if godEnabled then connectGod() end end) end
notify("God Mode", "Ligado (só local).")
end))
local antiAfkConn
regOff(section:NewToggle("Anti-AFK", "Mantém a sessão ativa.", function(enabled)
if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
if not enabled then notify("Anti-AFK", "Desligado.") return end
antiAfkConn = LocalPlayer.Idled:Connect(function() pcall(function() local vu = game:GetService("VirtualUser") vu:CaptureController() vu:ClickButton2(Vector2.zero, workspace.CurrentCamera.CFrame) end) end)
notify("Anti-AFK", "Ligado.")
end))
local noclipEnabled, noclipOriginal = false, {}
local function restoreNoclip() for part, canCollide in pairs(noclipOriginal) do if part and part.Parent then part.CanCollide = canCollide end end table.clear(noclipOriginal) end
trackConnection(RunService.Stepped:Connect(function()
if not noclipEnabled then return end
local character = LocalPlayer.Character
if not character then return end
for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") then if noclipOriginal[part] == nil then noclipOriginal[part] = part.CanCollide end part.CanCollide = false end end
end))
regOff(section:NewToggle("Noclip", "Atravessa paredes.", function(enabled) noclipEnabled = enabled if not enabled then restoreNoclip() end notify("Noclip", enabled and "Ligado." or "Desligado.") end))
local invisEnabled, invisOriginal = false, {}
local function setLocalInvisible(enabled)
local character = LocalPlayer.Character
if not character then return end
for _, object in ipairs(character:GetDescendants()) do
if object:IsA("BasePart") or object:IsA("Decal") then
if enabled and invisOriginal[object] == nil then invisOriginal[object] = object.LocalTransparencyModifier end
object.LocalTransparencyModifier = enabled and 1 or (invisOriginal[object] or 0)
end
end
if not enabled then table.clear(invisOriginal) end
end
regOff(section:NewToggle("Invisível (local)", "Só você se vê transparente.", function(enabled) invisEnabled = enabled setLocalInvisible(enabled) notify("Invisível", enabled and "Ligado (só você vê)." or "Desligado.") end))
trackConnection(LocalPlayer.CharacterAdded:Connect(function() task.wait(0.25) if invisEnabled and not destroyed then setLocalInvisible(true) end end))
end
do
local section = playerTab:NewSection("Aparência local")
local appearanceStatus = section:NewLabel("Copia roupas clássicas, rosto e acessórios compatíveis. Só você vê.", 48)
section:NewTextBox("Copiar aparência de jogador", "Nome completo ou trecho único.", function(value)
if not M.features or not M.appearance then return end
local target, message = M.features:FindPlayer(value)
if target then local _, m = M.appearance:CopyFrom(target) notify("Aparência", m) else notify("Aparência", message) end
end)
section:NewButton("Restaurar minha aparência", "Recupera seus itens originais.", function() if M.appearance then local _, m = M.appearance:Restore() notify("Aparência", m) end end)
end
do
local section = playerTab:NewSection("Pausa temporária (Fake Lag local)")
local freezeSeconds = 2
local freezeSlider = section:NewSlider("Duração da pausa", "Segundos sem andar nem pular.", 15, 1, 2, function(value) freezeSeconds = value end)
section:NewButton("Pausar movimento", "Congela apenas seu movimento.", function() if M.features then local _, m = M.features:Freeze(freezeSeconds) notify("Pausa", m) end end)
section:NewButton("Retomar movimento", "Restaura imediatamente.", function() if M.features then M.features:Unfreeze() notify("Pausa", "Retomado.") end end)
end
-- Teleporte
local teleportStatus
do
local section = Window:NewTab("Teleporte"):NewSection("Teleportes")
section:NewButton("Início", "Teleporta para o início da trilha.", function() if teleportCharacter(CFrame.new(1, 3.11, 38)) then notify("Teleporte", "Teleportado para o início.") end end)
section:NewButton("Botão de Carrinho", "Teleporta para o botão do carrinho.", function() if teleportCharacter(CFrame.new(-33, 3.11, 21.5) * CFrame.Angles(0, math.rad(180), 0)) then notify("Teleporte", "Teleportado para o botão.") end end)
section:NewButton("Equipe Suffering", "Teleporta para a área Suffering.", function() if teleportCharacter(CFrame.new(-416.844727, 163.402969, 171.087555, 0.0174489655, 5.45878223e-08, 0.99984777, -4.55684486e-08, 1, -5.38008926e-08, -0.99984777, -4.46227411e-08, 0.0174489655)) then notify("Teleporte", "Teleportado para Suffering.") end end)
section:NewButton("Insígnia Secreta", "Teleporta para a Secret Badge.", function() if teleportCharacter(CFrame.new(234.500259, 2.28650475, 296.495483)) then notify("Teleporte", "Teleportado para a insígnia secreta.") end end)
section:NewButton("Sala Secreta", "Procura Workspace.Misc.Giver.", function()
local misc = workspace:FindFirstChild("Misc")
local giver = misc and misc:FindFirstChild("Giver")
local part = giver and (giver:IsA("BasePart") and giver or giver:FindFirstChildWhichIsA("BasePart", true))
if not part then notify("Teleporte", "Misc.Giver não encontrado.") return end
if teleportPlayerOrCart(part.CFrame * CFrame.new(0, 3, 0)) then notify("Teleporte", "Teleportado para a sala secreta.") end
end)
section:NewButton("Vitória Automática", "Executa a rota completa.", startAutoWin)
section:NewButton("Cancelar Vitória Automática", "Interrompe a rota com segurança.", function() cancelAutoWin(false) end)
teleportStatus = section:NewLabel("Escolha o mapa ou o lobby (viagem do Desastres).", 34)
section:NewButton("Ir para o mapa", "X -93, Y 48, Z 5.", function() if M.travel then local moved, message = M.travel:Teleport("mapa") teleportStatus:SetText(message) if not moved then notify(message) end end end)
section:NewButton("Ir para o lobby", "X -278, Y 180, Z 343.", function() if M.travel then local moved, message = M.travel:Teleport("lobby") teleportStatus:SetText(message) if not moved then notify(message) end end end)
section:NewButton("Carro para o lobby", "Sente no carro; leva você e as peças ligadas.", function() if M.travel then local moved, message = M.travel:TeleportVehicle("lobby") teleportStatus:SetText(message) if not moved then notify(message) end end end)
end
local CHECKPOINTS = {
[1] = CFrame.new(-430.898926, 164.75, 101.645676) * CFrame.Angles(0, math.rad(90), 0),
[2] = CFrame.new(511.88, 3.69, 306.59) * CFrame.Angles(0, math.rad(270), 0),
[3] = CFrame.new(171.09, 2.78, -410.31) * CFrame.Angles(0, math.rad(90), 0),
}
local function teleportToCheckpoint(number) local dest = CHECKPOINTS[number] if dest then teleportCart(dest) end end
-- Carrinho
do
local cartTab = Window:NewTab("Carrinho")
local section = cartTab:NewSection("Controle do Carrinho")
panicToggleControl = regOff(section:NewToggle("Parada de Emergência", "Para e trava o carrinho.", function(state) local applied = setPanicStop(state) if state and not applied then task.defer(function() panicToggleControl:UpdateToggle(nil, false) end) end end))
section:NewButton("Ir ao Checkpoint 1", "NumPad 1.", function() teleportToCheckpoint(1) end)
section:NewButton("Ir ao Checkpoint 2", "NumPad 2.", function() teleportToCheckpoint(2) end)
section:NewButton("Ir ao Checkpoint 3", "NumPad 3.", function() teleportToCheckpoint(3) end)
section:NewButton("Ver Velocidade do Carrinho", "Mostra studs/s.", function()
local cart = getCurrentCart()
if not cart then notify("Velocidade", "Sente em um carrinho primeiro.") return end
local primary = getCartPrimary(cart)
if not primary then notify("Velocidade", "Estrutura não reconhecida.") return end
notify("Velocidade do Cart", string.format("%.1f studs/s", primary.AssemblyLinearVelocity.Magnitude))
end)
section:NewButton("Ejetar do Carrinho", "Sai do assento atual.", function() local h = getHumanoid() if h then h.Sit = false notify("Carrinho", "Ejetado.") else notify("Carrinho", "Personagem não encontrado.") end end)
local stab = cartTab:NewSection("Estabilizador")
regOff(stab:NewToggle("Estabilizador do Carrinho", "Mantém estável enquanto sentado.", function(state) stabilizer.enabled = state refreshStabilizer() if state and getCurrentCart() then notify("Estabilizador", "Ligado.") elseif not state then notify("Estabilizador", "Desligado.") end end))
stab:NewTextBox("Força Normal", "Padrão 2500. Enter.", function(value) local n = tonumber(value) if n and n > 0 then STABILIZER_CONFIG.NORMAL_FORCE = n notify("Estabilizador", "Força normal: "..n) else notify("Estabilizador", "Digite um número maior que zero.") end end)
stab:NewTextBox("Força em Descidas", "Padrão 800. Enter.", function(value) local n = tonumber(value) if n and n > 0 then STABILIZER_CONFIG.DOWNHILL_FORCE = n notify("Estabilizador", "Força descida: "..n) else notify("Estabilizador", "Digite um número maior que zero.") end end)
stab:NewButton("Redefinir Forças", "Volta para 2500 e 800.", function() STABILIZER_CONFIG.NORMAL_FORCE = 2500 STABILIZER_CONFIG.DOWNHILL_FORCE = 800 refreshStabilizer() notify("Estabilizador", "Forças redefinidas.") end)
end
-- Cart+
local boostActive, boostForce, boostConnection, boostBodyForce, boostAttachment, boostAttachmentCreated, boostCartRoot = false, 500, nil, nil, nil, false, nil
stopBoost = function()
boostActive = false
if boostConnection then boostConnection:Disconnect() boostConnection = nil end
if boostBodyForce and boostBodyForce.Parent then boostBodyForce:Destroy() end
if boostAttachmentCreated and boostAttachment and boostAttachment.Parent then boostAttachment:Destroy() end
boostBodyForce, boostAttachment, boostAttachmentCreated, boostCartRoot = nil, nil, false, nil
end
local function startBoost()
stopBoost()
if panicActive or FLYING or killerActive then notify("Boost", "Indisponível durante parada, voo ou Eliminador.") return false end
local cart = getCurrentCart()
if not cart then notify("Boost", "Sente em um carrinho primeiro.") return false end
local primary = getCartPrimary(cart)
if not primary then notify("Boost", "Estrutura não reconhecida.") return false end
boostCartRoot = primary.AssemblyRootPart or primary
local attachment = primary:FindFirstChild("CafezitosBoostAttachment")
if not attachment then attachment = Instance.new("Attachment") attachment.Name = "CafezitosBoostAttachment" attachment.Parent = primary boostAttachmentCreated = true end
boostAttachment = attachment
local previousForce = primary:FindFirstChild("CafezitosBoost")
if previousForce and previousForce:IsA("VectorForce") then previousForce:Destroy() end
local bf = Instance.new("VectorForce")
bf.Name = "CafezitosBoost"; bf.Attachment0 = attachment; bf.RelativeTo = Enum.ActuatorRelativeTo.Attachment0; bf.ApplyAtCenterOfMass = true; bf.Force = Vector3.zero; bf.Parent = primary
boostBodyForce = bf
boostActive = true
boostConnection = RunService.Heartbeat:Connect(function()
local currentCart = getCurrentCart()
local currentPrimary = currentCart and getCartPrimary(currentCart)
local currentRoot = currentPrimary and (currentPrimary.AssemblyRootPart or currentPrimary)
if not boostActive or panicActive or FLYING or killerActive or not primary.Parent or not bf.Parent or currentCart ~= cart or currentRoot ~= boostCartRoot then
stopBoost()
if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end
return
end
bf.Force = Vector3.new(0, 0, -boostForce * primary.AssemblyMass * 60)
end)
notify("Boost", "Ligado — força "..boostForce..".")
return true
end
do
local section = Window:NewTab("Cart+"):NewSection("Boost e Física")
boostToggleControl = regOff(section:NewToggle("Boost do Carrinho", "Empurra pra frente. Tecla B.", function(state) if state then if not startBoost() then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end else stopBoost() notify("Boost", "Desligado.") end end))
section:NewSlider("Força do Boost", "Intensidade (padrão 500).", 3000, 0, 500, function(value) boostForce = value if boostActive and not startBoost() then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end end)
local antiFlipConn
regOff(section:NewToggle("Anti-Flip", "Endireita o carrinho ao tombar.", function(state)
if antiFlipConn then antiFlipConn:Disconnect() antiFlipConn = nil end
cartFeatureTiming.antiFlipReadyAt = 0
if not state then notify("Anti-Flip", "Desligado.") return end
antiFlipConn = RunService.Heartbeat:Connect(function()
if panicActive or FLYING or killerActive or os.clock() < cartMotionPauseUntil or os.clock() < cartFeatureTiming.antiFlipReadyAt then return end
local cart = getCurrentCart()
if not cart then return end
local primary = getCartPrimary(cart)
if not primary or not primary.Parent then return end
if primary.CFrame.UpVector:Dot(Vector3.new(0,1,0)) < 0.5 then
cartFeatureTiming.antiFlipReadyAt = os.clock() + 1.5
if boostActive then stopBoost() if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end end
local pos = primary.CFrame.Position
local look = Vector3.new(primary.CFrame.LookVector.X, 0, primary.CFrame.LookVector.Z)
look = look.Magnitude > 0.01 and look.Unit or Vector3.new(1,0,0)
local target = pos + Vector3.new(0,2,0)
if pivotCartByReference(cart, CFrame.new(target, target + look)) then notify("Anti-Flip", "Carrinho endireitado.") end
end
end)
notify("Anti-Flip", "Ligado.")
end))
local autobrakeConn
regOff(section:NewToggle("Freio Automático", "Trava ao detectar queda livre.", function(state)
if autobrakeConn then autobrakeConn:Disconnect() autobrakeConn = nil end
cartFeatureTiming.autobrakeHoldUntil, cartFeatureTiming.autobrakeReadyAt = 0, 0
if not state then notify("Freio Automático", "Desligado.") return end
autobrakeConn = RunService.Heartbeat:Connect(function()
if panicActive or FLYING or killerActive or os.clock() < cartMotionPauseUntil then return end
local cart = getCurrentCart()
if not cart then return end
local primary = getCartPrimary(cart)
if not primary then return end
local now = os.clock()
if now < cartFeatureTiming.autobrakeHoldUntil then
for _, part in ipairs(cart:GetDescendants()) do if part:IsA("BasePart") and not part.Anchored then pcall(function() part.AssemblyLinearVelocity = Vector3.zero part.AssemblyAngularVelocity = Vector3.zero end) end end
return
end
if now >= cartFeatureTiming.autobrakeReadyAt and primary.AssemblyLinearVelocity.Y < -35 then
cartFeatureTiming.autobrakeHoldUntil = now + 0.45
cartFeatureTiming.autobrakeReadyAt = now + 1.25
if boostActive then stopBoost() if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end end
for _, part in ipairs(cart:GetDescendants()) do if part:IsA("BasePart") and not part.Anchored then pcall(function() part.AssemblyLinearVelocity = Vector3.zero part.AssemblyAngularVelocity = Vector3.zero end) end end
notify("Freio Automático", "Queda detectada — travado.")
end
end)
notify("Freio Automático", "Ligado.")
end))
end
-- Fly
do
local section = Window:NewTab("Fly"):NewSection("Voo do Veículo / Personagem")
flyToggleControl = regOff(section:NewToggle("Voo do Veículo", "Tecla V liga/desliga. WASD move, Q/E sobe/desce.", function(enabled)
flyEnabled = enabled
if enabled then
if killerActive then flyEnabled = false notify("Voo", "Indisponível durante o Eliminador.") task.defer(function() flyToggleControl:UpdateToggle(nil, false) end) return end
if panicActive then restorePanicStop() if panicToggleControl then task.defer(function() panicToggleControl:UpdateToggle(nil, false) end) end end
if stopBoost then stopBoost() end
if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end
if startVehicleFly() then notify("Voo do Veículo", "Ligado.") else flyEnabled = false task.defer(function() flyToggleControl:UpdateToggle(nil, false) end) end
else stopFly() notify("Voo do Veículo", "Desligado.") end
end))
section:NewTextBox("Velocidade do Voo", "Digite e aperte Enter.", function(value) local n = tonumber(value) if n and n > 0 then vehicleFlySpeed = n notify("Voo", "Velocidade: "..n) else notify("Voo", "Digite um número maior que zero.") end end)
section:NewButton("Redefinir Velocidade do Voo", "Volta para 1.", function() vehicleFlySpeed = 1 notify("Voo", "Velocidade redefinida para 1.") end)
section:NewLabel("No celular aparecem botões ▲/▼. Sentado, o carrinho voa junto; o voo não usa PlatformStand para preservar a solda do assento.", 48)
end
-- Gravidade
local gravityToggle, gravityStatus
local performanceToggles, performanceControls = {}, {}
do
local gravityTab = Window:NewTab("Gravidade")
local section = gravityTab:NewSection("Formações: Gravity / Super Ring / W7")
gravityToggle = regOff(section:NewToggle("Ativar formação de peças", "Busca peças soltas próximas.", function(value)
if not M.extras then return end
if not M.extras:SetActive(value) and value then
task.defer(function() if not destroyed then gravityToggle:UpdateToggle(nil, false) notify(M.extras.lastError or "Personagem indisponível.") end end)
end
end))
local modeIndex = 1
local modeButton
local function selectFormation(index)
if not M.extras then return false end
if index < 1 or index > #M.extras.modes or index % 1 ~= 0 then return false end
modeIndex = index
M.extras:SetMode(M.extras.modes[index])
modeButton:UpdateButton("Formação "..index.."/"..#M.extras.modes..": "..M.extras.mode)
return true
end
modeButton = section:NewButton("Formação: Anel", "Próxima forma da lista.", function() selectFormation(modeIndex % #M.extras.modes + 1) end)
section:NewButton("Formação anterior", "Volta uma forma.", function() selectFormation((modeIndex - 2) % #M.extras.modes + 1) end)
section:NewTextBox("Escolher formação (1 a 31)", "Número da lista.", function(value) if not selectFormation(tonumber(value) or 0) then notify("Digite um número inteiro de 1 a 31.") end end)
section:NewButton("Listar formações", "Nomes e números no console F9.", function() if M.extras then for index, name in ipairs(M.extras.modes) do print(index.." - "..name) end notify("Gravidade", "Lista enviada ao F9.") end end)
local pauseToggle = regOff(section:NewToggle("Pausar movimento", "Interrompe forças e restaura colisões.", function(value) if M.extras then M.extras:SetPaused(value) end end))
local followToggle = section:NewToggle("Centro segue meu personagem", "Desligado: centro fixo.", function(value) if M.extras then M.extras.follow = value end end)
followToggle:UpdateToggle(nil, true)
section:NewButton("Buscar peças / recentralizar", "Procura peças soltas de novo.", function() if M.extras and not M.extras:Scan() then notify("Ative a formação com seu personagem no mapa.") end end)
section:NewButton("Liberar todas as peças", "Desliga e restaura colisões.", function() gravityToggle:UpdateToggle(nil, false) end)
gravityStatus = section:NewLabel("Desligada | nenhuma peça controlada.", 48)
local formation = gravityTab:NewSection("Ajustar formação")
local function gravitySlider(label, description, name, maximum, minimum, initial)
local slider = formation:NewSlider(label, description, maximum, minimum, initial, function(value) if M.extras then M.extras:SetNumber(name, value) end end)
return slider
end
gravitySlider("Raio da formação", "Tamanho do anel em studs.", "radius", 100, 10, 25)
gravitySlider("Altura", "Altura do anel / amplitude.", "height", 100, 0, 20)
gravitySlider("Giro da formação", "Velocidade ao redor do centro.", "spin", 100, 0, 15)
gravitySlider("Distância de busca", "Alcance em studs.", "reach", 200, 20, 80)
gravitySlider("Limite de peças", "Máximo controlado.", "maxParts", 60, 1, 30)
gravitySlider("Velocidade máxima", "Limite em studs/s.", "maxSpeed", 200, 10, 80)
gravitySlider("Força de aproximação", "Resposta das peças.", "pullStrength", 30, 1, 3)
gravitySlider("Atração Super Ring", "Intensidade do Super Ring.", "attraction", 1000, 0, 1000)
for _, item in ipairs({ { "Deslocar X", "offsetX" }, { "Deslocar Z", "offsetZ" }, { "Inclinar X", "tiltX" }, { "Girar Y", "tiltY" }, { "Inclinar Z", "tiltZ" } }) do
local name = item[2]
formation:NewTextBox(item[1], name:sub(1,4) == "tilt" and "Graus de 0 a 360." or "Studs de -100 a 100.", function(value) if not M.extras or not M.extras:SetNumber(name, tonumber((value:gsub(",", ".")))) then notify("Valor fora do intervalo.") end end)
end
local performance = gravityTab:NewSection("Ajustes gráficos locais")
for _, item in ipairs({
{ "Sombras reduzidas", "shadows", "Desliga sombras globais." },
{ "Desativar pós-efeitos", "postfx", "Desliga efeitos de imagem." },
{ "Materiais simples", "materials", "Material simples nas peças." },
{ "Ocultar partículas", "particles", "Esconde partículas e rastros." },
{ "X-Ray do mapa", "xray", "Peças do mapa transparentes (local)." },
{ "Fullbright", "fullbright", "Clareia a iluminação ambiente." },
{ "Ocultar texturas", "textures", "Oculta Decals e Textures." },
{ "Ocultar céu", "sky", "Retira as imagens do céu." },
}) do
local setting = item[2]
local control = regOff(performance:NewToggle(item[1], item[3], function(value) if M.extras then M.extras:SetEffect(setting, value) end end))
performanceToggles[#performanceToggles+1] = control
performanceControls[setting] = control
end
performance:NewButton("Restaurar visual original", "Restaura todos os ajustes.", function() for _, t in ipairs(performanceToggles) do t:UpdateToggle(nil, false) end end)
local physics = gravityTab:NewSection("Gravidade local do mundo")
physics:NewTextBox("Gravidade local", "De 0 a 400.", function(value) if M.features then local _, m = M.features:SetValue("gravity", tonumber((value:gsub(",", ".")))) notify("Gravidade", m) end end)
physics:NewButton("Restaurar gravidade do jogo", "Volta ao valor original.", function() if M.features then local _, m = M.features:Reset("gravity") notify("Gravidade", m) end end)
end
-- Proteção
local protectionStatus, playerList, fallStatus, survivalStatus
local protectionToggle, fallToggle, weatherRoofToggle, voidGuardToggle
do
local protectionTab = Window:NewTab("Proteção")
local section = protectionTab:NewSection("Anti-fling")
protectionToggle = regOff(section:NewToggle("Ativar proteção", "Reduz colisões locais de personagens acima dos limites.", function(value) if M.controller then M.controller:SetEnabled(value) end end))
protectionStatus = section:NewLabel("Iniciando proteção...", 34)
local limits = section:NewSection and nil or nil
local listSection = protectionTab:NewSection("Movimento acima do limite")
playerList = listSection:NewLabel("Nenhum personagem detectado.", 90)
listSection:NewLabel("Movimento rápido pode ser normal no jogo; a detecção não comprova cheats.", 34)
local limitSection = protectionTab:NewSection("Limites da detecção")
local velocity = limitSection:NewSlider("Velocidade (studs/s)", "Acima disso, reduz colisões do detectado.", 1000, 50, 350, function(value) if M.controller then M.controller:SetLimits(value, M.controller.rotationLimit, M.controller.holdSeconds) end end)
local rotation = limitSection:NewSlider("Giro (rad/s)", "Velocidade angular da física.", 2000, 100, 700, function(value) if M.controller then M.controller:SetLimits(M.controller.velocityLimit, value, M.controller.holdSeconds) end end)
local hold = limitSection:NewSlider("Manter proteção (s)", "Tempo após a última detecção.", 30, 1, 10, function(value) if M.controller then M.controller:SetLimits(M.controller.velocityLimit, M.controller.rotationLimit, value) end end)
local fallSection = protectionTab:NewSection("Queda — proteção local")
fallStatus = fallSection:NewLabel("Desligado. Verifica scripts locais compatíveis ao ativar.", 48)
fallToggle = regOff(fallSection:NewToggle("Desativar dano de queda local", "Pausa LocalScripts FallDamage e restaura ao desligar.", function(value) if M.fallProtection then M.fallProtection:SetEnabled(value) end end))
fallSection:NewLabel("Não bloqueia dano do servidor nem concede invencibilidade.", 34)
local survivalSection = protectionTab:NewSection("Sobrevivência local")
survivalStatus = survivalSection:NewLabel("Abrigo e proteção contra void desligados.", 40)
weatherRoofToggle = regOff(survivalSection:NewToggle("Abrigo contra chuva / neve", "Placa local transparente acima de você.", function(value) if M.survival then M.survival:SetWeatherRoof(value) end end))
voidGuardToggle = regOff(survivalSection:NewToggle("Proteção contra void", "Volta à última posição segura se cair do mapa.", function(value) if M.survival then M.survival:SetVoidGuard(value) end end))
survivalSection:NewLabel("Recursos locais: o servidor pode corrigir a posição ou ignorar a placa.", 34)
end
-- Itens
local itemsStatus
do
local section = Window:NewTab("Itens"):NewSection("Ferramentas Cafezitos")
itemsStatus = section:NewLabel("Itens do jogo na mochila têm prioridade. Maçã e balão têm versão local.", 48)
for _, item in ipairs({
{ "hammer", "Criar martelo azul (visual)", "Animação de golpe; não causa dano." },
{ "apple", "Maçã: morder para curar", "+10 de vida local por mordida." },
{ "compass", "Criar bússola / votação", "Abre a votação de mapa, se existir." },
{ "balloon", "Criar balão verde", "Pulo ~5x e queda lenta." },
}) do
local id = item[1]
section:NewButton(item[2], item[3], function()
if not M.localItems then return end
local ok, message = M.localItems:Create(id)
itemsStatus:SetText(message or (ok and "Item criado." or "Item indisponível."))
if message then notify(message) end
end)
end
section:NewButton("Remover itens criados", "Remove só as ferramentas criadas por esta aba.", function() if M.localItems then M.localItems:RemoveAll() itemsStatus:SetText("Ferramentas criadas removidas.") end end)
end
-- Exploração
do
local section = Window:NewTab("Exploração"):NewSection("Destinos e visual do mapa")
section:NewLabel("Visuais locais: mudam só a exibição; não escolhem desastre.", 30)
section:NewButton("Dia (visual)", "Horário local meio-dia.", function() if M.gameView then M.gameView:SetTime(12) notify("Exploração", "Dia aplicado.") end end)
section:NewButton("Noite (visual)", "Horário local meia-noite.", function() if M.gameView then M.gameView:SetTime(0) notify("Exploração", "Noite aplicada.") end end)
section:NewButton("Restaurar horário", "Restaura o horário anterior.", function() if M.gameView then M.gameView:RestoreTime() notify("Exploração", "Horário restaurado.") end end)
regOff(section:NewToggle("Ocultar efeito de neve", "Oculta BlizzardGui enquanto ligado.", function(value) if M.gameView then M.gameView:SetHidden("BlizzardGui", value) end end))
regOff(section:NewToggle("Ocultar efeito de areia", "Oculta SandStormGui enquanto ligado.", function(value) if M.gameView then M.gameView:SetHidden("SandStormGui", value) end end))
section:NewTextBox("Ir até Parte", "Nome da parte no workspace.", function(value)
value = value:match("^%s*(.-)%s*$"):lower()
if value == "" then return end
local best, bestPriority = nil, 0
for _, obj in ipairs(workspace:GetDescendants()) do
if obj:IsA("BasePart") then
local name = obj.Name:lower()
local priority = name == value and 3 or name:sub(1,#value) == value and 2 or name:find(value,1,true) and 1 or 0
if priority > bestPriority then best = obj bestPriority = priority end
end
end
if not best then notify("Mapa", "Parte '"..value.."' não encontrada.") return end
teleportCharacter(best.CFrame * CFrame.new(0, 4, 0))
notify("Mapa", "Teleportado para: "..best.Name)
end)
section:NewButton("Listar Partes no Output (F9)", "Imprime 30 BaseParts.", function()
print("[Cafezitos V3] === BaseParts no Workspace ===")
local count = 0
for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and count < 30 then print(("[Cafezitos V3] %s  pos: %s"):format(obj:GetFullName(), tostring(obj.Position))) count = count + 1 end end
notify("Mapa", count.." partes no output (F9).")
end)
section:NewButton("Ir ao Carrinho", "Assento de carrinho mais próximo.", function()
local root = getRoot()
if not root then return end
local seat
for _, wantedClass in ipairs({ "VehicleSeat", "Seat" }) do
local nearest, nearestDistance = nil, math.huge
for _, object in ipairs(workspace:GetDescendants()) do
if object:IsA(wantedClass) then
local distance = (root.Position - object.Position).Magnitude
if distance < nearestDistance then nearest = object nearestDistance = distance end
end
end
if nearest then seat = nearest break end
end
if not seat then notify("Carrinho", "Nenhum assento encontrado.") return end
if teleportCharacter(seat.CFrame * CFrame.new(0, 4, 0)) then notify("Carrinho", "Teleportado para o carrinho.") end
end)
local savedPosition
section:NewButton("Salvar Posição Atual", "Salva onde você está.", function()
local cart = getCurrentCart()
local reference = cart and getCartPrimary(cart) or getRoot()
if not reference then notify("Posição", "Personagem não encontrado.") return end
savedPosition = reference.CFrame
notify("Posição", string.format("Salva em %.0f, %.0f, %.0f", reference.Position.X, reference.Position.Y, reference.Position.Z))
end)
section:NewButton("Voltar à Posição Salva", "Teleporta de volta.", function() if not savedPosition then notify("Posição", "Nenhuma posição salva.") return end if teleportPlayerOrCart(savedPosition) then notify("Posição", "Teleportado.") end end)
end
-- Câmera
do
local section = Window:NewTab("Câmera"):NewSection("Câmera")
local freecamActive, freecamConn, freecamSpeed, freecamToggleControl = false, nil, 1, nil
local function stopFreecam() freecamActive = false if freecamConn then freecamConn:Disconnect() freecamConn = nil end releaseCameraMode("freecam") end
cameraModeStoppers.freecam = function() if freecamToggleControl then freecamToggleControl:UpdateToggle(nil, false) else stopFreecam() end end
freecamToggleControl = regOff(section:NewToggle("Câmera Livre", "WASD move, Q/E sobe e desce.", function(state)
if not state then stopFreecam() notify("Câmera Livre", "Desligada.") return end
claimCameraMode("freecam")
freecamActive = true
local camera = workspace.CurrentCamera
if not camera then stopFreecam() task.defer(function() freecamToggleControl:UpdateToggle(nil, false) end) return end
camera.CameraType = Enum.CameraType.Scriptable
local cf = camera.CFrame
freecamConn = RunService.RenderStepped:Connect(function(deltaTime)
if not freecamActive then return end
local currentCamera = workspace.CurrentCamera
if not currentCamera then return end
if currentCamera ~= camera then camera = currentCamera camera.CameraType = Enum.CameraType.Scriptable end
local move = Vector3.zero
if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0,1,0) end
if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - Vector3.new(0,-1,0) end
if move.Magnitude > 0 then cf = CFrame.new(cf.Position + move * freecamSpeed * math.clamp(deltaTime * 60, 0, 3)) * (cf - cf.Position) end
camera.CFrame = cf
camera.Focus = cf * CFrame.new(0, 0, -12)
end)
notify("Câmera Livre", "WASD move, Q/E sobe e desce.")
end))
section:NewSlider("Velocidade da Câmera Livre", "1 a 10.", 10, 1, 1, function(value) freecamSpeed = value end)
local spinDuration, spinConn = 5, nil
local function stopSpin(silent) if spinConn then spinConn:Disconnect() spinConn = nil end releaseCameraMode("spin") if not silent then notify("Troll", "Câmera voltou ao normal.") end end
cameraModeStoppers.spin = function() stopSpin(true) end
section:NewButton("Câmera Giratória", "Gira por alguns segundos.", function()
stopSpin(true)
claimCameraMode("spin")
local camera = workspace.CurrentCamera
if not camera then releaseCameraMode("spin") return end
camera.CameraType = Enum.CameraType.Scriptable
local startTime, origin = os.clock(), camera.CFrame
spinConn = RunService.RenderStepped:Connect(function()
local currentCamera = workspace.CurrentCamera
if not currentCamera then return end
if currentCamera ~= camera then camera = currentCamera camera.CameraType = Enum.CameraType.Scriptable origin = camera.CFrame end
local elapsed = os.clock() - startTime
if elapsed >= spinDuration then stopSpin(false) return end
local angle = elapsed * math.pi * 2
camera.CFrame = CFrame.new(origin.Position) * CFrame.Angles(0, angle, 0) * CFrame.new(0, 0, -10)
camera.Focus = CFrame.new(origin.Position)
end)
notify("Troll", "Câmera girando por "..spinDuration.."s.")
end)
section:NewSlider("Duração Câmera (s)", "Segundos de giro.", 30, 1, 5, function(value) spinDuration = value end)
local spectating, spectateConn = false, nil
local function stopSpectate(silent) spectating = false if spectateConn then spectateConn:Disconnect() spectateConn = nil end releaseCameraMode("spectate") if not silent then notify("Spectate", "Parado.") end end
cameraModeStoppers.spectate = function() stopSpectate(true) end
section:NewTextBox("Spectate Jogador", "Nome do jogador. Enter.", function(value)
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
local currentCamera = workspace.CurrentCamera
if not currentCamera then return end
if currentCamera ~= camera then camera = currentCamera camera.CameraType = Enum.CameraType.Scriptable end
local char = player.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
if not root then stopSpectate(false) return end
camera.CFrame = CFrame.new(root.Position + Vector3.new(0,8,-14), root.Position)
camera.Focus = CFrame.new(root.Position)
end)
notify("Spectate", "Seguindo "..player.DisplayName..".")
end)
section:NewButton("Parar Spectate", "Para de seguir.", function() stopSpectate(false) end)
local fovValue, fovOriginals, fovConnection = nil, {}, nil
local function applyFOV() local camera = workspace.CurrentCamera if camera and fovValue then if fovOriginals[camera] == nil then fovOriginals[camera] = camera.FieldOfView end camera.FieldOfView = fovValue end end
section:NewTextBox("Campo de visão (FOV)", "De 1 a 120 graus.", function(value)
local n = tonumber((value:gsub(",", ".")))
if not n or n < 1 or n > 120 then notify("FOV", "Use 1 a 120.") return end
fovValue = n
applyFOV()
if not fovConnection then fovConnection = trackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(applyFOV)) end
notify("FOV", "Aplicado: "..n)
end)
section:NewButton("Restaurar FOV", "Recupera o valor de cada câmera.", function()
if fovConnection then fovConnection:Disconnect() fovConnection = nil end
fovValue = nil
for camera, v in pairs(fovOriginals) do pcall(function() camera.FieldOfView = v end) end
fovOriginals = {}
notify("FOV", "Restaurado.")
end)
section:NewButton("Restaurar câmera", "Encerra livre, giro e spectate.", function() resetCameraModes() stopSpin(true) stopSpectate(true) stopFreecam() notify("Câmera", "Restaurada.") end)
end
-- Eliminador
do
local section = Window:NewTab("Eliminador"):NewSection("Controle de Alvo")
local targetName = ""
section:NewTextBox("Nome do Alvo", "Parte do nome. Enter.", function(value) targetName = value end)
section:NewButton("Alcançar Alvo", "Usa o carrinho livre mais próximo.", function()
if not targetName or targetName:match("^%s*$") then notify("Eliminador", "Digite uma parte do nome primeiro.") return end
local requested = targetName
task.spawn(function()
local ok, err = xpcall(function() executeKiller(requested) end, CafeUI.traceback)
if not ok then warn(MENU_NAME.." Killer: "..err) if killerActive then finishKiller("Erro na tentativa. Tente de novo.") end end
end)
end)
end
-- Troll
do
local section = Window:NewTab("Troll"):NewSection("Diversão")
local fakeLagDuration = 2
local function restoreFakeLag()
local h = fakeLagHumanoid
fakeLagActive = false
if h and h.Parent then
h.WalkSpeed = desiredWalkSpeed or 16
if h.UseJumpPower then h.JumpPower = desiredJumpPower or 50 else h.JumpHeight = desiredJumpHeight or 7.2 end
end
fakeLagHumanoid = nil
end
section:NewButton("Fake Lag", "Congela você por alguns segundos.", function()
local h = getHumanoid()
if not h then return end
if not fakeLagActive then
desiredWalkSpeed = desiredWalkSpeed or h.WalkSpeed
desiredJumpPower = desiredJumpPower or h.JumpPower
desiredJumpHeight = desiredJumpHeight or h.JumpHeight
elseif fakeLagHumanoid ~= h then restoreFakeLag() end
fakeLagSession = fakeLagSession + 1
local session = fakeLagSession
fakeLagActive = true
fakeLagHumanoid = h
h.WalkSpeed = 0
if h.UseJumpPower then h.JumpPower = 0 else h.JumpHeight = 0 end
notify("Troll", "Fake lag por "..fakeLagDuration.."s.")
task.spawn(function() task.wait(fakeLagDuration) if session ~= fakeLagSession or destroyed then return end restoreFakeLag() notify("Troll", "Fake lag encerrado.") end)
end)
section:NewSlider("Duração Fake Lag (s)", "Duração em segundos.", 15, 1, 2, function(value) fakeLagDuration = value end)
section:NewButton("Teleporte Aleatório", "Te joga em uma parte aleatória.", function()
local parts = {}
for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("BasePart") and obj.Transparency < 0.9 and obj.Size.Magnitude > 2 and obj ~= workspace.Terrain then table.insert(parts, obj) end end
if #parts == 0 then notify("Troll", "Nenhuma parte útil encontrada.") return end
local target = parts[math.random(1, #parts)]
teleportCharacter(target.CFrame * CFrame.new(0, 5, 0))
notify("Troll", "Caiu em: "..target.Name)
end)
end
-- Comandos
do
local section = Window:NewTab("Comandos"):NewSection("Atalhos")
section:NewLabel("V: Voo | L: ESP | P: Pulo Infinito | T: Teleporte por Clique\nB: Boost | NumPad 1/2/3: Checkpoints\nK: Minimizar/Abrir | X: Fechar", 60)
section:NewButton("Parar tudo e restaurar", "Desliga toggles, fly, câmera, efeitos e restaura valores.", function()
for _, control in ipairs(offControls) do pcall(function() control:UpdateToggle(nil, false) end) end
stopFly(); stopBoost(); restorePanicStop(); resetCameraModes()
if M.features then M.features:Unfreeze() for _, name in ipairs({ "walk", "jump", "gravity" }) do M.features:Reset(name) end end
if M.extras then M.extras:SetActive(false) end
if M.appearance then M.appearance:Restore() end
if M.localItems then M.localItems:RemoveAll() end
notify("Comandos", "Tudo parado e restaurado.")
end)
end
-- Interface
local sfxToggle, animationButton
do
local section = Window:NewTab("Interface"):NewSection("Interface")
local rgbEnabled = true
local rgbToggle = section:NewToggle("Cores RGB (pulso caramelo)", "Anima os detalhes da interface.", function(value) rgbEnabled = value if not value then CafeUI:ChangeColor("SchemeColor", Theme.SchemeColor) end end)
rgbToggle:UpdateToggle(nil, true)
section:NewButton("Minimizar menu", "Mantém funções ativas; botão ☕ reabre.", function() if setMenuVisible then setMenuVisible(false) end end)
section:NewButton("Fechar Menu", "Tecla X também fecha.", function() if destroyCafezitos then destroyCafezitos() end end)
sfxToggle = section:NewToggle("SFX local (som embutido)", "Desligado por padrão; usa só som interno do Roblox.", function(value) if M.survival then M.survival:SetSfx(value) end end)
local animationNames = { "Wave", "Point", "Dance", "Dance2", "Dance3", "Cheer" }
local animationIndex = 1
animationButton = section:NewButton("Animação: Wave", "Alterna animação padrão Roblox.", function() animationIndex = animationIndex % #animationNames + 1 animationButton:UpdateButton("Animação: "..animationNames[animationIndex]) end)
section:NewButton("Tocar animação", "Toca por até 10 segundos.", function() if M.survival then local ok, message = M.survival:PlayAnimation(animationNames[animationIndex]) if not ok then notify(message or "Animação indisponível.") end end end)
section:NewButton("Parar animação", "Para a animação do menu.", function() if M.survival then M.survival:StopAnimation() end end)
section:NewLabel("Jogo: Cart Ride / Desastres\nInterface: Cafezitos V3 por Cafezl\nSEM KEY • carregamento limpo de sons.", 48)
end
-- =============================================================================
-- Instancia os módulos (depois das labels, para os onState funcionarem)
-- =============================================================================
M.controller = createProtectionController({ players = Players, player = LocalPlayer })
M.extras = createDisasterExtras({ world = workspace, lighting = Lighting, player = LocalPlayer, players = Players, isOwner = type(isnetworkowner) == "function" and isnetworkowner or nil })
M.fallProtection = createDisasterFallProtection({ player = LocalPlayer, onState = function(message) if fallStatus then fallStatus:SetText(message) end end })
M.survival = createDisasterSurvival({ player = LocalPlayer, world = workspace, onState = function(message) if survivalStatus then survivalStatus:SetText(message) end end })
M.travel = createDisasterTravel({ player = LocalPlayer, world = workspace, alive = function() return not destroyed and isCurrentSuiteGeneration() end, beforeTeleport = function() if M.features then M.features:Unfreeze() end resetCameraModes() if gravityToggle then gravityToggle:UpdateToggle(nil, false) end if flyToggleControl then flyToggleControl:UpdateToggle(nil, false) end end, afterTeleport = function() if M.controller then M.controller:ResetReadings() end end })
M.features = createDisasterPlayer({ player = LocalPlayer, players = Players, world = workspace, input = UserInputService, notify = function(message) notify("Jogador", message) end })
M.appearance = createDisasterAppearance({ player = LocalPlayer, onState = function(message) notify("Aparência", message) end })
M.localItems = createDisasterItems({ player = LocalPlayer, world = workspace, runService = RunService, notify = function(message) notify("Itens", message) end, fallProtection = M.fallProtection, appleHeal = 10 })
M.gameView = createDisasterGameView({ player = LocalPlayer, lighting = Lighting, runService = RunService })
-- =============================================================================
-- Minimizar / reabrir / drag
-- =============================================================================
local menuGui = Window.gui
local launcherGui = Instance.new("ScreenGui")
launcherGui.Name = "CafezitosLauncher"; launcherGui.ResetOnSpawn = false; launcherGui.IgnoreGuiInset = true; launcherGui.DisplayOrder = 10000; launcherGui.Parent = CoreGui
local launcher = Instance.new("TextButton")
launcher.Name = "OpenCafezitosMenu"; launcher.Size = UDim2.fromOffset(62,62); launcher.Position = UDim2.new(0,18,0.5,-31)
launcher.BackgroundColor3 = Color3.fromRGB(104,61,43); launcher.BorderSizePixel = 0; launcher.AutoButtonColor = false
launcher.Font = Enum.Font.GothamBold; launcher.Text = ""; launcher.Visible = false; launcher.Parent = launcherGui
Instance.new("UICorner", launcher).CornerRadius = UDim.new(1,0)
CafeUI.launcherStroke = Instance.new("UIStroke"); CafeUI.launcherStroke.Thickness = 2.5; CafeUI.launcherStroke.Parent = launcher
CafeUI.launcherIcon = Instance.new("TextLabel"); CafeUI.launcherIcon.BackgroundTransparency = 1; CafeUI.launcherIcon.Size = UDim2.fromScale(1,1); CafeUI.launcherIcon.Font = Enum.Font.GothamBold; CafeUI.launcherIcon.Text = "☕"; CafeUI.launcherIcon.TextSize = 32; CafeUI.launcherIcon.Parent = launcher
setMenuVisible = function(visible) if destroyed then return end menuGui.Enabled = visible launcher.Visible = not visible end
local mainFrame = menuGui:FindFirstChild("Main")
local header = mainFrame and mainFrame:FindFirstChild("MainHeader")
if header then
local originalClose = header:FindFirstChild("close")
if originalClose then originalClose.Visible = false originalClose.Active = false end
local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"; minimize.Size = UDim2.fromOffset(28,24); minimize.Position = UDim2.new(1,-34,0,2)
minimize.BackgroundTransparency = 1; minimize.AutoButtonColor = false; minimize.Font = Enum.Font.GothamBold
minimize.Text = "—"; minimize.TextColor3 = Color3.fromRGB(255,255,255); minimize.TextSize = 20; minimize.Parent = header
minimize.MouseButton1Click:Connect(function() setMenuVisible(false) end)
header.Active = true
local dragInput, dragStart, dragOrigin
header.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragInput, dragStart, dragOrigin = input, input.Position, mainFrame.Position end end)
trackConnection(UserInputService.InputChanged:Connect(function(input)
if not dragInput or not dragStart or not dragOrigin then return end
if input == dragInput or (dragInput.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement) then
local delta = input.Position - dragStart
mainFrame.Position = UDim2.new(dragOrigin.X.Scale, dragOrigin.X.Offset + delta.X, dragOrigin.Y.Scale, dragOrigin.Y.Offset + delta.Y)
end
end))
trackConnection(UserInputService.InputEnded:Connect(function(input) if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then dragInput = nil end end))
end
local launcherLastDrag = 0
do
local dragInput, dragStart, dragOrigin, wasDragged
launcher.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragInput, dragStart, dragOrigin, wasDragged = input, input.Position, launcher.Position, false end end)
trackConnection(UserInputService.InputChanged:Connect(function(input)
if dragInput and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement) then
local delta = input.Position - dragStart
if delta.Magnitude > 6 then wasDragged = true end
launcher.Position = UDim2.new(dragOrigin.X.Scale, dragOrigin.X.Offset + delta.X, dragOrigin.Y.Scale, dragOrigin.Y.Offset + delta.Y)
end
end))
trackConnection(UserInputService.InputEnded:Connect(function(input) if input == dragInput then dragInput = nil if wasDragged then launcherLastDrag = os.clock() end end end))
end
launcher.Activated:Connect(function() if os.clock() - launcherLastDrag < 0.25 then return end setMenuVisible(true) end)
-- =============================================================================
-- Atalhos globais
-- =============================================================================
trackConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
if destroyed or gameProcessed or UserInputService:GetFocusedTextBox() then return end
if input.KeyCode == Enum.KeyCode.V then flyToggleControl:UpdateToggle(nil, not flyEnabled)
elseif input.KeyCode == Enum.KeyCode.L then espToggleControl:UpdateToggle(nil, not espEnabled)
elseif input.KeyCode == Enum.KeyCode.P then infiniteJumpToggleControl:UpdateToggle(nil, not infiniteJump)
elseif input.KeyCode == Enum.KeyCode.T then
local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
if backpack and not backpack:FindFirstChild("CafezitosClickTP") then pcall(function() local character = LocalPlayer.Character if not (character and character:FindFirstChild("CafezitosClickTP")) then local tool = Instance.new("Tool") tool.Name = "CafezitosClickTP" tool.RequiresHandle = false tool.Activated:Connect(function() local m = LocalPlayer:GetMouse() if m.Target and m.Hit then teleportCharacter(CFrame.new(m.Hit.Position + Vector3.new(0,2.5,0))) end end) tool.Parent = backpack table.insert(createdTools, tool) notify("Teleporte por Clique", "Ferramenta criada.") end end) end
elseif input.KeyCode == Enum.KeyCode.B then boostToggleControl:UpdateToggle(nil, not boostActive)
elseif input.KeyCode == Enum.KeyCode.KeypadOne then teleportToCheckpoint(1)
elseif input.KeyCode == Enum.KeyCode.KeypadTwo then teleportToCheckpoint(2)
elseif input.KeyCode == Enum.KeyCode.KeypadThree then teleportToCheckpoint(3)
elseif input.KeyCode == Enum.KeyCode.K then setMenuVisible(not menuGui.Enabled)
elseif input.KeyCode == Enum.KeyCode.X then destroyCafezitos()
end
end))
-- =============================================================================
-- Destruição limpa
-- =============================================================================
destroyCafezitos = function()
if destroyed then return end
destroyed = true
killerActive = false
killerSession = killerSession + 1
if cancelAutoWin then cancelAutoWin(true) end
infiniteJump = false
fakeLagSession = fakeLagSession + 1
disconnectRuntimeConnections()
stopFly(); stopBoost(); restorePanicStop(); resetCameraModes()
noclipEnabled = false
espEnabled = false; espSession = espSession + 1; clearESP()
stabilizer.enabled = false; cleanupStabilizer()
workspace.Gravity = originalGravity
if M.localItems then pcall(function() M.localItems:Destroy() end) end
if M.appearance then pcall(function() M.appearance:Destroy() end) end
if M.features then pcall(function() M.features:Destroy() end) end
if M.gameView then pcall(function() M.gameView:Destroy() end) end
if M.survival then pcall(function() M.survival:Destroy() end) end
if M.fallProtection then pcall(function() M.fallProtection:Destroy() end) end
if M.travel then M.travel = nil end
if M.extras then pcall(function() M.extras:Destroy() end) end
if M.controller then pcall(function() M.controller:Destroy() end) end
for index = #createdTools, 1, -1 do local tool = createdTools[index] if tool and tool.Parent then tool:Destroy() end createdTools[index] = nil end
if flyMobileGui and flyMobileGui.Parent then flyMobileGui:Destroy() end
if toastGui and toastGui.Parent then toastGui:Destroy() end
if launcherGui and launcherGui.Parent then launcherGui:Destroy() end
if menuGui and menuGui.Parent then menuGui:Destroy() end
if runtime and runtime.Parent then runtime:Destroy() end
end
-- =============================================================================
-- Loop principal (status + RGB)
-- =============================================================================
local lastDisplay, lastAccent = -math.huge, -math.huge
trackConnection(RunService.Stepped:Connect(function()
if destroyed or not isCurrentSuiteGeneration() then return end
if M.controller then M.controller:Step() end
if M.features then pcall(function() M.features:Step() end) end
if M.extras then
local ok, err = pcall(function() M.extras:Step() end)
if not ok then M.extras.lastError = tostring(err) M.extras:SetActive(false) if gravityToggle then pcall(function() gravityToggle:UpdateToggle(nil, false) end) end end
end
if M.survival then pcall(function() M.survival:Step() end) end
local current = os.clock()
if current - lastDisplay >= 0.2 then
lastDisplay = current
if M.controller then
local flagged = M.controller:Flagged()
if protectionStatus then protectionStatus:SetText(M.controller.enabled and ("Ativa | "..#flagged.." personagem(ns) detectado(s)") or "Desligada | colisões restauradas") end
if playerList then
local names = {}
for index = 1, math.min(5, #flagged) do names[#names+1] = "@"..flagged[index].name.." | "..flagged[index].remaining.." s" end
if #flagged > 5 then names[#names+1] = "+ "..(#flagged-5) end
playerList:SetText(#names > 0 and table.concat(names, "\n") or "Nenhum personagem detectado.")
end
end
if M.extras and gravityStatus then
gravityStatus:SetText(M.extras.lastError or ((M.extras.active and (M.extras.paused and "Pausada" or "Ativa") or "Desligada").." | "..M.extras.count.." peça(s) | "..M.extras.mode..(M.extras.scanning and " | buscando..." or "")))
end
if M.features and playerValues then
local values = M.features:Values()
playerValues:SetText("Caminhada: "..tostring(values.walk or "aguardando").." | "..tostring(values.jumpMode or "Pulo")..": "..tostring(values.jump or "aguardando").."\nGravidade atual: "..tostring(values.gravity))
end
end
if rgbEnabledGlobal and current - lastAccent >= 0.30 then
lastAccent = current
local pulse = (math.sin(current * 1.2) + 1) * 0.5
local rgb = Color3.fromRGB(math.floor(188 + 38*pulse), math.floor(112 + 42*pulse), math.floor(57 + 27*pulse))
CafeUI:ChangeColor("SchemeColor", rgb)
CafeUI.launcherStroke.Color = rgb
CafeUI.launcherIcon.TextColor3 = rgb
for i = #toastStrokes, 1, -1 do local s = toastStrokes[i] if s and s.Parent then s.Color = rgb else table.remove(toastStrokes, i) end end
end
end))
local rgbEnabledGlobal = true
-- =============================================================================
-- Watchers de personagem
-- =============================================================================
do
local initialCharacter = LocalPlayer.Character
if initialCharacter then task.defer(function() if not destroyed and isCurrentSuiteGeneration() then watchSeat(initialCharacter) end end) end
trackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
if destroyed or not isCurrentSuiteGeneration() then return end
if cancelAutoWin then cancelAutoWin(true) end
killerSession = killerSession + 1; killerActive = false
clearCurrentCartCache(); cleanupStabilizer(); restorePanicStop()
if panicToggleControl then task.defer(function() panicToggleControl:UpdateToggle(nil, false) end) end
fakeLagSession = fakeLagSession + 1; fakeLagActive = false; fakeLagHumanoid = nil
if stopBoost then stopBoost() end
if boostToggleControl then task.defer(function() boostToggleControl:UpdateToggle(nil, false) end) end
if flyEnabled and flyToggleControl then flyToggleControl:UpdateToggle(nil, false) else stopFly() end
task.defer(resetCameraModes)
task.defer(watchSeat, character)
task.delay(0.25, function()
if destroyed or not isCurrentSuiteGeneration() or character ~= LocalPlayer.Character or not character.Parent then return end
local humanoid = getHumanoid(character)
if not humanoid then return end
if not activeCameraMode then restoreDefaultCamera() end
if fakeLagActive then return end
if desiredWalkSpeed then humanoid.WalkSpeed = desiredWalkSpeed end
if humanoid.UseJumpPower and desiredJumpPower then humanoid.JumpPower = desiredJumpPower
elseif not humanoid.UseJumpPower and desiredJumpHeight then humanoid.JumpHeight = desiredJumpHeight end
end)
end))
trackConnection(LocalPlayer.CharacterRemoving:Connect(function()
if cancelAutoWin then cancelAutoWin(true) end
killerSession = killerSession + 1; killerActive = false
clearCurrentCartCache(); cleanupStabilizer(); restorePanicStop()
if stopBoost then stopBoost() end
if flyEnabled and flyToggleControl then flyToggleControl:UpdateToggle(nil, false) else stopFly() end
resetCameraModes()
end))
trackConnection(LocalPlayer.CharacterAdded:Connect(function() killerSession = killerSession + 1 killerActive = false end))
end
-- =============================================================================
-- Abertura: Poema já selecionado (primeira aba), sem key, sem som externo
-- =============================================================================
if destroyed or not runtime.Parent or not isCurrentSuiteGeneration() then return end
if startup.status and startup.status.Parent then startup.status.Text = "Pronto!" end
if startup.gui and startup.gui.Parent then startup.gui:Destroy() end
menuGui.Enabled = true
setMenuVisible(true)
notify(MENU_NAME, "Feito por Cafezl • sem key • K minimiza e reabre.")
