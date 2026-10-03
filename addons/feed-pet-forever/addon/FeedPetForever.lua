local addonName, F = ...
local loader = CreateFrame("Frame")
F.loader = loader
loader:RegisterEvent("ADDON_LOADED")

local function registerEvents()
    for _, event in ipairs({"PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
        "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST", "PLAYER_CONTROL_LOST", "PLAYER_CONTROL_GAINED",
        "PLAYER_MOUNT_DISPLAY_CHANGED", "BAG_UPDATE_DELAYED", "ITEM_LOCK_CHANGED", "GET_ITEM_INFO_RECEIVED",
        "SPELLS_CHANGED", "SPELL_UPDATE_COOLDOWN", "PET_ATTACK_START", "PET_ATTACK_STOP", "UI_SCALE_CHANGED"}) do
        loader:RegisterEvent(event)
    end
    for _, event in ipairs({"UNIT_PET", "UNIT_HAPPINESS", "UNIT_HEALTH", "UNIT_FLAGS", "UNIT_AURA",
        "UNIT_SPELLCAST_SUCCEEDED"}) do
        loader:RegisterUnitEvent(event, "player", "pet")
    end
end

loader:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end
        loader:UnregisterEvent("ADDON_LOADED")
        F.LoadSettings()
        F.supported = F.CheckAPIs()
        -- A reload may happen in combat. Defer all protected frame construction.
        loader:RegisterEvent("PLAYER_REGEN_ENABLED")
        loader:RegisterEvent("PLAYER_ENTERING_WORLD")
        SLASH_FEEDPETFOREVER1 = "/fpf"
        SLASH_FEEDPETFOREVER2 = "/feedpetforever"
        SlashCmdList.FEEDPETFOREVER = function(message)
            if not F.button then F.Print("Waiting for the client to finish loading outside combat."); return end
            F.Command(message)
        end
        if not F.supported then
            F.Print("This build needs the Forever pet APIs. Alerts are disabled; use /fpf status for client details.")
        end
    end
    if not F.db then return end
    if event == "PLAYER_REGEN_DISABLED" then
        -- No protected frame writes here. The secure parent hides both alert states.
        F.unlocked, F.previewNoFood = false, false
        if F.options then F.options:Hide() end
        F.bagsDirty = true
        return
    end
    if event == "BAG_UPDATE_DELAYED" or event == "ITEM_LOCK_CHANGED" or event == "GET_ITEM_INFO_RECEIVED"
        or event == "UNIT_PET" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
        F.bagsDirty = true
    end
    if event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" and arg3 == F.FEED_SPELL then
        F.waitUntil = GetTime() + 1 -- Short acknowledgement gap, not a long blind feeding timer.
        F.bagsDirty = true
    end
    if InCombatLockdown() or F.clickInProgress then return end
    if not F.button then
        F.BuildUI()
        registerEvents()
        F.Print("Loaded. /fpf opens settings; Shift-drag moves the icon.")
        -- Cheap state checks only; scans occur on bag/pet changes or a real click.
        F.ticker = C_Timer.NewTicker(0.25, function()
            if not InCombatLockdown() then F.Refresh(); F.UpdateMinimap() end
        end)
    end
    if F.dragging and event == "PLAYER_REGEN_ENABLED" then
        F.button:StopMovingOrSizing(); F.dragging = false; F.ApplyLayout()
    end
    if event == "UI_SCALE_CHANGED" then F.ApplyLayout(); F.UpdateMinimap(true) end
    F.Refresh()
end)
