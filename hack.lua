-- Delta Executor Ultimate Fling
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Eliminar interfaz anterior si existe
local oldGui = game:GetService("CoreGui"):FindFirstChild("DeltaFlingGui") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DeltaFlingGui")
if oldGui then oldGui:Destroy() end

-- GUI Base
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFlingGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
	ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 330)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "Ultra Fling Panel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0.9, 0, 0.55, 0)
ScrollList.Position = UDim2.new(0.05, 0, 0.14, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 4
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

local FlingOneBtn = Instance.new("TextButton")
FlingOneBtn.Size = UDim2.new(0.9, 0, 0.11, 0)
FlingOneBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
FlingOneBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 40)
FlingOneBtn.Text = "ULTRA FLING ONE"
FlingOneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingOneBtn.Font = Enum.Font.SourceSansBold
FlingOneBtn.TextSize = 14
FlingOneBtn.Parent = MainFrame

local FlingAllBtn = Instance.new("TextButton")
FlingAllBtn.Size = UDim2.new(0.9, 0, 0.11, 0)
FlingAllBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
FlingAllBtn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
FlingAllBtn.Text = "ULTRA FLING ALL"
FlingAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingAllBtn.Font = Enum.Font.SourceSansBold
FlingAllBtn.TextSize = 14
FlingAllBtn.Parent = MainFrame

for _, btn in pairs({FlingOneBtn, FlingAllBtn}) do
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn
end

-- ==========================================
-- SISTEMA DE ULTRA FLING ANTI-SELF-FLING
-- ==========================================
local selectedPlayer = nil

local function getRoot(char)
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function executeUltraFling(targetPlayer)
	if not targetPlayer or targetPlayer == LocalPlayer then return end

	local myChar = LocalPlayer.Character
	local targetChar = targetPlayer.Character
	if not (myChar and targetChar) then return end

	local myHRP = getRoot(myChar)
	local targetHRP = getRoot(targetChar)
	local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
	if not (myHRP and targetHRP and myHumanoid) then return end

	-- Guardar CFrame original para regresar a salvo
	local originalCFrame = myHRP.CFrame

	-- 1. Desactivar colisiones de todo nuestro personaje
	local noclipConn = RunService.Stepped:Connect(function()
		for _, part in pairs(myChar:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)

	-- 2. Configurar giro hiper-acelerado sin resistencia
	local bAV = Instance.new("BodyAngularVelocity")
	bAV.Name = "HyperSpin"
	bAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bAV.AngularVelocity = Vector3.new(0, 9999999, 0) -- Velocidad extrema
	bAV.Parent = myHRP

	-- 3. Bucle de físicas agresivas
	local startTime = tick()
	local flingConn
	flingConn = RunService.Heartbeat:Connect(function()
		if tick() - startTime > 1.2 or not targetHRP.Parent or not targetChar:FindFirstChildOfClass("Humanoid") then
			-- Finalizar y limpiar
			flingConn:Disconnect()
			noclipConn:Disconnect()
			if bAV then bAV:Destroy() end
			
			-- Detener velocidad propia inmediatamente para no salir volando
			myHRP.Velocity = Vector3.new(0, 0, 0)
			myHRP.RotVelocity = Vector3.new(0, 0, 0)
			myHRP.CFrame = originalCFrame
		else
			-- Sincronizar estado para evitar tropezar con nuestras propias físicas
			myHumanoid:ChangeState(Enum.HumanoidStateType.Physics)

			-- Alternar posición entre el centro y la base del enemigo a súper velocidad
			-- Esto rompe el cálculo de físicas del objetivo y lo expulsa
			local offset = Vector3.new(math.random(-1, 1), -1.5, math.random(-1, 1))
			myHRP.CFrame = targetHRP.CFrame * CFrame.new(offset) * CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), 0)

			-- Inyectar impulso masivo en la red
			myHRP.Velocity = Vector3.new(0, 999999, 0)
			myHRP.RotVelocity = Vector3.new(999999, 999999, 999999)
		end
	end)
end

-- ==========================================
-- GESTIÓN DE JUGADORES
-- ==========================================
local function updatePlayerList()
	for _, child in pairs(ScrollList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 26)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
			btn.BorderSizePixel = 0
			btn.Text = "  " .. player.DisplayName
			btn.TextColor3 = Color3.fromRGB(220, 220, 220)
			btn.Font = Enum.Font.SourceSans
			btn.TextSize = 13
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Parent = ScrollList

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 4)
			btnCorner.Parent = btn

			btn.MouseButton1Click:Connect(function()
				selectedPlayer = player
				for _, b in pairs(ScrollList:GetChildren()) do
					if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(35, 35, 42) end
				end
				btn.BackgroundColor3 = Color3.fromRGB(200, 70, 40)
			end)
		end
	end
end

FlingOneBtn.MouseButton1Click:Connect(function()
	if selectedPlayer then
		executeUltraFling(selectedPlayer)
	end
end)

FlingAllBtn.MouseButton1Click:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			executeUltraFling(player)
			task.wait(1.3)
		end
	end
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()
