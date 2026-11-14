local _, ns = ...
local L = ns.L

local MinimapButton = {}
ns.MinimapButton = MinimapButton

local button

local function UpdatePosition()
    local angle = math.rad(ns.db.minimap.angle or 200)
    local radius = (Minimap:GetWidth() / 2) + 10
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function OnDragUpdate()
    local mx, my = Minimap:GetCenter()
    local cx, cy = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    ns.db.minimap.angle = math.deg(math.atan2(cy / scale - my, cx / scale - mx)) % 360
    UpdatePosition()
end

local function ShowTooltip(owner)
    GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
    GameTooltip:SetText(L.title, 0.71, 0.55, 1)
    GameTooltip:AddLine(ns.Get("enabled") and L.on or L.off, 1, 1, 1)
    for _, hint in ipairs({ L.hintLeft, L.hintRight, L.hintDrag }) do
        GameTooltip:AddLine(hint, 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
end

local function OnClick(_, mouse)
    if mouse == "RightButton" then
        ns.Set("enabled", not ns.Get("enabled"))
    else
        ns.Menu:Toggle()
    end
end

local function Create()
    button = CreateFrame("Button", "DisenchantInfoMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local bg = button:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(20, 20)
    bg:SetPoint("TOPLEFT", 7, -5)
    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetTexture(ns.ICON)
    button.icon:SetSize(17, 17)
    button.icon:SetPoint("TOPLEFT", 7, -6)
    button.icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")

    button:SetScript("OnClick", OnClick)
    button:SetScript("OnEnter", ShowTooltip)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", OnDragUpdate) end)
    button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    UpdatePosition()
end

function MinimapButton:Get()
    return button and button:IsShown() and button or nil
end

ns.OnSettingsChanged(function()
    if not ns.db then return end
    if not button then
        if ns.db.minimap.hide then return end
        Create()
    end
    button:SetShown(not ns.db.minimap.hide)
    button.icon:SetDesaturated(not ns.Get("enabled"))
end)

function DisenchantInfo_OnAddonCompartmentClick(_, mouse)
    OnClick(nil, mouse)
end
