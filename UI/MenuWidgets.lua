local _, ns = ...

local W = {}
ns.MenuWidgets = W

W.GOLD = { 1, 0.82, 0 }
local GOLD = W.GOLD
local WHITE = "Interface\\Buttons\\WHITE8X8"

function W.Solid(parent, layer, r, g, b, a, sub)
    local t = parent:CreateTexture(nil, layer, nil, sub)
    t:SetColorTexture(r, g, b, a)
    return t
end

function W.Gradient(tex, top, bottom)
    tex:SetTexture(WHITE)
    local ok = pcall(function()
        tex:SetGradient("VERTICAL", CreateColor(bottom[1], bottom[2], bottom[3], bottom[4]),
            CreateColor(top[1], top[2], top[3], top[4]))
    end)
    if not ok then tex:SetColorTexture(top[1], top[2], top[3], top[4]) end
end

function W.Edge(frame, r, g, b, a)
    local lines = {}
    for _, side in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        local t = W.Solid(frame, "BORDER", r, g, b, a)
        if side == "TOP" or side == "BOTTOM" then
            t:SetHeight(1)
            t:SetPoint(side .. "LEFT")
            t:SetPoint(side .. "RIGHT")
        else
            t:SetWidth(1)
            t:SetPoint("TOP" .. side)
            t:SetPoint("BOTTOM" .. side)
        end
        lines[#lines + 1] = t
    end
    return lines
end

local function Tint(lines, r, g, b, a)
    for _, t in ipairs(lines) do t:SetColorTexture(r, g, b, a) end
end

function W.Card(parent, spec)
    local c = CreateFrame("Button", nil, parent)
    c:SetHeight(58)
    c.bg = W.Solid(c, "BACKGROUND", 0.07, 0.06, 0.09, 0.95)
    c.bg:SetAllPoints()
    c.glow = c:CreateTexture(nil, "BACKGROUND", nil, 1)
    c.glow:SetAllPoints()
    W.Gradient(c.glow, { GOLD[1], GOLD[2], GOLD[3], 0.10 }, { GOLD[1], GOLD[2], GOLD[3], 0 })
    c.hover = W.Solid(c, "HIGHLIGHT", 1, 1, 1, 0.05)
    c.hover:SetAllPoints()
    c.edge = W.Edge(c, 0.3, 0.3, 0.35, 1)

    c.icon = c:CreateTexture(nil, "ARTWORK")
    c.icon:SetSize(38, 38)
    c.icon:SetPoint("LEFT", 10, 0)
    c.icon:SetTexture(spec.icon)
    c.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    c.iconEdge = W.Solid(c, "BORDER", GOLD[1], GOLD[2], GOLD[3], 0.6)
    c.iconEdge:SetPoint("TOPLEFT", c.icon, -1, 1)
    c.iconEdge:SetPoint("BOTTOMRIGHT", c.icon, 1, -1)

    c.name = c:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    c.name:SetPoint("TOPLEFT", c.icon, "TOPRIGHT", 10, -2)
    c.what = c:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    c.what:SetPoint("TOPLEFT", c.name, "BOTTOMLEFT", 0, -3)
    c.status = c:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    c.status:SetPoint("BOTTOMRIGHT", -8, 7)

    function c:SetTexts(name, what, status, color)
        self.name:SetText(name)
        self.what:SetText(what)
        self.status:SetText(status)
        self.status:SetTextColor(color[1], color[2], color[3])
    end
    function c:Set(on, learned)
        self.on = on
        self.glow:SetShown(on and learned)
        self.icon:SetDesaturated(not (on and learned))
        self.icon:SetAlpha(learned and 1 or 0.5)
        if on and learned then Tint(self.edge, GOLD[1], GOLD[2], GOLD[3], 0.8)
        else Tint(self.edge, 0.3, 0.3, 0.35, 1) end
    end
    function c:Width()
        return 10 + 38 + 10 + math.max(self.name:GetStringWidth(),
            self.what:GetStringWidth() + 12 + self.status:GetStringWidth()) + 12
    end
    c:SetScript("OnClick", function() spec.onClick() end)
    return c
end

function W.Switch(parent, onClick)
    local s = CreateFrame("Button", nil, parent)
    s:SetHeight(22)
    s.hover = W.Solid(s, "HIGHLIGHT", 1, 1, 1, 0.04)
    s.hover:SetAllPoints()
    s.label = s:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    s.label:SetPoint("LEFT", 2, 0)
    s.track = W.Solid(s, "ARTWORK", 0.25, 0.25, 0.28, 1)
    s.track:SetSize(30, 14)
    s.track:SetPoint("RIGHT", -2, 0)
    s.knob = W.Solid(s, "OVERLAY", 0.92, 0.92, 0.92, 1)
    s.knob:SetSize(10, 10)
    function s:Set(on)
        self.on = on
        self.knob:ClearAllPoints()
        if on then
            self.track:SetColorTexture(GOLD[1] * 0.85, GOLD[2] * 0.85, GOLD[3], 1)
            self.knob:SetPoint("RIGHT", self.track, "RIGHT", -2, 0)
        else
            self.track:SetColorTexture(0.25, 0.25, 0.28, 1)
            self.knob:SetPoint("LEFT", self.track, "LEFT", 2, 0)
        end
    end
    function s:Width() return self.label:GetStringWidth() + 16 + 34 end
    s:SetScript("OnClick", function()
        onClick()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end)
    return s
end

function W.IconButton(parent, icon, size, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(size, size)
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetAllPoints()
    b.tex:SetTexture(icon)
    b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b.hover = W.Solid(b, "HIGHLIGHT", 1, 1, 1, 0.15)
    b.hover:SetAllPoints()
    W.Edge(b, GOLD[1], GOLD[2], GOLD[3], 0.6)
    b:SetScript("OnClick", function() onClick(b) end)
    return b
end
