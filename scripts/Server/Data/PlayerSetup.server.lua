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

    -- Fragments is the cosmetic currency from Glitch Fragments / weekly
    -- chests. Exposed on the leaderboard so players can see it without
    -- a UI screen, and so the Glitch reward change is testable in
    -- isolation before the rest of the client exists.
    local fragments = Instance.new("IntValue")
    fragments.Name = "Fragments"
    fragments.Value = data.Fragments
    fragments.Parent = leaderstats

    local incomeRate = Instance.new("NumberValue")
    incomeRate.Name = "IncomeRate"
    incomeRate.Value = 0
    incomeRate.Parent = leaderstats
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Handles the case where this script starts after some players already joined
for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end
