--[[
	MobileCombatGUI - Interfaz de Combate Movil para RPG / Blox Fruits
	Un solo LocalScript: construye la GUI y maneja toda la logica
	Optimizado para dispositivos tactiles de gama media/baja
--]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
local backpack = player:WaitForChild("Backpack", 10)

-- ==================== VARIABLES ====================
local autoFarmActive = false
local autoStatsActive = {Melee = false, Defense = false, Sword = false, ["Demon Fruit"] = false}
local selectedWeapon = "Melee"
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ==================== CONSTRUIR GUI ====================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileCombatGUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Boton flotante
local floatButton = Instance.new("TextButton")
floatButton.Name = "FloatMinimize"
floatButton.Size = UDim2.new(0, 50, 0, 50)
floatButton.Position = UDim2.new(0.85, 0, 0.05, 0)
floatButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
floatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
floatButton.Text = "M"
floatButton.Font = Enum.Font.GothamBold
floatButton.TextSize = 24
floatButton.AutoButtonColor = false
floatButton.Parent = screenGui
local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = floatButton
local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(255, 200, 50); fs.Thickness = 2; fs.Parent = floatButton

-- Contenedor principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainContainer"
mainFrame.Size = UDim2.new(0.9, 0, 0.75, 0)
mainFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Visible = true
mainFrame.Parent = screenGui
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0.04, 0); mc.Parent = mainFrame
local ms = Instance.new("UIStroke"); ms.Color = Color3.fromRGB(255, 200, 50); ms.Thickness = 1.5; ms.Parent = mainFrame

-- Barra de titulo
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0.04, 0); tc.Parent = titleBar
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.7, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.fromRGB(255, 200, 50)
titleText.Text = "Mobile Combat"
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -16, 1, -55)
scrollFrame.Position = UDim2.new(0, 8, 0, 50)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.Parent = mainFrame
local uil = Instance.new("UIListLayout")
uil.Padding = UDim.new(0, 10)
uil.HorizontalAlignment = Enum.HorizontalAlignment.Center
uil.SortOrder = Enum.SortOrder.LayoutOrder
uil.Parent = scrollFrame

-- ==================== FUNCIONES PARA CREAR ELEMENTOS ====================

local function createSection(parent, title, order)
	local s = Instance.new("Frame")
	s.Size = UDim2.new(1, -10, 0, 0)
	s.AutomaticSize = Enum.AutomaticSize.Y
	s.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	s.BackgroundTransparency = 0.2
	s.BorderSizePixel = 0
	s.LayoutOrder = order
	s.Parent = parent
	local co = Instance.new("UICorner"); co.CornerRadius = UDim.new(0.03, 0); co.Parent = s
	local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(255, 200, 50); st.Thickness = 1; st.Parent = s
	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, -20, 0, 30)
	tl.Position = UDim2.new(0, 10, 0, 5)
	tl.BackgroundTransparency = 1
	tl.TextColor3 = Color3.fromRGB(255, 200, 50)
	tl.Text = title
	tl.Font = Enum.Font.GothamBold
	tl.TextSize = 16
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.Parent = s
	local cc = Instance.new("Frame")
	cc.Name = "Content"
	cc.Size = UDim2.new(1, -20, 0, 0)
	cc.Position = UDim2.new(0, 10, 0, 40)
	cc.AutomaticSize = Enum.AutomaticSize.Y
	cc.BackgroundTransparency = 1
	cc.Parent = s
	local cl = Instance.new("UIListLayout")
	cl.Padding = UDim.new(0, 8)
	cl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	cl.SortOrder = Enum.SortOrder.LayoutOrder
	cl.Parent = cc
	return cc
end

local function createToggleFrame(parent, text, btnName, order)
	local tf = Instance.new("Frame")
	tf.Size = UDim2.new(1, 0, 0, 50)
	tf.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	tf.BorderSizePixel = 0
	tf.LayoutOrder = order
	tf.Parent = parent
	local co = Instance.new("UICorner"); co.CornerRadius = UDim.new(0.15, 0); co.Parent = tf
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.65, 0, 1, 0)
	lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Text = text
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = tf
	local btn = Instance.new("TextButton")
	btn.Name = btnName
	btn.Size = UDim2.new(0, 50, 0, 28)
	btn.Position = UDim2.new(1, -65, 0.5, -14)
	btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = "OFF"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.AutoButtonColor = false
	btn.Parent = tf
	local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = btn
	return btn
end

