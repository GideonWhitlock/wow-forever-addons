local addonName, addon = ...
local L = addon.L

local GOLD = { 0.84, 0.68, 0.32 }
local GREEN = { 0.45, 0.72, 0.42 }
local CREAM = { 0.95, 0.90, 0.76 }
local DARK = { 0.055, 0.065, 0.05, 0.96 }
local ICON_PATH = "Interface\\AddOns\\GentleReminderForever\\Media\\Icon.tga"

local function setBackdrop(frame, alpha)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(DARK[1], DARK[2], DARK[3], alpha or DARK[4])
    frame:SetBackdropBorderColor(GOLD[1], GOLD[2], GOLD[3], 0.95)
end

local function makeText(parent, template, text, point, relative, relativePoint, x, y)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlight")
    label:SetPoint(point, relative or parent, relativePoint or point, x or 0, y or 0)
    label:SetText(text or "")
    return label
end

local function makeButton(parent, text, width, onClick)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, 24)
    button:SetText(text)
    button:SetScript("OnClick", onClick)
    return button
end

local function applyBasisButtonStyle(button, interaction)
    if not button:IsEnabled() then
        button:SetBackdropColor(0.10, 0.10, 0.10, 0.95)
        button:SetBackdropBorderColor(0.38, 0.38, 0.38, 1)
        button.label:SetTextColor(0.55, 0.55, 0.55)
        return
    end
    if button.active then
        if interaction == "pressed" then
            button:SetBackdropColor(0.03, 0.20, 0.07, 1)
        elseif interaction == "hover" then
            button:SetBackdropColor(0.10, 0.40, 0.15, 1)
        else
            button:SetBackdropColor(0.06, 0.31, 0.11, 1)
        end
        button:SetBackdropBorderColor(0.35, 0.95, 0.42, 1)
        button.label:SetTextColor(0.82, 1, 0.82)
    else
        if interaction == "pressed" then
            button:SetBackdropColor(0.22, 0.025, 0.02, 1)
        elseif interaction == "hover" then
            button:SetBackdropColor(0.44, 0.07, 0.045, 1)
        else
            button:SetBackdropColor(0.33, 0.045, 0.03, 1)
        end
        button:SetBackdropBorderColor(0.95, 0.28, 0.18, 1)
        button.label:SetTextColor(1, 0.82, 0.72)
    end
end

local function setBasisActive(button, active)
    button.active = active == true
    applyBasisButtonStyle(button)
end

local function makeBasisButton(parent, text, width, onClick)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width or 78, 25)
    button:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 } })
    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.label:SetPoint("CENTER", 0, 0)
    button.label:SetText(text)
    button:SetScript("OnClick", onClick)
    button:SetScript("OnEnter", function(self) applyBasisButtonStyle(self, "hover") end)
    button:SetScript("OnLeave", function(self) applyBasisButtonStyle(self) end)
    button:SetScript("OnMouseDown", function(self) applyBasisButtonStyle(self, "pressed") end)
    button:SetScript("OnMouseUp", function(self) applyBasisButtonStyle(self, self:IsMouseOver() and "hover" or nil) end)
    button:SetScript("OnEnable", function(self) applyBasisButtonStyle(self) end)
    button:SetScript("OnDisable", function(self) applyBasisButtonStyle(self) end)
    applyBasisButtonStyle(button)
    return button
end

local function makeEdit(parent, width, height, multiline)
    local box = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    box:SetSize(width, height)
    box:SetAutoFocus(false)
    box:SetFontObject("GameFontHighlight")
    box:SetTextInsets(8, 8, 6, 6)
    box:SetMaxLetters(addon.MAX_TEXT)
    box:SetMultiLine(multiline == true)
    box:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    box:SetBackdropColor(0.02, 0.025, 0.02, 0.96)
    box:SetBackdropBorderColor(0.45, 0.52, 0.34, 1)
    box:SetScript("OnEscapePressed", box.ClearFocus)
    box:SetScript("OnEnterPressed", function(self) if not multiline then self:ClearFocus() end end)
    return box
end

local function makeCheck(parent, labelText, x, y, onClick)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", x, y)
    check.Text:SetText(labelText)
    check:SetScript("OnClick", function(self) onClick(self:GetChecked() and true or false) end)
    return check
end

