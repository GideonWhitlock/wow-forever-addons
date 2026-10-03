local _, F = ...

F.VERSION = "1.0.14"
F.MIN_SIZE = 20
F.MAX_SIZE = 64
F.MIN_SPACING = 0
F.MAX_SPACING = 16
F.SIZE_STEPS = {24, 32, 40, 48, 56, 64}

local DEFAULTS = {
    x = 0,
    y = 180,
    size = 32,
    spacing = 4,
    vertical = false,
    expanded = false,
    showBackground = true,
    enabled = true,
}

local blockedNames = {
    AddonCompartmentFrame = true,
    BattlefieldMinimap = true,
    ExpansionLandingPageMinimapButton = true,
    GameTimeFrame = true,
    GarrisonLandingPageMinimapButton = true,
    MiniMapInstanceDifficulty = true,
    MiniMapLFGFrame = true,
    MiniMapMailFrame = true,
    MiniMapTracking = true,
    MiniMapTrackingButton = true,
    MiniMapVoiceChatFrame = true,
    MiniMapWorldMapButton = true,
    MinimapBackdrop = true,
    MinimapCluster = true,
    MinimapNorthTag = true,
    MinimapToggleButton = true,
    MinimapZoomIn = true,
    MinimapZoomOut = true,
    MinimapZoneTextButton = true,
    QueueStatusMinimapButton = true,
    TimeManagerClockButton = true,
}

local blockedPatterns = {
    "^QuestieFrame%d+$",
    "^GatherMatePin",
    "^HandyNotesPin",
    "^pfMiniMapPin",
}

local function isIgnoredByButtonBag(name)
    if not name or type(MBB_Ignore) ~= "table" then return false end
    for key, value in pairs(MBB_Ignore) do
        if key == name or value == name then return true end
    end
    return false
end

local function isMinimapRelative(frame)
    local current = frame and frame:GetParent()
    local depth = 0
    while current and depth < 8 do
        if current == Minimap or current == MinimapCluster then return true end
        current = current.GetParent and current:GetParent() or nil
        depth = depth + 1
    end
    if not frame or not frame.GetNumPoints then return false end
    for index = 1, frame:GetNumPoints() do
        local _, relativeTo = frame:GetPoint(index)
        current, depth = relativeTo, 0
        while current and depth < 8 do
            if current == Minimap or current == MinimapCluster then return true end
            current = current.GetParent and current:GetParent() or nil
            depth = depth + 1
        end
    end
    return false
end

function F.IsBlizzardMinimapControl(button)
    if not button then return false end
    if button == GameTimeFrame or button == TimeManagerClockButton or
            button == MiniMapTracking or button == MiniMapTrackingButton or
            button == MiniMapWorldMapButton or button == MinimapZoomIn or
            button == MinimapZoomOut then
        return true
    end
    if Minimap and (button == Minimap.ZoomIn or button == Minimap.ZoomOut or
            button == Minimap.Tracking or button == Minimap.WorldMapButton) then
        return true
    end
    return false
end

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < 100000
end

function F.Clamp(value, low, high)
    value = tonumber(value) or low
    return math.max(low, math.min(high, value))
end

function F.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc66Minimap Button: Forever:|r " .. tostring(message))
end

function F.LoadSettings()
    if type(MinimapButtonForeverDB) ~= "table" then MinimapButtonForeverDB = {} end
    F.db = MinimapButtonForeverDB
    for key, value in pairs(DEFAULTS) do
        if F.db[key] == nil then F.db[key] = value end
    end
    F.db.x = finite(F.db.x) and F.db.x or DEFAULTS.x
    F.db.y = finite(F.db.y) and F.db.y or DEFAULTS.y
    F.db.size = math.floor(F.Clamp(F.db.size, F.MIN_SIZE, F.MAX_SIZE) + 0.5)
    F.db.spacing = math.floor(F.Clamp(F.db.spacing, F.MIN_SPACING, F.MAX_SPACING) + 0.5)
    if type(F.db.vertical) ~= "boolean" then F.db.vertical = DEFAULTS.vertical end
    if type(F.db.expanded) ~= "boolean" then F.db.expanded = DEFAULTS.expanded end
    if type(F.db.showBackground) ~= "boolean" then F.db.showBackground = DEFAULTS.showBackground end
    if type(F.db.enabled) ~= "boolean" then F.db.enabled = DEFAULTS.enabled end
end

function F.IsCollectable(button)
    if not button or button == F.launcher or button == F.container or button == F.options then return false end
    if F.IsBlizzardMinimapControl(button) then return false end
    if button.IsForbidden and button:IsForbidden() then return false end
    if button.IsProtected and button:IsProtected() then return false end
    if not button.GetObjectType or button:GetObjectType() ~= "Button" then return false end
    local name = button.GetName and button:GetName()
    if name and (blockedNames[name] or name:match("^MinimapButtonForever")) then return false end
    if isIgnoredByButtonBag(name) then return false end
    if name then
        for _, pattern in ipairs(blockedPatterns) do
            if name:match(pattern) then return false end
        end
    end
    local width, height = button:GetWidth() or 0, button:GetHeight() or 0
    if width < 8 or height < 8 or width > 80 or height > 80 then return false end
    if not isMinimapRelative(button) then return false end
    return true
end

