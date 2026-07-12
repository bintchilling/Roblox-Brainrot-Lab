local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)

local BuyUnitEvent = ReplicatedStorage.Remotes.BuyUnit
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated

BuyUnitEvent.OnServerEvent:Connect(function(player, unitName)
    -- Always validate remote input on the server — never trust the client.
    if type(unitName) ~= "string" then return end

    local data = DataManager.Get(player)
    if not data then return end

    local unitInfo = UnitDatabase.Units[unitName]
    if not unitInfo then return end -- unknown unit name, ignore silently

    local ownedCount = data.OwnedUnits[unitName] or 0
    local cost = math.floor(unitInfo.BaseCost * (1.15 ^ ownedCount))

    if data.RotPoints < cost then
        return -- not enough currency
    end

    data.RotPoints -= cost
    data.OwnedUnits[unitName] = ownedCount + 1

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats["Rot Points"].Value = data.RotPoints
    end

    InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
end)
