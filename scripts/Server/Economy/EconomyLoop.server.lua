local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(script.Parent.Parent.Data.DataManager)
local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)

local ACCUMULATE_INTERVAL = 1 -- seconds between income ticks
local accumulator = 0

RunService.Heartbeat:Connect(function(dt)
    accumulator += dt
    if accumulator < ACCUMULATE_INTERVAL then
        return
    end
    accumulator = 0

    for _, player in ipairs(Players:GetPlayers()) do
        local data = DataManager.Get(player)
        if not data then continue end

        local incomeThisTick = 0
        for _, placed in ipairs(data.PlacedUnits) do
            local unitInfo = UnitDatabase.Units[placed.UnitName]
            if unitInfo then
                incomeThisTick += unitInfo.BaseIncome
            end
        end

        if data.Gamepasses["DoubleIncome"] then
            incomeThisTick *= 2
        end

        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local ir = leaderstats:FindFirstChild("IncomeRate")
            if ir then
                ir.Value = incomeThisTick
            end
        end

        if incomeThisTick > 0 then
            data.RotPoints += incomeThisTick

            if leaderstats then
                local rp = leaderstats:FindFirstChild("Rot Points")
                if rp then
                    rp.Value = data.RotPoints
                end
            end
        end
    end
end)
