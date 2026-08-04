-- Cafezl Cart Ride Menu
-- Menu no estilo Kavo, com tema preto, ícones RGB e botão para minimizar/reabrir.
-- Use somente no seu próprio place de teste.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local MENU_NAME = "Nothrilo 🇧🇷"
local UI_TITLE = MENU_NAME .. " | Feito por Cafezl"
local CoreGui = game:GetService("CoreGui")

-- Ao executar o loader de novo, encerra a instancia anterior antes de criar
-- outra. Isso evita menus e atalhos duplicados na mesma partida.
local previousRuntime = CoreGui:FindFirstChild("NothriloRuntime")
if previousRuntime then
    local previousCleanup = previousRuntime:FindFirstChild("Cleanup")
    if previousCleanup and previousCleanup:IsA("BindableEvent") then
        previousCleanup:Fire()
    end
    previousRuntime:Destroy()
end

local runtime = Instance.new("Folder")
runtime.Name = "NothriloRuntime"
runtime.Parent = CoreGui

local runtimeCleanup = Instance.new("BindableEvent")
runtimeCleanup.Name = "Cleanup"
runtimeCleanup.Parent = runtime

-- A segunda script original inicializa Rayfield e exibe o aviso de divulgação.
-- Esta versão não usa Rayfield; remove apenas uma janela antiga que tenha ficado
-- aberta depois de executar a script original.
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Name:lower():find("rayfield", 1, true) then
        gui:Destroy()
    end
end

-- Limpa apenas janelas antigas deste proprio menu que tenham sobrado de uma
-- versao anterior sem o controlador acima.
for _, gui in ipairs(CoreGui:GetChildren()) do
    if gui:IsA("ScreenGui") and (gui.Name == "NothriloLauncher" or gui.Name == "NothriloNotifications") then
        gui:Destroy()
    elseif gui:IsA("ScreenGui") then
        local main = gui:FindFirstChild("Main")
        local header = main and main:FindFirstChild("MainHeader")
        local title = header and header:FindFirstChild("title")
        if title and (title.Text == UI_TITLE or title.Text:find("Nothrilo", 1, true)) then
            gui:Destroy()
        end
    end
end

