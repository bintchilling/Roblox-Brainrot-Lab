-- scripts/Scene/Spawn.server.lua
--
-- Code-defined spawn point for the Brainrot Lab. Players join, fall
-- onto this SpawnLocation, and face the plot. SpawnLocation is the
-- only Part type that will actually respawn players on it — a regular
-- Part with the same shape will not.
--
-- For a single-player prototype, this is just the player's starting
-- position. For a multi-player launch, the spawn will eventually need
-- to be per-player (one spawn per plot), but for now one shared spawn
-- is fine because the prototype's only multi-player feature (trading)
-- is initiated via Remote, not by proximity.

local function buildSpawn()
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "SpawnLocation"
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = Vector3.new(0, 1, 30) -- 30 studs in front of the plot
    spawn.Anchored = true
    spawn.CanCollide = true
    spawn.Transparency = 0.5 -- see-through so it doesn't block the view
    spawn.Neutral = true -- don't force-team the player
    spawn.Parent = workspace
end

buildSpawn()