local function savePanelFields()
    local panel = addon.panel
    if not panel or addon.syncing then return true end
    local profile = addon.db[panel.profileKey]
    local interval = tonumber(panel.interval:GetText())
    if not interval or interval < addon.MIN_INTERVAL or interval > addon.MAX_INTERVAL then
        addon.Print("The interval must be from 5 to 360 minutes.")
        return false
    end
    local bedtime = addon.ParseClock(panel.bedtime:GetText())
    if bedtime == nil then
        addon.Print("Bedtime must use 24-hour HH:MM, or be blank.")
        return false
    end
    local snoozes = addon.ParseSnoozes(panel.snoozes:GetText())
    if not snoozes then
        addon.Print("Choose one to five comma-separated snooze times from 1 to 120 minutes.")
        return false
    end
    local previousInterval = profile.intervalMinutes
    profile.intervalMinutes = math.floor(interval + 0.5)
    profile.message = addon.SanitizeText(panel.message:GetText(), L.DEFAULT_MESSAGE)
    profile.bedtime = bedtime
    profile.bedtimeMessage = addon.SanitizeText(panel.bedtimeMessage:GetText(), L.DEFAULT_BEDTIME_MESSAGE)
    addon.db.snoozeChoices = snoozes
    local _, activeKey = addon.GetProfile()
    if panel.profileKey == activeKey and previousInterval ~= profile.intervalMinutes then addon.NextRecurring() end
    return true
end

function addon.SyncPanel()
    local panel = addon.panel
    if not panel then return end
    addon.syncing = true
    local profile = addon.db[panel.profileKey]
    panel.weekday:SetEnabled(panel.profileKey ~= "weekday")
    panel.weekend:SetEnabled(panel.profileKey ~= "weekend")
    panel.profileEnabled:SetChecked(profile.enabled)
    panel.interval:SetText(tostring(profile.intervalMinutes))
    panel.message:SetText(profile.message)
    panel.bedtime:SetText(profile.bedtime)
    panel.bedtimeMessage:SetText(profile.bedtimeMessage)
    panel.localBasis:SetEnabled(true)
    panel.serverBasis:SetEnabled(true)
    setBasisActive(panel.localBasis, addon.db.bedtimeBasis == "local")
    setBasisActive(panel.serverBasis, addon.db.bedtimeBasis == "server")
    panel.visual:SetChecked(addon.db.delivery.visual)
    panel.sound:SetChecked(addon.db.delivery.sound)
    panel.speech:SetChecked(addon.db.delivery.speech)
    panel.snoozes:SetText(table.concat(addon.db.snoozeChoices, ", "))
    panel.minimapCheck:SetChecked(addon.db.minimap.shown)
    addon.syncing = false
    addon.RefreshUI()
end

function addon.SelectProfile(key)
    if key ~= "weekday" and key ~= "weekend" then return end
    if not savePanelFields() then return end
    addon.panel.profileKey = key
    addon.SyncPanel()
end

function addon.SelectBedtimeBasis(basis)
    if basis ~= "local" and basis ~= "server" then return end
    if not savePanelFields() then return end
    addon.SetBedtimeBasis(basis)
    addon.SyncPanel()
end

