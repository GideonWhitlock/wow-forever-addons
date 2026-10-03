local ADDON_NAME = ...

local TTF = CreateFrame("Frame")
local PREFIX = "|cff40c7ebTotem Tooltip: Forever|r"
local hooked, busy, added = false, false, false

local COLORS = {
    Buff = { 0.25, 1.00, 0.45 },
    Debuff = { 1.00, 0.35, 0.35 },
    Damage = { 1.00, 0.55, 0.20 },
    Cleanse = { 0.35, 0.75, 1.00 },
    Utility = { 1.00, 0.82, 0.25 },
}

-- Spell IDs discover localized names. Descriptions avoid rank-specific
-- numbers so the same explanation remains true for every rank.
local EFFECTS = {
    { name = "Earthbind Totem", spellID = 2484, kind = "Debuff",
      text = "Slows the movement of nearby enemies." },
    { name = "Stoneclaw Totem", spellID = 5730, kind = "Utility",
      text = "Taunts nearby creatures, drawing their attacks to the totem." },
    { name = "Stoneskin Totem", spellID = 8071, kind = "Buff",
      text = "Reduces Physical damage taken by nearby party members." },
    { name = "Strength of Earth Totem", spellID = 8075, kind = "Buff",
      text = "Increases the Strength of nearby party members." },
    { name = "Tremor Totem", spellID = 8143, kind = "Cleanse",
      text = "Periodically removes Fear, Charm, and Sleep effects from nearby party members." },

    { name = "Searing Totem", spellID = 3599, kind = "Damage",
      text = "Repeatedly attacks a nearby enemy with fire." },
    { name = "Magma Totem", spellID = 8190, kind = "Damage",
      text = "Periodically deals fire damage to all nearby enemies." },
    { name = "Flametongue Totem", spellID = 8227, kind = "Buff",
      text = "Enhances nearby party members' weapons with bonus fire damage." },
    { name = "Frost Resistance Totem", spellID = 8181, kind = "Buff",
      text = "Increases the Frost resistance of nearby party and raid members." },

    { name = "Healing Stream Totem", spellID = 5394, kind = "Buff",
      text = "Periodically restores health to nearby party members." },
    { name = "Mana Spring Totem", spellID = 5675, kind = "Buff",
      text = "Periodically restores mana to nearby party members." },
    { name = "Mana Tide Totem", spellID = 16190, kind = "Buff",
      text = "Rapidly restores mana to nearby party members for a short time." },
    { name = "Fire Resistance Totem", spellID = 8184, kind = "Buff",
      text = "Increases the Fire resistance of nearby party and raid members." },
    { name = "Disease Cleansing Totem", spellID = 8170, kind = "Cleanse",
      text = "Periodically removes a disease effect from nearby party members." },
    { name = "Poison Cleansing Totem", spellID = 8166, kind = "Cleanse",
      text = "Periodically removes a poison effect from nearby party members." },

    { name = "Windfury Totem", spellID = 8512, kind = "Buff",
      text = "Enhances nearby party members' main-hand weapons with a chance to make extra attacks." },
    { name = "Grace of Air Totem", spellID = 8835, kind = "Buff",
      text = "Increases the Agility of nearby party members." },
    { name = "Nature Resistance Totem", spellID = 10595, kind = "Buff",
      text = "Increases the Nature resistance of nearby party and raid members." },
    { name = "Windwall Totem", spellID = 15107, kind = "Buff",
      text = "Reduces ranged damage taken by nearby party members." },
    { name = "Grounding Totem", spellID = 8177, kind = "Utility",
      text = "Redirects one harmful spell cast at a nearby party member to the totem." },
    { name = "Sentry Totem", spellID = 6495, kind = "Utility",
      text = "Lets its owner observe the area around the totem and warns them if it is attacked." },
}

local effectsByName = {}

-- Forever uses restricted values. Never inspect, compare, format, or index one.
local function IsReadable(value)
    if canaccessvalue then
        local ok, accessible = pcall(canaccessvalue, value)
        return ok and accessible
    end
    if issecretvalue then
        local ok, secret = pcall(issecretvalue, value)
        return ok and not secret
    end
    return true
end

local function Field(value, key)
    if not IsReadable(value) or type(value) ~= "table" then
        return nil
    end
    if canaccesstable and not canaccesstable(value) then
        return nil
    end
    local field = value[key]
    if IsReadable(field) then
        return field
    end
end

local function NormalizeName(name)
    if not IsReadable(name) or type(name) ~= "string" then
        return nil
    end
    name = name:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    name = name:gsub("%s+%([Rr]ank%s+[^%)]+%)$", "")
    name = name:gsub("%s+[IVXLCDM]+$", "")
    name = name:gsub("%s+%d+$", "")
    return name:lower()
end

local function AddName(name, effect)
    local key = NormalizeName(name)
    if key and key ~= "" then
        effectsByName[key] = effect
    end
end

local function GetLocalizedSpellName(spellID)
    if C_Spell and C_Spell.GetSpellName then
        local ok, name = pcall(C_Spell.GetSpellName, spellID)
        if ok and IsReadable(name) then return name end
    elseif GetSpellInfo then
        local ok, name = pcall(GetSpellInfo, spellID)
        if ok and IsReadable(name) then return name end
    end
end

