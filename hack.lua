-- SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- JUGADOR LOCAL
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ESTADOS
local objetivoBloqueado = nil
local estaVolando = false
local estaNoclipeando = false
local velocidadVuelo = 40
local distanciaAgarre = 3 -- Qué tan pegado quedas al enemigo
local conexiones = {}

-- ==============================================
-- GUI 1: AGARRE AL MÁS CERCANO (MUY CHICA)
-- ==============================================
local GuiAgarre = Instance.new("ScreenGui")
GuiAgarre.Name = "GuiAgarreEnemigo"
GuiAgarre.ResetOnSpawn = false
GuiAgarre.Parent = PlayerGui

local MarcoAgarre = Instance.new("Frame")
MarcoAgarre.Size = UDim2.new(0, 130, 0, 50) -- Muy reducido
MarcoAgarre.Position = UDim2.new(0.01,0,0.5,0)
MarcoAgarre.BackgroundColor3 = Color3.fromRGB(22,22,30)
MarcoAgarre.Active = true
MarcoAgarre.Draggable = true
MarcoAgarre.Parent = GuiAgarre

local BotonAgarre = Instance.new("TextButton")
BotonAgarre.Size = UDim2.new(1,0,1,0)
BotonAgarre.BackgroundColor3 = Color3.fromRGB(50,130,220)
BotonAgarre.Text = "AGARRAR"
BotonAgarre.TextScaled = true
BotonAgarre.TextColor3 = Color3.new(1,1,1)
BotonAgarre.Parent = MarcoAgarre

-- ==============================================
-- GUI 2: VUELO + NOCLIP (MUY CHICA)
-- ==============================================
local GuiVuelo = Instance.new("ScreenGui")
GuiVuelo.Name = "GuiVueloMovil"
GuiVuelo.ResetOnSpawn = false
GuiVuelo.Parent = PlayerGui

local MarcoVuelo = Instance.new("Frame")
MarcoVuelo.Size = UDim2.new(0, 130, 0, 90) -- Reducido
MarcoVuelo.Position = UDim2.new(0.01,0,0.58,0)
MarcoVuelo.BackgroundColor3 = Color3.fromRGB(22,22,30)
MarcoVuelo.Active = true
MarcoVuelo.Draggable = true
MarcoVuelo.Parent = GuiVuelo

local BotonVuelo = Instance.new("TextButton")
BotonVuelo.Size = UDim2.new(0.9,0,0.42,0)
BotonVuelo.Position = UDim2.new(0.05,0,0.05,0)
BotonVuelo.BackgroundColor3 = Color3.fromRGB(40,170,80)
BotonVuelo.Text = "VUELO"
BotonVuelo.TextScaled = true
BotonVuelo.TextColor3 = Color3.new(1,1,1)
BotonVuelo.Parent = MarcoVuelo

local BotonNoclip = Instance.new("TextButton")
BotonNoclip.Size = UDim2.new(0.9,0,0.42,0)
BotonNoclip.Position = UDim2.new(0.05,0,0.53,0)
BotonNoclip.BackgroundColor3 = Color3.fromRGB(190,70,70)
BotonNoclip.Text = "NOCLIP"
BotonNoclip.TextScaled = true
BotonNoclip.TextColor3 = Color3.new(1,1,1)
BotonNoclip.Parent = MarcoVuelo

-- ==============================================
-- FUNCIÓN: OBTENER JUGADOR MÁS CERCANO
-- ==============================================
local function obtenerMasCercano()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local miPos = char.HumanoidRootPart.Position
    local masCercano, distMin = nil, math.huge

    for _,j in pairs(Players:GetPlayers()) do
        if j~=LocalPlayer and j.Character and j.Character:FindFirstChild("HumanoidRootPart") and j.Character.Humanoid.Health>0 then
            local d = (miPos - j.Character.HumanoidRootPart.Position).Magnitude
            if d < distMin then distMin = d; masCercano = j end
        end
    end
    return masCercano
end

-- ==============================================
-- LÓGICA AGARRE: QUEDAS PEGADO AL ENEMIGO
-- ==============================================
BotonAgarre.MouseButton1Click:Connect(function()
    if objetivoBloqueado then
        objetivoBloqueado = nil
        BotonAgarre.Text = "AGARRAR"
        BotonAgarre.BackgroundColor3 = Color3.fromRGB(50,130,220)
    else
        objetivoBloqueado = obtenerMasCercano()
        if objetivoBloqueado then
            BotonAgarre.Text = "SOLTAR"
            BotonAgarre.BackgroundColor3 = Color3.fromRGB(210,60,60)
        end
    end
end)

-- ==============================================
-- LÓGICA VUELO: FUNCIONA EN MOVIL, NO DEPENDE DE TECLAS
-- ==============================================
local function alternarVuelo()
    estaVolando = not estaVolando
    BotonVuelo.Text = estaVolando and "DESACTIVAR" or "VUELO"
    BotonVuelo.BackgroundColor3 = estaVolando and Color3.fromRGB(210,60,60) or Color3.fromRGB(40,170,80)

    if estaVolando then
        conexiones.Vuelo = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            hum.PlatformStand = true
            hum.GravityScale = 0

            -- SI TIENES OBJETIVO: TE MANTIENES PEGADO A ÉL
            if objetivoBloqueado and objetivoBloqueado.Character and objetivoBloqueado.Character:FindFirstChild("HumanoidRootPart") then
                local objHRP = objetivoBloqueado.Character.HumanoidRootPart
                -- Te ajusta la distancia automáticamente
                hrp.CFrame = CFrame.new(objHRP.Position, objHRP.Position + (hrp.Position - objHRP.Position)) * CFrame.new(0,0,-distanciaAgarre)
            end

            -- MOVIMIENTO LIBRE: funciona con joystick de movil y teclado
            local dir = Vector3.new()
            if hum.MoveDirection.Magnitude > 0 then
                dir = hum.MoveDirection
            else
                -- Si no mueves nada: avanzas hacia donde mira la cámara
                dir = Camera.CFrame.LookVector
            end

            -- Subir/bajar con toque en pantalla o teclas
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,0.6,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir += Vector3.new(0,-0.6,0) end

            hrp.AssemblyLinearVelocity = dir * velocidadVuelo
        end)
    else
        if conexiones.Vuelo then conexiones.Vuelo:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
            LocalPlayer.Character.Humanoid.GravityScale = 1
        end
    end
end

-- ==============================================
-- LÓGICA NOCLIP
-- ==============================================
local function alternarNoclip()
    estaNoclipeando = not estaNoclipeando
    BotonNoclip.Text = estaNoclipeando and "DESACTIVAR" or "NOCLIP"
    BotonNoclip.BackgroundColor3 = estaNoclipeando and Color3.fromRGB(40,170,80) or Color3.fromRGB(190,70,70)

    if estaNoclipeando then
        conexiones.Noclip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = not estaNoclipeando end
                end
            end
        end)
    else
        if conexiones.Noclip then conexiones.Noclip:Disconnect() end
        if LocalPlayer.Character then
            for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end

-- CONECTAR BOTONES
BotonVuelo.MouseButton1Click:Connect(alternarVuelo)
BotonNoclip.MouseButton1Click:Connect(alternarNoclip)
