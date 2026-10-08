WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local registered = {}
local scheduled = {}
local whispers = {}
local eventHandler

ThanksForTheBuffForeverDB = { enabled = true }
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
SlashCmdList = {}
C_ChatInfo = {
    InChatMessagingLockdown = function() return false end,
    SendChatMessage = function(message, chatType, languageID, target)
        table.insert(whispers, { message = message, chatType = chatType, target = target })
    end,
}
C_Timer = {
    After = function(delay, callback)
        if delay == 2 then
            callback()
        else
            table.insert(scheduled, { delay = delay, callback = callback })
        end
    end,
}
C_UnitAuras = {
    GetAuraCasterGUID = function(unit, auraInstanceID)
        assert(unit == "player" and auraInstanceID == 9001)
        return "Player-Brother-Marlin"
    end,
    GetAuraDataByIndex = function() return nil end,
}

function CreateFrame()
    return {
        RegisterEvent = function(_, event) registered[event] = true end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end

function GetTime() return 3000 end
function GetBuildInfo() return "1.60.1.70245", "70245", "Oct 2026", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return true end
function issecretvalue() return false end
function UnitExists(unit) return unit == "player" or unit == "nameplate1" end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitGUID(unit)
    if unit == "player" then return "Player-Self" end
    if unit == "nameplate1" then return "Player-Brother-Marlin" end
end
function UnitFullName(unit)
    if unit == "player" then return "Self", "TestRealm" end
    if unit == "nameplate1" then return "Brother Marlin", "TestRealm" end
end
function GetPlayerInfoByGUID(guid)
    assert(guid == "Player-Brother-Marlin")
    return "Class", "CLASS", "Race", "Race", 2, "Brother", "TestRealm"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        {
            auraInstanceID = 9001,
            spellId = 1243,
            isHelpful = true,
            isFromPlayerOrPlayerPet = true,
            sourceUnit = nil,
        },
    },
})

assert(#scheduled == 1, "a grouped external multi-word caster should schedule one thank-you")
scheduled[1].callback()
assert(#whispers == 1, "the grouped external multi-word caster should receive one whisper")
assert(whispers[1].target == "Brother Marlin", "the visible full unit name must override the truncated GUID-only name")
assert(whispers[1].chatType == "WHISPER", "delivery must remain private")

print("Forever multi-word recipient tests passed")
