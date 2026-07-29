local RS = game:GetService("RunService")
local WP = game:GetService("Workspace")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local MAX_RANGE = 15
local ATTRACT_SPEED = 8
local BASE_SIZE = 10
local SLOT_SIZE = 3
local FLOOR_Y_OFFSET = 3

local collected = {}
local slots = {}
local slotIndex = 0
local baseActive = false

local function isCharacterPart(part)
    local p = part.Parent
    while p do
        if p:IsA("Model") and p:FindFirstChild("Humanoid") then return true end
        p = p.Parent
    end
    return false
end

local function isAlreadyCollected(part)
    for _, v in pairs(collected) do
        if v.part == part then return true end
    end
    return false
end

local function getSlotPosition(index)
    local layer = math.floor((index) / (BASE_SIZE * BASE_SIZE))
    local inLayer = index % (BASE_SIZE * BASE_SIZE)
    local row = math.floor(inLayer / BASE_SIZE)
    local col = inLayer % BASE_SIZE
    local half = (BASE_SIZE - 1) / 2 * SLOT_SIZE
    local x = (col - half / SLOT_SIZE) * SLOT_SIZE
    local z = (row - half / SLOT_SIZE) * SLOT_SIZE
    if layer == 0 then
        return Vector3.new(x, FLOOR_Y_OFFSET, z)
    else
        local y = FLOOR_Y_OFFSET + layer * SLOT_SIZE
        if row == 0 then
            return Vector3.new(x, y, -half)
        elseif row == BASE_SIZE - 1 then
            return Vector3.new(x, y, half)
        elseif col == 0 then
            return Vector3.new(-half, y, z)
        elseif col == BASE_SIZE - 1 then
            return Vector3.new(half, y, z)
        else
            return nil
        end
    end
end

local function getNextSlot()
    while true do
        local pos = getSlotPosition(slotIndex)
        slotIndex = slotIndex + 1
        if pos then
            local occupied = false
            for _, v in pairs(collected) do
                if v.slotIndex == slotIndex - 1 then
                    occupied = true
                    break
                end
            end
            if not occupied then
                return slotIndex - 1, pos
            end
        end
    end
end

RS.Heartbeat:Connect(function(dt)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local rootPos = hrp.Position

    for _, part in WP:GetDescendants() do
        if not part:IsA("BasePart") then continue end
        if part.Anchored then continue end
        if isCharacterPart(part) then continue end
        if isAlreadyCollected(part) then continue end
        if part:FindFirstChild("BodyPosition") then continue end

        local dist = (part.Position - rootPos).Magnitude
        if dist <= MAX_RANGE then
            local si, slotPos = getNextSlot()
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(50000, 50000, 50000)
            bp.P = ATTRACT_SPEED
            bp.D = 3
            bp.Parent = part
            part.Anchored = false
            table.insert(collected, {part = part, bp = bp, slotIndex = si})
            baseActive = true
        end
    end

    if not baseActive then return end

    local baseOrigin = rootPos
    for _, entry in pairs(collected) do
        local part = entry.part
        local bp = entry.bp
        if not part or not part.Parent then continue end
        local si = entry.slotIndex
        local slotPos = getSlotPosition(si)
        if slotPos then
            local target = baseOrigin + slotPos
            bp.Position = target
        end
    end
end)
