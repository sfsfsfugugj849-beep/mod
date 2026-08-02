-- Delta Executor + PC + Mobile compatible
local success, err = pcall(function()
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then return end

	-- TweenService con fallback (algunos ejecutores no lo tienen)
	local TweenService
	local useTween = pcall(function()
		TweenService = game:GetService("TweenService")
	end)

	local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
	if not PlayerGui then return end

	-- Eliminar version anterior
	local old = PlayerGui:FindFirstChild("ListaJugadores")
	if old then
		pcall(function() old:Destroy() end)
	end

	-- Crear ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ListaJugadores"
	screenGui.IgnoreGuiInset = true
	pcall(function()
		screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
		screenGui.ClipToDeviceSafeArea = true
	end)
	screenGui.Parent = PlayerGui

	-- ── Escala ──
	local uiScale = Instance.new("UIScale")
	uiScale.Name = "Escala"
	uiScale.Scale = 1
	uiScale.Parent = screenGui

	local baseWidth = 360
	local baseHeight = 640
	local function updateScale()
		local size = screenGui.AbsoluteSize
		if size.X > 0 and size.Y > 0 then
			local scaleW = size.X / baseWidth
			local scaleH = size.Y / baseHeight
			uiScale.Scale = math.clamp(math.min(scaleW, scaleH), 0.5, 2.0)
		end
	end
	-- Intentar usar evento, con fallback a polling
	local ok = pcall(function()
		screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
	end)
	if not ok then
		-- Polling para ejecutores que no soportan el evento
		spawn(function()
			while screenGui and screenGui.Parent do
				updateScale()
				task.wait(1)
			end
		end)
	end
	updateScale()

	-- ── Botón de alternancia (toggle) ──
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "Alternar"
	toggleBtn.Text = "☰"
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Color3.new(1, 1, 1)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	toggleBtn.BackgroundTransparency = 0.2
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Size = UDim2.new(0, 32, 0, 32)
	toggleBtn.Position = UDim2.new(1, -6, 0, 6)
	toggleBtn.AnchorPoint = Vector2.new(1, 0)
	toggleBtn.ZIndex = 10
	toggleBtn.Parent = screenGui

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleBtn

	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Color = Color3.fromRGB(255, 180, 30)
	toggleStroke.Thickness = 1.5
	toggleStroke.Transparency = 0.6
	toggleStroke.Parent = toggleBtn

	-- ── Panel principal ──
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

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 180, 30)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.4
	stroke.Parent = mainFrame

	-- ── Encabezado ──
	local header = Instance.new("Frame")
	header.Name = "Encabezado"
	header.Size = UDim2.new(1, 0, 0, 28)
	header.BackgroundColor3 = Color3.fromRGB(255, 120, 20)
	header.BackgroundTransparency = 0.3
	header.BorderSizePixel = 0
	header.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 10)
	headerCorner.Parent = header

	local patch = Instance.new("Frame")
	patch.BackgroundColor3 = Color3.fromRGB(255, 120, 20)
	patch.BackgroundTransparency = 0.3
	patch.BorderSizePixel = 0
	patch.Size = UDim2.new(1, 0, 0, 10)
	patch.Position = UDim2.new(0, 0, 1, -10)
	patch.Parent = header

	local title = Instance.new("TextLabel")
	title.Name = "Titulo"
	title.Text = "Jugadores"
	title.Font = Enum.Font.GothamBold
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
	closeBtn.Font = Enum.Font.GothamBlack
	closeBtn.TextSize = 14
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
	closeBtn.BorderSizePixel = 0
	closeBtn.Size = UDim2.new(0, 22, 0, 22)
	closeBtn.Position = UDim2.new(1, -24, 0.5, -11)
	closeBtn.Parent = header

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 11)
	cCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
	end)

	-- ── ScrollingFrame ──
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Lista"
	scroll.Size = UDim2.new(1, -6, 1, -34)
	scroll.Position = UDim2.new(0, 3, 0, 32)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 180, 30)
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 3)
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scroll

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 2)
	padding.PaddingBottom = UDim.new(0, 2)
	padding.Parent = scroll

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

		if useTween and TweenService then
			local ok = pcall(function()
				local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local goal = {CFrame = CFrame.new(targetRoot.Position)}
				local tween = TweenService:Create(root, tweenInfo, goal)
				tween:Play()
			end)
			if ok then return end
		end
		-- Fallback: teletransporte directo
		root.CFrame = CFrame.new(targetRoot.Position)
	end

	local function createPlayerEntry(player, layoutOrder)
		local entry = Instance.new("Frame")
		entry.Name = player.Name
		entry.Size = UDim2.new(1, -4, 0, 38)
		entry.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		entry.BackgroundTransparency = 0.25
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
		nameLabel.Size = UDim2.new(1, -44, 1, 0)
		nameLabel.Position = UDim2.new(0, 6, 0, 0)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = entry

		local flyBtn = Instance.new("TextButton")
		flyBtn.Name = "Volar"
		flyBtn.Text = "➤"
		flyBtn.Font = Enum.Font.GothamBold
		flyBtn.TextSize = 16
		flyBtn.TextColor3 = Color3.new(1, 1, 1)
		flyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 100)
		flyBtn.BorderSizePixel = 0
		flyBtn.Size = UDim2.new(0, 32, 0, 28)
		flyBtn.Position = UDim2.new(1, -36, 0.5, -14)
		flyBtn.Parent = entry

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 5)
		btnCorner.Parent = flyBtn

		flyBtn.MouseButton1Click:Connect(function()
			pcall(function() flyToPlayer(player) end)
		end)

		return entry
	end

	local function refreshList()
		for _, frame in pairs(playerFrames) do
			pcall(function() frame:Destroy() end)
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

	-- ── Eventos ──
	pcall(function() Players.PlayerAdded:Connect(refreshList) end)
	pcall(function() Players.PlayerRemoving:Connect(refreshList) end)
	pcall(function()
		LocalPlayer.CharacterAdded:Connect(refreshList)
	end)

	if LocalPlayer.Character then
		refreshList()
	end
	refreshList()

	-- ── Toggle ──
	toggleBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = not mainFrame.Visible
	end)
end)

if not success then
	warn("ListaJugadores error: " .. tostring(err))
end