local function BuildNameIndex()
    wipe(effectsByName)
    for _, effect in ipairs(EFFECTS) do
        AddName(effect.name, effect)
        AddName(GetLocalizedSpellName(effect.spellID), effect)
    end
end

local function FindEffect(name)
    local key = NormalizeName(name)
    if not key then return nil end
    local effect = effectsByName[key]
    if effect then return effect end

    -- Allow harmless owner/level suffixes, but never partial totem-name matches.
    for knownName, knownEffect in pairs(effectsByName) do
        if key:sub(1, #knownName) == knownName then
            local separator = key:sub(#knownName + 1, #knownName + 1)
            if separator == " " or separator == "-" then
                return knownEffect
            end
        end
    end
end

local function GetLegacyTooltipName(tooltip)
    if tooltip.GetUnit then
        local ok, unitName, unitToken = pcall(tooltip.GetUnit, tooltip)
        if ok and IsReadable(unitName) and type(unitName) == "string" then
            return unitName
        end
        if ok and IsReadable(unitToken) and unitToken and UnitName then
            local nameOK, name = pcall(UnitName, unitToken)
            if nameOK and IsReadable(name) then return name end
        end
    end
    local tooltipName = tooltip.GetName and tooltip:GetName()
    local firstLine = tooltipName and _G[tooltipName .. "TextLeft1"]
    local text = firstLine and firstLine:GetText()
    return IsReadable(text) and text or nil
end

local function GetTooltipName(tooltip, data)
    local lines = Field(data, "lines")
    local firstLine = Field(lines, 1)
    local title = Field(firstLine, "leftText")
    if type(title) == "string" then return title end
    return GetLegacyTooltipName(tooltip)
end

local function AppendTotemInformation(tooltip, data)
    if tooltip ~= GameTooltip or not TotemTooltipForeverDB or not TotemTooltipForeverDB.enabled or added then
        return
    end
    if data and tooltip.GetPrimaryTooltipData then
        local primary = tooltip:GetPrimaryTooltipData()
        if not IsReadable(primary) or (primary and primary ~= data) then return end
    end

    local effect = FindEffect(GetTooltipName(tooltip, data))
    if not effect then return end

    added = true
    local color = COLORS[effect.kind]
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine("Totem effect", effect.kind, 0.25, 0.78, 0.92, color[1], color[2], color[3])
    tooltip:AddLine(effect.text, 0.95, 0.95, 0.95, true)
end

local function InstallTooltipHooks()
    if hooked or not GameTooltip then return end

    local usesTooltipData = type(GameTooltip.GetPrimaryTooltipData) == "function"
        and TooltipDataProcessor
        and type(TooltipDataProcessor.AddTooltipPostCall) == "function"
        and Enum and Enum.TooltipDataType

    local function SafeAppend(tooltip, data)
        if busy then return end
        busy = true
        pcall(AppendTotemInformation, tooltip, data)
        busy = false
    end

    if usesTooltipData then
        if Enum.TooltipDataType.Unit then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, SafeAppend)
        end
        if Enum.TooltipDataType.Totem then
            TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Totem, SafeAppend)
        end
    elseif GameTooltip.HasScript and GameTooltip:HasScript("OnTooltipSetUnit") then
        GameTooltip:HookScript("OnTooltipSetUnit", SafeAppend)
    else
        return
    end

    if GameTooltip.HasScript and GameTooltip:HasScript("OnTooltipCleared") then
        GameTooltip:HookScript("OnTooltipCleared", function() added = false end)
    end
    hooked = true
end

local function PrintStatus()
    local state = TotemTooltipForeverDB.enabled and "enabled" or "disabled"
    print(PREFIX .. " is " .. state .. ".")
end

SLASH_TOTEMTOOLTIPFOREVER1 = "/ttf"
SLASH_TOTEMTOOLTIPFOREVER2 = "/totemtooltip"
SlashCmdList.TOTEMTOOLTIPFOREVER = function(message)
    local command = (message or ""):lower():match("^%s*(.-)%s*$")
    if command == "on" then
        TotemTooltipForeverDB.enabled = true
        print(PREFIX .. " enabled.")
    elseif command == "off" then
        TotemTooltipForeverDB.enabled = false
        print(PREFIX .. " disabled.")
    elseif command == "toggle" then
        TotemTooltipForeverDB.enabled = not TotemTooltipForeverDB.enabled
        PrintStatus()
    else
        PrintStatus()
        print("Use |cffffffff/ttf on|r, |cffffffff/ttf off|r, or |cffffffff/ttf toggle|r.")
    end
end

TTF:RegisterEvent("ADDON_LOADED")
TTF:RegisterEvent("PLAYER_LOGIN")
TTF:RegisterEvent("SPELL_DATA_LOAD_RESULT")
TTF:SetScript("OnEvent", function(_, event, value)
    if event == "ADDON_LOADED" and value == ADDON_NAME then
        if type(TotemTooltipForeverDB) ~= "table" then TotemTooltipForeverDB = {} end
        if TotemTooltipForeverDB.enabled == nil then TotemTooltipForeverDB.enabled = true end
        BuildNameIndex()
        InstallTooltipHooks()
    elseif event == "PLAYER_LOGIN" then
        InstallTooltipHooks()
    elseif event == "SPELL_DATA_LOAD_RESULT" then
        BuildNameIndex()
    end
end)
