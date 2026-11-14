local _, ns = ...

local Disenchant = {}
ns.Disenchant = Disenchant

local CLASS_WEAPON, CLASS_ARMOR = 2, 4
local QUALITY_UNCOMMON, QUALITY_RARE, QUALITY_EPIC = 2, 3, 4

local NOT_DISENCHANTABLE = { [""] = true, INVTYPE_BODY = true, INVTYPE_TABARD = true }

function Disenchant.Bracket(level)
    local brackets = ns.Brackets
    for _, b in ipairs(brackets) do
        if level <= b.maxLevel then return b end
    end
    return brackets[#brackets]
end

function Disenchant.Yield(quality, requiredLevel, classID, equipLoc)
    if classID ~= CLASS_WEAPON and classID ~= CLASS_ARMOR then return nil end
    if NOT_DISENCHANTABLE[equipLoc or ""] then return nil end

    local level = math.max(requiredLevel or 0, 1)
    local b = Disenchant.Bracket(level)
    local out = {}
    local function add(kind, chance)
        local mat = b[kind]
        if mat and chance > 0 then
            out[#out + 1] = { item = mat[1], min = mat[2], max = mat[3], chance = chance, kind = kind }
        end
    end

    if quality == QUALITY_UNCOMMON then
        local c = ns.UncommonChances[classID == CLASS_WEAPON and "weapon" or "armor"]
        add("dust", c.dust)
        add("essence", c.essence)
        if b.uncommonShard ~= false then add("shard", c.shard) end
    elseif quality == QUALITY_RARE then
        add("shard", 1)
        add("crystal", ns.RareCrystalChance)
    elseif quality == QUALITY_EPIC then
        if level > ns.EpicShardMaxLevel and b.crystal then
            add("crystal", 1)
        else
            add("shard", 1)
        end
    else
        return nil
    end
    return out
end

function Disenchant.ForItem(item)
    local _, _, quality, _, requiredLevel, _, _, _, equipLoc, _, _, classID = C_Item.GetItemInfo(item)
    if not quality then return nil end
    return Disenchant.Yield(quality, requiredLevel, classID, equipLoc)
end
