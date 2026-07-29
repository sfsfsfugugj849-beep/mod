local RS=game:GetService("RunService")
local WP=game.Workspace
local LP=game.Players.LocalPlayer
local MR=15
local cp={}
local si=0
local BS=10
local SS=3
local FY=3
local function ic(p)
	local m=p.Parent
	while m do
		if m:IsA("Model") and m:FindFirstChild("Humanoid") then return true end
		m=m.Parent
	end
	return false
end
local function ipc(p)
	for _,v in pairs(cp) do if v.p==p then return true end end
	return false
end
local function gsp(i)
	local l=math.floor(i/(BS*BS))
	local il=i%(BS*BS)
	local r=math.floor(il/BS)
	local c=il%BS
	local hf=(BS-1)/2*SS
	local x=(c-hf/SS)*SS
	local z=(r-hf/SS)*SS
	if l==0 then return Vector3.new(x,FY,z) end
	local y=FY+l*SS
	if r==0 then return Vector3.new(x,y,-hf)
	elseif r==BS-1 then return Vector3.new(x,y,hf)
	elseif c==0 then return Vector3.new(-hf,y,z)
	elseif c==BS-1 then return Vector3.new(hf,y,z)
	else return nil end
end
local function gns()
	for i=0,500 do
		local idx=si+i
		if gsp(idx) then
			local oc=false
			for _,v in pairs(cp) do if v.si==idx then oc=true break end end
			if not oc then si=idx+1 return idx,gsp(idx) end
		end
	end
	si=si+1
	return si-1,Vector3.new(0,FY,0)
end
RS.Heartbeat:Connect(function()
	local ch=LP.Character
	if not ch then return end
	local hr=ch:FindFirstChild("HumanoidRootPart")
	if not hr then return end
	local rp=hr.Position
	for _,o in WP:GetChildren() do
		if not o:IsA("Model") or o==WP then continue end
		if o:FindFirstChild("Humanoid") then continue end
		local parts={}
		for _,p in o:GetDescendants() do
			if p:IsA("BasePart") then table.insert(parts,p) end
		end
		if #parts==0 then continue end
		local mn=Vector3.new(9e9,9e9,9e9)
		local mx=Vector3.new(-9e9,-9e9,-9e9)
		for _,p in parts do
			local s=p.Size/2
			local c=p.CFrame.Position
			mn=Vector3.new(math.min(mn.X,c.X-s.X),math.min(mn.Y,c.Y-s.Y),math.min(mn.Z,c.Z-s.Z))
			mx=Vector3.new(math.max(mx.X,c.X+s.X),math.max(mx.Y,c.Y+s.Y),math.max(mx.Z,c.Z+s.Z))
		end
		local ct=(mn+mx)/2
		if (ct-rp).Magnitude<=MR then
			for _,p in parts do
				p.Anchored=false
				p.Parent=WP
			end
			if #o:GetChildren()==0 then o:Destroy() end
		end
	end
	for _,p in WP:GetChildren() do
		if not p:IsA("BasePart") then continue end
		if ic(p) then continue end
		if ipc(p) then continue end
		if p:FindFirstChild("BodyPosition") then continue end
		if (p.Position-rp).Magnitude<=MR then
			p.Anchored=false
			local s,sp=gns()
			local b=Instance.new("BodyPosition")
			b.MaxForce=Vector3.new(5e4,5e4,5e4)
			b.P=8
			b.D=3
			b.Parent=p
			table.insert(cp,{p=p,b=b,si=s})
		end
	end
	for _,v in pairs(cp) do
		if v.p and v.p.Parent then
			local sp=gsp(v.si)
			if sp then v.b.Position=rp+sp end
		end
	end
end)
