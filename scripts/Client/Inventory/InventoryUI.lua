-- scripts/Client/Inventory/InventoryUI.lua
--
-- THROWAWAY PROTOTYPE UI — replace with a proper framework when the UI grows
-- beyond 5 buttons. Imperative Instance.new throughout, no styling, no
-- animations. Scope: one ScreenGui, one Frame, one row per UnitDatabase entry
-- with Buy / Place / Unplace buttons. Driven entirely off the
-- InventoryUpdated RemoteEvent; seeded on first render via GetInventory.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local BuyUnit = ReplicatedStorage.Remotes.BuyUnit
local PlaceUnit = ReplicatedStorage.Remotes.PlaceUnit
local UnplaceUnit = ReplicatedStorage.Remotes.UnplaceUnit
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated
local GetInventory = ReplicatedStorage.Remotes.GetInventory

-- Mirrors the server's InventoryHandler.BASE_LAB_SLOTS. Gamepass bonus
-- (ExtraSlots) ignored for the throwaway — the server will silently reject
-- 7th+ placements if the player somehow has the gamepass.
local BASE_LAB_SLOTS = 6

-- Cached state. The server is the source of truth — these are just the
-- values the most recent InventoryUpdated push gave us.
local ownedUnits = {}  -- { [UnitName] = count }
local placedUnits = {} -- { {UnitName = "..."}, ... }
local slotsUsed = 0

-- Build the GUI once, on first run. Everything past this point is rebuild
-- of the row contents, not the chrome.

local gui = Instance.new("ScreenGui")
gui.Name = "InventoryUI"
gui.ResetOnSpawn = true
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Inventory"
frame.AnchorPoint = Vector2.new(0, 1)
frame.Position = UDim2.new(0, 16, 1, -16)
frame.Size = UDim2.new(0, 420, 0, 360)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
frame.BorderSizePixel = 0
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Brainrot Lab"
title.Parent = frame

local rotPointsLabel = Instance.new("TextLabel")
rotPointsLabel.Name = "RotPoints"
rotPointsLabel.Position = UDim2.new(0, 0, 0, 32)
rotPointsLabel.Size = UDim2.new(1, 0, 0, 24)
rotPointsLabel.BackgroundTransparency = 1
rotPointsLabel.Font = Enum.Font.Gotham
rotPointsLabel.TextSize = 16
rotPointsLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
rotPointsLabel.TextXAlignment = Enum.TextXAlignment.Left
rotPointsLabel.Text = "Rot Points: 0"
rotPointsLabel.Parent = frame

local list = Instance.new("Frame")
list.Name = "List"
list.Position = UDim2.new(0, 0, 0, 60)
list.Size = UDim2.new(1, 0, 1, -60)
list.BackgroundTransparency = 1
list.Parent = frame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = list

