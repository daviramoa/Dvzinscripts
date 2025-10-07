-- DVZIN DEVELOPER GUI - UNIVERSAL (CLIENT-SIDE / LEGIT)
-- Coloque esse LocalScript em StarterPlayerScripts ou StarterGui
-- Tudo aqui é local / observação apenas.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- STORAGE (persist config in a StringValue under player for session)
local function ensureSettingsStorage()
    local s = Player:FindFirstChild("DVZIN_Settings")
    if not s then
        s = Instance.new("StringValue")
        s.Name = "DVZIN_Settings"
        s.Value = "{}"
        s.Parent = Player
    end
    return s
end
local settingsStorage = ensureSettingsStorage()

local function saveSettings(table)
    settingsStorage.Value = HttpService:JSONEncode(table)
end
local function loadSettings()
    local ok, t = pcall(function() return HttpService:JSONDecode(settingsStorage.Value) end)
    if ok and type(t) == "table" then return t end
    return {}
end

-- UTILIDADES
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function createRounded(frame, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = frame
    return c
end

local function centerOnScreen(guiObject)
    guiObject.Position = UDim2.new(0.5,0,0.5,0)
    if guiObject:IsA("Frame") then
        guiObject.AnchorPoint = Vector2.new(0.5,0.5)
    end
end

-- GUI BASE
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DVZIN_DevGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,520,0,440)
mainFrame.Position = UDim2.new(0.5,0,0.5,0)
mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(28,28,30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
createRounded(mainFrame, 12)
makeDraggable(mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Text = "DVZIN DEVELOPER GUI — Universal (local)"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(240,240,240)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,14,0,10)
title.Size = UDim2.new(1,-28,0,26)
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Size = UDim2.new(0,32,0,28)
closeBtn.Position = UDim2.new(1,-40,0,8)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
createRounded(closeBtn, 6)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Sidebar (categories)
local sidebar = Instance.new("ScrollingFrame", mainFrame)
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0,160,1,-44)
sidebar.Position = UDim2.new(0,0,0,40)
sidebar.BackgroundColor3 = Color3.fromRGB(38,38,40)
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 8
createRounded(sidebar, 8)
local sideLayout = Instance.new("UIListLayout", sidebar)
sideLayout.Padding = UDim.new(0,8)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
local sidePad = Instance.new("UIPadding", sidebar)
sidePad.PaddingTop = UDim.new(0,10)
sidePad.PaddingLeft = UDim.new(0,10)
sidePad.PaddingRight = UDim.new(0,10)

local container = Instance.new("Frame", mainFrame)
container.Name = "Container"
container.Size = UDim2.new(1,-170,1,-44)
container.Position = UDim2.new(0,170,0,40)
container.BackgroundTransparency = 1

-- Helper to create category pages
local function createCategoryButton(name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Text = name
    btn.Size = UDim2.new(1,-10,0,38)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(55,55,58)
    btn.TextColor3 = Color3.fromRGB(240,240,240)
    createRounded(btn, 6)

    local page = Instance.new("ScrollingFrame", container)
    page.Size = UDim2.new(1,0,1,0)
    page.Position = UDim2.new(0,0,0,0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 8
    page.Visible = false
    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0,8)
    pad.PaddingLeft = UDim.new(0,10)
    pad.PaddingRight = UDim.new(0,10)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 12)
    end)

    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("ScrollingFrame") then child.Visible = false end
        end
        page.Visible = true
    end)

    return page
end

local pageInterface = createCategoryButton("Interface / UX")
local pageMovement = createCategoryButton("Movimento")
local pagePhysics = createCategoryButton("Física / Ambiente")
local pageCamera = createCategoryButton("Câmera / Observação")
local pageVisual = createCategoryButton("Visual / Efeitos")
local pageTools = createCategoryButton("Ferramentas / Debug")
local pageAudio = createCategoryButton("Áudio")
local pageProps = createCategoryButton("Props (client-side)")

-- top-level quick buttons
local function makeScriptButton(page, labelText, onClick)
    local f = Instance.new("Frame", page)
    f.Size = UDim2.new(1,0,0,78)
    f.BackgroundColor3 = Color3.fromRGB(46,46,48)
    createRounded(f,6)
    local t = Instance.new("TextLabel", f)
    t.Text = labelText
    t.Font = Enum.Font.GothamBold
    t.TextColor3 = Color3.fromRGB(240,240,240)
    t.TextSize = 15
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0.04,0,0.06,0)
    t.Size = UDim2.new(0.6,0,0,28)
    local b = Instance.new("TextButton", f)
    b.Text = "Abrir"
    b.Font = Enum.Font.GothamBold
    b.TextSize = 14
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.BackgroundColor3 = Color3.fromRGB(0,150,230)
    b.Size = UDim2.new(0.7,0,0,32)
    b.Position = UDim2.new(0.15,0,0.45,0)
    createRounded(b,6)
    b.MouseButton1Click:Connect(onClick)
end

-- SMALL HELPERS / STATE
local state = {
    doubleJumpEnabled = false,
    doubleJumpCount = 0,
    presets = {},
    anchors = {}, -- saved teleport anchors (local)
    freecam = {enabled = false, speed = 80, cf = CFrame.new()},
    noclip = false,
    esp = {},
    highlights = {},
    localProps = {},
    trails = {},
    particles = {},
    sounds = {},
    savedSettings = loadSettings()
}

-- Utility: create a centered popup frame
local function createPopup(width, height, titleText)
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0,width,0,height)
    popup.BackgroundColor3 = Color3.fromRGB(50,50,52)
    popup.BorderSizePixel = 0
    popup.Parent = screenGui
    createRounded(popup,8)
    centerOnScreen(popup)

    local t = Instance.new("TextLabel", popup)
    t.Text = titleText or ""
    t.Font = Enum.Font.GothamBold
    t.TextSize = 15
    t.TextColor3 = Color3.fromRGB(240,240,240)
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0.05,0,0.03,0)
    t.Size = UDim2.new(0.9,0,0,24)
    local close = Instance.new("TextButton", popup)
    close.Text = "X"
    close.Size = UDim2.new(0,28,0,26)
    close.Position = UDim2.new(1,-36,0,6)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.TextColor3 = Color3.fromRGB(255,255,255)
    close.BackgroundColor3 = Color3.fromRGB(180,60,60)
    createRounded(close,6)
    close.MouseButton1Click:Connect(function() popup:Destroy() end)
    return popup
end

