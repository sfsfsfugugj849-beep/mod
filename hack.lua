local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Esperar a que el PlayerGui esté listo
if not PlayerGui then return end

-- Verificar que no exista ya
if PlayerGui:FindFirstChild("ListaJugadores") then
	PlayerGui.ListaJugadores:Destroy()
end

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ListaJugadores"
screenGui.IgnoreGuiInset = true
screenGui.Parent = PlayerGui

-- Construir toda la UI
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Panel"
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.Position = UDim2.new(1, -210, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 180, 30)
stroke.Thickness = 1.5
stroke.Transparency = 0.5
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Titulo"
title.Text = "Jugadores"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Cerrar"
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBlack
closeBtn.TextSize = 14
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -26, 0, 7)
closeBtn.Parent = mainFrame

local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 11)
cCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Lista"
scroll.Size = UDim2.new(1, -10, 1, -42)
scroll.Position = UDim2.new(0, 5, 0, 40)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 180, 30)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 2)
padding.PaddingBottom = UDim.new(0, 4)
padding.Parent = scroll

local uiScale = Instance.new("UIScale")
uiScale.Name = "Escala"
uiScale.Scale = 1
uiScale.Parent = screenGui

local function updateScale()
	local h = screenGui.AbsoluteSize.Y
	uiScale.Scale = math.clamp(h / 1080, 0.5, 1.5)
end
screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
updateScale()

-- ── Lógica de jugadores ──
local playerFrames = {}

local function flyToPlayer(targetPlayer)
	local localChar = LocalPlayer.Character
	if not localChar then return end
	local targetChar = targetPlayer.Character
	if not targetChar then return end
	local root = localChar:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
	if not root or not targetRoot then return end

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local goal = {CFrame = CFrame.new(targetRoot.Position)}
	local tween = TweenService:Create(root, tweenInfo, goal)
	tween:Play()
end

local function createPlayerEntry(player, layoutOrder)
	local entry = Instance.new("Frame")
	entry.Name = player.Name
	entry.Size = UDim2.new(1, -6, 0, 36)
	entry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	entry.BackgroundTransparency = 0.3
	entry.BorderSizePixel = 0
	entry.LayoutOrder = layoutOrder
	entry.Parent = scroll

	local ecorner = Instance.new("UICorner")
	ecorner.CornerRadius = UDim.new(0, 6)
	ecorner.Parent = entry

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Text = player.Name
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 13
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, -60, 1, 0)
	nameLabel.Position = UDim2.new(0, 6, 0, 0)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = entry

	local flyBtn = Instance.new("TextButton")
	flyBtn.Name = "Volar"
	flyBtn.Text = "➤"
	flyBtn.Font = Enum.Font.GothamBold
	flyBtn.TextSize = 14
	flyBtn.TextColor3 = Color3.new(1, 1, 1)
	flyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
	flyBtn.BorderSizePixel = 0
	flyBtn.Size = UDim2.new(0, 34, 0, 26)
	flyBtn.Position = UDim2.new(1, -38, 0.5, -13)
	flyBtn.Parent = entry

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 5)
	btnCorner.Parent = flyBtn

	flyBtn.MouseButton1Click:Connect(function()
		flyToPlayer(player)
	end)

	return entry
end

local function refreshList()
	for _, frame in pairs(playerFrames) do
		frame:Destroy()
	end
	playerFrames = {}

	local sortedPlayers = Players:GetPlayers()
	table.sort(sortedPlayers, function(a, b) return a.UserId < b.UserId end)

	for i, player in ipairs(sortedPlayers) do
		if player ~= LocalPlayer then
			local frame = createPlayerEntry(player, i)
			playerFrames[player] = frame
		end
	end
end

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)

LocalPlayer.CharacterAdded:Connect(function()
	refreshList()
end)

if LocalPlayer.Character then
	refreshList()
end
refreshList()
