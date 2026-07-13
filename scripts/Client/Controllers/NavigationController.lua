-- scripts/Client/Controllers/NavigationController.lua
--
-- Bottom toolbar with screen tabs. Manages show/hide for registered screens.

local Theme = require(script.Parent.Parent.Theme)

local NavigationController = {}

local screens = {}
local tabButtons = {}
local activeScreen = nil
local toolbar = nil
local gui = nil

local TAB_LABELS = {
    { key = "shop",     label = "SHOP" },
    { key = "lab",      label = "LAB" },
    { key = "fuse",     label = "FUSE", disabled = true },
    { key = "trade",    label = "TRADE", disabled = true },
    { key = "settings", label = "SET" },
}

function NavigationController.Init(screenGui)
    gui = screenGui

    toolbar = Instance.new("Frame")
    toolbar.Name = "NavigationBar"
    toolbar.AnchorPoint = Vector2.new(0.5, 1)
    toolbar.Position = UDim2.new(0.5, 0, 1, -4)
    toolbar.Size = UDim2.new(1, -32, 0, Theme.Size.Toolbar)
    toolbar.BackgroundColor3 = Theme.Colors.PanelBackground
    toolbar.BorderSizePixel = 0
    toolbar.Parent = screenGui

    Theme.newCorner(toolbar, Theme.Corner.Medium)
    Theme.applyBorder(toolbar, Theme.Colors.Primary, Theme.Border.Thin)

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, Theme.Spacing.S)
    layout.Parent = toolbar

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, Theme.Spacing.S)
    padding.PaddingRight = UDim.new(0, Theme.Spacing.S)
    padding.Parent = toolbar

    for _, tab in ipairs(TAB_LABELS) do
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. tab.key
        btn.Size = UDim2.new(0, 70, 0, Theme.Size.Toolbar - 12)
        btn.BackgroundColor3 = Theme.Colors.CardBackground
        btn.BorderSizePixel = 0
        btn.Font = Theme.Font.Body
        btn.TextSize = Theme.TextSize.Small
        btn.TextColor3 = Theme.Colors.TextDim
        btn.Text = tab.label
        btn.AutoButtonColor = false
        btn.Parent = toolbar

        Theme.newCorner(btn, Theme.Corner.Small)

        if tab.disabled then
            btn:SetAttribute("Disabled", true)
            btn.MouseButton1Click:Connect(function()
                local Toast = require(script.Parent.Parent.Components.Toast)
                Toast.show(gui, {
                    Text = "Coming soon!",
                    Color = Theme.Colors.Warning,
                    Duration = 1.5,
                })
            end)
        else
            btn.MouseButton1Click:Connect(function()
                NavigationController.ToggleScreen(tab.key)
            end)
        end

        -- Hover (only for non-disabled)
        if not tab.disabled then
            btn.MouseEnter:Connect(function()
                if activeScreen ~= tab.key then
                    btn.BackgroundColor3 = Theme.Colors.CardHover
                end
            end)
            btn.MouseLeave:Connect(function()
                if activeScreen ~= tab.key then
                    btn.BackgroundColor3 = Theme.Colors.CardBackground
                end
            end)
        end

        tabButtons[tab.key] = btn
    end
end

function NavigationController.RegisterScreen(name, controller)
    screens[name] = controller
end

function NavigationController.ToggleScreen(name)
    if activeScreen == name then
        if screens[name] then screens[name]:Hide() end
        activeScreen = nil
        updateStyles()
        return
    end
    if activeScreen and screens[activeScreen] then
        screens[activeScreen]:Hide()
    end
    if screens[name] then
        screens[name]:Show()
    end
    activeScreen = name
    updateStyles()
end

function NavigationController.Hide()
    if activeScreen and screens[activeScreen] then
        screens[activeScreen]:Hide()
    end
    activeScreen = nil
    updateStyles()
end

function NavigationController.GetActive()
    return activeScreen
end

function updateStyles()
    for key, btn in pairs(tabButtons) do
        if btn:GetAttribute("Disabled") then
            continue
        end
        if key == activeScreen then
            btn.BackgroundColor3 = Theme.Colors.CardHover
            btn.TextColor3 = Theme.Colors.Primary
            Theme.applyBorder(btn, Theme.Colors.Primary, Theme.Border.Thin)
        else
            btn.BackgroundColor3 = Theme.Colors.CardBackground
            btn.TextColor3 = Theme.Colors.TextDim
            -- Remove existing UIStroke
            for _, child in ipairs(btn:GetChildren()) do
                if child:IsA("UIStroke") then
                    child:Destroy()
                end
            end
        end
    end
end

return NavigationController
