WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local SECRET = {}
local registered = {}
local scheduled = {}
local whispers = {}
local helpfulAuras = { SECRET }
local eventHandler

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
    GetAuraDataByIndex = function(unit, index, filter)
        return helpfulAuras[index]
    end,
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
function issecretvalue(value) return value == SECRET end
function UnitExists(unit) return unit == "player" or unit == "nameplate1" end
function UnitIsPlayer() return true end
function UnitGUID(unit) return unit == "player" and "Player-Self" or "Player-Druid" end
function UnitFullName(unit)
    if unit == "player" then return "Self", "TestRealm" end
    return "Druidbuffer", "TestRealm"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")

assert(registered.UNIT_AURA, "Forever should register aura detection")

helpfulAuras[2] = {
    auraInstanceID = 1126001,
    spellId = 1126,
    isHelpful = true,
    isFromPlayerOrPlayerPet = true,
    sourceUnit = "nameplate1",
}

eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 1, "a secret aura must not prevent a later Mark of the Wild from being detected")
scheduled[1].callback()
assert(#whispers == 1, "Mark of the Wild should send one thank-you whisper")
assert(whispers[1].target == "Druidbuffer TestRealm", "the druid should receive the thank-you using the complete Forever name")

print("Forever secret-aura scan regression test passed")
