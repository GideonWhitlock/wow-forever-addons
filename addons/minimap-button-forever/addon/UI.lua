local _, F = ...

local function setBackdrop(frame)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = {left = 3, right = 3, top = 3, bottom = 3},
    })
end

local function requestLayout()
    if F.layoutPending or F.layingOut or InCombatLockdown() then return end
    F.layoutPending = true
    C_Timer.After(0, function()
        F.layoutPending = false
        if F.ready and not F.dragging and not InCombatLockdown() then F.Layout() end
    end)
end

local function watchCollectedButton(button)
    if button.MBFWatched then return end
    button.MBFWatched = true
    hooksecurefunc(button, "SetParent", function()
        if F.collectedByButton and F.collectedByButton[button] and not F.layingOut then requestLayout() end
    end)
    hooksecurefunc(button, "SetPoint", function()
        if F.collectedByButton and F.collectedByButton[button] and not F.layingOut then requestLayout() end
    end)
    hooksecurefunc(button, "SetAlpha", function(_, alpha)
        if alpha ~= 1 and F.collectedByButton and F.collectedByButton[button] and not F.layingOut then requestLayout() end
    end)
    hooksecurefunc(button, "Hide", function()
        local info = F.collectedByButton and F.collectedByButton[button]
        if not info or not info.forceVisible or not F.db.expanded or F.layingOut then return end
        if InCombatLockdown() then
            C_Timer.After(0, function()
                local current = F.collectedByButton and F.collectedByButton[button]
                if current == info and F.db.expanded and
                        not (button.IsProtected and button:IsProtected()) then
                    button:Show()
                end
            end)
        else
            requestLayout()
        end
    end)
end

function F.ApplyPosition()
    if not F.container or F.dragging then return end
    local width, height = F.container:GetSize()
    local size = F.db.size
    local x, y = F.db.x, F.db.y
    if F.db.vertical then
        local launcherOffsetY
        if y < 0 then
            launcherOffsetY = -height / 2 + 4 + size / 2
        else
            launcherOffsetY = height / 2 - 4 - size / 2
        end
        y = y - launcherOffsetY
    else
        local launcherOffsetX
        if x > 0 then
            launcherOffsetX = width / 2 - 4 - size / 2
        else
            launcherOffsetX = -width / 2 + 4 + size / 2
        end
        x = x - launcherOffsetX
    end
    F.container:ClearAllPoints()
    F.container:SetPoint("CENTER", UIParent, "CENTER", x, y)
end

function F.SavePosition()
    local x, y = F.launcher:GetCenter()
    local px, py = UIParent:GetCenter()
    if x and y and px and py then
        F.db.x, F.db.y = x - px, y - py
    end
end

function F.ReleaseButtons()
    if InCombatLockdown() or not F.collected then return end
    for _, info in ipairs(F.collected) do F.RestoreButton(info) end
    F.collected, F.collectedByButton = {}, {}
    F.Layout()
end

