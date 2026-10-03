local _, F = ...

function F.UpdateMinimap(force)
    local b = F.minimap
    if not b or InCombatLockdown() then return end
    local scale = Minimap:GetEffectiveScale() / b:GetEffectiveScale()
    local width, height = Minimap:GetWidth(), Minimap:GetHeight()
    if not force and b.mapWidth == width and b.mapHeight == height and b.mapScale == scale then return end
    local angle = math.rad(F.db.minimapAngle)
    b:ClearAllPoints()
    b:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * (width * scale / 2 + 4),
        math.sin(angle) * (height * scale / 2 + 4))
    b:SetShown(not F.db.minimapHidden)
    b.mapWidth, b.mapHeight, b.mapScale = width, height, scale
end

function F.BuildMinimap()
    if F.minimap or not Minimap then return end
    local b = CreateFrame("Button", "FeedPetForeverMinimapButton", Minimap:GetParent() or UIParent)
    F.minimap = b
    b:SetSize(32, 32); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    b:EnableMouse(true); b:RegisterForClicks("LeftButtonUp", "RightButtonUp"); b:RegisterForDrag("LeftButton")
    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20); icon:SetPoint("TOPLEFT", 7, -5)
    icon:SetTexture((C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(F.FEED_SPELL))
        or "Interface\\Icons\\Ability_Hunter_BeastTraining")
    icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local border = b:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54); border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    b:SetScript("OnEnter", function()
        GameTooltip:SetOwner(b, "ANCHOR_LEFT"); GameTooltip:SetText("Feed Pet: Forever", 1, 0.82, 0.3)
        GameTooltip:AddLine("Left-click: settings", 1, 1, 1)
        GameTooltip:AddLine("Right-click: toggle layout preview", 1, 1, 1)
        GameTooltip:AddLine("Drag: move around the minimap", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetScript("OnClick", function(_, which)
        if GetTime() < (b.ignoreClickUntil or 0) then return end
        if InCombatLockdown() then F.Print("Wait until combat ends to change settings."); return end
        if which == "RightButton" then
            F.SetLayout(not F.unlocked)
            if F.options then F.options.layout:SetText(F.unlocked and "Lock" or "Unlock") end
        else F.ToggleOptions() end
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
            F.db.minimapAngle = math.deg(math.atan2(y / scale - cy, x / scale - cx)) % 360
            F.UpdateMinimap(true)
        end)
    end)
    b:SetScript("OnDragStop", stopDrag)
    b:SetScript("OnHide", stopDrag)
    F.UpdateMinimap(true)
end

function F.ApplyLayout()
    if InCombatLockdown() then return end
    local b = F.button
    b:SetSize(F.db.size, F.db.size)
    if b.cross then b.cross:SetSize(F.db.size * 0.55, F.db.size * 0.55) end
    b:ClearAllPoints()
    local maxX = math.max(0, (UIParent:GetWidth() - F.db.size) / 2)
    local maxY = math.max(0, (UIParent:GetHeight() - F.db.size) / 2 - 24)
    F.db.x, F.db.y = math.max(-maxX, math.min(maxX, F.db.x)), math.max(-maxY, math.min(maxY, F.db.y))
    b:SetPoint("CENTER", UIParent, "CENTER", F.db.x, F.db.y)
    b.label:SetWidth(math.max(100, F.db.size + 50))
    if F.sizeSlider then
        F.sizeSlider:SetValue(F.db.size)
        F.sizeText:SetText("Icon size: " .. F.db.size)
    end
end

function F.Render(mode)
    local b = F.button
    F.mode = mode
    if mode == "hidden" then b:Hide(); return end
    local noFood = mode == "nofood" or mode == "preview-nofood"
    local preview = mode == "preview" or mode == "preview-nofood"
    b.icon:SetTexture(noFood and "Interface\\Icons\\INV_Misc_Food_16"
        or (C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(F.FEED_SPELL))
        or "Interface\\Icons\\Ability_Hunter_BeastTraining")
    b.icon:SetDesaturated(noFood)
    b.icon:SetVertexColor(1, noFood and 0.5 or 1, noFood and 0.5 or 1)
    b.label:SetText(preview and "LAYOUT PREVIEW" or noFood and "NO FOOD" or "")
    b.label:SetTextColor(1, noFood and 0.35 or 0.8, noFood and 0.3 or 0.35)
    b.cross:SetShown(noFood)
    b.count:SetText(not preview and not noFood and tostring(F.foodCount or "") or "")
    b:Show()
    if F.db.flash and not noFood then
        if not b.pulse:IsPlaying() then b.pulse:Play() end
    else
        b.pulse:Stop(); b.icon:SetAlpha(1)
    end
end

function F.Tooltip()
    local b = F.button
    GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
    GameTooltip:SetText("Feed Pet: Forever", 1, 0.82, 0.3)
    if F.unlocked then
        GameTooltip:AddLine("Layout preview - feeding is disabled.", 1, 1, 1)
        GameTooltip:AddLine("Drag to move. Mouse wheel to resize.", 1, 1, 1)
        GameTooltip:AddLine("Type /fpf lock to finish.", 1, 1, 1)
    elseif F.mode == "food" and F.food then
        GameTooltip:AddLine((F.reason or "Hungry") .. " - left-click to feed.", 1, 1, 1)
        GameTooltip:AddLine(F.food.link or F.food.name, 1, 1, 1)
        GameTooltip:AddLine("Suitable food in bags: " .. F.foodCount, 0.7, 0.9, 0.7)
    else
        GameTooltip:AddLine("Your pet needs feeding, but has no suitable food in your bags.", 1, 0.5, 0.4, true)
        local diet = C_PetInfo and C_PetInfo.GetPetFoodTypes and C_PetInfo.GetPetFoodTypes()
        if diet and #diet > 0 then GameTooltip:AddLine("Eats: " .. table.concat(diet, ", "), 1, 1, 1, true) end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Right-click: settings", 0.7, 0.7, 0.7)
    GameTooltip:AddLine("Shift-drag: move  |  Shift-wheel: resize", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end

function F.BuildUI()
    -- The protected parent is hidden by Blizzard's state driver in combat, even
    -- if a Lua event arrives after lockdown has already begun.
    local gate = CreateFrame("Frame", "FeedPetForeverGate", UIParent, "SecureHandlerStateTemplate")
    gate:SetAllPoints(UIParent)
    RegisterStateDriver(gate, "visibility", "[combat][dead][@pet,dead][mounted][flying][vehicleui] hide; show")
    F.gate = gate
    local b = CreateFrame("Button", "FeedPetForeverButton", gate, "SecureActionButtonTemplate,BackdropTemplate")
    F.button = b
    b:Hide()
    b:SetFrameStrata("MEDIUM")
    b:SetClampedToScreen(true)
    b:SetMovable(true)
    b:EnableMouse(true)
    b:EnableMouseWheel(true)
    b:RegisterForClicks("AnyUp")
    b:RegisterForDrag("LeftButton")
    b:SetAttribute("useOnKeyDown", false)
    b:SetAttribute("shift-type1", "")
    b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14,
        insets = {left = 3, right = 3, top = 3, bottom = 3}})
    b:SetBackdropColor(0.03, 0.025, 0.02, 0.95)
    b:SetBackdropBorderColor(0.9, 0.65, 0.22, 1)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 4, -4); b.icon:SetPoint("BOTTOMRIGHT", -4, 4)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.label:SetPoint("TOP", b, "BOTTOM", 0, -3)
    b.count = b:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    b.count:SetPoint("BOTTOMRIGHT", -6, 6)
    b.cross = b:CreateTexture(nil, "OVERLAY")
    b.cross:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    b.cross:SetPoint("CENTER"); b.cross:SetSize(26, 26)
    b.pulse = b.icon:CreateAnimationGroup()
    local fadeOut = b.pulse:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1); fadeOut:SetToAlpha(0.3); fadeOut:SetDuration(0.55); fadeOut:SetOrder(1)
    local fadeIn = b.pulse:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0.3); fadeIn:SetToAlpha(1); fadeIn:SetDuration(0.55); fadeIn:SetOrder(2)
    b.pulse:SetLooping("REPEAT")
    b:SetScript("PreClick", F.PreClick)
    b:SetScript("PostClick", F.PostClick)
    b:SetScript("OnEnter", F.Tooltip)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetScript("OnHide", function()
        b.pulse:Stop()
        b.icon:SetAlpha(1)
        GameTooltip:Hide()
    end)
    b:SetScript("OnDragStart", function()
        if InCombatLockdown() or not (F.unlocked or IsShiftKeyDown()) then return end
        F.dragging = true; F.Disarm(); b:StartMoving()
    end)
    b:SetScript("OnDragStop", function()
        if InCombatLockdown() then return end
        b:StopMovingOrSizing()
        if F.dragging then
            local x, y = b:GetCenter()
            local px, py = UIParent:GetCenter()
            F.db.x, F.db.y = x - px, y - py
            F.dragging = false; F.dragStoppedAt = GetTime()
            F.ApplyLayout(); F.Refresh()
        end
    end)
    b:SetScript("OnMouseWheel", function(_, delta)
        if not InCombatLockdown() and (F.unlocked or IsShiftKeyDown()) then F.SetSize(F.db.size + delta * 4) end
    end)
    F.ApplyLayout()
    F.BuildMinimap()
