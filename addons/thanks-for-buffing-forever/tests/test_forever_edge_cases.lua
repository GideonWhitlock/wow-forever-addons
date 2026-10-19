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
        if delay == 2 then
            callback()
        else
            table.insert(scheduled, { delay = delay, callback = callback })
        end
    end,
}
C_UnitAuras = { GetAuraDataByIndex = function() return nil end }

function CreateFrame()
    return {
        RegisterEvent = function(_, event) registered[event] = true end,
        RegisterUnitEvent = function(_, event, unit) registered[event] = unit end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end

function GetTime() return now end
function GetBuildInfo() return "1.60.1.70450", "70450", "Oct 2026", 16001 end
function InCombatLockdown() return combat end
function IsInGroup() return grouped end
function issecretvalue(value) return value == SECRET end
function UnitExists(unit) return unit == "player" or unit == "nameplate1" or unit == "nameplate2" or unit == "nameplate3" or unit == "nameplate4" or (grouped and unit == "party1") end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitGUID(unit)
    if unit == "player" then return "Player-Self" end
    if unit == "nameplate1" then return "Player-One" end
    if unit == "nameplate2" then return "Player-Two" end
    if unit == "nameplate3" then return "Player-Three" end
    if unit == "nameplate4" then return "Player-One-AlternateRoute" end
    if unit == "party1" and grouped then return "Player-One" end
end
function UnitFullName(unit)
    if unit == "nameplate1" then return "One", "Realm" end
    if unit == "nameplate2" then return "Two", "Realm" end
    if unit == "nameplate3" then return secretThirdName and SECRET or "Three", "Realm" end
    if unit == "nameplate4" then return "One", "Realm" end
    if unit == "party1" and grouped then return "One", "Realm" end
    return "Self", "Realm"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
assert(ThanksForTheBuffForeverDB.enabled == false, "SavedVariables should preserve an explicit disabled setting")
assert(ThanksForTheBuffForeverDB.debug == nil, "a legacy persisted debug flag should be cleared during upgrade")

SlashCmdList.THANKSFORTHEBUFFFOREVER("on")
assert(ThanksForTheBuffForeverDB.enabled == true, "the on command should enable the addon")
SlashCmdList.THANKSFORTHEBUFFFOREVER("debug")

eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")
assert(registered.UNIT_AURA == true, "build 1.60.1.70450 should register global UNIT_AURA and filter player events")
assert(registered.UNIT_SPELLCAST_SUCCEEDED, "build 1.60.1.70450 should register cast correlation")
assert(registered.PLAYER_ENTERING_WORLD, "build 1.60.1.70450 should baseline helpful auras on world entry")
assert(registered.PLAYER_REGEN_ENABLED, "build 1.60.1.70450 should flush deferred whispers after combat")
assert(not registered.COMBAT_LOG_EVENT_UNFILTERED, "Forever must not register the protected combat log")

local directAura = {
    isFullUpdate = false,
    addedAuras = {
        { isHelpful = true, sourceUnit = "nameplate1", spellId = 1001 },
        { isHelpful = true, sourceUnit = "nameplate1", spellId = 1002 },
        { isHelpful = true, sourceUnit = "nameplate4", spellId = 1003 },
    },
}

eventHandler(nil, "UNIT_AURA", "player", directAura)
assert(#scheduled == 1, "multiple buffs with alternate GUID routes for one named caster should create one pending whisper")
assert(scheduled[1].delay >= 3 and scheduled[1].delay <= 10, "the delay should remain inside 3-10 seconds")
local detectedLines = 0
for _, message in ipairs(printed) do
    if string.find(message, "Detected a buff from One Realm.", 1, true) then
        detectedLines = detectedLines + 1
    end
end
assert(detectedLines == 1, "coalesced buffs should emit only one detection line for the caster")

grouped = true
scheduled[1].callback()
assert(#whispers == 0, "entering a group before the timer fires should cancel delivery")

grouped = false
eventHandler(nil, "UNIT_AURA", "player", directAura)
assert(#scheduled == 2, "a dropped grouped whisper should not start the cooldown")
combat = true
scheduled[2].callback()
assert(#whispers == 0, "entering combat before the timer fires should defer delivery")

combat = false
eventHandler(nil, "PLAYER_REGEN_ENABLED")
assert(#whispers == 1 and whispers[1].target == "One Realm", "leaving combat should deliver the deferred whisper to the complete Forever name")
assert(whispers[1].chatType == "WHISPER", "deferred combat delivery must remain private")

now = now + 600
eventHandler(nil, "UNIT_AURA", "player", directAura)
chatLocked = true
scheduled[3].callback()
assert(#whispers == 1, "chat lockdown should defer delivery")
assert(#scheduled == 4 and scheduled[4].delay == 1, "chat lockdown should schedule the bounded retry")

chatLocked = false
scheduled[4].callback()
assert(#whispers == 2 and whispers[2].target == "One Realm", "the retry should deliver to the caster's complete Forever name")
assert(whispers[2].chatType == "WHISPER", "chat-lockdown retry must remain private")

now = now + 599
eventHandler(nil, "UNIT_AURA", "player", directAura)
assert(#scheduled == 4, "the caster cooldown should still apply at 9:59")
now = now + 1
eventHandler(nil, "UNIT_AURA", "player", directAura)
assert(#scheduled == 5, "the caster should become eligible at exactly 10:00")
scheduled[5].callback()
assert(#whispers == 3, "the eligible repeat should send after ten minutes")

eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate2", "Cast-A", 20217)
eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate3", "Cast-B", 20217)
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { { isHelpful = true, sourceUnit = nil, spellId = 20217 } },
})
assert(#scheduled == 6, "an anonymous aura should queue a correlation wait")
now = now + 0.5
scheduled[6].callback()
assert(#scheduled == 6, "ambiguous same-spell casters should not be guessed")

eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate2", "Cast-C", 25898)
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { { isHelpful = true, sourceUnit = nil, spellId = 25898 } },
})
assert(#scheduled == 7, "a unique anonymous aura should queue a correlation wait")
now = now + 0.5
scheduled[7].callback()
assert(#scheduled == 8, "one recent visible caster should match after correlation")
scheduled[8].callback()
assert(#whispers == 4 and whispers[4].target == "Two Realm", "the unique correlated caster should receive the whisper")

eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        { isHelpful = SECRET, sourceUnit = "nameplate3", spellId = 3001 },
        { isHelpful = true, sourceUnit = SECRET, spellId = 3002 },
        { isHelpful = true, sourceUnit = nil, spellId = SECRET },
    },
})
assert(#scheduled == 9, "a secret source with a public spell should queue a safe correlation attempt")
now = now + 0.5
scheduled[9].callback()
assert(#scheduled == 9, "a secret source without an identifiable caster should be ignored after correlation")

secretThirdName = true
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { { isHelpful = true, sourceUnit = "nameplate3", spellId = 3003 } },
})
assert(#scheduled == 9, "secret caster names should be ignored")
secretThirdName = false

eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { { isHelpful = true, sourceUnit = "nameplate3", spellId = 3004 } },
})
assert(#scheduled == 10, "a third caster should be schedulable")
SlashCmdList.THANKSFORTHEBUFFFOREVER("off")
scheduled[10].callback()
assert(#whispers == 4, "disabling the addon should invalidate pending whispers")

assert(#printed > 0, "debug and command status should remain local chat output")
print("Forever 1.60.1.70450 edge-case tests passed")