-- One row per unit. Rebuilt every time the cache changes — the diff is
-- trivial (5 rows) and not worth a per-row update path for a throwaway.
local function buildRow(unitName, unitInfo)
    local row = Instance.new("Frame")
    row.Name = "Row_" .. unitName
    row.Size = UDim2.new(1, -8, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
    row.BorderSizePixel = 0
    row.Parent = list

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 160, 1, 0)
    nameLabel.Position = UDim2.new(0, 8, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = string.format("%s (%d RP)", unitName, unitInfo.BaseCost)
    nameLabel.Parent = row

    local ownedLabel = Instance.new("TextLabel")
    ownedLabel.Name = "Owned"
    ownedLabel.Size = UDim2.new(0, 70, 1, 0)
    ownedLabel.Position = UDim2.new(0, 172, 0, 0)
    ownedLabel.BackgroundTransparency = 1
    ownedLabel.Font = Enum.Font.Gotham
    ownedLabel.TextSize = 14
    ownedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    ownedLabel.TextXAlignment = Enum.TextXAlignment.Left
    ownedLabel.Text = "x0"
    ownedLabel.Parent = row

    local buyButton = Instance.new("TextButton")
    buyButton.Name = "Buy"
    buyButton.Size = UDim2.new(0, 50, 0, 24)
    buyButton.Position = UDim2.new(0, 244, 0.5, -12)
    buyButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
    buyButton.BorderSizePixel = 0
    buyButton.Font = Enum.Font.GothamBold
    buyButton.TextSize = 14
    buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyButton.Text = "Buy"
    buyButton.Parent = row
    buyButton.MouseButton1Click:Connect(function()
        BuyUnit:FireServer(unitName)
    end)

    local placeButton = Instance.new("TextButton")
    placeButton.Name = "Place"
    placeButton.Size = UDim2.new(0, 50, 0, 24)
    placeButton.Position = UDim2.new(0, 300, 0.5, -12)
    placeButton.BackgroundColor3 = Color3.fromRGB(70, 100, 150)
    placeButton.BorderSizePixel = 0
    placeButton.Font = Enum.Font.GothamBold
    placeButton.TextSize = 14
    placeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    placeButton.Text = "Place"
    placeButton.Parent = row
    placeButton.MouseButton1Click:Connect(function()
        PlaceUnit:FireServer(unitName)
    end)

    local unplaceButton = Instance.new("TextButton")
    unplaceButton.Name = "Unplace"
    unplaceButton.Size = UDim2.new(0, 60, 0, 24)
    unplaceButton.Position = UDim2.new(0, 356, 0.5, -12)
    unplaceButton.BackgroundColor3 = Color3.fromRGB(150, 70, 70)
    unplaceButton.BorderSizePixel = 0
    unplaceButton.Font = Enum.Font.GothamBold
    unplaceButton.TextSize = 14
    unplaceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    unplaceButton.Text = "Unplace"
    unplaceButton.Parent = row
    unplaceButton.MouseButton1Click:Connect(function()
        UnplaceUnit:FireServer(unitName)
    end)
end

local function rebuildRows()
    -- Tear down existing rows. Cheap; 5 children max.
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Iterate UnitDatabase so the order is stable and matches the
    -- documentation / rarity progression. Don't trust ownedUnits / placedUnits
    -- keys for the row set.
    for unitName, unitInfo in pairs(UnitDatabase.Units) do
        buildRow(unitName, unitInfo)
    end

    -- Refresh the per-row state in place (avoids the "buttons flash" you'd
    -- get from a full teardown + rebuild on every cache update).
    for _, child in ipairs(list:GetChildren()) do
        if not child:IsA("Frame") then continue end
        local unitName = child.Name:sub(5) -- strip "Row_" prefix
        local owned = ownedUnits[unitName] or 0
        local placedOfKind = 0
        for _, p in ipairs(placedUnits) do
            if p.UnitName == unitName then
                placedOfKind += 1
            end
        end

        local ownedLabel = child:FindFirstChild("Owned")
        if ownedLabel then
            ownedLabel.Text = string.format("x%d (%d placed)", owned, placedOfKind)
        end

        local placeButton = child:FindFirstChild("Place")
        if placeButton then
            -- Server will reject anyway, but disabling is friendlier feedback.
            placeButton.Active = not (slotsUsed >= BASE_LAB_SLOTS or placedOfKind >= owned)
        end

        local unplaceButton = child:FindFirstChild("Unplace")
        if unplaceButton then
            unplaceButton.Active = placedOfKind > 0
        end
    end
end

local function applyUpdate(newOwned, newPlaced)
    ownedUnits = newOwned or {}
    placedUnits = newPlaced or {}
    slotsUsed = #placedUnits
    rebuildRows()
end

-- Live updates from any server-side mutation (Buy / Place / Unplace / Rebirth).
InventoryUpdated.OnClientEvent:Connect(function(newOwned, newPlaced)
    applyUpdate(newOwned, newPlaced)
end)

-- One-time seed on join. GetInventory returns {} when the player's data
-- isn't loaded yet — fine, InventoryUpdated will fill it in moments later.
local seedOwned, seedPlaced = GetInventory:InvokeServer()
applyUpdate(seedOwned, seedPlaced)

-- RotPoints label follows leaderstats. Server is the only writer; we just
-- read.
local leaderstats = player:WaitForChild("leaderstats")
local rotPointsValue = leaderstats:WaitForChild("Rot Points")
local function refreshRotPoints()
    rotPointsLabel.Text = string.format("Rot Points: %d", math.floor(rotPointsValue.Value))
end
rotPointsValue.Changed:Connect(refreshRotPoints)
refreshRotPoints()