end

function F.ToggleOptions()
    if InCombatLockdown() then return end
    if not F.options then
        local panel = CreateFrame("Frame", "FeedPetForeverOptions", UIParent, "BackdropTemplate")
        F.options = panel
        panel:SetSize(340, 320); panel:SetPoint("CENTER", UIParent, "CENTER", 220, 0)
        panel:SetFrameStrata("DIALOG"); panel:SetClampedToScreen(true); panel:EnableMouse(true)
        panel:SetMovable(true); panel:RegisterForDrag("LeftButton")
        panel:SetScript("OnDragStart", panel.StartMoving)
        panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
        panel:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 28,
            insets = {left = 8, right = 8, top = 8, bottom = 8}})
        local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -20); title:SetText("Feed Pet: Forever")
        local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -4, -4)
        local help = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        help:SetPoint("TOP", 0, -50); help:SetText("Unlock for a draggable preview.\nSettings are saved for this character.")
        -- OptionsSliderTemplate is not present in this Forever UI build.
        local slider = CreateFrame("Slider", "FeedPetForeverSizeSlider", panel, "BackdropTemplate")
        F.sizeSlider = slider
        slider:SetPoint("TOP", 0, -108); slider:SetSize(270, 16)
        slider:SetOrientation("HORIZONTAL")
        slider:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
        slider:SetBackdropColor(0.08, 0.07, 0.05, 1)
        local thumb = slider:CreateTexture(nil, "ARTWORK")
        thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        thumb:SetSize(24, 24); slider:SetThumbTexture(thumb)
        slider:SetMinMaxValues(F.MIN_SIZE, F.MAX_SIZE); slider:SetValueStep(1); slider:SetObeyStepOnDrag(true)
        local low = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -2); low:SetText(tostring(F.MIN_SIZE))
        local high = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        high:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2); high:SetText(tostring(F.MAX_SIZE))
        F.sizeText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        F.sizeText:SetPoint("BOTTOM", slider, "TOP", 0, 5)
        slider:SetScript("OnValueChanged", function(_, value)
            if not InCombatLockdown() and math.floor(value + 0.5) ~= F.db.size then F.SetSize(value) end
        end)
        local function checkbox(y, label, key)
            local c = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
            c:SetPoint("TOPLEFT", 22, y); c.Text:SetText(label)
            c:SetScript("OnClick", function(self)
                if not InCombatLockdown() then F.db[key] = self:GetChecked() and true or false; F.Refresh() end
            end)
            return c
        end
        panel.noFood = checkbox(-145, "Show a warning when no food is available", "showNoFood")
        panel.flash = checkbox(-177, "Flash the feeding icon", "flash")
        panel.minimap = checkbox(-209, "Hide the minimap button", "minimapHidden")
        panel.minimap:SetScript("OnClick", function(self)
            if not InCombatLockdown() then
                F.db.minimapHidden = self:GetChecked() and true or false; F.UpdateMinimap(true)
            end
        end)
        local function button(x, label, action)
            local c = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
            c:SetSize(90, 25); c:SetPoint("BOTTOMLEFT", x, 24); c:SetText(label)
            c:SetScript("OnClick", function() if not InCombatLockdown() then action() end end)
            return c
        end
        panel.layout = button(23, "Unlock", function()
            F.SetLayout(not F.unlocked)
            panel.layout:SetText(F.unlocked and "Lock" or "Unlock")
        end)
        button(125, "Centre", function() F.db.x, F.db.y = 0, 0; F.ApplyLayout() end)
        button(227, "Done", function() F.SetLayout(false); panel:Hide() end)
        table.insert(UISpecialFrames, "FeedPetForeverOptions")
        panel:Hide()
        panel:SetScript("OnHide", function()
            if not InCombatLockdown() and F.unlocked then F.SetLayout(false) end
        end)
    end
    if F.options:IsShown() then F.options:Hide(); return end
    F.options.noFood:SetChecked(F.db.showNoFood)
    F.options.flash:SetChecked(F.db.flash)
    F.options.minimap:SetChecked(F.db.minimapHidden)
    F.options.layout:SetText(F.unlocked and "Lock" or "Unlock")
    F.ApplyLayout()
    F.options:Show()
end
