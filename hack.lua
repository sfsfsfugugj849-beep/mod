local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportMenu"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")
local mf = Instance.new("Frame")
mf.Size = UDim2.new(0,220,0,36)
mf.Position = UDim2.new(0,10,0.5,0)
mf.AnchorPoint = Vector2.new(0,0.5)
mf.BackgroundColor3 = Color3.fromRGB(30,30,30)
mf.BorderSizePixel = 0
Instance.new("UICorner",mf).CornerRadius = UDim.new(0,8)
mf.Parent = gui
local tb = Instance.new("TextButton")
tb.Size = UDim2.new(1,0,1,0)
tb.BackgroundColor3 = Color3.fromRGB(50,120,200)
tb.TextColor3 = Color3.new(1,1,1)
tb.Text = "Players"
tb.Font = Enum.Font.GothamBold
tb.TextSize = 14
Instance.new("UICorner",tb).CornerRadius = UDim.new(0,8)
tb.Parent = mf
local lf = Instance.new("Frame")
lf.Size = UDim2.new(1,0,0,0)
lf.Position = UDim2.new(0,0,1,4)
lf.BackgroundColor3 = Color3.fromRGB(25,25,25)
lf.BorderSizePixel = 0
lf.ClipsDescendants = true
lf.Visible = false
Instance.new("UICorner",lf).CornerRadius = UDim.new(0,8)
lf.Parent = mf
local ll = Instance.new("UIListLayout")
ll.SortOrder = Enum.SortOrder.LayoutOrder
ll.Padding = UDim.new(0,2)
ll.Parent = lf
local open = false
local function refresh()
	for _,c in lf:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
	local n=0
	for _,p in Players:GetPlayers() do
		if p==LP then continue end
		n=n+1
		local r=Instance.new("Frame")
		r.Size=UDim2.new(1,-8,0,28)
		r.Position=UDim2.new(0,4,0,0)
		r.BackgroundColor3=Color3.fromRGB(40,40,40)
		r.BorderSizePixel=0
		Instance.new("UICorner",r).CornerRadius=UDim.new(0,6)
		r.LayoutOrder=n
		r.Parent=lf
		local nl=Instance.new("TextLabel")
		nl.Size=UDim2.new(1,-60,1,0)
		nl.BackgroundTransparency=1
		nl.TextColor3=Color3.new(1,1,1)
		nl.Text=p.DisplayName
		nl.TextXAlignment=Enum.TextXAlignment.Left
		nl.Font=Enum.Font.Gotham
		nl.TextSize=12
		Instance.new("UIPadding",nl).PaddingLeft=UDim.new(0,8)
		nl.Parent=r
		local b=Instance.new("TextButton")
		b.Size=UDim2.new(0,50,0,20)
		b.Position=UDim2.new(1,-54,0.5,0)
		b.AnchorPoint=Vector2.new(0,0.5)
		b.BackgroundColor3=Color3.fromRGB(80,180,80)
		b.TextColor3=Color3.new(1,1,1)
		b.Text="TP"
		b.Font=Enum.Font.GothamBold
		b.TextSize=11
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,4)
		b.Parent=r
		b.MouseButton1Click:Connect(function()
			local hc=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			local tc=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if hc and tc then hc.CFrame=tc.CFrame*CFrame.new(0,0,3) end
		end)
	end
	lf.Size=UDim2.new(1,0,0,n*30+4)
end
tb.MouseButton1Click:Connect(function()
	open=not open
	lf.Visible=open
	if open then refresh() end
end)
Players.PlayerAdded:Connect(function() if open then refresh() end end)
Players.PlayerRemoving:Connect(function() if open then refresh() end end)
