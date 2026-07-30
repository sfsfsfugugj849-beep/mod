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
local velocidadVuelo = 50
local conexiones = {}

-- ==============================================
-- FUNCIÓN: OBTENER JUGADOR MÁS CERCANO
-- ==============================================
local function obtenerJugadorMasCercano()
    local miPersonaje = LocalPlayer.Character
    if not miPersonaje or not miPersonaje:FindFirstChild("HumanoidRootPart") then return nil end
    local miPos = miPersonaje.HumanoidRootPart.Position

    local masCercano, distanciaMinima = nil, math.huge
    for _, jugador in ipairs(Players:GetPlayers()) do
        if jugador ~= LocalPlayer and jugador.Character 
        and jugador.Character:FindFirstChild("HumanoidRootPart") 
        and jugador.Character:FindFirstChild("Humanoid").Health > 0 then
            local dist = (miPos - jugador.Character.HumanoidRootPart.Position).Magnitude
            if dist < distanciaMinima then
                distanciaMinima = dist
                masCercano = jugador
            end
        end
    end
    return masCercano
end

-- ==============================================
-- GUI 1: BLOQUEAR JUGADOR MÁS CERCANO
-- ==============================================
local GuiBloquear = Instance.new("ScreenGui")
GuiBloquear.Name = "GuiBloqueoJugador"
GuiBloquear.ResetOnSpawn = false
GuiBloquear.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GuiBloquear.Parent = PlayerGui

local MarcoBloqueo = Instance.new("Frame")
MarcoBloqueo.Size = UDim2.new(0, 220, 0, 100)
MarcoBloqueo.Position = UDim2.new(0.02, 0, 0.3, 0)
MarcoBloqueo.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MarcoBloqueo.Active = true
MarcoBloqueo.Draggable = true
MarcoBloqueo.Parent = GuiBloquear

local BotonBloquear = Instance.new("TextButton")
BotonBloquear.Size = UDim2.new(0.9, 0, 0.4, 0)
BotonBloquear.Position = UDim2.new(0.05, 0, 0.1, 0)
BotonBloquear.BackgroundColor3 = Color3.fromRGB(45, 120, 200)
BotonBloquear.Text = "Bloquear más cercano"
BotonBloquear.TextColor3 = Color3.new(1,1,1)
BotonBloquear.Parent = MarcoBloqueo

local EtiquetaEstado = Instance.new("TextLabel")
EtiquetaEstado.Size = UDim2.new(0.9, 0, 0.3, 0)
EtiquetaEstado.Position = UDim2.new(0.05, 0, 0.55, 0)
EtiquetaEstado.BackgroundTransparency = 1
EtiquetaEstado.Text = "Sin objetivo"
EtiquetaEstado.TextColor3 = Color3.new(1,1,1)
EtiquetaEstado.Parent = MarcoBloqueo

BotonBloquear.MouseButton1Click:Connect(function()
    if objetivoBloqueado then
        objetivoBloqueado = nil
        EtiquetaEstado.Text = "Sin objetivo"
        BotonBloquear.Text = "Bloquear más cercano"
    else
        objetivoBloqueado = obtenerJugadorMasCercano()
        if objetivoBloqueado then
            EtiquetaEstado.Text = "Objetivo: "..objetivoBloqueado.Name
            BotonBloquear.Text = "Soltar objetivo"
        else
            EtiquetaEstado.Text = "No hay jugadores cerca"
        end
    end
end)

-- ==============================================
-- GUI 2: VUELO + NOCLIP
-- ==============================================
local GuiVuelo = Instance.new("ScreenGui")
GuiVuelo.Name = "GuiVueloNoclip"
GuiVuelo.ResetOnSpawn = false
GuiVuelo.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GuiVuelo.Parent = PlayerGui