-- ========== 1) Interface / UX functions ==========
makeScriptButton(pageInterface, "Minimizar / Maximizar", function()
    local popup = createPopup(380,120, "Minimizar / Maximizar GUI")
    local btn = Instance.new("TextButton", popup)
    btn.Size = UDim2.new(0.6,0,0,36)
    btn.Position = UDim2.new(0.2,0,0.3,0)
    btn.Text = "Minimizar"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(btn, 6)
    local minimized = false
    btn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            mainFrame.Size = UDim2.new(0,300,0,44)
            btn.Text = "Maximizar"
        else
            mainFrame.Size = UDim2.new(0,520,0,440)
            btn.Text = "Minimizar"
        end
    end)
end)

makeScriptButton(pageInterface, "Tema / Cores (Dark/Light)", function()
    local popup = createPopup(380,150, "Tema da GUI")
    local darkBtn = Instance.new("TextButton", popup)
    darkBtn.Text = "Tema escuro"
    darkBtn.Size = UDim2.new(0.4,0,0,36)
    darkBtn.Position = UDim2.new(0.06,0,0.3,0)
    createRounded(darkBtn,6)
    darkBtn.MouseButton1Click:Connect(function()
        mainFrame.BackgroundColor3 = Color3.fromRGB(28,28,30)
        sidebar.BackgroundColor3 = Color3.fromRGB(38,38,40)
        container.BackgroundTransparency = 1
    end)
    local lightBtn = Instance.new("TextButton", popup)
    lightBtn.Text = "Tema claro"
    lightBtn.Size = UDim2.new(0.4,0,0,36)
    lightBtn.Position = UDim2.new(0.52,0,0.3,0)
    createRounded(lightBtn,6)
    lightBtn.MouseButton1Click:Connect(function()
        mainFrame.BackgroundColor3 = Color3.fromRGB(240,240,240)
        sidebar.BackgroundColor3 = Color3.fromRGB(230,230,230)
    end)
end)

makeScriptButton(pageInterface, "Salvar / Carregar Preset", function()
    local popup = createPopup(440,200, "Presets")
    local nameBox = Instance.new("TextBox", popup)
    nameBox.PlaceholderText = "Nome do preset..."
    nameBox.Size = UDim2.new(0.86,0,0,36)
    nameBox.Position = UDim2.new(0.07,0,0.18,0)
    nameBox.Font = Enum.Font.Gotham
    nameBox.TextSize = 14
    nameBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
    createRounded(nameBox,6)

    local saveBtn = Instance.new("TextButton", popup)
    saveBtn.Text = "Salvar preset"
    saveBtn.Size = UDim2.new(0.42,0,0,36)
    saveBtn.Position = UDim2.new(0.07,0,0.52,0)
    createRounded(saveBtn,6)
    saveBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    saveBtn.TextColor3 = Color3.fromRGB(255,255,255)

    local loadBtn = Instance.new("TextButton", popup)
    loadBtn.Text = "Carregar preset"
    loadBtn.Size = UDim2.new(0.42,0,0,36)
    loadBtn.Position = UDim2.new(0.51,0,0.52,0)
    createRounded(loadBtn,6)
    loadBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    loadBtn.TextColor3 = Color3.fromRGB(255,255,255)

    local presetList = Instance.new("ScrollingFrame", popup)
    presetList.Position = UDim2.new(0.07,0,0.72,0)
    presetList.Size = UDim2.new(0.86,0,0.22,0)
    presetList.BackgroundTransparency = 1
    presetList.ScrollBarThickness = 6
    local pLayout = Instance.new("UIListLayout", presetList)
    pLayout.Padding = UDim.new(0,4)

    local function refreshList()
        for _, v in pairs(presetList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        local s = state.savedSettings.presets or {}
        for name,_ in pairs(s) do
            local b = Instance.new("TextButton", presetList)
            b.Text = name
            b.Size = UDim2.new(1, -6, 0, 26)
            b.BackgroundColor3 = Color3.fromRGB(70,70,70)
            b.Font = Enum.Font.Gotham
            b.TextColor3 = Color3.fromRGB(255,255,255)
            createRounded(b,4)
            b.MouseButton1Click:Connect(function()
                nameBox.Text = name
            end)
        end
    end
    refreshList()

    saveBtn.MouseButton1Click:Connect(function()
        local name = nameBox.Text:match("%S+") or "preset"
        state.savedSettings.presets = state.savedSettings.presets or {}
        state.savedSettings.presets[name] = {
            WalkSpeed = Player.Character and (Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.WalkSpeed),
            JumpPower = Player.Character and (Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.JumpPower)
        }
        saveSettings(state.savedSettings)
        refreshList()
    end)

    loadBtn.MouseButton1Click:Connect(function()
        local name = nameBox.Text:match("%S+")
        if name and state.savedSettings.presets and state.savedSettings.presets[name] then
            local p = state.savedSettings.presets[name]
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                if p.WalkSpeed then Player.Character.Humanoid.WalkSpeed = p.WalkSpeed end
                if p.JumpPower then Player.Character.Humanoid.JumpPower = p.JumpPower end
            end
        end
    end)
end)

-- ========== 2) Movimento / personagem ==========
-- 10. WalkSpeed
makeScriptButton(pageMovement, "Ajustar WalkSpeed (só local)", function()
    local popup = createPopup(320,140, "WalkSpeed (local)")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "WalkSpeed (ex.: 16)"
    tb.Size = UDim2.new(0.8,0,0,36)
    tb.Position = UDim2.new(0.1,0,0.2,0)
    tb.Font = Enum.Font.Gotham

    local btn = Instance.new("TextButton", popup)
    btn.Text = "Aplicar"
    btn.Size = UDim2.new(0.8,0,0,36)
    btn.Position = UDim2.new(0.1,0,0.6,0)
    createRounded(btn,6)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.Font = Enum.Font.GothamBold
    btn.MouseButton1Click:Connect(function()
        local num = tonumber(tb.Text)
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if num and humanoid then humanoid.WalkSpeed = num end
    end)
end)

-- 11. JumpPower
makeScriptButton(pageMovement, "Ajustar JumpPower", function()
    local popup = createPopup(320,140, "JumpPower (local)")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "JumpPower (ex.: 50)"
    tb.Size = UDim2.new(0.8,0,0,36)
    tb.Position = UDim2.new(0.1,0,0.2,0)
    tb.Font = Enum.Font.Gotham
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Aplicar"
    btn.Size = UDim2.new(0.8,0,0,36)
    btn.Position = UDim2.new(0.1,0,0.6,0)
    createRounded(btn,6)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.Font = Enum.Font.GothamBold
    btn.MouseButton1Click:Connect(function()
        local num = tonumber(tb.Text)
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if num and humanoid then humanoid.JumpPower = num end
    end)
end)

