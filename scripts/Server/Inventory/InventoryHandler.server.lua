local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)

local PlaceUnitEvent = ReplicatedStorage.Remotes.PlaceUnit
local UnplaceUnitEvent = ReplicatedStorage.Remotes.UnplaceUnit
local GetInventory = ReplicatedStorage.Remotes.GetInventory
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated

local BASE_LAB_SLOTS = 6
local EXTRA_SLOTS_BONUS = 4 -- granted by the ExtraSlots gamepass

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

GetInventory.OnServerInvoke = function(player)
    local data = DataManager.Get(player)
    if not data then return {}, {} end
    return data.OwnedUnits, data.PlacedUnits
end

PlaceUnitEvent.OnServerEvent:Connect(function(player, unitName)
    if type(unitName) ~= "string" then return end

    local data = DataManager.Get(player)
    if not data then return end

    if not UnitDatabase.Units[unitName] then return end -- unknown unit, ignore

    if #data.PlacedUnits >= maxSlots(data) then
        return -- lab is full
    end

    local owned = data.OwnedUnits[unitName] or 0
    local placed = countPlaced(data, unitName)
    if placed >= owned then
        return -- every copy you own is already placed, nothing free to place
    end

    table.insert(data.PlacedUnits, { UnitName = unitName })
    InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
end)

UnplaceUnitEvent.OnServerEvent:Connect(function(player, unitName)
    if type(unitName) ~= "string" then return end

    local data = DataManager.Get(player)
    if not data then return end

    for i, placed in ipairs(data.PlacedUnits) do
        if placed.UnitName == unitName then
            table.remove(data.PlacedUnits, i)
            InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
            break
        end
    end
end)