local function refreshOneOffRows()
    local panel = addon.panel
    if not panel or not panel:IsShown() then return end
    for index, row in ipairs(panel.oneOffRows) do
        local item = addon.db.oneOffs[index]
        if item then
            local remaining = math.max(0, item.dueAt - time())
            row.itemID = item.id
            row.text:SetText(addon.FormatDuration(remaining) .. " — " .. item.text)
            row:Show()
        else
            row.itemID = nil
            row:Hide()
        end
    end
    panel.oneOffCount:SetText(#addon.db.oneOffs == 0 and L.NO_REMINDER or (#addon.db.oneOffs .. " scheduled"))
end

function addon.RefreshUI()
    local panel = addon.panel
    if panel and panel:IsShown() then
        panel.sessionValue:SetText(addon.FormatDuration(addon.GetSessionSeconds()))
        panel.todayValue:SetText(addon.FormatDuration(addon.GetTodaySeconds()))
        local seconds = addon.GetNextReminderSeconds()
        panel.nextValue:SetText(seconds and addon.FormatDuration(seconds) or L.NO_REMINDER)
        panel.clockHint:SetText(addon.GetClockSummary() .. " • Bedtime uses " ..
            (addon.db.bedtimeBasis == "server" and L.CLOCK_SERVER or L.CLOCK_LOCAL))
        panel.status:SetText(addon.deferred and L.STATUS_DEFERRED or (addon.db.enabled and L.STATUS_READY or L.STATUS_DISABLED))
        refreshOneOffRows()
    end
    if addon.minimapButton and GameTooltip:IsOwned(addon.minimapButton) then addon.ShowMinimapTooltip() end
end

local function buildPanel()
    local panel = CreateFrame("Frame", "GentleReminderForeverPanel", UIParent, "BackdropTemplate")
    addon.panel = panel
    panel:SetSize(560, 690)
    panel:SetPoint(addon.db.panel.point, UIParent, addon.db.panel.point, addon.db.panel.x, addon.db.panel.y)
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self) if not InCombatLockdown() then self:StartMoving() end end)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint(1)
        addon.db.panel.point, addon.db.panel.x, addon.db.panel.y = point, x, y
    end)
    panel:SetScript("OnHide", savePanelFields)
    setBackdrop(panel)

    local brandIcon = panel:CreateTexture(nil, "ARTWORK")
    brandIcon:SetTexture(ICON_PATH)
    brandIcon:SetSize(34, 34)
    brandIcon:SetPoint("TOPLEFT", 20, -15)
    makeText(panel, "GameFontNormalLarge", L.ADDON_NAME, "TOPLEFT", panel, "TOPLEFT", 62, -22):SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    local subtitle = makeText(panel, "GameFontHighlightSmall", "Private reminders that leave the choice with you.", "TOPLEFT", panel, "TOPLEFT", 25, -47)
    subtitle:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    panel.sessionValue = makeText(panel, "GameFontHighlight", "0s", "TOPLEFT", panel, "TOPLEFT", 110, -79)
    makeText(panel, "GameFontNormal", L.LABEL_SESSION .. ":", "RIGHT", panel.sessionValue, "LEFT", -8, 0)
    panel.todayValue = makeText(panel, "GameFontHighlight", "0s", "LEFT", panel.sessionValue, "RIGHT", 100, 0)
    makeText(panel, "GameFontNormal", L.LABEL_TODAY .. ":", "RIGHT", panel.todayValue, "LEFT", -8, 0)
    panel.nextValue = makeText(panel, "GameFontHighlight", "—", "LEFT", panel.todayValue, "RIGHT", 125, 0)
    makeText(panel, "GameFontNormal", L.LABEL_NEXT .. ":", "RIGHT", panel.nextValue, "LEFT", -8, 0)

    panel.weekday = makeButton(panel, L.PROFILE_WEEKDAY, 120, function() addon.SelectProfile("weekday") end)
    panel.weekday:SetPoint("TOPLEFT", 24, -112)
    panel.weekend = makeButton(panel, L.PROFILE_WEEKEND, 120, function() addon.SelectProfile("weekend") end)
    panel.weekend:SetPoint("LEFT", panel.weekday, "RIGHT", 8, 0)
    panel.profileKey = select(2, addon.GetProfile())

    panel.profileEnabled = makeCheck(panel, L.LABEL_ENABLED, 24, -150, function(value)
        addon.db[panel.profileKey].enabled = value
        if value then addon.NextRecurring() end
    end)

    makeText(panel, "GameFontNormal", L.LABEL_INTERVAL, "TOPLEFT", panel, "TOPLEFT", 30, -188)
    panel.interval = makeEdit(panel, 80, 30, false)
    panel.interval:SetPoint("TOPLEFT", 302, -178)
    panel.interval:SetMaxLetters(3)
    panel.interval:SetNumeric(true)
    panel.interval:SetScript("OnEditFocusLost", savePanelFields)

    makeText(panel, "GameFontNormal", L.LABEL_MESSAGE, "TOPLEFT", panel, "TOPLEFT", 30, -226)
    panel.message = makeEdit(panel, 500, 58, true)
    panel.message:SetPoint("TOPLEFT", 30, -247)
    panel.message:SetScript("OnEditFocusLost", savePanelFields)

    makeText(panel, "GameFontNormal", L.LABEL_BEDTIME, "TOPLEFT", panel, "TOPLEFT", 30, -320)
    panel.bedtime = makeEdit(panel, 90, 30, false)
    panel.bedtime:SetPoint("TOPLEFT", 278, -310)
    panel.bedtime:SetMaxLetters(5)
    panel.bedtime:SetScript("OnEditFocusLost", savePanelFields)

    local function basisTooltip(button, basis)
        button:HookScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(basis == "local" and L.CLOCK_LOCAL_HELP_TITLE or L.CLOCK_SERVER_HELP_TITLE,
                GOLD[1], GOLD[2], GOLD[3])
            GameTooltip:AddLine(basis == "local" and L.CLOCK_LOCAL_HELP or L.CLOCK_SERVER_HELP, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        button:HookScript("OnLeave", function() GameTooltip:Hide() end)
    end
    panel.localBasis = makeBasisButton(panel, L.CLOCK_LOCAL, 78, function() addon.SelectBedtimeBasis("local") end)
    panel.localBasis:SetPoint("TOPLEFT", 376, -312)
    basisTooltip(panel.localBasis, "local")
    panel.serverBasis = makeBasisButton(panel, L.CLOCK_SERVER, 78, function() addon.SelectBedtimeBasis("server") end)
    panel.serverBasis:SetPoint("LEFT", panel.localBasis, "RIGHT", 4, 0)
    basisTooltip(panel.serverBasis, "server")
    panel.clockHint = makeText(panel, "GameFontHighlightSmall", "", "TOPLEFT", panel, "TOPLEFT", 30, -348)
    panel.clockHint:SetTextColor(GREEN[1], GREEN[2], GREEN[3])

    makeText(panel, "GameFontNormal", "Bedtime message", "TOPLEFT", panel, "TOPLEFT", 30, -378)
    panel.bedtimeMessage = makeEdit(panel, 500, 48, true)
    panel.bedtimeMessage:SetPoint("TOPLEFT", 30, -399)
    panel.bedtimeMessage:SetScript("OnEditFocusLost", savePanelFields)

    panel.visual = makeCheck(panel, L.LABEL_VISUAL, 24, -464, function(value) addon.db.delivery.visual = value end)
    panel.sound = makeCheck(panel, L.LABEL_SOUND, 230, -464, function(value) addon.db.delivery.sound = value end)
    panel.speech = makeCheck(panel, L.LABEL_SPEECH, 24, -496, function(value) addon.db.delivery.speech = value end)

    makeText(panel, "GameFontNormal", L.LABEL_SNOOZES, "TOPLEFT", panel, "TOPLEFT", 30, -538)
    panel.snoozes = makeEdit(panel, 150, 30, false)
    panel.snoozes:SetPoint("TOPLEFT", 340, -528)
    panel.snoozes:SetMaxLetters(20)
    panel.snoozes:SetScript("OnEditFocusLost", savePanelFields)

    panel.minimapCheck = makeCheck(panel, L.LABEL_MINIMAP, 24, -575, function(value)
        addon.db.minimap.shown = value
        addon.ApplyMinimapVisibility()
    end)

    local add = makeButton(panel, L.BUTTON_ADD, 120, function() addon.ShowAddDialog() end)
    add:SetPoint("TOPRIGHT", -24, -572)

    makeText(panel, "GameFontNormal", L.LABEL_ONE_OFFS, "TOPLEFT", panel, "TOPLEFT", 30, -614)
    panel.oneOffCount = makeText(panel, "GameFontHighlightSmall", "", "TOPRIGHT", panel, "TOPRIGHT", -30, -615)
    panel.oneOffRows = {}
    for index = 1, 2 do
        local row = CreateFrame("Frame", nil, panel)
        row:SetSize(500, 20)
        row:SetPoint("TOPLEFT", 30, -631 - ((index - 1) * 22))
        row.text = makeText(row, "GameFontHighlightSmall", "", "LEFT", row, "LEFT", 0, 0)
        row.text:SetWidth(445)
        row.text:SetJustifyH("LEFT")
        local cancel = makeButton(row, "×", 28, function()
            if row.itemID then addon.RemoveOneOff(row.itemID); addon.RefreshUI() end
        end)
        cancel:SetPoint("RIGHT")
        row.cancel = cancel
        panel.oneOffRows[index] = row
    end

    panel.status = makeText(panel, "GameFontHighlightSmall", "", "BOTTOMLEFT", panel, "BOTTOMLEFT", 25, 15)
    panel.status:SetTextColor(GREEN[1], GREEN[2], GREEN[3])
    local preview = makeButton(panel, L.BUTTON_TEST, 80, function()
        if savePanelFields() then addon.QueueReminder("preview", addon.db[panel.profileKey].message) end
    end)
    preview:SetPoint("BOTTOMRIGHT", -24, 11)

    addon.SyncPanel()
    panel:Hide()
end

function addon.TogglePanel()
    if InCombatLockdown() then addon.Print("Settings can be opened after combat."); return end
    if not addon.panel then buildPanel() end
    if addon.panel:IsShown() then addon.panel:Hide() else addon.SyncPanel(); addon.panel:Show() end
end

local function buildReminder()
    local card = CreateFrame("Frame", "GentleReminderForeverCard", UIParent, "BackdropTemplate")
    addon.reminderCard = card
    card:SetSize(460, 210)
    card:SetPoint("TOP", UIParent, "TOP", 0, -145)
    card:SetFrameStrata("DIALOG")
    card:SetClampedToScreen(true)
    setBackdrop(card, 0.94)
    local emblem = card:CreateTexture(nil, "ARTWORK")
    emblem:SetTexture(ICON_PATH)
    emblem:SetSize(44, 44)
    emblem:SetPoint("TOPLEFT", 18, -17)
    card.title = makeText(card, "GameFontNormalLarge", "", "TOPLEFT", card, "TOPLEFT", 68, -23)
    card.title:SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    card.message = makeText(card, "GameFontHighlight", "", "TOPLEFT", card, "TOPLEFT", 24, -72)
    card.message:SetWidth(412)
    card.message:SetJustifyH("LEFT")
    card.message:SetJustifyV("TOP")
    card.message:SetWordWrap(true)
    card.done = makeButton(card, L.BUTTON_DONE, 120, addon.DismissCurrent)
    card.done:SetPoint("BOTTOMLEFT", 22, 20)
    card.snoozeButtons = {}
    card:Hide()
end

function addon.ShowReminder(reminder)
    if not addon.reminderCard then buildReminder() end
    local card = addon.reminderCard
    if reminder.kind == "bedtime" then card.title:SetText(L.TITLE_BEDTIME)
    elseif reminder.kind == "oneoff" then card.title:SetText(L.TITLE_ONE_OFF)
    else card.title:SetText(L.TITLE_BREAK) end
    card.message:SetText(reminder.text)
    for _, button in ipairs(card.snoozeButtons) do button:Hide() end
    for index, minutes in ipairs(addon.db.snoozeChoices) do
        local button = card.snoozeButtons[index]
        if not button then
            button = makeButton(card, "", 64, function(self) addon.SnoozeCurrent(self.minutes) end)
            card.snoozeButtons[index] = button
        end
        button.minutes = minutes
        button:SetText(minutes .. "m")
        button:ClearAllPoints()
        button:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -22 - ((index - 1) * 69), 20)
        button:Show()
    end
    card:Show()
