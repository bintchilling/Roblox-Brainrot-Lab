local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)
local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)

local FuseEvent = ReplicatedStorage.Remotes.FuseUnits
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated

local function getUnitsOfRarity(rarity)
    local list = {}
    for name, info in pairs(UnitDatabase.Units) do
        if info.Rarity == rarity then
            table.insert(list, name)
        end
    end
    return list
end

FuseEvent.OnServerEvent:Connect(function(player, unitName)
    if type(unitName) ~= "string" then return end

    local data = DataManager.Get(player)
    if not data then return end

    local unitInfo = UnitDatabase.Units[unitName]
    if not unitInfo then return end

    local recipe = UnitDatabase.FusionRecipes[unitInfo.Rarity]
    if not recipe then return end -- already top rarity, nothing to fuse into

    local owned = data.OwnedUnits[unitName] or 0
    if owned < recipe.RequiredCount then return end

    data.OwnedUnits[unitName] = owned - recipe.RequiredCount

    local pool = getUnitsOfRarity(recipe.ResultRarity)
    if #pool == 0 then return end

    local resultUnit = pool[math.random(1, #pool)]
    data.OwnedUnits[resultUnit] = (data.OwnedUnits[resultUnit] or 0) + 1

    FuseEvent:FireClient(player, resultUnit)
    InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
end)
