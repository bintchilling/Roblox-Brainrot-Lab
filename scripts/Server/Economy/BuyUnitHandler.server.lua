local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)

local BuyUnitEvent = ReplicatedStorage.Remotes.BuyUnit
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated

print("[BuyUnitHandler] Server script loaded")

BuyUnitEvent.OnServerEvent:Connect(function(player, unitName)
    print("[BuyUnitHandler] Buy request from", player.Name, "→", tostring(unitName))

    if type(unitName) ~= "string" then
        warn("[BuyUnitHandler] Invalid unitName type:", typeof(unitName))
        return
    end

    local data = DataManager.Get(player)
    if not data then
        warn("[BuyUnitHandler] No data for", player.Name)
        return
    end

    local unitInfo = UnitDatabase.Units[unitName]
    if not unitInfo then
        warn("[BuyUnitHandler] Unknown unit:", unitName)
        return
    end

    local ownedCount = data.OwnedUnits[unitName] or 0
    local cost = math.floor(unitInfo.BaseCost * (1.15 ^ ownedCount))

    print("[BuyUnitHandler] RP:", data.RotPoints, "Cost:", cost, "Owned:", ownedCount)

    if data.RotPoints < cost then
        warn("[BuyUnitHandler] Not enough RP for", unitName)
        return
    end

    data.RotPoints -= cost
    data.OwnedUnits[unitName] = ownedCount + 1

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats["Rot Points"].Value = data.RotPoints
    end

    DataManager.Save(player)

    print("[BuyUnitHandler] Bought", unitName, "→ new RP:", data.RotPoints, "owned:", data.OwnedUnits[unitName])

    InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
end)
