WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local registered = {}
local scheduled = {}
local whispers = {}
local eventHandler

DEFAULT_CHAT_FRAME = { AddMessage = function() end }
SlashCmdList = {}
C_ChatInfo = {
    InChatMessagingLockdown = function() return false end,
    SendChatMessage = function(message, chatType, languageID, target)
        table.insert(whispers, { message = message, chatType = chatType, target = target })
    end,
}
C_PlayerInfo = { GUIDIsPlayer = function() return true end }
C_Timer = {
    After = function(delay, callback)
        if delay == 2 then callback() else table.insert(scheduled, callback) end
    end,
}
C_UnitAuras = {
    GetAuraDataByIndex = function() return nil end,
    GetAuraCasterGUID = function() return "Player-Nocturna" end,
}

function CreateFrame()
    return {
        RegisterEvent = function(_, event) registered[event] = true end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end

function GetTime() return 100 end
function GetBuildInfo() return "1.60.1.70450", "70450", "Oct 2026", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return false end
function issecretvalue() return false end
function UnitExists(unit) return unit == "player" end
function UnitIsPlayer() return true end
function UnitGUID(unit) return unit == "player" and "Player-Self" or nil end
function UnitFullName(unit) return "Self", "TestRealm" end
function GetPlayerInfoByGUID() return nil, nil, nil, nil, nil, "Nocturna", "TestRealm" end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")

assert(registered.CHAT_MSG_SAY, "Forever should remember nearby speakers")

eventHandler(nil, "CHAT_MSG_SAY", "sure", "Nocturna Sjes", nil, nil, nil, nil, nil, nil, nil, nil, nil, "Player-Nocturna")
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        {
            auraInstanceID = 1243001,
            spellId = 1243,
            isHelpful = true,
            isFromPlayerOrPlayerPet = true,
        },
    },
})

assert(#scheduled == 1, "Power Word: Fortitude should schedule one thank-you")
scheduled[1]()
assert(#whispers == 1, "the priest should receive one whisper")
assert(whispers[1].target == "Nocturna Sjes", "the exact multi-word name from nearby chat should override the truncated GUID name")

print("Forever recent-speaker name regression test passed")
