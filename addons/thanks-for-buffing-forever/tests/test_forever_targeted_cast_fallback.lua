WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local scheduled = {}
local whispers = {}
local eventHandler
local now = 1500

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
        if delay == 2 then callback() else table.insert(scheduled, { delay = delay, callback = callback }) end
    end,
}
C_UnitAuras = {
    GetAuraDataByIndex = function() return nil end,
    GetAuraDataByAuraInstanceID = function() return nil end,
}

function CreateFrame()
    return {
        RegisterEvent = function(_, event) end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end
function GetTime() return now end
function GetBuildInfo() return "1.60.1.70862", "70862", "Nov 2026", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return false end
function issecretvalue() return false end
function UnitExists(unit) return unit == "player" or unit == "nameplate1" end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitIsUnit(left, right) return left == "nameplate1target" and right == "player" end
function UnitGUID(unit) return unit == "player" and "Player-Self" or "Player-Arwen" end
function UnitFullName(unit)
    if unit == "player" then return "Self", "TestRealm" end
    return "Arwen", "El"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")

eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate1", "Cast-Arwen", 12345)
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        { auraInstanceID = 3001, spellId = 99999, isHelpful = true, sourceUnit = nil },
    },
})

assert(#scheduled == 1, "an anonymous aura should queue only its correlation timer")
now = now + 0.5
scheduled[1].callback()
assert(#scheduled == 1, "a different recent targeted spell must not be treated as the aura caster")
assert(#whispers == 0, "uncertain caster attribution must never send a whisper")

print("Forever unsafe targeted-caster fallback rejection test passed")
