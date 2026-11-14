local _, ns = ...
local L = ns.L
local W = ns.MenuWidgets
local GOLD = W.GOLD

local Menu = {}
ns.Menu = Menu

local PAD, GAP = 18, 10
local HEADER_H = 76
local TITLE_FONT = "Fonts\\MORPHEUS.TTF"
local NO_BOOK_FONT = { ruRU = true }
local GEAR_ICON = "Interface\\Icons\\INV_Misc_Gear_01"
local ADDON_ICON = "Interface\\Icons\\INV_Enchant_Disenchant"
local MODEL_DISPLAY, MODEL_NPC = 3271, 906
local THANKS_H, MODEL_W = 118, 92
local TIER_SET = { 22506, 22507, 22504, 22511, 22509, 22510, 22505, 22508 }
local HUMAN, MALE = 1, 0

local function Dress(model)
    local ok = pcall(model.SetCustomRace, model, HUMAN, MALE)
    if not ok then ok = pcall(model.SetUnit, model, "player") end
    if not ok then return false end
    pcall(model.Undress, model)
    for _, id in ipairs(TIER_SET) do
        if C_Item.RequestLoadItemDataByID then C_Item.RequestLoadItemDataByID(id) end
        pcall(model.TryOn, model, "item:" .. id)
    end
    return true
end

local function BuildModel(parent)
    local ok, model = pcall(CreateFrame, "DressUpModel", nil, parent)
    if ok and model and Dress(model) then
        local wanted = {}
        for _, id in ipairs(TIER_SET) do wanted[id] = true end
        pcall(model.RegisterEvent, model, "GET_ITEM_INFO_RECEIVED")
        model:SetScript("OnEvent", function(self, _, id) if wanted[id] then Dress(self) end end)
        model:SetScript("OnShow", function(self) Dress(self) end)
        model.dressed = true
        return model
    end
    model = CreateFrame("PlayerModel", nil, parent)
    if not pcall(model.SetDisplayInfo, model, MODEL_DISPLAY) then pcall(model.SetCreature, model, MODEL_NPC) end
    pcall(model.SetPortraitZoom, model, 0.35)
    return model
end

