local addonName, addon = ...
local L = addon.L

addon.VERSION = "1.0.2"
addon.SCHEMA = 1
addon.MODE_RXP = "restedxp"
addon.MODE_ALWAYS = "always"

local DEFAULTS = {
    schema = 1,
    enabled = true,
    mode = addon.MODE_RXP,
    minimap = {
        shown = true,
        angle = 225,
    },
}
addon.DEFAULTS = DEFAULTS

local function deepCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local copy = {}
    seen[value] = copy
    for key, child in pairs(value) do copy[deepCopy(key, seen)] = deepCopy(child, seen) end
    return copy
end
addon.DeepCopy = deepCopy

local function normalizeAngle(value)
    value = tonumber(value) or DEFAULTS.minimap.angle
    value = value % 360
    if value < 0 then value = value + 360 end
    return value
end
addon.NormalizeAngle = normalizeAngle

local function angleFromXY(x, y)
    x, y = tonumber(x), tonumber(y)
    if not x or not y or (x == 0 and y == 0) then return nil end
    local atan2 = math.atan2
    if atan2 then return normalizeAngle(math.deg(atan2(y, x))) end
    local angle = math.deg(math.atan(y / (x == 0 and 0.000001 or x)))
    if x < 0 then angle = angle + 180 elseif y < 0 then angle = angle + 360 end
    return normalizeAngle(angle)
end
addon.AngleFromXY = angleFromXY

function addon.SanitizeDB(db)
    db = type(db) == "table" and db or {}
    db.schema = addon.SCHEMA
    db.enabled = db.enabled ~= false
    db.mode = db.mode == addon.MODE_ALWAYS and addon.MODE_ALWAYS or addon.MODE_RXP
    db.toggleKey = nil -- Remove the obsolete 0.1.1 test-build field if a profile retained it.
    db.minimap = type(db.minimap) == "table" and db.minimap or {}
    if db.minimap.angle == nil then
        db.minimap.angle = db.minimap.minimapAngle or angleFromXY(db.minimap.x, db.minimap.y)
    end
    db.minimap.angle = normalizeAngle(db.minimap.angle)
    db.minimap.shown = db.minimap.shown ~= false
    db.minimap.minimapAngle, db.minimap.x, db.minimap.y = nil, nil, nil
    return db
end

