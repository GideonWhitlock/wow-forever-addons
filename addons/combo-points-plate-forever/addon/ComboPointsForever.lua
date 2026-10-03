local ADDON_NAME = ...

local CPF = CreateFrame("Frame")
local displays = {}
local testPoints
local minimapButton

local COMBO_POWER = 4
if Enum and Enum.PowerType and Enum.PowerType.ComboPoints then
    COMBO_POWER = Enum.PowerType.ComboPoints
end

local defaults = {
    scale = 1,
    offset = 7,
    spacing = 1,
    showEmpty = true,
    minimapAngle = 225,
    minimapHidden = false,
}

local POINT_TEXTURE = "Interface\\AddOns\\ComboPointsForever\\Media\\ComboPoint"
local MINIMAP_TEXTURE = "Interface\\AddOns\\ComboPointsForever\\Media\\ComboPointMinimap"

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffc928Combo Points: Forever:|r " .. message)
end

local function Clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function CopyDefaults()
    if type(ComboPointsForeverDB) ~= "table" then
        ComboPointsForeverDB = {}
    end

    for key, value in pairs(defaults) do
        if ComboPointsForeverDB[key] == nil then
            ComboPointsForeverDB[key] = value
        end
    end
end

local function GetPointTexture()
    return POINT_TEXTURE
end

local function GetComboPoints()
    if testPoints then
        return testPoints
    end

    -- Forever and older clients associate combo points with the target.
    if type(_G.GetComboPoints) == "function" then
        local points = _G.GetComboPoints("player", "target")
        if type(points) == "number" then
            return points
        end
    end

    -- Newer resource implementations keep combo points on the player.
    if type(UnitPower) == "function" then
        return UnitPower("player", COMBO_POWER) or 0
    end

    return 0
end

local function GetMaximumPoints(points)
    local maximum = 0
    if type(UnitPowerMax) == "function" then
        maximum = UnitPowerMax("player", COMBO_POWER) or 0
    end

    if maximum <= 0 then maximum = 5 end
    if points > maximum then maximum = points end
    return Clamp(maximum, 1, 10)
end

local function CreatePoint(display, index)
    local point = CreateFrame("Frame", nil, display)
    point:SetSize(24, 24)

    point.glow = point:CreateTexture(nil, "BACKGROUND")
    point.glow:SetPoint("CENTER")
    point.glow:SetSize(30, 30)
    point.glow:SetTexture(GetPointTexture())
    point.glow:SetBlendMode("ADD")
    point.glow:SetAlpha(0)

    point.icon = point:CreateTexture(nil, "ARTWORK")
    point.icon:SetAllPoints()
    point.icon:SetTexture(GetPointTexture())

    point.flare = point.glow:CreateAnimationGroup()
    local fade = point.flare:CreateAnimation("Alpha")
    fade:SetFromAlpha(0.95)
    fade:SetToAlpha(0)
    fade:SetDuration(0.38)
    fade:SetSmoothing("OUT")
    point.flare:SetScript("OnPlay", function()
        point.glow:SetAlpha(0.95)
    end)
    point.flare:SetScript("OnFinished", function()
        point.glow:SetAlpha(0)
    end)

    display.points[index] = point
    return point
end

local function CreateDisplay(plate)
    local display = CreateFrame("Frame", nil, plate)
    display:SetFrameStrata("HIGH")
    display:SetFrameLevel((plate:GetFrameLevel() or 0) + 20)
    display:EnableMouse(false)
    display.points = {}
    display.lastPoints = 0
    display:Hide()
    displays[plate] = display
    return display
end

local function LayoutDisplay(display, maximum)
    local scale = ComboPointsForeverDB.scale
    local pointSize = 24 * scale
    local step = pointSize + (ComboPointsForeverDB.spacing * scale)
    local width = pointSize + ((maximum - 1) * step)

    display:SetSize(width, pointSize)
    display:ClearAllPoints()
    display:SetPoint("BOTTOM", display:GetParent(), "TOP", 0, ComboPointsForeverDB.offset)

    for index = 1, maximum do
        local point = display.points[index] or CreatePoint(display, index)
        point:SetSize(pointSize, pointSize)
        point.glow:SetSize(pointSize * 1.35, pointSize * 1.35)
        point:ClearAllPoints()
        point:SetPoint("LEFT", display, "LEFT", (index - 1) * step, 0)
        point:Show()
    end

    for index = maximum + 1, #display.points do
        display.points[index]:Hide()
    end
