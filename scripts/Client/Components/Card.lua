-- scripts/Client/Components/Card.lua
--
-- List row with left accent stripe for rarity indication.

local Theme = require(script.Parent.Parent.Theme)

local Card = {}

function Card.new(opts)
    local card = Instance.new("Frame")
    card.Name = opts.Name or "Card"
    card.Size = UDim2.new(1, 0, 0, Theme.Size.Card + 16)
    card.BackgroundColor3 = Theme.Colors.CardBackground
    card.BorderSizePixel = 0
    card.Parent = Theme.Unwrap(opts.Parent)

    Theme.newCorner(card, Theme.Corner.Small)

    if opts.LayoutOrder then
        card.LayoutOrder = opts.LayoutOrder
    end

    -- Left accent stripe
    local stripe = Instance.new("Frame")
    stripe.Name = "AccentStripe"
    stripe.Size = UDim2.new(0, 4, 1, -8)
    stripe.Position = UDim2.new(0, 4, 0, 4)
    stripe.BackgroundColor3 = opts.AccentColor or Theme.Colors.Primary
    stripe.BorderSizePixel = 0
    stripe.Parent = card

    Theme.newCorner(stripe, Theme.Corner.Small)

    -- Content area (offset from stripe)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 1, -8)
    content.Position = UDim2.new(0, 14, 0, 4)
    content.BackgroundTransparency = 1
    content.Parent = card

    local wrapper = setmetatable({}, {
        __index = function(_, key)
            if key == "Content" then return content end
            if key == "Stripe" then return stripe end
            if key == "_Instance" then return card end
            if key == "SetAccentColor" then
                return function(_, color)
                    stripe.BackgroundColor3 = color
                end
            end
            local member = card[key]
            if type(member) == "function" then
                return function(_, ...)
                    return member(card, ...)
                end
            end
            return member
        end,
        __newindex = function(_, key, value)
            card[key] = value
        end,
    })

    return wrapper
end

return Card
