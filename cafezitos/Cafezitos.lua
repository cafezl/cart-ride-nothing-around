-- =============================================================================
-- Cafezitos V2 ☕ — Menu completo por Cafezl
-- Versão auditada: bugs corrigidos + novas funções + Key Gate + Auto Win
-- =============================================================================
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")

-- Token compartilhado entre execuções/skins.
local suiteGuard = { environment = _G }
if type(getgenv) == "function" then
	local ok, environment = pcall(getgenv)
	if ok and type(environment) == "table" then suiteGuard.environment = environment end
end
suiteGuard.generation = (tonumber(suiteGuard.environment.__CafezlSuiteGeneration) or 0) + 1
local storedGeneration = pcall(function()
	suiteGuard.environment.__CafezlSuiteGeneration = suiteGuard.generation
end)
if not storedGeneration then
	suiteGuard.environment = _G
	suiteGuard.generation = (tonumber(_G.__CafezlSuiteGeneration) or 0) + 1
	_G.__CafezlSuiteGeneration = suiteGuard.generation
end
local function isCurrentSuiteGeneration()
	return suiteGuard.environment.__CafezlSuiteGeneration == suiteGuard.generation
end

local LocalPlayer  = Players.LocalPlayer
do
	local deadline = os.clock() + 10
	while not LocalPlayer and os.clock() < deadline do
		if not isCurrentSuiteGeneration() then return end
		task.wait(0.05)
		LocalPlayer = Players.LocalPlayer
	end
	if not LocalPlayer then
		error("Cafezitos: jogador local indisponível após 10 segundos; execute no cliente do Roblox.")
	end
end

local MENU_NAME    = "Cafezitos V2 ☕"
local UI_TITLE     = MENU_NAME .. " | Feito por Cafezl"

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
	local ok, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if ok and coreGui then
		local ready = usable(coreGui)
		if ready then return ready end
	end
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
		or LocalPlayer:WaitForChild("PlayerGui", 10)
	local ready = usable(playerGui)
	if ready then return ready end
	error("Cafezitos: não foi possível encontrar um local permitido para a interface.")
end

local CoreGui      = getGuiParent()
if not isCurrentSuiteGeneration() then return end

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

local destroyCafezitos
local setMenuVisible
local destroyed = false
local runtimeConnections = {}
local function trackConnection(connection)
	if connection then table.insert(runtimeConnections, connection) end
	return connection
end
local function disconnectRuntimeConnections()
	for index = #runtimeConnections, 1, -1 do
		local connection = runtimeConnections[index]
		if connection then pcall(function() connection:Disconnect() end) end
		runtimeConnections[index] = nil
	end
end

for _, guiRoot in ipairs(guiRoots) do
	for _, runtimeName in ipairs({ "CafezitosRuntime", "NothriloRuntime" }) do
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

local originalGravity = workspace.Gravity
local runtime = Instance.new("Folder")
runtime.Name  = "CafezitosRuntime"
runtime.Parent = CoreGui
local runtimeCleanup = Instance.new("BindableEvent")
runtimeCleanup.Name   = "Cleanup"
runtimeCleanup.Parent = runtime
trackConnection(runtimeCleanup.Event:Connect(function()
	if destroyCafezitos then
		destroyCafezitos()
		return
	end
	destroyed = true
	disconnectRuntimeConnections()
	if runtime and runtime.Parent then runtime:Destroy() end
end))

local cafeGuiNames = {
	CafezitosV2UI = true,
	CafezitosLauncher = true,
	CafezitosNotifications = true,
	CafezitosLoading = true,
	CafezitosMobileFly = true,
	CafezitosKeyGate = true,
}
for _, guiRoot in ipairs(guiRoots) do
	for _, gui in ipairs(guiRoot:GetChildren()) do
		if gui:IsA("ScreenGui") then
			if cafeGuiNames[gui.Name] then
				gui:Destroy()
			else
				local main   = gui:FindFirstChild("Main")
				local header = main and main:FindFirstChild("MainHeader")
				local title  = header and header:FindFirstChild("title")
				if title and title.Text:find("Cafezitos", 1, true) then
					gui:Destroy()
				end
			end
		end
	end
end

local Theme = {
	SchemeColor  = Color3.fromRGB(239, 180, 112),
	Background   = Color3.fromRGB(66, 41, 33),
	Header       = Color3.fromRGB(108, 67, 49),
	TextColor    = Color3.fromRGB(255, 246, 232),
	ElementColor = Color3.fromRGB(121, 76, 56),
}

