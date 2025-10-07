-- DVZIN ADMIN GUI BROOKHAVEN + UNIVERSAL ~400 linhas
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- GUI base
local gui = Instance.new("ScreenGui")
gui.Name = "DVZIN_AdminGUI_BH"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

local activePopups = {}

-- Função Drag PC/celular
local function makeDraggable(frame)
	local dragging, dragStart, startPos = false, nil, nil
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

-- Função criar popup
local function createPopup(titleText,width,height)
	local popup = Instance.new("Frame")
	popup.Size = UDim2.new(0,width,0,height)
	popup.Position = UDim2.new(0.5,0,0.5,0)
	popup.AnchorPoint = Vector2.new(0.5,0.5)
	popup.BackgroundColor3 = Color3.fromRGB(50,50,50)
	popup.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,8)
	corner.Parent = popup

	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
	closeBtn.Size = UDim2.new(0,25,0,25)
	closeBtn.Position = UDim2.new(1,-30,0,5)
	closeBtn.Parent = popup
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0,5)
	closeCorner.Parent = closeBtn
	closeBtn.MouseButton1Click:Connect(function()
		popup:Destroy()
		for i,v in pairs(activePopups) do
			if v == popup then table.remove(activePopups,i) break end
		end
	end)

	makeDraggable(popup)
	table.insert(activePopups,popup)
	return popup
end

-- Função adicionar script
local function addScript(scrollFrame, scriptName, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,0,0,80)
	frame.BackgroundColor3 = Color3.fromRGB(60,60,60)
	frame.Parent = scrollFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Text = scriptName
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0.05,0,0.05,0)
	label.Size = UDim2.new(0.9,0,0,22)
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Text = "Abrir"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	btn.Size = UDim2.new(0.9,0,0,30)
	btn.Position = UDim2.new(0.05,0,0.45,0)
	btn.Parent = frame
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0,6)
	btnCorner.Parent = btn

	btn.MouseButton1Click:Connect(callback)
end

-- Criar frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,450,0,450)
mainFrame.Position = UDim2.new(0.5,0,0.5,0)
mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.Parent = gui
	mainFrame.ClipsDescendants = true
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = mainFrame
makeDraggable(mainFrame)

local title = Instance.new("TextLabel")
title.Text = "DVZIN ADMIN - BROOKHAVEN"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,15,0,10)
title.Size = UDim2.new(1,-30,0,28)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- Botão fechar GUI
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeBtn.Size = UDim2.new(0,28,0,28)
closeBtn.Position = UDim2.new(1,-36,0,10)
closeBtn.Parent = mainFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0,6)
closeCorner.Parent = closeBtn
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Botão fechar todos popups
local closeAllBtn = Instance.new("TextButton")
closeAllBtn.Text = "Fechar Popups"
closeAllBtn.Font = Enum.Font.GothamBold
closeAllBtn.TextSize = 14
closeAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeAllBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
closeAllBtn.Size = UDim2.new(0,120,0,28)
closeAllBtn.Position = UDim2.new(1,-160,0,10)
closeAllBtn.Parent = mainFrame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0,6)
btnCorner.Parent = closeAllBtn
closeAllBtn.MouseButton1Click:Connect(function()
	for _, popup in pairs(activePopups) do
		if popup and popup.Parent then popup:Destroy() end
	end
	activePopups = {}
end)

-- Sidebar
local sidebar = Instance.new("ScrollingFrame")
sidebar.Size = UDim2.new(0,160,1,-40)
sidebar.Position = UDim2.new(0,0,0,40)
sidebar.BackgroundColor3 = Color3.fromRGB(40,40,40)
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 8
sidebar.Parent = mainFrame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,8)
corner.Parent = sidebar
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = sidebar
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,10)
padding.PaddingLeft = UDim.new(0,10)
padding.PaddingRight = UDim.new(0,10)
padding.Parent = sidebar

-- Container
local container = Instance.new("Frame")
container.Size = UDim2.new(1,-170,1,-40)
container.Position = UDim2.new(0,170,0,40)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Categorias
local function createCategory(name)
	local btn = Instance.new("TextButton")
	btn.Text = name
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.Size = UDim2.new(1,-10,0,38)
	btn.Parent = sidebar
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,6)
	corner.Parent = btn
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1,0,1,0)
	scroll.Position = UDim2.new(0,0,0,0)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 8
	scroll.Visible = false
	scroll.Parent = container
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0,10)
	padding.PaddingLeft = UDim.new(0,10)
	padding.PaddingRight = UDim.new(0,10)
	padding.Parent = scroll
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
	end)
	btn.MouseButton1Click:Connect(function()
		for _, child in pairs(container:GetChildren()) do
			if child:IsA("ScrollingFrame") then child.Visible = false end
		end
		scroll.Visible = true
	end)
	return scroll
end

local universal = createCategory("Universal")
local brookhaven = createCategory("Brookhaven")

