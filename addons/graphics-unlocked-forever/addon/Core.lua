local _, EGF = ...

EGF.TITLE = "Graphics Unlocked: Forever"
EGF.VERSION = "1.0.1"
EGF.INTERFACE = 16001
EGF.settings = {}
EGF.settingsByID = {}
EGF.presets = {}
EGF.presetsByID = {}

local DEFAULTS = {
    minimapAngle = 225,
    minimapHidden = false,
    windowX = 0,
    windowY = 0,
    capturedOriginals = {},
    desiredValues = {},
    autoApply = false,
}

local function copyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = type(value) == "table" and {} or value
        end
    end
end

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < 1000000
end

function EGF.Clamp(value, low, high)
    value = tonumber(value)
    if not finite(value) then return low end
    return math.max(low, math.min(high, value))
end

function EGF.RoundToStep(value, low, step)
    if not step or step <= 0 then return value end
    return low + math.floor(((value - low) / step) + 0.5) * step
end

function EGF.Print(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc66" .. EGF.TITLE .. ":|r " .. tostring(message))
    end
end

function EGF.LoadSettings()
    if type(GraphicsUnlockedForeverDB) ~= "table" then GraphicsUnlockedForeverDB = {} end
    EGF.db = GraphicsUnlockedForeverDB
    copyDefaults(EGF.db, DEFAULTS)
    if type(EGF.db.capturedOriginals) ~= "table" then EGF.db.capturedOriginals = {} end
    if type(EGF.db.desiredValues) ~= "table" then EGF.db.desiredValues = {} end
    EGF.db.autoApply = EGF.db.autoApply and true or false
    EGF.db.minimapAngle = tonumber(EGF.db.minimapAngle) or DEFAULTS.minimapAngle
    EGF.db.minimapHidden = EGF.db.minimapHidden and true or false
    EGF.db.windowX = tonumber(EGF.db.windowX) or 0
    EGF.db.windowY = tonumber(EGF.db.windowY) or 0
end

local function apiGetCVar(name)
    if C_CVar and type(C_CVar.GetCVar) == "function" then
        local ok, value = pcall(C_CVar.GetCVar, name)
        if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
    end
    if type(GetCVar) == "function" then
        local ok, value = pcall(GetCVar, name)
        if ok and value ~= nil and tostring(value) ~= "" then return tostring(value) end
    end
end

local function apiSetCVar(name, value)
    if C_CVar and type(C_CVar.SetCVar) == "function" then
        local ok, result = pcall(C_CVar.SetCVar, name, tostring(value))
        return ok and result ~= false, ok and nil or result
    end
    if type(SetCVar) == "function" then
        local ok, result = pcall(SetCVar, name, tostring(value))
        return ok and result ~= false, ok and nil or result
    end
    return false, "This client does not expose the CVar setting API."
end

function EGF.GetRawValue(definition)
    return definition and apiGetCVar(definition.cvar)
end

function EGF.GetValue(definition)
    local raw = EGF.GetRawValue(definition)
    if raw == nil then return nil end
    if definition.kind == "toggle" then
        return raw == tostring(definition.onValue)
    end
    if definition.fromRaw then
        local ok, value = pcall(definition.fromRaw, raw)
        if ok then return value end
        return nil
    end
    return tonumber(raw)
end

local function validateDefinition(definition)
    if type(definition) ~= "table" then return false, "definition must be a table" end
    if type(definition.id) ~= "string" or definition.id == "" then return false, "missing id" end
    if type(definition.cvar) ~= "string" or definition.cvar == "" then return false, "missing cvar" end
    if type(definition.label) ~= "string" or definition.label == "" then return false, "missing label" end
    if definition.kind ~= "toggle" and definition.kind ~= "slider" then return false, "unsupported kind" end
    if definition.kind == "toggle" then
        definition.onValue = definition.onValue == nil and "1" or tostring(definition.onValue)
        definition.offValue = definition.offValue == nil and "0" or tostring(definition.offValue)
    else
        definition.min = tonumber(definition.min)
        definition.max = tonumber(definition.max)
        definition.step = tonumber(definition.step) or 1
        if not definition.min or not definition.max or definition.min >= definition.max or definition.step <= 0 then
            return false, "invalid slider range"
        end
    end
    definition.category = definition.category or "Other"
    definition.description = definition.description or ""
    return true
end

function EGF.RegisterSetting(definition)
    local ok, reason = validateDefinition(definition)
    if not ok then error("Invalid graphics setting: " .. reason, 2) end
    if EGF.settingsByID[definition.id] then error("Duplicate graphics setting id: " .. definition.id, 2) end
    EGF.settings[#EGF.settings + 1] = definition
    EGF.settingsByID[definition.id] = definition
end

function EGF.RegisterPreset(preset)
    if type(preset) ~= "table" or type(preset.id) ~= "string" or
            type(preset.label) ~= "string" or type(preset.values) ~= "table" then
        error("Invalid graphics preset", 2)
    end
    if EGF.presetsByID[preset.id] then error("Duplicate graphics preset id: " .. preset.id, 2) end
    EGF.presets[#EGF.presets + 1] = preset
    EGF.presetsByID[preset.id] = preset
end

function EGF.SetValue(definition, value, remember)
    if not definition then return false, "Unknown setting." end
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        return false, "Graphics controls are locked until combat ends."
    end
    local raw
    if definition.kind == "toggle" then
        raw = value and definition.onValue or definition.offValue
    else
        value = EGF.Clamp(value, definition.min, definition.max)
        value = EGF.RoundToStep(value, definition.min, definition.step)
        if definition.toRaw then
            local ok, converted = pcall(definition.toRaw, value)
            if not ok then return false, "Could not convert this value for the game client." end
            raw = tostring(converted)
        else
            raw = string.format(definition.format or "%g", value)
        end
    end

    local current = EGF.GetRawValue(definition)
    if current == nil then return false, "The game did not recognise " .. definition.cvar .. "." end
    if EGF.db and EGF.db.capturedOriginals[definition.id] == nil then
        EGF.db.capturedOriginals[definition.id] = current
    end

    local ok, reason = apiSetCVar(definition.cvar, raw)
    if not ok then return false, "The game rejected this change" .. (reason and ": " .. tostring(reason) or ".") end
    if EGF.db and remember ~= false then EGF.db.desiredValues[definition.id] = raw end
    if definition.onApply then pcall(definition.onApply, value) end
    return true, definition.reload and "Changed. Reload the UI to finish applying it." or "Changed."
end

function EGF.RestoreSetting(definition)
    if not definition or not EGF.db then return false, "Unknown setting." end
    local original = EGF.db.capturedOriginals[definition.id]
    if original == nil then return false, "No earlier value was captured for this setting." end
    local ok, reason = apiSetCVar(definition.cvar, original)
    if ok then
        EGF.db.capturedOriginals[definition.id] = nil
        EGF.db.desiredValues[definition.id] = nil
    end
    return ok, ok and "Restored the value captured before the first change." or tostring(reason)
end

function EGF.RestoreAll()
    local restored, failed = 0, 0
    for _, definition in ipairs(EGF.settings) do
        if EGF.db.capturedOriginals[definition.id] ~= nil then
            local ok = EGF.RestoreSetting(definition)
            if ok then restored = restored + 1 else failed = failed + 1 end
        end
    end
    return restored, failed
end

function EGF.ApplyPreset(preset)
    if not preset then return 0, 1 end
    local changed, failed = 0, 0
    for id, value in pairs(preset.values) do
        local definition = EGF.settingsByID[id]
        local ok = definition and EGF.SetValue(definition, value)
        if ok then changed = changed + 1 else failed = failed + 1 end
    end
    return changed, failed
end

function EGF.ApplySavedValues()
    if not EGF.db or not EGF.db.autoApply then return 0, 0 end
    if type(InCombatLockdown) == "function" and InCombatLockdown() then return 0, 0 end
    local changed, failed = 0, 0
    for id, raw in pairs(EGF.db.desiredValues) do
        local definition = EGF.settingsByID[id]
        if definition and EGF.GetRawValue(definition) ~= nil then
            local ok = apiSetCVar(definition.cvar, raw)
            if ok then changed = changed + 1 else failed = failed + 1 end
        end
    end
    return changed, failed
end

function EGF.FindSetting(text)
    text = tostring(text or ""):lower()
    if EGF.settingsByID[text] then return EGF.settingsByID[text] end
    for _, definition in ipairs(EGF.settings) do
        if definition.cvar:lower() == text then return definition end
    end
end

function EGF.StatusText()
    return string.format("Version %s; interface %d; %d verified control(s).", EGF.VERSION, EGF.INTERFACE, #EGF.settings)
end
