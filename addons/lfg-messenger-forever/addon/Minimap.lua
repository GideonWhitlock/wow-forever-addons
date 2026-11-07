local _, Q = ...
local RIM_INSET = 10

function Q.UpdateMinimap()
    local button = Q.minimapButton
    if not button or not Q.db then return end
    local angle = math.rad(Q.db.minimap.angle or 215)
    local scale = Minimap:GetEffectiveScale() / button:GetEffectiveScale()
    local radiusX = math.max(1, Minimap:GetWidth() / 2 - RIM_INSET) * scale
    local radiusY = math.max(1, Minimap:GetHeight() / 2 - RIM_INSET) * scale
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radiusX, math.sin(angle) * radiusY)
    button:SetShown(not Q.db.minimap.hidden)
end

local function loadGroupFinder()
    if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
        pcall(C_AddOns.LoadAddOn, Q.BLIZZARD_ADDON)
    elseif type(LoadAddOn) == "function" then
        pcall(LoadAddOn, Q.BLIZZARD_ADDON)
    end
end

function Q.ToggleGroupFinder()
    loadGroupFinder()
    Q.TryAttachToGroupFinder()
    if type(LFGVanilla_ToggleFrame) == "function" then
        LFGVanilla_ToggleFrame(2)
        return
    end
    if LFGParentFrame and LFGParentFrame:IsShown() then
        if type(HideUIPanel) == "function" then HideUIPanel(LFGParentFrame) else LFGParentFrame:Hide() end
        return
    end
    if type(PVEFrame_ShowFrame) == "function" and LFGParentFrame then
        local ok = pcall(PVEFrame_ShowFrame, "GroupFinderFrame", LFGParentFrame)
        if ok then return end
    end
    if LFGParentFrame then
        if type(ShowUIPanel) == "function" then ShowUIPanel(LFGParentFrame) else LFGParentFrame:Show() end
    else
        Q.Print("Open Looking For Group once so the game can load it.")
    end
end

function Q.CreateMinimapButton()
    if Q.minimapButton or not Minimap then return end
    local button = CreateFrame("Button", "LFGMessengerForeverMinimapButton", Minimap:GetParent() or UIParent)
    Q.minimapButton = button
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(24, 24)
    background:SetPoint("CENTER")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", 7, -5)
    icon:SetTexture(Q.ICON)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function(_, mouse)
        if GetTime() < (button.ignoreClickUntil or 0) then return end
        if mouse == "RightButton" then Q.ToggleOptions() else Q.ToggleGroupFinder() end
    end)
    button:SetScript("OnDragStart", function(self) self.dragging = true; GameTooltip:Hide() end)
    button:SetScript("OnDragStop", function(self) self.dragging = false; self.ignoreClickUntil = GetTime() + 0.2 end)
    button:SetScript("OnUpdate", function(self)
        if not self.dragging then return end
        local mx, my = Minimap:GetCenter()
        local cx, cy = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        if mx and my then
            Q.db.minimap.angle = math.deg(math.atan2(cy / scale - my, cx / scale - mx)) % 360
            Q.UpdateMinimap()
        end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(Q.TITLE, 1, 0.82, 0)
        GameTooltip:AddLine("Left-click: open or close Looking For Group", 1, 1, 1, true)
        GameTooltip:AddLine("Right-click: message settings", 1, 1, 1)
        GameTooltip:AddLine("Drag: move this icon", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Current message: " .. Q.BuildMessage(), 1, 0.82, 0, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    Q.UpdateMinimap()
end
