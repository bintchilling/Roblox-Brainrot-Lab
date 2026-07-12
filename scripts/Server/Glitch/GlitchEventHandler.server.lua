local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

local GlitchEvent = ReplicatedStorage.Remotes.GlitchTriggered
local GlitchClicked = ReplicatedStorage.Remotes.GlitchClicked

local MIN_INTERVAL = 180 -- 3 minutes
local MAX_INTERVAL = 360 -- 6 minutes
local GLITCH_WINDOW = 8  -- seconds the player has to react

local activeGlitches = {} -- [player] = index into PlacedUnits

local function startGlitchLoop(player)
    while player.Parent do
        task.wait(math.random(MIN_INTERVAL, MAX_INTERVAL))

        local data = DataManager.Get(player)
        if data and #data.PlacedUnits > 0 then
            local index = math.random(1, #data.PlacedUnits)
            activeGlitches[player] = index
            GlitchEvent:FireClient(player, index)

            task.delay(GLITCH_WINDOW, function()
                if activeGlitches[player] == index then
                    activeGlitches[player] = nil -- expired — no penalty, just gone
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(startGlitchLoop, player)
end)

Players.PlayerRemoving:Connect(function(player)
    activeGlitches[player] = nil
end)

GlitchClicked.OnServerEvent:Connect(function(player, index)
    if type(index) ~= "number" then return end

    if activeGlitches[player] == index then
        local data = DataManager.Get(player)
        if data then
            local bonus = math.random(50, 150)
            data.RotPoints += bonus

            local leaderstats = player:FindFirstChild("leaderstats")
            if leaderstats then
                leaderstats["Rot Points"].Value = data.RotPoints
            end

            GlitchClicked:FireClient(player, true, bonus)
        end
        activeGlitches[player] = nil
    end
end)
