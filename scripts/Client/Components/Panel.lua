-- scripts/Client/Components/Panel.lua
--
-- Modal panel with title bar and close button. Default hidden.

local Theme = require(script.Parent.Parent.Theme)

local Panel = {}

function Panel.new(opts)
    local panel = Instance.new("Frame")
    panel.Name = opts.Name or "Panel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.Size = opts.Size or UDim2.new(0.8, 0, 0.7, 0)
    panel.BackgroundColor3 = Theme.Colors.PanelBackground
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = Theme.Unwrap(opts.Parent)

    Theme.newCorner(panel, Theme.Corner.Medium)
    Theme.applyBorder(panel, Theme.Colors.Primary, Theme.Border.Thin)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, Theme.Size.TitleBar)
    titleBar.BackgroundColor3 = Theme.Colors.TitleBar
    titleBar.BorderSizePixel = 0
    titleBar.Parent = panel

    Theme.newCorner(titleBar, Theme.Corner.Medium)

    -- Bottom cover to make title bar square at bottom
    local cover = Instance.new("Frame")
    cover.Size = UDim2.new(1, 0, 0, Theme.Corner.Medium)
    cover.Position = UDim2.new(0, 0, 1, -Theme.Corner.Medium)
    cover.BackgroundColor3 = Theme.Colors.TitleBar
    cover.BorderSizePixel = 0
    cover.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -48, 1, 0)
    titleLabel.Position = UDim2.new(0, Theme.Spacing.L, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Theme.Font.Heading
    titleLabel.TextSize = Theme.TextSize.Subhead
    titleLabel.TextColor3 = Theme.Colors.Primary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = opts.Title or "Panel"
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -36, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Theme.Font.Body
    closeBtn.TextSize = Theme.TextSize.Subhead
    closeBtn.TextColor3 = Theme.Colors.Error
    closeBtn.Text = "X"
    closeBtn.Parent = titleBar

    closeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
        if opts.OnClose then
            opts.OnClose()
        end
    end)

    -- Content area (below title bar)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -Theme.Spacing.L * 2, 1, -Theme.Size.TitleBar - Theme.Spacing.M)
    content.Position = UDim2.new(0, Theme.Spacing.L, 0, Theme.Size.TitleBar + Theme.Spacing.M)
    content.BackgroundTransparency = 1
    content.Parent = panel

    local wrapper = setmetatable({}, {
        __index = function(_, key)
            if key == "Content" then return content end
            if key == "TitleLabel" then return titleLabel end
            if key == "_Instance" then return panel end
            if key == "SetTitle" then
                return function(_, text)
                    titleLabel.Text = text
                end
            end
            local member = panel[key]
            if type(member) == "function" then
                return function(_, ...)
                    return member(panel, ...)
                end
            end
            return member
        end,
        __newindex = function(_, key, value)
            panel[key] = value
        end,
    })

    return wrapper
end

return Panel
