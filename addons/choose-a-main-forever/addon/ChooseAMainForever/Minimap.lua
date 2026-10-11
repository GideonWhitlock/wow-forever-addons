local _, NS = ...
local VISIBLE_RIM_INSET = 10

local function angleFromCursor()
    local mx, my = Minimap:GetCenter()
    local scale = Minimap:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    return math.deg(math.atan2(cy / scale - my, cx / scale - mx))
end

function NS:UpdateMinimapPosition()
    if not self.minimapButton or not self.db then return end
    local button = self.minimapButton
    local angle = math.rad(self.db.minimap.angle or 220)
    local scale = Minimap:GetEffectiveScale() / button:GetEffectiveScale()
    local radiusX = math.max(1, Minimap:GetWidth()/2 - VISIBLE_RIM_INSET) * scale
    local radiusY = math.max(1, Minimap:GetHeight()/2 - VISIBLE_RIM_INSET) * scale
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle)*radiusX, math.sin(angle)*radiusY)
    button:SetShown(not self.db.minimap.hidden)
end

function NS:CreateMinimapButton()
    if self.minimapButton then return end
    local button = CreateFrame("Button", "ChooseAMainForeverMinimapButton", Minimap:GetParent() or UIParent)
    button:SetSize(32,32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel()+5)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    local border = button:CreateTexture(nil,"OVERLAY")
    border:SetSize(54,54); border:SetPoint("TOPLEFT"); border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    local background = button:CreateTexture(nil,"BACKGROUND")
    background:SetSize(24,24); background:SetPoint("CENTER"); background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    local icon = button:CreateTexture(nil,"ARTWORK")
    icon:SetSize(20,20); icon:SetPoint("TOPLEFT",7,-5); icon:SetTexture("Interface\\AddOns\\ChooseAMainForever\\Media\\ChooseAMainForeverIcon.tga"); icon:SetTexCoord(.08,.92,.08,.92)
    button:RegisterForClicks("LeftButtonUp","RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnClick", function(_, mouse) if mouse == "RightButton" and NS.db.lastResult then NS:ShowResults(NS.db.lastResult) else NS:Toggle() end end)
    button:SetScript("OnDragStart", function(self) self.dragging=true end)
    button:SetScript("OnDragStop", function(self) self.dragging=false end)
    button:SetScript("OnUpdate", function(self) if self.dragging then NS.db.minimap.angle=angleFromCursor(); NS:UpdateMinimapPosition() end end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self,"ANCHOR_LEFT"); GameTooltip:SetText(NS.title,.85,.70,.34)
        GameTooltip:AddLine("Left-click: open assessment",1,1,1); GameTooltip:AddLine("Right-click: previous result",.7,.7,.7); GameTooltip:AddLine("Drag: move this icon",.7,.7,.7); GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.minimapButton=button
    self:UpdateMinimapPosition()
end