-- 12. Double Jump
do
    local conn
    makeScriptButton(pageMovement, "Double Jump (toggle)", function()
        state.doubleJumpEnabled = not state.doubleJumpEnabled
        if state.doubleJumpEnabled then
            -- Connect once
            if conn == nil then
                conn = Player.CharacterAdded:Connect(function(char)
                    local humanoid = char:WaitForChild("Humanoid")
                    state.doubleJumpCount = 0
                    humanoid.Jumping:Connect(function(active)
                        if active and state.doubleJumpEnabled then
                            if state.doubleJumpCount < 1 then
                                state.doubleJumpCount = state.doubleJumpCount + 1
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                                humanoid.JumpPower = humanoid.JumpPower -- keep
                            end
                        end
                    end)
                    humanoid.StateChanged:Connect(function(old, new)
                        if new == Enum.HumanoidStateType.Landed then
                            state.doubleJumpCount = 0
                        end
                    end)
                end)
            end
            -- Also enable on current character
            local char = Player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    state.doubleJumpCount = 0
                    humanoid.Jumping:Connect(function(active)
                        if active and state.doubleJumpEnabled then
                            if state.doubleJumpCount < 1 then
                                state.doubleJumpCount = state.doubleJumpCount + 1
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end)
                    humanoid.StateChanged:Connect(function(old,new)
                        if new == Enum.HumanoidStateType.Landed then state.doubleJumpCount = 0 end
                    end)
                end
            end
        else
            -- disabling is handled by flag; connections stay but are inert
        end
        -- quick notify
        local p = Instance.new("TextLabel", screenGui)
        p.Text = "DoubleJump: "..tostring(state.doubleJumpEnabled)
        p.Size = UDim2.new(0,220,0,28)
        p.Position = UDim2.new(0.5,-110,0.1,0)
        p.BackgroundColor3 = Color3.fromRGB(40,40,40)
        p.TextColor3 = Color3.fromRGB(255,255,255)
        p.Font = Enum.Font.GothamBold
        createRounded(p,6)
        delay(1.2, function() p:Destroy() end)
    end)
end

-- 13. Super Jump (one-click preset)
addScript(pageMovement, "Super Jump (preset)", function()
    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = 200
        local p = Instance.new("TextLabel", screenGui)
        p.Text = "Super Jump enabled (200)"
        p.Size = UDim2.new(0,240,0,28)
        p.Position = UDim2.new(0.5,-120,0.12,0)
        p.BackgroundColor3 = Color3.fromRGB(40,40,40)
        p.TextColor3 = Color3.fromRGB(255,255,255)
        p.Font = Enum.Font.GothamBold
        createRounded(p,6)
        delay(1.2, function() p:Destroy() end)
    end
end)

-- 14. Fly avanzado (local)
do
    local flying = false
    local bodyVel, bodyGyro
    local speed = 60
    addScript(pageMovement, "Fly Avançado (toggle)", function()
        flying = not flying
        local char = Player.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if flying then
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyVel.Velocity = Vector3.new(0,0,0)
            bodyVel.Parent = root
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bodyGyro.CFrame = root.CFrame
            bodyGyro.Parent = root
        else
            if bodyVel then bodyVel:Destroy() bodyVel=nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro=nil end
        end
    end)

    RunService.RenderStepped:Connect(function()
        if flying and bodyVel and bodyGyro and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local root = Player.Character.HumanoidRootPart
            local cam = workspace.CurrentCamera
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
            if move.Magnitude > 0 then
                bodyVel.Velocity = move.Unit * speed
            else
                bodyVel.Velocity = Vector3.new(0,0,0)
            end
            bodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
        end
    end)
end

-- 15. Glide / slow-fall
addScript(pageMovement, "Glide / Slow-Fall (toggle)", function()
    local char = Player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    local toggled = false
    toggled = true
    local oldGravity = workspace.Gravity
    workspace.Gravity = 30 -- softer gravity locally
    local p = Instance.new("TextLabel", screenGui)
    p.Text = "Glide active (local)"
    p.Size = UDim2.new(0,220,0,28)
    p.Position = UDim2.new(0.5,-110,0.12,0)
    p.BackgroundColor3 = Color3.fromRGB(40,40,40)
    p.TextColor3 = Color3.fromRGB(255,255,255)
    p.Font = Enum.Font.GothamBold
    createRounded(p,6)
    delay(2,function()
        p:Destroy()
        workspace.Gravity = oldGravity
    end)
end)

-- 16. Sprint / Nitro (local toggle)
do
    local sprinting = false
    addScript(pageMovement, "Sprint (toggle)", function()
        sprinting = not sprinting
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            if sprinting then humanoid.WalkSpeed = (humanoid.WalkSpeed or 16) * 1.8
            else humanoid.WalkSpeed = 16 end
        end
    end)
end

-- 17. Anti-queda (visual local)
addScript(pageMovement, "Anti-queda (local visual)", function()
    -- This will create a soft landing by detecting high downward velocity and applying upward impulse locally (visual)
    local char = Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not root or not root.Parent then conn:Disconnect() return end
        local velY = root.Velocity.Y
        if velY < -80 then
            -- apply a tiny upwardBodyVelocity clamped to be client-only visual
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(0,1e4,0)
            bv.Velocity = Vector3.new(0,40,0)
            bv.P = 5000
            bv.Parent = root
            game:GetService("Debris"):AddItem(bv, 0.18)
        end
    end)
    -- notification
    local p = Instance.new("TextLabel", screenGui)
    p.Text = "Anti-queda (local) ativo por alguns segundos"
    p.Size = UDim2.new(0,300,0,28)
    p.Position = UDim2.new(0.5,-150,0.12,0)
    p.BackgroundColor3 = Color3.fromRGB(40,40,40)
    p.TextColor3 = Color3.fromRGB(255,255,255)
    createRounded(p,6)
    delay(3, function() p:Destroy(); if conn then conn:Disconnect() end end)
end)

-- 18. Resetar personagem (local)
addScript(pageMovement, "Resetar personagem", function()
    local char = Player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(0,5,0)
        end
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- ========== 3) Física / ambiente ==========
-- 19. Ajustar gravidade (local)
addScript(pagePhysics, "Alterar Gravidade (local)", function()
    local popup = createPopup(340,140, "Alterar Gravidade (local visual)")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Valor de gravidade (ex.: 196)"
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.25,0)
    tb.Font = Enum.Font.Gotham
    createRounded(tb,6)
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Aplicar"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.62,0)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.Font = Enum.Font.GothamBold
    createRounded(btn,6)
    btn.MouseButton1Click:Connect(function()
        local val = tonumber(tb.Text)
        if val then
            workspace.Gravity = val
        end
    end)
end)

