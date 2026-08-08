Exit code: 0
Wall time: 0.8 seconds
Output:
-- Diagnostico temporario do Cafezitos completo.
-- Este arquivo mostra a mensagem real se o roteiro grande falhar ao carregar.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    if type(gethui) == "function" then
        local ok, parent = pcall(gethui)
        if ok and parent then return parent end
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function showMessage(title, message)
    warn(title .. ": " .. message)
    local parent = getGuiParent()
    local previous = parent:FindFirstChild("CafezitosDiagnostic")
    if previous then previous:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "CafezitosDiagnostic"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = parent

    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.Position = UDim2.fromScale(0.5, 0.5)
    box.Size = UDim2.fromOffset(520, 220)
    box.BackgroundColor3 = Color3.fromRGB(47, 27, 20)
    box.BorderSizePixel = 0
    box.Parent = gui
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 16)

    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Position = UDim2.fromOffset(18, 16)
    header.Size = UDim2.new(1, -36, 0, 28)
    header.Font = Enum.Font.GothamBold
    header.Text = title
    header.TextColor3 = Color3.fromRGB(255, 215, 169)
    header.TextSize = 18
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = box

    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(18, 54)
    body.Size = UDim2.new(1, -36, 1, -72)
    body.Font = Enum.Font.Code
    body.Text = message
    body.TextColor3 = Color3.fromRGB(255, 237, 220)
    body.TextSize = 13
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.Parent = box
end

local url = "https://raw.githubusercontent.com/cafezl/cart-ride-nothing-around/main/Cafezitos-completo.lua"
local okHttp, source = pcall(function()
    return game:HttpGet(url)
end)
if not okHttp or type(source) ~= "string" then
    showMessage("Cafezitos nao baixou", tostring(source))
    return
end

local run, compileError = loadstring(source)
if not run then
    showMessage("Cafezitos nao compilou", tostring(compileError))
    return
end

local okRun, runtimeError = xpcall(run, function(errorMessage)
    return debug.traceback(tostring(errorMessage), 2)
end)
if not okRun then
    showMessage("Cafezitos parou ao abrir", tostring(runtimeError))
end

