local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

local RebirthEvent = ReplicatedStorage.Remotes.Rebirth
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
end)