local function createCycleFrame(parent, labelText, options, btnName, order)
	local cf = Instance.new("Frame")
	cf.Size = UDim2.new(1, 0, 0, 50)
	cf.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	cf.BorderSizePixel = 0
	cf.LayoutOrder = order
	cf.Parent = parent
	local co = Instance.new("UICorner"); co.CornerRadius = UDim.new(0.15, 0); co.Parent = cf
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, 0, 1, 0)
	lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Text = labelText
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 15
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = cf
	local btn = Instance.new("TextButton")
	btn.Name = btnName
	btn.Size = UDim2.new(0, 100, 0, 28)
	btn.Position = UDim2.new(1, -115, 0.5, -14)
	btn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	btn.TextColor3 = Color3.fromRGB(20, 20, 20)
	btn.Text = options[1]
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.AutoButtonColor = false
	btn.Parent = cf
	local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0.15, 0); bc.Parent = btn
	return btn
end

-- ==================== SECCIONES DE LA GUI ====================

-- Auto Farm
local farmContent = createSection(scrollFrame, "Auto Farm", 1)
local farmToggleBtn = createToggleFrame(farmContent, "Activar Auto Farm", "FarmToggleBtn", 1)
local weaponCycleBtn = createCycleFrame(farmContent, "Arma:", {"Melee", "Sword", "Fruit", "Gun"}, "WeaponCycleBtn", 2)

-- Auto Stats
local statsContent = createSection(scrollFrame, "Auto Stats", 2)
local sd = Instance.new("TextLabel")
sd.Size = UDim2.new(1, 0, 0, 25)
sd.BackgroundTransparency = 1
sd.TextColor3 = Color3.fromRGB(180, 180, 180)
sd.Text = "Subir automaticamente al subir de nivel"
sd.Font = Enum.Font.Gotham
sd.TextSize = 12
sd.TextXAlignment = Enum.TextXAlignment.Left
sd.LayoutOrder = 0
sd.Parent = statsContent

local statBtns = {}
for i, name in ipairs({"Melee", "Defense", "Sword", "Demon Fruit"}) do
	statBtns[name] = createToggleFrame(statsContent, name, name .. "ToggleBtn", i)
end

-- Info
local infoContent = createSection(scrollFrame, "Info", 3)
local il = Instance.new("TextLabel")
il.Size = UDim2.new(1, 0, 0, 70)
il.BackgroundTransparency = 1
il.TextColor3 = Color3.fromRGB(200, 200, 200)
il.Text = "Mobile Combat GUI v1.0\nOptimizado para moviles\nTactil compatible | Bajo consumo"
il.Font = Enum.Font.Gotham
il.TextSize = 12
il.TextXAlignment = Enum.TextXAlignment.Left
il.TextYAlignment = Enum.TextYAlignment.Top
il.LayoutOrder = 0
il.Parent = infoContent

-- ==================== UTILIDADES ====================

local function equipTool(toolName)
	local char = player.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return false end
	local currentTool = char:FindFirstChildOfClass("Tool")
	if currentTool and currentTool.Name == toolName then return true end
	local tool = backpack:FindFirstChild(toolName)
	if tool then hum:EquipTool(tool) return true end
	return false
end

local function findToolByType(weaponType)
	local char = player.Character
	if not char then return nil end
	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			local tn = tool.Name:lower()
			if weaponType == "Melee" and not tn:find("gun") and not tn:find("fruit") and not tn:find("pistol") and not tn:find("rifle") then return tool.Name
			elseif weaponType == "Sword" and (tn:find("sword") or tn:find("espada") or tn:find("blade") or tn:find("katana") or tn:find("saber")) then return tool.Name
			elseif weaponType == "Fruit" and (tn:find("fruit") or tn:find("fruta")) then return tool.Name
			elseif weaponType == "Gun" and (tn:find("gun") or tn:find("pistol") or tn:find("rifle") or tn:find("bazooka")) then return tool.Name
			end
		end
	end
	local all = backpack:GetChildren()
	if weaponType == "Melee" and #all > 0 then return all[1].Name end
	return nil
end

local function findNearestNPC()
	local char = player.Character
	if not char then return nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local nearest, nearestDist = nil, math.huge
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= char then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local root = obj:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
				local d = (hrp.Position - root.Position).Magnitude
				if d < nearestDist then nearest, nearestDist = obj, d end
			end
		end
	end
	return nearest
end

