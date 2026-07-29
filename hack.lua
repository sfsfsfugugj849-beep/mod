local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local function pressMobileBlock()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        -- Busca el botón de bloqueo de Jujutsu Shenanigans en la interfaz de celular
        local blockBtn = playerGui:FindFirstChild("BlockButton", true) or playerGui:FindFirstChild("Block", true)
        if blockBtn and blockBtn:IsA("GuiObject") then
            local pos = blockBtn.AbsolutePosition + (blockBtn.AbsoluteSize / 2)
            VirtualInputManager:SendTouchTapEvent(pos.X, pos.Y)
        end
    end
    
    -- Acción de respaldo para activar el bloqueo del juego directamente
    pcall(function()
        ContextActionService:CallFunction("Block", Enum.UserInputState.Begin, nil)
        task.wait(0.35)
        ContextActionService:CallFunction("Block", Enum.UserInputState.End, nil)
    end)
end

local function monitorTarget(char)
    if char == LocalPlayer.Character then return end
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    local animator = humanoid:WaitForChild("Animator", 5)
    if not animator then return end
    
    animator.AnimationPlayed:Connect(function(track)
        -- Filtra animaciones cortas/ataques rápido (como M1 o habilidades)
        if track.Length > 0.15 then
            task.spawn(function()
                local delayTime = math.max(0, track.Length - 0.3)
                if delayTime > 0 then task.wait(delayTime) end
                
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                    if distance <= 18 then
                        pressMobileBlock()
                    end
                end
            end)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then monitorTarget(player.Character) end
        player.CharacterAdded:Connect(monitorTarget)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(monitorTarget)
end)