-- Mantém toda a interface preta; somente os detalhes e ícones passam pelo RGB.
local Theme = {
    SchemeColor = Color3.fromRGB(255, 0, 170),
    Background = Color3.fromRGB(8, 8, 10),
    Header = Color3.fromRGB(15, 15, 18),
    TextColor = Color3.fromRGB(245, 245, 245),
    ElementColor = Color3.fromRGB(22, 22, 27),
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib(UI_TITLE, Theme)

local toastContainer
local toastStrokes = {}

-- Notificacao visual propria: aparece fora do menu, no canto direito, sem
-- qualquer mensagem da biblioteca Rayfield.
local function notify(title, text)
    if not toastContainer or not toastContainer.Parent then
        warn((title or MENU_NAME) .. ": " .. (text or ""))
        return
    end

    local card = Instance.new("Frame")
    card.Name = "NothriloToast"
    card.Size = UDim2.new(1, 0, 0, 74)
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
    card.BackgroundTransparency = 1
    card.BorderSizePixel = 0
    card.Parent = toastContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Name = "RGBStroke"
    stroke.Thickness = 1.5
    stroke.Transparency = 1
    stroke.Parent = card
    table.insert(toastStrokes, stroke)

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.fromOffset(42, 42)
    icon.Position = UDim2.fromOffset(14, 16)
    icon.BackgroundColor3 = Color3.fromRGB(30, 30, 37)
    icon.BackgroundTransparency = 1
    icon.Font = Enum.Font.GothamBold
    icon.Text = "N"
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.TextSize = 18
    icon.TextTransparency = 1
    icon.Parent = card

    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(1, 0)
    iconCorner.Parent = icon

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -76, 0, 20)
    titleLabel.Position = UDim2.fromOffset(68, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title or MENU_NAME
    titleLabel.TextColor3 = Color3.fromRGB(250, 250, 252)
    titleLabel.TextSize = 14
    titleLabel.TextTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = card

    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Size = UDim2.new(1, -76, 0, 30)
    bodyLabel.Position = UDim2.fromOffset(68, 34)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.Font = Enum.Font.Gotham
    bodyLabel.Text = text or ""
    bodyLabel.TextColor3 = Color3.fromRGB(185, 185, 195)
    bodyLabel.TextSize = 12
    bodyLabel.TextTransparency = 1
    bodyLabel.TextWrapped = true
    bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    bodyLabel.Parent = card

    TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
    }):Play()
    TweenService:Create(stroke, TweenInfo.new(0.22), { Transparency = 0.15 }):Play()
    TweenService:Create(icon, TweenInfo.new(0.22), { BackgroundTransparency = 0, TextTransparency = 0 }):Play()
    TweenService:Create(titleLabel, TweenInfo.new(0.22), { TextTransparency = 0 }):Play()
    TweenService:Create(bodyLabel, TweenInfo.new(0.22), { TextTransparency = 0 }):Play()

    task.delay(4, function()
        if not card.Parent then return end
        TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
        TweenService:Create(icon, TweenInfo.new(0.2), { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
        TweenService:Create(bodyLabel, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
        task.wait(0.25)
        card:Destroy()
    end)
end

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid(character)
    character = character or getCharacter()
    return character and (character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5))
end

local function getRoot(character)
    character = character or getCharacter()
    return character and (character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 5))
end

local function teleportCharacter(cframe)
    local root = getRoot()
    if not root then
        notify("Teleport", "HumanoidRootPart não encontrado.")
        return false
    end

    root.CFrame = cframe
    return true
end

-- ESP local: marca os outros jogadores apenas na sua tela.
local ESP_TAG = "NothriloESP"
local espEnabled = false
local espObjects = {}
local espPlayerConnections = {}
local espGlobalConnections = {}
local espSession = 0

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
        if object and object.Parent then
            object:Destroy()
        end
    end
    espObjects[player] = nil
end

local function refreshESPColor(player)
    local objects = espObjects[player]
    if not objects then return end

    local color = getESPColor(player)
    if objects.Highlight and objects.Highlight.Parent then
        objects.Highlight.FillColor = color
        objects.Highlight.OutlineColor = color
    end
    if objects.Label and objects.Label.Parent then
        objects.Label.TextColor3 = color
    end
end

local function refreshESPSize(player)
    local objects = espObjects[player]
    if not objects or not objects.Billboard or not objects.Billboard.Parent then
        return
    end

    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local targetRoot = objects.Billboard.Adornee
    if not localRoot or not targetRoot or not targetRoot.Parent then
        return
    end

    local distance = (localRoot.Position - targetRoot.Position).Magnitude
    -- Perto: nome discreto. A partir de 90 studs ele aumenta aos poucos; no
    -- maximo, so fica grande quando o jogador esta realmente distante.
    local progress = math.clamp((distance - 90) / 510, 0, 1)
    local width = math.floor(78 + (170 - 78) * progress)
    local height = math.floor(16 + (36 - 16) * progress)
    objects.Billboard.Size = UDim2.fromOffset(width, height)
end

local function addESP(player, character)
    if not espEnabled or player == LocalPlayer then return end

    character = character or player.Character
    if not character or not character.Parent then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    removeESP(player)

    -- O nome fica visivel a qualquer distancia enquanto o personagem tiver sido
    -- carregado pelo Roblox neste cliente.
    local billboard = Instance.new("BillboardGui")
    billboard.Name = ESP_TAG .. "Name"
    billboard.Size = UDim2.fromOffset(78, 16)
    billboard.Adornee = root
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = math.huge
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.Parent = root

    local label = Instance.new("TextLabel")
    label.Name = "NameLabel"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = player.DisplayName ~= "" and player.DisplayName or player.Name
    label.TextScaled = true
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Parent = billboard

    local highlight = Instance.new("Highlight")
    highlight.Name = ESP_TAG
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = character

    espObjects[player] = {
        Billboard = billboard,
        Label = label,
        Highlight = highlight,
    }
    refreshESPColor(player)
    refreshESPSize(player)
end

local function disconnectESPPlayer(player)
    local connections = espPlayerConnections[player]
    if connections then
        for _, connection in ipairs(connections) do
            connection:Disconnect()
        end
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
    for _, connection in ipairs(espGlobalConnections) do
        connection:Disconnect()
    end
    table.clear(espGlobalConnections)

    local watchedPlayers = {}
    for player in pairs(espPlayerConnections) do
        table.insert(watchedPlayers, player)
    end
    for _, player in ipairs(watchedPlayers) do
        disconnectESPPlayer(player)
    end

    local markedPlayers = {}
    for player in pairs(espObjects) do
        table.insert(markedPlayers, player)
    end
    for _, player in ipairs(markedPlayers) do
        removeESP(player)
    end
end

local function setESP(enabled)
    espEnabled = enabled
    espSession = espSession + 1
    clearESP()

    if not enabled then
        notify("ESP", "Desligado.")
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        watchESPPlayer(player)
    end
    table.insert(espGlobalConnections, Players.PlayerAdded:Connect(watchESPPlayer))
    table.insert(espGlobalConnections, Players.PlayerRemoving:Connect(function(player)
        removeESP(player)
        disconnectESPPlayer(player)
    end))

    -- Em mapas com carregamento por distancia, o modelo do outro jogador pode
    -- chegar alguns segundos depois do Player. Revisa sem criar ESP duplicado.
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

-- ============================================================================
-- Fly da segunda script
-- ============================================================================

local FLYING = false
local vehicleFlySpeed = 1
local flyKeyDown
local flyKeyUp
local flyHumanoid
local flyAutoRotate
local flyPlatformStand
local mouse = LocalPlayer:GetMouse()

local function stopFly()
    FLYING = false

    if flyKeyDown then
        flyKeyDown:Disconnect()
        flyKeyDown = nil
    end
    if flyKeyUp then
        flyKeyUp:Disconnect()
        flyKeyUp = nil
    end

    local humanoid = flyHumanoid or getHumanoid()
    if humanoid then
        humanoid.PlatformStand = flyPlatformStand ~= nil and flyPlatformStand or false
        humanoid.AutoRotate = flyAutoRotate ~= nil and flyAutoRotate or true
        pcall(function()
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        end)
    end
    flyHumanoid = nil
    flyAutoRotate = nil
    flyPlatformStand = nil

    pcall(function()
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
    end)
end

local function startVehicleFly()
    stopFly()

    local character = getCharacter()
    local root = getRoot(character)
    local humanoid = getHumanoid(character)
    if not root or not humanoid then
        notify("Voo do Veículo", "Personagem não encontrado.")
        return
    end

    -- Evita a animacao de queda enquanto o BodyVelocity controla o personagem.
    flyHumanoid = humanoid
    flyAutoRotate = humanoid.AutoRotate
    flyPlatformStand = humanoid.PlatformStand
    humanoid.AutoRotate = false
    -- Quando ja esta sentado, PlatformStand pode soltar o personagem do
    -- carrinho e impedir o Killer. Fora do carrinho ele evita a animacao de
    -- queda normalmente.
    if not humanoid.SeatPart then
        humanoid.PlatformStand = true
    end
    pcall(function()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end)

    local control = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
    local lastControl = { F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0 }
    local speed = 0
    FLYING = true

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "CafezlVehicleFlyGyro"
    bodyGyro.P = 90000
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "CafezlVehicleFlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    flyKeyDown = mouse.KeyDown:Connect(function(key)
        key = key:lower()
        if key == "w" then
            control.F = vehicleFlySpeed
        elseif key == "s" then
            control.B = -vehicleFlySpeed
        elseif key == "a" then
            control.L = -vehicleFlySpeed
        elseif key == "d" then
            control.R = vehicleFlySpeed
        elseif key == "e" then
            control.Q = vehicleFlySpeed * 2
        elseif key == "q" then
            control.E = -vehicleFlySpeed * 2
        end

        pcall(function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Track
        end)
    end)

    flyKeyUp = mouse.KeyUp:Connect(function(key)
        key = key:lower()
        if key == "w" then
            control.F = 0
        elseif key == "s" then
            control.B = 0
        elseif key == "a" then
            control.L = 0
        elseif key == "d" then
            control.R = 0
        elseif key == "e" then
            control.Q = 0
        elseif key == "q" then
            control.E = 0
        end
    end)

    task.spawn(function()
        while FLYING and root.Parent and humanoid.Parent do
            task.wait()

            local moving = control.L + control.R ~= 0
                or control.F + control.B ~= 0
                or control.Q + control.E ~= 0

            speed = moving and 50 or 0
            if moving then
                lastControl = {
                    F = control.F,
                    B = control.B,
                    L = control.L,
                    R = control.R,
                    Q = control.Q,
                    E = control.E,
                }
            end

            local current = moving and control or lastControl
            if speed > 0 then
                local camera = workspace.CurrentCamera
                bodyVelocity.Velocity = (
                    (camera.CFrame.LookVector * (current.F + current.B))
                    + ((camera.CFrame * CFrame.new(
                        current.L + current.R,
                        (current.F + current.B + current.Q + current.E) * 0.2,
                        0
                    )).Position - camera.CFrame.Position)
                ) * speed
            else
                bodyVelocity.Velocity = Vector3.zero
            end

            bodyGyro.CFrame = workspace.CurrentCamera.CFrame
        end

        if bodyGyro.Parent then bodyGyro:Destroy() end
        if bodyVelocity.Parent then bodyVelocity:Destroy() end
    end)
