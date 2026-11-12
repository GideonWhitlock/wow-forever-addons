WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local eventHandler
local printed = {}

DEFAULT_CHAT_FRAME = {
    AddMessage = function(_, message)
        table.insert(printed, message)
    end,
}
SlashCmdList = {}
C_ChatInfo = {}

function CreateFrame()
    return {
        RegisterEvent = function() end,
        RegisterUnitEvent = function() end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end

function GetBuildInfo() return "1.60.1", "build", "date", 16001 end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")
eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")

assert(#ThanksForTheBuffForeverDB.messages == 15, "new installs should receive the 15 default phrases")

SlashCmdList.THANKSFORTHEBUFFFOREVER("phrases add Brilliant, thank you!")
assert(#ThanksForTheBuffForeverDB.messages == 16, "a custom phrase should be saved")
assert(ThanksForTheBuffForeverDB.messages[16] == "Brilliant, thank you!", "the custom phrase text should be preserved")

SlashCmdList.THANKSFORTHEBUFFFOREVER("phrases add brilliant, thank you!")
assert(#ThanksForTheBuffForeverDB.messages == 16, "case-only duplicate phrases should be rejected")

SlashCmdList.THANKSFORTHEBUFFFOREVER("phrases remove 1")
assert(#ThanksForTheBuffForeverDB.messages == 15, "removing a numbered phrase should update the saved list")
assert(ThanksForTheBuffForeverDB.messages[1] == "ty!", "the remaining phrases should close the removed gap")

SlashCmdList.THANKSFORTHEBUFFFOREVER("phrases reset")
assert(#ThanksForTheBuffForeverDB.messages == 15, "reset should restore the full default list")
assert(ThanksForTheBuffForeverDB.messages[1] == "thanks!", "reset should restore the original ordering")

SlashCmdList.THANKSFORTHEBUFFFOREVER("phrases")
local sawHeader = false
local sawLastPhrase = false
for _, message in ipairs(printed) do
    if string.find(message, "thank%-you phrases %(15%)") then sawHeader = true end
    if string.find(message, "15%. much appreciated!", 1, false) then sawLastPhrase = true end
end
assert(sawHeader and sawLastPhrase, "listing phrases should print the complete numbered list")

print("Custom phrase tests passed")