function F.ScanButtons(report)
    if InCombatLockdown() or F.dragging or not Minimap or not F.container then return end
    if not F.db.enabled then
        F.ReleaseButtons()
        return
    end
    for index = #F.collected, 1, -1 do
        local info = F.collected[index]
        if F.IsBlizzardMinimapControl(info.button) then
            F.collectedByButton[info.button] = nil
            table.remove(F.collected, index)
            F.RestoreButton(info)
        end
    end
    local added, seen = 0, {}
    local children = {}
    local function addChildren(frame, depth)
        if not frame or not frame.GetChildren or depth > 6 then return end
        for _, child in ipairs({frame:GetChildren()}) do
            if not seen[child] then
                seen[child] = true
                children[#children + 1] = child
                addChildren(child, depth + 1)
            end
        end
    end
    addChildren(Minimap, 0)
    local minimapParent = Minimap:GetParent()
    addChildren(minimapParent, 0)
    if UIParent and UIParent.GetChildren then
        for _, child in ipairs({UIParent:GetChildren()}) do
            if not seen[child] then
                seen[child] = true
                children[#children + 1] = child
            end
        end
    end
    for _, button in ipairs(children) do
        if F.IsCollectable(button) and not F.collectedByButton[button] then
            local info = F.CaptureButton(button)
            F.collected[#F.collected + 1] = info
            F.collectedByButton[button] = info
            watchCollectedButton(button)
            F.BrightenButton(info)
            -- Button-bag add-ons sometimes install an OnShow handler whose only
            -- job is to hide the button again. The original is restored on release.
            button:SetScript("OnShow", nil)
            button:SetParent(F.buttonHolder)
            button:SetScale(1)
            added = added + 1
        end
    end
    table.sort(F.collected, function(left, right) return left.order < right.order end)
    F.Layout()
    if report then F.Print("Scan complete: " .. added .. " new, " .. #F.collected .. " total button(s).") end
end

function F.ApplyExpandedVisibility()
    if not F.buttonHolder or not F.background then return end
    if F.db.expanded then
        for _, info in ipairs(F.collected or {}) do
            local button = info.button
            if info.forceVisible and button and
                    not (button.IsProtected and button:IsProtected()) then
                button:Show()
            end
        end
    end
    F.buttonHolder:SetShown(F.db.expanded)
    F.background:SetShown(F.db.expanded)
end

function F.ToggleExpanded()
    F.db.expanded = not F.db.expanded
    if InCombatLockdown() then
        F.ApplyExpandedVisibility()
    else
        F.Layout()
    end
end

function F.Layout()
    if InCombatLockdown() or not F.container then return end
    F.layingOut = true
    local size, spacing = F.db.size, F.db.spacing
    local visible = {}
    for _, info in ipairs(F.collected or {}) do
        local button = info.button
        if button then
            F.BrightenButton(info)
            button:SetParent(F.buttonHolder)
            button:SetScale(1)
            if info.forceVisible then button:Show() end
            if button:IsShown() then visible[#visible + 1] = button end
        end
    end
    local fullCount = 1 + #visible
    local count = F.db.expanded and fullCount or 1
    local length = count * size + math.max(0, count - 1) * spacing + 8
    local fullLength = fullCount * size + math.max(0, fullCount - 1) * spacing + 8
    local thickness = size + 8
    if F.db.vertical then F.container:SetSize(thickness, length) else F.container:SetSize(length, thickness) end
    F.background:SetBackdropColor(0.025, 0.02, 0.015, F.db.showBackground and 0.86 or 0)
    F.background:SetBackdropBorderColor(0.68, 0.48, 0.18, F.db.showBackground and 1 or 0)

    F.background:ClearAllPoints()
    F.buttonHolder:ClearAllPoints()
    if F.db.vertical then
        F.background:SetSize(thickness, fullLength)
        F.buttonHolder:SetSize(thickness, fullLength)
        if F.db.y < 0 then
            F.background:SetPoint("BOTTOM", F.container, "BOTTOM")
            F.buttonHolder:SetPoint("BOTTOM", F.container, "BOTTOM")
        else
            F.background:SetPoint("TOP", F.container, "TOP")
            F.buttonHolder:SetPoint("TOP", F.container, "TOP")
        end
    else
        F.background:SetSize(fullLength, thickness)
        F.buttonHolder:SetSize(fullLength, thickness)
        if F.db.x > 0 then
            F.background:SetPoint("RIGHT", F.container, "RIGHT")
            F.buttonHolder:SetPoint("RIGHT", F.container, "RIGHT")
        else
            F.background:SetPoint("LEFT", F.container, "LEFT")
            F.buttonHolder:SetPoint("LEFT", F.container, "LEFT")
        end
    end

    F.ApplyExpandedVisibility()
    local buttons = {F.launcher}
    for _, button in ipairs(visible) do buttons[#buttons + 1] = button end
    for index, button in ipairs(buttons) do
        local info = F.collectedByButton and F.collectedByButton[button]
        if info and info.isLibDBIcon then
            if button.SetFixedFrameLevel then button:SetFixedFrameLevel(false) end
            if button.SetFixedFrameStrata then button:SetFixedFrameStrata(false) end
        end
        button:ClearAllPoints()
        button:SetSize(size, size)
        button:SetFrameStrata("MEDIUM")
        button:SetFrameLevel(F.buttonHolder:GetFrameLevel() + 2)
        local offset = 4 + (index - 1) * (size + spacing)
        if F.db.vertical then
            if F.db.y < 0 then
                button:SetPoint("BOTTOM", F.container, "BOTTOM", 0, offset)
            else
                button:SetPoint("TOP", F.container, "TOP", 0, -offset)
            end
        else
            if F.db.x > 0 then
                button:SetPoint("RIGHT", F.container, "RIGHT", -offset, 0)
            else
                button:SetPoint("LEFT", F.container, "LEFT", offset, 0)
            end
        end
    end
    F.launcher.icon:SetSize(math.max(12, size - 8), math.max(12, size - 8))
    F.ApplyPosition()
    F.layingOut = false
end

local function launcherTooltip()
    GameTooltip:SetOwner(F.launcher, "ANCHOR_RIGHT")
    GameTooltip:SetText("Minimap Button: Forever", 1, 0.82, 0.3)
    GameTooltip:AddLine(F.db.expanded and "Left-click: hide collected icons" or "Left-click: show collected icons", 1, 1, 1)
    GameTooltip:AddLine("Right-click: open settings", 1, 1, 1)
    GameTooltip:AddLine("Alt-drag: move the button bar", 0.72, 0.72, 0.72)
    GameTooltip:AddLine((F.db.vertical and "Vertical" or "Horizontal") .. " layout - size " .. F.db.size, 0.72, 0.9, 0.72)
    GameTooltip:Show()
end

function F.BuildUI()
    if F.container then return end
    F.collected, F.collectedByButton = {}, {}

    local container = CreateFrame("Frame", "MinimapButtonForeverBar", UIParent, "BackdropTemplate")
    F.container = container
    container:SetFrameStrata("MEDIUM")
    container:SetFrameLevel(10)
    container:SetMovable(true)
    -- The bar can be wider than its controller. Clamping the whole bar makes
    -- the controller fall behind the cursor near a screen edge.
    container:SetClampedToScreen(false)
    local background = CreateFrame("Frame", "MinimapButtonForeverBackground", container, "BackdropTemplate")
    F.background = background
    background:SetFrameStrata("MEDIUM")
    background:SetFrameLevel(container:GetFrameLevel())
    if background.SetFixedFrameLevel then background:SetFixedFrameLevel(true) end
    background:EnableMouse(false)
    setBackdrop(background)

    local buttonHolder = CreateFrame("Frame", "MinimapButtonForeverButtonHolder", container)
    F.buttonHolder = buttonHolder
    buttonHolder:SetFrameStrata("MEDIUM")
    buttonHolder:SetFrameLevel(container:GetFrameLevel() + 10)
    buttonHolder.brightnessElapsed = 0
    buttonHolder:SetScript("OnUpdate", function(self, elapsed)
        self.brightnessElapsed = self.brightnessElapsed + elapsed
        if self.brightnessElapsed < 0.2 then return end
        self.brightnessElapsed = 0
        if InCombatLockdown() then return end
        for _, info in ipairs(F.collected or {}) do F.BrightenButton(info) end
    end)

    local launcher = CreateFrame("Button", "MinimapButtonForeverLauncher", container, "BackdropTemplate")
    F.launcher = launcher
    launcher:SetFrameStrata("MEDIUM")
    launcher:SetFrameLevel(buttonHolder:GetFrameLevel() + 2)
    launcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    launcher:RegisterForDrag("LeftButton")
    launcher:EnableMouse(true)
    launcher:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10,
        insets = {left = 2, right = 2, top = 2, bottom = 2}})
    launcher:SetBackdropColor(0.12, 0.08, 0.02, 1)
    launcher:SetBackdropBorderColor(1, 0.72, 0.2, 1)
    launcher.icon = launcher:CreateTexture(nil, "ARTWORK")
    launcher.icon:SetPoint("CENTER")
    launcher.icon:SetTexture("Interface\\Icons\\INV_Misc_PocketWatch_01")
    launcher.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    launcher:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    launcher:SetScript("OnEnter", launcherTooltip)
    launcher:SetScript("OnLeave", function() GameTooltip:Hide() end)
    launcher:SetScript("OnClick", function(_, mouseButton)
        if GetTime() < (launcher.ignoreClickUntil or 0) then return end
        if mouseButton == "RightButton" then
            F.ToggleOptions()
        else
            F.ToggleExpanded()
            if GameTooltip:IsOwned(launcher) then launcherTooltip() end
        end
    end)
    launcher:SetScript("OnDragStart", function()
        if InCombatLockdown() or not IsAltKeyDown() then return end
        GameTooltip:Hide()
        F.dragging = true
        local cursorX, cursorY = GetCursorPosition()
        local scale = UIParent:GetEffectiveScale()
        local containerX, containerY = container:GetCenter()
        local parentX, parentY = UIParent:GetCenter()
        if not cursorX or not cursorY or not scale or scale == 0 or
                not containerX or not containerY or not parentX or not parentY then
            F.dragging = false
            return
        end
        F.dragCursorX, F.dragCursorY = cursorX / scale, cursorY / scale
        F.dragContainerX, F.dragContainerY = containerX - parentX, containerY - parentY
        container:SetScript("OnUpdate", function()
            local currentX, currentY = GetCursorPosition()
            local currentScale = UIParent:GetEffectiveScale()
            if not currentX or not currentY or not currentScale or currentScale == 0 then return end
            local x = F.dragContainerX + currentX / currentScale - F.dragCursorX
            local y = F.dragContainerY + currentY / currentScale - F.dragCursorY
            container:ClearAllPoints()
            container:SetPoint("CENTER", UIParent, "CENTER", x, y)
        end)
    end)
    launcher:SetScript("OnDragStop", function()
        if not F.dragging then return end
        container:SetScript("OnUpdate", nil)
        F.dragging = false
        F.dragCursorX, F.dragCursorY = nil, nil
        F.dragContainerX, F.dragContainerY = nil, nil
        launcher.ignoreClickUntil = GetTime() + 0.2
        F.SavePosition()
        F.Layout()
    end)
    F.ApplyPosition()
    F.Layout()
end

local function createSlider(parent, name, y, lowValue, highValue, valueStep, onChanged)
    local slider = CreateFrame("Slider", name, parent, "BackdropTemplate")
    slider:SetPoint("TOP", 0, y)
    slider:SetSize(270, 16)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(lowValue, highValue)
    slider:SetValueStep(valueStep)
    slider:SetObeyStepOnDrag(true)
    slider:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
    slider:SetBackdropColor(0.08, 0.07, 0.05, 1)
    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
    thumb:SetSize(24, 24)
    slider:SetThumbTexture(thumb)
    local low = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -2); low:SetText(tostring(lowValue))
    local high = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    high:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2); high:SetText(tostring(highValue))
    slider.label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    slider.label:SetPoint("BOTTOM", slider, "TOP", 0, 5)
    slider:SetScript("OnValueChanged", function(_, value)
        if not F.syncingOptions then onChanged(value) end
    end)
    return slider
end

function F.SyncOptions()
    if not F.options then return end
    F.syncingOptions = true
    F.options.enabled:SetChecked(F.db.enabled)
    F.options.vertical:SetChecked(F.db.vertical)
    F.options.background:SetChecked(F.db.showBackground)
    F.options.size:SetValue(F.db.size)
    F.options.size.label:SetText("Icon size: " .. F.db.size)
    F.options.spacing:SetValue(F.db.spacing)
    F.options.spacing.label:SetText("Spacing: " .. F.db.spacing)
    F.syncingOptions = false
end

function F.ToggleOptions()
    if InCombatLockdown() then F.Print("Settings can be changed after combat."); return end
    if not F.options then
        local panel = CreateFrame("Frame", "MinimapButtonForeverOptions", UIParent, "BackdropTemplate")
        F.options = panel
        panel:SetSize(360, 390)
        panel:SetPoint("CENTER", UIParent, "CENTER", 250, 0)
        panel:SetFrameStrata("DIALOG")
        panel:SetClampedToScreen(true)
        panel:SetMovable(true)
        panel:EnableMouse(true)
        panel:RegisterForDrag("LeftButton")
        panel:SetScript("OnDragStart", panel.StartMoving)
        panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
        panel:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 28,
            insets = {left = 8, right = 8, top = 8, bottom = 8}})
        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -20); title:SetText("Minimap Button: Forever")
        local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -4, -4)
        local help = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        help:SetPoint("TOP", 0, -52)
        help:SetText("Alt-drag the gold icon to move it.\nThe bar opens inward from the nearest screen edge.")

        local function checkbox(y, label, action)
            local check = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
            check:SetPoint("TOPLEFT", 24, y); check.Text:SetText(label)
            check:SetScript("OnClick", function(self) action(self:GetChecked() and true or false) end)
            return check
        end
        panel.enabled = checkbox(-92, "Organise add-on minimap buttons", function(checked)
            F.db.enabled = checked
            if checked then F.ScanButtons(true) else F.ReleaseButtons() end
        end)
        panel.vertical = checkbox(-124, "Use a vertical layout", function(checked)
            F.db.vertical = checked; F.Layout()
        end)
        panel.background = checkbox(-156, "Show the bar background", function(checked)
            F.db.showBackground = checked; F.Layout()
        end)
        panel.size = createSlider(panel, "MinimapButtonForeverSizeSlider", -220,
            F.MIN_SIZE, F.MAX_SIZE, 1, F.SetSize)
        panel.spacing = createSlider(panel, "MinimapButtonForeverSpacingSlider", -285,
            F.MIN_SPACING, F.MAX_SPACING, 1, F.SetSpacing)

        local scan = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        scan:SetSize(110, 26); scan:SetPoint("BOTTOMLEFT", 48, 28); scan:SetText("Scan buttons")
        scan:SetScript("OnClick", function() F.ScanButtons(true) end)
        local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        reset:SetSize(110, 26); reset:SetPoint("BOTTOMRIGHT", -48, 28); reset:SetText("Reset layout")
        reset:SetScript("OnClick", F.ResetLayout)
    end
    if F.options:IsShown() then F.options:Hide() else F.SyncOptions(); F.options:Show() end
end