-- 20. Ajustar friction/density (local) - applied to player's parts
addScript(pagePhysics, "Ajustar Friction (local no personagem)", function()
    local popup = createPopup(340,160, "Friction no personagem")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Friction (ex.: 0.3)"
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.18,0)
    tb.Font = Enum.Font.Gotham
    createRounded(tb,6)
    local apply = Instance.new("TextButton", popup)
    apply.Text = "Aplicar"
    apply.Size = UDim2.new(0.86,0,0,36)
    apply.Position = UDim2.new(0.07,0,0.6,0)
    apply.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(apply,6)
    apply.MouseButton1Click:Connect(function()
        local num = tonumber(tb.Text)
        if not num then return end
        local char = Player.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CustomPhysicalProperties = PhysicalProperties.new(num, part.CustomPhysicalProperties and part.CustomPhysicalProperties.FrictionWeight or 1, 0.7)
            end
        end
    end)
end)

-- 21. Noclip toggle (local)
do
    local noclipConn
    local toggled = false
    addScript(pagePhysics, "Noclip (toggle, local)", function()
        toggled = not toggled
        if toggled then
            noclipConn = RunService.Stepped:Connect(function()
                local char = Player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() noclipConn=nil end
            local char = Player.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end)
end

-- 22. Alterar velocidade de queda (terminal velocity local)
addScript(pagePhysics, "Velocidade de Queda (limit)", function()
    local popup = createPopup(360,140, "Limitar velocidade de queda")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Vel max (ex.: -80)"
    tb.Size = UDim2.new(0.86,0,0,34)
    tb.Position = UDim2.new(0.07,0,0.22,0)
    tb.Font = Enum.Font.Gotham
    createRounded(tb,6)
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Aplicar"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.62,0)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(btn,6)
    local conn
    btn.MouseButton1Click:Connect(function()
        if conn then conn:Disconnect() end
        local val = tonumber(tb.Text)
        if not val then return end
        conn = RunService.Heartbeat:Connect(function()
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                if root.Velocity.Y < val then
                    root.Velocity = Vector3.new(root.Velocity.X, val, root.Velocity.Z)
                end
            end
        end)
    end)
end)

-- ========== 4) Câmera / visão / observação ==========
-- 23. Lista de jogadores (observação) & basic buttons (view/follow/highlight)
makeScriptButton(pageCamera, "Players (lista & observação)", function()
    local popup = createPopup(520,360, "Players — Observação (local)")
    local list = Instance.new("ScrollingFrame", popup)
    list.Size = UDim2.new(0.48, -12, 0.85, 0)
    list.Position = UDim2.new(0.02,0,0.12,0)
    list.BackgroundTransparency = 1
    list.ScrollBarThickness = 8
    createRounded(list,6)
    local lLayout = Instance.new("UIListLayout", list)
    lLayout.Padding = UDim.new(0,6)
    local infoLabel = Instance.new("TextLabel", popup)
    infoLabel.Size = UDim2.new(0.48,0,0.85,0)
    infoLabel.Position = UDim2.new(0.5,6,0.12,0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextWrapped = true
    infoLabel.Text = "Selecione um jogador à esquerda"
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 14
    infoLabel.TextColor3 = Color3.fromRGB(240,240,240)

    local function refresh()
        for _, v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then
                local b = Instance.new("TextButton", list)
                b.Size = UDim2.new(1,-8,0,34)
                b.BackgroundColor3 = Color3.fromRGB(60,60,62)
                b.Font = Enum.Font.GothamBold
                b.Text = plr.Name
                b.TextColor3 = Color3.fromRGB(255,255,255)
                createRounded(b,6)
                b.MouseButton1Click:Connect(function()
                    -- show options for plr
                    infoLabel.Text = "Player: "..plr.Name.."\nUserId: "..tostring(plr.UserId)
                    local char = plr.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        infoLabel.Text = infoLabel.Text .. "\nPosition: "..tostring(char.HumanoidRootPart.Position)
                    end
                    -- create action buttons
                    -- View
                    local viewBtn = Instance.new("TextButton", infoLabel)
                    viewBtn.Text = "Ver Visão (local)"
                    viewBtn.Size = UDim2.new(0.95,0,0,34)
                    viewBtn.Position = UDim2.new(0.025,0,0.55,0)
                    viewBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
                    createRounded(viewBtn,6)
                    viewBtn.Font = Enum.Font.GothamBold
                    viewBtn.TextColor3 = Color3.fromRGB(255,255,255)

                    viewBtn.MouseButton1Click:Connect(function()
                        local cam = workspace.CurrentCamera
                        local targetHum = plr.Character and plr.Character:FindFirstChild("Humanoid")
                        if targetHum then
                            cam.CameraSubject = targetHum
                        end
                    end)

                    -- Follow (camera)
                    local followBtn = Instance.new("TextButton", infoLabel)
                    followBtn.Text = "Seguir (local)"
                    followBtn.Size = UDim2.new(0.95,0,0,34)
                    followBtn.Position = UDim2.new(0.025,0,0.7,0)
                    followBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
                    createRounded(followBtn,6)
                    followBtn.Font = Enum.Font.GothamBold
                    followBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    local followConn
                    followBtn.MouseButton1Click:Connect(function()
                        if followConn then followConn:Disconnect(); followConn=nil; followBtn.Text = "Seguir (local)"; return end
                        local cam = workspace.CurrentCamera
                        followBtn.Text = "Parar (local)"
                        followConn = RunService.RenderStepped:Connect(function()
                            local char = plr.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local hrp = char.HumanoidRootPart
                                cam.CFrame = hrp.CFrame * CFrame.new(0,5,10)
                            end
                        end)
                    end)

                    -- Highlight (local only)
                    local highBtn = Instance.new("TextButton", infoLabel)
                    highBtn.Text = "Highlight (local)"
                    highBtn.Size = UDim2.new(0.95,0,0,34)
                    highBtn.Position = UDim2.new(0.025,0,0.85,0)
                    highBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
                    createRounded(highBtn,6)
                    highBtn.Font = Enum.Font.GothamBold
                    highBtn.TextColor3 = Color3.fromRGB(255,255,255)
                    highBtn.MouseButton1Click:Connect(function()
                        local char = plr.Character
                        if not char then return end
                        local h = Instance.new("Highlight")
                        h.Name = "DVZIN_Highlight_"..plr.Name
                        h.Adornee = char
                        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        h.Parent = workspace
                        delay(6, function() if h and h.Parent then h:Destroy() end end)
                    end)
                end)
            end
        end
    end
    refresh()
    Players.PlayerAdded:Connect(refresh)
    Players.PlayerRemoving:Connect(refresh)
end)

-- 24. Ver visão do jogador (explicit button)
addScript(pageCamera, "Freecam (toggle)", function()
    state.freecam.enabled = not state.freecam.enabled
    local cam = workspace.CurrentCamera
    if state.freecam.enabled then
        -- initialize camera position at current camera
        state.freecam.cf = cam.CFrame
        cam.CameraType = Enum.CameraType.Scriptable
        local note = Instance.new("TextLabel", screenGui)
        note.Text = "Freecam ativada (WASD, QE para vertical). Pressione F para sair."
        note.Size = UDim2.new(0,420,0,28)
        note.Position = UDim2.new(0.5,-210,0.06,0)
        note.BackgroundColor3 = Color3.fromRGB(40,40,40)
        createRounded(note,6)
        delay(2.5, function() if note and note.Parent then note:Destroy() end end)
    else
        cam.CameraType = Enum.CameraType.Custom
    end
end)

-- Freecam movement handler
do
    local speed = 80
    local rot = Vector2.new()
    local enabled = false
    RunService.RenderStepped:Connect(function(dt)
        if state.freecam.enabled then
            enabled = true
            local cam = workspace.CurrentCamera
            local cf = cam.CFrame
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cf.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cf.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - Vector3.new(0,1,0) end
            cam.CFrame = cam.CFrame + move * speed * dt
        else
            enabled = false
        end
    end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.F and state.freecam.enabled then
            state.freecam.enabled = false
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        end
    end)
end

-- ========== 5) Visual / Efeitos ==========
-- 31. Glow / Highlight no próprio personagem
addScript(pageVisual, "Glow / Highlight no player", function()
    local char = Player.Character
    if not char then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "DVZIN_MyHighlight"
    highlight.Adornee = char
    highlight.Parent = workspace
    highlight.OutlineTransparency = 0.6
    highlight.FillTransparency = 0.75
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    delay(10, function() if highlight and highlight.Parent then highlight:Destroy() end end)
end)