end

local function PaintDisplay(display, points, maximum)
    local texture = GetPointTexture()
    for index = 1, maximum do
        local point = display.points[index]
        point.icon:SetTexture(texture)
        point.glow:SetTexture(texture)

        if index <= points then
            point.icon:SetDesaturated(false)
            point.icon:SetVertexColor(1, 1, 1, 1)
            point.icon:SetAlpha(1)
            if index > display.lastPoints then
                point.flare:Stop()
                point.flare:Play()
            end
        elseif ComboPointsForeverDB.showEmpty then
            point.flare:Stop()
            point.glow:SetAlpha(0)
            point.icon:SetDesaturated(true)
            point.icon:SetVertexColor(0.28, 0.25, 0.22, 1)
            point.icon:SetAlpha(0.42)
        else
            point.flare:Stop()
            point.glow:SetAlpha(0)
            point.icon:SetAlpha(0)
        end
    end

    display.lastPoints = points
end

local function HideDisplays(exceptPlate)
    for plate, display in pairs(displays) do
        if plate ~= exceptPlate then
            display:Hide()
            display.lastPoints = 0
        end
    end
end

local function IsValidTarget()
    if not UnitExists("target") then return false end
    if not testPoints and not UnitCanAttack("player", "target") then return false end
    return true
end

local function Refresh()
    if not ComboPointsForeverDB or not IsValidTarget() then
        HideDisplays()
        return
    end
    if not C_NamePlate or not C_NamePlate.GetNamePlateForUnit then
        HideDisplays()
        return
    end

    local plate = C_NamePlate.GetNamePlateForUnit("target")
    if not plate then
        HideDisplays()
        return
    end

    HideDisplays(plate)

    local points = Clamp(GetComboPoints(), 0, 10)
    if points <= 0 and not testPoints then
        local oldDisplay = displays[plate]
        if oldDisplay then
            oldDisplay:Hide()
            oldDisplay.lastPoints = 0
        end
        return
    end

    local maximum = GetMaximumPoints(points)
    local display = displays[plate] or CreateDisplay(plate)
    LayoutDisplay(display, maximum)
    PaintDisplay(display, points, maximum)
    display:Show()
end

local function RefreshSoon()
    Refresh()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, Refresh)
    end
end

local function ShowTestPreview()
    testPoints = GetMaximumPoints(5)
    Refresh()
    Print("Showing a full combo-point preview on your target nameplate for 8 seconds.")
    if C_Timer and C_Timer.After then
        C_Timer.After(8, function()
            testPoints = nil
            Refresh()
        end)
    end
end

local function UpdateMinimapButton()
    if not minimapButton or not Minimap or not ComboPointsForeverDB then return end

    local width = Minimap:GetWidth() or 140
    local height = Minimap:GetHeight() or 140
    local scale = Minimap:GetEffectiveScale() / minimapButton:GetEffectiveScale()
    local angle = math.rad(ComboPointsForeverDB.minimapAngle or defaults.minimapAngle)

    minimapButton:ClearAllPoints()
    minimapButton:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        math.cos(angle) * (width * scale / 2 + 4),
        math.sin(angle) * (height * scale / 2 + 4)
    )

    if ComboPointsForeverDB.minimapHidden then
        minimapButton:Hide()
    else
        minimapButton:Show()
    end
end

local function CreateMinimapButton()
    if minimapButton or not Minimap then return end

    local button = CreateFrame("Button", "ComboPointsForeverMinimapButton", UIParent)
    minimapButton = button
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel((Minimap:GetFrameLevel() or 0) + 5)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", 7, -5)
    icon:SetTexture(MINIMAP_TEXTURE)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Combo Points: Forever", 1, 0.82, 0.45)
        GameTooltip:AddLine("Left-click: toggle empty combo-point slots", 1, 1, 1)
        GameTooltip:AddLine("Right-click: preview a full combo-point row", 1, 1, 1)
        GameTooltip:AddLine("Drag: move this minimap icon", 0.75, 0.75, 0.75)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnClick", function(_, mouseButton)
        if GetTime() < (button.ignoreClickUntil or 0) then return end
        if mouseButton == "RightButton" then
            ShowTestPreview()
        else
            ComboPointsForeverDB.showEmpty = not ComboPointsForeverDB.showEmpty
            Refresh()
            Print("Empty combo-point slots are now " .. (ComboPointsForeverDB.showEmpty and "shown." or "hidden."))
        end
    end)

    local function StopDragging()
        button:SetScript("OnUpdate", nil)
        button.ignoreClickUntil = GetTime() + 0.2
    end

    button:SetScript("OnDragStart", function()
        GameTooltip:Hide()
        button:SetScript("OnUpdate", function()
            local x, y = GetCursorPosition()
            local centerX, centerY = Minimap:GetCenter()
            if not centerX or not centerY then return end
            local scale = Minimap:GetEffectiveScale()
            ComboPointsForeverDB.minimapAngle = math.deg(math.atan2(y / scale - centerY, x / scale - centerX)) % 360
            UpdateMinimapButton()
        end)
    end)
    button:SetScript("OnDragStop", StopDragging)

    UpdateMinimapButton()
