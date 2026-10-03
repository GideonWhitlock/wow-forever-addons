-- SPDX-License-Identifier: GPL-3.0-or-later
local addonName, ns = ...
local hooked, busy, added = false, false, false
local history, lastObservation = {}, nil
ns.stats = { objects = 0, matched = 0, appended = 0, errors = 0 }

-- A restricted value is never compared, formatted, used as a key or inspected.
function ns.Readable(value)
    if canaccessvalue then return canaccessvalue(value) end
    if issecretvalue then return not issecretvalue(value) end
    return false
end

function ns.Field(value, key)
    if not ns.Readable(value) or type(value) ~= "table" then return nil end
    if canaccesstable and not canaccesstable(value) then return nil end
    local field = value[key]
    if ns.Readable(field) then return field end
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, result = pcall(fn, ...)
    if ok and ns.Readable(result) then return result end
end
ns.SafeCall = safeCall

function ns.Identify(data)
    local kind = ns.Field(data, "type")
    if kind == ns.unitType then
        local guid = ns.Field(data, "guid")
        if type(guid) ~= "string" then return nil end
        local entry = guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
        entry = entry and tonumber(entry)
        return entry and ns.creatures[entry], entry, "camp service ID"
    end
    if kind ~= ns.objectType then return nil end
    local guid = ns.Field(data, "guid")
    if type(guid) == "string" and guid ~= "" then
        local entry = guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
        entry = entry and tonumber(entry)
        -- A known but unrelated GUID must never fall back to a matching name.
        return entry and ns.objects[entry], entry, "object ID"
    end
    local title = ns.Field(ns.Field(ns.Field(data, "lines"), 1), "leftText")
    local names = ns.names[ns.locale]
    local entry = type(title) == "string" and names and names[title]
    local object = entry and ns.objects[entry]
    if object and object.nameFallback then return object, entry, "exact object name" end
end

local function auraAccessAllowed()
    if type(InCombatLockdown) ~= "function" then return false end
    local combat = safeCall(InCombatLockdown)
    if combat ~= false then return false end
    if not C_Secrets or type(C_Secrets.ShouldAurasBeSecret) ~= "function" then return false end
    return safeCall(C_Secrets.ShouldAurasBeSecret) == false
end

function ns.AuraStatus(benefit)
    if not benefit.aura or not auraAccessAllowed() then return nil end
    if not C_UnitAuras then return nil end
    local aura = safeCall(C_UnitAuras.GetPlayerAuraBySpellID, benefit.aura)
    -- An absent or unavailable aura is intentionally not called "Not active".
    if ns.Field(aura, "spellId") ~= benefit.aura then return nil end
    local expiration = ns.Field(aura, "expirationTime")
    local now = safeCall(GetTime)
    if type(expiration) ~= "number" or type(now) ~= "number" then return nil end
    if expiration <= now then return nil end
    local left = expiration - now
    if left ~= left or left == math.huge then return nil end
    local timeText = left < 60 and (math.ceil(left) .. " seconds") or (math.ceil(left / 60) .. " minutes")
    if benefit.lockout then return "Ready again in " .. timeText .. "." end
    return "Your buff: " .. timeText .. " remaining."
end

function ns.Description(benefit)
    return benefit.effect
end

local function atLevel(rows, level)
    for _, row in ipairs(rows) do if level <= row[1] then return row[2] end end
end

function ns.Prediction(benefit)
    if not ns.buildMatches then return nil end
    local level = safeCall(UnitLevel, "player")
    if type(level) ~= "number" or level < 1 or level > 60 or level % 1 ~= 0 then return nil end
    if benefit.armor then
        local armor = atLevel(benefit.armor, level)
        local attributes = atLevel(benefit.attributes, level)
        local resist = atLevel(benefit.resistances, level)
        local text = "+" .. armor .. " armor"
        if attributes > 0 then text = text .. ", +" .. attributes .. " all attributes" end
        if resist > 0 then text = text .. ", +" .. resist .. " all resistances" end
        return text .. "."
    end
    if not benefit.levels or not benefit.prediction then return nil end
    local amount = atLevel(benefit.levels, level)
    if not amount then return nil end
    if benefit.lockout then return benefit.prediction end
    return string.format(benefit.prediction, amount)
end

