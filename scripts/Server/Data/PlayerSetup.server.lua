local Players = game:GetService("Players")
local DataManager = require(script.Parent.DataManager)

local function onPlayerAdded(player)
    local data = DataManager.Load(player)

    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local rotPoints = Instance.new("NumberValue")
    rotPoints.Name = "Rot Points"
    rotPoints.Value = data.RotPoints
    rotPoints.Parent = leaderstats

    local rebirths = Instance.new("IntValue")
    rebirths.Name = "Rebirths"
    rebirths.Value = data.Rebirths
    rebirths.Parent = leaderstats
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Handles the case where this script starts after some players already joined
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
