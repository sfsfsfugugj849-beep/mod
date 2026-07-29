local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local function createFire()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Buscamos las manos dependiendo de si el avatar es R15 o R6
    local hands = {"RightHand", "LeftHand", "Right Arm", "Left Arm"}
    
    for _, partName in ipairs(hands) do
        local hand = char:FindFirstChild(partName)
        if hand then
            -- Crear el efecto de fuego
            local fire = Instance.new("Fire")
            fire.Size = 4
            fire.Heat = 15
            fire.Color = Color3.fromRGB(255, 100, 0)
            fire.SecondaryColor = Color3.fromRGB(255, 0, 0)
            fire.Parent = hand
            
            -- Eliminar el fuego despues de 2.5 segundos (tiempo de la habilidad)
            task.delay(2.5, function()
                if fire then fire:Destroy() end
            end)
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Detectar toque en la pantalla de celular
    if input.UserInputType == Enum.UserInputType.Touch then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        
        -- Obtener los elementos de la interfaz que fueron tocados
        local guis = playerGui:GetGuiObjectsAtPosition(input.Position.X, input.Position.Y)
        
        local isSkill1 = false
        for _, gui in ipairs(guis) do
            local name = string.lower(gui.Name)
            -- Comprueba nombres comunes para el botón de la habilidad 1 en la interfaz
            if name == "1" or name == "skill1" or name == "move1" or name == "ability1" or name == "button1" or name == "attack1" then
                isSkill1 = true
                break
            end
        end
        
        if isSkill1 then
            createFire()
        end
        
    -- Soporte para PC (Tecla 1) por si acaso
    elseif input.KeyCode == Enum.KeyCode.One then
        createFire()
    end
end)
