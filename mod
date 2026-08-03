local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Multiplicador
local MULTIPLIER = 1.25

humanoid.WalkSpeed = humanoid.WalkSpeed * MULTIPLIER
if humanoid.UseJumpPower then
	humanoid.JumpPower = humanoid.JumpPower * MULTIPLIER
else
	humanoid.JumpHeight = humanoid.JumpHeight * MULTIPLIER
end

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
local oldGui = playerGui:FindFirstChild("FlyGui")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

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

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -30, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Fly Panel (CFrame)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -28, 0, 3)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14
closeButton.Parent = mainFrame

closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0.85, 0, 0, 40)
flyButton.Position = UDim2.new(0.075, 0, 0.28, 0)
flyButton.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
flyButton.Text = "Volar (CFrame Mode)"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.SourceSansBold
flyButton.TextSize = 13
flyButton.Parent = mainFrame

local upDownFrame = Instance.new("Frame")
upDownFrame.Size = UDim2.new(0.85, 0, 0, 35)
upDownFrame.Position = UDim2.new(0.075, 0, 0.65, 0)
upDownFrame.BackgroundTransparency = 1
upDownFrame.Parent = mainFrame

local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0.47, 0, 1, 0)
upButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
upButton.Text = "▲ Subir"
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Parent = upDownFrame

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0.47, 0, 1, 0)
downButton.Position = UDim2.new(0.53, 0, 0, 0)
downButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
downButton.Text = "▼ Bajar"
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Parent = upDownFrame

-- DRAGGABLE
local dragging, dragStart, startPos, dragInput
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local isGoingUp, isGoingDown = false, false
upButton.MouseButton1Down:Connect(function() isGoingUp = true end)
upButton.MouseButton1Up:Connect(function() isGoingUp = false end)
downButton.MouseButton1Down:Connect(function() isGoingDown = true end)
downButton.MouseButton1Up:Connect(function() isGoingDown = false end)

local isFlying = false
flyButton.MouseButton1Click:Connect(function()
	if isFlying then return end
	isFlying = true
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then isFlying = false; return end

	local camera = Workspace.CurrentCamera
	
	-- Vuelo suave mediante actualización directa de CFrame
	local connection
	connection = RunService.RenderStepped:Connect(function(deltaTime)
		if not character or not hrp then return end
		
		-- Desactivar colisiones
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end

		local moveDir = humanoid.MoveDirection
		local speed = 50 * deltaTime
		local newCFrame = hrp.CFrame

		if moveDir.Magnitude > 0 then
			local flyVector = camera.CFrame:VectorToWorldSpace(camera.CFrame:VectorToObjectSpace(moveDir))
			newCFrame = newCFrame + (flyVector * speed)
		end

		if isGoingUp then
			newCFrame = newCFrame + Vector3.new(0, speed, 0)
		elseif isGoingDown then
			newCFrame = newCFrame - Vector3.new(0, speed, 0)
		end

		hrp.CFrame = CFrame.new(newCFrame.Position, newCFrame.Position + camera.CFrame.LookVector)
	end)

	for i = 10, 1, -1 do
		flyButton.Text = "Volando CFrame... (" .. i .. "s)"
		flyButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
		task.wait(1)
	end

	connection:Disconnect()
	isFlying = false
	flyButton.Text = "Volar (CFrame Mode)"
	flyButton.BackgroundColor3 = Color3.fromRGB(0, 160, 230)
end)
