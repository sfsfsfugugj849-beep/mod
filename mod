local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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
local oldGui = playerGui:FindFirstChild("NoclipGui")
if oldGui then
	oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NoclipGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 120)
mainFrame.Position = UDim2.new(0.5, -100, 0.4, -60)
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
titleLabel.Text = "Noclip Panel"
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

-- Botón de Activar Noclip
local noclipButton = Instance.new("TextButton")
noclipButton.Name = "NoclipButton"
noclipButton.Size = UDim2.new(0.85, 0, 0, 45)
noclipButton.Position = UDim2.new(0.075, 0, 0.45, 0)
noclipButton.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
noclipButton.Text = "Traspasar Paredes (1s)"
noclipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipButton.Font = Enum.Font.SourceSansBold
noclipButton.TextSize = 14
noclipButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = noclipButton

-- HACER EL GUI DESPLAZABLE (DRAGGABLE)
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

-- LÓGICA DE NOCLIP (1 SEGUNDO)
local isNoclipActive = false

noclipButton.MouseButton1Click:Connect(function()
	if isNoclipActive then return end
	isNoclipActive = true
	
	noclipButton.Text = "¡Noclip Activo!"
	noclipButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
	
	local connection
	connection = RunService.Stepped:Connect(function()
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
	
	task.wait(1)
	
	connection:Disconnect()
	isNoclipActive = false
	noclipButton.Text = "Traspasar Paredes (1s)"
	noclipButton.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
end)
