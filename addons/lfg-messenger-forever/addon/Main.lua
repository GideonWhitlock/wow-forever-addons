local addonName, Q = ...
local frame = CreateFrame("Frame")

local function isBlizzardLoaded()
    if C_AddOns and type(C_AddOns.IsAddOnLoaded) == "function" then
        local ok, loaded = pcall(C_AddOns.IsAddOnLoaded, Q.BLIZZARD_ADDON)
        return ok and loaded
    end
    return LFGBrowseFrame ~= nil
end

local function command(message)
    local cmd, arg = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()
    if cmd == "" or cmd == "options" then Q.ToggleOptions()
    elseif cmd == "preview" then Q.Print("Preview: " .. Q.BuildMessage())
    elseif cmd == "send" then Q.SendSelected()
    elseif cmd == "minimap" and (arg == "show" or arg == "hide") then
        Q.db.minimap.hidden = arg == "hide"
        Q.UpdateMinimap()
    elseif cmd == "reset" then Q.ResetSettings(); Q.Print("Settings restored.")
    else
        Q.Print("/lfgmsg options | preview | send | minimap show|hide | reset")
    end
end

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            Q.InitializeDB()
            SLASH_LFGMESSENGERFOREVER1 = "/lfgmsg"
            SLASH_LFGMESSENGERFOREVER2 = "/lfgmessenger"
            SlashCmdList.LFGMESSENGERFOREVER = command
            if isBlizzardLoaded() then Q.TryAttachToGroupFinder() end
        elseif arg1 == Q.BLIZZARD_ADDON then
            Q.TryAttachToGroupFinder()
        end
    elseif event == "PLAYER_LOGIN" then
        if not Q.db then Q.InitializeDB() end
        Q.CreateMinimapButton()
        if isBlizzardLoaded() then Q.TryAttachToGroupFinder() end
        Q.Print("Loaded. Select a group and use Quick Whisper. /lfgmsg for options.")
    else
        if Q.UpdateLFGButton then Q.UpdateLFGButton() end
    end
end)

for _, event in ipairs({
    "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
    "LFG_LIST_ROLE_UPDATE", "LFG_LIST_SEARCH_RESULT_UPDATED", "LFG_LIST_SEARCH_RESULTS_RECEIVED",
    "LFG_LIST_SEARCH_FAILED", "LFG_LIST_ACTIVE_ENTRY_UPDATE",
}) do
    pcall(frame.RegisterEvent, frame, event)
end
