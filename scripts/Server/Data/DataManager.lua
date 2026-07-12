local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

-- GetDataStore itself can throw if "Studio Access to API Services" is off
-- (the default for any unpublished place). Wrap it so the whole module
-- doesn't fail to load — every other script requires this one, so an
-- unguarded error here takes down the entire server.
local PlayerDataStore
do
    local success, result = pcall(function()
        return DataStoreService:GetDataStore("BrainrotTycoon_v1")
    end)
    if success then
        PlayerDataStore = result
    else
        warn("DataStores unavailable in this session (enable 'Studio Access to API Services' " ..
            "under Game Settings > Security, or publish the place). Falling back to " ..
            "in-memory-only data for this playtest — nothing will persist between sessions.")
    end
end

local DataManager = {}
local Cache = {}

local DEFAULT_DATA = {
    RotPoints = 0,
    OwnedUnits = {},   -- { [UnitName] = countOwned }
    PlacedUnits = {},  -- { {UnitName = "..."}, ... } only placed units earn income
    Rebirths = 0,
    LastDailyClaim = 0,
    DailyStreak = 0,
    WeeklyClaims = 0,       -- counts toward the weekly chest (resets every 7 claims)
    Fragments = 0,          -- cosmetic currency from Glitch Fragments / weekly chests
    Gamepasses = {},   -- { [PassName] = true }
}

local function DeepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            copy[k] = DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function DataManager.Load(player)
    if not PlayerDataStore then
        Cache[player.UserId] = DeepCopy(DEFAULT_DATA)
        return Cache[player.UserId]
    end

    local key = "Player_" .. player.UserId
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(key)
    end)

    if success and data then
        Cache[player.UserId] = data
    else
        Cache[player.UserId] = DeepCopy(DEFAULT_DATA)
        if not success then
            warn("Failed to load data for " .. player.Name .. " — using defaults")
        end
    end

    return Cache[player.UserId]
end

function DataManager.Get(player)
    return Cache[player.UserId]
end

function DataManager.Save(player)
    if not PlayerDataStore then return end

    local data = Cache[player.UserId]
    if not data then return end

    local key = "Player_" .. player.UserId
    local success, err = pcall(function()
        PlayerDataStore:SetAsync(key, data)
    end)

    if not success then
        warn("Failed to save data for " .. player.Name .. ": " .. tostring(err))
    end
end

function DataManager.Remove(player)
    Cache[player.UserId] = nil
end

Players.PlayerRemoving:Connect(function(player)
    DataManager.Save(player)
    DataManager.Remove(player)
end)

game:BindToClose(function()
    for _, player in ipairs(Players:GetPlayers()) do
        DataManager.Save(player)
    end
end)

return DataManager