function addon.Print(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cffd8ad52" .. L.SHORT_NAME .. ":|r " .. tostring(message))
    end
end

local function isAddOnLoaded(name)
    if C_AddOns and C_AddOns.IsAddOnLoaded then return C_AddOns.IsAddOnLoaded(name) end
    return IsAddOnLoaded and IsAddOnLoaded(name) or false
end

function addon.IsRestedXPLoaded()
    return isAddOnLoaded("RXPGuides")
end

function addon.IsQuestieLoaded()
    return isAddOnLoaded("Questie")
end

function addon.IsRestedXPVisible()
    if not addon.IsRestedXPLoaded() then return false, "not loaded" end
    local frame = _G.RXPFrame
    if not frame then return false, "guide frame unavailable" end
    if frame.IsShown and frame:IsShown() then return true, "guide frame visible" end
    if type(frame.IsFeatureEnabled) == "function" then
        local ok, enabled = pcall(frame.IsFeatureEnabled, frame)
        if ok and enabled then return true, "guide window enabled" end
    end
    return false, "guide window hidden"
end

function addon.ShouldHide()
    if not addon.db or not addon.db.enabled then return false end
    if addon.db.mode == addon.MODE_ALWAYS then return true end
    return addon.IsRestedXPVisible()
end

function addon.GetTracker()
    local frame = _G.ObjectiveTrackerFrame
    if frame and frame.Hide and frame.Show and frame.IsShown then return frame end
    return nil
end

local function noteFailure(message)
    addon.compatibilityError = tostring(message or "unknown tracker error")
    addon.compatibilityDegraded = true
end

function addon.HookTracker()
    local tracker = addon.GetTracker()
    if not tracker then
        addon.compatibilityDegraded = true
        addon.compatibilityError = "ObjectiveTrackerFrame is unavailable on this client build."
        return false
    end
    if addon.trackerHooked == tracker then return true end
    local ok, err = pcall(tracker.HookScript, tracker, "OnShow", function()
        if addon.ShouldHide() then addon.RequestApply("Blizzard showed the tracker") end
    end)
    if not ok then noteFailure(err); return false end
    addon.trackerHooked = tracker
    addon.compatibilityDegraded = false
    addon.compatibilityError = nil
    return true
end

function addon.HookRestedXP()
    local frame = _G.RXPFrame
    if not frame or addon.rxpHooked == frame or not frame.HookScript then return end
    local function changed() addon.RequestApply("RestedXP visibility changed") end
    local ok = pcall(frame.HookScript, frame, "OnShow", changed)
    if ok then
        pcall(frame.HookScript, frame, "OnHide", changed)
        addon.rxpHooked = frame
    end
end

local function applyNow(reason)
    addon.applyScheduled = false
    addon.lastReason = reason or addon.lastReason
    local inCombat = InCombatLockdown and InCombatLockdown()
    local shouldHide = addon.ShouldHide()
    -- Re-hiding is intentionally allowed in combat. Blizzard can show the
    -- tracker when combat begins, and postponing this Hide until combat ends
    -- defeats the add-on's purpose. Any state that could show or restore the
    -- tracker remains deferred until PLAYER_REGEN_ENABLED.
    if inCombat and not shouldHide then
        addon.pendingCombat = true
        if addon.RefreshUI then addon.RefreshUI() end
        return false, "combat"
    end
    addon.pendingCombat = false
    if not addon.HookTracker() then
        if addon.RefreshUI then addon.RefreshUI() end
        return false, "unsupported"
    end
    addon.HookRestedXP()
    local tracker = addon.GetTracker()
    if not tracker then return false, "unsupported" end
    if shouldHide then
        if not addon.hiddenByUs then
            addon.previousShown = tracker:IsShown() and true or false
        end
        local ok, err = pcall(tracker.Hide, tracker)
        if not ok then noteFailure(err); return false, "error" end
        addon.hiddenByUs = true
        addon.hideCount = (addon.hideCount or 0) + 1
    elseif addon.hiddenByUs then
        local ok, err
        if addon.previousShown then ok, err = pcall(tracker.Show, tracker)
        else ok, err = pcall(tracker.Hide, tracker) end
        if not ok then noteFailure(err); return false, "error" end
        addon.hiddenByUs = false
        addon.previousShown = nil
    end
    if addon.RefreshUI then addon.RefreshUI() end
    return true
end
addon.ApplyNow = applyNow

function addon.RequestApply(reason, immediate)
    addon.lastReason = reason or addon.lastReason
    if immediate then return applyNow(reason) end
    if addon.applyScheduled then return end
    addon.applyScheduled = true
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function() applyNow(reason) end)
    else
        applyNow(reason)
    end
end

function addon.SetEnabled(enabled, source)
    addon.db.enabled = enabled and true or false
    addon.RequestApply(source or "setting changed", true)
    if addon.UpdateMinimapVisual then addon.UpdateMinimapVisual() end
    if addon.SyncPanel then addon.SyncPanel() end
end

function addon.ToggleEnabled(source)
    addon.SetEnabled(not addon.db.enabled, source or "toggle")
    addon.Print(addon.db.enabled and L.STATUS_ON or L.STATUS_OFF)
end

function addon.SetMode(mode)
    addon.db.mode = mode == addon.MODE_ALWAYS and addon.MODE_ALWAYS or addon.MODE_RXP
    addon.RequestApply("mode changed", true)
    if addon.SyncPanel then addon.SyncPanel() end
end

function addon.ResetSettings()
    _G.RXPObjectiveHiderForeverBackupDB = deepCopy(addon.db)
    addon.db = addon.SanitizeDB(deepCopy(DEFAULTS))
    _G.RXPObjectiveHiderForeverDB = addon.db
    addon.RequestApply("settings reset", true)
    if addon.ApplyMinimapVisibility then addon.ApplyMinimapVisibility() end
    if addon.ApplyMinimapPosition then addon.ApplyMinimapPosition(true) end
    if addon.SyncPanel then addon.SyncPanel() end
    addon.Print("Settings reset. The previous profile is available with /rxpoh recover.")
