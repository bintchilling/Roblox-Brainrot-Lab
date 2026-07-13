-- scripts/Client/ClientBootstrap/init.server.lua
--
-- Entry point for the client GUI system. Requires all controllers,
-- initializes state, wires up remote event listeners, and orchestrates
-- screen switching via NavigationController.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Prevent double execution from RunContext clone behavior
if playerGui:FindFirstChild("BrainrotLabGUI") then
    return
end

-- Create the root ScreenGui (all UI must live inside one)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotLabGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Require core modules
local StateManager = require(script.Parent.StateManager)

-- Require controllers
local NavigationController = require(script.Parent.Controllers.NavigationController)
local HUDController = require(script.Parent.Controllers.HUDController)
local ShopController = require(script.Parent.Controllers.ShopController)
local LabController = require(script.Parent.Controllers.LabController)
local SettingsController = require(script.Parent.Controllers.SettingsController)
local RebirthController = require(script.Parent.Controllers.RebirthController)

-- Wait for remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local InventoryUpdated = Remotes:WaitForChild("InventoryUpdated")
local GetInventory = Remotes:WaitForChild("GetInventory")

-- Initialize controllers (they create their GUIs, hidden by default)
NavigationController.Init(screenGui)
HUDController.Init(screenGui)
ShopController.Init(screenGui)
LabController.Init(screenGui)
SettingsController.Init(screenGui)
RebirthController.Init(screenGui)

-- Wire navigation to controllers
NavigationController.RegisterScreen("shop", ShopController)
NavigationController.RegisterScreen("lab", LabController)
NavigationController.RegisterScreen("settings", SettingsController)

-- Connect live inventory listener BEFORE any yielding calls
InventoryUpdated.OnClientEvent:Connect(function(newOwned, newPlaced)
    StateManager.Update(newOwned, newPlaced)
end)

-- Seed initial state from server (non-blocking)
task.spawn(function()
    local ok, owned, placed = pcall(function()
        return GetInventory:InvokeServer()
    end)
    if ok then
        StateManager.Update(owned, placed)
    else
        warn("[ClientBootstrap] GetInventory failed:", owned)
    end
end)

print("[ClientBootstrap] GUI system initialized")