-- 32. Trail local on humanoid root
addScript(pageVisual, "Trail (attach to HumanoidRootPart)", function()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local attachment0 = Instance.new("Attachment", hrp)
    local attachment1 = Instance.new("Attachment", hrp)
    attachment0.Position = Vector3.new(0,0.5,0)
    local trail = Instance.new("Trail", hrp)
    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Lifetime = 0.5
    trail.Transparency = NumberSequence.new(0.2)
    trail.Color = ColorSequence.new(Color3.fromRGB(0,160,255))
    game:GetService("Debris"):AddItem(trail, 8)
end)

-- 33. Spawn particles around player
addScript(pageVisual, "Particles around player", function()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local emitterPart = Instance.new("Part", workspace)
    emitterPart.Size = Vector3.new(1,1,1)
    emitterPart.Transparency = 1
    emitterPart.Anchored = true
    emitterPart.CFrame = hrp.CFrame
    local ps = Instance.new("ParticleEmitter", emitterPart)
    ps.Texture = "rbxassetid://241594314" -- generic spark
    ps.Speed = NumberRange.new(2,6)
    ps.Rate = 80
    ps.Lifetime = NumberRange.new(0.6,1.2)
    ps.Size = NumberSequence.new{NumberSequenceKeypoint.new(0,0.6), NumberSequenceKeypoint.new(1,0)}
    game:GetService("Debris"):AddItem(emitterPart, 5)
end)

-- 34. Explosion visual local
addScript(pageVisual, "Explosão visual (local)", function()
    local char = Player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local boom = Instance.new("Part", workspace)
    boom.Size = Vector3.new(1,1,1)
    boom.Anchored = true
    boom.Transparency = 1
    boom.CFrame = hrp.CFrame
    local e = Instance.new("ParticleEmitter", boom)
    e.Texture = "rbxassetid://243660676"
    e.Speed = NumberRange.new(10,40)
    e.Rate = 0
    e:Emit(150)
    game:GetService("Debris"):AddItem(boom, 2)
end)

-- 35. Screen flash / blur local
addScript(pageVisual, "Screen flash (local)", function()
    local flash = Instance.new("Frame", screenGui)
    flash.Size = UDim2.new(1,0,1,0)
    flash.BackgroundColor3 = Color3.fromRGB(255,255,255)
    flash.ZIndex = 1000
    flash.BackgroundTransparency = 1
    flash.Visible = true
    TweenService:Create(flash, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
    delay(0.12, function()
        TweenService:Create(flash, TweenInfo.new(0.6), {BackgroundTransparency = 1}):Play()
        delay(0.7, function() if flash and flash.Parent then flash:Destroy() end end)
    end)
end)

-- 36. Alterar cor de roupas localmente (attempts to change character parts color)
addScript(pageVisual, "Colorize character (local)", function()
    local popup = createPopup(360,150, "Colorize (local)")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Hex code (e.g. FF0000) or 'random'"
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.22,0)
    tb.Font = Enum.Font.Gotham
    createRounded(tb,6)
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Aplicar"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.62,0)
    createRounded(btn,6)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.Font = Enum.Font.GothamBold
    btn.MouseButton1Click:Connect(function()
        local color = tb.Text
        local col
        if color:lower() == "random" then
            col = Color3.fromHSV(math.random(), 0.8, 0.9)
        else
            local hex = color:match("%x+")
            if hex and #hex==6 then
                local r = tonumber(hex:sub(1,2),16)/255
                local g = tonumber(hex:sub(3,4),16)/255
                local b = tonumber(hex:sub(5,6),16)/255
                col = Color3.new(r,g,b)
            end
        end
        if col then
            local char = Player.Character
            if not char then return end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = col
                elseif part:IsA("Accessory") and part:FindFirstChildWhichIsA("BasePart") then
                    for _, bp in pairs(part:GetDescendants()) do
                        if bp:IsA("BasePart") then bp.Color = col end
                    end
                end
            end
        end
    end)
end)

-- ========== 6) ESP / Debug Visual ==========
-- 37/38 - ESP boxes and labels (client-only)
do
    local espEnabled = false
    local espObjs = {}
    addScript(pageVisual, "ESP Boxes (toggle, client-only)", function()
        espEnabled = not espEnabled
        if espEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local h = Instance.new("Highlight")
                    h.Adornee = plr.Character
                    h.Parent = workspace
                    h.Name = "DVZIN_ESP_"..plr.Name
                    table.insert(espObjs, h)
                end
            end
            -- watch for new players
            Players.PlayerAdded:Connect(function(plr)
                if espEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local h = Instance.new("Highlight")
                    h.Adornee = plr.Character
                    h.Parent = workspace
                    h.Name = "DVZIN_ESP_"..plr.Name
                    table.insert(espObjs, h)
                end
            end)
        else
            for _, h in ipairs(espObjs) do if h and h.Parent then h:Destroy() end end
            espObjs = {}
        end
    end)
end

-- ========== 7) Audio ==========
-- 40. Play local sound
addScript(pageAudio, "Tocar som local (ID)", function()
    local popup = createPopup(380,160, "Tocar som local")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "rbxassetid://<ID>"
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.18,0)
    tb.Font = Enum.Font.Gotham
    createRounded(tb,6)
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Tocar"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.62,0)
    createRounded(btn,6)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.Font = Enum.Font.GothamBold
    btn.MouseButton1Click:Connect(function()
        local id = tb.Text:match("(%d+)")
        if id then
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://"..id
            s.Parent = workspace.CurrentCamera
            s.Volume = 1
            s:Play()
            game:GetService("Debris"):AddItem(s, 10)
        end
    end)
