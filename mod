local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Multiplicador
local MULTIPLIER = 1.25

-- Aplicar multiplicador a la velocidad y fuerza de salto
humanoid.WalkSpeed = humanoid.WalkSpeed * MULTIPLIER

if humanoid.UseJumpPower then
	humanoid.JumpPower = humanoid.JumpPower * MULTIPLIER
else
	humanoid.JumpHeight = humanoid.JumpHeight * MULTIPLIER
end

-- Reaplicar al reaparecer el personaje
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = humanoid.WalkSpeed * MULTIPLIER
	if humanoid.UseJumpPower then
		humanoid.JumpPower = humanoid.JumpPower * MULTIPLIER
	else
		humanoid.JumpHeight = humanoid.JumpHeight * MULTIPLIER
	end
end)

-- CREACIÓN DEL GUI
local playerGui = player:WaitForChild("PlayerGui")

-- Evitar duplicados de GUI
local oldGui = playerGui:FindFirstChild("FlyGui")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.5, -100, 0.4, -75)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Título / Barra Superior
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -30, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Fly + Noclip Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

-- Botón de Cerrar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -28, 0, 3)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Botón de Activar Vuelo
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"
flyButton.Size = UDim2.new(0.85, 0, 0, 40)
flyButton.Position = UDim2.new(0.075, 0, 0.28, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
flyButton.Text = "Volar Rápido + Noclip (10s)"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.SourceSansBold
flyButton.TextSize = 13
flyButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = flyButton

-- Frame de botones para subir/bajar (Móviles / PC)
local upDownFrame = Instance.new("Frame")
upDownFrame.Name = "UpDownFrame"
upDownFrame.Size = UDim2.new(0.85, 0, 0, 35)
upDownFrame.Position = UDim2.new(0.075, 0, 0.65, 0)
upDownFrame.BackgroundTransparency = 1
upDownFrame.Parent = mainFrame

local upButton = Instance.new("TextButton")
upButton.Name = "UpButton"
upButton.Size = UDim2.new(0.47, 0, 1, 0)
upButton.Position = UDim2.new(0, 0, 0, 0)
upButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
upButton.Text = "▲ Subir"
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Font = Enum.Font.SourceSansBold
upButton.TextSize = 13
upButton.Parent = upDownFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 6)
upCorner.Parent = upButton

local downButton = Instance.new("TextButton")
downButton.Name = "DownButton"
downButton.Size = UDim2.new(0.47, 0, 1, 0)
downButton.Position = UDim2.new(0.53, 0, 0, 0)
downButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
downButton.Text = "▼ Bajar"
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Font = Enum.Font.SourceSansBold
downButton.TextSize = 13
downButton.Parent = upDownFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 6)
downCorner.Parent = downButton

-- HACER EL GUI DESPLAZABLE (DRAGGABLE MULTIPLATAFORMA)
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- CONTROLES MANUALES SUBIR / BAJAR (ÚTIL EN MÓVIL)
local isGoingUp = false
local isGoingDown = false

upButton.MouseButton1Down:Connect(function() isGoingUp = true end)
upButton.MouseButton1Up:Connect(function() isGoingUp = false end)
upButton.MouseLeave:Connect(function() isGoingUp = false end)

downButton.MouseButton1Down:Connect(function() isGoingDown = true end)
downButton.MouseButton1Up:Connect(function() isGoingDown = false end)
downButton.MouseLeave:Connect(function() isGoingDown = false end)

-- LÓGICA DE VUELO + NOCLIP (10 SEGUNDOS)
local isFlying = false
local FLY_SPEED = 80

flyButton.MouseButton1Click:Connect(function()
	if isFlying then return end
	isFlying = true
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		isFlying = false
		return
	end

	local originalPlatformStand = humanoid.PlatformStand
	humanoid.PlatformStand = true

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = hrp

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bodyGyro.P = 10000
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp

	local renderConn
	renderConn = RunService.RenderStepped:Connect(function()
		-- 1. Noclip continuo
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end

		-- 2. Vuelo según dirección de la cámara y Joystick/Touch de Móvil o Teclado
		local camera = Workspace.CurrentCamera
		if camera then
			local moveDir = humanoid.MoveDirection
			local targetVelocity = Vector3.zero

			if moveDir.Magnitude > 0 then
				-- Se mueve según hacia dónde apunta la cámara en 3D (incluye mirar arriba/abajo con el dedo)
				targetVelocity = camera.CFrame.LookVector * (moveDir.Magnitude * FLY_SPEED)
			end

			-- Botones en pantalla / teclas extra para subir o bajar directo
			if isGoingUp then
				targetVelocity = targetVelocity + Vector3.new(0, FLY_SPEED, 0)
			elseif isGoingDown then
				targetVelocity = targetVelocity - Vector3.new(0, FLY_SPEED, 0)
			end

			bodyVelocity.Velocity = targetVelocity
			bodyGyro.CFrame = camera.CFrame
		end
	end)

	for i = 10, 1, -1 do
		flyButton.Text = "Volando... (" .. i .. "s)"
		flyButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
		task.wait(1)
	end

	renderConn:Disconnect()
	bodyVelocity:Destroy()
	bodyGyro:Destroy()
	humanoid.PlatformStand = originalPlatformStand

	isGoingUp = false
	isGoingDown = false
	isFlying = false
	flyButton.Text = "Volar Rápido + Noclip (10s)"
	flyButton.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
end)
