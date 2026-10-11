local ADDON_NAME, NS = ...

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, event, loaded)
    if event ~= "ADDON_LOADED" or loaded ~= ADDON_NAME then return end
    NS:LoadDatabase()
    NS:CreateUI()
    NS:CreateMinimapButton()
    SLASH_CHOOSEAMAINFOREVER1 = "/classcompass"
    SLASH_CHOOSEAMAINFOREVER2 = "/chooseamain"
    SlashCmdList.CHOOSEAMAINFOREVER = function(message)
        message = (message or ""):lower():match("^%s*(.-)%s*$")
        if message == "reset" then NS:ShowResetConfirmation()
        elseif message == "show" then NS.db.minimap.hidden=false; NS:UpdateMinimapPosition()
        elseif message == "hide" then NS.db.minimap.hidden=true; NS:UpdateMinimapPosition()
        elseif message == "result" and NS.db.lastResult then NS:ShowResults(NS.db.lastResult)
        else NS:Toggle() end
    end
end)
