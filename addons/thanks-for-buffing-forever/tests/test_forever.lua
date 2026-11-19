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
function GetBuildInfo() return "1.60.1", "build", "date", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return grouped end
function issecretvalue(value) return value == "SecretName" end
function UnitExists(unit) return unit == "party1" or unit == "nameplate1" or unit == "nameplate2" or unit == "player" end
function UnitIsPlayer(unit) return unit == "party1" or unit == "nameplate1" or unit == "nameplate2" or unit == "player" end
function UnitGUID(unit)
    if unit == "player" then return "Player-Self" end
    if unit == "nameplate1" then return "Player-Kings" end
    if unit == "nameplate2" then return "Player-Arcane" end
    return "Player-Buff"
end
function UnitFullName(unit)
    if unit == "party1" then return secretName and "SecretName" or "Buffy", "TestRealm" end
    if unit == "nameplate1" then return "Kingsbuffer", "TestRealm" end
    if unit == "nameplate2" then return "Arcana", "TestRealm" end
    return "Self", "DifferentLocalRealmLabel"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")
assert(registered.UNIT_AURA == true, "Forever should register global UNIT_AURA and filter for player events")
assert(registered.UNIT_SPELLCAST_SUCCEEDED, "Forever may observe nearby casts without using them as aura ownership evidence")
assert(registered.PLAYER_ENTERING_WORLD, "Forever should baseline helpful auras on world entry")
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
assert(whispers[1].target == "Buffy TestRealm", "Forever should combine the caster's first name and surname")
assert(#ThanksForTheBuffForeverDB.auditLog == 1, "an approved thank-you should be retained in the local audit")
assert(ThanksForTheBuffForeverDB.auditLog[1].target == "Buffy TestRealm", "the audit should retain the exact recipient")
assert(string.find(ThanksForTheBuffForeverDB.auditLog[1].details, "attribution=aura source unit", 1, true),
    "the audit should retain how the exact caster was identified")

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
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        { isHelpful = true, sourceUnit = nil, spellId = 1459 },
    },
})
assert(#scheduled == 3, "an anonymous Arcane Intellect aura should queue a short correlation wait")
eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate2", "Cast-Arcane", 1459)
now = now + 0.5
scheduled[3].callback()
assert(#scheduled == 3, "an anonymous aura must not infer ownership from a later same-spell cast")
assert(#whispers == 2, "strict mode must not whisper for the anonymous Arcane Intellect aura")

eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate1", "Cast-1", 20217)
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        { isHelpful = true, sourceUnit = nil, spellId = 20217 },
    },
})
assert(#scheduled == 4, "an anonymous Blessing should queue one exact-caster refresh")
now = now + 0.5
scheduled[4].callback()
assert(#scheduled == 4, "an earlier same-spell cast must not become aura ownership evidence")
assert(#whispers == 2, "strict mode must not whisper for the anonymous Blessing aura")

chatLocked = true
eventHandler(nil, "UNIT_AURA", "player", update)
assert(#scheduled == 5, "an otherwise eligible buff should still schedule before chat lockdown is checked")
scheduled[5].callback()
assert(#whispers == 2, "chat lockdown should drop the whisper without calling the protected API")

print("Forever behavior tests passed")
