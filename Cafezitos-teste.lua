-- Diagnostico temporario do Cafezitos completo.
-- Este arquivo mostra a mensagem real se o roteiro grande falhar ao carregar.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
do
    local deadline = os.clock() + 10
    while not LocalPlayer and os.clock() < deadline do
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
    end
    if not LocalPlayer then error("Diagnóstico: execute no cliente do Roblox, após entrar no jogo.") end
end

local environment = _G
if type(getgenv) == "function" then
    local ok, candidate = pcall(getgenv)
    if ok and type(candidate) == "table" then environment = candidate end
end
local target = environment.CafezlDiagnosticTarget or "Cafezitos"
local sourceRef = environment.CafezlDiagnosticRef or "main"

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
        if ok then
            local ready = usable(parent)
            if ready then return ready end
        end
    end
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok then
        local ready = usable(core)
        if ready then return ready end
    end
    return usable(LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10))
end

local function showMessage(title, message)
    message = tostring(message):gsub("NLEASE%-%x+", "[autorização ocultada]")
        :gsub("NOTH%-%w[%w%-]+", "[key ocultada]")
        :gsub("([?&][%w_]*[Tt][Oo][Kk][Ee][Nn]=)[^&%s]+", "%1[oculto]")
        :sub(1, 1600)
    warn(title .. ": " .. message)
    local parent = getGuiParent()
    if not parent then return end
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
    box.Size = UDim2.new(0.92, 0, 0, 260)
    box.BackgroundColor3 = Color3.fromRGB(47, 27, 20)
    box.BorderSizePixel = 0
    box.Parent = gui
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 16)
    local size = Instance.new("UISizeConstraint")
    size.MaxSize = Vector2.new(600, 260)
    size.Parent = box

    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Position = UDim2.fromOffset(18, 16)
    header.Size = UDim2.new(1, -80, 0, 28)
    header.Font = Enum.Font.GothamBold
    header.Text = title
    header.TextColor3 = Color3.fromRGB(255, 215, 169)
    header.TextSize = 18
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = box

    local close = Instance.new("TextButton")
    close.Position = UDim2.new(1, -48, 0, 12)
    close.Size = UDim2.fromOffset(36, 36)
    close.Text = "×"
    close.TextSize = 24
    close.Parent = box
    close.Activated:Connect(function() gui:Destroy() end)

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

if target ~= "Cafezitos" and target ~= "Nothrilo" then
    showMessage("Diagnóstico", "CafezlDiagnosticTarget deve ser Cafezitos ou Nothrilo.")
    return
end
if type(sourceRef) ~= "string" or #sourceRef > 160 or not sourceRef:match("^[%w%._/%-]+$") or sourceRef:find("..", 1, true) then
    showMessage("Diagnóstico", "A referência do GitHub é inválida.")
    return
end
local url = "https://raw.githubusercontent.com/cafezl/cart-ride-nothing-around/" .. sourceRef .. "/" .. target .. ".lua"
local okHttp, source = pcall(function()
    return game:HttpGet(url)
end)
if not okHttp or type(source) ~= "string" or #source == 0 or #source > 1024 * 1024 then
    showMessage(target .. " não baixou", okHttp and "Resposta vazia ou maior que 1 MiB." or tostring(source))
    return
end

if type(loadstring) ~= "function" then
    showMessage(target .. " não compilou", "Este ambiente não oferece loadstring. Verifique o ambiente de teste autorizado.")
    return
end
local okCompile, run, compileError = pcall(loadstring, source, "@Cafezl/" .. target)
if not okCompile or type(run) ~= "function" then
    showMessage(target .. " não compilou", tostring(okCompile and compileError or run))
    return
end

local okRun, runtimeError = xpcall(run, function(errorMessage)
    return debug and type(debug.traceback) == "function" and debug.traceback(tostring(errorMessage), 2) or tostring(errorMessage)
end)
if not okRun then
    showMessage(target .. " parou ao abrir", tostring(runtimeError))
end
