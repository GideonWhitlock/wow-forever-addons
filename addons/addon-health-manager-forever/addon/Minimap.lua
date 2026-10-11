local ADDON_NAME, NS = ...

-- Forever's modern Minimap frame includes transparent/art padding outside the
-- visible circular rim. Orbiting at half the raw frame width therefore places
-- a button visibly outside the ring. This inset is measured against the
-- 1.60.1 minimap artwork; live width/height and relative scale remain dynamic.
local VISIBLE_RIM_INSET = 10

local function angleFromCursor()
    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx, cy = cx / scale, cy / scale
    return math.deg(math.atan2(cy - my, cx - mx))
end

function NS:UpdateMinimapPosition()
    if not self.minimapButton then return end
    local angle = math.rad(self.db.minimap.angle or 220)
    -- Measure the live minimap and account for relative scale, then remove the
    -- transparent/art margin between the Minimap frame and its visible ring.
    local button = self.minimapButton
    local scale = Minimap:GetEffectiveScale() / button:GetEffectiveScale()
    local radiusX = math.max(1, Minimap:GetWidth() / 2 - VISIBLE_RIM_INSET) * scale
    local radiusY = math.max(1, Minimap:GetHeight() / 2 - VISIBLE_RIM_INSET) * scale
    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radiusX, math.sin(angle) * radiusY)
    self.minimapButton:SetShown(not self.db.minimap.hidden)
    self.minimapButton.mapWidth = Minimap:GetWidth()
    self.minimapButton.mapHeight = Minimap:GetHeight()
    self.minimapButton.mapScale = scale
end

function NS:CreateMinimapButton()
    if self.minimapButton then return end
    local button = CreateFrame("Button", "AddonHealthManagerForeverMinimapButton", Minimap:GetParent() or UIParent)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 5)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    -- This texture has asymmetric transparent padding and is designed to be
    -- anchored from the button's top-left, as Blizzard-style minimap buttons do.
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(24, 24)
    background:SetPoint("CENTER")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", 7, -5)
    icon:SetTexture("Interface\\AddOns\\AddonHealthManagerForever\\Media\\AddonHealthManagerIcon.tga")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "RightButton" then
            NS:Scan()
            NS:Print("Scan complete.")
        else
            NS:Toggle()
        end
    end)
    button:SetScript("OnDragStart", function(self) self.dragging = true end)
    button:SetScript("OnDragStop", function(self) self.dragging = false end)
    button:SetScript("OnUpdate", function(self)
        if self.dragging then
            NS.db.minimap.angle = angleFromCursor()
            NS:UpdateMinimapPosition()
        else
            local scale = Minimap:GetEffectiveScale() / self:GetEffectiveScale()
            if self.mapWidth ~= Minimap:GetWidth() or self.mapHeight ~= Minimap:GetHeight() or self.mapScale ~= scale then
                NS:UpdateMinimapPosition()
            end
        end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Addon Health Manager: Forever", 0.85, 0.70, 0.34)
        GameTooltip:AddLine("Left-click: open diagnostics", 1, 1, 1)
        GameTooltip:AddLine("Right-click: scan now", 0.7, 0.7, 0.7)
        GameTooltip:AddLine("Drag: move this icon", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.minimapButton = button
    self:UpdateMinimapPosition()
end
