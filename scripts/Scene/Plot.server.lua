-- scripts/Scene/Plot.server.lua
--
-- Code-defined scaffold for the Brainrot Lab's main plot. The prototype's
-- UI is built around placing units on this plot, so it needs to exist
-- before any UI work is testable. This is intentionally minimal — see
-- Docs/SceneSetup.md for how to dress it up further in Studio.
--
-- What this script does:
--   1. Creates a Model "Lab" in Workspace (the parent for all scene parts)
--   2. Creates a 50x50 Part as the floor of the lab
--   3. Creates a base plate underneath so the lab looks like it sits on
--      something instead of floating in space
--
-- What this script does NOT do (yet):
--   - Place any unit visuals on the plot (the UI will add Parts when the
--     player places a unit, see scripts/Client/Inventory/InventoryUI.lua
--     when that lands)
--   - Provide lighting, skybox, or atmosphere (decorative, see SceneSetup.md)
--   - Provide any plot divisions (the plot is one open surface right now)

local function buildPlot()
    local lab = Instance.new("Model")
    lab.Name = "Lab"
    lab.Parent = workspace

    -- The plot floor itself. 50x50 studs is enough room for the 6 base
    -- placement slots (1.15^owned cost curve means most players will
    -- use a handful of slots, not fill the whole plot).
    local plot = Instance.new("Part")
    plot.Name = "Plot"
    plot.Size = Vector3.new(50, 1, 50)
    plot.Position = Vector3.new(0, 0.5, 0) -- sit on top of y=0
    plot.Anchored = true
    plot.CanCollide = true
    plot.Material = Enum.Material.SmoothPlastic
    plot.Color = Color3.fromRGB(60, 60, 70) -- dark grey, makes unit Parts pop
    plot.Parent = lab

    -- A base plate underneath so the lab doesn't look like a floating
    -- tile. Sized larger than the plot so it shows the edge of the world
    -- beneath.
    local baseplate = Instance.new("Part")
    baseplate.Name = "Baseplate"
    baseplate.Size = Vector3.new(100, 1, 100)
    baseplate.Position = Vector3.new(0, -0.5, 0)
    baseplate.Anchored = true
    baseplate.CanCollide = true
    baseplate.Material = Enum.Material.Grass
    baseplate.Color = Color3.fromRGB(80, 140, 70) -- grass green
    baseplate.Parent = lab
end

buildPlot()
