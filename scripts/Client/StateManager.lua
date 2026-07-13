-- scripts/Client/StateManager.lua
--
-- Lightweight client-side state cache. Controllers read from here
-- instead of repeatedly invoking the server.

local StateManager = {}

local state = {
    OwnedUnits = {},
    PlacedUnits = {},
}

local subscribers = {}

function StateManager.Update(owned, placed)
    state.OwnedUnits = owned or {}
    state.PlacedUnits = placed or {}
    for _, callback in ipairs(subscribers) do
        callback(state)
    end
end

function StateManager.Get()
    return state
end

function StateManager.Subscribe(callback)
    table.insert(subscribers, callback)
end

return StateManager