-- =============================================================================
-- KEY GATE (sistema de key gratuita do Nothrilo adaptado para Cafezitos)
-- =============================================================================
do
	local keyGateGui
	local function runFreeKeyGate()
		local apiOrigin = "https://nothrilo-key.urielcafe01.workers.dev"
		local serverConfigured = apiOrigin:match("^https://") ~= nil and not apiOrigin:find("__NOTHRILO_", 1, true)
		local cachePath = "Cafezitos/key-cache-v1.json"
		local cacheFolder = "Cafezitos"
		local cacheSlot = "__CafezitosFreeKeyCacheV1"
		local maxKeyTtl = 24 * 60 * 60

		local function environmentFunction(name)
			local ok, value = pcall(function()
				return suiteGuard.environment[name]
			end)
			if ok and type(value) == "function" then return value end
			ok, value = pcall(function() return _G[name] end)
			return ok and type(value) == "function" and value or nil
		end

		local function nestedEnvironmentFunction(name, member)
			local function lookup(environment)
				local ok, value = pcall(function()
					local container = environment[name]
					return type(container) == "table" and container[member] or nil
				end)
				return ok and type(value) == "function" and value or nil
			end
			return lookup(suiteGuard.environment) or lookup(_G)
		end

		local function getRequestFunction()
			return environmentFunction("request")
				or environmentFunction("http_request")
				or nestedEnvironmentFunction("syn", "request")
				or nestedEnvironmentFunction("fluxus", "request")
				or nestedEnvironmentFunction("http", "request")
		end

		local function postKeyServer(A)
			if not serverConfigured then
				return false, 0, nil, "server_not_configured"
			end
			local B, C = pcall(function() return HttpService:JSONEncode(A) end)
			if not B then return false, 0, nil, "invalid_request" end
			local D = {
				Url = apiOrigin .. "/v1/nothrilo/key/verify",
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json", ["Accept"] = "application/json" },
				Body = C,
			}
			local E = getRequestFunction()
			local F, G
			if E then F, G = pcall(E, D)
			else
				F, G = pcall(function() return HttpService:RequestAsync(D) end)
			end
			if not F then return false, 0, nil, "network_error" end
			local H = 0
			local I
			if type(G) == "table" then
				H = tonumber(G.StatusCode or G.Status or G.status_code) or 0
				I = G.Body or G.body
				if H == 0 and G.Success == true then H = 200 end
			elseif type(G) == "string" then
				H = 200
				I = G
			end
			if type(I) ~= "string" or I == "" then return false, H, nil, "invalid_response" end
			local J, K = pcall(function() return HttpService:JSONDecode(I) end)
			if not J or type(K) ~= "table" then return false, H, nil, "invalid_response" end
			return H >= 200 and H < 300, H, K, K.error
		end

		local function validLease(A)
			return type(A) == "string" and #A == 71 and A:match("^NLEASE%-%x+$") ~= nil
		end

		local function clearKeyCache()
			pcall(function() suiteGuard.environment[cacheSlot] = nil end)
			local A = environmentFunction("delfile")
			if A then pcall(A, cachePath) end
		end

		local function decodeCache(A)
			if type(A) == "table" then return A end
			if type(A) ~= "string" or A == "" then return nil end
			local B, C = pcall(function() return HttpService:JSONDecode(A) end)
			return B and type(C) == "table" and C or nil
		end

		local function validateCachedRecord(A)
			if type(A) ~= "table" then return nil end
			local B = os.time()
			local C = tonumber(A.savedAt)
			local D = tonumber(A.expiresAt)
			if A.version ~= 1
				or A.product ~= "nothrilo"
				or tostring(A.userId or "") ~= tostring(LocalPlayer.UserId)
				or not validLease(A.lease)
				or not C or not D
				or C > B + 300
				or D <= B + 5
				or D - C > maxKeyTtl + 60
			then
				return nil
			end
			return A
		end

		local function readKeyCache()
			local A = environmentFunction("isfile")
			local B = environmentFunction("readfile")
			if B then
				local C = true
				if A then
					local D, E = pcall(A, cachePath)
					C = D and E == true
				end
				if C then
					local D, E = pcall(B, cachePath)
					if D then
						local F = validateCachedRecord(decodeCache(E))
						if F then return F end
					end
				end
			end
			local C
			pcall(function() C = suiteGuard.environment[cacheSlot] end)
			return validateCachedRecord(decodeCache(C))
		end

		local function saveKeyCache(A, B)
			if not validLease(A) then return end
			local C = math.floor(math.clamp(tonumber(B) or 0, 1, maxKeyTtl))
			if C <= 5 then return end
			local D = os.time()
			local E = {
				version = 1,
				product = "nothrilo",
				userId = tostring(LocalPlayer.UserId),
				lease = A,
				savedAt = D,
				expiresAt = D + C,
			}
			pcall(function() suiteGuard.environment[cacheSlot] = E end)
			local F = environmentFunction("writefile")
			if not F then return end
			local G, H = pcall(function() return HttpService:JSONEncode(E) end)
			if not G then return end
			local I = environmentFunction("makefolder")
			if I then pcall(I, cacheFolder) end
			pcall(F, cachePath, H)
		end

		local A = false
		local B = false
		local C = {}
		local D = 0
		local E = {}

		local function gateAlive()
			return not destroyed and isCurrentSuiteGeneration() and keyGateGui and keyGateGui.Parent ~= nil and E ~= nil
		end

		local function connect(F, G)
			local H = F:Connect(G)
			table.insert(C, H)
			return H
		end

		local F = Instance.new("ScreenGui")
		F.Name = "CafezitosKeyGate"
		F.ResetOnSpawn = false
		F.IgnoreGuiInset = true
		F.DisplayOrder = 10100
		F.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		F.Parent = CoreGui
		keyGateGui = F

		local G = Instance.new("Frame")
		G.Name = "Shade"
		G.Size = UDim2.fromScale(1, 1)
		G.BackgroundColor3 = Color3.fromRGB(20, 10, 5)
		G.BackgroundTransparency = 0.06
		G.BorderSizePixel = 0
		G.Parent = F

		local H = Instance.new("Frame")
		H.Name = "Card"
		H.AnchorPoint = Vector2.new(0.5, 0.5)
		H.Position = UDim2.fromScale(0.5, 0.5)
		H.BackgroundColor3 = Color3.fromRGB(43, 26, 19)
		H.BorderSizePixel = 0
		H.ClipsDescendants = true
		H.Parent = G

		local I = Instance.new("UICorner")
		I.CornerRadius = UDim.new(0, 22)
		I.Parent = H

		local J = Instance.new("UIStroke")
		J.Thickness = 2
		J.Color = Theme.SchemeColor
		J.Parent = H

		local K = Instance.new("Frame")
		K.Name = "Header"
		K.Size = UDim2.new(1, 0, 0, 68)
		K.BackgroundColor3 = Color3.fromRGB(108, 67, 49)
		K.BorderSizePixel = 0
		K.Parent = H

		local L = Instance.new("Frame")
		L.AnchorPoint = Vector2.new(0, 0.5)
		L.Position = UDim2.new(0, 18, 0.5, 0)
		L.Size = UDim2.fromOffset(13, 13)
		L.BackgroundColor3 = Theme.SchemeColor
		L.BorderSizePixel = 0
		L.Parent = K
		Instance.new("UICorner", L).CornerRadius = UDim.new(1, 0)

		local M = Instance.new("TextLabel")
		M.Position = UDim2.new(0, 42, 0, 8)
		M.Size = UDim2.new(1, -96, 0, 27)
		M.BackgroundTransparency = 1
		M.Font = Enum.Font.GothamBold
		M.Text = "Cafezitos ☕ • Key grátis"
		M.TextColor3 = Theme.TextColor
		M.TextSize = 19
		M.TextXAlignment = Enum.TextXAlignment.Left
		M.Parent = K

		local N = Instance.new("TextLabel")
		N.Position = UDim2.new(0, 42, 0, 36)
		N.Size = UDim2.new(1, -96, 0, 20)
		N.BackgroundTransparency = 1
		N.Font = Enum.Font.Gotham
		N.Text = "Key gratuita • menu completo por até 24 horas"
		N.TextColor3 = Color3.fromRGB(255, 223, 188)
		N.TextSize = 13
		N.TextXAlignment = Enum.TextXAlignment.Left
		N.Parent = K

		local O = Instance.new("TextButton")
		O.Name = "Close"
		O.AnchorPoint = Vector2.new(1, 0.5)
		O.Position = UDim2.new(1, -10, 0.5, 0)
		O.Size = UDim2.fromOffset(46, 46)
		O.BackgroundColor3 = Color3.fromRGB(94, 48, 34)
		O.BorderSizePixel = 0
		O.AutoButtonColor = true
		O.Font = Enum.Font.GothamBold
		O.Text = "\u{d7}"
		O.TextColor3 = Theme.TextColor
		O.TextSize = 23
		O.Parent = K
		Instance.new("UICorner", O).CornerRadius = UDim.new(0, 13)

		local P = Instance.new("ScrollingFrame")
		P.Name = "Content"
		P.Position = UDim2.fromOffset(0, 68)
		P.Size = UDim2.new(1, 0, 1, -68)
		P.BackgroundTransparency = 1
		P.BorderSizePixel = 0
		P.ScrollBarThickness = 5
		P.ScrollBarImageColor3 = Theme.SchemeColor
		P.ScrollingDirection = Enum.ScrollingDirection.Y
		P.AutomaticCanvasSize = Enum.AutomaticSize.Y
		P.CanvasSize = UDim2.new()
		P.Parent = H

		local Q = Instance.new("UIPadding")
		Q.PaddingLeft = UDim.new(0, 18)
		Q.PaddingRight = UDim.new(0, 18)
		Q.PaddingTop = UDim.new(0, 14)
		Q.PaddingBottom = UDim.new(0, 16)
		Q.Parent = P

		local R = Instance.new("UIListLayout")
		R.FillDirection = Enum.FillDirection.Vertical
		R.HorizontalAlignment = Enum.HorizontalAlignment.Center
		R.SortOrder = Enum.SortOrder.LayoutOrder
		R.Padding = UDim.new(0, 10)
		R.Parent = P

		local function label(S, T, U, V, W)
			local X = Instance.new("TextLabel")
			X.Size = UDim2.new(1, 0, 0, T)
			X.BackgroundTransparency = 1
			X.Font = U or Enum.Font.Gotham
			X.Text = S
			X.TextColor3 = W or Theme.TextColor
			X.TextSize = V or 13
			X.TextWrapped = true
			X.TextXAlignment = Enum.TextXAlignment.Left
			X.TextYAlignment = Enum.TextYAlignment.Center
			X.Parent = P
			return X
		end

		local S = label(
			"Escolha uma opção, conclua as etapas no navegador e cole a key aqui. Work.ink, LootLabs e Linkvertise liberam exatamente as mesmas funções.",
			58, Enum.Font.GothamMedium, 15, Color3.fromRGB(255, 238, 220)
		)
		S.LayoutOrder = 1

		local T = label("ESCOLHA ONDE PEGAR A KEY", 22, Enum.Font.GothamBold, 13, Color3.fromRGB(255, 223, 188))
		T.LayoutOrder = 2

		local U = Instance.new("Frame")
		U.Size = UDim2.new(1, 0, 0, 54)
		U.BackgroundTransparency = 1
		U.LayoutOrder = 3
		U.Parent = P

		local V = Instance.new("UIListLayout")
		V.FillDirection = Enum.FillDirection.Horizontal
		V.HorizontalAlignment = Enum.HorizontalAlignment.Center
		V.VerticalAlignment = Enum.VerticalAlignment.Center
		V.Padding = UDim.new(0, 8)
		V.Parent = U

		local W = Instance.new("TextBox")
		W.Name = "KeyLink"
		W.Size = UDim2.new(1, 0, 0, 46)
		W.BackgroundColor3 = Color3.fromRGB(78, 46, 34)
		W.BorderSizePixel = 0
		W.ClearTextOnFocus = false
		W.Font = Enum.Font.Code
		W.PlaceholderText = "O link escolhido aparece aqui"
		W.PlaceholderColor3 = Color3.fromRGB(200, 160, 130)
		W.Text = ""
		W.TextColor3 = Color3.fromRGB(255, 240, 230)
		W.TextSize = 13
		W.TextTruncate = Enum.TextTruncate.AtEnd
		W.TextXAlignment = Enum.TextXAlignment.Left
		W.LayoutOrder = 4
		W.Parent = P
		Instance.new("UICorner", W).CornerRadius = UDim.new(0, 11)
		local X = Instance.new("UIPadding")
		X.PaddingLeft = UDim.new(0, 12)
		X.PaddingRight = UDim.new(0, 12)
		X.Parent = W
		local Y = Instance.new("UIStroke")
		Y.Color = Color3.fromRGB(140, 90, 60)
		Y.Thickness = 1
		Y.Parent = W

		local Z = Instance.new("TextBox")
		Z.Name = "KeyInput"
		Z.Size = UDim2.new(1, 0, 0, 52)
		Z.BackgroundColor3 = Color3.fromRGB(78, 46, 34)
		Z.BorderSizePixel = 0
		Z.ClearTextOnFocus = false
		Z.Font = Enum.Font.RobotoMono
		Z.PlaceholderText = "Cole sua key: NOTH-XXXX-XXXX-XXXX-XXXX-XXXX"
		Z.PlaceholderColor3 = Color3.fromRGB(200, 160, 130)
		Z.Text = ""
		Z.TextColor3 = Theme.TextColor
		Z.TextSize = 15
		Z.TextXAlignment = Enum.TextXAlignment.Left
		Z.LayoutOrder = 5
		Z.Parent = P
		Instance.new("UICorner", Z).CornerRadius = UDim.new(0, 12)
		local _ = Instance.new("UIPadding")
		_.PaddingLeft = UDim.new(0, 14)
		_.PaddingRight = UDim.new(0, 14)
		_.Parent = Z
		local aa = Instance.new("UIStroke")
		aa.Color = Color3.fromRGB(150, 100, 70)
		aa.Thickness = 1
		aa.Parent = Z

		local ab = Instance.new("TextButton")
		ab.Name = "Verify"
		ab.Size = UDim2.new(1, 0, 0, 52)
		ab.BackgroundColor3 = Theme.SchemeColor
		ab.BorderSizePixel = 0
		ab.AutoButtonColor = true
		ab.Font = Enum.Font.GothamBold
		ab.Text = "VALIDAR E ABRIR O CAFEZITOS"
		ab.TextColor3 = Color3.fromRGB(30, 15, 8)
		ab.TextSize = 14
		ab.LayoutOrder = 6
		ab.Parent = P
		Instance.new("UICorner", ab).CornerRadius = UDim.new(0, 13)

		local ac = Instance.new("Frame")
		ac.Size = UDim2.new(1, 0, 0, 62)
		ac.BackgroundColor3 = Color3.fromRGB(50, 30, 20)
		ac.BorderSizePixel = 0
		ac.LayoutOrder = 7
		ac.Parent = P
		Instance.new("UICorner", ac).CornerRadius = UDim.new(0, 12)
		local ad = Instance.new("Frame")
		ad.AnchorPoint = Vector2.new(0, 0.5)
		ad.Position = UDim2.new(0, 13, 0.5, 0)
		ad.Size = UDim2.fromOffset(10, 10)
		ad.BackgroundColor3 = Theme.SchemeColor
		ad.BorderSizePixel = 0
		ad.Parent = ac
		Instance.new("UICorner", ad).CornerRadius = UDim.new(1, 0)
		local ae = Instance.new("TextLabel")
		ae.Position = UDim2.new(0, 35, 0, 6)
		ae.Size = UDim2.new(1, -48, 1, -12)
		ae.BackgroundTransparency = 1
		ae.Font = Enum.Font.Gotham
		ae.Text = serverConfigured and "Escolha uma opção para gerar sua key grátis."
			or "O servidor de keys ainda não foi conectado nesta build."
		ae.TextColor3 = Color3.fromRGB(255, 235, 215)
		ae.TextSize = 14
		ae.TextWrapped = true
		ae.TextXAlignment = Enum.TextXAlignment.Left
		ae.TextYAlignment = Enum.TextYAlignment.Center
		ae.Parent = ac

		local af = label(
			"\u{1f510} Todas as funções são grátis após a key. Nenhuma senha é pedida.",
			42, Enum.Font.GothamMedium, 13, Color3.fromRGB(220, 190, 160)
		)
		af.LayoutOrder = 8

		local ag = {}
		local ah = {
			{ id = "workink", text = "Work.ink \u{1f7e2}" },
			{ id = "lootlabs", text = "LootLabs \u{1f48e}" },
			{ id = "linkvertise", text = "Linkvertise \u{1f517}" },
		}

		local function setStatus(ai, aj)
			ae.Text = ai
			if aj == "good" then ae.TextColor3 = Color3.fromRGB(116, 255, 158)
			elseif aj == "bad" then ae.TextColor3 = Color3.fromRGB(255, 116, 148)
			else ae.TextColor3 = Color3.fromRGB(255, 235, 215) end
		end

		local function copyText(ai)
			for aj, ak in ipairs({ "setclipboard", "toclipboard" }) do
				local al = environmentFunction(ak)
				if al then
					local am = pcall(al, ai)
					if am then return true end
				end
			end
			return false
		end

		for ai, aj in ipairs(ah) do
			local ak = Instance.new("TextButton")
			ak.Name = aj.id
			ak.Size = UDim2.new(1 / 3, -6, 1, 0)
			ak.BackgroundColor3 = Color3.fromRGB(80, 45, 30)
			ak.BorderSizePixel = 0
			ak.AutoButtonColor = true
			ak.Font = Enum.Font.GothamBold
			ak.Text = aj.text
			ak.TextColor3 = Theme.TextColor
			ak.TextSize = 14
			ak.Parent = U
			Instance.new("UICorner", ak).CornerRadius = UDim.new(0, 12)
			local al = Instance.new("UIStroke")
			al.Color = Theme.SchemeColor
			al.Transparency = 0.18
			al.Thickness = 1
			al.Parent = ak
			table.insert(ag, al)
			connect(ak.Activated, function()
				if not gateAlive() then return end
				if not serverConfigured then
					setStatus("O servidor ainda não foi publicado. Esta build é apenas de preparação.", "bad")
					return
				end
				local am = apiOrigin
					.. "/v1/nothrilo/key/start?provider="
					.. HttpService:UrlEncode(aj.id)
					.. "&userId="
					.. HttpService:UrlEncode(tostring(LocalPlayer.UserId))
				W.Text = am
				if copyText(am) then
					setStatus("Link do " .. aj.text .. " copiado. Cole no navegador, conclua e volte com a key.", "good")
				else
					setStatus("Copie o link do campo acima, abra no navegador, conclua e volte com a key.", nil)
					pcall(function()
						W:CaptureFocus()
						W.CursorPosition = #W.Text + 1
						W.SelectionStart = 1
					end)
				end
			end)
		end

		local function setBusy(ai)
			ab.Active = not ai
			ab.AutoButtonColor = not ai
			ab.Text = ai and "VERIFICANDO..." or "VALIDAR E ABRIR O CAFEZITOS"
			ab.BackgroundTransparency = ai and 0.35 or 0
			pcall(function() Z.TextEditable = not ai end)
		end

		local function friendlyError(ai, aj)
			if ai == "server_not_configured" then
				return "O servidor de keys ainda não foi conectado nesta build."
			end
			if ai == "network_error" then
				return "Não consegui falar com o servidor. Confira a internet e tente novamente."
			end
			if ai == "invalid_key" or ai == "invalid_lease" or aj == 401 or aj == 403 then
				return "Key inválida, expirada ou criada para outro usuário."
			end
			if aj == 429 then
				return "Muitas tentativas. Aguarde um pouco e tente novamente."
			end
			return "O servidor respondeu de um jeito inesperado. Tente novamente em instantes."
		end

		local function beginVerification(ai, aj, ak)
			if not gateAlive() then return end
			aj = tostring(aj or ""):match("^%s*(.-)%s*$")
			if ai == "key" then aj = aj:upper() end
			if (ai == "key" and not aj:match("^NOTH%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w%-%w%w%w%w$"))
				or (ai == "lease" and not validLease(aj)) then
				if ak then clearKeyCache()
				else setStatus("Cole uma key Nothrilo completa antes de validar.", "bad") end
				return
			end
			D += 1
			local al = D
			setBusy(true)
			setStatus(ak and "Verificando seu acesso salvo..." or "Validando sua key com segurança...", nil)
			task.delay(20, function()
				if gateAlive() and D == al and not A then
					D += 1
					setBusy(false)
					setStatus("A verificação demorou demais. Tente novamente.", "bad")
				end
			end)
			task.spawn(function()
				local am = tostring(os.clock())
				pcall(function() am = HttpService:GenerateGUID(false) end)
				local an = {
					product = "nothrilo",
					clientVersion = "free-key-v1",
					userId = tostring(LocalPlayer.UserId),
					placeId = tostring(game.PlaceId),
					nonce = am,
				}
				an[ai] = aj
				local ao, ap, aq, ar = postKeyServer(an)
				if not gateAlive() or D ~= al or A then return end
				if ao and type(aq) == "table" and aq.ok == true
					and validLease(aq.lease)
					and tonumber(aq.ttlSeconds) and tonumber(aq.ttlSeconds) > 5 then
					local as = math.floor(math.clamp(tonumber(aq.ttlSeconds), 1, maxKeyTtl))
					saveKeyCache(aq.lease, as)
					local at = os.clock() + as
					task.spawn(function()
						while not destroyed and isCurrentSuiteGeneration() do
							local au = at - os.clock()
							if au <= 0 then break end
							task.wait(math.max(0.25, math.min(30, au)))
						end
						if destroyed or not isCurrentSuiteGeneration() or os.clock() < at then return end
						clearKeyCache()
						if destroyCafezitos then destroyCafezitos()
						else
							destroyed = true
							if runtime and runtime.Parent then runtime:Destroy() end
						end
					end)
					setStatus("Acesso liberado! Abrindo o Cafezitos completo...", "good")
					task.wait(0.45)
					if gateAlive() and D == al then
						B = true
						A = true
					end
					return
				end
				if ak then clearKeyCache() end
				setBusy(false)
				setStatus(friendlyError(ar or (aq and aq.error), ap), "bad")
			end)
		end

		connect(ab.Activated, function() beginVerification("key", Z.Text, false) end)
		connect(Z.FocusLost, function(ai)
			if ai then beginVerification("key", Z.Text, false) end
		end)
		connect(O.Activated, function()
			D += 1
			A = true
			B = false
		end)

		local ai = Vector2.new()
		local function resizeGate()
			local aj = workspace.CurrentCamera
			local ak = aj and aj.ViewportSize or Vector2.new(800, 600)
			if ak == ai then return end
			ai = ak
			local al = math.max(284, math.min(600, ak.X - 16))
			local am = math.max(350, math.min(550, ak.Y - 16))
			H.Size = UDim2.fromOffset(al, am)
			local an = al < 390
			M.TextSize = an and 17 or 19
			N.TextSize = an and 12 or 13
			S.TextSize = an and 14 or 15
			T.TextSize = an and 12 or 13
			W.TextSize = an and 12 or 13
			Z.TextSize = an and 13 or 15
			ab.TextSize = an and 13 or 14
			ae.TextSize = an and 13 or 14
			af.TextSize = an and 12 or 13
			for ao, ap in ipairs(ag) do
				ap.Parent.TextSize = an and 12 or 14
			end
		end
		resizeGate()

		task.spawn(function()
			while gateAlive() and not A do
				resizeGate()
				local pulse = (math.sin(os.clock() * 1.2) + 1) * 0.5
				local rgb = Color3.fromRGB(
					math.floor(188 + 38 * pulse),
					math.floor(112 + 42 * pulse),
					math.floor(57 + 27 * pulse)
				)
				J.Color = rgb
				L.BackgroundColor3 = rgb
				ab.BackgroundColor3 = rgb
				P.ScrollBarImageColor3 = rgb
				ad.BackgroundColor3 = rgb
				for ak, al in ipairs(ag) do al.Color = rgb end
				task.wait(0.08)
			end
		end)

		local aj = readKeyCache()
		if aj then beginVerification("lease", aj.lease, true)
		elseif serverConfigured then
			setStatus("Escolha uma opção para gerar sua key grátis.", nil)
		end

		repeat task.wait(0.05) until A or not gateAlive()
		D += 1
		E = nil
		for ak = #C, 1, -1 do
			pcall(function() C[ak]:Disconnect() end)
			C[ak] = nil
		end
		if keyGateGui and keyGateGui.Parent then
			pcall(function() keyGateGui:Destroy() end)
		end
		keyGateGui = nil
		return B and not destroyed and isCurrentSuiteGeneration()
	end

	if not runFreeKeyGate() then
		destroyed = true
		disconnectRuntimeConnections()
		if runtime and runtime.Parent then runtime:Destroy() end
		return
	end
