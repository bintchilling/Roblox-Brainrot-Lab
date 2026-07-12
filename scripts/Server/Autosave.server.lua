local Players = game:GetService("Players")
local DataManager = require(script.Parent.Data.DataManager)

while true do
    task.wait(120) -- every 2 minutes
    for _, player in ipairs(Players:GetPlayers()) do
        DataManager.Save(player)
    end
end