end

function addon.HideReminder()
    if addon.reminderCard then addon.reminderCard:Hide() end
end

local function buildAddDialog()
    local dialog = CreateFrame("Frame", "GentleReminderForeverAddDialog", UIParent, "BackdropTemplate")
    addon.addDialog = dialog
    dialog:SetSize(430, 250)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("FULLSCREEN_DIALOG")
    dialog:SetClampedToScreen(true)
    setBackdrop(dialog)
    makeText(dialog, "GameFontNormalLarge", "Remind me later", "TOPLEFT", dialog, "TOPLEFT", 22, -22):SetTextColor(GOLD[1], GOLD[2], GOLD[3])
    makeText(dialog, "GameFontNormal", "In", "TOPLEFT", dialog, "TOPLEFT", 24, -67)
    dialog.duration = makeEdit(dialog, 100, 30, false)
    dialog.duration:SetPoint("TOPLEFT", 54, -57)
    dialog.duration:SetMaxLetters(8)
    makeText(dialog, "GameFontHighlightSmall", "Examples: 20m, 1h30m, 90", "LEFT", dialog.duration, "RIGHT", 12, 0)
    makeText(dialog, "GameFontNormal", "Reminder", "TOPLEFT", dialog, "TOPLEFT", 24, -106)
    dialog.message = makeEdit(dialog, 382, 58, true)
    dialog.message:SetPoint("TOPLEFT", 24, -127)
    local cancel = makeButton(dialog, L.BUTTON_CANCEL, 90, function() dialog:Hide() end)
    cancel:SetPoint("BOTTOMLEFT", 24, 20)
    local save = makeButton(dialog, L.BUTTON_SAVE, 90, function()
        local seconds = addon.ParseDuration(dialog.duration:GetText())
        if not seconds then addon.Print("Use a duration such as 20m, 1h30m, or 90 minutes."); return end
        local ok, result = addon.AddOneOff(seconds, dialog.message:GetText())
        if not ok then addon.Print(result); return end
        addon.Print("I’ll remind you in " .. addon.FormatDuration(seconds) .. ".")
        dialog:Hide()
    end)
    save:SetPoint("BOTTOMRIGHT", -24, 20)
    dialog:Hide()
