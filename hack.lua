local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer = Players.LocalPlayer

local function getShieldButton()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    
    local touchGui = playerGui:FindFirstChild("TouchGui")
    if touchGui then
        local touchFrame = touchGui:FindFirstChild("TouchControlFrame")
        if touchFrame then
            return touchFrame:FindFirstChild("ShieldButton") or touchFrame:FindFirstChild("BlockButton") or touchFrame:FindFirstChild("JumpButton")
        end
    end
    return nil
end

local function triggerShield()
    local shieldBtn = getShieldButton()
    if shieldBtn then
        local pos = shieldBtn.AbsolutePosition + (shieldBtn.AbsoluteSize / 2)
        VirtualInputManager:SendTouchTapEvent(pos.X, pos.Y)
    else
        ContextActionService:CallFunction("Block", Enum.UserInputState.Begin, nil)
        task.wait(0.2)
        ContextActionService:CallFunction("Block", Enum.UserInputState.End, nil)
    end
end

local function watchCharacter(char)
    if char == LocalPlayer.Character then return end
    local humanoid = char:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    local animator = humanoid:WaitForChild("Animator", 5)
    if not animator then return end
    
    animator.AnimationPlayed:Connect(function(track)
        task.delay(0.1, function()
            local waitTime = math.max(0, track.Length - 0.3)
            task.wait(waitTime)
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("HumanoidRootPart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if dist <= 15 then
                    triggerShield()
                end
            end
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then watchCharacter(player.Character) end
        player.CharacterAdded:Connect(watchCharacter)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(watchCharacter)
end)
