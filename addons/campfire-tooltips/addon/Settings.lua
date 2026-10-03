-- SPDX-License-Identifier: GPL-3.0-or-later
local _, ns = ...
local panel, category, reportBox

local function label(parent, text, x, y, width, font)
    local f = parent:CreateFontString(nil, "ARTWORK", font or "GameFontHighlight")
    f:SetPoint("TOPLEFT", x, y)
    f:SetWidth(width)
    f:SetJustifyH("LEFT")
    f:SetText(text)
    return f
end

local function refresh()
    if reportBox then reportBox:SetText(ns.Report()); reportBox:ClearFocus() end
end

function ns.CreateSettings()
    if panel or not ns.db then return end
    panel = CreateFrame("Frame")
    panel.name = "Campfire Tooltips"
    label(panel, "Campfire Tooltips", 20, -20, 560, "GameFontNormalLarge")
    label(panel, "Hover over a supported object at a campsite to read its benefit in the normal tooltip.", 20, -55, 560)
    local function check(text, key, y)
        local button = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
        button:SetPoint("TOPLEFT", 20, y)
        label(panel, text, 56, y - 7, 510)
        button:SetScript("OnShow", function(self) self:SetChecked(ns.db[key]) end)
        button:SetScript("OnClick", function(self) ns.db[key] = self:GetChecked() and true or false; refresh() end)
        return button
    end
    check("Explain camping object benefits", "enabled", -92)
    check("Show the corresponding active buff and time remaining when readable", "showStatus", -128)
    label(panel, "Changes apply on the next hover. Active status describes your buff; it does not identify which object gave it to you.", 20, -177, 560, "GameFontHighlightSmall")
    label(panel, "Optional checks", 20, -225, 560, "GameFontNormal")
    label(panel, "Record hovers, then refresh the report. Only readable object details are kept locally. No data is uploaded.", 20, -250, 560, "GameFontHighlightSmall")
    local function button(text, x, callback)
        local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        b:SetSize(172, 26)
        b:SetPoint("TOPLEFT", x, -290)
        b:SetText(text)
        b:SetScript("OnClick", callback)
        return b
    end
    button("Start hover checks", 20, function(self)
        ns.recording = not ns.recording
        self:SetText(ns.recording and "Stop hover checks" or "Start hover checks")
        refresh()
    end)
    button("Refresh report", 202, refresh)
    button("Reload interface", 384, function()
        if InCombatLockdown and not InCombatLockdown() then ReloadUI() end
    end)
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 24, -335)
    scroll:SetPoint("BOTTOMRIGHT", -46, 24)
    reportBox = CreateFrame("EditBox", nil, scroll)
    reportBox:SetMultiLine(true)
    reportBox:SetAutoFocus(false)
    reportBox:SetFontObject("GameFontHighlightSmall")
    reportBox:SetWidth(535)
    reportBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scroll:SetScrollChild(reportBox)
    panel:SetScript("OnShow", refresh)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
    end
end

SLASH_CAMPFIRETOOLTIPS1 = "/camptooltips"
SlashCmdList.CAMPFIRETOOLTIPS = function()
    if category and Settings and Settings.OpenToCategory then Settings.OpenToCategory(category:GetID()) end
end