end

-- =============================================================================
-- Tela de carregamento
-- =============================================================================
local function showStartupCard()
	local gui  = Instance.new("ScreenGui")
	gui.Name            = "CafezitosLoading"
	gui.ResetOnSpawn    = false
	gui.IgnoreGuiInset  = true
	gui.DisplayOrder    = 10050
	gui.Parent          = CoreGui

	local card = Instance.new("Frame")
	card.Name            = "Card"
	card.AnchorPoint     = Vector2.new(0.5, 0.5)
	card.Position        = UDim2.fromScale(0.5, 0.5)
	card.Size            = UDim2.new(0.9, 0, 0, 150)
	card.BackgroundColor3 = Color3.fromRGB(43, 26, 19)
	card.BorderSizePixel = 0
	card.Parent          = gui
	local cardSize = Instance.new("UISizeConstraint")
	cardSize.MinSize = Vector2.new(270, 150)
	cardSize.MaxSize = Vector2.new(390, 150)
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
	cup.Text = "☕"
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
-- CAFÉ UI
-- =============================================================================
local CafeUI = {
	accent = Theme.SchemeColor,
	accentObjects = {},
	traceback = debug and debug.traceback or function(errorValue)
		return tostring(errorValue)
	end,
}

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

	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	local function getResponsiveSizes(currentViewport)
		local mobile = currentViewport.X < 700 or currentViewport.Y < 520
		local normal = mobile and UDim2.fromScale(0.94, 0.84) or UDim2.fromScale(0.64, 0.66)
		local mini = mobile and UDim2.fromScale(0.82, 0.62) or UDim2.fromScale(0.48, 0.48)
		return mobile, normal, mini
	end
	local mobileLayout, normalSize, miniSize = getResponsiveSizes(viewport)

	local main = ui("Frame", {
		Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), Size = normalSize,
		BackgroundColor3 = Theme.Background, BorderSizePixel = 0,
	}, gui)
	corner(main, 22)
	local mainStroke = stroke(main, Color3.fromRGB(120, 74, 46), 1.5, 0.1)
	CafeUI:trackAccent(mainStroke, "Color")
	local sizeConstraint = ui("UISizeConstraint", {
		MinSize = mobileLayout and Vector2.new(250, 270) or Vector2.new(420, 350),
		MaxSize = Vector2.new(780, 570),
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
		Text = "☕", TextSize = 31, TextColor3 = Theme.SchemeColor,
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
		Text = "Cappuccino doce • simples de usar", TextColor3 = Color3.fromRGB(255, 223, 188),
		TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
	}, header)

	local close = ui("TextButton", {
		Name = "close", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
		Size = UDim2.fromOffset(38, 38), BackgroundColor3 = Color3.fromRGB(94, 48, 34),
		BorderSizePixel = 0, Text = "×", Font = Enum.Font.GothamBold,
		TextColor3 = Theme.TextColor, TextSize = 25,
	}, header)
	corner(close, 12)
	close.Activated:Connect(function()
		if destroyCafezitos then destroyCafezitos() else gui:Destroy() end
	end)

	local compact = false
	local resize = ui("TextButton", {
		Name = "CoffeeResize", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -64, 0.5, 0),
		Size = UDim2.fromOffset(38, 38), BackgroundColor3 = Color3.fromRGB(255, 222, 181),
		BorderSizePixel = 0, Text = "↙", Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(89, 51, 37), TextSize = 20,
	}, header)
	corner(resize, 12)
	resize.Activated:Connect(function()
		compact = not compact
		resize.Text = compact and "↗" or "↙"
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

	local watermark = ui("TextLabel", {
		Name = "CoffeeWatermark", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.56),
		Size = UDim2.fromScale(0.9, 0.55), BackgroundTransparency = 1,
		Text = "☕  C A F E Z I T O S  ☕", Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.fromRGB(255, 226, 193), TextTransparency = 0.91,
		TextSize = mobileLayout and 32 or 48, ZIndex = 0,
	}, pages)

	local function updateResponsiveLayout()
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then return end
		mobileLayout, normalSize, miniSize = getResponsiveSizes(currentCamera.ViewportSize)
		sizeConstraint.MinSize = mobileLayout and Vector2.new(250, 270) or Vector2.new(420, 350)
		watermark.TextSize = mobileLayout and 30 or 48
		main.Size = compact and miniSize or normalSize
	end

	local viewportConnection
	local function bindViewportCamera()
		if viewportConnection then
			viewportConnection:Disconnect()
			viewportConnection = nil
		end
		camera = workspace.CurrentCamera
		if camera then
			viewportConnection = trackConnection(
				camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveLayout)
			)
			updateResponsiveLayout()
		end
	end
	bindViewportCamera()
	trackConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindViewportCamera))

	local window = { tabs = {}, activeTab = nil, gui = gui }
	local tabEmoji = {
		["Jogador"] = "🧑", ["Teleporte"] = "🗺️", ["Carrinho"] = "🚋",
		["Cart+"] = "⚡", ["Extras"] = "✨", ["Mapa"] = "🧭",
		["Eliminador"] = "🎯", ["Troll"] = "🎭", ["Comandos"] = "☕",
		["Interface"] = "🎨",
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
			Text = (tabEmoji[name] or "☕") .. " " .. name, Font = Enum.Font.GothamBold, TextColor3 = Theme.TextColor, TextSize = 13,
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

			local function labels(frame, label, description, rightInset)
				rightInset = rightInset or 0
				local textWidth = -(28 + rightInset)
				local title = ui("TextLabel", { Name = "togName", BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 8), Size = UDim2.new(1, textWidth, 0, 20), Text = label, Font = Enum.Font.GothamBold, TextColor3 = Theme.TextColor, TextSize = 15, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left }, frame)
				ui("TextLabel", { BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 30), Size = UDim2.new(1, textWidth, 0, 17), Text = description or "", Font = Enum.Font.Gotham, TextColor3 = Color3.fromRGB(255, 220, 185), TextSize = 12, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left }, frame)
				return title
			end

			function api:NewButton(label, description, callback)
				local frame = ui("TextButton", { Name = "buttonElement", Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
				corner(frame, 12); labels(frame, label, description, 108)
				local action = ui("TextLabel", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(37, 37), BackgroundColor3 = Theme.SchemeColor, BorderSizePixel = 0, Text = "›", Font = Enum.Font.GothamBold, TextColor3 = Theme.Background, TextSize = 26 }, frame)
				corner(action, 10); CafeUI:trackAccent(action, "BackgroundColor3")
				frame.Activated:Connect(function() if callback then callback() end end)
				return frame
			end

			function api:NewToggle(label, description, callback)
				local frame = ui("TextButton", { Name = "toggleElement", Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
				corner(frame, 12); labels(frame, label, description, 108)
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
				local frame = ui("TextButton", { Name = "textboxElement", Size = UDim2.new(1, 0, 0, 84), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
				corner(frame, 12); labels(frame, label, description, 0)
				local input = ui("TextBox", { Position = UDim2.new(0, 13, 1, -34), Size = UDim2.new(1, -26, 0, 27), BackgroundColor3 = Color3.fromRGB(78, 46, 34), BorderSizePixel = 0, PlaceholderText = "Digite aqui...", Text = "", ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextColor3 = Theme.TextColor, PlaceholderColor3 = Color3.fromRGB(239, 196, 158), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left }, frame)
				corner(input, 7); addPadding(input, 8)
				input.FocusLost:Connect(function(enter) if enter and callback then callback(input.Text) end end)
				return input
			end

			function api:NewSlider(label, description, maximum, minimum, defaultValue, callback)
				if type(defaultValue) == "function" then
					callback = defaultValue
					defaultValue = minimum
				end
				maximum = maximum or 100
				minimum = minimum or 0
				local frame = card(84, "sliderElement"); labels(frame, label, description, 72)
				local value = math.clamp(tonumber(defaultValue) or minimum, minimum, maximum)
				local valueLabel = ui("TextLabel", { Position = UDim2.new(1, -64, 0, 8), Size = UDim2.fromOffset(50, 20), BackgroundTransparency = 1, Text = tostring(value), Font = Enum.Font.GothamBold, TextColor3 = Theme.SchemeColor, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right }, frame); CafeUI:trackAccent(valueLabel, "TextColor3")
				local bar = ui("TextButton", { Position = UDim2.new(0, 13, 1, -23), Size = UDim2.new(1, -26, 0, 9), BackgroundColor3 = Color3.fromRGB(78, 46, 34), BorderSizePixel = 0, Text = "" }, frame); corner(bar, 5)
				local range = maximum - minimum
				local initialPercent = range ~= 0 and ((value - minimum) / range) or 0
				local fill = ui("Frame", { Size = UDim2.new(initialPercent, 0, 1, 0), BackgroundColor3 = Theme.SchemeColor, BorderSizePixel = 0 }, bar); corner(fill, 4); CafeUI:trackAccent(fill, "BackgroundColor3")
				local dragging = false
				local control = {}
				function control:SetValue(nextValue, invokeCallback)
					nextValue = math.clamp(tonumber(nextValue) or minimum, minimum, maximum)
					value = nextValue
					local percent = range ~= 0 and ((value - minimum) / range) or 0
					fill.Size = UDim2.new(percent, 0, 1, 0)
					valueLabel.Text = tostring(value)
					if invokeCallback ~= false and callback then callback(value) end
				end
				function control:GetValue() return value end
				local function setFrom(input)
					local percent = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
					control:SetValue(math.floor((minimum + range * percent) + 0.5), true)
				end
				bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; setFrom(input) end end)
				trackConnection(UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then setFrom(input) end end))
				trackConnection(UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end))
				return control
			end

			function api:NewKeybind(label, description, keyCode, callback)
				local frame = ui("TextButton", { Name = "keybindElement", Size = UDim2.new(1, 0, 0, 62), BackgroundColor3 = Theme.ElementColor, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, section)
				corner(frame, 12); labels(frame, label, description, 108)
				local key = ui("TextLabel", { Name = "key", Position = UDim2.new(1, -49, 0.5, -13), Size = UDim2.fromOffset(37, 26), BackgroundColor3 = Color3.fromRGB(35, 21, 16), BorderSizePixel = 0, Text = keyCode.Name, Font = Enum.Font.GothamBold, TextColor3 = Theme.SchemeColor, TextSize = 11 }, frame); corner(key, 8); CafeUI:trackAccent(key, "TextColor3")
				trackConnection(UserInputService.InputBegan:Connect(function(input, processed)
					if destroyed or processed or UserInputService:GetFocusedTextBox() then return end
					if input.KeyCode == keyCode and callback then callback() end
				end))
				return frame
			end

			return api
		end
		return tab
	end

	local startSize = mobileLayout and UDim2.fromScale(0.72, 0.56) or UDim2.fromScale(0.46, 0.46)
	main.Size = startSize; main.BackgroundTransparency = 0.2
	tween(main, 0.45, { Size = normalSize, BackgroundTransparency = 0 }):Play()
	return window
end

local startup = {}
startup.gui, startup.status = showStartupCard()
startup.finished = false
startup.fail = function(reason)
	if startup.finished or destroyed then return end
	warn(MENU_NAME .. " startup: " .. tostring(reason))
	if startup.status and startup.status.Parent then
		startup.status.Text = "Não foi possível abrir • veja o console"
	end
	task.delay(1.5, function()
		if startup.finished or destroyed then return end
		destroyed = true
		disconnectRuntimeConnections()
		for _, guiRoot in ipairs(guiRoots) do
			for _, gui in ipairs(guiRoot:GetChildren()) do
				if gui:IsA("ScreenGui") and (cafeGuiNames[gui.Name] or gui.Name == "CafezitosFallbackHost") then
					gui:Destroy()
				end
			end
		end
		if runtime and runtime.Parent then runtime:Destroy() end
	end)
end

task.delay(10, function()
	if not startup.finished and not destroyed and isCurrentSuiteGeneration() then
		startup.fail("tempo limite durante a montagem")
	end
end)

if startup.status then startup.status.Text = "Montando a interface..." end
task.wait()
if destroyed or not runtime.Parent or not isCurrentSuiteGeneration() then return end

local Window
do
	local createOk, windowOrError = xpcall(function()
		return CafeUI.CreateLib(UI_TITLE, Theme)
	end, CafeUI.traceback)
	if not createOk then
		startup.fail(windowOrError)
		return
	end
	Window = windowOrError
end

if Window.gui then Window.gui.Enabled = false end
if startup.status and startup.status.Parent then startup.status.Text = "Montando funções e atalhos..." end

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
	card.Name             = "CafezitosToast"
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
	icon.Text             = "☕"
	icon.TextColor3       = Color3.fromRGB(255, 255, 255)
	icon.TextSize         = 22
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
local cancelAutoWin

local function getCharacter(waitSeconds)
	local character = LocalPlayer.Character
	if character or not waitSeconds or waitSeconds <= 0 then return character end
	local deadline = os.clock() + waitSeconds
	repeat
		task.wait()
		character = LocalPlayer.Character
	until character or destroyed or not isCurrentSuiteGeneration() or os.clock() >= deadline
	return character
end

local function getHumanoid(character, waitSeconds)
	character = character or getCharacter(waitSeconds)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid or not character or not waitSeconds or waitSeconds <= 0 then return humanoid end
	local deadline = os.clock() + waitSeconds
	repeat
		task.wait()
		humanoid = character:FindFirstChildOfClass("Humanoid")
	until humanoid or not character.Parent or destroyed
		or not isCurrentSuiteGeneration() or os.clock() >= deadline
	return humanoid
end

local function getRoot(character, waitSeconds)
	character = character or getCharacter(waitSeconds)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root or not character or not waitSeconds or waitSeconds <= 0 then return root end
	root = character:WaitForChild("HumanoidRootPart", waitSeconds)
	return root and root:IsA("BasePart") and root or nil
end

-- CORRIGIDO: usa PivotTo com offset como no Nothrilo (mais robusto)
local function teleportCharacter(cframe, preserveAutoWin)
	if destroyed or not isCurrentSuiteGeneration() then return false end
	if not preserveAutoWin and cancelAutoWin then cancelAutoWin(true) end
	local character = getCharacter(2)
	local humanoid = getHumanoid(character, 2)
	local root = getRoot(character, 2)
	if destroyed or not isCurrentSuiteGeneration()
		or not character or character ~= LocalPlayer.Character or not character.Parent
	then return false end
	if not root or not root.Parent then
		notify("Teleporte", "HumanoidRootPart não encontrado.")
		return false
	end
	if humanoid and humanoid.SeatPart then
		humanoid.Sit = false
		pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
		local deadline = os.clock() + 0.6
		repeat RunService.Heartbeat:Wait()
		until not humanoid.Parent or humanoid.SeatPart == nil
			or destroyed or not isCurrentSuiteGeneration() or os.clock() >= deadline
		if destroyed or not isCurrentSuiteGeneration()
			or character ~= LocalPlayer.Character or not character.Parent
		then return false end
		root = getRoot(character, 1)
		if not root or not root.Parent or humanoid.SeatPart then
			notify("Teleporte", "Não foi possível sair do assento.")
			return false
		end
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

-- =============================================================================
-- ESP
-- =============================================================================
local ESP_TAG             = "CafezitosESP"
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
	if objects.Billboard and objects.Billboard.Parent then objects.Billboard:Destroy() end
	if objects.Highlight and objects.Highlight.Parent then objects.Highlight:Destroy() end
	local humanoid = objects.Humanoid
	local state = objects.DisplayState
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
	if not localRoot or not targetRoot or not targetRoot.Parent then
		objects.Billboard.Enabled = false
		return
	end
	local distance = (localRoot.Position - targetRoot.Position).Magnitude
	local scaleStartDistance = 150
	objects.Billboard.Enabled = true
	if objects.Label and objects.Label.Parent then
		local displayName = player.DisplayName ~= "" and player.DisplayName or player.Name
		objects.Label.Text = string.format("%s  •  %d studs", displayName, math.floor(distance + 0.5))
	end
	local progress = math.clamp((distance - scaleStartDistance) / 450, 0, 1)
	objects.Billboard.Size = UDim2.fromOffset(
		math.floor(118 + (220 - 118) * progress),
		math.floor(18  + (36  - 18)  * progress)
	)
end

local function addESP(player, character)
	if not espEnabled or player == LocalPlayer then return end
	character = character or player.Character
	if not character or not character.Parent then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end
	removeESP(player)
	local displayState = {
		DisplayDistanceType = humanoid.DisplayDistanceType,
		NameOcclusion = humanoid.NameOcclusion,
		NameDisplayDistance = humanoid.NameDisplayDistance,
		HealthDisplayDistance = humanoid.HealthDisplayDistance,
	}
	pcall(function()
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion
		humanoid.NameDisplayDistance = 0
		humanoid.HealthDisplayDistance = 0
	end)
	local billboard = Instance.new("BillboardGui")
	billboard.Name          = ESP_TAG .. "Name"
	billboard.Size          = UDim2.fromOffset(118, 18)
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
	espObjects[player] = {
		Billboard = billboard, Label = label, Highlight = highlight,
		Humanoid = humanoid, DisplayState = displayState,
	}
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
	local watchSession = espSession
	espPlayerConnections[player] = connections
	table.insert(connections, player.CharacterAdded:Connect(function(character)
		character:WaitForChild("HumanoidRootPart", 5)
		local deadline = os.clock() + 5
		while character.Parent and not character:FindFirstChildOfClass("Humanoid")
			and os.clock() < deadline do task.wait() end
		if destroyed or not espEnabled or watchSession ~= espSession then return end
		addESP(player, character)
	end))
	table.insert(connections, player.CharacterRemoving:Connect(function()
		removeESP(player)
	end))
	table.insert(connections, player:GetPropertyChangedSignal("Team"):Connect(function()
		refreshESPColor(player)
	end))
	table.insert(connections, player:GetPropertyChangedSignal("DisplayName"):Connect(function()
		refreshESPSize(player)
	end))
	addESP(player, player.Character)
end

local function clearESP()
	for _, c in ipairs(espGlobalConnections) do c:Disconnect() end
	table.clear(espGlobalConnections)
	local connectedPlayers = {}
	for player in pairs(espPlayerConnections) do table.insert(connectedPlayers, player) end
	for _, player in ipairs(connectedPlayers) do disconnectESPPlayer(player) end
	local renderedPlayers = {}
	for player in pairs(espObjects) do table.insert(renderedPlayers, player) end
	for _, player in ipairs(renderedPlayers) do removeESP(player) end
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
			task.wait(0.25)
		end
	end)
	notify("ESP", "Ligado: nomes e contornos ativos.")
end

-- Estados
local flyEnabled = false
local flyToggleControl
local boostToggleControl
local panicToggleControl
local stopBoost
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
local cartFeatureTiming = { antiFlipReadyAt = 0, autobrakeHoldUntil = 0, autobrakeReadyAt = 0 }

local activeCameraMode
local cameraModeStoppers = {}
local cameraBaseline

local function captureCameraBaseline()
	local camera = workspace.CurrentCamera
	if not camera then return end
	cameraBaseline = {
		camera = camera,
		cameraType = camera.CameraType,
		cameraSubject = camera.CameraSubject,
		cframe = camera.CFrame,
		focus = camera.Focus,
		fieldOfView = camera.FieldOfView,
	}
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
			else
				local humanoid = getHumanoid()
				if humanoid then camera.CameraSubject = humanoid end
			end
		end)
	end
	if not restored then
		pcall(function()
			camera.CameraType = Enum.CameraType.Custom
			local humanoid = getHumanoid()
			if humanoid then camera.CameraSubject = humanoid end
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
-- Voo (Vehicle Fly)
-- =============================================================================
local FLYING         = false
local vehicleFlySpeed = 1
local flyKeyDown
local flyKeyUp
local flyHumanoid
local flyAutoRotate
local flyPlatformStand
local flySavedState = {
	freefall = nil, fallingDown = nil, inputEnabled = true,
	humanoidModified = false, startedSeated = false,
}
local flyRoot
local flyBodyGyro
local flyBodyVelocity
local flySession    = 0
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
	gui.Name           = "CafezitosMobileFly"
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
	if flyBodyGyro and flyBodyGyro.Parent then flyBodyGyro:Destroy() end
	if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy() end
	local function removeNamedMovers(root)
		if root and root.Parent then
			local gyro = root:FindFirstChild("CafezitosVehicleFlyGyro")
			local velocity = root:FindFirstChild("CafezitosVehicleFlyVelocity")
			if gyro then gyro:Destroy() end
			if velocity then velocity:Destroy() end
		end
	end
	removeNamedMovers(flyRoot)
	local currentRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if currentRoot ~= flyRoot then removeNamedMovers(currentRoot) end
	local humanoid = flyHumanoid or getHumanoid()
	if humanoid and humanoid.Parent and flySavedState.humanoidModified then
		if flyPlatformStand ~= nil then humanoid.PlatformStand = flyPlatformStand end
		if flyAutoRotate ~= nil then humanoid.AutoRotate = flyAutoRotate end
		pcall(function()
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall,
				flySavedState.freefall == nil and true or flySavedState.freefall)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown,
				flySavedState.fallingDown == nil and true or flySavedState.fallingDown)
		end)
	end
	flyHumanoid     = nil
	flyAutoRotate   = nil
	flyPlatformStand = nil
	flyRoot = nil
	flyBodyGyro = nil
	flyBodyVelocity = nil
	flySavedState.freefall = nil
	flySavedState.fallingDown = nil
	flySavedState.inputEnabled = true
	flySavedState.humanoidModified = false
	flySavedState.startedSeated = false
	releaseCameraMode("fly")
