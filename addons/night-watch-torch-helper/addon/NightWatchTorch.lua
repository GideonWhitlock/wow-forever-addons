local addonName, N = ...
local fallbackIcon = "Interface\\Icons\\INV_Torch_Lit"
local macro = "/use [nocombat,nomounted,noflying,novehicleui,nodead] item:" .. N.ITEM_ID

BINDING_HEADER_NIGHTWATCHTORCH = "Night Watch Torch"
_G["BINDING_NAME_CLICK NightWatchTorchButton:LeftButton"] = "Use torch when eligible"

function N.Disarm()
    if N.button and not InCombatLockdown() then N.button:SetAttribute("type1", nil) end
end

function N.ApplyPosition()
    if InCombatLockdown() then return end
    local b = N.button
    b:SetSize(N.db.size, N.db.size)
    local maxX = math.max(0, (UIParent:GetWidth() - N.db.size) / 2)
    local maxY = math.max(0, (UIParent:GetHeight() - N.db.size) / 2 - 30)
    N.db.x = math.max(-maxX, math.min(maxX, N.db.x))
    N.db.y = math.max(-maxY, math.min(maxY, N.db.y))
    b:ClearAllPoints()
    b:SetPoint("CENTER", UIParent, "CENTER", N.db.x, N.db.y)
end

function N.Refresh()
    if not N.button or InCombatLockdown() then return end
    N.UpdateMinimap()
    N.UpdateOptions()
    local ready, reason = N.Evaluate()
    N.reason = reason
    -- Arm only for a real user click; no timer or event ever uses the item.
    N.button:SetAttribute("type1", ready and "macro" or nil)
    N.button.label:SetText(N.preview and "Drag to move - /nwt lock" or "Light torch")
    N.button:SetShown(ready or N.preview or N.dragging or false)
    if C_Item and C_Item.GetItemIconByID then
        N.button.icon:SetTexture(C_Item.GetItemIconByID(N.ITEM_ID) or fallbackIcon)
    end
end

function N.PreClick(self, mouseButton, down)
    if InCombatLockdown() then return end
    self.accepted = false
    N.Disarm()
    if mouseButton ~= "LeftButton" or down or IsShiftKeyDown() then return end
    -- Recheck everything at the actual click, including a fresh bag scan.
    local ready = N.Evaluate(true)
    if ready then
        self:SetAttribute("type1", "macro")
        self.accepted = true
    end
end

function N.PostClick(self)
    if InCombatLockdown() then return end
    if self.accepted then N.retryAfter = GetTime() + 2 end
    self.accepted = false
    N.Refresh()
end