end

local function ShowHelp()
    Print("/cpf test | scale 0.6-2 | offset -20-80 | spacing 0-8 | empty | minimap | reset")
end

SLASH_COMBOPOINTSFOREVER1 = "/cpf"
SlashCmdList.COMBOPOINTSFOREVER = function(message)
    local command, argument = string.match(string.lower(message or ""), "^%s*(%S*)%s*(.-)%s*$")

    if command == "test" then
        ShowTestPreview()
    elseif command == "scale" then
        local value = tonumber(argument)
        if not value then ShowHelp() return end
        ComboPointsForeverDB.scale = Clamp(value, 0.6, 2)
        Refresh()
        Print("Scale set to " .. ComboPointsForeverDB.scale .. ".")
    elseif command == "offset" then
        local value = tonumber(argument)
        if not value then ShowHelp() return end
        ComboPointsForeverDB.offset = Clamp(value, -20, 80)
        Refresh()
        Print("Vertical offset set to " .. ComboPointsForeverDB.offset .. ".")
    elseif command == "spacing" then
        local value = tonumber(argument)
        if not value then ShowHelp() return end
        ComboPointsForeverDB.spacing = Clamp(value, 0, 8)
        Refresh()
        Print("Spacing set to " .. ComboPointsForeverDB.spacing .. ".")
    elseif command == "empty" then
        ComboPointsForeverDB.showEmpty = not ComboPointsForeverDB.showEmpty
        Refresh()
        Print("Empty combo-point slots are now " .. (ComboPointsForeverDB.showEmpty and "shown." or "hidden."))
    elseif command == "minimap" then
        ComboPointsForeverDB.minimapHidden = not ComboPointsForeverDB.minimapHidden
        UpdateMinimapButton()
        Print("Minimap icon is now " .. (ComboPointsForeverDB.minimapHidden and "hidden. Use /cpf minimap to show it again." or "shown."))
    elseif command == "reset" then
        for key, value in pairs(defaults) do
            ComboPointsForeverDB[key] = value
        end
        UpdateMinimapButton()
        Refresh()
        Print("Settings reset.")
    else
        ShowHelp()
    end
end

CPF:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then return end
        CopyDefaults()
        CreateMinimapButton()
        CPF:UnregisterEvent("ADDON_LOADED")
        RefreshSoon()
    elseif event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_FREQUENT" then
        if arg1 == "player" and (not arg2 or arg2 == "COMBO_POINTS" or arg2 == "COMBOPOINTS") then
            RefreshSoon()
        end
    elseif event == "UNIT_MAXPOWER" then
        if arg1 == "player" then RefreshSoon() end
    else
        if event == "PLAYER_ENTERING_WORLD" then
            CreateMinimapButton()
            UpdateMinimapButton()
        end
        RefreshSoon()
    end
end)

local function RegisterCompatibleEvent(event)
    -- Forever bridges APIs from several client generations. Optional events are
    -- registered defensively so one retired event cannot stop the add-on loading.
    pcall(CPF.RegisterEvent, CPF, event)
end

RegisterCompatibleEvent("ADDON_LOADED")
RegisterCompatibleEvent("PLAYER_ENTERING_WORLD")
RegisterCompatibleEvent("PLAYER_TARGET_CHANGED")
RegisterCompatibleEvent("NAME_PLATE_UNIT_ADDED")
RegisterCompatibleEvent("NAME_PLATE_UNIT_REMOVED")
RegisterCompatibleEvent("UNIT_POWER_UPDATE")
RegisterCompatibleEvent("UNIT_POWER_FREQUENT")
RegisterCompatibleEvent("UNIT_MAXPOWER")
RegisterCompatibleEvent("UNIT_COMBO_POINTS")
RegisterCompatibleEvent("SPELLS_CHANGED")