end

local function startVehicleFly(inputEnabled)
	stopFly()
	local session   = flySession
	local character = getCharacter(3)
	local root      = getRoot(character, 3)
	local humanoid  = getHumanoid(character, 3)
	if destroyed or not isCurrentSuiteGeneration() or session ~= flySession
		or not character or character ~= LocalPlayer.Character or not character.Parent
	then return false end
	if not root or not root.Parent or not humanoid or not humanoid.Parent then
		notify("Voo do Veículo", "Personagem não encontrado.")
		return false
	end
	claimCameraMode("fly")
	pcall(function()
		local camera = workspace.CurrentCamera
		if camera then camera.CameraType = Enum.CameraType.Track end
	end)
	flyHumanoid      = humanoid
	flyAutoRotate    = humanoid.AutoRotate
	flyPlatformStand = humanoid.PlatformStand
	flySavedState.inputEnabled = inputEnabled ~= false
	flySavedState.startedSeated = humanoid.SeatPart ~= nil
	pcall(function()
		flySavedState.freefall = humanoid:GetStateEnabled(Enum.HumanoidStateType.Freefall)
		flySavedState.fallingDown = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
	end)
	flySavedState.humanoidModified = false
	local control     = { F=0, B=0, L=0, R=0, Q=0, E=0 }
	FLYING = true
	showMobileFlyControls(flySavedState.inputEnabled)
	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.Name      = "CafezitosVehicleFlyGyro"
	bodyGyro.P         = 90000
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame    = root.CFrame
	bodyGyro.Parent    = root
	flyRoot            = root
	flyBodyGyro        = bodyGyro
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name     = "CafezitosVehicleFlyVelocity"
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent   = root
	flyBodyVelocity       = bodyVelocity
	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if not flySavedState.inputEnabled or processed or UserInputService:GetFocusedTextBox() then return end
		local key = input.KeyCode
		if     key == Enum.KeyCode.W then control.F =  vehicleFlySpeed
		elseif key == Enum.KeyCode.S then control.B = -vehicleFlySpeed
		elseif key == Enum.KeyCode.A then control.L = -vehicleFlySpeed
		elseif key == Enum.KeyCode.D then control.R =  vehicleFlySpeed
		elseif key == Enum.KeyCode.E then control.Q =  vehicleFlySpeed * 2
		elseif key == Enum.KeyCode.Q then control.E = -vehicleFlySpeed * 2
		end
	end)
	flyKeyUp = UserInputService.InputEnded:Connect(function(input)
		local key = input.KeyCode
		if     key == Enum.KeyCode.W then control.F = 0
		elseif key == Enum.KeyCode.S then control.B = 0
		elseif key == Enum.KeyCode.A then control.L = 0
		elseif key == Enum.KeyCode.D then control.R = 0
		elseif key == Enum.KeyCode.E then control.Q = 0
		elseif key == Enum.KeyCode.Q then control.E = 0
		end
	end)
	task.spawn(function()
		local boundCamera
		while FLYING and session == flySession and root.Parent and humanoid.Parent
			and bodyGyro.Parent and bodyVelocity.Parent
		do
			task.wait()
			if flySavedState.startedSeated and humanoid.SeatPart == nil then break end
			local camera = workspace.CurrentCamera
			if not camera then break end
			if camera ~= boundCamera then
				boundCamera = camera
				pcall(function() camera.CameraType = Enum.CameraType.Track end)
			end
			if flySavedState.inputEnabled and UserInputService.KeyboardEnabled then
				control.F = UserInputService:IsKeyDown(Enum.KeyCode.W) and  vehicleFlySpeed or 0
				control.B = UserInputService:IsKeyDown(Enum.KeyCode.S) and -vehicleFlySpeed or 0
				control.L = UserInputService:IsKeyDown(Enum.KeyCode.A) and -vehicleFlySpeed or 0
				control.R = UserInputService:IsKeyDown(Enum.KeyCode.D) and  vehicleFlySpeed or 0
				control.Q = UserInputService:IsKeyDown(Enum.KeyCode.E) and  vehicleFlySpeed * 2 or 0
				control.E = UserInputService:IsKeyDown(Enum.KeyCode.Q) and -vehicleFlySpeed * 2 or 0
			end
			local keyboardMoving = flySavedState.inputEnabled and ((control.L + control.R ~= 0)
				or (control.F + control.B ~= 0)
				or (control.Q + control.E ~= 0))
			local mobileDir = humanoid.MoveDirection
			if UserInputService.TouchEnabled
				and Vector3.new(mobileDir.X, 0, mobileDir.Z).Magnitude <= 0.05 then
				local seat = humanoid.SeatPart
				if seat and seat:IsA("VehicleSeat") then
					local flatLook = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
					local flatRight = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
					if flatLook.Magnitude > 0.01 then flatLook = flatLook.Unit end
					if flatRight.Magnitude > 0.01 then flatRight = flatRight.Unit end
					mobileDir = flatLook * seat.ThrottleFloat + flatRight * seat.SteerFloat
				end
			end
			local mobileMoving  = flySavedState.inputEnabled and UserInputService.TouchEnabled and (
				Vector3.new(mobileDir.X, 0, mobileDir.Z).Magnitude > 0.05
				or flyTouchUp ~= 0 or flyTouchDown ~= 0
			)
			if keyboardMoving then
				local cameraCFrame = camera.CFrame
				local direction = cameraCFrame.LookVector * (control.F + control.B)
					+ ((cameraCFrame * CFrame.new(
						control.L + control.R,
						(control.F + control.B + control.Q + control.E) * 0.2,
						0
					)).Position - cameraCFrame.Position)
				bodyVelocity.Velocity = direction * 50
			elseif mobileMoving then
				bodyVelocity.Velocity =
					Vector3.new(mobileDir.X, 0, mobileDir.Z) * (vehicleFlySpeed * 50)
					+ Vector3.new(0, (flyTouchUp - flyTouchDown) * vehicleFlySpeed * 50, 0)
			else
				bodyVelocity.Velocity = Vector3.zero
			end
			bodyGyro.CFrame = camera.CFrame
		end
		if bodyGyro.Parent    then bodyGyro:Destroy()    end
		if bodyVelocity.Parent then bodyVelocity:Destroy() end
		if flyBodyGyro == bodyGyro then flyBodyGyro = nil end
		if flyBodyVelocity == bodyVelocity then flyBodyVelocity = nil end
		if flyRoot == root then flyRoot = nil end
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
					and (not assemblyRoot or object.AssemblyRootPart == assemblyRoot) then
					assemblyParts = assemblyParts + 1
					if assemblyParts >= 2 then return current end
				end
			end
		end
		current = current.Parent
	end
	return fallback
end

local cartCache = {
	humanoid = nil, seat = nil, cart = nil, assemblyRoot = nil, primary = nil,
}

local function clearCurrentCartCache()
	cartCache.humanoid = nil
	cartCache.seat = nil
	cartCache.cart = nil
	cartCache.assemblyRoot = nil
	cartCache.primary = nil
end

local function cacheCurrentCart(humanoid, seat)
	clearCurrentCartCache()
	if not humanoid or not seat or not seat:IsA("BasePart") or not seat.Parent then return nil end
	cartCache.humanoid = humanoid
	cartCache.seat = seat
	cartCache.assemblyRoot = seat.AssemblyRootPart
	cartCache.cart = findCartFromSeat(seat)
	cartCache.primary = (cartCache.cart and cartCache.cart.PrimaryPart) or cartCache.assemblyRoot
	return cartCache.cart
end

local function getCurrentCart()
	local humanoid = getHumanoid()
	local seat = humanoid and humanoid.SeatPart
	if not humanoid or not seat or not seat.Parent then
		clearCurrentCartCache()
		return nil
	end
	if cartCache.humanoid == humanoid
		and cartCache.seat == seat
		and cartCache.cart
		and cartCache.cart.Parent
		and cartCache.cart:IsAncestorOf(seat)
		and (not cartCache.assemblyRoot or cartCache.assemblyRoot.Parent)
		and cartCache.assemblyRoot == seat.AssemblyRootPart
	then
		return cartCache.cart
	end
	return cacheCurrentCart(humanoid, seat)
end

local function getCartPrimary(cart)
	if not cart then return nil end
	if cart.PrimaryPart then
		if cartCache.cart == cart then cartCache.primary = cart.PrimaryPart end
		return cart.PrimaryPart
	end
	if cartCache.cart == cart and cartCache.primary and cartCache.primary.Parent then
		return cartCache.primary
	end
	local humanoid = getHumanoid()
	local seat = humanoid and humanoid.SeatPart
	if seat and cart:IsAncestorOf(seat) and seat.AssemblyRootPart then
		if cartCache.cart == cart then cartCache.primary = seat.AssemblyRootPart end
		return seat.AssemblyRootPart
	end
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
	if cancelAutoWin then cancelAutoWin(true) end
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
	if not cart or not reference or not reference.Parent then return false end
	return pcall(function()
		local referenceOffset = cart:GetPivot():ToObjectSpace(reference.CFrame)
		local function stopPart(part)
			if not part.Anchored then
				pcall(function()
					part.AssemblyLinearVelocity = Vector3.zero
					part.AssemblyAngularVelocity = Vector3.zero
				end)
			end
		end
		for _, part in ipairs(cart:GetDescendants()) do
			if part:IsA("BasePart") then stopPart(part) end
		end
		cart:PivotTo(desiredReferenceCFrame * referenceOffset:Inverse())
		for _, part in ipairs(cart:GetDescendants()) do
			if part:IsA("BasePart") then stopPart(part) end
		end
	end)
end

local function stopCartControllersForTeleport(preserveAutoWin)
	if not preserveAutoWin and cancelAutoWin then cancelAutoWin(true) end
	cartMotionPauseUntil = os.clock() + 0.3
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
local stabilizer = { enabled = false, cart = nil, forces = {}, attachments = {}, heartbeat = nil }

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

-- CORRIGIDO: força dividida pelo número de rodas (como no Nothrilo)
local function applyStabilizer(cart)
	cleanupStabilizer()
	if not cart or not cart.Parent then return end
	local wheels = getWheels(cart)
	if #wheels == 0 then notify("Estabilizador", "Nenhuma roda encontrada.") return end
	stabilizer.cart = cart
	for _, part in ipairs(wheels) do
		for _, child in ipairs(part:GetChildren()) do
			if child:IsA("VectorForce") and child.Name == "CafezitosStabilizerForce" then
				child:Destroy()
			end
		end
		local att = part:FindFirstChild("_CafezitosStabilizer")
		if not att then
			att        = Instance.new("Attachment")
			att.Name   = "_CafezitosStabilizer"
			att.Parent = part
		end
		table.insert(stabilizer.attachments, att)
		local force = Instance.new("VectorForce")
		force.Name       = "CafezitosStabilizerForce"
		force.Attachment0 = att
		force.RelativeTo = Enum.ActuatorRelativeTo.World
		force.Force      = Vector3.zero
		force.Parent     = part
		table.insert(stabilizer.forces, force)
	end
	local reference = getCartPrimary(cart) or wheels[1]
	stabilizer.heartbeat = RunService.Heartbeat:Connect(function()
		if not reference or not reference.Parent then cleanupStabilizer() return end
		local mag = 0
		if stabilizer.enabled and not FLYING and not panicActive
			and os.clock() >= cartMotionPauseUntil
			and os.clock() >= cartFeatureTiming.autobrakeHoldUntil
		then
			mag = math.abs(reference.AssemblyLinearVelocity.Y) > 5
				and STABILIZER_CONFIG.DOWNHILL_FORCE
				or  STABILIZER_CONFIG.NORMAL_FORCE
		end
		local forceCount = math.max(#stabilizer.forces, 1)
		for _, force in ipairs(stabilizer.forces) do
			if force and force.Parent and force.Attachment0 and force.Attachment0.Parent then
				force.Force = Vector3.new(
					0,
					-(mag * force.Parent.AssemblyMass) / forceCount,
					0
				)
			elseif force and force.Parent then
				force:Destroy()
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
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid and character and character.Parent then
		humanoid = character:WaitForChild("Humanoid", 5)
	end
	if destroyed or not isCurrentSuiteGeneration()
		or not character or character ~= LocalPlayer.Character or not character.Parent
		or not humanoid or not humanoid:IsA("Humanoid") or not humanoid.Parent
	then return end
	if seatConnection then
		seatConnection:Disconnect()
		seatConnection = nil
	end
	local initialSeat = humanoid.SeatPart
	if initialSeat then
		local initialCart = cacheCurrentCart(humanoid, initialSeat)
		if stabilizer.enabled then applyStabilizer(initialCart) end
	else
		clearCurrentCartCache()
	end
	seatConnection = trackConnection(humanoid.Seated:Connect(function(isSeated, seat)
		if destroyed or not isCurrentSuiteGeneration()
			or character ~= LocalPlayer.Character or humanoid.Parent ~= character
		then return end
		if not isSeated then
			clearCurrentCartCache()
			cleanupStabilizer()
			restorePanicStop()
			if FLYING and flySavedState.startedSeated then
				if flyEnabled and flyToggleControl then
					task.defer(function() flyToggleControl:UpdateToggle(nil, false) end)
				else
					stopFly()
				end
			end
			if stopBoost then stopBoost() end
			if boostToggleControl then
				task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
			end
			if panicToggleControl then
				task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
			end
		else
			local cart = cacheCurrentCart(humanoid, seat)
			if stabilizer.enabled then applyStabilizer(cart) end
		end
	end))
end

local function teleportPlayerOrCart(cframe)
	local cart = getCurrentCart()
	if cart then
		stopCartControllersForTeleport()
		return pivotCartByReference(cart, cframe)
	end
	return teleportCharacter(cframe)
end

do
	local initialCharacter = LocalPlayer.Character
	if initialCharacter then
		task.defer(function()
			if not destroyed and isCurrentSuiteGeneration() then
				watchSeat(initialCharacter)
			end
		end)
	end
end

trackConnection(LocalPlayer.CharacterAdded:Connect(function(character)
	if destroyed or not isCurrentSuiteGeneration() then return end
	if cancelAutoWin then cancelAutoWin(true) end
	clearCurrentCartCache()
	cleanupStabilizer()
	restorePanicStop()
	if panicToggleControl then
		task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
	end
	fakeLagSession = fakeLagSession + 1
	fakeLagActive = false
	fakeLagHumanoid = nil
	if stopBoost then stopBoost() end
	if boostToggleControl then
		task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
	end
	if flyEnabled and flyToggleControl then
		flyToggleControl:UpdateToggle(nil, false)
	else
		stopFly()
	end
	task.defer(resetCameraModes)
	task.defer(watchSeat, character)
	task.delay(0.25, function()
		if destroyed or not isCurrentSuiteGeneration()
			or character ~= LocalPlayer.Character or not character.Parent
		then return end
		local humanoid = getHumanoid(character)
		if not humanoid then return end
		if not activeCameraMode then restoreDefaultCamera() end
		if fakeLagActive then return end
		if desiredWalkSpeed then humanoid.WalkSpeed = desiredWalkSpeed end
		if humanoid.UseJumpPower and desiredJumpPower then
			humanoid.JumpPower = desiredJumpPower
		elseif not humanoid.UseJumpPower and desiredJumpHeight then
			humanoid.JumpHeight = desiredJumpHeight
		end
	end)
end))

trackConnection(LocalPlayer.CharacterRemoving:Connect(function()
	killerSession = killerSession + 1
	killerActive = false
	clearCurrentCartCache()
	cleanupStabilizer()
	restorePanicStop()
	if stopBoost then stopBoost() end
	if flyEnabled and flyToggleControl then
		flyToggleControl:UpdateToggle(nil, false)
	else
		stopFly()
	end
	if boostToggleControl then
		task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
	end
	if panicToggleControl then
		task.defer(function() panicToggleControl:UpdateToggle(nil, false) end)
	end
	resetCameraModes()
end))

-- =============================================================================
-- Eliminador (Killer)
-- =============================================================================
local function findNearestFreeVehicleSeat()
	local root = getRoot(nil, 5)
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

local function sitOnVehicleSeat(seat, session)
	local root     = getRoot(nil, 5)
	local humanoid = getHumanoid(nil, 5)
	if destroyed or not isCurrentSuiteGeneration()
		or (session and (session ~= killerSession or not killerActive))
		or not seat or not root or not humanoid or seat.Occupant
	then return false end
	if humanoid.SeatPart and humanoid.SeatPart ~= seat then
		humanoid.Sit = false
		pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
		local deadline = os.clock() + 0.5
		repeat RunService.Heartbeat:Wait()
		until not humanoid.Parent or not humanoid.SeatPart or destroyed
			or (session and session ~= killerSession) or os.clock() >= deadline
		if destroyed or not isCurrentSuiteGeneration() or not humanoid.Parent
			or (session and (session ~= killerSession or not killerActive))
		then return false end
	end
	for _ = 1, 3 do
		if destroyed or not isCurrentSuiteGeneration()
			or (session and (session ~= killerSession or not killerActive))
			or not seat.Parent or seat.Occupant
		then break end
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
	local root    = getRoot()
	local humanoid = getHumanoid()
	local started = os.clock()
	while os.clock() - started < duration do
		if destroyed or not killerActive or session ~= killerSession then return false end
		if not root or not root.Parent or not humanoid or not humanoid.Parent
			or not targetRoot or not targetRoot.Parent
			or not seat or not seat.Parent or seat.Occupant ~= humanoid
			or humanoid.SeatPart ~= seat or getCurrentCart() ~= cart
		then return false end
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
	if humanoid then
		humanoid.Sit = false
		pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
	end
	if wasSeated then
		task.wait(0.05)
		if killerSession ~= cleanupSession then return end
	end
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
	if cancelAutoWin then cancelAutoWin(true) end
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
	if session == killerSession then
		finishKiller(reached and "Carrinho levado ao alvo." or "Tentativa cancelada.", session)
	end
end

trackConnection(LocalPlayer.CharacterAdded:Connect(function()
	killerSession = killerSession + 1
	killerActive = false
end))

-- =============================================================================
-- Variáveis adiantadas
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
local walkSpeedSlider = PlayerSection:NewSlider("Velocidade", "Velocidade de caminhada (padrão 16).", 500, 0, 16, function(value)
	desiredWalkSpeed = value
	local h = getHumanoid()
	if h and not fakeLagActive then h.WalkSpeed = value end
end)
PlayerSection:NewButton("Redefinir Velocidade", "Volta para 16.", function()
	desiredWalkSpeed = 16
	local h = getHumanoid()
	if h and not fakeLagActive then h.WalkSpeed = 16 end
	walkSpeedSlider:SetValue(16, false)
	notify("Velocidade", "Redefinida para 16.")
end)

infiniteJumpToggleControl = PlayerSection:NewToggle(
	"Pulo Infinito", "Pula no ar. Tecla P.", function(state)
		infiniteJump = state
		notify("Pulo Infinito", state and "Ligado." or "Desligado.")
	end
)

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

-- God Mode local
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
PlayerSection:NewToggle("God Mode (local)", "Impede que sua vida caia abaixo de 1 localmente.", setGodMode)

-- Anti-AFK
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
-- ABA: Teleporte (com Vitória Automática do Nothrilo)
-- =============================================================================
do
	local autoWinSession = 0
	local autoWinActive = false
	local autoWinAnchoredRoot
	local autoWinOriginalAnchored

	local function restoreAutoWinAnchor()
		if autoWinAnchoredRoot and autoWinAnchoredRoot.Parent then
			autoWinAnchoredRoot.Anchored = autoWinOriginalAnchored == true
		end
		autoWinAnchoredRoot = nil
		autoWinOriginalAnchored = nil
	end

	cancelAutoWin = function(silent)
		local wasActive = autoWinActive
		autoWinSession = autoWinSession + 1
		autoWinActive = false
		restoreAutoWinAnchor()
		if wasActive and not silent then notify("Vitória Automática", "Rota cancelada.") end
	end

	local function autoWinAlive(session)
		return autoWinActive and session == autoWinSession
			and not destroyed and isCurrentSuiteGeneration()
	end

	local function waitAutoWin(seconds, session)
		local deadline = os.clock() + seconds
		while autoWinAlive(session) and os.clock() < deadline do
			task.wait(math.min(0.1, math.max(0, deadline - os.clock())))
		end
		return autoWinAlive(session)
	end

	local autoWinRoute = {
		{ action = "teleport", delay = 4.1, cframe = CFrame.new(
			-430.898926, 165.25, 101.645676,
			1, 1.51719295e-08, -1.24212969e-14,
			-1.51719295e-08, 1, -1.14675147e-09,
			1.24038988e-14, 1.14675147e-09, 1
		) },
		{ action = "move", delay = 10, cframe = CFrame.new(
			-430.898529, 163.273926, 131.145554,
			1, -2.85942061e-08, 2.0407586e-07,
			2.85942079e-08, 1, -1.07927356e-08,
			-2.0407586e-07, 1.07927409e-08, 1
		) },
		{ action = "sit", value = true, delay = 33 },
		{ action = "sit", value = false, delay = 2 },
		{ action = "move", delay = 0.1, cframe = CFrame.new(
			-500.748535, -21.78265, -302.303406, 0, 0, 1, 0, -1, 0, 1, 0, 0
		) },
		{ action = "anchor", delay = 1.3 },
		{ action = "restoreAnchor", delay = 0.6 },
		{ action = "move", delay = 10, cframe = CFrame.new(
			-470.360138, -21.1945782, -302.303101, 0, 0, 1, 0, -1, 0, 1, 0, 0
		) },
		{ action = "sit", value = true, delay = 35 },
		{ action = "sit", value = false, delay = 0.5 },
		{ action = "move", delay = 0, cframe = CFrame.new(
			-421.770264, -44.2260475, -297.081909,
			0.999515891, 6.59387993e-08, 0.0311128739,
			-6.60972859e-08, 1, 4.06536627e-09,
			-0.0311128739, -6.11987483e-09, 0.999515891
		) },
	}

	local function startAutoWin()
		if autoWinActive then notify("Vitória Automática", "A rota já está em andamento.") return end
		local character = getCharacter()
		if not character or not getRoot(character) or not getHumanoid(character) then
			notify("Vitória Automática", "Personagem não encontrado.")
			return
		end
		stopCartControllersForTeleport(true)
		autoWinSession = autoWinSession + 1
		local session = autoWinSession
		autoWinActive = true
		notify("Vitória Automática", "Rota antiga iniciada; não feche o menu.")
		task.spawn(function()
			local ok, completed = pcall(function()
				for _, step in ipairs(autoWinRoute) do
					if not autoWinAlive(session) then return false end
					local root = getRoot(character)
					local humanoid = getHumanoid(character)
					if getCharacter() ~= character or not root or not root.Parent
						or not humanoid or not humanoid.Parent
					then error("Personagem perdido durante a rota.", 0) end
					if step.action == "teleport" then
						if not teleportCharacter(step.cframe, true) then
							error("Não foi possível iniciar a rota.", 0)
						end
					elseif step.action == "move" then
						root.CFrame = step.cframe
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
					elseif step.action == "sit" then
						humanoid.Sit = step.value
					elseif step.action == "anchor" then
						autoWinAnchoredRoot = root
						autoWinOriginalAnchored = root.Anchored
						root.Anchored = true
					elseif step.action == "restoreAnchor" then
						restoreAutoWinAnchor()
					end
					if not waitAutoWin(step.delay, session) then return false end
				end
				return true
			end)
			if session ~= autoWinSession then return end
			cancelAutoWin(true)
			if not destroyed then
				if not ok then
					notify("Vitória Automática", tostring(completed):sub(1, 160))
				elseif completed then
					notify("Vitória Automática", "Rota concluída.")
				end
			end
		end)
	end

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
	TeleportSection:NewButton("Insígnia Secreta", "Teleporta para a Secret Badge.", function()
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
	TeleportSection:NewButton("Vitória Automática", "Executa a rota completa do menu antigo.", startAutoWin)
	TeleportSection:NewButton("Cancelar Vitória Automática", "Interrompe a rota com segurança.", function()
		cancelAutoWin(false)
	end)
end

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
do
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
	CartSection:NewButton("Ver Velocidade do Carrinho", "Mostra studs/s na notificação.", function()
		local cart = getCurrentCart()
		if not cart then notify("Velocidade", "Sente em um carrinho primeiro.") return end
		local primary = getCartPrimary(cart)
		if not primary then notify("Velocidade", "Estrutura não reconhecida.") return end
		local vel = primary.AssemblyLinearVelocity.Magnitude
		notify("Velocidade do Cart", string.format("%.1f studs/s", vel))
	end)
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
end

-- =============================================================================
-- ABA: Cart+ (boost CORRIGIDO com Attachment0 como no Nothrilo)
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

-- CORRIGIDO: usa RelativeTo Attachment0 com Z negativo (como no Nothrilo)
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
	local attachment = primary:FindFirstChild("CafezitosBoostAttachment")
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "CafezitosBoostAttachment"
		attachment.Parent = primary
		boostAttachmentCreated = true
	end
	boostAttachment = attachment
	local previousForce = primary:FindFirstChild("CafezitosBoost")
	if previousForce and previousForce:IsA("VectorForce") then previousForce:Destroy() end
	local bf = Instance.new("VectorForce")
	bf.Name = "CafezitosBoost"
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

-- Anti-Flip com timestamps (superior ao Nothrilo)
local antiFlipEnabled  = false
local antiFlipConn
BoostSection:NewToggle("Anti-Flip", "Endireita o carrinho ao tombar automaticamente.", function(state)
	antiFlipEnabled = state
	if antiFlipConn then antiFlipConn:Disconnect() antiFlipConn = nil end
	cartFeatureTiming.antiFlipReadyAt = 0
	if not state then
		notify("Anti-Flip", "Desligado.")
		return
	end
	antiFlipConn = RunService.Heartbeat:Connect(function()
		if not antiFlipEnabled or panicActive or FLYING or killerActive
			or os.clock() < cartMotionPauseUntil
			or os.clock() < cartFeatureTiming.antiFlipReadyAt
		then return end
		local cart = getCurrentCart()
		if not cart then return end
		local primary = getCartPrimary(cart)
		if not primary or not primary.Parent then return end
		local dot = primary.CFrame.UpVector:Dot(Vector3.new(0, 1, 0))
		if dot < 0.5 then
			cartFeatureTiming.antiFlipReadyAt = os.clock() + 1.5
			if boostActive then
				stopBoost()
				if boostToggleControl then
					task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
				end
			end
			local pos  = primary.CFrame.Position
			local look = Vector3.new(primary.CFrame.LookVector.X, 0, primary.CFrame.LookVector.Z)
			look = look.Magnitude > 0.01 and look.Unit or Vector3.new(1, 0, 0)
			local targetPosition = pos + Vector3.new(0, 2, 0)
			local ok = pivotCartByReference(cart, CFrame.new(targetPosition, targetPosition + look))
			if ok then notify("Anti-Flip", "Carrinho endireitado.") end
		end
	end)
	notify("Anti-Flip", "Ligado.")
end)

-- Freio automático com timestamps (superior ao Nothrilo)
local autobrakeEnabled  = false
local autobrakeConn
BoostSection:NewToggle("Freio Automático", "Trava ao detectar queda livre.", function(state)
	autobrakeEnabled = state
	if autobrakeConn then autobrakeConn:Disconnect() autobrakeConn = nil end
	cartFeatureTiming.autobrakeHoldUntil = 0
	cartFeatureTiming.autobrakeReadyAt = 0
	if not state then
		notify("Freio Automático", "Desligado.")
		return
	end
	autobrakeConn = RunService.Heartbeat:Connect(function()
		if not autobrakeEnabled or panicActive or FLYING or killerActive
			or os.clock() < cartMotionPauseUntil
		then return end
		local cart = getCurrentCart()
		if not cart then return end
		local primary = getCartPrimary(cart)
		if not primary then return end
		local now = os.clock()
		if now < cartFeatureTiming.autobrakeHoldUntil then
			for _, part in ipairs(cart:GetDescendants()) do
				if part:IsA("BasePart") and not part.Anchored then
					pcall(function()
						part.AssemblyLinearVelocity = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end
			return
		end
		if now >= cartFeatureTiming.autobrakeReadyAt and primary.AssemblyLinearVelocity.Y < -35 then
			cartFeatureTiming.autobrakeHoldUntil = now + 0.45
			cartFeatureTiming.autobrakeReadyAt = now + 1.25
			if boostActive then
				stopBoost()
				if boostToggleControl then
					task.defer(function() boostToggleControl:UpdateToggle(nil, false) end)
				end
			end
			for _, part in ipairs(cart:GetDescendants()) do
				if part:IsA("BasePart") and not part.Anchored then
					pcall(function()
						part.AssemblyLinearVelocity  = Vector3.zero
						part.AssemblyAngularVelocity = Vector3.zero
					end)
				end
			end
			notify("Freio Automático", "Queda detectada — travado.")
		end
	end)
	notify("Freio Automático", "Ligado.")
end)

-- =============================================================================
-- ABA: Extras
-- =============================================================================
local ExtrasSection = Window:NewTab("Extras"):NewSection("Movimento e Física")

local noclipEnabled = false
local noclipOriginal = {}
local function restoreNoclip()
	for part, canCollide in pairs(noclipOriginal) do
		if part and part.Parent then part.CanCollide = canCollide end
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

local jumpPowerSlider = ExtrasSection:NewSlider("Jump Power", "Altura do pulo (padrão 50).", 300, 0, 50, function(value)
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
	jumpPowerSlider:SetValue(50, false)
	notify("Jump Power", "Redefinido.")
end)

local gravitySlider = ExtrasSection:NewSlider("Gravidade", "Gravidade global (padrão 196.2).", 400, 0, math.clamp(originalGravity, 0, 400), function(value)
	workspace.Gravity = value
end)
ExtrasSection:NewButton("Redefinir Gravidade", "Volta ao valor original do jogo.", function()
	workspace.Gravity = originalGravity
	gravitySlider:SetValue(math.clamp(originalGravity, 0, 400), false)
	notify("Gravidade", "Valor original restaurado.")
end)

local savedPosition = nil
ExtrasSection:NewButton("Salvar Posição Atual", "Salva onde você está.", function()
	local cart = getCurrentCart()
	local reference = cart and getCartPrimary(cart) or getRoot()
	if not reference then notify("Posição", "Personagem não encontrado.") return end
	savedPosition = reference.CFrame
	local p = reference.Position
	notify("Posição", string.format("Salva em %.0f, %.0f, %.0f", p.X, p.Y, p.Z))
end)
ExtrasSection:NewButton("Voltar à Posição Salva", "Teleporta de volta.", function()
	if not savedPosition then notify("Posição", "Nenhuma posição salva ainda.") return end
	if teleportPlayerOrCart(savedPosition) then notify("Posição", "Teleportado.") end
end)

-- =============================================================================
-- ABA: Mapa
-- =============================================================================
local MapSection = Window:NewTab("Mapa"):NewSection("Exploração")

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

MapSection:NewButton("Listar Partes no Output (F9)", "Imprime 30 BaseParts no console.", function()
	print("[Cafezitos V2] === BaseParts no Workspace ===")
	local count = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and count < 30 then
			print(("[Cafezitos V2] %s  pos: %s"):format(obj:GetFullName(), tostring(obj.Position)))
			count = count + 1
		end
	end
	print(("[Cafezitos V2] %d partes listadas. Abra F9 para ver."):format(count))
	notify("Mapa", count .. " partes no output (F9).")
end)

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
	if freecamToggleControl then freecamToggleControl:UpdateToggle(nil, false)
	else stopFreecam() end
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
	freecamConn = RunService.RenderStepped:Connect(function(deltaTime)
		if not freecamActive then return end
		local currentCamera = workspace.CurrentCamera
		if not currentCamera then return end
		if currentCamera ~= camera then
			camera = currentCamera
			camera.CameraType = Enum.CameraType.Scriptable
		end
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector  end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector  end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - Vector3.new(0, 1, 0) end
		if move.Magnitude > 0 then
			cf = CFrame.new(cf.Position + move * freecamSpeed * math.clamp(deltaTime * 60, 0, 3))
				* (cf - cf.Position)
		end
		camera.CFrame = cf
		camera.Focus = cf * CFrame.new(0, 0, -12)
	end)
	notify("Câmera Livre", "WASD move, Q/E sobe e desce. Desative para voltar.")
end)
MapSection:NewSlider("Velocidade da Câmera Livre", "Velocidade de movimento (1–10).", 10, 1, 1, function(value)
	freecamSpeed = value
end)

-- =============================================================================
-- ABA: Eliminador
-- =============================================================================
do
	local KillerSection = Window:NewTab("Eliminador"):NewSection("Controle de Alvo")
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
			end, CafeUI.traceback)
			if not ok then
				warn(MENU_NAME .. " Killer: " .. err)
				if killerActive then finishKiller("Erro na tentativa. Tente de novo.") end
			end
		end)
	end)
end

-- =============================================================================
-- ABA: Troll
-- =============================================================================
local stopSpin
local restoreFakeLag
local stopSpectate
do
	local TrollSection = Window:NewTab("Troll"):NewSection("Diversão")

	local spinDuration = 5
	local spinConn
	stopSpin = function(silent)
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
			local currentCamera = workspace.CurrentCamera
			if not currentCamera then return end
			if currentCamera ~= camera then
				camera = currentCamera
				camera.CameraType = Enum.CameraType.Scriptable
				origin = camera.CFrame
			end
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
	TrollSection:NewSlider("Duração Câmera (s)", "Segundos de giro.", 30, 1, 5, function(value)
		spinDuration = value
	end)

	local fakeLagDuration = 2
	restoreFakeLag = function()
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
	TrollSection:NewSlider("Duração Fake Lag (s)", "Duração em segundos.", 15, 1, 2, function(value)
		fakeLagDuration = value
	end)

	local spectating  = false
	local spectateConn
	stopSpectate = function(silent)
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
			local currentCamera = workspace.CurrentCamera
			if not currentCamera then return end
			if currentCamera ~= camera then
				camera = currentCamera
				camera.CameraType = Enum.CameraType.Scriptable
			end
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
end

-- =============================================================================
-- Minimizar / reabrir + drag
-- =============================================================================
local function findMenuGui()
	for _, guiRoot in ipairs(guiRoots) do
		for _, gui in ipairs(guiRoot:GetChildren()) do
			if gui:IsA("ScreenGui") then
				if gui.Name == "CafezitosV2UI" then return gui end
				local main   = gui:FindFirstChild("Main", true)
				local header = main and main:FindFirstChild("MainHeader")
				local title  = header and header:FindFirstChild("title")
				if title and title.Text == UI_TITLE then return gui end
			end
		end
	end
	return nil
end

local menuGui = findMenuGui()
local commandsTabButton
if not menuGui then
	warn(MENU_NAME .. ": não foi possível localizar a janela principal.")
	menuGui = Instance.new("ScreenGui")
	menuGui.Name = "CafezitosFallbackHost"
	menuGui.ResetOnSpawn = false
	menuGui.Parent = CoreGui
end

local function applyRoundedStyle(root)
	for _, object in ipairs(root:GetDescendants()) do
		if object:IsA("UICorner") then object.CornerRadius = UDim.new(0, 12) end
	end
end
applyRoundedStyle(menuGui)
trackConnection(menuGui.DescendantAdded:Connect(function(object)
	if object:IsA("UICorner") then object.CornerRadius = UDim.new(0, 12) end
end))

do
	local textBoxesByLabel = {}
	for _, element in ipairs(menuGui:GetDescendants()) do
		if element:IsA("TextButton") and element.Name == "textboxElement" then
			local title = element:FindFirstChild("togName")
			local input = element:FindFirstChildOfClass("TextBox")
			if title and input then
				textBoxesByLabel[title.Text] = input
				if input.PlaceholderText == "Type here!" then
					input.PlaceholderText = "Digite aqui..."
				end
			end
		end
	end
	getKavoTextBoxByLabel = function(labelText)
		local input = textBoxesByLabel[labelText]
		return input and input.Parent and input or nil
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
	configureKavoTextBox("Ir até Jogador",    "Nome ou começo do nome", nil)
	configureKavoTextBox("Velocidade do Voo", "Digite a velocidade",    nil)
	configureKavoTextBox("Nome do Alvo",      "Nome ou começo do nome", nil)
	configureKavoTextBox("Força Normal",      "2500", 2500)
	configureKavoTextBox("Força em Descidas", "800",  800)
end

local customKeybindIcons = {}
local shortcutElementsByLabel
local function rebuildShortcutElementIndex()
	shortcutElementsByLabel = {}
	for _, element in ipairs(menuGui:GetDescendants()) do
		if element:IsA("TextButton") then
			local title = element:FindFirstChild("togName")
			if title and title:IsA("TextLabel") then
				local list = shortcutElementsByLabel[title.Text]
				if not list then
					list = {}
					shortcutElementsByLabel[title.Text] = list
				end
				table.insert(list, element)
			end
		end
	end
end

local function addShortcutBadge(labelText, keyText)
	if not shortcutElementsByLabel then rebuildShortcutElementIndex() end
	for _, element in ipairs(shortcutElementsByLabel[labelText] or {}) do
		if element.Parent and not element:FindFirstChild("CafezitosShortcut_" .. keyText) then
			local badgeWidth = keyText == "1/2/3" and 42 or 21
			local badge      = Instance.new("TextButton")
			badge.Name           = "CafezitosShortcut_" .. keyText
			badge.Size           = UDim2.fromOffset(badgeWidth, 21)
			badge.AnchorPoint    = Vector2.new(1, 0)
			badge.Position       = UDim2.new(1, -66, 0, 9)
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
				elseif keyText == "K" and setMenuVisible then setMenuVisible(false)
				elseif keyText == "X" and destroyCafezitos then destroyCafezitos()
				end
			end)
		end
	end
