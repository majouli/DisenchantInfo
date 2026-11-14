local ADDON, ns = ...

ns.SetLanguage("auto")

ns.ICON = "Interface\\Icons\\INV_Enchant_Disenchant"
ns.DB_VERSION = 3

ns.defaults = {
    enabled       = true,
    disenchant    = true,
    skinning      = true,
    mining        = true,
    herbalism     = true,
    names         = true,
    compact       = false,
    chances       = true,
    value         = true,
    shiftOnly     = false,
    language      = "auto",
    onlyKnown     = true,
    prices        = {},
    absent        = {},
    minimap       = { hide = false, angle = 200 },
}

local listeners = {}
function ns.OnSettingsChanged(fn)
    listeners[#listeners + 1] = fn
end
function ns.SettingsChanged()
    for _, fn in ipairs(listeners) do fn() end
end

function ns.Get(key)
    local v = ns.db and ns.db[key]
    if v == nil then v = ns.defaults[key] end
    return v
end

function ns.Set(key, value)
    ns.db[key] = value
    if key == "language" then ns.SetLanguage(value) end
    ns.SettingsChanged()
end

local function FillDefaults(db, defaults)
    for k, v in pairs(defaults) do
        if db[k] == nil then
            if type(v) == "table" then
                db[k] = {}
                FillDefaults(db[k], v)
            else
                db[k] = v
            end
        elseif type(v) == "table" and type(db[k]) == "table" then
            FillDefaults(db[k], v)
        end
    end
end

local function Migrate(db)
    local version = db.version or (next(db) and 1 or ns.DB_VERSION)
    if version < 2 then
        db.replicateAt, db.lastScan = nil, nil
    end
    if version < 3 then
        db.onlyKnown, db.enchanterOnly = true, nil
    end
    db.version = ns.DB_VERSION
end
ns.Migrate = Migrate

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(self, _, name)
    if name ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")
    DisenchantInfoDB = DisenchantInfoDB or {}
    Migrate(DisenchantInfoDB)
    FillDefaults(DisenchantInfoDB, ns.defaults)
    ns.db = DisenchantInfoDB
    ns.SetLanguage(ns.db.language)
    ns.SettingsChanged()
end)

SLASH_DISENCHANTINFO1 = "/dei"
SlashCmdList.DISENCHANTINFO = function(msg)
    if strtrim(msg or ""):lower() == "probe" then
        ns.Scanner.Probe()
    elseif ns.Menu then
        ns.Menu:Toggle()
    end
end