end

function addon.ShowAddDialog()
    if InCombatLockdown() then addon.Print("You can add a reminder after combat."); return end
    if not addon.addDialog then buildAddDialog() end
    addon.addDialog.duration:SetText("20m")
    addon.addDialog.message:SetText("")
    addon.addDialog:Show()
    addon.addDialog.message:SetFocus()
end

function addon.ShowMinimapTooltip()
    local button = addon.minimapButton
    GameTooltip:SetOwner(button, "ANCHOR_LEFT")
    GameTooltip:SetText(L.ADDON_NAME, GOLD[1], GOLD[2], GOLD[3])
    GameTooltip:AddLine(L.MINIMAP_LEFT, 1, 1, 1)
    GameTooltip:AddLine(L.MINIMAP_RIGHT, 1, 1, 1)
    GameTooltip:AddLine(L.MINIMAP_DRAG, 0.7, 0.8, 0.7)
    GameTooltip:AddLine(L.LABEL_SESSION .. ": " .. addon.FormatDuration(addon.GetSessionSeconds()), 0.85, 0.85, 0.85)
    GameTooltip:AddLine(L.LABEL_TODAY .. ": " .. addon.FormatDuration(addon.GetTodaySeconds()), 0.85, 0.85, 0.85)
    GameTooltip:AddLine(addon.GetClockSummary(), 0.72, 0.9, 0.72)
    GameTooltip:AddLine("Bedtime uses " .. (addon.db.bedtimeBasis == "server" and L.CLOCK_SERVER or L.CLOCK_LOCAL), 0.72, 0.9, 0.72)
    local seconds = addon.GetNextReminderSeconds()
    GameTooltip:AddLine(L.LABEL_NEXT .. ": " .. (seconds and addon.FormatDuration(seconds) or L.NO_REMINDER), 0.85, 0.85, 0.85)
    GameTooltip:Show()