end

addShortcutBadge("Voo do Veículo",      "V")
addShortcutBadge("ESP",                 "L")
addShortcutBadge("Pulo Infinito",       "P")
addShortcutBadge("Teleporte por Clique","T")
addShortcutBadge("Boost do Carrinho",   "B")
addShortcutBadge("Ir ao Checkpoint 1",  "1")
addShortcutBadge("Ir ao Checkpoint 2",  "2")
addShortcutBadge("Ir ao Checkpoint 3",  "3")

local toastGui = Instance.new("ScreenGui")
toastGui.Name           = "CafezitosNotifications"
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
do
	local toastLayout = Instance.new("UIListLayout")
	toastLayout.Padding    = UDim.new(0, 8)
	toastLayout.SortOrder  = Enum.SortOrder.LayoutOrder
	toastLayout.Parent     = toastContainer
end

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

local launcherGui = Instance.new("ScreenGui")
launcherGui.Name           = "CafezitosLauncher"
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
CafeUI.launcherStroke = Instance.new("UIStroke")
CafeUI.launcherStroke.Thickness = 2.5
CafeUI.launcherStroke.Parent    = launcher
CafeUI.launcherIcon = Instance.new("TextLabel")
CafeUI.launcherIcon.BackgroundTransparency = 1
CafeUI.launcherIcon.Size     = UDim2.fromScale(1, 1)
CafeUI.launcherIcon.Position = UDim2.fromOffset(0, 0)
CafeUI.launcherIcon.Font     = Enum.Font.GothamBold
CafeUI.launcherIcon.Text     = "☕"
CafeUI.launcherIcon.TextSize = 32
CafeUI.launcherIcon.Parent   = launcher

