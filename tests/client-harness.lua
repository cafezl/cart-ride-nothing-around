-- Deterministic bootstrap-only Roblox model. This is NOT a Roblox emulator
-- and does not validate gameplay, real HTTP, executor permissions or physics.
local function runFixture(source, options)
    options = options or {}
    local base = getfenv()
    local now, sequence = 0, 0
    local scheduled, failures, warnings = {}, {}, {}
    local env = setmetatable({}, { __index = base })
    local function schedule(thread, at, args)
        sequence += 1
        table.insert(scheduled, { thread = thread, at = at, args = args or {}, order = sequence })
        return thread
    end
    env.task = {}
    function env.task.spawn(fn, ...)
        return schedule(coroutine.create(fn), now, table.pack(...))
    end
    env.task.defer = env.task.spawn
    function env.task.delay(delay, fn, ...)
        return schedule(coroutine.create(fn), now + delay, table.pack(...))
    end
    function env.task.wait(delay)
        return coroutine.yield(math.max(0.001, delay or 1 / 60))
    end
    function env.task.cancel(thread)
        for index = #scheduled, 1, -1 do
            if scheduled[index].thread == thread then table.remove(scheduled, index) end
        end
    end
    env.os = { clock = function() return now end, time = function() return 1800000000 + math.floor(now) end }
    env.tick = env.os.clock
    env.warn = function(message) table.insert(warnings, tostring(message)) end
    env._G = env
    env.getgenv = function() return env end
    env.SCRIPT_KEY = options.sessionKey
    local sdkCalls, copiedText = {}, {}
    env.setclipboard = function(value) table.insert(copiedText, value) end
    local sdk = {}
    function sdk.get_key_link()
        table.insert(sdkCalls, { name = "get_key_link", service = sdk.service, identifier = sdk.identifier, provider = sdk.provider })
        if options.sdkDelay then env.task.wait(options.sdkDelay) end
        return options.sdkLink or "https://jnkie.com/get-key/nothrilov2"
    end
    function sdk.check_key(key)
        table.insert(sdkCalls, { name = "check_key", key = key, service = sdk.service, identifier = sdk.identifier, provider = sdk.provider })
        if options.sdkDelay then env.task.wait(options.sdkDelay) end
        if options.sdkValid == false then return { valid = false, error = "KEY_INVALID" } end
        return { valid = true }
    end
    env.loadstring = function(source, ...)
        if source == "fixture-jnkie-sdk" then return function() return sdk end end
        return base.loadstring(source, ...)
    end

    local function signal()
        local listeners = {}
        return {
            Connect = function(_, callback)
                local connection = { Connected = true }
                function connection:Disconnect() self.Connected = false end
                table.insert(listeners, { connection, callback })
                return connection
            end,
            Fire = function(_, ...)
                for _, entry in ipairs(listeners) do
                    if entry[1].Connected then entry[2](...) end
                end
            end,
            Wait = function() return env.task.wait(1 / 60) end,
            ListenerCount = function()
                local count = 0
                for _, entry in ipairs(listeners) do if entry[1].Connected then count += 1 end end
                return count
            end,
        }
    end
    local vectorMeta = {}
    local function vector(x, y, z)
        return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0, __type = "Vector3" }, vectorMeta)
    end
    vectorMeta.__index = function(value, key)
        if key == "Magnitude" then return math.sqrt(value.X ^ 2 + value.Y ^ 2 + value.Z ^ 2) end
        if key == "Unit" then local length = value.Magnitude; return length > 0 and vector(value.X / length, value.Y / length, value.Z / length) or vector() end
        if key == "Dot" then return function(a, b) return a.X * b.X + a.Y * b.Y + a.Z * b.Z end end
        if key == "Lerp" then return function(a) return a end end
    end
    vectorMeta.__add = function(a, b) return vector(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
    vectorMeta.__sub = function(a, b) return vector(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
    vectorMeta.__unm = function(a) return vector(-a.X, -a.Y, -a.Z) end
    vectorMeta.__mul = function(a, b)
        if type(a) == "number" then a, b = b, a end
        return vector(a.X * b, a.Y * b, a.Z * b)
    end
    env.Vector2 = { new = vector, zero = vector() }
    env.Vector3 = { new = vector, zero = vector(), one = vector(1, 1, 1), xAxis = vector(1), yAxis = vector(0, 1), zAxis = vector(0, 0, 1) }
    env.UDim = { new = function(scale, offset) return { Scale = scale, Offset = offset } end }
    env.UDim2 = {
        new = function(xs, xo, ys, yo) return { X = env.UDim.new(xs, xo), Y = env.UDim.new(ys, yo) } end,
        fromScale = function(x, y) return { X = env.UDim.new(x, 0), Y = env.UDim.new(y, 0) } end,
        fromOffset = function(x, y) return { X = env.UDim.new(0, x), Y = env.UDim.new(0, y) } end,
    }
    env.Color3 = {
        new = function(r, g, b) return { R = r, G = g, B = b, __type = "Color3" } end,
        fromRGB = function(r, g, b) return { R = r / 255, G = g / 255, B = b / 255, __type = "Color3" } end,
        fromHSV = function() return { R = 1, G = 0.5, B = 0.25, __type = "Color3" } end,
    }
    local cframeMeta = {}
    local function cframe()
        return setmetatable({ Position = vector(), LookVector = vector(0, 0, -1), RightVector = vector(1), UpVector = vector(0, 1), __type = "CFrame" }, cframeMeta)
    end
    cframeMeta.__mul = function(a) return a end
    cframeMeta.__add = function(a) return a end
    cframeMeta.__sub = function(a) return a end
    cframeMeta.__index = function(_, key)
        if key == "Lerp" or key == "ToObjectSpace" or key == "ToWorldSpace" then return function(a) return a end end
    end
    env.CFrame = { new = cframe, Angles = cframe, lookAt = cframe, identity = cframe() }
    for _, name in ipairs({ "TweenInfo", "ColorSequence", "ColorSequenceKeypoint", "NumberSequence", "NumberSequenceKeypoint", "NumberRange", "Rect", "RaycastParams", "PhysicalProperties" }) do
        env[name] = { new = function(...) return table.pack(...) end }
    end
    env.Enum = setmetatable({}, { __index = function(enums, category)
        local values = setmetatable({}, { __index = function(items, name)
            local item = { Name = name, Value = 1, __type = "EnumItem" }
            rawset(items, name, item)
            return item
        end })
        rawset(enums, category, values)
        return values
    end })

    local methods, instanceMeta = {}, {}
    local signals = {}
    for _, name in ipairs({ "Activated", "MouseButton1Click", "MouseButton1Down", "MouseEnter", "MouseLeave", "InputBegan", "InputChanged", "InputEnded", "FocusLost", "Focused", "DescendantAdded", "ChildAdded", "ChildRemoved", "AncestryChanged", "Changed", "Destroying", "CharacterAdded", "CharacterRemoving", "PlayerAdded", "PlayerRemoving", "JumpRequest", "Idled", "Died", "Seated", "StateChanged", "RenderStepped", "Heartbeat", "Stepped", "Loaded", "Completed", "Event" }) do
        signals[name] = true
    end
    local function instance(className, parent)
        local object = setmetatable({ __type = "Instance", _props = {
            ClassName = className, Name = className, Enabled = true, Visible = true,
            Text = "", TextSize = 14, TextBounds = vector(100, 20), AbsoluteSize = vector(800, 600), AbsolutePosition = vector(),
            AbsoluteContentSize = vector(), CanvasPosition = vector(), Position = env.UDim2.fromOffset(0, 0), Size = env.UDim2.fromOffset(100, 30),
        }, _children = {}, _signals = {}, _attributes = {}, _stateEnabled = {} }, instanceMeta)
        if parent then object.Parent = parent end
        return object
    end
    instanceMeta.__index = function(self, key)
        if methods[key] then return methods[key] end
        if signals[key] then
            if not self._signals[key] then self._signals[key] = signal() end
            return self._signals[key]
        end
        return self._props[key]
    end
    instanceMeta.__newindex = function(self, key, value)
        if key == "Parent" then
            if value and options.blockCore and value.ClassName == "CoreGui" then error("CoreGui write denied") end
            local previous = self._props.Parent
            if previous then
                for index, child in ipairs(previous._children) do
                    if child == self then table.remove(previous._children, index); break end
                end
            end
            self._props.Parent = value
            if value then table.insert(value._children, self) end
        else self._props[key] = value end
    end
    function methods:IsA(name)
        if name == self.ClassName or name == "Instance" then return true end
        if name == "GuiObject" then return self.ClassName == "Frame" or self.ClassName == "ScrollingFrame" or self.ClassName:find("Text", 1, true) == 1 or self.ClassName:find("Image", 1, true) == 1 end
        if name == "BasePart" then return self.ClassName == "Part" or self.ClassName == "VehicleSeat" end
        return false
    end
    function methods:GetChildren() return table.clone(self._children) end
    function methods:GetDescendants()
        local result = {}
        local function collect(root)
            for _, child in ipairs(root._children) do table.insert(result, child); collect(child) end
        end
        collect(self)
        return result
    end
    function methods:FindFirstChild(name, recursive)
        for _, child in ipairs(recursive and self:GetDescendants() or self._children) do
            if child.Name == name then return child end
        end
        return nil
    end
    function methods:FindFirstChildOfClass(name)
        for _, child in ipairs(self._children) do if child:IsA(name) then return child end end
        return nil
    end
    methods.FindFirstChildWhichIsA = methods.FindFirstChildOfClass
    function methods:WaitForChild(name, timeout)
        local deadline = now + (timeout or 10)
        repeat
            local child = self:FindFirstChild(name)
            if child then return child end
            env.task.wait(0.02)
        until now >= deadline
        return nil
    end
    function methods:GetPropertyChangedSignal(name)
        if not self._signals[name] then self._signals[name] = signal() end
        return self._signals[name]
    end
    function methods:SetAttribute(name, value) self._attributes[name] = value end
    function methods:GetAttribute(name) return self._attributes[name] end
    function methods:IsDescendantOf(root)
        local parent = self.Parent
        while parent do if parent == root then return true end; parent = parent.Parent end
        return false
    end
    function methods:Destroy()
        for _, child in ipairs(self:GetChildren()) do child:Destroy() end
        self.Parent = nil
    end
    function methods:Fire(...) self.Event:Fire(...) end
    function methods:GetFullName() return self.Name end
    function methods:Play() end
    function methods:Cancel() end
    function methods:GetFocusedTextBox() return nil end
    function methods:IsKeyDown() return false end
    function methods:GetMouseLocation() return vector() end
    function methods:GetMouseDelta() return vector() end
    function methods:GetState() return env.Enum.HumanoidStateType.Running end
    function methods:GetStateEnabled(state)
        local value = self._stateEnabled[state]
        if value == nil then return true end
        return value
    end
    function methods:SetStateEnabled(state, enabled) self._stateEnabled[state] = enabled end
    function methods:SetCore() end
    function methods:IsLoaded() return true end
    function methods:IsClient() return true end
    env.Instance = { new = instance }
    env.typeof = function(value) return type(value) == "table" and rawget(value, "__type") or type(value) end

    local services = {}
    env.game = instance("DataModel")
    env.game.PlaceId = 10660791703
    env.game.GameId = 0
    function methods:GetService(name)
        if not services[name] then services[name] = instance(name) end
        return services[name]
    end
    local players = env.game:GetService("Players")
    local player = instance("Player", players)
    player.Name, player.DisplayName, player.UserId = "FixturePlayer", "FixturePlayer", 123456
    local playerGui = instance("PlayerGui")
    local workspace = env.game:GetService("Workspace")
    env.workspace = workspace
    workspace.Gravity = 196.2
    local character = instance("Model", workspace)
    character.Name = "FixtureCharacter"
    local humanoid = instance("Humanoid", character)
    humanoid.Health, humanoid.MaxHealth, humanoid.WalkSpeed, humanoid.JumpPower, humanoid.JumpHeight = 100, 100, 16, 50, 7.2
    humanoid.UseJumpPower = true
    local root = instance("Part", character)
    root.Name, root.CFrame, root.Position, root.AssemblyLinearVelocity = "HumanoidRootPart", cframe(), vector(), vector()
    player.Character = character
    instance("Backpack", player)
    local mouse = { Hit = cframe(), Button1Down = signal(), KeyDown = signal(), KeyUp = signal() }
    function methods:GetMouse() return mouse end
    function methods:GetPlayers() return { player } end
    function methods:GetPlayerFromCharacter(value) return value == character and player or nil end
    function methods:GetTagged() return {} end
    local camera = instance("Camera", workspace)
    camera.ViewportSize, camera.CFrame, camera.FieldOfView, camera.CameraSubject = vector(options.viewportWidth or 800, options.viewportHeight or 600), cframe(), 70, humanoid
    workspace.CurrentCamera = camera
    function methods:Create(target, _, properties)
        return { Play = function() for key, value in pairs(properties) do target[key] = value end end, Cancel = function() end, Completed = signal() }
    end
    function methods:JSONEncode() return "fixture-json" end
    function methods:JSONDecode() error("fixture does not decode external JSON") end
    function methods:GenerateGUID() return "00000000-0000-4000-8000-000000000000" end
    function methods:RequestAsync() error("fixture does not make external requests") end
    function methods:HttpGet(url)
        if options.sdk and url == "https://jnkie.com/sdk/library.lua" then return "fixture-jnkie-sdk" end
        error("fixture does not download files")
    end
    env.gethui = function() return options.badHui and {} or env.game:GetService("CoreGui") end

    local main = assert(loadstring(source, "@fixture/" .. (options.name or "client")))
    setfenv(main, env)
    local mainThread = schedule(coroutine.create(main), 0)
    local submitted = {}
    local steps = 0
    while #scheduled > 0 and now <= (options.maxTime or 15) do
        table.sort(scheduled, function(a, b) return a.at == b.at and a.order < b.order or a.at < b.at end)
        local current = table.remove(scheduled, 1)
        now = current.at
        if not options.noPlayer and now >= (options.playerDelay or 0) then players.LocalPlayer = player end
        if now >= (options.guiDelay or 0) and not playerGui.Parent then playerGui.Parent = player end
        if options.authorize ~= false or options.closeGate or options.replaceSuite or options.onGate then
            for _, parent in ipairs({ env.game:GetService("CoreGui"), playerGui }) do
                local gate = parent:FindFirstChild("NothriloKeyGate")
                if gate and not submitted[gate] then
                    local input, button = gate:FindFirstChild("KeyInput", true), gate:FindFirstChild("Verify", true)
                    if options.onGate then
                        submitted[gate] = true
                        env.task.spawn(function() options.onGate(gate, env) end)
                    elseif options.closeGate then
                        submitted[gate] = true
                        env.task.spawn(function() gate:FindFirstChild("Close", true).Activated:Fire() end)
                    elseif options.replaceSuite then
                        submitted[gate] = true
                        env.__CafezlSuiteGeneration = (env.__CafezlSuiteGeneration or 0) + 1
                    elseif input and button then
                        submitted[gate] = true
                        input.Text = "fixture-valid-key"
                        env.task.spawn(function() button.Activated:Fire() end)
                    end
                end
            end
        end
        if coroutine.status(current.thread) ~= "dead" then
            local ok, delay = coroutine.resume(current.thread, table.unpack(current.args, 1, current.args.n or #current.args))
            if not ok then table.insert(failures, tostring(delay))
            elseif coroutine.status(current.thread) ~= "dead" then schedule(current.thread, now + (tonumber(delay) or 1 / 60)) end
        end
        steps += 1
        assert(steps < 10000, "fixture scheduler exceeded its budget")
        if coroutine.status(mainThread) == "dead" and not options.drainAfterMain then break end
    end
    return { env = env, core = env.game:GetService("CoreGui"), playerGui = playerGui, failures = failures, warnings = warnings, finished = coroutine.status(mainThread) == "dead", elapsed = now, sdkCalls = sdkCalls, copiedText = copiedText }
end
