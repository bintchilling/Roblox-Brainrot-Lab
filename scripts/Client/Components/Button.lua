-- scripts/Client/Components/Button.lua
--
-- Retro-styled text button with hover/press states.

local Theme = require(script.Parent.Parent.Theme)

local Button = {}

function Button.new(opts)
    local btn = Instance.new("TextButton")
    btn.Name = opts.Name or "Button"
    btn.Size = opts.Size or UDim2.new(0, 100, 0, Theme.Size.Button)
    btn.Position = opts.Position or UDim2.new(0, 0, 0, 0)
    btn.AnchorPoint = opts.AnchorPoint or Vector2.new(0, 0)
    btn.BackgroundColor3 = Theme.Colors.CardBackground
    btn.BorderSizePixel = 0
    btn.Font = Theme.Font.Body
    btn.TextSize = Theme.TextSize.Body
    btn.TextColor3 = Theme.Colors.TextPrimary
    btn.Text = opts.Text or "Button"
    btn.AutoButtonColor = false
    btn.Parent = Theme.Unwrap(opts.Parent)

    Theme.newCorner(btn, Theme.Corner.Small)
    local stroke = Theme.applyBorder(btn, opts.Color or Theme.Colors.Primary, Theme.Border.Thin)

    if opts.LayoutOrder then
        btn.LayoutOrder = opts.LayoutOrder
    end

    -- Hover
    btn.MouseEnter:Connect(function()
        if not btn.Active then return end
        btn.BackgroundColor3 = Theme.Colors.CardHover
    end)

    btn.MouseLeave:Connect(function()
        if not btn.Active then return end
        btn.BackgroundColor3 = Theme.Colors.CardBackground
    end)

    -- Press feedback
    btn.MouseButton1Down:Connect(function()
        if not btn.Active then return end
        btn.BackgroundColor3 = Theme.Colors.Background
    end)

    btn.MouseButton1Up:Connect(function()
        if not btn.Active then return end
        btn.BackgroundColor3 = Theme.Colors.CardHover
    end)

    -- Click handler
    if opts.OnClick then
        btn.MouseButton1Click:Connect(function()
            if not btn.Active then return end
            opts.OnClick()
        end)
    end

    -- Disabled state
    local setDisabled = function(_, disabled)
        if disabled then
            btn.Active = false
            btn.TextColor3 = Theme.Colors.TextDim
            stroke.Color = Theme.Colors.Disabled
            btn.BackgroundColor3 = Theme.Colors.CardBackground
        else
            btn.Active = true
            btn.TextColor3 = Theme.Colors.TextPrimary
            stroke.Color = opts.Color or Theme.Colors.Primary
        end
    end

    if opts.Disabled then
        setDisabled(nil, true)
    end

    local wrapper = setmetatable({}, {
        __index = function(_, key)
            if key == "SetDisabled" then return setDisabled end
            if key == "_Instance" then return btn end
            local member = btn[key]
            if type(member) == "function" then
                return function(_, ...)
                    return member(btn, ...)
                end
            end
            return member
        end,
        __newindex = function(_, key, value)
            btn[key] = value
        end,
    })

    return wrapper
end

return Button