setMenuVisible = function(visible)
	if destroyed then return end
	menuGui.Enabled    = visible
	launcher.Visible   = not visible
end

do
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
end

CafeUI.launcherLastDrag = 0
enableDrag(launcher, launcher, function(wasDragged)
	if wasDragged then CafeUI.launcherLastDrag = os.clock() end
end)
launcher.Activated:Connect(function()
	if os.clock() - CafeUI.launcherLastDrag < 0.25 then return end
	setMenuVisible(true)
end)

-- =============================================================================
-- Atalhos de teclado globais
-- =============================================================================
if destroyed or not runtime.Parent or not isCurrentSuiteGeneration() then return end
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
		destroyCafezitos()
	end
end))

-- =============================================================================
-- Destruição limpa
-- =============================================================================
destroyCafezitos = function()
	if destroyed then return end
	local hadManagedCamera = activeCameraMode ~= nil or cameraBaseline ~= nil
	destroyed    = true
	killerActive = false
	killerSession = killerSession + 1
	if cancelAutoWin then cancelAutoWin(true) end
	infiniteJump = false
	disconnectRuntimeConnections()
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
	if cameraBaseline or not hadManagedCamera then restoreDefaultCamera() end
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
-- ABA: Comandos
-- =============================================================================
do
	local CommandsSection = Window:NewTab("Comandos"):NewSection("Atalhos")
	commandsTabButton = menuGui:FindFirstChild("ComandosTabButton", true)
	CommandsSection:NewButton("V  •  Voo do Veículo",       "Tecla V", function() flyToggleControl:UpdateToggle(nil, not flyEnabled) end)
	CommandsSection:NewButton("L  •  ESP",                  "Tecla L", function() espToggleControl:UpdateToggle(nil, not espEnabled) end)
	CommandsSection:NewButton("P  •  Pulo Infinito",        "Tecla P", function() infiniteJumpToggleControl:UpdateToggle(nil, not infiniteJump) end)
	CommandsSection:NewButton("T  •  Teleporte por Clique", "Tecla T", giveClickTeleportTool)
	CommandsSection:NewButton("B  •  Boost do Carrinho",    "Tecla B", function() boostToggleControl:UpdateToggle(nil, not boostActive) end)
	CommandsSection:NewButton("NumPad 1/2/3  •  Checkpoints","Teclado numérico", function()
		notify("Checkpoints", "Use NumPad 1, 2 ou 3.")
	end)
	CommandsSection:NewButton("K  •  Minimizar / Abrir",    "Tecla K", function() setMenuVisible(false) end)
	CommandsSection:NewButton("X  •  Fechar o Cafezitos",   "Tecla X", destroyCafezitos)
	shortcutElementsByLabel = nil
	addShortcutBadge("V  •  Voo do Veículo",        "V")
	addShortcutBadge("L  •  ESP",                   "L")
	addShortcutBadge("P  •  Pulo Infinito",         "P")
	addShortcutBadge("T  •  Teleporte por Clique",  "T")
	addShortcutBadge("B  •  Boost do Carrinho",     "B")
	addShortcutBadge("NumPad 1/2/3  •  Checkpoints","1/2/3")
	addShortcutBadge("K  •  Minimizar / Abrir",     "K")
	addShortcutBadge("X  •  Fechar o Cafezitos",    "X")
