-- scripts/Client/Components/Toast.lua
--
-- Temporary notification that appears at the top of the screen.

local Theme = require(script.Parent.Parent.Theme)

local Toast = {}

function Toast.show(parent, opts)
    local duration = opts.Duration or 2

    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.AnchorPoint = Vector2.new(0.5, 0)
    toast.Position = UDim2.new(0.5, 0, 0, 8)
    toast.Size = UDim2.new(0, 300, 0, 40)
    toast.BackgroundColor3 = Theme.Colors.PanelBackground
    toast.BorderSizePixel = 0
    toast.ZIndex = 100
    toast.Parent = Theme.Unwrap(parent)

    Theme.newCorner(toast, Theme.Corner.Small)
    Theme.applyBorder(toast, opts.Color or Theme.Colors.Primary, Theme.Border.Thin)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Theme.Font.Body
    label.TextSize = Theme.TextSize.Body
    label.TextColor3 = opts.Color or Theme.Colors.TextPrimary
    label.Text = opts.Text or ""
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = toast

    task.delay(duration, function()
        toast:Destroy()
    end)

    return toast
end

return Toast