local function positionAboveTarget(target)
	local char = player.Character
	if not char or not target then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local tr = target:FindFirstChild("HumanoidRootPart")
	if not hrp or not tr then return end
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(tr.Position + Vector3.new(0, 8, 0))})
	tween:Play()
	tween.Completed:Wait()
end

local function performAttack()
	pcall(function()
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
		task.wait(0.1)
		VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
	end)
end

-- ==================== CICLO AUTO FARM ====================

local function autoFarmLoop()
	if not autoFarmActive then return end
	local char = player.Character
	if not char then task.wait(0.5) autoFarmLoop() return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then task.wait(0.5) autoFarmLoop() return end
	local target = findNearestNPC()
	if not target then task.wait(0.5) autoFarmLoop() return end
	local tn = findToolByType(selectedWeapon)
	if tn then equipTool(tn) end
	positionAboveTarget(target)
	performAttack()
	task.wait(0.3)
	autoFarmLoop()
end

-- ==================== CICLO AUTO STATS ====================

local function autoStatsLoop()
	while autoStatsActive.Melee or autoStatsActive.Defense or autoStatsActive.Sword or autoStatsActive["Demon Fruit"] do
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			local pts = ls:FindFirstChild("Points") or ls:FindFirstChild("StatPoints") or ls:FindFirstChild("SkillPoints")
			if pts and pts.Value > 0 then
				local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
				if remotes then
					local add = remotes:FindFirstChild("AddStat") or remotes:FindFirstChild("UpgradeStat")
					if add then
						if autoStatsActive.Melee then pcall(function() add:FireServer("Melee") end) end
						if autoStatsActive.Defense then pcall(function() add:FireServer("Defense") end) end
						if autoStatsActive.Sword then pcall(function() add:FireServer("Sword") end) end
						if autoStatsActive["Demon Fruit"] then pcall(function() add:FireServer("Demon Fruit") end) end
					end
				end
			end
		end
		task.wait(1)
	end
end

-- ==================== CONECTAR BOTONES ====================

-- Toggle Auto Farm
farmToggleBtn.MouseButton1Click:Connect(function()
	autoFarmActive = not autoFarmActive
	if autoFarmActive then
		farmToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		farmToggleBtn.Text = "ON"
		farmToggleBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
		autoFarmLoop()
	else
		farmToggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		farmToggleBtn.Text = "OFF"
		farmToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

-- Ciclo de arma
local weaponOptions = {"Melee", "Sword", "Fruit", "Gun"}
local weaponIndex = 1
weaponCycleBtn.MouseButton1Click:Connect(function()
	weaponIndex = weaponIndex + 1
	if weaponIndex > #weaponOptions then weaponIndex = 1 end
	selectedWeapon = weaponOptions[weaponIndex]
	weaponCycleBtn.Text = selectedWeapon
end)

-- Toggles Auto Stats
for _, name in ipairs({"Melee", "Defense", "Sword", "Demon Fruit"}) do
	local btn = statBtns[name]
	if btn then
		btn.MouseButton1Click:Connect(function()
			autoStatsActive[name] = not autoStatsActive[name]
			if autoStatsActive[name] then
				btn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
				btn.Text = "ON"
				btn.TextColor3 = Color3.fromRGB(20, 20, 20)
				autoStatsLoop()
			else
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				btn.Text = "OFF"
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end)
	end
end

-- ==================== BOTON FLOTANTE ====================

floatButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Arrastrar boton flotante (tactil)
local dragToggle, dragStart, startPos = nil, nil, nil
floatButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragToggle = true
		dragStart = input.Position
		startPos = floatButton.Position
	end
end)
floatButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch and dragToggle then
		local delta = input.Position - dragStart
		floatButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
floatButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then dragToggle = nil end
end)

-- ==================== AJUSTE DE PANTALLA ====================

local function adjustForScreen()
	local cam = workspace.CurrentCamera
	if not cam then return end
	local ss = cam.ViewportSize
	if ss.X < 400 then floatButton.Size = UDim2.new(0, 42, 0, 42) floatButton.TextSize = 20 end
	if ss.X > 800 then mainFrame.Size = UDim2.new(0.7, 0, 0.7, 0) mainFrame.Position = UDim2.new(0.15, 0, 0.15, 0) end
end
adjustForScreen()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adjustForScreen) end

-- ==================== MANEJAR RESPAWN ====================

player.CharacterAdded:Connect(function(newChar)
	task.wait(0.5)
	if autoFarmActive then autoFarmLoop() end
end)

print("Mobile Combat GUI cargada - Un solo LocalScript - Optimizado para tactil")
