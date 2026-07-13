-- scripts/Client/Components/ScrollList.lua
--
-- ScrollingFrame wrapper with UIListLayout and auto canvas sizing.

local Theme = require(script.Parent.Parent.Theme)

local ScrollList = {}

function ScrollList.new(opts)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = opts.Name or "ScrollList"
    scroll.Size = opts.Size or UDim2.new(1, 0, 1, 0)
    scroll.Position = opts.Position or UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = opts.BackgroundTransparency or 1
    scroll.BackgroundColor3 = Theme.Colors.Background
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Theme.Colors.Primary
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Parent = Theme.Unwrap(opts.Parent)

    Theme.newCorner(scroll, Theme.Corner.Small)

    local layout = Instance.new("UIListLayout")
    layout.Name = "Layout"
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, Theme.Spacing.S)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Parent = scroll

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, Theme.Spacing.S)
    padding.PaddingBottom = UDim.new(0, Theme.Spacing.S)
    padding.PaddingLeft = UDim.new(0, Theme.Spacing.S)
    padding.PaddingRight = UDim.new(0, Theme.Spacing.S)
    padding.Parent = scroll

    local wrapper = setmetatable({}, {
        __index = function(_, key)
            if key == "Layout" then return layout end
            if key == "_Instance" then return scroll end
            local member = scroll[key]
            if type(member) == "function" then
                return function(_, ...)
                    return member(scroll, ...)
                end
            end
            return member
        end,
        __newindex = function(_, key, value)
            scroll[key] = value
        end,
    })

    return wrapper
end

return ScrollList
