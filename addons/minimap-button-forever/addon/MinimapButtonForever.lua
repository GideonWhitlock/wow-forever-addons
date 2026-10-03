local addonName, F = ...
local loader = CreateFrame("Frame")
F.loader = loader

loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:RegisterEvent("PLAYER_REGEN_ENABLED")
loader:RegisterEvent("PLAYER_REGEN_DISABLED")
loader:RegisterEvent("UI_SCALE_CHANGED")

local function initialise()
    if F.ready or InCombatLockdown() then return end
    F.BuildUI()
    F.ScanButtons()
    F.ready = true
    F.ticker = C_Timer.NewTicker(2, function()
        if not InCombatLockdown() and not F.dragging then F.ScanButtons(); F.Layout() end
    end)
    F.Print("Loaded. Left-click shows or hides icons, right-click opens settings, and Alt-drag moves the controller.")
end

loader:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            F.LoadSettings()
            SLASH_MINIMAPBUTTONFOREVER1 = "/mbf"
            SLASH_MINIMAPBUTTONFOREVER2 = "/minimapbuttonforever"
            SlashCmdList.MINIMAPBUTTONFOREVER = function(message)
                if not F.ready then F.Print("Waiting for the game to finish loading outside combat."); return end
                F.Command(message)
            end
            initialise()
        elseif F.ready and F.db.enabled then
            F.ScanButtons()
        end
        return
    end
    if not F.db then return end
    if event == "PLAYER_REGEN_DISABLED" then
        if F.dragging then
            F.container:SetScript("OnUpdate", nil)
            F.dragging = false
            F.dragCursorX, F.dragCursorY = nil, nil
            F.dragContainerX, F.dragContainerY = nil, nil
            F.SavePosition()
        end
        if F.options then F.options:Hide() end
        return
    end
    initialise()
    if not F.ready or InCombatLockdown() then return end
    if event == "UI_SCALE_CHANGED" then F.ApplyPosition() end
    F.ScanButtons()
end)
