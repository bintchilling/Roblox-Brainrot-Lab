-- scripts/Client/Controllers/HUDController.lua
--
-- Always-visible top bar showing RotPoints, Fragments, Rebirths, IncomeRate.

local Players = game:GetService("Players")
local Theme = require(script.Parent.Parent.Theme)
local IconLabel = require(script.Parent.Parent.Components.IconLabel)

local HUDController = {}

local player = Players.LocalPlayer
local hudFrame = nil
local icons = {}

function HUDController.Init(screenGui)
    hudFrame = Instance.new("Frame")
    hudFrame.Name = "HUD"
    hudFrame.AnchorPoint = Vector2.new(0.5, 0)
    hudFrame.Position = UDim2.new(0.5, 0, 0, 4)
    hudFrame.Size = UDim2.new(1, -32, 0, Theme.Size.HUD)
    hudFrame.BackgroundColor3 = Theme.Colors.PanelBackground
    hudFrame.BackgroundTransparency = 0.2
    hudFrame.BorderSizePixel = 0
    hudFrame.Parent = screenGui

    Theme.newCorner(hudFrame, Theme.Corner.Small)
    Theme.applyBorder(hudFrame, Theme.Colors.Primary, Theme.Border.Thin)

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, Theme.Spacing.L)
    layout.Parent = hudFrame

    -- Wait for leaderstats
    local leaderstats = player:WaitForChild("leaderstats", 10)
    if not leaderstats then return end

    local rpValue = leaderstats:WaitForChild("Rot Points", 5)
    local fragValue = leaderstats:WaitForChild("Fragments", 5)
    local rebValue = leaderstats:WaitForChild("Rebirths", 5)
    local irValue = leaderstats:WaitForChild("IncomeRate", 5)

    -- RotPoints
    icons.rp = IconLabel.new({
        Name = "RotPoints",
        Label = "RP",
        Value = rpValue and rpValue.Value or 0,
        IconColor = Theme.Colors.Gold,
        TextColor = Theme.Colors.Gold,
        LayoutOrder = 1,
        Parent = hudFrame,
    })

    -- Fragments
    icons.frag = IconLabel.new({
        Name = "Fragments",
        Label = "Frag",
        Value = fragValue and fragValue.Value or 0,
        IconColor = Theme.Colors.Secondary,
        TextColor = Theme.Colors.Secondary,
        LayoutOrder = 2,
        Parent = hudFrame,
    })

    -- Rebirths
    icons.reb = IconLabel.new({
        Name = "Rebirths",
        Label = "RB",
        Value = rebValue and rebValue.Value or 0,
        IconColor = Theme.Colors.TextPrimary,
        TextColor = Theme.Colors.TextPrimary,
        LayoutOrder = 3,
        Parent = hudFrame,
    })

    -- IncomeRate
    icons.ir = IconLabel.new({
        Name = "IncomeRate",
        Label = "/s",
        Value = irValue and irValue.Value or 0,
        IconColor = Theme.Colors.Success,
        TextColor = Theme.Colors.Success,
        LayoutOrder = 4,
        Parent = hudFrame,
    })

    -- Connect change listeners
    if rpValue then
        rpValue.Changed:Connect(function(v)
            icons.rp:SetValue(math.floor(v))
        end)
    end

    if fragValue then
        fragValue.Changed:Connect(function(v)
            icons.frag:SetValue(v)
        end)
    end

    if rebValue then
        rebValue.Changed:Connect(function(v)
            icons.reb:SetValue(v)
        end)
    end

    if irValue then
        irValue.Changed:Connect(function(v)
            icons.ir:SetValue(math.floor(v))
        end)
    end
end

function HUDController.Show()
    if hudFrame then hudFrame.Visible = true end
end

function HUDController.Hide()
    if hudFrame then hudFrame.Visible = true end -- HUD is always visible
end

return HUDController
