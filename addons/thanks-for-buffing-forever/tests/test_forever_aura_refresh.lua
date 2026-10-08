WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local SECRET = {}
local registered = {}
local scheduled = {}
local whispers = {}
local eventHandler
local now = 500

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
    GetAuraDataByIndex = function() return nil end,
    GetAuraDataByAuraInstanceID = function(unit, auraInstanceID)
        assert(unit == "player", "the player aura should be re-queried")
        if auraInstanceID == 77 then
            return { sourceUnit = "nameplate1" }
        end
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
function InCombatLockdown() return false end
function IsInGroup() return false end
function issecretvalue(value) return value == SECRET end
function UnitExists(unit) return unit == "player" or unit == "nameplate1" end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitGUID(unit) return unit == "player" and "Player-Self" or "Player-Mage" end
function UnitFullName(unit)
    if unit == "nameplate1" then return "Arcana", "TestRealm" end
    return "Self", "TestRealm"
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
            isHelpful = true,
            sourceUnit = SECRET,
            spellId = 1459,
            auraInstanceID = 77,
        },
    },
})

assert(#scheduled == 1, "a secret initial source should queue a safe aura refresh")
assert(scheduled[1].delay == 0.5, "the aura refresh should wait briefly for stable source data")

now = now + 0.5
scheduled[1].callback()
assert(#scheduled == 2, "a refreshed sourceUnit should schedule the thank-you")
assert(scheduled[2].delay >= 2.5 and scheduled[2].delay <= 9.5, "the refresh wait should remain inside the original 3-10 second total")

scheduled[2].callback()
assert(#whispers == 1, "the refreshed aura caster should receive one whisper")
assert(whispers[1].target == "Arcana", "the refreshed source should use the accepted same-realm whisper name")
assert(whispers[1].chatType == "WHISPER", "the refreshed source path must remain private")

print("Forever aura refresh tests passed")