local PROFESSIONS = {
    { key = "disenchant", icon = "Interface\\Icons\\INV_Enchant_Disenchant" },
    { key = "skinning",   icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01" },
    { key = "mining",     icon = "Interface\\Icons\\Trade_Mining" },
    { key = "herbalism",  icon = "Interface\\Icons\\Trade_Herbalism" },
}
local DISPLAY = { "names", "compact", "chances", "value" }
local BEHAVIOR = { "shiftOnly", "onlyKnown", "minimap" }
local LABEL = {
    names = "optNames", compact = "optCompact", chances = "optChances", value = "optValue",
    shiftOnly = "optShift", onlyKnown = "optKnown", minimap = "optMinimap", enabled = "master",
}

local frame, parts
Menu.controls = {}

local function Get(key)
    if key == "minimap" then return not ns.db.minimap.hide end
    return ns.Get(key) and true or false
end

local function Toggle(key)
    if key == "minimap" then
        ns.db.minimap.hide = not ns.db.minimap.hide
        ns.SettingsChanged()
    else
        ns.Set(key, not ns.Get(key))
    end
end

local function Learned(key)
    return not ns.Get("onlyKnown") or ns.Professions.Knows(key)
end

local popup

local function LanguageRows()
    local rows = { { code = "auto" } }
    for _, lang in ipairs(ns.LANGUAGES) do rows[#rows + 1] = lang end
    return rows
end

local function ShowLanguages(anchor)
    if not popup then
        popup = CreateFrame("Frame", "DisenchantInfoLanguages", frame)
        popup:SetFrameStrata("FULLSCREEN_DIALOG")
        popup:EnableMouse(true)
        W.Solid(popup, "BACKGROUND", 0.05, 0.04, 0.07, 0.98):SetAllPoints()
        W.Edge(popup, GOLD[1], GOLD[2], GOLD[3], 0.7)
        popup.head = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        popup.head:SetPoint("TOPLEFT", 10, -8)
        popup.rows = {}
        for i, lang in ipairs(LanguageRows()) do
            local b = CreateFrame("Button", nil, popup)
            b:SetHeight(20)
            b:SetPoint("TOPLEFT", 6, -8 - 16 - (i - 1) * 20)
            b:SetPoint("RIGHT", -6, 0)
            W.Solid(b, "HIGHLIGHT", 1, 1, 1, 0.08):SetAllPoints()
            b.mark = W.Solid(b, "ARTWORK", GOLD[1], GOLD[2], GOLD[3], 1)
            b.mark:SetSize(6, 6)
            b.mark:SetPoint("LEFT", 6, 0)
            b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            b.text:SetPoint("LEFT", 18, 0)
            b.code = lang.code
            b.name = lang.name
            b:SetScript("OnClick", function()
                ns.Set("language", lang.code)
                popup:Hide()
            end)
            popup.rows[i] = b
        end
        popup:SetHeight(8 + 16 + #popup.rows * 20 + 8)
        popup:Hide()
    end
    popup.head:SetText(L.language)
    local width = popup.head:GetStringWidth() + 20
    for _, b in ipairs(popup.rows) do
        b.text:SetText(b.code == "auto" and L.langAuto or b.name)
        b.mark:SetShown((ns.Get("language") or "auto") == b.code)
        width = math.max(width, b.text:GetStringWidth() + 36)
    end
    popup:SetWidth(width)
    popup:ClearAllPoints()
    popup:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -4)
    popup:SetShown(not popup:IsShown())
end

local function SectionTitle(parent)
    local t = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    local rule = W.Solid(parent, "ARTWORK", GOLD[1], GOLD[2], GOLD[3], 0.3)
    rule:SetHeight(1)
    rule:SetPoint("LEFT", t, "RIGHT", 8, 0)
    t.rule = rule
    return t
end

local function Create()
    frame = CreateFrame("Frame", "DisenchantInfoMenu", UIParent)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetScript("OnHide", function() if popup then popup:Hide() end end)
    frame:Hide()
    tinsert(UISpecialFrames, "DisenchantInfoMenu")

    W.Solid(frame, "BACKGROUND", 0.035, 0.03, 0.045, 0.97):SetAllPoints()
    local glow = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    glow:SetPoint("TOPLEFT")
    glow:SetPoint("TOPRIGHT")
    glow:SetHeight(140)
    W.Gradient(glow, { 0.45, 0.25, 0.7, 0.28 }, { 0.45, 0.25, 0.7, 0 })
    W.Edge(frame, GOLD[1], GOLD[2], GOLD[3], 0.7)
    local inner = CreateFrame("Frame", nil, frame)
    inner:SetPoint("TOPLEFT", 4, -4)
    inner:SetPoint("BOTTOMRIGHT", -4, 4)
    W.Edge(inner, GOLD[1], GOLD[2], GOLD[3], 0.18)

    parts = {}
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(46, 46)
    icon:SetPoint("TOPLEFT", PAD, -PAD)
    icon:SetTexture(ADDON_ICON)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local iconEdge = W.Solid(frame, "BORDER", GOLD[1], GOLD[2], GOLD[3], 0.8)
    iconEdge:SetPoint("TOPLEFT", icon, -1, 1)
    iconEdge:SetPoint("BOTTOMRIGHT", icon, 1, -1)
    parts.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    parts.title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 12, 2)
    if not pcall(parts.title.SetFont, parts.title, TITLE_FONT, 26, "") then
        parts.title:SetFontObject("GameFontNormalHuge")
    end
    parts.title:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    parts.title:SetShadowOffset(1, -1)
    parts.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    parts.subtitle:SetPoint("TOPLEFT", parts.title, "BOTTOMLEFT", 1, -4)
    parts.subtitle:SetTextColor(0.78, 0.72, 0.9)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    parts.gear = W.IconButton(frame, GEAR_ICON, 20, ShowLanguages)
    parts.gear:SetPoint("RIGHT", close, "LEFT", -4, 0)
    parts.gear.tex:SetDesaturated(true)
    parts.gear:SetScript("OnEnter", function(self) self.tex:SetDesaturated(false) end)
    parts.gear:SetScript("OnLeave", function(self) self.tex:SetDesaturated(true) end)
    Menu.gear = parts.gear

    parts.band = W.Solid(frame, "ARTWORK", 1, 1, 1, 0.04)
    parts.band:SetPoint("TOPLEFT", PAD, -HEADER_H)
    parts.band:SetPoint("RIGHT", -PAD, 0)
    parts.band:SetHeight(28)
    local master = W.Switch(frame, function() Toggle("enabled") end)
    master:SetPoint("TOPLEFT", parts.band, "TOPLEFT", 6, -3)
    master:SetPoint("RIGHT", parts.band, "RIGHT", -6, 0)
    master.label:SetFontObject("GameFontNormal")
    Menu.controls.enabled = master

    parts.profTitle = SectionTitle(frame)
    parts.cards = {}
    for _, p in ipairs(PROFESSIONS) do
        local card = W.Card(frame, { icon = p.icon, onClick = function() Toggle(p.key) end })
        card.key = p.key
        parts.cards[#parts.cards + 1] = card
        Menu.controls[p.key] = card
    end

    parts.displayTitle = SectionTitle(frame)
    parts.behaviorTitle = SectionTitle(frame)
    parts.switches = {}
    for _, list in ipairs({ DISPLAY, BEHAVIOR }) do
        for _, key in ipairs(list) do
            local s = W.Switch(frame, function() Toggle(key) end)
            s.key = key
            parts.switches[key] = s
            Menu.controls[key] = s
        end
    end

    parts.aboutBg = W.Solid(frame, "ARTWORK", 1, 1, 1, 0.03)
    parts.aboutTitle = SectionTitle(frame)
    parts.about = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    parts.about:SetJustifyH("LEFT")
    parts.about:SetTextColor(0.8, 0.8, 0.82)

    local card = CreateFrame("Frame", nil, frame)
    card:SetHeight(THANKS_H)
    W.Solid(card, "BACKGROUND", 0.06, 0.04, 0.08, 0.95):SetAllPoints()
    local cardGlow = card:CreateTexture(nil, "BACKGROUND", nil, 1)
    cardGlow:SetAllPoints()
    W.Gradient(cardGlow, { 0.55, 0.2, 0.75, 0.14 }, { 0.55, 0.2, 0.75, 0 })
    W.Edge(card, GOLD[1], GOLD[2], GOLD[3], 0.55)
    local stage = W.Solid(card, "ARTWORK", 0, 0, 0, 0.6)
    stage:SetPoint("TOPLEFT", 6, -6)
    stage:SetPoint("BOTTOMLEFT", 6, 6)
    stage:SetWidth(MODEL_W)
    local model = BuildModel(card)
    model:SetPoint("TOPLEFT", stage)
    model:SetPoint("BOTTOMRIGHT", stage)
    local facing = 0.6
    pcall(model.SetFacing, model, facing)
    model:SetScript("OnUpdate", function(self, elapsed)
        facing = (facing + elapsed * 0.4) % (2 * math.pi)
        pcall(self.SetFacing, self, facing)
    end)
    parts.thanksBook = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    parts.thanksBook:SetPoint("TOPLEFT", stage, "TOPRIGHT", 14, -14)
    parts.bookFont = pcall(parts.thanksBook.SetFont, parts.thanksBook, TITLE_FONT, 20, "")
    parts.thanksPlain = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    parts.thanksPlain:SetPoint("TOPLEFT", stage, "TOPRIGHT", 14, -16)
    for _, title in ipairs({ parts.thanksBook, parts.thanksPlain }) do
        title:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    end
    parts.thanks = card:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    parts.thanks:SetPoint("TOPLEFT", stage, "TOPRIGHT", 14, -48)
    parts.thanks:SetJustifyH("LEFT")
    parts.thanksCard, parts.model = card, model
    parts.version = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    parts.footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    Menu.parts = parts
end

local function Texts()
    parts.title:SetText(L.title)
    parts.subtitle:SetText(L.subtitle)
    Menu.controls.enabled.label:SetText(L.master)
    parts.profTitle:SetText(L.secProfessions)
    for _, card in ipairs(parts.cards) do
        local on = Get(card.key)
        local status, color
        if not Learned(card.key) then status, color = L.notLearned, { 0.6, 0.45, 0.45 }
        elseif on then status, color = L.cardOn, { 0.35, 0.9, 0.35 }
        else status, color = L.cardOff, { 0.55, 0.55, 0.55 } end
        card:SetTexts(L[card.key], L[card.key .. "What"], status, color)
        card:Set(on, Learned(card.key))
    end
    parts.displayTitle:SetText(L.secDisplay)
    parts.behaviorTitle:SetText(L.secBehavior)
    for key, s in pairs(parts.switches) do
        s.label:SetText(L[LABEL[key]])
        s:Set(Get(key))
    end
    Menu.controls.enabled:Set(Get("enabled"))
    parts.aboutTitle:SetText(L.secAbout)
    parts.about:SetText(L.aboutText)
    local book = parts.bookFont and not NO_BOOK_FONT[ns.Language()]
    parts.thanksBook:SetShown(book)
    parts.thanksPlain:SetShown(not book)
    parts.thanksTitle = book and parts.thanksBook or parts.thanksPlain
    parts.thanksTitle:SetText(L.thanksTitle)
    parts.thanks:SetText(L.thanks)
    parts.version:SetText(L.aboutVersion:format(C_AddOns.GetAddOnMetadata("DisenchantInfo", "Version") or "?"))
    parts.footer:SetText(L.menuFooter)
end

local function Layout()
    local cardW = 180
    for _, card in ipairs(parts.cards) do cardW = math.max(cardW, card:Width()) end
    local colW = 170
    for _, s in pairs(parts.switches) do colW = math.max(colW, s:Width()) end
    local headerW = 46 + 12 + math.max(parts.title:GetStringWidth(), parts.subtitle:GetStringWidth()) + 60
    local inner = math.ceil(math.max(2 * cardW + GAP, 2 * colW + 2 * GAP, headerW, 380))
    cardW = (inner - GAP) / 2
    colW = (inner - 2 * GAP) / 2

    local y = -HEADER_H - 28 - 14
    parts.profTitle:ClearAllPoints()
    parts.profTitle:SetPoint("TOPLEFT", PAD, y)
    parts.profTitle.rule:SetPoint("RIGHT", frame, "RIGHT", -PAD, 0)
    y = y - 20
    for i, card in ipairs(parts.cards) do
        local col, row = (i - 1) % 2, math.floor((i - 1) / 2)
        card:ClearAllPoints()
        card:SetWidth(cardW)
        card:SetPoint("TOPLEFT", PAD + col * (cardW + GAP), y - row * (58 + GAP))
    end
    y = y - 2 * 58 - GAP - 18

    local lowest = y
    for c, column in ipairs({ { parts.displayTitle, DISPLAY }, { parts.behaviorTitle, BEHAVIOR } }) do
        local x = PAD + (c - 1) * (colW + 2 * GAP)
        local title = column[1]
        title:ClearAllPoints()
        title:SetPoint("TOPLEFT", x, y)
        title.rule:SetPoint("RIGHT", frame, "LEFT", x + colW, 0)
        local cy = y - 20
        for _, key in ipairs(column[2]) do
            local s = parts.switches[key]
            s:ClearAllPoints()
            s:SetPoint("TOPLEFT", x, cy)
            s:SetWidth(colW)
            cy = cy - 24
        end
        lowest = math.min(lowest, cy)
    end
    y = lowest - 14

    parts.aboutTitle:ClearAllPoints()
    parts.aboutTitle:SetPoint("TOPLEFT", PAD, y)
    parts.aboutTitle.rule:SetPoint("RIGHT", frame, "RIGHT", -PAD, 0)
    parts.about:ClearAllPoints()
    parts.about:SetPoint("TOPLEFT", PAD, y - 20)
    parts.about:SetWidth(inner)
    local unwrapped = parts.about.GetUnboundedStringWidth and parts.about:GetUnboundedStringWidth()
        or parts.about:GetStringWidth()
    local aboutH = math.max(parts.about:GetStringHeight() or 0, math.ceil((unwrapped or 0) * 1.1 / inner) * 13)
    y = y - 20 - aboutH - 12
    parts.aboutBg:ClearAllPoints()
    parts.aboutBg:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD - 8, lowest - 8)
    parts.aboutBg:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -PAD + 8, y + 4)

    y = y - 8
    parts.thanksCard:ClearAllPoints()
    parts.thanksCard:SetPoint("TOPLEFT", PAD, y)
    parts.thanksCard:SetPoint("RIGHT", frame, "RIGHT", -PAD, 0)
    parts.thanks:SetWidth(inner - MODEL_W - 34)
    y = y - THANKS_H - 10

    parts.version:ClearAllPoints()
    parts.version:SetPoint("BOTTOMLEFT", PAD, 12)
    parts.footer:ClearAllPoints()
    parts.footer:SetPoint("BOTTOMRIGHT", -PAD, 12)
    frame:SetSize(inner + 2 * PAD, -y + 26)
end

function Menu:Refresh()
    if not frame then return end
    Texts()
    Layout()
    if popup and popup:IsShown() then popup:Hide() end
end

function Menu:Toggle()
    if not ns.db then return end
    if not frame then Create() end
    if frame:IsShown() then
        frame:Hide()
        return
    end
    frame:ClearAllPoints()
    local anchor = ns.MinimapButton:Get()
    if anchor then
        frame:SetPoint("TOPRIGHT", anchor, "BOTTOMLEFT", 0, 0)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    self:Refresh()
    frame:Show()
    C_Timer.After(0, function() self:Refresh() end)
end

ns.OnSettingsChanged(function() Menu:Refresh() end)
