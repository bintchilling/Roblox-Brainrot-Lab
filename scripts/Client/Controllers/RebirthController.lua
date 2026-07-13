-- scripts/Client/Controllers/RebirthController.lua
--
-- Rebirth confirmation dialog. Triggered when the server sends ConfirmRebirth.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Theme = require(script.Parent.Parent.Theme)
local Panel = require(script.Parent.Parent.Components.Panel)
local Button = require(script.Parent.Parent.Components.Button)

local RebirthController = {}

local panel = nil
local rebirthsLabel = nil

local ConfirmRebirth = ReplicatedStorage.Remotes.ConfirmRebirth

function RebirthController.Init(screenGui)
    panel = Panel.new({
        Name = "RebirthPanel",
        Title = "CONFIRM REBIRTH",
        Size = UDim2.new(0.5, 0, 0.4, 0),
        Parent = screenGui,
    })

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(1, 0, 0, 40)
    message.BackgroundTransparency = 1
    message.Font = Theme.Font.Body
    message.TextSize = Theme.TextSize.Body
    message.TextColor3 = Theme.Colors.Warning
    message.TextWrapped = true
    message.Text = "Are you sure? This will reset all your units and Rot Points!"
    message.Parent = panel.Content

    rebirthsLabel = Instance.new("TextLabel")
    rebirthsLabel.Size = UDim2.new(1, 0, 0, 20)
    rebirthsLabel.Position = UDim2.new(0, 0, 0, 44)
    rebirthsLabel.BackgroundTransparency = 1
    rebirthsLabel.Font = Theme.Font.Small
    rebirthsLabel.TextSize = Theme.TextSize.Small
    rebirthsLabel.TextColor3 = Theme.Colors.TextDim
    rebirthsLabel.Text = "You will become Rebirth #?"
    rebirthsLabel.Parent = panel.Content

    local yesBtn = Button.new({
        Name = "YesBtn",
        Size = UDim2.new(0.45, 0, 0, 32),
        Position = UDim2.new(0.025, 0, 1, -38),
        Text = "YES, REBIRTH!",
        Color = Theme.Colors.Warning,
        OnClick = function()
            ConfirmRebirth:FireServer(true)
            panel.Visible = false
        end,
        Parent = panel.Content,
    })

    local cancelBtn = Button.new({
        Name = "CancelBtn",
        Size = UDim2.new(0.45, 0, 0, 32),
        Position = UDim2.new(0.525, 0, 1, -38),
        Text = "CANCEL",
        Color = Theme.Colors.Error,
        OnClick = function()
            ConfirmRebirth:FireServer(false)
            panel.Visible = false
        end,
        Parent = panel.Content,
    })

    -- Listen for server-triggered rebirth confirmation
    ConfirmRebirth.OnClientEvent:Connect(function(nextRebirth)
        rebirthsLabel.Text = string.format("You will become Rebirth #%d", nextRebirth)
        panel.Visible = true
    end)
end

function RebirthController.Show()
    if panel then panel.Visible = true end
end

function RebirthController.Hide()
    if panel then panel.Visible = false end
end

return RebirthController
