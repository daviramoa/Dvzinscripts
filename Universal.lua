-- DVZIN ADMIN GUI COMPACTA - FINAL
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "DVZIN_AdminGUI_Compact"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = PlayerGui

-- Função para drag PC e celular
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

-- Função criar frame principal
local function createMainFrame()
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,400,0,320)
	frame.Position = UDim2.new(0.5,0,0.5,0)
	frame.AnchorPoint = Vector2.new(0.5,0.5)
	frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
	frame.BorderSizePixel = 0
	frame.Parent = gui
	frame.ClipsDescendants = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,12)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Text = "DVZIN ADMIN"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = Color3.fromRGB(255,255,255)
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0,15,0,10)
	title.Size = UDim2.new(1,-30,0,28)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	-- Botão minimizar
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Text = "_"
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 18
	minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
	minimizeBtn.Size = UDim2.new(0,28,0,28)
	minimizeBtn.Position = UDim2.new(1,-70,0,10)
	minimizeBtn.Parent = frame
	local minCorner = Instance.new("UICorner")
	minCorner.CornerRadius = UDim.new(0,6)
	minCorner.Parent = minimizeBtn

	-- Botão fechar
	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
	closeBtn.Size = UDim2.new(0,28,0,28)
	closeBtn.Position = UDim2.new(1,-36,0,10)
	closeBtn.Parent = frame
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0,6)
	closeCorner.Parent = closeBtn
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

	makeDraggable(frame)

	return frame, minimizeBtn
end

-- Criar sidebar e container
local function createSidebar(parent)
	local sidebar = Instance.new("ScrollingFrame")
	sidebar.Size = UDim2.new(0,140,1,-40)
	sidebar.Position = UDim2.new(0,0,0,40)
	sidebar.BackgroundColor3 = Color3.fromRGB(35,35,35)
	sidebar.BorderSizePixel = 0
	sidebar.ScrollBarThickness = 8
	sidebar.Parent = parent

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

	return sidebar
end

local function createContainer(parent)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1,-150,1,-40)
	container.Position = UDim2.new(0,150,0,40)
	container.BackgroundTransparency = 1
	container.Parent = parent
	return container
end

local function createCategory(name, sidebar, container)
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
			if child:IsA("ScrollingFrame") then
				child.Visible = false
			end
		end
		scroll.Visible = true
	end)

	return scroll
end

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
	closeBtn.MouseButton1Click:Connect(function() popup:Destroy() end)

	makeDraggable(popup)
	return popup
end

local function addScript(scrollFrame,scriptName,callback)
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

-- CRIANDO GUI
-- Criar frame principal
local mainFrame, minimizeBtn = createMainFrame()
local sidebar = createSidebar(mainFrame)
local container = createContainer(mainFrame)
local universal = createCategory("Universal", sidebar, container)

-- Função para minimizar/restaurar GUI
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	if minimized then
		-- Restaurar
		mainFrame.Size = UDim2.new(0,400,0,320)
		container.Visible = true
		sidebar.Visible = true
		minimized = false
	else
		-- Minimizar
		mainFrame.Size = UDim2.new(0,200,0,50)
		container.Visible = false
		sidebar.Visible = false
		minimized = true
	end
end)

-- SCRIPT VELOCIDADE
addScript(universal, "Velocidade", function()
	local popup = createPopup("Velocidade", 280, 140)
	local char = Player.Character or Player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")

	local textBox = Instance.new("TextBox")
	textBox.PlaceholderText = "Digite a velocidade..."
	textBox.Font = Enum.Font.Gotham
	textBox.TextColor3 = Color3.fromRGB(255,255,255)
	textBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
	textBox.Size = UDim2.new(0.8,0,0,35)
	textBox.Position = UDim2.new(0.1,0,0.2,0)
	textBox.TextSize = 16
	textBox.Parent = popup
	local tbCorner = Instance.new("UICorner")
	tbCorner.CornerRadius = UDim.new(0,6)
	tbCorner.Parent = textBox

	local applyBtn = Instance.new("TextButton")
	applyBtn.Text = "Aplicar Velocidade"
	applyBtn.Font = Enum.Font.GothamBold
	applyBtn.TextColor3 = Color3.fromRGB(255,255,255)
	applyBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	applyBtn.Size = UDim2.new(0.8,0,0,35)
	applyBtn.Position = UDim2.new(0.1,0,0.6,0)
	applyBtn.TextSize = 16
	applyBtn.Parent = popup
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0,6)
	btnCorner.Parent = applyBtn

	applyBtn.MouseButton1Click:Connect(function()
		local speed = tonumber(textBox.Text)
		if speed and humanoid then
			humanoid.WalkSpeed = speed
			applyBtn.Text = "Velocidade: "..speed
			applyBtn.BackgroundColor3 = Color3.fromRGB(0,200,100)
			task.wait(0.8)
			applyBtn.Text = "Aplicar Velocidade"
			applyBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
		else
			applyBtn.Text = "Número inválido!"
			applyBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
			task.wait(0.8)
			applyBtn.Text = "Aplicar Velocidade"
			applyBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
		end
	end)
end)

-- SCRIPT VOO AVANÇADO CORRIGIDO
addScript(universal, "Voo Avançado", function()
	local popup = createPopup("Voo Avançado", 320, 220)
	local char = Player.Character or Player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	local flying, speed = false, 50
	local bodyVelocity, bodyGyro

	-- Caixa de velocidade
	local speedBox = Instance.new("TextBox")
	speedBox.PlaceholderText = "Velocidade (padrão 50)"
	speedBox.Font = Enum.Font.Gotham
	speedBox.TextColor3 = Color3.fromRGB(255,255,255)
	speedBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
	speedBox.Size = UDim2.new(0.8,0,0,35)
	speedBox.Position = UDim2.new(0.1,0,0.15,0)
	speedBox.TextSize = 16
	speedBox.Parent = popup
	local speedCorner = Instance.new("UICorner")
	speedCorner.CornerRadius = UDim.new(0,6)
	speedCorner.Parent = speedBox

	-- Botão Ativar/Desativar voo
	local flyBtn = Instance.new("TextButton")
	flyBtn.Text = "Ativar Voo"
	flyBtn.Font = Enum.Font.GothamBold
	flyBtn.TextSize = 16
	flyBtn.TextColor3 = Color3.fromRGB(255,255,255)
	flyBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	flyBtn.Size = UDim2.new(0.8,0,0,35)
	flyBtn.Position = UDim2.new(0.1,0,0.45,0)
	flyBtn.Parent = popup
	local flyCorner = Instance.new("UICorner")
	flyCorner.CornerRadius = UDim.new(0,6)
	flyCorner.Parent = flyBtn

	-- Funções de voo
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

	-- Movimento voo PC e celular corrigido
	RunService.RenderStepped:Connect(function()
		if flying and bodyVelocity and bodyGyro then
			local move = Vector3.new(0,0,0)
			local camCFrame = workspace.CurrentCamera.CFrame

			-- Teclas PC
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camCFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camCFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camCFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camCFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

			-- Toques celular
			local touches = UserInputService:GetTouches()
			for _, t in ipairs(touches) do
				if t.Position.Y < workspace.CurrentCamera.ViewportSize.Y/2 then
					move += Vector3.new(0,1,0)
				else
					move -= Vector3.new(0,1,0)
				end
			end

			if move.Magnitude > 0 then
				bodyVelocity.Velocity = move.Unit * speed
			else
				bodyVelocity.Velocity = Vector3.new(0,0,0)
			end
			bodyGyro.CFrame = CFrame.new(root.Position, root.Position + camCFrame.LookVector)
		end
	end)
end)
