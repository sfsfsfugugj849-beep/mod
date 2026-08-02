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

-- Boton toggle
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "Alternar"
toggleBtn.Text = "J"
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
toggleBtn.BorderSizePixel = 0
toggleBtn.Size = UDim2.new(0, 32, 0, 32)
toggleBtn.Position = UDim2.new(1, -6, 0, 6)
toggleBtn.AnchorPoint = Vector2.new(1, 0)
toggleBtn.ZIndex = 10
toggleBtn.Parent = screenGui
print("ListaJugadores: boton toggle creado")

-- Panel principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Panel"
mainFrame.Size = UDim2.new(0, 170, 0, 280)
mainFrame.Position = UDim2.new(1, -6, 0, 44)
mainFrame.AnchorPoint = Vector2.new(1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.ZIndex = 5
mainFrame.Parent = screenGui
print("ListaJugadores: panel creado")

-- Encabezado
local header = Instance.new("Frame")
header.Name = "Encabezado"
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = Color3.fromRGB(255, 120, 20)
header.BorderSizePixel = 0
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Titulo"
title.Text = "Jugadores"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -28, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Cerrar"
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -24, 0.5, -11)
closeBtn.Parent = header

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)
print("ListaJugadores: encabezado creado")

-- ScrollingFrame simple
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Lista"
scroll.Size = UDim2.new(1, -6, 1, -34)
scroll.Position = UDim2.new(0, 3, 0, 32)
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
	root.CFrame = CFrame.new(targetRoot.Position)
	print("ListaJugadores: volando hacia " .. targetPlayer.Name)
end

local function createPlayerEntry(player, layoutOrder)
	local entry = Instance.new("Frame")
	entry.Name = player.Name
	entry.Size = UDim2.new(1, -4, 0, 38)
	entry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	entry.BorderSizePixel = 0
	entry.LayoutOrder = layoutOrder
	entry.Parent = scroll

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Text = player.Name
	nameLabel.Font = Enum.Font.SourceSans
	nameLabel.TextSize = 13
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, -44, 1, 0)
	nameLabel.Position = UDim2.new(0, 6, 0, 0)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = entry

	local flyBtn = Instance.new("TextButton")
	flyBtn.Name = "Volar"
	flyBtn.Text = ">"
	flyBtn.Font = Enum.Font.SourceSansBold
	flyBtn.TextSize = 16
	flyBtn.TextColor3 = Color3.new(1, 1, 1)
	flyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
	flyBtn.BorderSizePixel = 0
	flyBtn.Size = UDim2.new(0, 32, 0, 28)
	flyBtn.Position = UDim2.new(1, -36, 0.5, -14)
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

	-- Ajustar tamano del canvas manualmente
	local count = 0
	local sortedPlayers = Players:GetPlayers()
	table.sort(sortedPlayers, function(a, b) return a.UserId < b.UserId end)

	for i, player in ipairs(sortedPlayers) do
		if player ~= LocalPlayer then
			local frame = createPlayerEntry(player, i)
			playerFrames[player] = frame
			count = count + 1
		end
	end
	-- Canvas manual
	scroll.CanvasSize = UDim2.new(0, 0, 0, count * 41)
	print("ListaJugadores: lista actualizada, " .. count .. " jugadores")
end

-- Eventos
Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)

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
