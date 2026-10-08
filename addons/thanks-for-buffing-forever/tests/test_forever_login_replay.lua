WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local registered = {}
local scheduled = {}
local baselineCallbacks = {}
local whispers = {}
local helpfulAuras = {
    { auraInstanceID = 6001, spellId = 1126, isHelpful = true, sourceUnit = "nameplate1" },
}
local eventHandler
local now = 3000

local units = {
    nameplate1 = { guid = "Player-OldCaster", name = "Oldcaster" },
    nameplate2 = { guid = "Player-NewCaster", name = "Newcaster" },
}

ThanksForTheBuffForeverDB = { enabled = true, debug = true }
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
            table.insert(baselineCallbacks, callback)
        else
            table.insert(scheduled, { delay = delay, callback = callback })
        end
    end,
}
C_UnitAuras = {
    GetAuraDataByIndex = function(unit, index, filter)
        assert(unit == "player" and filter == "HELPFUL")
        return helpfulAuras[index]
    end,
    GetAuraDataByAuraInstanceID = function() return nil end,
}

function CreateFrame()
    return {
        RegisterEvent = function(_, event) registered[event] = true end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end
function GetTime() return now end
function GetBuildInfo() return "1.60.1.70205", "70205", "Oct 2026", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return false end
function issecretvalue() return false end
function UnitExists(unit) return unit == "player" or units[unit] ~= nil end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitGUID(unit) return unit == "player" and "Player-Self" or units[unit].guid end
function UnitFullName(unit)
    if unit == "player" then return "Self", "TestRealm" end
    return units[unit].name, "TestRealm"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")

eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = { helpfulAuras[1] },
})
assert(#scheduled == 0 and #whispers == 0, "pre-world aura replay must not schedule a thank-you")

eventHandler(nil, "PLAYER_ENTERING_WORLD")
eventHandler(nil, "UNIT_AURA", "player", nil)
eventHandler(nil, "PLAYER_ENTERING_WORLD")
assert(#scheduled == 0 and #whispers == 0, "relogging with an existing buff must remain silent")
baselineCallbacks[1]()
assert(#scheduled == 0 and #whispers == 0, "a superseded world-entry baseline callback must not arm detection")
baselineCallbacks[2]()

eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate1", "Stale-Cast", 7001)
eventHandler(nil, "PLAYER_ENTERING_WORLD")

helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 6002,
    spellId = 7001,
    isHelpful = true,
    sourceUnit = nil,
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 0 and #whispers == 0, "a long-lived aura restored after world entry must be absorbed into the settling baseline")
baselineCallbacks[3]()
assert(#scheduled == 0 and #whispers == 0, "finishing the delayed baseline must not replay a restored aura")

helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 6003,
    spellId = 1459,
    isHelpful = true,
    sourceUnit = "nameplate2",
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 1, "a genuinely new external buff after the settling baseline should schedule one thank-you")
scheduled[1].callback()
assert(#whispers == 1 and whispers[1].target == "Newcaster", "the genuine same-realm caster should receive the accepted whisper name")

print("Forever login replay tests passed")
