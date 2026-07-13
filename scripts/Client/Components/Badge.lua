-- scripts/Client/Components/Badge.lua
--
-- Small colored pill label for rarity tags, slot counts, etc.

local Theme = require(script.Parent.Parent.Theme)

local Badge = {}

function Badge.new(opts)
    local badge = Instance.new("Frame")
    badge.Name = "Badge"
    badge.Size = UDim2.new(0, 0, 0, Theme.Size.Badge)
    badge.BackgroundColor3 = opts.Color or Theme.Colors.Primary
    badge.BorderSizePixel = 0
    badge.AutomaticSize = Enum.AutomaticSize.X
    badge.Parent = Theme.Unwrap(opts.Parent)

    Theme.newCorner(badge, Theme.Corner.Small)

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, Theme.Spacing.XS + 2)
    padding.PaddingRight = UDim.new(0, Theme.Spacing.XS + 2)
    padding.Parent = badge

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Theme.Font.Small
    label.TextSize = Theme.TextSize.Tiny
    label.TextColor3 = Theme.Colors.TextPrimary
    label.Text = opts.Text or ""
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Parent = badge

    if opts.LayoutOrder then
        badge.LayoutOrder = opts.LayoutOrder
    end

    local setText = function(_, text)
        label.Text = text
    end

    local setColor = function(_, color)
        badge.BackgroundColor3 = color
    end

    local wrapper = setmetatable({}, {
        __index = function(_, key)
            if key == "SetText" then return setText end
            if key == "SetColor" then return setColor end
            if key == "_Instance" then return badge end
            local member = badge[key]
            if type(member) == "function" then
                return function(_, ...)
                    return member(badge, ...)
                end
            end
            return member
        end,
        __newindex = function(_, key, value)
            badge[key] = value
        end,
    })

    return wrapper
end

return Badge
