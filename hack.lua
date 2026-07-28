local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Ofuscación de nombres para evadir detectores simples
local guiNames = {"CoreGuiBridge", "NotificationHandler", "SystemOverlay", "TopbarPlus_Ext", "RobloxConnection"}
local frameNames = {"Container_v2", "DataHolder", "TempFrame", "UI_Block", "RenderLayer"}
local btnNames = {"ActionKey", "ToggleState", "SysBtn", "Interact", "Confirm"}

local function getRandomName(list)
	return list[math.random(1, #list)]
end

-- Carga diferida para evitar detección inmediata al spawnear
task.delay(math.random(3, 8), function()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = getRandomName(guiNames)
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = getRandomName(frameNames)
	mainFrame.Size = UDim2.new(0.45, 0, 0.5, 0)
	mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
	mainFrame.BackgroundTransparency = 0.1 -- Ligeramente transparente para camuflaje
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 0 -- Sin bordes para parecer más nativo
	mainFrame.Parent = screenGui

	-- Hacerlo arrastrable para móvil
	local dragStart, startPos
	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragStart = nil
				end
			end)
		end
	end)
	mainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragStart then
				local delta = input.Position - dragStart
				mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end
	end)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.15, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = ""
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = mainFrame

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = getRandomName(frameNames)
	scrollFrame.Size = UDim2.new(1, -10, 0.7, 0)
	scrollFrame.Position = UDim2.new(0, 5, 0.15, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = mainFrame

	local uiListLayout = Instance.new("UIListLayout")
	uiListLayout.Padding = UDim.new(0, 5)
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout.Parent = scrollFrame

	local orbitButton = Instance.new("TextButton")
	orbitButton.Name = getRandomName(btnNames)
	orbitButton.Size = UDim2.new(1, -10, 0.15, 0)
	orbitButton.Position = UDim2.new(0, 5, 0.85, 0)
	orbitButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
	orbitButton.Text = ""
	orbitButton.TextColor3 = Color3.new(1, 1, 1)
	orbitButton.Font = Enum.Font.GothamBold
	orbitButton.TextSize = 22
	orbitButton.Parent = mainFrame

	-- Variables de lógica
	local targetPlayer = nil
	local isOrbiting = false
	local orbitAngle = 0
	local orbitRadius = 5
	local isUsingAbility = false

	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://92575777827146"

	local function updatePlayerList()
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end

		local count = 0
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= player then
				count = count + 1
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, -10, 0, 45)
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				btn.Text = p.Name
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.Font = Enum.Font.Gotham
				btn.TextSize = 20
				btn.Parent = scrollFrame

				btn.MouseButton1Click:Connect(function()
					for _, b in ipairs(scrollFrame:GetChildren()) do
						if b:IsA("TextButton") then
							b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
						end
					end
					btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
					targetPlayer = p
				end)
			end
		end
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 50 + 10)
	end

	Players.PlayerAdded:Connect(updatePlayerList)
	Players.PlayerRemoving:Connect(updatePlayerList)
	updatePlayerList()

	orbitButton.MouseButton1Click:Connect(function()
		if not targetPlayer then
			return
		end
		isOrbiting = not isOrbiting
		orbitButton.BackgroundColor3 = isOrbiting and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 150, 0)
	end)

	-- Bucle de órbita con anti-detección (jittering y variaciones de velocidad)
	RunService.Heartbeat:Connect(function(dt)
		if isOrbiting and not isUsingAbility and targetPlayer and targetPlayer.Character and player.Character then
			local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			local localHRP = player.Character:FindFirstChild("HumanoidRootPart")
			if targetHRP and localHRP then
				-- Variación aleatoria de velocidad y radio para evitar patrones detectables
				local speedVariation = 0.05 + (math.random(-10, 10) * 0.0005)
				local radiusJitter = (math.random(-5, 5) * 0.02)
				orbitAngle = orbitAngle + speedVariation
				local offset = CFrame.Angles(0, orbitAngle, 0) * CFrame.new(0, 0, orbitRadius + radiusJitter)
				localHRP.CFrame = targetHRP.CFrame * offset
			end
		end
	end)

	local function triggerAbility()
		if not isOrbiting or isUsingAbility or not targetPlayer or not targetPlayer.Character or not player.Character then
			return
		end
		isUsingAbility = true
		isOrbiting = false

		local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		local localHRP = player.Character:FindFirstChild("HumanoidRootPart")
		if targetHRP and localHRP then
			-- Teletransportar frente a frente
			localHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -3)
			localHRP.CFrame = CFrame.lookAt(localHRP.Position, targetHRP.Position)

			-- Reproducir animación forzosamente con prioridad alta
			local humanoid = player.Character:FindFirstChild("Humanoid")
			if humanoid then
				local track = humanoid:LoadAnimation(anim)
				track.Priority = Enum.AnimationPriority.Action
				track:Play()

				-- Volver a orbitar solo cuando termine la animación
				track.Stopped:Connect(function()
					isUsingAbility = false
					isOrbiting = true
					orbitButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
				end)
			end
		end
	end

	-- Detectar input para interrumpir órbita
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			local target = input.Target
			if target and target:IsA("GuiButton") then
				local name = string.lower(target.Name)
				local parentName = target.Parent and string.lower(target.Parent.Name) or ""
				if string.find(name, "skill") or string.find(name, "ability") or string.find(name, "move") or string.find(name, "key") or string.find(name, "slot") or string.find(parentName, "skill") or string.find(parentName, "ability") or string.find(parentName, "hotbar") or string.find(parentName, "action") then
					triggerAbility()
				end
			else
				if isOrbiting and not isUsingAbility and targetPlayer and targetPlayer.Character and player.Character then
					triggerAbility()
				end
			end
		end
	end)

	-- Detectar teclas comunes de habilidades
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.One or input.KeyCode == Enum.KeyCode.Two or input.KeyCode == Enum.KeyCode.Three or input.KeyCode == Enum.KeyCode.Four or input.KeyCode == Enum.KeyCode.Q or input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Z or input.KeyCode == Enum.KeyCode.X then
			triggerAbility()
		end
	end)
end)
