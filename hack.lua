-- Delta Executor - Perfect Back Lock & Target Camera Focus
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Limpiar GUI anterior si existe
local oldGui = game:GetService("CoreGui"):FindFirstChild("DeltaCamFollowGui") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DeltaCamFollowGui")
if oldGui then oldGui:Destroy() end

-- ==========================================
-- INTERFAZ GRÁFICA PEQUEÑA (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaCamFollowGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
	ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "Back Cam & Lock"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0.9, 0, 0.52, 0)
ScrollList.Position = UDim2.new(0.05, 0, 0.16, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 3
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)

local FollowBtn = Instance.new("TextButton")
FollowBtn.Size = UDim2.new(0.9, 0, 0.2, 0)
FollowBtn.Position = UDim2.new(0.05, 0, 0.74, 0)
FollowBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 180)
FollowBtn.Text = "Seguir Espalda"
FollowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FollowBtn.Font = Enum.Font.SourceSansBold
FollowBtn.TextSize = 13
FollowBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = FollowBtn

-- ==========================================
-- LÓGICA PERFECCIONADA DE CÁMARA Y PERSONAJE
-- ==========================================
local selectedPlayer = nil
local isFollowing = false
local followConnection = nil

local function getRoot(char)
	return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function getHead(char)
	return char and (char:FindFirstChild("Head") or getRoot(char))
end

local function stopFollowing()
	isFollowing = false
	FollowBtn.Text = "Seguir Espalda"
	FollowBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 180)

	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end

	-- Restaurar personaje a la normalidad
	if LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end

	-- Restaurar control de la cámara
	Camera.CameraType = Enum.CameraType.Custom
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
		Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	end
end

local function startFollowing(targetPlayer)
	if not targetPlayer or targetPlayer == LocalPlayer then return end

	isFollowing = true
	FollowBtn.Text = "Detener"
	FollowBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)

	followConnection = RunService.RenderStepped:Connect(function()
		local myChar = LocalPlayer.Character
		local targetChar = targetPlayer.Character

		if not (myChar and targetChar and isFollowing) then
			stopFollowing()
			return
		end

		local myHRP = getRoot(myChar)
		local targetHRP = getRoot(targetChar)
		local targetHead = getHead(targetChar)
		local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")

		if not (myHRP and targetHRP and targetHead) then return end

		-- Anti-temblor: Apagamos físicas y colisiones para no rebotar
		if myHumanoid then
			myHumanoid:ChangeState(Enum.HumanoidStateType.Physics)
		end
		for _, part in pairs(myChar:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end

		-- 1. POSICIONAR AL PERSONAJE (Copia exacta de su rotación, 4 studs atrás)
		-- En Roblox, +Z es hacia atrás. Esto asegura que mires hacia la misma dirección que él.
		myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 4)
		
		-- Matar inercia para evitar tirones
		myHRP.Velocity = Vector3.new(0, 0, 0)
		myHRP.RotVelocity = Vector3.new(0, 0, 0)

		-- 2. POSICIONAR LA CÁMARA (Tomando como base al jugador objetivo, no a ti)
		-- Nos ponemos 12 studs detrás del objetivo, un poco elevados, y obligamos a la cámara a mirar su cabeza.
		Camera.CameraType = Enum.CameraType.Scriptable
		local camPos = (targetHRP.CFrame * CFrame.new(0, 2.5, 12)).Position
		Camera.CFrame = CFrame.new(camPos, targetHead.Position)
	end)
end

-- ==========================================
-- ACTUALIZACIÓN DE JUGADORES
-- ==========================================
local function updatePlayerList()
	for _, child in pairs(ScrollList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 22)
			btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
			btn.BorderSizePixel = 0
			btn.Text = " " .. player.DisplayName
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			btn.Font = Enum.Font.SourceSans
			btn.TextSize = 12
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Parent = ScrollList

			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 4)
			bCorner.Parent = btn

			btn.MouseButton1Click:Connect(function()
				selectedPlayer = player
				for _, b in pairs(ScrollList:GetChildren()) do
					if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(25, 25, 30) end
				end
				btn.BackgroundColor3 = Color3.fromRGB(50, 110, 190)

				if isFollowing then
					stopFollowing()
				end
			end)
		end
	end
end

FollowBtn.MouseButton1Click:Connect(function()
	if isFollowing then
		stopFollowing()
	elseif selectedPlayer then
		startFollowing(selectedPlayer)
	end
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(function(player)
	if player == selectedPlayer and isFollowing then
		stopFollowing()
	end
	updatePlayerList()
end)

updatePlayerList()
