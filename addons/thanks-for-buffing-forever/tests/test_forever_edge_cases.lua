WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local SECRET = {}
local registered = {}
local scheduled = {}
local whispers = {}
local printed = {}
local eventHandler
local now = 1000
local grouped = false
local combat = false
local chatLocked = false
local secretThirdName = false

ThanksForTheBuffForeverDB = { enabled = false, debug = true }
DEFAULT_CHAT_FRAME = { AddMessage = function(_, message) table.insert(printed, message) end }
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
function GetBuildInfo() return "1.60.1.70205", "70205", "Oct 2026", 16001 end
function InCombatLockdown() return combat end
function IsInGroup() return grouped end
function issecretvalue(value) return value == SECRET end
function UnitExists(unit) return unit == "player" or unit == "nameplate1" or unit == "nameplate2" or unit == "nameplate3" end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitGUID(unit)
    if unit == "player" then return "Player-Self" end
    if unit == "nameplate1" then return "Player-One" end
    if unit == "nameplate2" then return "Player-Two" end
    if unit == "nameplate3" then return "Player-Three" end
end
function UnitFullName(unit)
    if unit == "nameplate1" then return "One", "Realm" end
    if unit == "nameplate2" then return "Two", "Realm" end
    if unit == "nameplate3" then return secretThirdName and SECRET or "Three", "Realm" end
    return "Self", "Realm"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
assert(ThanksForTheBuffForeverDB.enabled == false, "SavedVariables should preserve an explicit disabled setting")
assert(ThanksForTheBuffForeverDB.debug == true, "SavedVariables should preserve the debug setting")

SlashCmdList.THANKSFORTHEBUFFFOREVER("on")
assert(ThanksForTheBuffForeverDB.enabled == true, "the on command should enable the addon")

eventHandler(nil, "PLAYER_LOGIN")
assert(registered.UNIT_AURA == "player", "build 1.60.1.70205 should use player UNIT_AURA")
assert(registered.UNIT_SPELLCAST_SUCCEEDED, "build 1.60.1.70205 should register cast correlation")
assert(not registered.COMBAT_LOG_EVENT_UNFILTERED, "Forever must not register the protected combat log")

local directAura = {
    isFullUpdate = false,
    addedAuras = {
        { isHelpful = true, sourceUnit = "nameplate1", spellId = 1001 },
        { isHelpful = true, sourceUnit = "nameplate1", spellId = 1002 },
    },
}

eventHandler(nil, "UNIT_AURA", "player", directAura)
assert(#scheduled == 1, "two buffs from one caster should create one pending whisper")
assert(scheduled[1].delay >= 3 and scheduled[1].delay <= 10, "the delay should remain inside 3-10 seconds")

grouped = true
scheduled[1].callback()
assert(#whispers == 0, "entering a group before the timer fires should cancel delivery")

grouped = false
eventHandler(nil, "UNIT_AURA", "player", directAura)
assert(#scheduled == 2, "a dropped grouped whisper should not start the cooldown")
combat = true
scheduled[2].callback()
assert(#whispers == 0, "entering combat before the timer fires should cancel delivery")

combat = false
eventHandler(nil, "UNIT_AURA", "player", directAura)
chatLocked = true
scheduled[3].callback()
assert(#whispers == 0, "chat lockdown should cancel delivery")

chatLocked = false
eventHandler(nil, "UNIT_AURA", "player", directAura)
scheduled[4].callback()
assert(#whispers == 1 and whispers[1].target == "One-Realm", "an eligible direct aura should whisper its caster")
assert(whispers[1].chatType == "WHISPER", "delivery must remain private")

now = now + 599
eventHandler(nil, "UNIT_AURA", "player", directAura)
assert(#scheduled == 4, "the caster cooldown should still apply at 9:59")
now = now + 1
eventHandler(nil, "UNIT_AURA", "player", directAura)
assert(#scheduled == 5, "the caster should become eligible at exactly 10:00")
scheduled[5].callback()
assert(#whispers == 2, "the eligible repeat should send after ten minutes")

eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate2", "Cast-A", 20217)
eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate3", "Cast-B", 20217)
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { { isHelpful = true, sourceUnit = nil, spellId = 20217 } },
})
assert(#scheduled == 5, "ambiguous same-spell casters should not be guessed")

eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate2", "Cast-C", 25898)
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { { isHelpful = true, sourceUnit = nil, spellId = 25898 } },
})
assert(#scheduled == 6, "one recent visible caster should match an anonymous aura")
scheduled[6].callback()
assert(#whispers == 3 and whispers[3].target == "Two-Realm", "the unique correlated caster should receive the whisper")

eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        { isHelpful = SECRET, sourceUnit = "nameplate3", spellId = 3001 },
        { isHelpful = true, sourceUnit = SECRET, spellId = 3002 },
        { isHelpful = true, sourceUnit = nil, spellId = SECRET },
    },
})
assert(#scheduled == 6, "secret aura values should be ignored")

secretThirdName = true
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { { isHelpful = true, sourceUnit = "nameplate3", spellId = 3003 } },
})
assert(#scheduled == 6, "secret caster names should be ignored")
secretThirdName = false

eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { { isHelpful = true, sourceUnit = "nameplate3", spellId = 3004 } },
})
assert(#scheduled == 7, "a third caster should be schedulable")
SlashCmdList.THANKSFORTHEBUFFFOREVER("off")
scheduled[7].callback()
assert(#whispers == 3, "disabling the addon should invalidate pending whispers")

assert(#printed > 0, "debug and command status should remain local chat output")
print("Forever 1.60.1.70205 edge-case tests passed")