-- ======== FUNÇÕES UNIVERSAIS =========
-- Velocidade
addScript(universal,"Velocidade",function()
	local popup = createPopup("Velocidade",280,140)
	local char = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")
	local tb = Instance.new("TextBox")
	tb.PlaceholderText = "Digite a velocidade..."
	tb.Size = UDim2.new(0.8,0,0,35)
	tb.Position = UDim2.new(0.1,0,0.2,0)
	tb.BackgroundColor3 = Color3.fromRGB(60,60,60)
	tb.TextColor3 = Color3.fromRGB(255,255,255)
	tb.Parent = popup
	local btn = Instance.new("TextButton")
	btn.Text = "Aplicar"
	btn.Size = UDim2.new(0.8,0,0,35)
	btn.Position = UDim2.new(0.1,0,0.6,0)
	btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Parent = popup
	btn.MouseButton1Click:Connect(function()
		local speed = tonumber(tb.Text)
		if speed then humanoid.WalkSpeed = speed end
	end)
end)

-- Voo simples
addScript(universal,"Voo",function()
	local popup = createPopup("Voo",280,160)
	local char = Player.Character or Player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local humanoid = char:WaitForChild("Humanoid")
	local flying,speed = false,50
	local bodyVelocity,bodyGyro
	local speedBox = Instance.new("TextBox")
	speedBox.PlaceholderText = "Velocidade padrão 50"
	speedBox.Size = UDim2.new(0.8,0,0,35)
	speedBox.Position = UDim2.new(0.1,0,0.15,0)
	speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
	speedBox.TextColor3 = Color3.fromRGB(255,255,255)
	speedBox.Parent = popup
	local flyBtn = Instance.new("TextButton")
	flyBtn.Text = "Ativar Voo"
	flyBtn.Size = UDim2.new(0.8,0,0,35)
	flyBtn.Position = UDim2.new(0.1,0,0.55,0)
	flyBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	flyBtn.TextColor3 = Color3.fromRGB(255,255,255)
	flyBtn.Parent = popup

	local function startFlying()
		if flying then return end
		flying = true
		speed = tonumber(speedBox.Text) or 50
		flyBtn.Text = "Desativar Voo"
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
		bodyVelocity.Velocity = Vector3.new(0,0,0)
		bodyVelocity.Parent = root
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root
	end
	local function stopFlying()
		flying = false
		flyBtn.Text = "Ativar Voo"
		if bodyVelocity then bodyVelocity:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
	end
	flyBtn.MouseButton1Click:Connect(function()
		if flying then stopFlying() else startFlying() end
	end)
	RunService.RenderStepped:Connect(function()
		if flying and bodyVelocity and bodyGyro then
			local move = Vector3.new(0,0,0)
			local camCFrame = workspace.CurrentCamera.CFrame
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camCFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camCFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camCFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camCFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
			local touches = UserInputService:GetTouches()
			for _, t in ipairs(touches) do
				if t.Position.Y < workspace.CurrentCamera.ViewportSize.Y/2 then
					move += Vector3.new(0,1,0)
				else
					move -= Vector3.new(0,1,0)
				end
			end
			if move.Magnitude>0 then
				bodyVelocity.Velocity = move.Unit*speed
			else
				bodyVelocity.Velocity = Vector3.new(0,0,0)
			end
			bodyGyro.CFrame = CFrame.new(root.Position,root.Position+camCFrame.LookVector)
		end
	end)
end)

-- ======== FUNÇÕES BROOKHAVEN =========
-- Unban casas
addScript(brookhaven,"Unban Casas",function()
	for _,house in pairs(Workspace:GetChildren()) do
		if house:FindFirstChild("BanBox") then
			house.BanBox:Destroy()
		end
	end
end)

-- Troll spawn sons FE
addScript(brookhaven,"Troll Sons FE",function()
	for i=1,10 do
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://142376088" -- Exemplo FE
		sound.Volume = 10
		sound.Parent = Workspace
		sound:Play()
	end
end)

-- Anti sentar / anti carro
addScript(brookhaven,"Proteção Sentar/Carro",function()
	local char = Player.Character or Player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	hum.Seated:Connect(function(active)
		if active then hum.Sit = false end
	end)
end)

-- Spawn itens FE
addScript(brookhaven,"Spawn Itens FE",function()
	local popup = createPopup("Spawn Itens",300,200)
	local tb = Instance.new("TextBox")
	tb.PlaceholderText = "Digite o nome do item FE"
	tb.Size = UDim2.new(0.8,0,0,35)
	tb.Position = UDim2.new(0.1,0,0.2,0)
	tb.BackgroundColor3 = Color3.fromRGB(60,60,60)
	tb.TextColor3 = Color3.fromRGB(255,255,255)
	tb.Parent = popup
	local btn = Instance.new("TextButton")
	btn.Text = "Spawn"
	btn.Size = UDim2.new(0.8,0,0,35)
	btn.Position = UDim2.new(0.1,0,0.6,0)
	btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Parent = popup
	btn.MouseButton1Click:Connect(function()
		local itemName = tb.Text
		local item = ReplicatedStorage:FindFirstChild(itemName)
		if item then
			local clone = item:Clone()
			clone.Parent = Workspace
			clone.Position = Player.Character.HumanoidRootPart.Position + Vector3.new(0,5,0)
		end
	end)
end)

-- ⚠️ OBS: Este script é expandido, você pode continuar adicionando mais funções similares
-- para trollagens
