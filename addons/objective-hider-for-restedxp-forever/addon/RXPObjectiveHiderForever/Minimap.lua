local _, addon = ...
local L = addon.L
local ICON = "Interface\\AddOns\\RXPObjectiveHiderForever\\Media\\Icon.tga"

local function cursorAngle()
    local cursorX, cursorY = GetCursorPosition()
    local mapX, mapY = Minimap:GetCenter()
    if not cursorX or not cursorY or not mapX or not mapY then return addon.db.minimap.angle end
    local scale = UIParent:GetEffectiveScale()
    return addon.AngleFromXY(cursorX / scale - mapX, cursorY / scale - mapY) or addon.db.minimap.angle
end

function addon.ApplyMinimapPosition(force)
    local button = addon.minimapButton
    if not button or not Minimap or not addon.db then return end
    -- Button collectors own layout after reparenting; do not fight them.
    if button:GetParent() ~= Minimap then return end
    local width, height = Minimap:GetWidth(), Minimap:GetHeight()
    if not width or width <= 0 or not height or height <= 0 then return end
    local angle = math.rad(addon.NormalizeAngle(addon.db.minimap.angle))
    local x, y = math.cos(angle) * width / 2, math.sin(angle) * height / 2
    if not force and button.lastX == x and button.lastY == y then return end
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
    button.lastX, button.lastY = x, y
end

function addon.ApplyMinimapVisibility()
    if addon.minimapButton and addon.db then addon.minimapButton:SetShown(addon.db.minimap.shown) end
end

function addon.UpdateMinimapVisual()
    local button = addon.minimapButton
    if not button or not addon.db then return end
    local enabled = addon.db.enabled
    button.icon:SetDesaturated(not enabled)
    button.icon:SetVertexColor(enabled and 1 or 0.62, enabled and 1 or 0.62, enabled and 1 or 0.62, 1)
    if GameTooltip and GameTooltip:IsOwned(button) then button:GetScript("OnEnter")(button) end
end

local function stopDrag(button)
    button:SetScript("OnUpdate", nil)
    button.dragging = false
    button.ignoreClickUntil = GetTime() + 0.2
    addon.ApplyMinimapPosition(true)
end

local function buildButton()
    if addon.minimapButton or not Minimap or not addon.db then return end
    local button = CreateFrame("Button", "RXPObjectiveHiderForeverMinimapButton", Minimap)
    addon.minimapButton = button
    button:SetSize(34, 34)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:SetClampedToScreen(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHitRectInsets(2, 2, 2, 2)

    local icon = button:CreateTexture(nil, "ARTWORK")
    button.icon = icon
    icon:SetAllPoints(button)
    icon:SetTexture(ICON)
    icon:SetTexCoord(0, 1, 0, 1)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(L.ADDON_NAME, 0.88, 0.70, 0.30)
        local enabled = addon.db.enabled
        GameTooltip:AddLine(enabled and L.STATUS_ON or L.STATUS_OFF,
            enabled and 0.35 or 0.72, enabled and 0.9 or 0.72, enabled and 0.42 or 0.72)
        if addon.pendingCombat then GameTooltip:AddLine(L.STATUS_PENDING, 1, 0.55, 0.2) end
        GameTooltip:AddLine(L.LEFT_CLICK, 1, 1, 1)
        GameTooltip:AddLine(L.RIGHT_CLICK, 1, 1, 1)
        GameTooltip:AddLine(L.DRAG, 0.72, 0.72, 0.72)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnClick", function(_, mouseButton)
        if GetTime() < (button.ignoreClickUntil or 0) then return end
        if mouseButton == "RightButton" then addon.OpenSettings()
        else addon.ToggleEnabled("minimap button") end
    end)
    button:SetScript("OnDragStart", function(self)
        if InCombatLockdown and InCombatLockdown() then
            addon.Print("Move the minimap button after combat.")
            return
        end
        if self:GetParent() ~= Minimap then return end
        self.dragging = true
        GameTooltip:Hide()
        self:SetScript("OnUpdate", function()
            if InCombatLockdown and InCombatLockdown() then stopDrag(self); return end
            addon.db.minimap.angle = cursorAngle()
            addon.ApplyMinimapPosition(true)
        end)
    end)
    button:SetScript("OnDragStop", stopDrag)
    button:SetScript("OnHide", function(self) if self.dragging then stopDrag(self) end end)
    button:SetScript("OnShow", function(self)
        if self:GetParent() == Minimap then addon.ApplyMinimapPosition(true) end
        addon.UpdateMinimapVisual()
    end)

    addon.ApplyMinimapPosition(true)
    addon.ApplyMinimapVisibility()
    addon.UpdateMinimapVisual()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("DISPLAY_SIZE_CHANGED")
frame:RegisterEvent("UI_SCALE_CHANGED")
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then buildButton()
    else addon.ApplyMinimapPosition(true) end
end)