local MarcoVuelo = Instance.new("Frame")
MarcoVuelo.Size = UDim2.new(0, 220, 0, 140)
MarcoVuelo.Position = UDim2.new(0.02, 0, 0.45, 0)
MarcoVuelo.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MarcoVuelo.Active = true
MarcoVuelo.Draggable = true
MarcoVuelo.Parent = GuiVuelo

local BotonVuelo = Instance.new("TextButton")
BotonVuelo.Size = UDim2.new(0.9, 0, 0.28, 0)
BotonVuelo.Position = UDim2.new(0.05, 0, 0.05, 0)
BotonVuelo.BackgroundColor3 = Color3.fromRGB(35, 160, 70)
BotonVuelo.Text = "Activar Vuelo"
BotonVuelo.TextColor3 = Color3.new(1,1,1)
BotonVuelo.Parent = MarcoVuelo

local BotonNoclip = Instance.new("TextButton")
BotonNoclip.Size = UDim2.new(0.9, 0, 0.28, 0)
BotonNoclip.Position = UDim2.new(0.05, 0, 0.38, 0)
BotonNoclip.BackgroundColor3 = Color3.fromRGB(180, 80, 80)
BotonNoclip.Text = "Activar Noclip"
BotonNoclip.TextColor3 = Color3.new(1,1,1)
BotonNoclip.Parent = MarcoVuelo

local EtiquetaVelocidad = Instance.new("TextLabel")
EtiquetaVelocidad.Size = UDim2.new(0.9, 0, 0.28, 0)
EtiquetaVelocidad.Position = UDim2.new(0.05, 0, 0.71, 0)
EtiquetaVelocidad.BackgroundTransparency = 1
EtiquetaVelocidad.Text = "Velocidad: "..velocidadVuelo
EtiquetaVelocidad.TextColor3 = Color3.new(1,1,1)
EtiquetaVelocidad.Parent = MarcoVuelo

-- ==============================================
-- LÓGICA DE VUELO
-- ==============================================
local function alternarVuelo()
    estaVolando = not estaVolando
    BotonVuelo.Text = estaVolando and "Desactivar Vuelo" or "Activar Vuelo"
    BotonVuelo.BackgroundColor3 = estaVolando and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(35, 160, 70)

    if estaVolando then
        conexiones.Vuelo = RunService.RenderStepped:Connect(function(delta)
            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            hum.PlatformStand = true
            hum.GravityScale = 0

            -- Si hay objetivo bloqueado: seguirlo
            if objetivoBloqueado and objetivoBloqueado.Character and objetivoBloqueado.Character:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = hrp.CFrame:Lerp(objetivoBloqueado.Character.HumanoidRootPart.CFrame, 0.08)
            end

            -- Movimiento libre + vuelo
            local dir = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0,-1,0) end

            if dir.Magnitude > 0 then dir = dir.Unit end
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
-- LÓGICA DE NOCLIP
-- ==============================================
local function alternarNoclip()
    estaNoclipeando = not estaNoclipeando
    BotonNoclip.Text = estaNoclipeando and "Desactivar Noclip" or "Activar Noclip"
    BotonNoclip.BackgroundColor3 = estaNoclipeando and Color3.fromRGB(35, 160, 70) or Color3.fromRGB(180, 80, 80)

    if estaNoclipeando then
        conexiones.Noclip = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, parte in ipairs(char:GetDescendants()) do
                if parte:IsA("BasePart") then parte.CanCollide = false end
            end
        end)
    else
        if conexiones.Noclip then conexiones.Noclip:Disconnect() end
        if LocalPlayer.Character then
            for _, parte in ipairs(LocalPlayer.Character:GetDescendants()) do
                if parte:IsA("BasePart") then parte.CanCollide = true end
            end
        end
    end
end

-- ==============================================
-- CONECTAR BOTONES
-- ==============================================
BotonVuelo.MouseButton1Click:Connect(alternarVuelo)
BotonNoclip.MouseButton1Click:Connect(alternarNoclip)