end

function addon.RecoverBackup()
    if type(_G.RXPObjectiveHiderForeverBackupDB) ~= "table" then
        addon.Print("No backup profile is available.")
        return false
    end
    addon.db = addon.SanitizeDB(deepCopy(_G.RXPObjectiveHiderForeverBackupDB))
    _G.RXPObjectiveHiderForeverDB = addon.db
    addon.RequestApply("backup recovered", true)
    if addon.ApplyMinimapVisibility then addon.ApplyMinimapVisibility() end
    if addon.ApplyMinimapPosition then addon.ApplyMinimapPosition(true) end
    if addon.SyncPanel then addon.SyncPanel() end
    addon.Print("Backup profile recovered.")
    return true
end

function addon.GetStatus()
    local _, _, _, interface = GetBuildInfo()
    local rxpVisible, rxpReason = addon.IsRestedXPVisible()
    return {
        interface = tonumber(interface),
        trackerFound = addon.GetTracker() ~= nil,
        hiddenByUs = addon.hiddenByUs == true,
        enabled = addon.db and addon.db.enabled == true,
        mode = addon.db and addon.db.mode or addon.MODE_RXP,
        pendingCombat = addon.pendingCombat == true,
        restedXPLoaded = addon.IsRestedXPLoaded(),
        restedXPVisible = rxpVisible,
        restedXPReason = rxpReason,
        questieLoaded = addon.IsQuestieLoaded(),
        degraded = addon.compatibilityDegraded == true,
        error = addon.compatibilityError,
        hideCount = addon.hideCount or 0,
    }
end

function addon.PrintStatus()
    local s = addon.GetStatus()
    addon.Print((s.enabled and "ON" or "OFF") .. " · mode " .. s.mode .. " · tracker " ..
        (s.hiddenByUs and "hidden" or "released") .. (s.pendingCombat and " · pending combat" or ""))
    addon.Print("RestedXP " .. (s.restedXPLoaded and "loaded" or "not loaded") .. ", " .. s.restedXPReason ..
        " · Questie " .. (s.questieLoaded and "loaded" or "not loaded") .. " · interface " .. tostring(s.interface or "unknown"))
    if s.degraded then addon.Print("Compatibility warning: " .. tostring(s.error)) end
end

local function initializeDB()
    local existing = _G.RXPObjectiveHiderForeverDB
    if type(existing) == "table" then _G.RXPObjectiveHiderForeverBackupDB = deepCopy(existing) end
    addon.db = addon.SanitizeDB(existing)
    _G.RXPObjectiveHiderForeverDB = addon.db
    if type(_G.RXPObjectiveHiderForeverBackupDB) ~= "table" then
        _G.RXPObjectiveHiderForeverBackupDB = deepCopy(addon.db)
    end
    _G.RXPObjectiveHiderForeverBackupDB.toggleKey = nil
end

local eventFrame = CreateFrame("Frame")
addon.eventFrame = eventFrame
local events = {
    "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_ENABLED",
    "QUEST_ACCEPTED", "QUEST_TURNED_IN", "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED",
    "ZONE_CHANGED_NEW_AREA", "DISPLAY_SIZE_CHANGED", "UI_SCALE_CHANGED",
}
for _, event in ipairs(events) do pcall(eventFrame.RegisterEvent, eventFrame, event) end

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        initializeDB()
        local _, _, _, interface = GetBuildInfo()
        if tonumber(interface) ~= 16001 then
            addon.compatibilityDegraded = true
            addon.compatibilityError = "Untested interface " .. tostring(interface) .. "; expected 16001."
        end
        addon.RequestApply("add-on loaded")
    elseif event == "ADDON_LOADED" and (arg1 == "RXPGuides" or arg1 == "Blizzard_ObjectiveTracker") then
        addon.HookRestedXP()
        addon.RequestApply(arg1 .. " loaded")
    elseif event == "PLAYER_REGEN_ENABLED" then
        addon.RequestApply("combat ended", true)
    elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
        if addon.ApplyMinimapPosition then addon.ApplyMinimapPosition(true) end
    else
        addon.RequestApply(event)
    end
end)

