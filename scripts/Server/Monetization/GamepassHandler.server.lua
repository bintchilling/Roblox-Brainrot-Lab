local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local DataManager = require(script.Parent.Parent.Data.DataManager)

local GAMEPASS_IDS = {
    DoubleIncome = 0, -- put your real gamepass ID here
    AutoCollect  = 0,
    ExtraSlots   = 0,
}

local function ownsGamepass(player, gamepassId)
    if gamepassId == 0 then return false end
    local success, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
    end)
    return success and owns
end

local function checkGamepasses(player)
    local data = DataManager.Get(player)
    if not data then return end

    for name, id in pairs(GAMEPASS_IDS) do
        if ownsGamepass(player, id) then
            data.Gamepasses[name] = true
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    task.wait(1) -- give DataManager.Load a moment to run first
    checkGamepasses(player)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
    if wasPurchased then
        checkGamepasses(player)
    end
end)
