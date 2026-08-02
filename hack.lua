print("ListaJugadores: iniciando...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
print("ListaJugadores: LocalPlayer = " .. tostring(LocalPlayer))

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
print("ListaJugadores: PlayerGui obtenido")

-- Eliminar version anterior
local old = PlayerGui:FindFirstChild("ListaJugadores")
if old then
	old:Destroy()
	print("ListaJugadores: version anterior eliminada")
end

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ListaJugadores"
screenGui.Parent = PlayerGui
print("ListaJugadores: ScreenGui creado")

-- UIScale basico
local uiScale = Instance.new("UIScale")
uiScale.Name = "Escala"
uiScale.Scale = 1
uiScale.Parent = screenGui

-- Ajuste de escala simple con loop
spawn(function()
	while screenGui and screenGui.Parent do
		local size = screenGui.AbsoluteSize
		if size.X > 0 and size.Y > 0 then
			local scaleW = size.X / 360
			local scaleH = size.Y / 640
			uiScale.Scale = math.clamp(math.min(scaleW, scaleH), 0.5, 2.0)
		end
		wait(1)
	end
end)
print("ListaJugadores: escala configurada")

-- Boton toggle en esquina superior derecha (layout movil)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Alternar"
toggleBtn.Text = "JUG"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleBtn.BorderSizePixel = 0
toggleBtn.Size = UDim2.new(0, 80, 0, 44)
toggleBtn.Position = UDim2.new(1, -8, 0, 8)
toggleBtn.AnchorPoint = Vector2.new(1, 0)
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui

print("ListaJugadores: boton toggle en esquina superior derecha")

-- Hacer el boton arrastrable
local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragStartPos = nil
local btnStartPos = nil

toggleBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStartPos = input.Position
		btnStartPos = toggleBtn.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartPos
		toggleBtn.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- Panel principal en esquina superior derecha, debajo del toggle
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Panel"
mainFrame.Size = UDim2.new(0, 200, 0, 280)
mainFrame.Position = UDim2.new(1, -8, 0, 60)  -- misma X que toggle, debajo
mainFrame.AnchorPoint = Vector2.new(1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.ZIndex = 5
mainFrame.Parent = screenGui
print("ListaJugadores: panel creado")

-- Encabezado con fondo mas visible
local header = Instance.new("Frame")
header.Name = "Encabezado"
header.Size = UDim2.new(1, 0, 0, 32)
header.BackgroundColor3 = Color3.fromRGB(255, 120, 20)
header.BorderSizePixel = 0
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Titulo"
title.Text = "Jugadores"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -36, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Cerrar"
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -30, 0.5, -14)
closeBtn.Parent = header

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)
print("ListaJugadores: encabezado creado")

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Lista"
scroll.Size = UDim2.new(1, -6, 1, -36)
scroll.Position = UDim2.new(0, 3, 0, 34)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 3)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll
print("ListaJugadores: scrolling frame creado")

-- Logica de jugadores
local playerFrames = {}

local function flyToPlayer(targetPlayer)
	local localChar = LocalPlayer.Character
	if not localChar then return end
	local targetChar = targetPlayer.Character
	if not targetChar then return end
	local root = localChar:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
	if not root or not targetRoot then return end

	-- Vuelo suave en lugar de teleport
	local startPos = root.Position
	local targetPos = targetRoot.Position
	local duration = 0.5
	local startTime = tick()

	spawn(function()
		while root and root.Parent and tick() - startTime < duration do
			local alpha = math.min((tick() - startTime) / duration, 1)
			root.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha))
			wait()
		end
		if root then
			root.CFrame = CFrame.new(targetPos)
		end
	end)

	print("ListaJugadores: volando hacia " .. targetPlayer.Name)
end

local function createPlayerEntry(player, layoutOrder)
	local entry = Instance.new("Frame")
	entry.Name = player.Name
	entry.Size = UDim2.new(1, -4, 0, 42)
	entry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	entry.BorderSizePixel = 0
	entry.LayoutOrder = layoutOrder
	entry.Parent = scroll

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Text = player.Name
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, -48, 1, 0)
	nameLabel.Position = UDim2.new(0, 6, 0, 0)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = entry

	local flyBtn = Instance.new("TextButton")
	flyBtn.Name = "Volar"
	flyBtn.Text = ">"
	flyBtn.Font = Enum.Font.SourceSansBold
	flyBtn.TextSize = 18
	flyBtn.TextColor3 = Color3.new(1, 1, 1)
	flyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
	flyBtn.BorderSizePixel = 0
	flyBtn.Size = UDim2.new(0, 36, 0, 30)
	flyBtn.Position = UDim2.new(1, -40, 0.5, -15)
	flyBtn.Parent = entry

	flyBtn.MouseButton1Click:Connect(function()
		flyToPlayer(player)
	end)

	return entry
end

local function refreshList()
	-- Limpiar
	for _, frame in pairs(playerFrames) do
		frame:Destroy()
	end
	playerFrames = {}

	local allPlayers = Players:GetPlayers()
	print("ListaJugadores: total jugadores = " .. #allPlayers)
	
	table.sort(allPlayers, function(a, b) return a.Name < b.Name end)

	local count = 0
	for i, player in ipairs(allPlayers) do
		if player ~= LocalPlayer then
			local frame = createPlayerEntry(player, i)
			playerFrames[player] = frame
			count = count + 1
			print("  -> " .. player.Name)
		end
	end
	-- Canvas manual
	scroll.CanvasSize = UDim2.new(0, 0, 0, count * 45)
	print("ListaJugadores: lista actualizada, " .. count .. " jugadores")
end

-- Eventos
Players.PlayerAdded:Connect(function(p)
	print("ListaJugadores: jugador agregado: " .. p.Name)
	refreshList()
end)
Players.PlayerRemoving:Connect(function(p)
	print("ListaJugadores: jugador removido: " .. p.Name)
	refreshList()
end)

LocalPlayer.CharacterAdded:Connect(refreshList)

if LocalPlayer.Character then
	refreshList()
end
refreshList()

-- Toggle
toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

print("ListaJugadores: script cargado correctamente")
