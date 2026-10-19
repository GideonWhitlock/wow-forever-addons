WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local scheduled = {}
local whispers = {}
local eventHandler
local fortitudeAura = {
    auraInstanceID = 1243001,
    spellId = 1243,
    isHelpful = true,
    isFromPlayerOrPlayerPet = true,
    sourceUnit = "nameplate1",
}

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
        if delay == 2 then callback() else table.insert(scheduled, callback) end
    end,
}
C_UnitAuras = {
    GetAuraDataByIndex = function() return nil end,
    GetAuraDataByAuraInstanceID = function(unit, auraInstanceID)
        if unit == "player" and auraInstanceID == fortitudeAura.auraInstanceID then
            return fortitudeAura
        end
    end,
}

function CreateFrame()
    return {
        RegisterEvent = function() end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end

function GetTime() return 100 end
function GetBuildInfo() return "1.60.1.70450", "70450", "Oct 2026", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return false end
function issecretvalue() return false end
function UnitExists(unit) return unit == "player" or unit == "nameplate1" end
function UnitIsPlayer() return true end
function UnitGUID(unit) return unit == "player" and "Player-Self" or "Player-Morwenna" end
function UnitFullName(unit)
    if unit == "player" then return "Kio", "Zanim" end
    return "Morwenna", "Duskmirage"
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
    addedAuras = {},
    updatedAuraInstanceIDs = { fortitudeAura.auraInstanceID },
})

assert(#scheduled == 1, "a reapplied Power Word: Fortitude reported as an updated aura should schedule a thank-you")
scheduled[1]()
assert(#whispers == 1, "the refreshed stamina buff should send one whisper")
assert(whispers[1].target == "Morwenna Duskmirage", "the whisper should use the priest's complete Forever name")

print("Forever updated-aura regression test passed")
