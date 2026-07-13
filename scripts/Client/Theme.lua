-- scripts/Client/Theme.lua
--
-- Retro/CRT design tokens for the Brainrot Lab UI.

local Theme = {}

Theme.Colors = {
    Background     = Color3.fromRGB(13, 17, 23),
    PanelBackground = Color3.fromRGB(22, 27, 34),
    TitleBar       = Color3.fromRGB(33, 38, 45),
    CardBackground = Color3.fromRGB(28, 33, 40),
    CardHover      = Color3.fromRGB(45, 51, 59),
    Primary        = Color3.fromRGB(0, 255, 136),
    Secondary      = Color3.fromRGB(124, 58, 237),
    Error          = Color3.fromRGB(255, 68, 68),
    Warning        = Color3.fromRGB(255, 184, 0),
    Success        = Color3.fromRGB(0, 255, 136),
    Gold           = Color3.fromRGB(255, 215, 0),
    TextPrimary    = Color3.fromRGB(230, 237, 243),
    TextDim        = Color3.fromRGB(125, 133, 144),
    Disabled       = Color3.fromRGB(72, 79, 88),
}

Theme.Font = {
    Heading = Enum.Font.Code,
    Body    = Enum.Font.Code,
    Small   = Enum.Font.Code,
}

Theme.TextSize = {
    Heading  = 18,
    Subhead  = 14,
    Body     = 13,
    Small    = 11,
    Tiny     = 10,
}

Theme.Size = {
    HUD      = 28,
    Toolbar  = 44,
    Button   = 36,
    Card     = 48,
    TitleBar = 40,
    Badge    = 20,
}

Theme.Spacing = {
    XS = 2,
    S  = 4,
    M  = 8,
    L  = 12,
}

Theme.Corner = {
    Small  = 4,
    Medium = 8,
}

Theme.Border = {
    Thin = 1,
}

function Theme.newCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

function Theme.applyBorder(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

function Theme.Unwrap(obj)
    if type(obj) == "table" and obj._Instance then
        return obj._Instance
    end
    return obj
end

return Theme
