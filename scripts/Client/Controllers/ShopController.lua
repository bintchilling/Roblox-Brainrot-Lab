-- scripts/Client/Controllers/ShopController.lua
--
-- Unit purchase screen. Displays all units from UnitDatabase with buy
-- buttons, cost, income, and owned counts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.Theme)
local Panel = require(script.Parent.Parent.Components.Panel)
local Card = require(script.Parent.Parent.Components.Card)
local Button = require(script.Parent.Parent.Components.Button)
local ScrollList = require(script.Parent.Parent.Components.ScrollList)
local StateManager = require(script.Parent.Parent.StateManager)

local ShopController = {}

local panel = nil
local unitCards = {}

local UnitDatabase = require(ReplicatedStorage.Shared.UnitDatabase)
local BuyUnitEvent = ReplicatedStorage.Remotes.BuyUnit

local RARITY_COLORS = {
    Common    = Color3.fromRGB(160, 160, 170),
    Uncommon  = Color3.fromRGB( 80, 200, 100),
    Rare      = Color3.fromRGB( 80, 140, 230),
    Epic      = Color3.fromRGB(180,  90, 220),
    Legendary = Color3.fromRGB(240, 190,  60),
}

function ShopController.Init(screenGui)
    panel = Panel.new({
        Name = "ShopPanel",
        Title = "UNIT SHOP",
        Size = UDim2.new(0.85, 0, 0.8, 0),
        Parent = screenGui,
    })

    local scroll = ScrollList.new({
        Name = "UnitList",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0,
        Parent = panel.Content,
    })

    local player = Players.LocalPlayer

    for i, unitName in ipairs(UnitDatabase.Order) do
        local unitInfo = UnitDatabase.Units[unitName]
        if not unitInfo then continue end

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

        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(0.5, 0, 0, 14)
        rarityLabel.Position = UDim2.new(0, 0, 0, 20)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Font = Theme.Font.Small
        rarityLabel.TextSize = Theme.TextSize.Small
        rarityLabel.TextColor3 = RARITY_COLORS[unitInfo.Rarity]
        rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
        rarityLabel.Text = unitInfo.Rarity
        rarityLabel.Parent = card.Content

        local costLabel = Instance.new("TextLabel")
        costLabel.Size = UDim2.new(0.5, 0, 0, 14)
        costLabel.Position = UDim2.new(0, 0, 0, 36)
        costLabel.BackgroundTransparency = 1
        costLabel.Font = Theme.Font.Small
        costLabel.TextSize = Theme.TextSize.Small
        costLabel.TextColor3 = Theme.Colors.Gold
        costLabel.TextXAlignment = Enum.TextXAlignment.Left
        costLabel.Text = string.format("Cost: %d RP", unitInfo.BaseCost)
        costLabel.Parent = card.Content

        local incomeLabel = Instance.new("TextLabel")
        incomeLabel.Size = UDim2.new(0.5, 0, 0, 14)
        incomeLabel.Position = UDim2.new(0, 0, 0, 50)
        incomeLabel.BackgroundTransparency = 1
        incomeLabel.Font = Theme.Font.Small
        incomeLabel.TextSize = Theme.TextSize.Small
        incomeLabel.TextColor3 = Theme.Colors.Success
        incomeLabel.TextXAlignment = Enum.TextXAlignment.Left
        incomeLabel.Text = string.format("+%d/s", unitInfo.BaseIncome)
        incomeLabel.Parent = card.Content

        local ownedLabel = Instance.new("TextLabel")
        ownedLabel.Name = "OwnedLabel"
        ownedLabel.Size = UDim2.new(0, 60, 0, 14)
        ownedLabel.Position = UDim2.new(1, -70, 0, 6)
        ownedLabel.BackgroundTransparency = 1
        ownedLabel.Font = Theme.Font.Small
        ownedLabel.TextSize = Theme.TextSize.Small
        ownedLabel.TextColor3 = Theme.Colors.TextDim
        ownedLabel.TextXAlignment = Enum.TextXAlignment.Right
        ownedLabel.Text = "Owned: 0"
        ownedLabel.Parent = card.Content

        local buyBtn = Button.new({
            Name = "BuyBtn",
            Size = UDim2.new(0, 60, 0, 28),
            Position = UDim2.new(1, -70, 1, -34),
            Text = "BUY",
            Color = Theme.Colors.Primary,
            OnClick = function()
                print("[ShopController] BUY clicked →", unitName, "| Remote:", BuyUnitEvent ~= nil)
                BuyUnitEvent:FireServer(unitName)
            end,
            Parent = card.Content,
        })

        unitCards[unitName] = {
            Card = card,
            OwnedLabel = ownedLabel,
            BuyBtn = buyBtn,
        }
    end

    -- Update cards when state changes
    StateManager.Subscribe(function(state)
        for unitName, data in pairs(unitCards) do
            local owned = state.OwnedUnits[unitName] or 0
            data.OwnedLabel.Text = string.format("Owned: %d", owned)

            local rpValue = player:FindFirstChild("leaderstats")
                and player.leaderstats:FindFirstChild("Rot Points")
            local unitInfo = UnitDatabase.Units[unitName]
            if rpValue and unitInfo and unitInfo.BaseCost > 0 then
                data.BuyBtn:SetDisabled(rpValue.Value < unitInfo.BaseCost)
            end
        end
    end)

    -- Listen for RP changes to update buy button states
    local leaderstats = player:WaitForChild("leaderstats", 10)
    if leaderstats then
        local rp = leaderstats:WaitForChild("Rot Points", 5)
        if rp then
            rp.Changed:Connect(function(v)
                for unitName, data in pairs(unitCards) do
                    local unitInfo = UnitDatabase.Units[unitName]
                    if unitInfo and unitInfo.BaseCost > 0 then
                        data.BuyBtn:SetDisabled(v < unitInfo.BaseCost)
                    end
                end
            end)
        end
    end
end

function ShopController.Show()
    if panel then panel.Visible = true end
end

function ShopController.Hide()
    if panel then panel.Visible = false end
end

return ShopController
