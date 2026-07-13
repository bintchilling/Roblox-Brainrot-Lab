-- scripts/Client/Components/IconLabel.lua
--
-- Horizontal layout with a colored icon square + value text. Used for
-- currency displays in the HUD.

local Theme = require(script.Parent.Parent.Theme)

local IconLabel = {}

function IconLabel.new(opts)
    local frame = Instance.new("Frame")
    frame.Name = opts.Name or "IconLabel"
    frame.Size = UDim2.new(0, 0, 0, Theme.Size.HUD)
    frame.BackgroundTransparency = 1
    frame.AutomaticSize = Enum.AutomaticSize.X
    frame.Parent = Theme.Unwrap(opts.Parent)

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, Theme.Spacing.XS)
    layout.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, Theme.Spacing.S)
    padding.PaddingRight = UDim.new(0, Theme.Spacing.S)
    padding.Parent = frame

    -- Icon square
    local icon = Instance.new("Frame")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 14, 0, 14)
    icon.BackgroundColor3 = opts.IconColor or Theme.Colors.Gold
    icon.BorderSizePixel = 0
    icon.Parent = frame

    Theme.newCorner(icon, Theme.Corner.Small)

    -- Value label
    local label = Instance.new("TextLabel")
    label.Name = "Value"
    label.Size = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Theme.Font.Body
    label.TextSize = Theme.TextSize.Small
    label.TextColor3 = opts.TextColor or Theme.Colors.Gold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Text = string.format("%s: %s", opts.Label or "", tostring(opts.Value or 0))
    label.Parent = frame

    if opts.LayoutOrder then
        frame.LayoutOrder = opts.LayoutOrder
    end

    local setValue = function(_, newValue)
        label.Text = string.format("%s: %s", opts.Label or "", tostring(newValue))
    end

    local setIconColor = function(_, color)
        icon.BackgroundColor3 = color
    end

    local wrapper = setmetatable({}, {
        __index = function(_, key)
            if key == "SetValue" then return setValue end
            if key == "SetIconColor" then return setIconColor end
            if key == "_Instance" then return frame end
            local member = frame[key]
            if type(member) == "function" then
                return function(_, ...)
                    return member(frame, ...)
                end
            end
            return member
        end,
        __newindex = function(_, key, value)
            frame[key] = value
        end,
    })

    return wrapper
end

return IconLabel
