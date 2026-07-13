local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)

local PlaceUnitEvent = ReplicatedStorage.Remotes.PlaceUnit
local UnplaceUnitEvent = ReplicatedStorage.Remotes.UnplaceUnit
local GetInventory = ReplicatedStorage.Remotes.GetInventory
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated

local BASE_LAB_SLOTS = 6
local EXTRA_SLOTS_BONUS = 4 -- granted by the ExtraSlots gamepass

-- Rarity -> Color3 for the placed-unit Part. Purely cosmetic, makes the lab
-- look like a lab instead of a row of identical boxes.
local RARITY_COLORS = {
    Common    = Color3.fromRGB(160, 160, 170),
    Uncommon  = Color3.fromRGB( 80, 200, 100),
    Rare      = Color3.fromRGB( 80, 140, 230),
    Epic      = Color3.fromRGB(180,  90, 220),
    Legendary = Color3.fromRGB(240, 190,  60),
}

-- 3x2 grid on the 50x50 plot, centered at origin. Slot i (1-indexed) lands
-- at SLOT_POSITIONS[i]. Sized 4x4x4 with 15-stud pitch so the 6 parts fit
-- comfortably with room to walk between them.
local SLOT_POSITIONS = {
    Vector3.new(-15, 1.5,  -7.5),
    Vector3.new(  0, 1.5,  -7.5),
    Vector3.new( 15, 1.5,  -7.5),
    Vector3.new(-15, 1.5,   7.5),
    Vector3.new(  0, 1.5,   7.5),
    Vector3.new( 15, 1.5,   7.5),
}

local function maxSlots(data)
    local max = BASE_LAB_SLOTS
    if data.Gamepasses["ExtraSlots"] then
        max += EXTRA_SLOTS_BONUS
    end
    return max
end

local function countPlaced(data, unitName)
    local count = 0
    for _, placed in ipairs(data.PlacedUnits) do
        if placed.UnitName == unitName then
            count += 1
        end
    end
    return count
end

-- The Placements folder lives under workspace.Lab (created by
-- scripts/Scene/Plot.server.lua). Built lazily on first use so this script
-- doesn't need to assume a particular script load order.
local function getPlacementsFolder()
    local lab = workspace:FindFirstChild("Lab")
    if not lab then return nil end

    local folder = lab:FindFirstChild("Placements")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "Placements"
        folder.Parent = lab
    end
    return folder
end

local function placeUnitPart(unitName, slotIndex)
    local folder = getPlacementsFolder()
    if not folder then return end

    local unitInfo = UnitDatabase.Units[unitName]
    if not unitInfo then return end

    local part = Instance.new("Part")
    part.Name = "Placed_" .. unitName
    part.Size = Vector3.new(4, 4, 4)
    part.Anchored = true
    part.CanCollide = true
    part.Material = Enum.Material.SmoothPlastic
    part.Color = RARITY_COLORS[unitInfo.Rarity] or Color3.fromRGB(200, 200, 200)
    part.Position = SLOT_POSITIONS[slotIndex] or Vector3.new(0, 1.5, 0)
    part.Parent = folder
end

local function removeFirstUnitPart(unitName)
    local folder = getPlacementsFolder()
    if not folder then return end

    for _, child in ipairs(folder:GetChildren()) do
        if child.Name == "Placed_" .. unitName then
            child:Destroy()
            return
        end
    end
end

GetInventory.OnServerInvoke = function(player)
    local data = DataManager.Get(player)
    if not data then return {}, {} end
    return data.OwnedUnits, data.PlacedUnits
end

PlaceUnitEvent.OnServerEvent:Connect(function(player, unitName)
    print("[InventoryHandler] PlaceUnit request:", player.Name, "→", tostring(unitName))

    if type(unitName) ~= "string" then
        warn("[InventoryHandler] Invalid unitName type:", typeof(unitName))
        return
    end

    local data = DataManager.Get(player)
    if not data then
        warn("[InventoryHandler] No data for", player.Name)
        return
    end

    if not UnitDatabase.Units[unitName] then
        warn("[InventoryHandler] Unknown unit:", unitName)
        return
    end

    if #data.PlacedUnits >= maxSlots(data) then
        warn("[InventoryHandler] Lab full for", player.Name)
        return
    end

    local owned = data.OwnedUnits[unitName] or 0
    local placed = countPlaced(data, unitName)
    print("[InventoryHandler] Owned:", owned, "Already placed:", placed, "Max slots:", maxSlots(data))

    if placed >= owned then
        warn("[InventoryHandler] No free copies of", unitName, "to place")
        return
    end

    table.insert(data.PlacedUnits, { UnitName = unitName })
    placeUnitPart(unitName, #data.PlacedUnits)

    print("[InventoryHandler] Placed", unitName, "→ slot", #data.PlacedUnits)

    -- Update IncomeRate leaderstat
    local ir = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("IncomeRate")
    if ir then
        local rate = 0
        for _, p in ipairs(data.PlacedUnits) do
            local u = UnitDatabase.Units[p.UnitName]
            if u then rate += u.BaseIncome end
        end
        if data.Gamepasses["DoubleIncome"] then rate *= 2 end
        ir.Value = rate
    end

    InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
end)

UnplaceUnitEvent.OnServerEvent:Connect(function(player, unitName)
    print("[InventoryHandler] UnplaceUnit request:", player.Name, "→", tostring(unitName))

    if type(unitName) ~= "string" then
        warn("[InventoryHandler] Invalid unitName type:", typeof(unitName))
        return
    end

    local data = DataManager.Get(player)
    if not data then
        warn("[InventoryHandler] No data for", player.Name)
        return
    end

    for i, placed in ipairs(data.PlacedUnits) do
        if placed.UnitName == unitName then
            table.remove(data.PlacedUnits, i)
            removeFirstUnitPart(unitName)

            print("[InventoryHandler] Unplaced", unitName, "→ remaining placed:", #data.PlacedUnits)

            -- Update IncomeRate leaderstat
            local ir = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("IncomeRate")
            if ir then
                local rate = 0
                for _, p in ipairs(data.PlacedUnits) do
                    local u = UnitDatabase.Units[p.UnitName]
                    if u then rate += u.BaseIncome end
                end
                if data.Gamepasses["DoubleIncome"] then rate *= 2 end
                ir.Value = rate
            end

            InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
            break
        end
    end
end)

-- THROWAWAY PROTOTYPE LIMITATION:
-- Parts are only created/destroyed in response to live PlaceUnit / UnplaceUnit
-- calls. Players who join a session with pre-placed units (loaded from
-- DataStore on a previous session) will see them in the UI but not on the
-- plot. To fix: rebuild the Placements folder per-player on PlayerAdded using
-- a UserId-keyed sub-folder, and clean up on PlayerRemoving. Defer to
-- post-prototype.
