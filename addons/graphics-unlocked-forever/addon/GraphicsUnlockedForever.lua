local addonName, EGF = ...

local frame = CreateFrame("Frame")

local function help()
    EGF.Print("Commands: /guf, /guf list, /guf preset <potato|low|medium|high|ufo|enhanced|normal>, /guf set <id> <value>, /guf reset <id|all>, /guf minimap, /guf status")
end

local function command(message)
    local action, remainder = tostring(message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    action = action:lower()
    if action == "" or action == "settings" or action == "open" then
        EGF.ToggleOptions()
    elseif action == "list" then
        if #EGF.settings == 0 then EGF.Print(EGF.CATALOG_STATUS) return end
        for _, definition in ipairs(EGF.settings) do
            EGF.Print(definition.id .. " (" .. definition.cvar .. ")")
        end
    elseif action == "set" then
        local id, value = remainder:match("^(%S+)%s+(.+)$")
        local definition = EGF.FindSetting(id)
        if not definition then EGF.Print("Unknown setting. Use /guf list.") return end
        if definition.kind == "toggle" then
            value = tostring(value):lower()
            if value ~= "on" and value ~= "off" and value ~= "1" and value ~= "0" then help() return end
            value = value == "on" or value == "1"
        else
            value = tonumber(value)
            if not value then help() return end
        end
        local _, result = EGF.SetValue(definition, value)
        EGF.Print(result)
        EGF.RefreshOptions()
    elseif action == "preset" then
        local wanted = remainder:lower()
        local preset = EGF.presetsByID[wanted] or
            wanted == "enhanced" and EGF.presetsByID["enhanced-ground"] or
            wanted == "normal" and EGF.presetsByID["standard-ground"] or
            (wanted == "max" or wanted == "fidelity") and EGF.presetsByID["ufo"]
        if not preset then help() return end
        local changed, failed = EGF.ApplyPreset(preset)
        EGF.Print(string.format("%s: changed %d setting(s); %d failed.", preset.label, changed, failed))
        EGF.RefreshOptions()
    elseif action == "reset" then
        if remainder:lower() == "all" then
            local restored, failed = EGF.RestoreAll()
            EGF.Print(string.format("Restored %d setting(s); %d failed.", restored, failed))
        else
            local definition = EGF.FindSetting(remainder)
            local _, result = EGF.RestoreSetting(definition)
            EGF.Print(result)
        end
        EGF.RefreshOptions()
    elseif action == "minimap" then
        EGF.db.minimapHidden = not EGF.db.minimapHidden
        EGF.UpdateMinimapButton()
        EGF.Print("Minimap button " .. (EGF.db.minimapHidden and "hidden. Use /guf minimap to show it again." or "shown."))
    elseif action == "status" then
        EGF.Print(EGF.StatusText())
    else
        help()
    end
end

function _G.GraphicsUnlockedForever_OnAddonCompartmentClick()
    EGF.OpenNativeSettings()
end

SLASH_GRAPHICSUNLOCKEDFOREVER1 = "/guf"
SLASH_GRAPHICSUNLOCKEDFOREVER2 = "/graphicsunlocked"
SlashCmdList.GRAPHICSUNLOCKEDFOREVER = command

frame:SetScript("OnEvent", function(_, event, argument)
    if event == "ADDON_LOADED" then
        if argument ~= addonName then return end
        EGF.LoadSettings()
        EGF.RegisterNativeSettings()
        EGF.BuildMinimapButton()
        frame:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        EGF.BuildMinimapButton()
        EGF.UpdateMinimapButton()
        if EGF.db.autoApply and C_Timer and C_Timer.After then
            C_Timer.After(1.5, function() EGF.ApplySavedValues() end)
        end
        if EGF.options and EGF.options:IsShown() then EGF.RefreshOptions() end
    elseif event == "CVAR_UPDATE" and EGF.options and EGF.options:IsShown() and not EGF.options.sliderDragging then
        EGF.RefreshOptions()
    end
end)

pcall(frame.RegisterEvent, frame, "ADDON_LOADED")
pcall(frame.RegisterEvent, frame, "PLAYER_ENTERING_WORLD")
pcall(frame.RegisterEvent, frame, "CVAR_UPDATE")
