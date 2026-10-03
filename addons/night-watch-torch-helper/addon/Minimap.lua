local _, N = ...
local fallbackIcon = "Interface\\Icons\\INV_Torch_Lit"

function N.UpdateMinimap(force)
    local b = N.minimap
    if not b or InCombatLockdown() then return end
    local width, height = Minimap:GetWidth(), Minimap:GetHeight()
    local scale = Minimap:GetEffectiveScale() / b:GetEffectiveScale()
    if not force and b.mapWidth == width and b.mapHeight == height and b.mapScale == scale then return end
    local angle = math.rad(N.db.minimapAngle)
    b:ClearAllPoints()
    b:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * (width * scale / 2 + 4),
        math.sin(angle) * (height * scale / 2 + 4))
    b:SetShown(not N.db.minimapHidden)
    b.mapWidth, b.mapHeight, b.mapScale = width, height, scale
end

function N.UpdateOptions()
    if not N.options then return end
    N.options.enabled:SetChecked(N.db.enabled)
    N.options.dim:SetChecked(N.dimArea or false)
    N.options.size:SetText("Torch button size: " .. N.db.size)
    N.options.layout:SetText(N.preview and "Lock torch button" or "Move torch button")
end

function N.ToggleLayout()
    if InCombatLockdown() then N.Print("Wait until combat ends to arrange the torch button."); return end
    N.preview = not N.preview
    N.Refresh()
    N.UpdateOptions()
end

function N.ToggleOptions()
    if InCombatLockdown() then N.Print("Wait until combat ends to change settings."); return end
    if not N.options then
        local panel = CreateFrame("Frame", "NightWatchTorchOptions", UIParent, "BackdropTemplate")
        N.options = panel
        panel:SetSize(330, 300)
        panel:SetPoint("CENTER", UIParent, "CENTER", 180, 0)
        panel:SetFrameStrata("DIALOG")
        panel:SetClampedToScreen(true)
        panel:EnableMouse(true)
        panel:SetMovable(true)
        panel:RegisterForDrag("LeftButton")
        panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
        panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
        panel:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 28,
            insets = { left = 8, right = 8, top = 8, bottom = 8 } })
        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -22)
        title:SetText("Night Watch Torch")
        local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -4, -4)
        close:SetScript("OnClick", function() panel:Hide() end)
        local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOP", 0, -49)
        hint:SetText("Click the torch when it appears to light it.")

        local function checkbox(label, y, getter, setter)
            local b = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
            b:SetSize(26, 26)
            b:SetPoint("TOPLEFT", 24, y)
            local text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            text:SetPoint("LEFT", b, "RIGHT", 5, 0)
            text:SetText(label)
            b:SetScript("OnClick", function(self)
                if InCombatLockdown() then
                    self:SetChecked(getter())
                    N.Print("Change settings after combat ends.")
                    return
                end
                setter(self:GetChecked() and true or false)
                N.Refresh()
                N.UpdateOptions()
            end)
            return b
        end
        panel.enabled = checkbox("Enable torch reminders", -76,
            function() return N.db.enabled end,
            function(value) N.db.enabled = value; if not value then N.preview = false end end)
        panel.dim = checkbox("This area is dim or foggy", -108,
            function() return N.dimArea or false end,
            function(value) N.dimArea = value end)
        local dimHint = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        dimHint:SetPoint("TOPLEFT", 30, -140)
        dimHint:SetText("Dim-area setting clears when you change area.")
        panel.size = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        panel.size:SetPoint("TOP", 0, -173)
        local function button(label, width, x, y, action)
            local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            b:SetSize(width, 24)
            b:SetPoint("TOP", panel, "TOP", x, y)
            b:SetText(label)
            b:SetScript("OnClick", function()
                if InCombatLockdown() then N.Print("Change settings after combat ends."); return end
                action()
                N.Refresh()
                N.UpdateOptions()
            end)
            return b
        end
        button("Smaller", 105, -58, -198, function()
            N.db.size = math.max(32, N.db.size - 4); N.ApplyPosition()
        end)
        button("Larger", 105, 58, -198, function()
            N.db.size = math.min(100, N.db.size + 4); N.ApplyPosition()
        end)
        panel.layout = button("Move torch button", 220, 0, -237, N.ToggleLayout)
        panel:Hide()
        UISpecialFrames[#UISpecialFrames + 1] = "NightWatchTorchOptions"
    end
    N.UpdateOptions()
    N.options:SetShown(not N.options:IsShown())
end

function N.BuildMinimap()
    if N.minimap or not Minimap or InCombatLockdown() then return end
    local b = CreateFrame("Button", "NightWatchTorchMinimapButton", UIParent)
    N.minimap = b
    b:SetSize(32, 32)
    b:SetFrameStrata("MEDIUM")
    b:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    b:EnableMouse(true)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:RegisterForDrag("LeftButton")
    local icon = b:CreateTexture(nil, "ARTWORK")
    b.icon = icon
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", 7, -5)
    icon:SetTexture((C_Item and C_Item.GetItemIconByID(N.ITEM_ID)) or fallbackIcon)
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    b:SetScript("OnEnter", function()
        GameTooltip:SetOwner(b, "ANCHOR_LEFT")
        GameTooltip:SetText("Night Watch Torch", 1, 0.82, 0.45)
        GameTooltip:AddLine("Left-click: settings", 1, 1, 1)
        GameTooltip:AddLine("Right-click: move or lock the torch button", 1, 1, 1, true)
        GameTooltip:AddLine("Drag: move this minimap icon", 0.75, 0.75, 0.75)
        local _, reason = N.Evaluate()
        GameTooltip:AddLine(reason, 1, 0.82, 0.45, true)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetScript("OnClick", function(_, which)
        if GetTime() < (b.ignoreClickUntil or 0) then return end
        if which == "RightButton" then N.ToggleLayout() else N.ToggleOptions() end
    end)
    local function stopDrag()
        b:SetScript("OnUpdate", nil)
        b.ignoreClickUntil = GetTime() + 0.2
    end
    b:SetScript("OnDragStart", function()
        if InCombatLockdown() then return end
        GameTooltip:Hide()
        b:SetScript("OnUpdate", function()
            if InCombatLockdown() then stopDrag(); return end
            local x, y = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            if not cx or not cy then return end
            local scale = Minimap:GetEffectiveScale()
            N.db.minimapAngle = math.deg(math.atan2(y / scale - cy, x / scale - cx)) % 360
            N.UpdateMinimap(true)
        end)
    end)
    b:SetScript("OnDragStop", stopDrag)
    b:SetScript("OnHide", stopDrag)
    N.UpdateMinimap(true)
end
