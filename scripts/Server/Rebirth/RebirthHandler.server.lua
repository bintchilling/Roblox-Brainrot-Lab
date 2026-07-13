local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

local RebirthEvent = ReplicatedStorage.Remotes.Rebirth
local ConfirmRebirth = ReplicatedStorage.Remotes.ConfirmRebirth
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated
local REBIRTH_REQUIREMENT = 100000

RebirthEvent.OnServerEvent:Connect(function(player)
    local data = DataManager.Get(player)
    if not data then return end
    if data.RotPoints < REBIRTH_REQUIREMENT then return end

    ConfirmRebirth:FireClient(player, data.Rebirths + 1)
end)

ConfirmRebirth.OnServerEvent:Connect(function(player, confirmed)
    if type(confirmed) ~= "boolean" then return end
    if not confirmed then return end

    local data = DataManager.Get(player)
    if not data then return end
    if data.RotPoints < REBIRTH_REQUIREMENT then return end

    data.RotPoints = 0
    data.OwnedUnits = {}
    data.PlacedUnits = {}
    data.Rebirths += 1

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats["Rot Points"].Value = 0
        leaderstats["Rebirths"].Value = data.Rebirths
        local ir = leaderstats:FindFirstChild("IncomeRate")
        if ir then ir.Value = 0 end
    end

    RebirthEvent:FireClient(player, data.Rebirths)
    InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
end)