function N.BuildUI()
    if InCombatLockdown() then return end
    local gate = CreateFrame("Frame", "NightWatchTorchGate", UIParent, "SecureHandlerStateTemplate")
    gate:SetAllPoints(UIParent)
    N.gate = gate
    local b = CreateFrame("Button", "NightWatchTorchButton", gate, "SecureActionButtonTemplate,BackdropTemplate")
    N.button = b
    b:Hide()
    b:SetFrameStrata("MEDIUM")
    b:SetClampedToScreen(true)
    b:SetMovable(true)
    b:EnableMouse(true)
    b:RegisterForClicks("AnyUp")
    b:RegisterForDrag("LeftButton")
    b:SetAttribute("useOnKeyDown", false)
    b:SetAttribute("macrotext1", macro)
    b:SetAttribute("shift-type1", "")
    b:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14, insets = { left = 3, right = 3, top = 3, bottom = 3 } })
    b:SetBackdropColor(0.06, 0.035, 0.015, 0.95)
    b:SetBackdropBorderColor(1, 0.66, 0.2, 1)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 5, -5)
    b.icon:SetPoint("BOTTOMRIGHT", -5, 5)
    b.icon:SetTexture(fallbackIcon)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.label:SetPoint("TOP", b, "BOTTOM", 0, -4)
    b.label:SetTextColor(1, 0.82, 0.45)
    b:SetScript("PreClick", N.PreClick)
    b:SetScript("PostClick", N.PostClick)
    b:SetScript("OnEnter", function()
        GameTooltip:SetOwner(b, "ANCHOR_RIGHT")
        GameTooltip:SetText("Night Watchman's Torch", 1, 0.82, 0.45)
        GameTooltip:AddLine(N.preview and "Preview only; item use is disabled." or (N.reason or ""), 1, 1, 1, true)
        GameTooltip:AddLine("Left-click to light. Shift-drag to move.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("/nwt for commands", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetScript("OnHide", function() GameTooltip:Hide() end)
    b:SetScript("OnDragStart", function()
        if InCombatLockdown() or not (N.preview or IsShiftKeyDown()) then return end
        N.dragging = true
        N.Disarm()
        b:StartMoving()
    end)
    b:SetScript("OnDragStop", function()
        if InCombatLockdown() then return end
        b:StopMovingOrSizing()
        if N.dragging then
            local x, y = b:GetCenter()
            local px, py = UIParent:GetCenter()
            N.db.x, N.db.y = x - px, y - py
            N.dragging = false
            N.retryAfter = GetTime() + 0.3
            N.ApplyPosition()
            N.Refresh()
        end
    end)
    gate:SetFrameRef("torch", b)
    gate:SetAttribute("_onstate-blocked", [[
        local button = self:GetFrameRef("torch")
        button:SetAttribute("type1", nil)
        if newstate == "1" then self:Hide() else self:Show() end
    ]])
    -- Secure state handling can hide and disarm immediately during lockdown.
    RegisterStateDriver(gate, "blocked", "[combat][dead][mounted][flying][vehicleui] 1; 0")
    N.ApplyPosition()
    N.BuildMinimap()
end

local function status()
    local ready, reason = N.Evaluate(true)
    N.Print((ready and "Ready: " or "Waiting: ") .. reason)
    N.Print("Item " .. N.ITEM_ID .. "; buffs checked by ID and name; click required.")
    if N.lastBuffID then N.Print("Active torch buff ID: " .. N.lastBuffID) end
    if N.lastError then N.Print("API detail: " .. N.lastError) end
    local ok, text = pcall(function()
        local day = C_DateAndTime and C_DateAndTime.IsDayTime and C_DateAndTime.IsDayTime()
        local weather = C_Weather and C_Weather.GetCurrentWeather and C_Weather.GetCurrentWeather()
        return "Daytime: " .. tostring(day) .. "; weather type/intensity: "
            .. (weather and (tostring(weather.type) .. "/" .. tostring(weather.intensity)) or "unavailable")
    end)
    if ok then N.Print(text) end
end

local function command(message)
    local cmd, arg = (message or ""):lower():match("^%s*(%S*)%s*(.-)%s*$")
    if cmd == "status" then status(); return end
    if cmd == "options" then N.ToggleOptions(); return end
    if cmd == "" or cmd == "help" then
        N.Print("/nwt options | unlock | lock | size 32-100 | on | off | reset | status")
        N.Print("/nwt minimap show|hide: show or hide the minimap settings icon.")
        N.Print("/nwt dim on|off: manual dim/foggy area; clears when you change zone or reload.")
        N.Print("Set an optional key in Options > Keybindings > Night Watch Torch.")
        return
    end
    if InCombatLockdown() then N.Print("Change settings after combat ends."); return end
    if cmd == "unlock" then N.preview = true
    elseif cmd == "lock" then N.preview = false
    elseif cmd == "on" then N.db.enabled = true
    elseif cmd == "off" then N.db.enabled = false; N.preview = false
    elseif cmd == "size" and tonumber(arg) then
        N.db.size = math.max(32, math.min(100, tonumber(arg)))
        N.ApplyPosition()
    elseif cmd == "dim" and (arg == "on" or arg == "off") then
        N.dimArea = arg == "on"
        N.Print("Manual dim area " .. arg .. ". All bag, buff, combat and travel checks still apply.")
    elseif cmd == "minimap" and (arg == "show" or arg == "hide") then
        N.db.minimapHidden = arg == "hide"
        N.UpdateMinimap(true)
    elseif cmd == "reset" then
        for key, value in pairs(N.DEFAULTS) do N.db[key] = value end
        N.preview, N.dimArea = false, false
        N.ApplyPosition()
        N.UpdateMinimap(true)
    else N.Print("Unknown command. Type /nwt for help."); return end
    N.Refresh()
end

local f = CreateFrame("Frame")
N.events = f
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
local events = {
    "PLAYER_ENTERING_WORLD", "PLAYER_LEAVING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
    "PLAYER_STARTED_MOVING", "PLAYER_STOPPED_MOVING", "PLAYER_MOUNT_DISPLAY_CHANGED",
    "PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED", "UNIT_AURA", "BAG_UPDATE_DELAYED",
    "BAG_UPDATE", "BAG_UPDATE_COOLDOWN", "ITEM_LOCK_CHANGED", "SPELL_UPDATE_COOLDOWN",
    "WEATHER_CHANGED", "DIEL_CYCLE_CHANGED", "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA",
    "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE",
}
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then N.InitializeDB() end
        return
    end
    if event == "PLAYER_LOGIN" then
        if not N.db then N.InitializeDB() end
        N.BuildUI()
        for _, name in ipairs(events) do
            -- Beta events may be renamed; periodic refresh still provides checks.
            pcall(f.RegisterEvent, f, name)
        end
        SLASH_NIGHTWATCHTORCH1 = "/nwt"
        SLASH_NIGHTWATCHTORCH2 = "/nightwatchtorch"
        SlashCmdList.NIGHTWATCHTORCH = command
        N.Print("Loaded. Click the torch when it appears. /nwt for commands.")
    elseif event == "UNIT_AURA" and arg1 ~= "player" then return
    elseif event == "PLAYER_STARTED_MOVING" then N.movementActive = true; N.stillSince = nil
    elseif event == "PLAYER_STOPPED_MOVING" then N.movementActive = false; N.stillSince = nil
    elseif event == "PLAYER_LEAVING_WORLD" then N.worldReady = false; N.stillSince = nil
    elseif event == "PLAYER_ENTERING_WORLD" then
        N.worldReady, N.bagsDirty = true, true
        N.stillSince, N.movementActive, N.dimArea = nil, false, false
    elseif event:find("^ZONE_CHANGED") then N.dimArea = false
    elseif event:find("^BAG_UPDATE") or event == "ITEM_LOCK_CHANGED" then N.bagsDirty = true
    elseif event == "PLAYER_REGEN_DISABLED" then N.stillSince = nil
    elseif event == "PLAYER_REGEN_ENABLED" then
        if not N.button then N.BuildUI() end
        if N.dragging then N.button:StopMovingOrSizing(); N.dragging = false; N.ApplyPosition() end
    end
    N.Refresh()
end)
local elapsedTotal = 0
f:SetScript("OnUpdate", function(_, elapsed)
    elapsedTotal = elapsedTotal + elapsed
    if elapsedTotal >= 0.2 then elapsedTotal = 0; N.Refresh() end
end)
