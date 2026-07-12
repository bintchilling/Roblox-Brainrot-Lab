local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.Parent.Data.DataManager)

local DailyEvent = ReplicatedStorage.Remotes.ClaimDaily
local SECONDS_IN_DAY = 86400

DailyEvent.OnServerEvent:Connect(function(player)
    local data = DataManager.Get(player)
    if not data then return end

    local now = os.time()
    local elapsed = now - data.LastDailyClaim

    if elapsed < SECONDS_IN_DAY then
        return -- too early, not eligible yet
    end

    if elapsed < SECONDS_IN_DAY * 2 then
        data.DailyStreak += 1
    else
        data.DailyStreak = 1 -- streak reset, but no punishment beyond that
    end

    local reward = 100 * data.DailyStreak
    data.RotPoints += reward
    data.LastDailyClaim = now

    -- Weekly chest: every 7 daily claims (not necessarily consecutive days),
    -- grant a bonus. Missing a day never resets this counter, only skips it
    -- forward slower — same reward-only philosophy as the daily streak.
    data.WeeklyClaims += 1
    local gotWeeklyChest = false
    if data.WeeklyClaims >= 7 then
        data.WeeklyClaims = 0
        data.Fragments += 5
        data.RotPoints += 500
        gotWeeklyChest = true
    end

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats["Rot Points"].Value = data.RotPoints
    end

    DailyEvent:FireClient(player, reward, data.DailyStreak, gotWeeklyChest)
end)
