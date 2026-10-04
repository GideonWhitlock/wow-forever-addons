WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local registered = {}
local scheduled = {}
local whispers = {}
local eventHandler
local now = 100
local grouped = false
local chatLocked = false
local secretName = false

DEFAULT_CHAT_FRAME = { AddMessage = function() end }
SlashCmdList = {}
C_ChatInfo = {
    InChatMessagingLockdown = function() return chatLocked end,
    SendChatMessage = function(message, chatType, languageID, target)
        table.insert(whispers, { message = message, chatType = chatType, target = target })
    end,
}
C_Timer = {
    After = function(delay, callback)
        table.insert(scheduled, { delay = delay, callback = callback })
    end,
}

function CreateFrame()
    return {
        RegisterEvent = function(_, event) registered[event] = true end,
        RegisterUnitEvent = function(_, event, unit) registered[event] = unit end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end

function GetTime() return now end
function GetBuildInfo() return "1.60.1", "build", "date", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return grouped end
function issecretvalue(value) return value == "SecretName" end
function UnitExists(unit) return unit == "party1" or unit == "nameplate1" or unit == "player" end
function UnitIsPlayer(unit) return unit == "party1" or unit == "nameplate1" or unit == "player" end
function UnitGUID(unit)
    if unit == "player" then return "Player-Self" end
    if unit == "nameplate1" then return "Player-Kings" end
    return "Player-Buff"
end
function UnitFullName(unit)
    if unit == "party1" then return secretName and "SecretName" or "Buffy", "TestRealm" end
    if unit == "nameplate1" then return "Kingsbuffer", "TestRealm" end
    return "Self", "TestRealm"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
assert(registered.UNIT_AURA == "player", "Forever should register player UNIT_AURA")
assert(registered.UNIT_SPELLCAST_SUCCEEDED, "Forever should correlate nearby casts when aura caster data is missing")
assert(not registered.COMBAT_LOG_EVENT_UNFILTERED, "Forever must not register the protected combat log")

local update = {
    isFullUpdate = false,
    addedAuras = {
        { isHelpful = true, sourceUnit = "party1" },
        { isHelpful = true, sourceUnit = "party1" },
    },
}
eventHandler(nil, "UNIT_AURA", "player", update)
assert(#scheduled == 1, "multiple buffs from one caster should coalesce")
assert(scheduled[1].delay >= 3 and scheduled[1].delay <= 10, "delay must be 3-10 seconds")

scheduled[1].callback()
assert(#whispers == 1, "one whisper should be sent")
assert(whispers[1].chatType == "WHISPER", "message must be a whisper")
assert(whispers[1].target == "Buffy-TestRealm", "cross-realm target should be preserved")

eventHandler(nil, "UNIT_AURA", "player", update)
assert(#scheduled == 1, "ten-minute cooldown should suppress another immediate thank-you")

now = now + 599
eventHandler(nil, "UNIT_AURA", "player", update)
assert(#scheduled == 1, "ten-minute cooldown should still apply at 9:59")

now = now + 1
eventHandler(nil, "UNIT_AURA", "player", update)
assert(#scheduled == 2, "the same player should be eligible again after ten minutes")
scheduled[2].callback()
assert(#whispers == 2, "a second whisper should be sent after the cooldown")

grouped = true
now = now + 600
eventHandler(nil, "UNIT_AURA", "player", update)
assert(#scheduled == 2, "party and raid buffs should not schedule whispers")

grouped = false
secretName = true
eventHandler(nil, "UNIT_AURA", "player", update)
assert(#scheduled == 2, "secret player names should not schedule whispers")

secretName = false
eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate1", "Cast-1", 20217)
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        { isHelpful = true, sourceUnit = nil, spellId = 20217 },
    },
})
assert(#scheduled == 3, "a nearby player cast should identify an otherwise anonymous Blessing buff")
scheduled[3].callback()
assert(#whispers == 3, "the correlated Blessing should send a whisper")
assert(whispers[3].target == "Kingsbuffer-TestRealm", "the nearby caster should receive the whisper")

chatLocked = true
eventHandler(nil, "UNIT_AURA", "player", update)
assert(#scheduled == 4, "an otherwise eligible buff should still schedule before chat lockdown is checked")
scheduled[4].callback()
assert(#whispers == 3, "chat lockdown should drop the whisper without calling the protected API")

print("Forever behavior tests passed")