end)

-- 41. Loop sound local with control
addScript(pageAudio, "Loop sound local (ID)", function()
    local popup = createPopup(380,150, "Loop sound local")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "rbxassetid://<ID>"
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.18,0)
    tb.Font = Enum.Font.Gotham
    createRounded(tb,6)

    local startBtn = Instance.new("TextButton", popup)
    startBtn.Text = "Start Loop"
    startBtn.Size = UDim2.new(0.42,0,0,36)
    startBtn.Position = UDim2.new(0.07,0,0.62,0)
    startBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(startBtn,6)

    local stopBtn = Instance.new("TextButton", popup)
    stopBtn.Text = "Stop All"
    stopBtn.Size = UDim2.new(0.42,0,0,36)
    stopBtn.Position = UDim2.new(0.51,0,0.62,0)
    stopBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
    createRounded(stopBtn,6)

    startBtn.MouseButton1Click:Connect(function()
        local id = tb.Text:match("(%d+)")
        if id then
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://"..id
            s.Looped = true
            s.Volume = 0.8
            s.Parent = workspace.CurrentCamera
            s:Play()
            table.insert(state.sounds, s)
        end
    end)
    stopBtn.MouseButton1Click:Connect(function()
        for _, s in ipairs(state.sounds) do
            if s and s.Parent then s:Stop(); s:Destroy() end
        end
        state.sounds = {}
    end)
end)

-- ========== 8) Props / spawn client-side ==========
-- 43. Spawn prop local (clone from ReplicatedStorage if exists)
addScript(pageProps, "Spawn prop local (from ReplicatedStorage)", function()
    local popup = createPopup(420,160, "Spawn prop (local)")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Nome do modelo em ReplicatedStorage"
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.18,0)
    tb.Font = Enum.Font.Gotham
    createRounded(tb,6)
    local spawnBtn = Instance.new("TextButton", popup)
    spawnBtn.Text = "Spawnar local"
    spawnBtn.Size = UDim2.new(0.86,0,0,36)
    spawnBtn.Position = UDim2.new(0.07,0,0.62,0)
    spawnBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(spawnBtn,6)
    spawnBtn.MouseButton1Click:Connect(function()
        local name = tb.Text:match("%S+")
        if not name then return end
        local template = ReplicatedStorage:FindFirstChild(name)
        if template and template:IsA("Model") then
            local clone = template:Clone()
            clone.Parent = workspace
            clone:MoveTo((Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position or Vector3.new()) + Vector3.new(0,3,0))
            table.insert(state.localProps, clone)
            -- ensure cleanup later
        end
    end)
end)

-- 44. Clone model local
addScript(pageProps, "Clone local selected model", function()
    local popup = createPopup(420,160, "Clonar instância local")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Nome do objeto no Workspace (ex.: Tree)"
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.18,0)
    tb.Font = Enum.Font.Gotham
    createRounded(tb,6)

    local btn = Instance.new("TextButton", popup)
    btn.Text = "Clonar"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.62,0)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(btn,6)
    btn.MouseButton1Click:Connect(function()
        local name = tb.Text:match("%S+")
        if not name then return end
        local target = workspace:FindFirstChild(name, true)
        if target then
            local clone = target:Clone()
            clone.Parent = workspace
            clone:MoveTo((Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position or Vector3.new()) + Vector3.new(0,3,0))
            table.insert(state.localProps, clone)
        end
    end)
end)

-- 45. Teleport prop locally (pick nearest local prop)
addScript(pageProps, "Teleport local prop to you", function()
    local popup = createPopup(360,140, "Teleport prop local")
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Teleport nearest prop to player"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.35,0)
    createRounded(btn,6)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.MouseButton1Click:Connect(function()
        local pos = (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position) or Vector3.new()
        local nearest, dist = nil, math.huge
        for _, prop in ipairs(state.localProps) do
            if prop.PrimaryPart then
                local d = (prop.PrimaryPart.Position - pos).Magnitude
                if d < dist then dist = d; nearest = prop end
            end
        end
        if nearest and nearest.PrimaryPart then
            nearest:MoveTo(pos + Vector3.new(0,3,0))
        end
    end)
end)

-- 46. Alterar escala de props (local)
addScript(pageProps, "Escalar props (local)", function()
    local popup = createPopup(380,140, "Escalar local")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Escala (ex.: 1.5)"
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.18,0)
    createRounded(tb,6)
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Aplicar na primeira prop local"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.62,0)
    createRounded(btn,6)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.MouseButton1Click:Connect(function()
        local scale = tonumber(tb.Text)
        if not scale then return end
        local prop = state.localProps[1]
        if prop then
            for _, part in pairs(prop:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * scale
                end
            end
        end
    end)
end)

-- ========== 9) Utilitários / Debug ==========
-- 47. FPS overlay
do
    local running = false
    addScript(pageTools, "FPS overlay (toggle)", function()
        running = not running
        if running then
            local label = Instance.new("TextLabel", screenGui)
            label.Name = "DVZIN_FPS"
            label.Size = UDim2.new(0,120,0,28)
            label.Position = UDim2.new(0.02,0,0.02,0)
            label.BackgroundColor3 = Color3.fromRGB(30,30,30)
            label.TextColor3 = Color3.fromRGB(255,255,255)
            label.Font = Enum.Font.GothamBold
            createRounded(label,6)
            local last = tick()
            local fps = 0
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local now = tick()
                fps = math.floor(1/(now-last))
                last = now
                label.Text = "FPS: "..tostring(fps)
            end)
            -- toggle off will disconnect; store connection in label
            label:SetAttribute("DVZIN_CONN", true)
            -- store connection
            state.fpsConn = conn
        else
            local label = screenGui:FindFirstChild("DVZIN_FPS")
            if label then label:Destroy() end
            if state.fpsConn then state.fpsConn:Disconnect(); state.fpsConn = nil end
        end
    end)
end

-- 48. Show position coords
addScript(pageTools, "Mostrar posição (coords)", function()
    local popup = createPopup(300,120, "Posição atual")
    local lbl = Instance.new("TextLabel", popup)
    lbl.Size = UDim2.new(0.9,0,0.7,0)
    lbl.Position = UDim2.new(0.05,0,0.15,0)
    lbl.TextWrapped = true
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = char.HumanoidRootPart.Position
            lbl.Text = ("X: %.2f\nY: %.2f\nZ: %.2f"):format(pos.X, pos.Y, pos.Z)
        end
    end)
    popup.AncestryChanged:Connect(function()
        if not popup.Parent and conn then conn:Disconnect() end
    end)
