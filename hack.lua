-- Delta Executor Compatible
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Destruir interfaz previa si existe
local oldGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DeltaFlingGui")
if oldGui then oldGui:Destroy() end

-- ==========================================
-- CREACIÓN DE LA INTERFAZ GRÁFICA (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFlingGui"
ScreenGui.ResetOnSpawn = false

-- Delta prefiere CoreGui o PlayerGui directo
local success = pcall(function()
	ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 330)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Borde redondeado
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "Delta Fling Panel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0.9, 0, 0.55, 0)
ScrollList.Position = UDim2.new(0.05, 0, 0.14, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
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
FlingOneBtn.BackgroundColor3 = Color3.fromRGB(210, 85, 45)
FlingOneBtn.Text = "Fling One"
FlingOneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingOneBtn.Font = Enum.Font.SourceSansBold
FlingOneBtn.TextSize = 15
FlingOneBtn.Parent = MainFrame

local FlingAllBtn = Instance.new("TextButton")
FlingAllBtn.Size = UDim2.new(0.9, 0, 0.11, 0)
FlingAllBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
FlingAllBtn.BackgroundColor3 = Color3.fromRGB(190, 40, 40)
FlingAllBtn.Text = "Fling All"
FlingAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingAllBtn.Font = Enum.Font.SourceSansBold
FlingAllBtn.TextSize = 15
FlingAllBtn.Parent = MainFrame

-- Estilos para botones
for _, btn in pairs({FlingOneBtn, FlingAllBtn}) do
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn
end

-- ==========================================
-- LÓGICA DE FLING (MÉTODO PARA EXECUTORS)
-- ==========================================
local selectedPlayer = nil

local function getRoot(char)
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function executeFling(targetPlayer)
	if not targetPlayer or targetPlayer == LocalPlayer then return end

	local myChar = LocalPlayer.Character
	local targetChar = targetPlayer.Character
	if not (myChar and targetChar) then return end

	local myHRP = getRoot(myChar)
	local targetHRP = getRoot(targetChar)
	if not (myHRP and targetHRP) then return end

	-- Desactivar colisiones para atravesar y pegar físicamente
	local noclipConnection
	noclipConnection = RunService.Stepped:Connect(function()
		for _, part in pairs(myChar:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end)

	-- Configurar la velocidad angular extrema
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.Name = "DeltaFlingSpin"
	bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyAngularVelocity.AngularVelocity = Vector3.new(0, 999999, 0)
	bodyAngularVelocity.Parent = myHRP

	-- Bucle de pegado hiper-cercano
	local startTime = tick()
	local flingConnection
	flingConnection = RunService.Heartbeat:Connect(function()
		if tick() - startTime > 1.8 or not targetHRP.Parent or not targetChar:FindFirstChildOfClass("Humanoid") then
			-- Limpieza al terminar
			flingConnection:Disconnect()
			noclipConnection:Disconnect()
			if bodyAngularVelocity then bodyAngularVelocity:Destroy() end
		else
			-- Pegado milimétrico y desestabilización de físicas
			myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), 0)
			myHRP.Velocity = Vector3.new(99999, 99999, 99999)
		end
	end)
end

-- ==========================================
-- ACTUALIZACIÓN DE JUGADORES
-- ==========================================
local function updatePlayerList()
	for _, child in pairs(ScrollList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 26)
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
			btn.BorderSizePixel = 0
			btn.Text = "  " .. player.DisplayName
			btn.TextColor3 = Color3.fromRGB(210, 210, 210)
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
				btn.BackgroundColor3 = Color3.fromRGB(50, 110, 190)
			end)
		end
	end
end

FlingOneBtn.MouseButton1Click:Connect(function()
	if selectedPlayer then
		executeFling(selectedPlayer)
	end
end)

FlingAllBtn.MouseButton1Click:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			executeFling(player)
			task.wait(1.9)
		end
	end
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()