function F.CaptureButton(button)
    local name = button:GetName()
    local icon = button.icon
    local iconR, iconG, iconB, iconA
    if icon and icon.GetVertexColor then iconR, iconG, iconB, iconA = icon:GetVertexColor() end
    local info = {
        button = button,
        parent = button:GetParent(),
        width = button:GetWidth(),
        height = button:GetHeight(),
        scale = button:GetScale(),
        strata = button:GetFrameStrata(),
        level = button:GetFrameLevel(),
        points = {},
        alpha = button:GetAlpha(),
        onShow = button:GetScript("OnShow"),
        showOnMouseover = button.showOnMouseover,
        icon = icon,
        iconR = iconR,
        iconG = iconG,
        iconB = iconB,
        iconA = iconA,
        iconAlpha = icon and icon.GetAlpha and icon:GetAlpha() or nil,
        iconDesaturated = icon and icon.IsDesaturated and icon:IsDesaturated() or nil,
        isLibDBIcon = name and name:match("^LibDBIcon10_") and true or false,
        forceVisible = button:IsShown() or
            (button.db and button.db.hide == false) or false,
        order = name or tostring(button),
    }
    for index = 1, button:GetNumPoints() do
        local point, relativeTo, relativePoint, x, y = button:GetPoint(index)
        info.points[#info.points + 1] = {point, relativeTo, relativePoint, x, y}
    end
    return info
end

function F.RestoreButton(info)
    local button = info and info.button
    if not button then return end
    if info.isLibDBIcon then
        if button.SetFixedFrameLevel then button:SetFixedFrameLevel(false) end
        if button.SetFixedFrameStrata then button:SetFixedFrameStrata(false) end
    end
    button:SetParent(info.parent)
    button:ClearAllPoints()
    button:SetSize(info.width, info.height)
    button:SetScale(info.scale)
    button:SetAlpha(info.alpha or 1)
    button:SetFrameStrata(info.strata)
    button:SetFrameLevel(info.level)
    if info.isLibDBIcon then
        if button.SetFixedFrameLevel then button:SetFixedFrameLevel(true) end
        if button.SetFixedFrameStrata then button:SetFixedFrameStrata(true) end
    end
    button.showOnMouseover = info.showOnMouseover
    button:SetScript("OnShow", info.onShow)
    if info.isLibDBIcon and button.fadeOut and button.fadeOut.SetToFinalAlpha then
        button.fadeOut:SetToFinalAlpha(true)
    end
    if info.icon and info.icon.SetVertexColor and info.iconR then
        info.icon:SetVertexColor(info.iconR, info.iconG, info.iconB, info.iconA or 1)
        if info.icon.SetAlpha and info.iconAlpha then info.icon:SetAlpha(info.iconAlpha) end
        if info.icon.SetDesaturated and info.iconDesaturated ~= nil then
            info.icon:SetDesaturated(info.iconDesaturated)
        end
    end
    for _, point in ipairs(info.points) do
        button:SetPoint(point[1], point[2], point[3], point[4], point[5])
    end
end

function F.BrightenButton(info)
    local button = info and info.button
    if not button then return end
    if button.fadeOut and button.fadeOut.Stop then button.fadeOut:Stop() end
    if info.isLibDBIcon and button.fadeOut and button.fadeOut.SetToFinalAlpha then
        button.fadeOut:SetToFinalAlpha(false)
    end
    button.showOnMouseover = false
    button:SetAlpha(1)
    if info.icon then
        if info.icon.SetAlpha then info.icon:SetAlpha(1) end
        if info.icon.SetVertexColor then info.icon:SetVertexColor(1, 1, 1, 1) end
        if info.icon.SetDesaturated then info.icon:SetDesaturated(false) end
    end
end

function F.SetSize(value)
    if InCombatLockdown() then
        F.Print("Icon sizes can be changed after combat.")
        return
    end
    F.db.size = math.floor(F.Clamp(value, F.MIN_SIZE, F.MAX_SIZE) + 0.5)
    F.Layout()
    F.SyncOptions()
end

function F.SetSpacing(value)
    if InCombatLockdown() then return end
    F.db.spacing = math.floor(F.Clamp(value, F.MIN_SPACING, F.MAX_SPACING) + 0.5)
    F.Layout()
    F.SyncOptions()
end

function F.ResetLayout()
    if InCombatLockdown() then return end
    F.db.x, F.db.y = DEFAULTS.x, DEFAULTS.y
    F.db.size, F.db.spacing = DEFAULTS.size, DEFAULTS.spacing
    F.db.vertical, F.db.expanded, F.db.showBackground, F.db.enabled = false, false, true, true
    F.ApplyPosition()
    F.ScanButtons()
    F.Layout()
    F.SyncOptions()
    F.Print("Layout reset.")
end

function F.Command(message)
    local command, value = tostring(message or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    if command == "" or command == "settings" then
        F.ToggleOptions()
    elseif command == "horizontal" then
        F.db.vertical = false; F.Layout(); F.SyncOptions()
    elseif command == "vertical" then
        F.db.vertical = true; F.Layout(); F.SyncOptions()
    elseif command == "size" and tonumber(value) then
        F.SetSize(value)
    elseif command == "spacing" and tonumber(value) then
        F.SetSpacing(value)
    elseif command == "scan" then
        F.ScanButtons(true)
    elseif command == "reset" then
        F.ResetLayout()
    elseif command == "status" then
        local count = F.collected and #F.collected or 0
        F.Print("Version " .. F.VERSION .. "; " .. count .. " button(s); " ..
            (F.db.vertical and "vertical" or "horizontal") .. "; size " .. F.db.size .. ".")
    else
        F.Print("Commands: /mbf, /mbf horizontal, /mbf vertical, /mbf size 40, /mbf spacing 4, /mbf scan, /mbf reset, /mbf status")
    end
end