end

-- =============================================================================
-- ABA: Interface
-- =============================================================================
do
	local GuiSection = Window:NewTab("Interface"):NewSection("Interface")
	GuiSection:NewButton("Fechar Menu", "Tecla X também fecha o Cafezitos.", destroyCafezitos)
end

-- =============================================================================
-- Loop RGB
-- =============================================================================
task.spawn(function()
	while not destroyed and menuGui.Parent and launcherGui.Parent do
		local pulse = (math.sin(os.clock() * 1.2) + 1) * 0.5
		local rgb = Color3.fromRGB(
			math.floor(188 + 38 * pulse),
			math.floor(112 + 42 * pulse),
			math.floor(57 + 27 * pulse)
		)
		CafeUI:ChangeColor("SchemeColor", rgb)
		if commandsTabButton and commandsTabButton.Parent then
			commandsTabButton.BackgroundColor3 = rgb
		end
		CafeUI.launcherStroke.Color = rgb
		CafeUI.launcherIcon.TextColor3 = rgb
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

startup.finished = true
if Window.gui and Window.gui.Parent then Window.gui.Enabled = true end
if startup.status and startup.status.Parent then startup.status.Text = "Pronto!" end
if startup.gui and startup.gui.Parent then startup.gui:Destroy() end
notify(MENU_NAME, "Feito por Cafezl  •  K minimiza e reabre o menu.")