end)

-- 49. Ping estimation (simple)
addScript(pageTools, "Ping estimado (ms)", function()
    local popup = createPopup(300,120, "Ping estimado")
    local lbl = Instance.new("TextLabel", popup)
    lbl.Size = UDim2.new(0.9,0,0.7,0)
    lbl.Position = UDim2.new(0.05,0,0.15,0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    local last = tick()
    local function update()
        local now = tick()
        lbl.Text = ("Time now: %.2f\n(estimativa local)"):format(now)
    end
    local conn = RunService.Heartbeat:Connect(update)
    popup.AncestryChanged:Connect(function()
        if not popup.Parent and conn then conn:Disconnect() end
    end)
end)

-- 50. Raycast helper (click to inspect)
addScript(pageTools, "Raycast helper (clique)", function()
    local popup = createPopup(380,140, "Raycast Helper")
    local lbl = Instance.new("TextLabel", popup)
    lbl.Size = UDim2.new(0.86,0,0.6,0)
    lbl.Position = UDim2.new(0.07,0,0.18,0)
    lbl.Text = "Clique em alguma parte do mundo para ver info (ESC para fechar)"
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    local conn
    conn = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = Players.LocalPlayer:GetMouse()
            local target = mouse.Target
            if target then
                lbl.Text = "Target: "..tostring(target.Name) .. "\nMaterial: "..tostring(target.Material) .. "\nSize: "..tostring(target.Size)
            else
                lbl.Text = "Nada detectado"
            end
        end
    end)
    popup.AncestryChanged:Connect(function()
        if not popup.Parent and conn then conn:Disconnect() end
    end)
end)

-- 51. Part inspector: click to highlight properties
addScript(pageTools, "Part inspector (clique)", function()
    local popup = createPopup(420,160, "Part Inspector")
    local lbl = Instance.new("TextLabel", popup)
    lbl.Size = UDim2.new(0.86,0,0.6,0)
    lbl.Position = UDim2.new(0.07,0,0.18,0)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.Text = "Clique em uma peça para inspecionar"
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local target = Players.LocalPlayer:GetMouse().Target
            if target and target:IsA("BasePart") then
                lbl.Text = ("Name: %s\nSize: %s\nColor: %s\nCanCollide: %s\nAnchored: %s"):format(
                    target.Name, tostring(target.Size), tostring(target.Color), tostring(target.CanCollide), tostring(target.Anchored)
                )
                -- temporary highlight
                local h = Instance.new("SelectionBox", workspace)
                h.Adornee = target
                game:GetService("Debris"):AddItem(h, 2)
            end
        end
    end)
    popup.AncestryChanged:Connect(function()
        if not popup.Parent and connection then connection:Disconnect() end
    end)
end)

-- 52. Safe mode (simple: clamps bodyforces)
addScript(pageTools, "Safe Mode (clamp local forces)", function()
    -- This is a simple visual/clamp for extreme body forces on local character: it removes BodyVelocity/BodyForce parented to HRP
    local popup = createPopup(380,120, "Safe Mode (local)")
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Limpar BodyForces locais"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.3,0)
    btn.BackgroundColor3 = Color3.fromRGB(180,60,60)
    createRounded(btn,6)
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(function()
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            for _, c in pairs(char.HumanoidRootPart:GetChildren()) do
                if c:IsA("BodyVelocity") or c:IsA("BodyForce") or c:IsA("BodyGyro") or c:IsA("VectorForce") then
                    c:Destroy()
                end
            end
        end
    end)
end)

-- 53. Undo (very simple: destroy last local prop/effect)
addScript(pageTools, "Undo last local prop/effect", function()
    local last = table.remove(state.localProps)
    if last and last.Parent then last:Destroy() end
    local p = Instance.new("TextLabel", screenGui)
    p.Text = "Undo local prop"
    p.Size = UDim2.new(0,180,0,28)
    p.Position = UDim2.new(0.5,-90,0.08,0)
    createRounded(p,6)
    delay(1, function() if p and p.Parent then p:Destroy() end end)
end)

-- ========== 10) UI / Chat / Messages ==========
makeScriptButton(pageInterface, "HUD / Notificações", function()
    local popup = createPopup(360,160, "Notificação local")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Mensagem..."
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.18,0)
    createRounded(tb,6)
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Mostrar HUD"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.62,0)
    createRounded(btn,6)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.MouseButton1Click:Connect(function()
        local lbl = Instance.new("TextLabel", screenGui)
        lbl.Text = tb.Text
        lbl.Size = UDim2.new(0,420,0,36)
        lbl.Position = UDim2.new(0.5,-210,0.9,0)
        lbl.BackgroundColor3 = Color3.fromRGB(30,30,30)
        lbl.TextColor3 = Color3.fromRGB(255,255,255)
        lbl.Font = Enum.Font.GothamBold
        createRounded(lbl,6)
        delay(3, function() if lbl and lbl.Parent then lbl:Destroy() end end)
    end)
end)

-- ========== 11) Anchors / Teleport local ==========
do
    addScript(pageTools, "Salvar anchor (local)", function()
        local popup = createPopup(360,140, "Salvar anchor local")
        local tb = Instance.new("TextBox", popup)
        tb.PlaceholderText = "Nome do anchor..."
        tb.Size = UDim2.new(0.86,0,0,36)
        tb.Position = UDim2.new(0.07,0,0.18,0)
        createRounded(tb,6)
        local btn = Instance.new("TextButton", popup)
        btn.Text = "Salvar anchor"
        btn.Size = UDim2.new(0.86,0,0,36)
        btn.Position = UDim2.new(0.07,0,0.62,0)
        btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
        createRounded(btn,6)
        btn.MouseButton1Click:Connect(function()
            local name = tb.Text:match("%S+")
            if not name then return end
            local pos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.Position
            if pos then
                state.anchors[name] = pos
                state.savedSettings.anchors = state.savedSettings.anchors or {}
                state.savedSettings.anchors[name] = {x=pos.X,y=pos.Y,z=pos.Z}
                saveSettings(state.savedSettings)
            end
        end)
    end)

    addScript(pageTools, "Teleportar para anchor (local)", function()
        local popup = createPopup(360,160, "Teleport anchors")
        local list = Instance.new("ScrollingFrame", popup)
        list.Size = UDim2.new(0.86,0,0.7,0)
        list.Position = UDim2.new(0.07,0,0.18,0)
        list.BackgroundTransparency = 1
        local layout = Instance.new("UIListLayout", list)
        layout.Padding = UDim.new(0,6)
        for k,v in pairs(state.savedSettings.anchors or {}) do
            local btn = Instance.new("TextButton", list)
            btn.Text = k
            btn.Size = UDim2.new(1,0,0,30)
            btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            btn.Font = Enum.Font.Gotham
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            createRounded(btn,6)
            btn.MouseButton1Click:Connect(function()
                local pos = v
                if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(pos.x,pos.y,pos.z)
                end
            end)
        end
    end)
