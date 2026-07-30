-- Delta Executor - Lock Back & Camera Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Eliminar interfaz anterior si existe
local oldGui = game:GetService("CoreGui"):FindFirstChild("DeltaBackFollowGui") or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DeltaBackFollowGui")
if oldGui then oldGui:Destroy() end

-- ==========================================
-- CREACIÓN DE INTERFAZ GRÁFICA PEQUEÑA (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaBackFollowGui"
ScreenGui.ResetOnSpawn = false

pcall(function()
	ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Cuadro Pequeño (180x220 pixels)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.Text = "Back Follower"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(0.9, 0, 0.52, 0)
ScrollList.Position = UDim2.new(0.05, 0, 0.16, 0)
ScrollList.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
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
FollowBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
FollowBtn.Text = "Seguir Espalda"
FollowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FollowBtn.Font = Enum.Font.SourceSansBold
FollowBtn.TextSize = 13
FollowBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = FollowBtn

-- ==========================================
-- LÓGICA DE SEGUIMIENTO Y CÁMARA
-- ==========================================
local selectedPlayer = nil
local isFollowing = false
local followConnection = nil

local function getRoot(char)
	return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function stopFollowing()
	isFollowing = false
	FollowBtn.Text = "Seguir Espalda"
	FollowBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
	
	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end
	
	-- Restaurar tipo de cámara a normal
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

		if not (myHRP and targetHRP) then return end

		-- 1. Posicionar exactamente a 4 studs detrás de su espalda (+Z en espacio local de la CFrame)
		-- CFrame.new(0, 0, 4) se coloca a 4 studs detrás de la orientación del objetivo
		local backPosition = targetHRP.CFrame * CFrame.new(0, 0, 4)
		myHRP.CFrame = backPosition

		-- 2. Apuntar la cámara directamente al jugador objetivo
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHRP.Position)
	end)
end

-- ==========================================
-- ACTUALIZACIÓN DE LISTA DE JUGADORES
-- ==========================================
local function updatePlayerList()
	for _, child in pairs(ScrollList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 22)
			btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
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
					if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30, 30, 38) end
				end
				btn.BackgroundColor3 = Color3.fromRGB(50, 110, 190)
				
				-- Si ya estaba siguiendo a otro, detenerlo
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
