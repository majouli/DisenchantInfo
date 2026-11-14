local _, ns = ...

ns.LANGUAGES = {
    { code = "deDE", name = "Deutsch" },
    { code = "enUS", name = "English" },
    { code = "frFR", name = "Français" },
    { code = "esES", name = "Español" },
    { code = "ruRU", name = "Русский" },
}

local Locales = {}
ns.Locales = Locales

local CLIENT_TO_MENU = { enGB = "enUS", esMX = "esES" }
local current = "deDE"
local nameColumn = 1

local function Resolve(code)
    if code == "auto" or not Locales[code] then
        local game = GetLocale and GetLocale() or "deDE"
        code = CLIENT_TO_MENU[game] or game
    end
    return Locales[code] and code or "enUS"
end

function ns.SetLanguage(code)
    current = Resolve(code)
    for i, lang in ipairs(ns.ItemNameLanguages or {}) do
        if lang == current then nameColumn = i end
    end
end

function ns.Language() return current end

ns.L = setmetatable({}, {
    __index = function(_, key)
        local v = Locales[current][key]
        if v == nil then v = Locales.enUS[key] end
        if v == nil then v = Locales.deDE[key] end
        return v
    end,
})

function ns.ItemName(id)
    local names = ns.ItemNames and ns.ItemNames[id]
    local name = names and names[nameColumn]
    return name ~= "" and name or nil
end

ns.ClientNames = {
    professions = {
        disenchant = { "Verzauberkunst", "Enchanting", "Enchantement", "Encantamiento", "Наложение чар" },
        skinning   = { "Kürschnerei", "Skinning", "Dépeçage", "Desuello", "Снятие шкур" },
        mining     = { "Bergbau", "Mining", "Minage", "Minería", "Горное дело" },
        herbalism  = { "Kräuterkunde", "Herbalism", "Herboristerie", "Herboristería", "Травничество" },
    },
    beasts = { ["Wildtier"] = true, ["Beast"] = true, ["Bête"] = true, ["Bestia"] = true, ["Животное"] = true },
}