local function observe(data, object, entry, method, status)
    if not ns.recording then return end
    -- Never record player names, pets or unrelated creature details.
    if ns.Field(data, "type") ~= ns.objectType and not object then return end
    local title = ns.Field(ns.Field(ns.Field(data, "lines"), 1), "leftText")
    if type(title) ~= "string" then title = "name unavailable" end
    local record = title .. " | " .. (entry and tostring(entry) or "no readable ID")
        .. " | " .. (object and method or "unchanged") .. " | " .. (status or "status omitted")
    local dataID = ns.Field(data, "id")
    if type(dataID) == "number" then record = record .. " | tooltip id " .. dataID end
    local guid = ns.Field(data, "guid")
    record = record .. " | GUID " .. (type(guid) == "string" and "readable" or "unavailable")
    if record ~= lastObservation then
        lastObservation = record
        history[#history + 1] = record
        if #history > 25 then table.remove(history, 1) end
        ns.db.hoverChecks = history
    end
end

local function append(tooltip, data)
    if tooltip ~= GameTooltip then return end
    local object, entry, method = ns.Identify(data)
    if ns.Field(data, "type") == ns.objectType then ns.stats.objects = ns.stats.objects + 1 end
    local benefit = object and ns.benefits[object.benefit]
    local status = benefit and ns.db.showStatus and ns.AuraStatus(benefit)
    observe(data, object, entry, method, status)
    if not benefit or not ns.db.enabled or added then return end
    ns.stats.matched = ns.stats.matched + 1
    -- Ignore appended sub-tooltips; only the primary real world object is ours.
    local primary = tooltip.GetPrimaryTooltipData and tooltip:GetPrimaryTooltipData()
    if not ns.Readable(primary) then return end
    if primary and primary ~= data then return end
    added = true
    tooltip:AddLine(" ")
    local prediction = ns.Prediction(benefit)
    local prefix = prediction and not benefit.lockout and "At your level: " or "Benefit: "
    tooltip:AddLine(prefix .. (prediction or ns.Description(benefit)), 0.55, 1, 0.55, true)
    if prediction and benefit.predictionNote then tooltip:AddLine(benefit.predictionNote, 0.75, 0.75, 0.75, true) end
    if benefit.receive or benefit.duration then tooltip:AddLine(" ") end
    if benefit.receive then tooltip:AddLine(benefit.receive, 1, 1, 1, true) end
    if benefit.duration then tooltip:AddLine(benefit.duration, 1, 1, 1, true) end
    if object.requirement then tooltip:AddLine(object.requirement, 1, 1, 1, true) end
    if benefit.exclusive then tooltip:AddLine(benefit.exclusive, 0.75, 0.75, 0.75, true) end
    if object.utility then
        tooltip:AddLine(" ")
        tooltip:AddLine("Extra: " .. object.utility, 1, 0.82, 0, true)
    end
    if status then tooltip:AddLine(" "); tooltip:AddLine(status, 0.55, 1, 0.55, true) end
    ns.stats.appended = ns.stats.appended + 1
    -- Blizzard shows and sizes the tooltip after its post-callbacks.
    -- Never call SetOwner, SetPoint, ClearLines or replace a tooltip script.
end

function ns.InstallHook()
    if hooked or not GameTooltip or not TooltipDataProcessor then return end
    ns.objectType = Enum and Enum.TooltipDataType and Enum.TooltipDataType.Object
    ns.unitType = Enum and Enum.TooltipDataType and Enum.TooltipDataType.Unit
    if not ns.objectType or type(TooltipDataProcessor.AddTooltipPostCall) ~= "function" then return end
    GameTooltip:HookScript("OnTooltipCleared", function() added = false end)
    local function callback(tooltip, data)
        if busy or not ns.db then return end
        busy = true
        local ok = pcall(append, tooltip, data)
        busy = false
        if not ok then ns.stats.errors = ns.stats.errors + 1 end
    end
    TooltipDataProcessor.AddTooltipPostCall(ns.objectType, callback)
    if ns.unitType then TooltipDataProcessor.AddTooltipPostCall(ns.unitType, callback) end
    hooked = true
end

function ns.Report()
    local version, build, date, interface = GetBuildInfo()
    local lines = {
        "Campfire Tooltips - version " .. ns.version,
        "Client: " .. version .. " / " .. build .. " / " .. date .. " / Interface " .. interface,
        "Locale: " .. ns.locale,
        "Object callback registered: " .. tostring(hooked),
        "Saved preferences loaded: " .. tostring(ns.loadedSaved),
        "Previous session: " .. tostring(ns.previousSession or "none"),
        "Current session: " .. tostring(ns.db.session),
        "Enabled: " .. tostring(ns.db.enabled) .. "; show status: " .. tostring(ns.db.showStatus),
        "Object callbacks: " .. ns.stats.objects .. "; sections added: " .. ns.stats.appended .. "; callback errors: " .. ns.stats.errors,
        "Aura access currently permitted: " .. tostring(auraAccessAllowed()),
        "Hover recording: " .. tostring(ns.recording == true),
        "",
        "Recent recorded real object hovers (up to 25):",
    }
    for _, line in ipairs(ns.db.hoverChecks or {}) do lines[#lines + 1] = line end
    lines[#lines + 1] = "\nClient spell descriptions (placement cooldown is not buff duration):"
    local seen = {}
    local all = {}
    for _, object in pairs(ns.objects) do all[#all+1] = object end
    for _, object in pairs(ns.creatures) do all[#all+1] = object end
    table.sort(all, function(a,b) return a.spell < b.spell end)
    for _, object in ipairs(all) do
        local spell = object.spell
        if not seen[spell] then
            seen[spell] = true
            local description = C_Spell and safeCall(C_Spell.GetSpellDescription, spell)
            if type(description) == "string" then
                lines[#lines + 1] = spell .. " " .. object.name .. ": " .. description
            elseif C_Spell and C_Spell.RequestLoadSpellData then
                C_Spell.RequestLoadSpellData(spell)
            end
        end
    end
    ns.db.lastReport = table.concat(lines, "\n")
    return ns.db.lastReport
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then
        ns.loadedSaved = type(CampfireTooltipsDB) == "table"
        if not ns.loadedSaved then CampfireTooltipsDB = {} end
        ns.db = CampfireTooltipsDB
        if type(ns.db.enabled) ~= "boolean" then ns.db.enabled = true end
        if type(ns.db.showStatus) ~= "boolean" then ns.db.showStatus = true end
        ns.previousSession = ns.db.session
        ns.db.session = (GetServerTime and GetServerTime()) or time()
        ns.locale = GetLocale()
        local _, build = GetBuildInfo()
        ns.buildMatches = build == ns.checkedBuild
        ns.InstallHook()
        if ns.CreateSettings then ns.CreateSettings() end
    elseif event == "PLAYER_LOGIN" then
        ns.InstallHook()
    end
end)