end

-- ========== 12) Accessibility / Layout ==========
makeScriptButton(pageInterface, "Ajustar fonte / contraste (acessibilidade)", function()
    local popup = createPopup(380,160, "Acessibilidade")
    local lbl = Instance.new("TextLabel", popup)
    lbl.Text = "Mudar fonte/contraste na GUI"
    lbl.Size = UDim2.new(0.86,0,0,30)
    lbl.Position = UDim2.new(0.07,0,0.12,0)
    lbl.BackgroundTransparency = 1

    local bigBtn = Instance.new("TextButton", popup)
    bigBtn.Text = "Fonte maior"
    bigBtn.Size = UDim2.new(0.42,0,0,34)
    bigBtn.Position = UDim2.new(0.07,0,0.52,0)
    bigBtn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(bigBtn,6)
    bigBtn.MouseButton1Click:Connect(function()
        for _, txt in pairs(mainFrame:GetDescendants()) do
            if txt:IsA("TextLabel") or txt:IsA("TextButton") or txt:IsA("TextBox") then
                txt.TextSize = (txt.TextSize or 14) + 2
            end
        end
    end)
end)

-- ========== 13) Profiling / Profiler ==========
addScript(pageTools, "Profiler simples (executar função)", function()
    local popup = createPopup(420,160, "Profiler simples")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Digite 'task.wait(0.01)' ou função..."
    tb.Size = UDim2.new(0.86,0,0,36)
    tb.Position = UDim2.new(0.07,0,0.18,0)
    createRounded(tb,6)
    local btn = Instance.new("TextButton", popup)
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.62,0)
    btn.Text = "Executar temporizar"
    createRounded(btn,6)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    btn.MouseButton1Click:Connect(function()
        local code = tb.Text
        local func, err = loadstring("return function() "..code.." end")
        if func then
            local f = func()
            local t0 = tick()
            pcall(f)
            local t1 = tick()
            local lbl = Instance.new("TextLabel", screenGui)
            lbl.Text = ("Tempo: %.4f s"):format(t1-t0)
            lbl.Size = UDim2.new(0,200,0,28)
            lbl.Position = UDim2.new(0.5,-100,0.08,0)
            lbl.BackgroundColor3 = Color3.fromRGB(40,40,40)
            createRounded(lbl,6)
            delay(2, function() if lbl and lbl.Parent then lbl:Destroy() end end)
        else
            warn("Erro no profiler: ", err)
        end
    end)
end)

-- ========== 14) Mobile helpers ==========
makeScriptButton(pageInterface, "Touch controls (on-screen buttons)", function()
    local popup = createPopup(420,180, "Touch controls")
    local info = Instance.new("TextLabel", popup)
    info.Text = "Esse botão irá mostrar botões grandes na tela para comandos rápidos (ex.: jump, fly)."
    info.TextWrapped = true
    info.Size = UDim2.new(0.86,0,0.6,0)
    info.Font = Enum.Font.Gotham
    local btn = Instance.new("TextButton", popup)
    btn.Text = "Criar touch buttons"
    btn.Size = UDim2.new(0.86,0,0,36)
    btn.Position = UDim2.new(0.07,0,0.65,0)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(btn,6)
    btn.MouseButton1Click:Connect(function()
        local jumpBtn = Instance.new("TextButton", screenGui)
        jumpBtn.Size = UDim2.new(0,120,0,56)
        jumpBtn.Position = UDim2.new(1,-140,0.6,0)
        jumpBtn.Text = "Jump"
        createRounded(jumpBtn,8)
        jumpBtn.BackgroundColor3 = Color3.fromRGB(0,120,220)
        jumpBtn.Font = Enum.Font.GothamBold
        jumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
        jumpBtn.MouseButton1Click:Connect(function()
            local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        game:GetService("Debris"):AddItem(jumpBtn, 30)
    end)
end)

-- ========== 15) Macros / Automations ==========
addScript(pageTools, "Macro simple (sequence)", function()
    local popup = createPopup(420,160, "Macro (sequence)")
    local tb = Instance.new("TextBox", popup)
    tb.PlaceholderText = "Comandos separados por ';' ex: WalkSpeed=30;JumpPower=100;Wait=1"
    tb.Size = UDim2.new(0.86,0,0,44)
    tb.Position = UDim2.new(0.07,0,0.12,0)
    createRounded(tb,6)
    local run = Instance.new("TextButton", popup)
    run.Text = "Executar macro"
    run.Size = UDim2.new(0.86,0,0,36)
    run.Position = UDim2.new(0.07,0,0.68,0)
    run.BackgroundColor3 = Color3.fromRGB(0,140,220)
    createRounded(run,6)
    run.MouseButton1Click:Connect(function()
        local content = tb.Text
        for cmd in content:gmatch("[^;]+") do
            local k, v = cmd:match("(%w+)%s*=%s*(.+)")
            if k and v then
                k = k:lower()
                if k == "walkspeed" then
                    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
                    if humanoid then humanoid.WalkSpeed = tonumber(v) or humanoid.WalkSpeed end
                elseif k == "jumppower" then
                    local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
                    if humanoid then humanoid.JumpPower = tonumber(v) or humanoid.JumpPower end
                elseif k == "wait" then
                    task.wait(tonumber(v) or 0.5)
                end
            end
        end
    end)
end)

-- ========== 16) Extras & cleanup ==========
-- Quick cleanup: remove all local props/effects
addScript(pageTools, "Limpar props/efeitos locais", function()
    for _, p in ipairs(state.localProps) do if p and p.Parent then p:Destroy() end end
    state.localProps = {}
    for _, s in ipairs(state.sounds) do if s and s.Parent then s:Destroy() end end
    state.sounds = {}
    for _, h in ipairs(workspace:GetChildren()) do
        if h:IsA("Highlight") and tostring(h.Name):match("^DVZIN_") then pcall(function() h:Destroy() end) end
    end
    local msg = Instance.new("TextLabel", screenGui)
    msg.Text = "Limpeza local executada"
    msg.Size = UDim2.new(0,220,0,28)
    msg.Position = UDim2.new(0.5,-110,0.08,0)
    createRounded(msg,6)
    delay(1.4, function() if msg and msg.Parent then msg:Destroy() end end)
end)

-- finalize: make Universal category visible by default
for _, child in pairs(container:GetChildren()) do if child:IsA("ScrollingFrame") then child.Visible = false end end
pageInterface.Visible = true

-- Save default settings on exit
game:BindToClose(function()
    saveSettings(state.savedSettings)
end)

print("DVZIN Developer GUI loaded (client-side).")
