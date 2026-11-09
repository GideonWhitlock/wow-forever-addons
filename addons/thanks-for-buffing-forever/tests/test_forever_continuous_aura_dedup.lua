WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local scheduled = {}
local whispers = {}
local eventHandler
local now = 100
local grouped = true
local daxAura = {
    auraInstanceID = 5501,
    spellId = 1126,
    isHelpful = true,
    isFromPlayerOrPlayerPet = true,
    sourceUnit = "nameplate1",
    duration = 3600,
    expirationTime = 3700,
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
        if delay == 2 then callback() else table.insert(scheduled, { delay = delay, callback = callback }) end
    end,
}
C_UnitAuras = {
    GetAuraDataByIndex = function() return nil end,
    GetAuraDataByAuraInstanceID = function(unit, auraInstanceID)
        if unit == "player" and auraInstanceID == daxAura.auraInstanceID then return daxAura end
    end,
}

function CreateFrame()
    return {
        RegisterEvent = function() end,
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end
function GetTime() return now end
function GetBuildInfo() return "1.60.1.70862", "70862", "Nov 2026", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return grouped end
function issecretvalue() return false end
function UnitExists(unit)
    return unit == "player" or unit == "nameplate1" or (grouped and unit == "party1")
end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitGUID(unit)
    if unit == "player" then return "Player-Self" end
    if unit == "nameplate1" or unit == "party1" then return "Player-Dax" end
end
function UnitFullName(unit)
    if unit == "player" then return "Self", "TestRealm" end
    return "Dax", "Vonkragerak"
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
    addedAuras = { daxAura },
})
assert(#scheduled == 0 and #whispers == 0, "a party member's buff should be recorded but not thanked")

grouped = false
now = 200
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {},
    updatedAuraInstanceIDs = { daxAura.auraInstanceID },
})
assert(#scheduled == 0, "leaving the group must not replay the same continuous buff")

now = 900
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {},
    updatedAuraInstanceIDs = { daxAura.auraInstanceID },
})
assert(#scheduled == 0, "the same aura must remain suppressed after the old ten-minute cooldown")

daxAura.expirationTime = 4500
now = 1000
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {},
    updatedAuraInstanceIDs = { daxAura.auraInstanceID },
})
assert(#scheduled == 1, "a genuine reapplication with a later expiry should schedule one thank-you")
scheduled[1].callback()
assert(#whispers == 1 and whispers[1].target == "Dax Vonkragerak", "the genuine reapplication should thank Dax once")

now = 1700
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {},
    updatedAuraInstanceIDs = { daxAura.auraInstanceID },
})
assert(#scheduled == 1 and #whispers == 1, "ordinary updates must not thank Dax again")

print("Forever continuous aura deduplication tests passed")
