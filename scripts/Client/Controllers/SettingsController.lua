-- scripts/Client/Controllers/SettingsController.lua
--
-- Settings screen. Placeholder for future settings.

local Theme = require(script.Parent.Parent.Theme)
local Panel = require(script.Parent.Parent.Components.Panel)

local SettingsController = {}

local panel = nil

function SettingsController.Init(screenGui)
    panel = Panel.new({
        Name = "SettingsPanel",
        Title = "SETTINGS",
        Size = UDim2.new(0.6, 0, 0.5, 0),
        Parent = screenGui,
    })

    local placeholder = Instance.new("TextLabel")
    placeholder.Size = UDim2.new(1, 0, 0, 40)
    placeholder.Position = UDim2.new(0, 0, 0.5, -20)
    placeholder.BackgroundTransparency = 1
    placeholder.Font = Theme.Font.Body
    placeholder.TextSize = Theme.TextSize.Body
    placeholder.TextColor3 = Theme.Colors.TextDim
    placeholder.Text = "Settings coming soon!"
    placeholder.Parent = panel.Content
end

function SettingsController.Show()
    if panel then panel.Visible = true end
end

function SettingsController.Hide()
    if panel then panel.Visible = false end
end

return SettingsController
