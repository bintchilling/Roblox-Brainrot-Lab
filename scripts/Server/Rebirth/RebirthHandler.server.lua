local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

local RebirthEvent = ReplicatedStorage.Remotes.Rebirth
local InventoryUpdated = ReplicatedStorage.Remotes.InventoryUpdated
local REBIRTH_REQUIREMENT = 100000

RebirthEvent.OnServerEvent:Connect(function(player)
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
    end

    RebirthEvent:FireClient(player, data.Rebirths)
    -- Push the freshly-emptied inventory too, otherwise the client UI keeps
    -- showing the pre-rebirth unit list. (THROWAWAY LIMITATION: placed Part
    -- visuals are not torn down here — they will linger on the plot until the
    -- player un-places them. Fix in a follow-up.)
    InventoryUpdated:FireClient(player, data.OwnedUnits, data.PlacedUnits)
end)