end

local function placeMinimapButton()
    local button = addon.minimapButton
    if not button or not Minimap then return end
    local angle = math.rad(addon.db.minimap.angle or 220)
    local radius = 80
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

function addon.ApplyMinimapVisibility()
    if not addon.minimapButton then return end
    addon.minimapButton:SetShown(addon.db.minimap.shown)
end

local function buildMinimapButton()
    if not Minimap then return end
    local button = CreateFrame("Button", "GentleReminderForeverMinimapButton", Minimap)
    addon.minimapButton = button
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(ICON_PATH)
    icon:SetPoint("CENTER")
    icon:SetSize(30, 30)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
    button:SetScript("OnEnter", addon.ShowMinimapTooltip)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnClick", function(_, mouseButton)
        if button.dragged then button.dragged = nil; return end
        if mouseButton == "RightButton" then addon.ShowAddDialog() else addon.TogglePanel() end
    end)
    button:SetScript("OnDragStart", function(self)
        if InCombatLockdown() then return end
        self.dragging = true
        GameTooltip:Hide()
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            local cx, cy = GetCursorPosition()
            if mx and my and scale and scale > 0 then
                addon.db.minimap.angle = math.deg(math.atan2(cy / scale - my, cx / scale - mx))
                placeMinimapButton()
            end
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        if not self.dragging then return end
        self.dragging = nil
        self.dragged = true
        self:SetScript("OnUpdate", nil)
    end)
    placeMinimapButton()
    addon.ApplyMinimapVisibility()
end

function addon.ApplyAllSettings()
    addon.ApplyMinimapVisibility()
    if addon.panel then addon.SyncPanel() end
end

function addon.BuildUI()
    buildPanel()
    buildReminder()
    buildMinimapButton()
end

