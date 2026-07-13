-- scripts/Client/Controllers/LabController.lua
--
-- Lab/inventory screen. Shows owned units with place/unplace actions,
-- lab slot usage, and a rebirth button.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.Theme)
local Panel = require(script.Parent.Parent.Components.Panel)
local Card = require(script.Parent.Parent.Components.Card)
local Button = require(script.Parent.Parent.Components.Button)
local Badge = require(script.Parent.Parent.Components.Badge)
local ScrollList = require(script.Parent.Parent.Components.ScrollList)
local StateManager = require(script.Parent.Parent.StateManager)

local LabController = {}

local panel = nil
local unitCards = {}

local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)
local PlaceUnitEvent = ReplicatedStorage.Remotes.PlaceUnit
local UnplaceUnitEvent = ReplicatedStorage.Remotes.UnplaceUnit
local RebirthEvent = ReplicatedStorage.Remotes.Rebirth

local BASE_LAB_SLOTS = 6

local RARITY_COLORS = {
    Common    = Color3.fromRGB(160, 160, 170),
    Uncommon  = Color3.fromRGB( 80, 200, 100),
    Rare      = Color3.fromRGB( 80, 140, 230),
    Epic      = Color3.fromRGB(180,  90, 220),
    Legendary = Color3.fromRGB(240, 190,  60),
}

local function countPlaced(state, unitName)
    local count = 0
    for _, p in ipairs(state.PlacedUnits) do
        if p.UnitName == unitName then count += 1 end
    end
    return count
end

function LabController.Init(screenGui)
    panel = Panel.new({
        Name = "LabPanel",
        Title = "LAB",
        Size = UDim2.new(0.85, 0, 0.8, 0),
        Parent = screenGui,
    })

    -- Slots display
    local slotsLabel = Instance.new("TextLabel")
    slotsLabel.Name = "SlotsLabel"
    slotsLabel.Size = UDim2.new(1, 0, 0, 18)
    slotsLabel.BackgroundTransparency = 1
    slotsLabel.Font = Theme.Font.Small
    slotsLabel.TextSize = Theme.TextSize.Small
    slotsLabel.TextColor3 = Theme.Colors.TextDim
    slotsLabel.TextXAlignment = Enum.TextXAlignment.Left
    slotsLabel.Text = "Slots: 0 / " .. BASE_LAB_SLOTS
    slotsLabel.Parent = panel.Content

    local scroll = ScrollList.new({
        Name = "InventoryList",
        Size = UDim2.new(1, 0, 1, -50),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundTransparency = 0,
        Parent = panel.Content,
    })

    -- Rebirth button at bottom
    local rebirthBtn = Button.new({
        Name = "RebirthBtn",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 1, -38),
        Text = "REBIRTH (100,000 RP)",
        Color = Theme.Colors.Warning,
        OnClick = function()
            RebirthEvent:FireServer()
        end,
        Parent = panel.Content,
    })

    local player = Players.LocalPlayer

    -- Build cards for each unit type on first show
    local function rebuildCards(state)
        -- Clear old cards
        for _, child in ipairs(scroll._Instance:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        unitCards = {}

        local totalPlaced = #state.PlacedUnits

        for i, unitName in ipairs(UnitDatabase.Order) do
            local unitInfo = UnitDatabase.Units[unitName]
            if not unitInfo then continue end

            local owned = state.OwnedUnits[unitName] or 0
            if owned <= 0 then continue end

            local placed = countPlaced(state, unitName)

            local card = Card.new({
                Name = unitName,
                AccentColor = RARITY_COLORS[unitInfo.Rarity],
                LayoutOrder = i,
                Parent = scroll,
            })

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(0.5, 0, 0, 18)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Theme.Font.Heading
            nameLabel.TextSize = Theme.TextSize.Body
            nameLabel.TextColor3 = Theme.Colors.TextPrimary
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Text = unitName
            nameLabel.Parent = card.Content

            local countLabel = Instance.new("TextLabel")
            countLabel.Size = UDim2.new(0.5, 0, 0, 14)
            countLabel.Position = UDim2.new(0, 0, 0, 20)
            countLabel.BackgroundTransparency = 1
            countLabel.Font = Theme.Font.Small
            countLabel.TextSize = Theme.TextSize.Small
            countLabel.TextColor3 = Theme.Colors.TextDim
            countLabel.TextXAlignment = Enum.TextXAlignment.Left
            countLabel.Text = string.format("Owned: %d  |  Placed: %d", owned, placed)
            countLabel.Parent = card.Content

            local placeBtn = Button.new({
                Name = "PlaceBtn",
                Size = UDim2.new(0, 55, 0, 24),
                Position = UDim2.new(1, -120, 1, -30),
                Text = "PLACE",
                Color = Theme.Colors.Success,
                Disabled = placed >= owned or totalPlaced >= BASE_LAB_SLOTS,
                OnClick = function()
                    PlaceUnitEvent:FireServer(unitName)
                end,
                Parent = card.Content,
            })

            local unplaceBtn = Button.new({
                Name = "UnplaceBtn",
                Size = UDim2.new(0, 55, 0, 24),
                Position = UDim2.new(1, -60, 1, -30),
                Text = "REMOVE",
                Color = Theme.Colors.Error,
                Disabled = placed <= 0,
                OnClick = function()
                    UnplaceUnitEvent:FireServer(unitName)
                end,
                Parent = card.Content,
            })

            unitCards[unitName] = {
                Card = card,
                CountLabel = countLabel,
                PlaceBtn = placeBtn,
                UnplaceBtn = unplaceBtn,
            }
        end

        slotsLabel.Text = string.format("Slots: %d / %d", totalPlaced, BASE_LAB_SLOTS)

        -- Update rebirth button state
        local rpValue = player:FindFirstChild("leaderstats")
            and player.leaderstats:FindFirstChild("Rot Points")
        if rpValue then
            rebirthBtn:SetDisabled(rpValue.Value < 100000)
        end
    end

    -- Rebuild on state change
    StateManager.Subscribe(rebuildCards)

    -- Listen for RP changes to update rebirth button
    local leaderstats = player:WaitForChild("leaderstats", 10)
    if leaderstats then
        local rp = leaderstats:WaitForChild("Rot Points", 5)
        if rp then
            rp.Changed:Connect(function(v)
                rebirthBtn:SetDisabled(v < 100000)
            end)
        end
    end
end

function LabController.Show()
    if panel then panel.Visible = true end
end

function LabController.Hide()
    if panel then panel.Visible = false end
end

return LabController
