local _, EGF = ...

local function setBackdrop(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
end

local function label(parent, text, x, y, template)
    local font = parent:CreateFontString(nil, "ARTWORK", template or "GameFontNormal")
    font:SetPoint("TOPLEFT", x, y)
    font:SetText(text)
    font:SetJustifyH("LEFT")
    return font
end

local function button(parent, text, x, y, width, onClick)
    local control = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    control:SetPoint("TOPLEFT", x, y)
    control:SetSize(width, 24)
    control:SetText(text)
    control:SetScript("OnClick", onClick)
    return control
end

local function decimals(step)
    local text = tostring(step or 1)
    local point = text:find("%.")
    return point and (#text - point) or 0
end

local PROFILE_IDS = {"potato", "low", "medium", "high", "ufo"}
local PROFILE_SHORT = {potato = "P", low = "L", medium = "M", high = "H", ufo = "UFO"}
local PROFILE_COLORS = {
    potato = {0.78, 0.54, 0.27}, low = {0.72, 0.76, 0.8}, medium = {1, 0.82, 0.28},
    high = {0.2, 0.86, 1}, ufo = {0.76, 0.42, 1},
}

local function colourPresetButton(control, id)
    local colour = PROFILE_COLORS[id]
    local font = control.GetFontString and control:GetFontString()
    if colour and font then font:SetTextColor(colour[1], colour[2], colour[3]) end
end

local function addProfileChips(row, definition, y)
    local x = 390
    for _, id in ipairs(PROFILE_IDS) do
        local preset = EGF.presetsByID[id]
        local value = preset and preset.values[definition.id]
        if value ~= nil then
            local width = id == "ufo" and 50 or 36
            local chip = button(row, PROFILE_SHORT[id], x, y, width, function()
                local ok, message = EGF.SetValue(definition, value)
                EGF.options.message:SetText(ok and (preset.label .. " value applied to " .. definition.label .. ".") or message)
                EGF.RefreshOptions()
            end)
            colourPresetButton(chip, id)
            chip:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText(preset.label .. " — " .. definition.label)
                GameTooltip:AddLine(tostring(value), 1, 1, 1)
                GameTooltip:AddLine("Apply only this setting's " .. preset.label .. " value.", 0.72, 0.78, 0.86, true)
                GameTooltip:Show()
            end)
            chip:SetScript("OnLeave", function() GameTooltip:Hide() end)
            x = x + width + 8
        end
    end
end

function EGF.RefreshOptions()
    local panel = EGF.options
    if not panel then return end
    for _, row in ipairs(panel.rows or {}) do row:Hide() end
    panel.rows = {}

    local y = -8
    if #EGF.settings == 0 then
        local empty = label(panel.content, "The control framework is ready. Verified graphics controls will appear here as the examples are identified and tested.", 10, y, "GameFontHighlight")
        empty:SetWidth(610)
        empty:SetJustifyH("CENTER")
        panel.rows[#panel.rows + 1] = empty
        y = y - 60
    else
        local lastCategory
        for _, definition in ipairs(EGF.settings) do
            if definition.category ~= lastCategory then
                local heading = label(panel.content, definition.category:upper(), 8, y, "GameFontNormalLarge")
                heading:SetTextColor(1, 0.78, 0.28)
                panel.rows[#panel.rows + 1] = heading
                y = y - 30
                lastCategory = definition.category
            end

            local row = CreateFrame("Frame", nil, panel.content)
            row:SetPoint("TOPLEFT", 8, y)
            row:SetSize(615, definition.description ~= "" and 104 or 78)
            panel.rows[#panel.rows + 1] = row
            local title = label(row, definition.label, 0, 0, "GameFontNormal")
            title:SetTextColor(1, 1, 1)
            local description = label(row, definition.description, 0, -22, "GameFontHighlightSmall")
            description:SetWidth(365)
            description:SetHeight(46)
            description:SetTextColor(0.7, 0.76, 0.84)

            local value = EGF.GetValue(definition)
            if definition.kind == "toggle" then
                local check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
                check:SetPoint("TOPLEFT", 390, 4)
                check:SetSize(28, 28)
                check:SetChecked(value and true or false)
                local state = label(row, value == nil and "Unavailable" or (value and "On" or "Off"), 425, -3, "GameFontHighlight")
                check:SetEnabled(value ~= nil)
                check:SetScript("OnClick", function(self)
                    local ok, message = EGF.SetValue(definition, self:GetChecked() and true or false)
                    panel.message:SetText(message)
                    if not ok then self:SetChecked(not self:GetChecked()) end
                    EGF.RefreshOptions()
                end)
                row.state = state
            else
                local slider = CreateFrame("Slider", nil, row, "OptionsSliderTemplate")
                slider:SetPoint("TOPLEFT", 390, -7)
                slider:SetSize(175, 16)
                slider:SetMinMaxValues(definition.min, definition.max)
                slider:SetValueStep(definition.step)
                slider:SetObeyStepOnDrag(true)
                if value ~= nil then slider:SetValue(value) else slider:SetValue(definition.min); slider:Disable() end
                local count = decimals(definition.step)
                local valueText = label(row, value == nil and "Unavailable" or string.format("%." .. count .. "f", value), 574, -3, "GameFontHighlight")
                valueText:SetWidth(42)
                slider:SetScript("OnValueChanged", function(_, newValue)
                    valueText:SetText(string.format("%." .. count .. "f", newValue))
                    local ok, message = EGF.SetValue(definition, newValue)
                    panel.message:SetText(message)
                    if not ok then EGF.RefreshOptions() end
                end)
            end

            addProfileChips(row, definition, -57)
            local reset = button(row, "Restore", 525, -83, 82, function()
                local _, message = EGF.RestoreSetting(definition)
                panel.message:SetText(message)
                EGF.RefreshOptions()
            end)
            reset:SetEnabled(EGF.db.capturedOriginals[definition.id] ~= nil)
            y = y - row:GetHeight() - 10
        end
    end
    panel.content:SetHeight(math.max(390, -y + 20))
end

function EGF.RefreshPresets()
    local panel = EGF.options
    if not panel then return end
    for _, control in ipairs(panel.presetButtons or {}) do control:Hide() end
    panel.presetButtons = {}
    local x = 22
    for _, preset in ipairs(EGF.presets) do
        if preset.showButton ~= false then
        local control = button(panel, preset.label, x, -68, 116, function()
            local changed, failed = EGF.ApplyPreset(preset)
            panel.message:SetText(string.format("%s: changed %d setting(s); %d failed.", preset.label, changed, failed))
            EGF.RefreshOptions()
        end)
        control:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(preset.label)
            GameTooltip:AddLine(preset.description or "", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        control:SetScript("OnLeave", function() GameTooltip:Hide() end)
        colourPresetButton(control, preset.id)
        panel.presetButtons[#panel.presetButtons + 1] = control
        x = x + 126
        end
    end
end

function EGF.BuildOptions()
    if EGF.options then return EGF.options end
    local panel = CreateFrame("Frame", "GraphicsUnlockedForeverOptions", UIParent, "BackdropTemplate")
    EGF.options = panel
    panel:SetSize(690, 570)
    panel:SetPoint("CENTER", UIParent, "CENTER", EGF.db.windowX, EGF.db.windowY)
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    setBackdrop(panel)
    panel:SetBackdropColor(0.025, 0.035, 0.05, 0.98)
    panel:SetBackdropBorderColor(0.72, 0.52, 0.2, 1)
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        local px, py = UIParent:GetCenter()
        if x and y and px and py then EGF.db.windowX, EGF.db.windowY = x - px, y - py end
    end)

    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -3, -3)
    label(panel, EGF.TITLE, 22, -16, "GameFontNormalLarge")
    local subtitle = label(panel, "Extra graphics controls for WoW: Forever", 22, -41, "GameFontHighlight")
    subtitle:SetTextColor(0.72, 0.78, 0.88)
    button(panel, "Restore my original values", 448, -18, 185, function()
        local restored, failed = EGF.RestoreAll()
        panel.message:SetText(string.format("Restored %d setting(s); %d failed.", restored, failed))
        EGF.RefreshOptions()
    end)

    local scroll = CreateFrame("ScrollFrame", "GraphicsUnlockedForeverScroll", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 20, -105)
    scroll:SetPoint("BOTTOMRIGHT", -42, 62)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(625)
    content:SetHeight(390)
    scroll:SetScrollChild(content)
    panel.content = content
    panel.message = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    panel.message:SetPoint("BOTTOMLEFT", 22, 18)
    panel.message:SetText(EGF.CATALOG_STATUS or "Ready.")
    panel.message:SetWidth(320)
    panel.message:SetJustifyH("LEFT")
    panel.message:SetTextColor(0.75, 0.8, 0.88)
    panel.autoApply = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    panel.autoApply:SetPoint("BOTTOMRIGHT", -26, 10)
    panel.autoApply:SetSize(24, 24)
    panel.autoApply.Text:ClearAllPoints()
    panel.autoApply.Text:SetPoint("RIGHT", panel.autoApply, "LEFT", -4, 0)
    panel.autoApply.Text:SetWidth(305)
    panel.autoApply.Text:SetText("Reapply chosen values on login and zone changes")
    panel.autoApply.Text:SetJustifyH("RIGHT")
    panel.autoApply:SetChecked(EGF.db.autoApply)
    panel.autoApply:SetScript("OnClick", function(self)
        EGF.db.autoApply = self:GetChecked() and true or false
        panel.message:SetText(EGF.db.autoApply and "Automatic reapplication enabled." or "Automatic reapplication disabled.")
    end)
    panel.rows = {}
    panel.presetButtons = {}
    tinsert(UISpecialFrames, "GraphicsUnlockedForeverOptions")
    panel:Hide()
    EGF.RefreshPresets()
    EGF.RefreshOptions()
    return panel
end

function EGF.ToggleOptions()
    local panel = EGF.BuildOptions()
    panel:SetShown(not panel:IsShown())
    if panel:IsShown() then EGF.RefreshOptions() end
end

function EGF.RegisterNativeSettings()
    if EGF.nativeSettingsPanel then return end
    if not ((Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory) or InterfaceOptions_AddCategory) then return end
    local native = CreateFrame("Frame", "GraphicsUnlockedForeverNativeSettings")
    native.name = EGF.TITLE
    EGF.nativeSettingsPanel = native

    local title = label(native, EGF.TITLE, 18, -18, "GameFontNormalLarge")
    title:SetTextColor(0.2, 0.9, 0.82)
    label(native, "From Potato to UFO — hidden graphics controls with safe personal restoration.", 18, -46, "GameFontHighlight")
    local x = 18
    for _, id in ipairs(PROFILE_IDS) do
        local preset = EGF.presetsByID[id]
        local control = button(native, preset.label, x, -72, 100, function()
            EGF.ApplyPreset(preset)
            EGF.RefreshOptions()
        end)
        colourPresetButton(control, id)
        x = x + 108
    end
    button(native, "Open full individual controls", 18, -106, 220, function() EGF.ToggleOptions() end)
    button(native, "Restore my original values", 246, -106, 190, function()
        EGF.RestoreAll()
        EGF.RefreshOptions()
    end)
    local note = label(native, "The full panel contains every slider, toggle, per-setting P/L/M/H/UFO shortcut, warning and current value. The standard Settings API places add-on panels under Options → AddOns; it does not provide a supported way for add-ons to inject controls into Blizzard's protected Graphics canvas.", 18, -145, "GameFontHighlightSmall")
    note:SetWidth(560)
    note:SetTextColor(0.72, 0.78, 0.86)

    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(native, EGF.TITLE)
        EGF.settingsCategory = category
        Settings.RegisterAddOnCategory(category)
    else
        InterfaceOptions_AddCategory(native)
    end
end

function EGF.OpenNativeSettings()
    if EGF.settingsCategory and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(EGF.settingsCategory:GetID())
    elseif EGF.nativeSettingsPanel and InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(EGF.nativeSettingsPanel)
        InterfaceOptionsFrame_OpenToCategory(EGF.nativeSettingsPanel)
    else
        EGF.ToggleOptions()
    end
end

function EGF.UpdateMinimapButton()
    local minimap = EGF.minimap
    if not minimap or not Minimap or not EGF.db then return end
    local angle = math.rad(EGF.db.minimapAngle)
    local scale = Minimap:GetEffectiveScale() / minimap:GetEffectiveScale()
    local width, height = Minimap:GetWidth() or 140, Minimap:GetHeight() or 140
    minimap:ClearAllPoints()
    minimap:SetPoint("CENTER", Minimap, "CENTER",
        math.cos(angle) * (width * scale / 2 + 4),
        math.sin(angle) * (height * scale / 2 + 4))
    minimap:SetShown(not EGF.db.minimapHidden)
end

function EGF.BuildMinimapButton()
    if EGF.minimap or not Minimap then return end
    local minimap = CreateFrame("Button", "GraphicsUnlockedForeverMinimapButton", Minimap:GetParent() or UIParent)
    EGF.minimap = minimap
    minimap:SetSize(32, 32)
    minimap:SetFrameStrata("MEDIUM")
    minimap:SetFrameLevel((Minimap:GetFrameLevel() or 0) + 8)
    minimap:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimap:RegisterForDrag("LeftButton")
    local icon = minimap:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", 7, -5)
    icon:SetTexture("Interface\\AddOns\\GraphicsUnlockedForever\\Media\\Icon.tga")
    local border = minimap:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    minimap:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local function stopDrag()
        minimap:SetScript("OnUpdate", nil)
        minimap.ignoreClickUntil = GetTime() + 0.2
    end
    minimap:SetScript("OnClick", function()
        if GetTime() >= (minimap.ignoreClickUntil or 0) then EGF.ToggleOptions() end
    end)
    minimap:SetScript("OnDragStart", function()
        GameTooltip:Hide()
        minimap:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            if not cx or not cy then return end
            local scale = Minimap:GetEffectiveScale()
            EGF.db.minimapAngle = math.deg(math.atan2(y / scale - cy, x / scale - cx)) % 360
            EGF.UpdateMinimapButton()
        end)
    end)
    minimap:SetScript("OnDragStop", stopDrag)
    minimap:SetScript("OnHide", stopDrag)
    minimap:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(EGF.TITLE, 1, 0.82, 0.45)
        GameTooltip:AddLine("Click: open graphics controls", 1, 1, 1)
        GameTooltip:AddLine("Drag: move around the minimap", 0.75, 0.75, 0.75)
        GameTooltip:Show()
    end)
    minimap:SetScript("OnLeave", function() GameTooltip:Hide() end)
    EGF.UpdateMinimapButton()
end