end

-- ============================================================================
-- Carrinho: parar, checkpoints e estabilizador
-- ============================================================================

local function findCartFromSeat(seat)
    if not seat then return nil end

    local current = seat.Parent
    while current and current ~= workspace do
        if current:IsA("Model") then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function getCurrentCart()
    local humanoid = getHumanoid()
    return humanoid and findCartFromSeat(humanoid.SeatPart) or nil
end

local panicParts = {}
local function restorePanicStop()
    for part, wasAnchored in pairs(panicParts) do
        if part and part.Parent then
            part.Anchored = wasAnchored
        end
    end
    panicParts = {}
end

local function setPanicStop(enabled)
    local cart = getCurrentCart()
    if not cart then
        notify("Cart", "Sente em um carrinho primeiro.")
        return
    end

    if enabled then
        panicParts = {}
        for _, part in ipairs(cart:GetDescendants()) do
            if part:IsA("BasePart") then
                panicParts[part] = part.Anchored
                part.Anchored = true
                part.AssemblyLinearVelocity = Vector3.zero
                part.AssemblyAngularVelocity = Vector3.zero
            end
        end
    else
        restorePanicStop()
    end
end

local function teleportCart(cframe)
    local cart = getCurrentCart()
    if not cart then
        notify("Cart", "Sente em um carrinho primeiro.")
        return
    end

    local ok = pcall(function()
        cart:PivotTo(cframe)
    end)
    if not ok then
        notify("Cart", "Não foi possível mover este carrinho.")
    end
