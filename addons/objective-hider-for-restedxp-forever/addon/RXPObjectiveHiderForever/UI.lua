local _, addon = ...
local L = addon.L

local function makeText(parent, template, text, x, y, width)
    local label = parent:CreateFontString(nil, "ARTWORK", template)
    label:SetPoint("TOPLEFT", x, y)
    if width then label:SetWidth(width); label:SetJustifyH("LEFT"); label:SetWordWrap(true) end
    label:SetText(text)
    return label
end

local function makeCheck(parent, text, x, y, onClick)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    local label = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    label:SetText(text)
    check.label = label
    check:SetScript("OnClick", function(self) onClick(self:GetChecked() and true or false) end)
    return check
end

local function makeButton(parent, text, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 24)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

function addon.RefreshUI()
    local panel = addon.settingsPanel
    if panel and panel:IsShown() and addon.db then
        local s = addon.GetStatus()
        panel.status:SetText((s.enabled and L.STATUS_ON or L.STATUS_OFF) ..
            (s.pendingCombat and " — " .. L.STATUS_PENDING or ""))
        panel.status:SetTextColor(s.enabled and 0.35 or 0.72, s.enabled and 0.9 or 0.72, s.enabled and 0.42 or 0.72)
        panel.compatibility:SetText("Blizzard tracker: " .. (s.trackerFound and "found" or "not found") ..
            "   RestedXP: " .. (s.restedXPLoaded and (s.restedXPVisible and "active" or "loaded, hidden") or "not loaded") ..
            "   Questie: " .. (s.questieLoaded and "detected" or "not detected"))
        panel.warning:SetText(s.degraded and ("Compatibility warning: " .. tostring(s.error)) or
            "The add-on changes only Blizzard's tracker visibility. RestedXP and Questie frames are left untouched.")
    end
    if addon.UpdateMinimapVisual then addon.UpdateMinimapVisual() end
end

function addon.SyncPanel()
    local panel = addon.settingsPanel
    if not panel or not addon.db then return end
    addon.syncingPanel = true
    panel.enabled:SetChecked(addon.db.enabled)
    panel.modeRXP:SetChecked(addon.db.mode == addon.MODE_RXP)
    panel.modeAlways:SetChecked(addon.db.mode == addon.MODE_ALWAYS)
    panel.minimap:SetChecked(addon.db.minimap.shown)
    addon.syncingPanel = false
    addon.RefreshUI()
end

local function buildSettings()
    if addon.settingsPanel then return end
    local panel = CreateFrame("Frame", "RXPObjectiveHiderForeverSettingsPanel")
    addon.settingsPanel = panel
    panel.name = L.ADDON_NAME

    local title = makeText(panel, "GameFontNormalLarge", L.ADDON_NAME, 16, -16)
    title:SetTextColor(0.88, 0.70, 0.30)
    local summary = makeText(panel, "GameFontHighlight", L.SUMMARY, 16, -45, 610)
    summary:SetTextColor(0.55, 0.82, 0.48)
    local independence = makeText(panel, "GameFontHighlightSmall", L.INDEPENDENCE, 16, -70, 610)
    independence:SetTextColor(0.75, 0.75, 0.75)

    panel.enabled = makeCheck(panel, L.ENABLED, 12, -110, function(value)
        if not addon.syncingPanel then addon.SetEnabled(value, "settings") end
    end)

    makeText(panel, "GameFontNormal", "When should it hide?", 20, -152)
    panel.modeRXP = makeCheck(panel, L.MODE_RXP, 28, -177, function(value)
        if value and not addon.syncingPanel then addon.SetMode(addon.MODE_RXP) else addon.SyncPanel() end
    end)
    panel.modeAlways = makeCheck(panel, L.MODE_ALWAYS, 28, -207, function(value)
        if value and not addon.syncingPanel then addon.SetMode(addon.MODE_ALWAYS) else addon.SyncPanel() end
    end)
    panel.minimap = makeCheck(panel, L.SHOW_MINIMAP, 12, -252, function(value)
        if addon.syncingPanel then return end
        addon.db.minimap.shown = value
        if addon.ApplyMinimapVisibility then addon.ApplyMinimapVisibility() end
    end)

    panel.status = makeText(panel, "GameFontNormal", "", 20, -300, 610)
    panel.compatibility = makeText(panel, "GameFontHighlightSmall", "", 20, -327, 610)
    panel.warning = makeText(panel, "GameFontHighlightSmall", "", 20, -352, 610)
    panel.warning:SetTextColor(0.85, 0.72, 0.40)

    local restore = makeButton(panel, L.RESTORE, 170, function() addon.SetEnabled(false, "restore button") end)
    restore:SetPoint("TOPLEFT", 20, -405)
    local reset = makeButton(panel, L.RESET, 125, addon.ResetSettings)
    reset:SetPoint("LEFT", restore, "RIGHT", 10, 0)
    local recover = makeButton(panel, L.RECOVER, 125, addon.RecoverBackup)
    recover:SetPoint("LEFT", reset, "RIGHT", 10, 0)

    makeText(panel, "GameFontHighlightSmall",
        "Commands: /rxpoh on | off | toggle | mode rxp | mode always | status | reset | recover", 20, -450, 610)
    makeText(panel, "GameFontHighlightSmall",
        "Keybinding is unavailable on Forever; use the minimap button or /rxpoh.", 20, -475, 610)

    panel:SetScript("OnShow", addon.SyncPanel)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, L.ADDON_NAME)
        Settings.RegisterAddOnCategory(category)
        addon.settingsCategory = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

function addon.OpenSettings()
    buildSettings()
    if addon.settingsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(addon.settingsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(addon.settingsPanel)
        InterfaceOptionsFrame_OpenToCategory(addon.settingsPanel)
    end
end

local function showHelp()
    addon.Print("/rxpoh toggles objective hiding. Use on, off, mode rxp, mode always, status, reset, recover, or settings.")
end

SLASH_RXPOBJECTIVEHIDERFOREVER1 = "/rxpoh"
SLASH_RXPOBJECTIVEHIDERFOREVER2 = "/rxpobjectivehider"
SlashCmdList.RXPOBJECTIVEHIDERFOREVER = function(input)
    local command, rest = tostring(input or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    if command == "" or command == "toggle" then addon.ToggleEnabled("slash command")
    elseif command == "on" or command == "hide" then addon.SetEnabled(true, "slash command"); addon.Print(L.STATUS_ON)
    elseif command == "off" or command == "show" then addon.SetEnabled(false, "slash command"); addon.Print(L.STATUS_OFF)
    elseif command == "mode" and (rest == "always" or rest == "rxp" or rest == "restedxp") then
        addon.SetMode(rest == "always" and addon.MODE_ALWAYS or addon.MODE_RXP)
        addon.Print("Mode set to " .. addon.db.mode .. ".")
    elseif command == "status" then addon.PrintStatus()
    elseif command == "reset" then addon.ResetSettings()
    elseif command == "recover" then addon.RecoverBackup()
    elseif command == "settings" or command == "options" then addon.OpenSettings()
    else showHelp() end
end

local initializer = CreateFrame("Frame")
initializer:RegisterEvent("PLAYER_LOGIN")
initializer:SetScript("OnEvent", function()
    buildSettings()
    addon.SyncPanel()
end)
