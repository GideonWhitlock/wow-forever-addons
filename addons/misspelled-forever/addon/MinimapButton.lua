-- Misspelled: Forever minimap button

local Misspelled = _G.Misspelled
if not Misspelled then return end

local BUTTON_RADIUS = 80
local DEFAULT_ANGLE = 220

local function SetButtonPosition(button)
	local angle = math.rad(MisspelledForeverDB.MinimapAngle or DEFAULT_ANGLE)
	button:ClearAllPoints()
	button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * BUTTON_RADIUS, math.sin(angle) * BUTTON_RADIUS)
end

local function UpdateDragPosition(button)
	local minimapX, minimapY = Minimap:GetCenter()
	local scale = Minimap:GetEffectiveScale()
	local cursorX, cursorY = GetCursorPosition()
	if not minimapX or not minimapY or not scale or scale == 0 then return end

	cursorX, cursorY = cursorX / scale, cursorY / scale
	local angle = math.deg(math.atan2(cursorY - minimapY, cursorX - minimapX))
	MisspelledForeverDB.MinimapAngle = angle
	SetButtonPosition(button)
end

function Misspelled:UpdateMinimapButtonVisibility()
	if not self.MinimapButton then return end
	if MisspelledForeverDB.ShowMinimapButton then
		self.MinimapButton:Show()
	else
		self.MinimapButton:Hide()
	end
	if MisspelledForever_cfgShowMinimap then
		MisspelledForever_cfgShowMinimap:SetChecked(MisspelledForeverDB.ShowMinimapButton)
	end
end

function Misspelled:ToggleMinimapButton()
	MisspelledForeverDB.ShowMinimapButton = not MisspelledForeverDB.ShowMinimapButton
	self:UpdateMinimapButtonVisibility()
	self:print("Misspelled: Forever minimap button " .. (MisspelledForeverDB.ShowMinimapButton and "shown." or "hidden."))
end

function Misspelled:ResetMinimapButton()
	MisspelledForeverDB.MinimapAngle = DEFAULT_ANGLE
	if self.MinimapButton then
		SetButtonPosition(self.MinimapButton)
	end
	self:print("Misspelled: Forever minimap button position reset.")
end

function Misspelled:CreateMinimapButton()
	if self.MinimapButton or not Minimap then return end

	local button = CreateFrame("Button", "MisspelledForeverMinimapButton", Minimap)
	button:SetSize(33, 33)
	button:SetFrameStrata("MEDIUM")
	button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:RegisterForDrag("LeftButton")

	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetSize(24, 24)
	background:SetPoint("CENTER")
	background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetSize(22, 22)
	icon:SetPoint("CENTER")
	icon:SetTexture("Interface\\AddOns\\MisspelledForever\\Media\\MinimapIcon")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon = icon

	local border = button:CreateTexture(nil, "OVERLAY")
	border:SetSize(54, 54)
	border:SetPoint("TOPLEFT")
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

	local highlight = button:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetSize(24, 24)
	highlight:SetPoint("CENTER")
	highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	highlight:SetBlendMode("ADD")

	button:SetScript("OnClick", function(_, mouseButton)
		if mouseButton == "RightButton" then
			Misspelled:EditUserDict()
		else
			Misspelled:OpenSettings()
		end
	end)

	button:SetScript("OnDragStart", function(self)
		self:SetScript("OnUpdate", UpdateDragPosition)
	end)

	button:SetScript("OnDragStop", function(self)
		self:SetScript("OnUpdate", nil)
		UpdateDragPosition(self)
	end)

	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine("Misspelled: Forever", 1, 0.82, 0)
		GameTooltip:AddLine("Left-click: Open settings", 1, 1, 1)
		GameTooltip:AddLine("Right-click: Personal dictionary", 1, 1, 1)
		GameTooltip:AddLine("Drag: Move around the minimap", 0.75, 0.75, 0.75)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	self.MinimapButton = button
	SetButtonPosition(button)
	self:UpdateMinimapButtonVisibility()
end
