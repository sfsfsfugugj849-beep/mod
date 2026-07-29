--[[ MobileCombatGUI v2 - Delta Executor compatible - RPG/Blox Fruits ]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local plr = Players.LocalPlayer
local pg = plr:WaitForChild("PlayerGui")
local bp = plr:WaitForChild("Backpack")

local farmActive, statsActive, weapon = false, {Melee=false,Defense=false,Sword=false,["Demon Fruit"]=false}, "Melee"

-- ==================== GUI ====================
local sg = Instance.new("ScreenGui"); sg.Name="MobileCombatGUI"; sg.Parent=pg; sg.ResetOnSpawn=false

local fb = Instance.new("TextButton")
fb.Name="FB"; fb.Size=UDim2.new(0,54,0,54); fb.Position=UDim2.new(0.82,0,0.04,0)
fb.BackgroundColor3=Color3.fromRGB(25,25,25); fb.BorderSizePixel=0
fb.TextColor3=Color3.fromRGB(255,200,50); fb.Text="+"; fb.Font=Enum.Font.SourceSansBold
fb.TextSize=28; fb.AutoButtonColor=false; fb.Parent=sg

local mf = Instance.new("Frame")
mf.Name="MF"; mf.Size=UDim2.new(0.92,0,0.7,0); mf.Position=UDim2.new(0.04,0,0.14,0)
mf.BackgroundColor3=Color3.fromRGB(18,18,18); mf.BorderSizePixel=0; mf.Visible=true; mf.Parent=sg

local tb = Instance.new("Frame")
tb.Size=UDim2.new(1,0,0,44); tb.BackgroundColor3=Color3.fromRGB(28,28,28); tb.BorderSizePixel=0; tb.Parent=mf
local tt = Instance.new("TextLabel")
tt.Size=UDim2.new(1,-16,1,0); tt.Position=UDim2.new(0,8,0,0); tt.BackgroundTransparency=1
tt.TextColor3=Color3.fromRGB(255,200,50); tt.Text="Mobile Combat"; tt.Font=Enum.Font.SourceSansBold
tt.TextSize=17; tt.TextXAlignment=Enum.TextXAlignment.Left; tt.Parent=tb
local ln = Instance.new("Frame")
ln.Size=UDim2.new(1,0,0,2); ln.Position=UDim2.new(0,0,0,44)
ln.BackgroundColor3=Color3.fromRGB(255,200,50); ln.BorderSizePixel=0; ln.Parent=mf

local sf = Instance.new("ScrollingFrame")
sf.Size=UDim2.new(1,-10,1,-54); sf.Position=UDim2.new(0,5,0,48)
sf.CanvasSize=UDim2.new(0,0,0,520); sf.ScrollBarThickness=5
sf.ScrollBarImageColor3=Color3.fromRGB(255,200,50); sf.BackgroundTransparency=1; sf.BorderSizePixel=0; sf.Parent=mf
local ul = Instance.new("UIListLayout")
ul.Padding=UDim.new(0,8); ul.HorizontalAlignment=Enum.HorizontalAlignment.Center
ul.SortOrder=Enum.SortOrder.LayoutOrder; ul.Parent=sf

-- helpers
local function sec(title,ord)
 local s=Instance.new("Frame"); s.Size=UDim2.new(1,-6,0,0); s.BackgroundColor3=Color3.fromRGB(26,26,26)
 s.BorderSizePixel=0; s.LayoutOrder=ord; s.Parent=sf
 local tl=Instance.new("TextLabel"); tl.Size=UDim2.new(1,-16,0,26); tl.Position=UDim2.new(0,8,0,5)
 tl.BackgroundTransparency=1; tl.TextColor3=Color3.fromRGB(255,200,50); tl.Text=title
 tl.Font=Enum.Font.SourceSansBold; tl.TextSize=15; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.Parent=s
 local cc=Instance.new("Frame"); cc.Name="C"; cc.Size=UDim2.new(1,-14,0,0); cc.Position=UDim2.new(0,7,0,34)
 cc.BackgroundTransparency=1; cc.BorderSizePixel=0; cc.Parent=s
 local cl=Instance.new("UIListLayout"); cl.Padding=UDim.new(0,6)
 cl.HorizontalAlignment=Enum.HorizontalAlignment.Center; cl.SortOrder=Enum.SortOrder.LayoutOrder; cl.Parent=cc
 return s,cc
end

local function tog(parent,txt,bn,ord)
 local tf=Instance.new("Frame"); tf.Size=UDim2.new(1,0,0,46); tf.BackgroundColor3=Color3.fromRGB(36,36,36)
 tf.BorderSizePixel=0; tf.LayoutOrder=ord; tf.Parent=parent
 local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(0.6,0,1,0); lb.Position=UDim2.new(0,10,0,0)
 lb.BackgroundTransparency=1; lb.TextColor3=Color3.fromRGB(235,235,235); lb.Text=txt
 lb.Font=Enum.Font.SourceSansSemibold; lb.TextSize=15; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=tf
 local bt=Instance.new("TextButton"); bt.Name=bn; bt.Size=UDim2.new(0,52,0,27)
 bt.Position=UDim2.new(1,-66,0.5,-13); bt.BackgroundColor3=Color3.fromRGB(65,65,65); bt.BorderSizePixel=0
 bt.TextColor3=Color3.fromRGB(255,255,255); bt.Text="OFF"; bt.Font=Enum.Font.SourceSansBold
 bt.TextSize=13; bt.AutoButtonColor=false; bt.Parent=tf
 return bt
end

local function cyc(parent,lab,opts,bn,ord)
 local cf=Instance.new("Frame"); cf.Size=UDim2.new(1,0,0,46); cf.BackgroundColor3=Color3.fromRGB(36,36,36)
 cf.BorderSizePixel=0; cf.LayoutOrder=ord; cf.Parent=parent
 local lb=Instance.new("TextLabel"); lb.Size=UDim2.new(0.38,0,1,0); lb.Position=UDim2.new(0,10,0,0)
 lb.BackgroundTransparency=1; lb.TextColor3=Color3.fromRGB(235,235,235); lb.Text=lab
 lb.Font=Enum.Font.SourceSansSemibold; lb.TextSize=15; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Parent=cf
 local bt=Instance.new("TextButton"); bt.Name=bn; bt.Size=UDim2.new(0,105,0,27)
 bt.Position=UDim2.new(1,-120,0.5,-13); bt.BackgroundColor3=Color3.fromRGB(255,200,50); bt.BorderSizePixel=0
 bt.TextColor3=Color3.fromRGB(20,20,20); bt.Text=opts[1]; bt.Font=Enum.Font.SourceSansBold
 bt.TextSize=14; bt.AutoButtonColor=false; bt.Parent=cf
 return bt
end

-- secciones
local fc,cc1 = sec("Auto Farm",1)
local fbtn = tog(cc1,"Activar Auto Farm","FarmBtn",1)
local wbtn = cyc(cc1,"Arma:",{"Melee","Sword","Fruit","Gun"},"WpnBtn",2)

local sc,cc2 = sec("Auto Stats",2)
local sd = Instance.new("TextLabel"); sd.Size=UDim2.new(1,0,0,22); sd.BackgroundTransparency=1
sd.TextColor3=Color3.fromRGB(160,160,160); sd.Text="Sube automaticamente al subir de nivel"
sd.Font=Enum.Font.SourceSans; sd.TextSize=12; sd.TextXAlignment=Enum.TextXAlignment.Left
sd.LayoutOrder=0; sd.Parent=cc2

local sbtns = {}
for i,n in ipairs({"Melee","Defense","Sword","Demon Fruit"}) do sbtns[n]=tog(cc2,n,n.."Btn",i) end

local ic,cc3 = sec("Info",3)
local il = Instance.new("TextLabel"); il.Size=UDim2.new(1,0,0,55); il.BackgroundTransparency=1
il.TextColor3=Color3.fromRGB(180,180,180); il.Text="Mobile Combat GUI v2\nDelta Executor compatible\nTactil | Bajo consumo"
il.Font=Enum.Font.SourceSans; il.TextSize=12; il.TextXAlignment=Enum.TextXAlignment.Left
il.TextYAlignment=Enum.TextYAlignment.Top; il.LayoutOrder=0; il.Parent=cc3

-- ajustar altura de secciones
local function fixHeights()
 local total = 0
 for _,v in ipairs(sf:GetChildren()) do if v:IsA("Frame") and v.LayoutOrder then total=total+v.AbsoluteSize.Y+8 end end
 sf.CanvasSize = UDim2.new(0,0,0,math.max(total,500))
end
fixHeights()

-- ==================== LOGICA ====================

local function equipTool(name)
 local c=plr.Character; if not c then return false end
 local h=c:FindFirstChildOfClass("Humanoid"); if not h then return false end
 local ct=c:FindFirstChildOfClass("Tool"); if ct and ct.Name==name then return true end
 local t=bp:FindFirstChild(name); if t then h:EquipTool(t); return true end
 return false
end

local function findTool(wt)
 for _,t in ipairs(bp:GetChildren()) do
  if t:IsA("Tool") then
   local n=t.Name:lower()
   if wt=="Melee" and not n:find("gun") and not n:find("fruit") and not n:find("pistol") and not n:find("rifle") then return t.Name
   elseif wt=="Sword" and (n:find("sword") or n:find("espada") or n:find("blade") or n:find("katana") or n:find("saber")) then return t.Name
   elseif wt=="Fruit" and (n:find("fruit") or n:find("fruta")) then return t.Name
   elseif wt=="Gun" and (n:find("gun") or n:find("pistol") or n:find("rifle") or n:find("bazooka")) then return t.Name
   end
  end
 end
 local all=bp:GetChildren(); if wt=="Melee" and #all>0 then return all[1].Name end; return nil
end

local function nearestNPC()
 local c=plr.Character; if not c then return end
 local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
 local near,nd=nil,math.huge
 for _,o in ipairs(workspace:GetDescendants()) do
  if o:IsA("Model") and o~=c then
   local h=o:FindFirstChildOfClass("Humanoid"); local r=o:FindFirstChild("HumanoidRootPart")
   if h and r and h.Health>0 and not Players:GetPlayerFromCharacter(o) then
    local d=(hrp.Position-r.Position).Magnitude; if d<nd then near,nd=o,d end
   end
  end
 end
 return near
end

local function moveAbove(tgt)
 local c=plr.Character; if not c or not tgt then return end
 local hrp=c:FindFirstChild("HumanoidRootPart"); local tr=tgt:FindFirstChild("HumanoidRootPart")
 if not hrp or not tr then return end
 local dest=tr.Position+Vector3.new(0,7,0)
 local tw=TweenService:Create(hrp,TweenInfo.new(0.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=CFrame.new(dest)})
 tw:Play(); tw.Completed:Wait()
end

local function attack()
 pcall(function()
  local vim = game:GetService("VirtualInputManager")
  vim:SendMouseButtonEvent(0,0,0,true,game,0); wait(0.08)
  vim:SendMouseButtonEvent(0,0,0,false,game,0)
 end)
 pcall(function()
  local vim = game:GetService("VirtualUser")
  vim:CaptureController(); vim:ClickButton1(Vector2.new()); wait(0.08); vim:ClickButton1(Vector2.new())
 end)
end

local function farmLoop()
 if not farmActive then return end
 local c=plr.Character; if not c then wait(0.5); farmLoop(); return end
 local h=c:FindFirstChildOfClass("Humanoid"); if not h or h.Health<=0 then wait(0.5); farmLoop(); return end
 local t=nearestNPC(); if not t then wait(0.5); farmLoop(); return end
 local tn=findTool(weapon); if tn then equipTool(tn) end
 moveAbove(t); attack(); wait(0.25); farmLoop()
end

local function statsLoop()
 while statsActive.Melee or statsActive.Defense or statsActive.Sword or statsActive["Demon Fruit"] do
  local ls=plr:FindFirstChild("leaderstats")
  if ls then
   local pts=ls:FindFirstChild("Points") or ls:FindFirstChild("StatPoints") or ls:FindFirstChild("SkillPoints")
   if pts and pts.Value>0 then
    local rem=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if rem then
     local add=rem:FindFirstChild("AddStat") or rem:FindFirstChild("UpgradeStat")
     if add then
      if statsActive.Melee then pcall(function() add:FireServer("Melee") end) end
      if statsActive.Defense then pcall(function() add:FireServer("Defense") end) end
      if statsActive.Sword then pcall(function() add:FireServer("Sword") end) end
      if statsActive["Demon Fruit"] then pcall(function() add:FireServer("Demon Fruit") end) end
     end
    end
   end
  end
  wait(1)
 end
end

-- ==================== CONEXIONES ====================

fbtn.MouseButton1Click:Connect(function()
 farmActive=not farmActive
 if farmActive then fbtn.BackgroundColor3=Color3.fromRGB(255,200,50); fbtn.Text="ON"; fbtn.TextColor3=Color3.fromRGB(20,20,20); farmLoop()
 else fbtn.BackgroundColor3=Color3.fromRGB(65,65,65); fbtn.Text="OFF"; fbtn.TextColor3=Color3.fromRGB(255,255,255)
 end
end)

local wopts={"Melee","Sword","Fruit","Gun"}; local widx=1
wbtn.MouseButton1Click:Connect(function()
 widx=widx+1; if widx>#wopts then widx=1 end; weapon=wopts[widx]; wbtn.Text=weapon
end)

for _,n in ipairs({"Melee","Defense","Sword","Demon Fruit"}) do
 local b=sbtns[n]; if b then
  b.MouseButton1Click:Connect(function()
   statsActive[n]=not statsActive[n]
   if statsActive[n] then b.BackgroundColor3=Color3.fromRGB(255,200,50); b.Text="ON"; b.TextColor3=Color3.fromRGB(20,20,20); statsLoop()
   else b.BackgroundColor3=Color3.fromRGB(65,65,65); b.Text="OFF"; b.TextColor3=Color3.fromRGB(255,255,255)
   end
  end)
 end
end

-- ==================== FLOTANTE + TACTIL ====================

fb.MouseButton1Click:Connect(function() mf.Visible=not mf.Visible end)

local drag,ds,sp
fb.InputBegan:Connect(function(inp)
 if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then
  drag=true; ds=inp.Position; sp=fb.Position
 end
end)
fb.InputChanged:Connect(function(inp)
 if drag and (inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseMovement) then
  local d=inp.Position-ds; fb.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
 end
end)
fb.InputEnded:Connect(function(inp)
 if inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.MouseButton1 then drag=nil end
end)

-- pantalla
local function adj()
 local cam=workspace.CurrentCamera; if not cam then return end
 local ss=cam.ViewportSize
 if ss.X<400 then fb.Size=UDim2.new(0,44,0,44); fb.TextSize=22 end
 if ss.X>800 then mf.Size=UDim2.new(0.65,0,0.6,0); mf.Position=UDim2.new(0.175,0,0.2,0) end
end
adj()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adj) end

-- respawn
plr.CharacterAdded:Connect(function(c) wait(0.4); if farmActive then farmLoop() end end)