end

local STABILIZER_CONFIG = {
    NORMAL_FORCE = 2500,
    DOWNHILL_FORCE = 800,
}

local stabilizer = {
    enabled = false,
    cart = nil,
    forces = {},
    heartbeat = nil,
}

local function cleanupStabilizer()
    if stabilizer.heartbeat then
        stabilizer.heartbeat:Disconnect()
        stabilizer.heartbeat = nil
    end

    for _, force in ipairs(stabilizer.forces) do
        if force and force.Parent then
            force:Destroy()
        end
    end

    stabilizer.forces = {}
    stabilizer.cart = nil
end

local function getWheels(cart)
    local wheels = {}
    local keywords = { "wheel", "tire", "tyre", "roda", "pneu", "axle" }

    for _, part in ipairs(cart:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored then
            local name = part.Name:lower()
            for _, keyword in ipairs(keywords) do
                if name:find(keyword, 1, true) then
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
        table.sort(parts, function(a, b)
            return a.Position.Y < b.Position.Y
        end)

        local count = math.max(1, math.floor(#parts / 3))
        for index = 1, math.min(count, #parts) do
            table.insert(wheels, parts[index])
        end
    end

    return wheels
end

local function applyStabilizer(cart)
    if not cart or not cart.Parent then return end
    cleanupStabilizer()

    local wheels = getWheels(cart)
    if #wheels == 0 then
        notify("Estabilizador", "Nenhuma roda foi encontrada.")
        return
    end

    stabilizer.cart = cart
    for _, part in ipairs(wheels) do
        local attachment = part:FindFirstChild("_CafezlStabilizer")
        if not attachment then
            attachment = Instance.new("Attachment")
            attachment.Name = "_CafezlStabilizer"
            attachment.Parent = part
        end

        local force = Instance.new("VectorForce")
        force.Name = "CafezlStabilizerForce"
        force.Attachment0 = attachment
        force.RelativeTo = Enum.ActuatorRelativeTo.World
        force.Force = Vector3.zero
        force.Parent = part
        table.insert(stabilizer.forces, force)
    end

    local reference = cart.PrimaryPart or wheels[1]
    stabilizer.heartbeat = RunService.Heartbeat:Connect(function()
        if not reference or not reference.Parent then
            cleanupStabilizer()
            return
        end

        local magnitude = 0
        if stabilizer.enabled and not FLYING then
            if math.abs(reference.AssemblyLinearVelocity.Y) > 5 then
                magnitude = STABILIZER_CONFIG.DOWNHILL_FORCE
            else
                magnitude = STABILIZER_CONFIG.NORMAL_FORCE
            end
        end

        for _, force in ipairs(stabilizer.forces) do
            if force and force.Parent then
                force.Force = Vector3.new(0, -magnitude * force.Parent.AssemblyMass, 0)
            end
        end
    end)
end

local function refreshStabilizer()
    if stabilizer.enabled then
        local cart = getCurrentCart()
        if cart then
            applyStabilizer(cart)
        else
            notify("Estabilizador", "Sente em um carrinho primeiro.")
        end
    else
        cleanupStabilizer()
    end
end

local function watchSeat(character)
    local humanoid = getHumanoid(character)
    if not humanoid then return end

    humanoid.Seated:Connect(function(isSeated, seat)
        if not isSeated then
            cleanupStabilizer()
        elseif stabilizer.enabled then
            applyStabilizer(findCartFromSeat(seat))
        end
    end)
end

watchSeat()
LocalPlayer.CharacterAdded:Connect(function(character)
    cleanupStabilizer()
    task.defer(watchSeat, character)
end)

-- ============================================================================
-- Ação de alvo da segunda script
-- ============================================================================

local function findNearestFreeVehicleSeat()
    local root = getRoot()
    if not root then return nil end

    local nearestVehicleSeat
    local nearestVehicleDistance = math.huge
    local nearestSeat
    local nearestSeatDistance = math.huge
    for _, instance in ipairs(workspace:GetDescendants()) do
        if (instance:IsA("VehicleSeat") or instance:IsA("Seat")) and not instance.Occupant then
            local distance = (root.Position - instance.Position).Magnitude
            if instance:IsA("VehicleSeat") and distance < nearestVehicleDistance then
                nearestVehicleSeat = instance
                nearestVehicleDistance = distance
            elseif instance:IsA("Seat") and distance < nearestSeatDistance then
                nearestSeat = instance
                nearestSeatDistance = distance
            end
        end
    end

    -- Prioriza VehicleSeat (o assento de carrinho) e usa Seat normal somente
    -- como reserva para mapas que nao usam VehicleSeat.
    return nearestVehicleSeat or nearestSeat
end

local function findPlayerByPartialName(value)
    value = (value or ""):match("^%s*(.-)%s*$"):lower()
    if value == "" then return nil end

    -- Nome exato ganha de nome parcial para nao escolher outra pessoa quando
    -- existem apelidos parecidos no servidor.
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Name:lower() == value or player.DisplayName:lower() == value then
            return player
        end
    end

    -- Se nao for exato, prioriza o comeco do nome antes de procurar no meio.
    for _, player in ipairs(Players:GetPlayers()) do
        local name = player.Name:lower()
        local displayName = player.DisplayName:lower()
        if name:sub(1, #value) == value or displayName:sub(1, #value) == value then
            return player
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local name = player.Name:lower()
        local displayName = player.DisplayName:lower()
        if name:find(value, 1, true) or displayName:find(value, 1, true) then
            return player
        end
    end
    return nil
end

local function sitOnVehicleSeat(seat)
    local root = getRoot()
    local humanoid = getHumanoid()
    if not seat or not root or not humanoid or seat.Occupant then
        return false
    end

    -- O jogo pode demorar alguns frames para registrar a ocupacao. Tres
    -- tentativas curtas e o fallback Humanoid.Sit tornam isso mais confiavel.
    for _ = 1, 3 do
        if not seat.Parent or seat.Occupant then break end
        root.CFrame = seat.CFrame * CFrame.new(0, 2, 0)
        task.wait(0.12)
        pcall(function()
            seat:Sit(humanoid)
        end)
        task.wait(0.2)

        if humanoid.SeatPart == seat or seat.Occupant == humanoid then
            return true
        end

        humanoid.Sit = true
        task.wait(0.12)
        if humanoid.SeatPart == seat or seat.Occupant == humanoid then
            return true
        end
    end

    return false
end

local function moveToTarget(targetRoot, duration)
    local root = getRoot()
    local started = os.clock()
    while os.clock() - started < duration do
        if not root or not root.Parent or not targetRoot or not targetRoot.Parent then
            break
        end

        local position = targetRoot.Position - targetRoot.CFrame.LookVector * 1.2 + Vector3.new(0, 1.5, 0)
        root.CFrame = CFrame.lookAt(position, targetRoot.Position)
        task.wait()
    end
end

local killerActive = false

local function finishKiller(message)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.Sit = false
    end
    stopFly()
    killerActive = false

    if message then
        notify("Eliminador", message)
    end
end

local function executeKiller(partialName)
    if killerActive then
        notify("Eliminador", "Aguarde a tentativa atual terminar.")
        return
    end
    killerActive = true

    -- Esta ordem e a mesma do menu de referencia: primeiro pega um carrinho,
    -- depois liga o Vehicle Fly e so entao acompanha o alvo.
    stopFly()
    local seat = findNearestFreeVehicleSeat()
    if not seat then
        finishKiller("Nao ha carrinho livre por perto.")
        return
    end
    if not sitOnVehicleSeat(seat) then
        finishKiller("Nao foi possivel sentar no carrinho.")
        return
    end

    startVehicleFly()
    task.wait(0.15)

    local target = findPlayerByPartialName(partialName)
    if not target then
        finishKiller("Jogador nao encontrado.")
        return
    end

    -- O alvo pode estar fora de um carrinho. So precisamos que o personagem
    -- dele tenha carregado neste cliente.
    local targetRoot
    local deadline = os.clock() + 2
    repeat
        local targetCharacter = target.Character
        targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
        if targetRoot then break end
        task.wait(0.2)
    until os.clock() >= deadline

    if not targetRoot then
        finishKiller("O personagem do alvo ainda nao carregou.")
        return
    end

    moveToTarget(targetRoot, 3)
    finishKiller("Carrinho levado ao alvo.")
end

-- ============================================================================
-- Interface no formato da primeira script
-- ============================================================================

local PlayerTab = Window:NewTab("Jogador")
local PlayerSection = PlayerTab:NewSection("Configurações do Jogador")

PlayerSection:NewSlider("Velocidade", "Define a velocidade do personagem.", 500, 0, function(value)
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = value
    end
end)

PlayerSection:NewButton("Redefinir Velocidade", "Volta a velocidade para 16.", function()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = 16
    end
end)

local infiniteJump = false
PlayerSection:NewToggle("Pulo Infinito", "Permite pular enquanto estiver no ar.", function(state)
    infiniteJump = state
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local humanoid = getHumanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

PlayerSection:NewButton("Teleporte por Clique", "Cria a ferramenta de teleporte na mochila.", function()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then return end
    if backpack:FindFirstChild("ClickTP") then
        notify("Teleporte por Clique", "A ferramenta já está na mochila.")
        return
    end

    local tool = Instance.new("Tool")
    tool.Name = "ClickTP"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        teleportCharacter(CFrame.new(mouse.Hit.Position + Vector3.new(0, 2.5, 0)))
    end)
    tool.Parent = backpack
end)

PlayerSection:NewTextBox("Ir até Jogador", "Digite o nome do jogador e aperte Enter.", function(name)
    local player = findPlayerByPartialName(name)
    if not player then
        notify("Ir ate Jogador", "Jogador nao encontrado.")
        return
    end

    local targetRoot
    local deadline = os.clock() + 2
    repeat
        local character = player.Character
        targetRoot = character and character:FindFirstChild("HumanoidRootPart")
        if targetRoot then break end
        task.wait(0.2)
    until os.clock() >= deadline

    if not targetRoot then
        notify("Ir ate Jogador", "O personagem ainda nao carregou.")
        return
    end

    teleportCharacter(targetRoot.CFrame * CFrame.new(0, 2, 0))
    notify("Ir ate Jogador", "Teleportado para " .. player.DisplayName .. ".")
end)

local flyEnabled = false
PlayerSection:NewKeybind("Alternar Voo do Veículo", "Tecla V liga ou desliga o voo.", Enum.KeyCode.V, function()
    flyEnabled = not flyEnabled
    if flyEnabled then
        startVehicleFly()
        notify("Voo do Veículo", "Ligado.")
    else
        stopFly()
        notify("Voo do Veículo", "Desligado.")
    end
end)

PlayerSection:NewToggle("ESP", "Destaca os outros jogadores na sua tela.", setESP)

PlayerSection:NewTextBox("Velocidade do Voo", "Digite a velocidade e aperte Enter.", function(value)
    local number = tonumber(value)
    if number and number > 0 then
        vehicleFlySpeed = number
        notify("Voo do Veículo", "Velocidade: " .. number)
    else
        notify("Voo do Veículo", "Digite um número maior que zero.")
    end
end)

local TeleportTab = Window:NewTab("Teleporte")
local TeleportSection = TeleportTab:NewSection("Teleportes")

TeleportSection:NewButton("Inicio", "Teleporta para o inicio.", function()
    teleportCharacter(CFrame.new(1, 3.11, 38))
end)

TeleportSection:NewButton("Botão de Carrinho", "Teleporta para o botão de carrinho.", function()
    teleportCharacter(CFrame.new(-33, 3.11, 21.5) * CFrame.Angles(0, math.rad(180), 0))
end)

TeleportSection:NewButton("Equipe Suffering", "Teleporta para o time Suffering.", function()
    teleportCharacter(CFrame.new(-416.844727, 163.402969, 171.087555))
end)

TeleportSection:NewButton("Sala Secreta", "Procura Workspace.Misc.Giver.", function()
    local misc = workspace:FindFirstChild("Misc")
    local giver = misc and misc:FindFirstChild("Giver")
    local part = giver and (giver:IsA("BasePart") and giver or giver:FindFirstChildWhichIsA("BasePart"))
    if not part then
        notify("Teleport", "Misc.Giver não encontrado.")
        return
    end
    teleportCharacter(part.CFrame * CFrame.new(0, 3, 0))
end)

local CartTab = Window:NewTab("Carrinho")
local CartSection = CartTab:NewSection("Controle do Carrinho")

CartSection:NewToggle("Parada de Emergência", "Para e trava o carrinho; desligue para restaurar.", setPanicStop)

CartSection:NewButton("Ir ao Checkpoint 1", "Move o carrinho para o checkpoint 1.", function()
    teleportCart(CFrame.new(-430.898926, 164.75, 101.645676) * CFrame.Angles(0, math.rad(90), 0))
end)

CartSection:NewButton("Ir ao Checkpoint 2", "Move o carrinho para o checkpoint 2.", function()
    teleportCart(CFrame.new(511.88, 3.69, 306.59) * CFrame.Angles(0, math.rad(270), 0))
end)

CartSection:NewButton("Ir ao Checkpoint 3", "Move o carrinho para o checkpoint 3.", function()
    teleportCart(CFrame.new(171.09, 2.78, -410.31) * CFrame.Angles(0, math.rad(90), 0))
end)

local StabilizerSection = CartTab:NewSection("Estabilizador")
StabilizerSection:NewToggle("Estabilizador do Carrinho", "Mantém o carrinho estável enquanto você está sentado.", function(state)
    stabilizer.enabled = state
    refreshStabilizer()
end)

StabilizerSection:NewTextBox("Força Normal", "Força normal; aperte Enter para aplicar.", function(value)
    local number = tonumber(value)
    if number and number > 0 then
        STABILIZER_CONFIG.NORMAL_FORCE = number
        notify("Estabilizador", "Força normal: " .. number)
    else
        notify("Estabilizador", "Digite um número maior que zero.")
    end
end)

StabilizerSection:NewTextBox("Força em Descidas", "Força em descidas; aperte Enter para aplicar.", function(value)
    local number = tonumber(value)
    if number and number > 0 then
        STABILIZER_CONFIG.DOWNHILL_FORCE = number
        notify("Estabilizador", "Força de descida: " .. number)
    else
        notify("Estabilizador", "Digite um número maior que zero.")
    end
end)

local KillerTab = Window:NewTab("Eliminador")
local KillerSection = KillerTab:NewSection("Controle de Alvo")
local targetName = ""

KillerSection:NewTextBox("Nome do Alvo", "Digite uma parte do nome e aperte Enter.", function(value)
    targetName = value
end)

KillerSection:NewButton("Alcançar Alvo", "Usa o carrinho livre mais próximo para alcançar o alvo.", function()
    if not targetName or targetName:match("^%s*$") then
        notify("Eliminador", "Digite uma parte do nome primeiro.")
        return
    end
    local requestedTarget = targetName
    task.spawn(function()
        local ok, errorMessage = xpcall(function()
            executeKiller(requestedTarget)
        end, debug.traceback)
        if not ok then
            warn(MENU_NAME .. " Killer: " .. errorMessage)
            if killerActive then
                finishKiller("A tentativa encontrou um erro. Tente de novo.")
            end
        end
    end)
end)

-- ============================================================================
-- Minimizar e reabrir: o X azul original fica escondido para não destruir tudo.
-- ============================================================================

local function findMenuGui()
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") then
            local main = gui:FindFirstChild("Main")
            local header = main and main:FindFirstChild("MainHeader")
            local title = header and header:FindFirstChild("title")
            if title and title.Text == UI_TITLE then
                return gui
            end
        end
    end
    return nil
end

local menuGui = findMenuGui()
if not menuGui then
    warn(MENU_NAME .. ": nao foi possivel localizar a janela Kavo.")
    return
end

-- Deixa a janela e cada controle menos quadrados, sem trocar o layout do
-- primeiro menu que voce escolheu.
local function applyRoundedStyle(root)
    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("UICorner") then
            object.CornerRadius = UDim.new(0, 12)
        end
    end
end

applyRoundedStyle(menuGui)
menuGui.DescendantAdded:Connect(function(object)
    if object:IsA("UICorner") then
        object.CornerRadius = UDim.new(0, 12)
    end
end)

local toastGui = Instance.new("ScreenGui")
toastGui.Name = "NothriloNotifications"
toastGui.ResetOnSpawn = false
toastGui.IgnoreGuiInset = true
toastGui.DisplayOrder = 10001
toastGui.Parent = menuGui.Parent

toastContainer = Instance.new("Frame")
toastContainer.Name = "ToastContainer"
toastContainer.AnchorPoint = Vector2.new(1, 0)
toastContainer.Position = UDim2.new(1, -18, 0, 20)
toastContainer.Size = UDim2.fromOffset(300, 300)
toastContainer.BackgroundTransparency = 1
toastContainer.Parent = toastGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.Padding = UDim.new(0, 8)
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Parent = toastContainer

-- Arrastar funciona com mouse e com toque. O Kavo continua responsavel pelo
-- restante da interface; isto so resolve a movimentacao no celular.
local function enableDrag(target, handle, onDragEnd)
    target.Active = true
    handle.Active = true

    local dragging = false
    local dragInput
    local dragStart
    local startPosition
    local wasDragged = false

    local function updatePosition(input)
        local delta = input.Position - dragStart
        if delta.Magnitude > 6 then
            wasDragged = true
        end
        target.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        dragging = true
        wasDragged = false
        dragStart = input.Position
        startPosition = target.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                if onDragEnd then
                    onDragEnd(wasDragged)
                end
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
        if dragging and input == dragInput then
            updatePosition(input)
        end
    end)
end

local launcherGui = Instance.new("ScreenGui")
launcherGui.Name = "NothriloLauncher"
launcherGui.ResetOnSpawn = false
launcherGui.IgnoreGuiInset = true
launcherGui.DisplayOrder = 10000
launcherGui.Parent = menuGui.Parent

local launcher = Instance.new("TextButton")
launcher.Name = "OpenNothriloMenu"
launcher.Size = UDim2.fromOffset(178, 50)
launcher.Position = UDim2.new(0, 16, 0.5, -25)
launcher.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
launcher.BorderSizePixel = 0
launcher.AutoButtonColor = false
launcher.Font = Enum.Font.GothamBold
launcher.Text = "    " .. string.upper(MENU_NAME)
launcher.TextColor3 = Color3.fromRGB(255, 255, 255)
launcher.TextSize = 16
launcher.TextXAlignment = Enum.TextXAlignment.Left
launcher.Visible = false
launcher.Parent = launcherGui

local launcherCorner = Instance.new("UICorner")
launcherCorner.CornerRadius = UDim.new(0, 8)
launcherCorner.Parent = launcher

local launcherStroke = Instance.new("UIStroke")
launcherStroke.Thickness = 2
launcherStroke.Parent = launcher

local launcherIcon = Instance.new("TextLabel")
launcherIcon.BackgroundTransparency = 1
launcherIcon.Size = UDim2.fromOffset(38, 50)
launcherIcon.Position = UDim2.fromOffset(6, 0)
launcherIcon.Font = Enum.Font.GothamBold
launcherIcon.Text = "N"
launcherIcon.TextSize = 20
launcherIcon.Parent = launcher

local destroyed = false
local function setMenuVisible(visible)
    if destroyed then return end
    menuGui.Enabled = visible
    launcher.Visible = not visible
end

local main = menuGui:FindFirstChild("Main")
local header = main and main:FindFirstChild("MainHeader")
local originalClose = header and header:FindFirstChild("close")
if originalClose then
    originalClose.Visible = false
    originalClose.Active = false
end

if header then
    local minimize = Instance.new("TextButton")
    minimize.Name = "Minimize"
    minimize.Size = UDim2.fromOffset(28, 24)
    minimize.Position = UDim2.new(1, -34, 0, 2)
    minimize.BackgroundTransparency = 1
    minimize.AutoButtonColor = false
    minimize.Font = Enum.Font.GothamBold
    minimize.Text = "—"
    minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimize.TextSize = 20
    minimize.Parent = header
    minimize.MouseButton1Click:Connect(function()
        setMenuVisible(false)
    end)

    enableDrag(main, header)
end

local launcherLastDrag = 0
enableDrag(launcher, launcher, function(wasDragged)
    if wasDragged then
        launcherLastDrag = os.clock()
    end
end)

launcher.Activated:Connect(function()
    if os.clock() - launcherLastDrag < 0.25 then
        return
    end
    setMenuVisible(true)
end)

-- K minimiza quando o menu esta aberto e o reabre quando esta minimizado.
-- O atalho e ignorado enquanto voce escreve em uma caixa de texto.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if destroyed or gameProcessed or UserInputService:GetFocusedTextBox() then
        return
    end

    if input.KeyCode == Enum.KeyCode.K then
        setMenuVisible(not menuGui.Enabled)
    end
end)

local running = true
local function destroyNothrilo()
    if destroyed then return end
    destroyed = true
    running = false
    killerActive = false

    stopFly()
    espEnabled = false
    espSession = espSession + 1
    clearESP()
    stabilizer.enabled = false
    cleanupStabilizer()
    restorePanicStop()

    if toastGui and toastGui.Parent then toastGui:Destroy() end
    if launcherGui and launcherGui.Parent then launcherGui:Destroy() end
    if menuGui and menuGui.Parent then menuGui:Destroy() end
    if runtime and runtime.Parent then runtime:Destroy() end
end

runtimeCleanup.Event:Connect(destroyNothrilo)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if destroyed or gameProcessed or UserInputService:GetFocusedTextBox() then
        return
    end
    if input.KeyCode == Enum.KeyCode.X then
        destroyNothrilo()
    end
end)

local GuiTab = Window:NewTab("Interface")
local GuiSection = GuiTab:NewSection("Interface")
GuiSection:NewButton("Fechar Menu", "Fecha tudo do Nothrilo. A tecla X também funciona.", destroyNothrilo)

task.spawn(function()
    while running and not destroyed and menuGui.Parent and launcherGui.Parent do
        local rgb = Color3.fromHSV((os.clock() * 0.12) % 1, 0.85, 1)
        Library:ChangeColor("SchemeColor", rgb)
        launcherStroke.Color = rgb
        launcherIcon.TextColor3 = rgb
        for index = #toastStrokes, 1, -1 do
            local stroke = toastStrokes[index]
            if stroke and stroke.Parent then
                stroke.Color = rgb
            else
                table.remove(toastStrokes, index)
            end
        end
        -- Kavo ja atualiza muitos elementos internamente. Um intervalo maior
        -- preserva o RGB sem travar executores mais leves, como o Xeno.
        task.wait(0.30)
    end
end)

notify(MENU_NAME, "Feito por Cafezl  •  K minimiza e reabre o menu.")
