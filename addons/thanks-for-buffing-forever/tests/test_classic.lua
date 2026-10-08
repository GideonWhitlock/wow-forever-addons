WOW_PROJECT_ID = 2
WOW_PROJECT_MAINLINE = 1

local registered = {}
local scheduled = {}
local whispers = {}
local eventHandler
local combatEvent
local now = 200
local grouped = false

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
        table.insert(scheduled, { delay = delay, callback = callback })
    end,
}
COMBATLOG_OBJECT_TYPE_PLAYER = 0x400
bit = { band = function(left, right) return left & right end }

function CreateFrame()
    return {
        RegisterEvent = function(_, event) registered[event] = true end,
        RegisterUnitEvent = function(_, event, unit) registered[event] = unit end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end

function GetTime() return now end
function GetBuildInfo() return "2.5.5", "build", "date", 20506 end
function InCombatLockdown() return false end
function IsInGroup() return grouped end
function UnitExists(unit) return unit == "player" or unit == "party1" end
function UnitGUID(unit)
    if unit == "player" then return "Player-Self" end
    if unit == "party1" then return "Player-Buff" end
end
function UnitFullName(unit)
    if unit == "party1" then return "Helpful", "TestRealm" end
    return "Self", "TestRealm"
end
function CombatLogGetCurrentEventInfo() return table.unpack(combatEvent) end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
assert(registered.COMBAT_LOG_EVENT_UNFILTERED, "Classic should register the combat log")
assert(not registered.UNIT_AURA, "Classic should not use the limited aura path")

combatEvent = {
    0, "SPELL_AURA_APPLIED", false,
    "Player-Buff", "Helpful-TestRealm", COMBATLOG_OBJECT_TYPE_PLAYER, 0,
    "Player-Self", "Self-TestRealm", 0, 0,
    12345, "Helpful Buff", 2, "BUFF",
}
eventHandler(nil, "COMBAT_LOG_EVENT_UNFILTERED")
assert(#scheduled == 1, "a player buff should schedule a thank-you")
assert(scheduled[1].delay >= 3 and scheduled[1].delay <= 10, "delay must be 3-10 seconds")

scheduled[1].callback()
assert(#whispers == 1, "one whisper should be sent")
assert(whispers[1].chatType == "WHISPER", "message must be a whisper")
assert(whispers[1].target == "Helpful-TestRealm", "combat-log target should be preserved")

grouped = true
now = now + 600
eventHandler(nil, "COMBAT_LOG_EVENT_UNFILTERED")
assert(#scheduled == 1, "group buffs should not schedule whispers")

combatEvent[4] = "Player-Outside"
combatEvent[5] = "Outside-TestRealm"
eventHandler(nil, "COMBAT_LOG_EVENT_UNFILTERED")
assert(#scheduled == 2, "an external player should still be thanked while the recipient is grouped")
scheduled[2].callback()
assert(#whispers == 2 and whispers[2].target == "Outside-TestRealm", "the external grouped-state caster should receive one whisper")

combatEvent[2] = "SPELL_DAMAGE"
eventHandler(nil, "COMBAT_LOG_EVENT_UNFILTERED")
assert(#scheduled == 2, "non-buff combat events should be ignored")

print("Classic behavior tests passed")
