WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local registered = {}
local scheduled = {}
local whispers = {}
local printed = {}
local helpfulAuras = {}
local eventHandler
local now = 900

local units = {
    nameplate1 = { guid = "Player-Mage", name = "Magebuffer" },
    nameplate2 = { guid = "Player-Paladin", name = "Paladinbuffer" },
    nameplate3 = { guid = "Player-Priest", name = "Priestbuffer" },
    nameplate4 = { guid = "Player-Druid", name = "Druidbuffer" },
    nameplate5 = { guid = "Player-Shaman", name = "Shamanbuffer" },
    nameplate6 = { guid = "Player-Warlock", name = "Warlockbuffer", realm = "OtherRealm" },
}

ThanksForTheBuffForeverDB = { enabled = true, debug = true }
DEFAULT_CHAT_FRAME = { AddMessage = function(_, message) table.insert(printed, message) end }
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
    GetAuraDataByIndex = function(unit, index, filter)
        assert(unit == "player" and filter == "HELPFUL", "the fallback should scan player helpful auras")
        return helpfulAuras[index]
    end,
    GetAuraDataByAuraInstanceID = function(unit, auraInstanceID)
        for _, aura in ipairs(helpfulAuras) do
            if aura.auraInstanceID == auraInstanceID then
                return aura
            end
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
function issecretvalue() return false end
function UnitExists(unit) return unit == "player" or units[unit] ~= nil end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitGUID(unit) return unit == "player" and "Player-Self" or units[unit].guid end
function UnitFullName(unit)
    if unit == "player" then return "Self", "TestRealm" end
    return units[unit].name, units[unit].realm or "TestRealm"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")
SlashCmdList.THANKSFORTHEBUFFFOREVER("debug")

assert(registered.UNIT_AURA == true, "Forever should use global UNIT_AURA for clients without incremental payloads")

local families = {
    { label = "Mage Arcane Intellect", spellID = 1459, unit = "nameplate1" },
    { label = "Paladin Blessing of Might", spellID = 19740, unit = "nameplate2" },
    { label = "Priest Power Word: Fortitude", spellID = 1243, unit = "nameplate3" },
    { label = "Druid Mark of the Wild", spellID = 1126, unit = "nameplate4" },
    { label = "Shaman Water Breathing", spellID = 131, unit = "nameplate5" },
    { label = "Warlock Unending Breath", spellID = 5697, unit = "nameplate6" },
}

for index, family in ipairs(families) do
    helpfulAuras[#helpfulAuras + 1] = {
        auraInstanceID = 1000 + index,
        spellId = family.spellID,
        isHelpful = true,
        isFromPlayerOrPlayerPet = true,
        sourceUnit = family.unit,
    }

    if index == 1 then
        eventHandler(nil, "UNIT_AURA", "target", nil)
        assert(#scheduled == 0, "non-player UNIT_AURA events should be ignored")
    end

    local updateInfo = index % 2 == 0 and { isFullUpdate = true } or nil
    eventHandler(nil, "UNIT_AURA", "player", updateInfo)
    assert(#scheduled == index, family.label .. " should be detected by the full-scan fallback")
    assert(scheduled[index].delay >= 3 and scheduled[index].delay <= 10, family.label .. " should keep the 3-10 second delay")
    scheduled[index].callback()
    assert(#whispers == index, family.label .. " should send exactly one whisper")
    assert(whispers[index].target == units[family.unit].name, family.label .. " should use Forever's bare-name whisper target even when an aura exposes a realm")
    assert(whispers[index].chatType == "WHISPER", family.label .. " must stay private")
    now = now + 1
end

local sawScanDebug = false
for _, message in ipairs(printed) do
    if string.find(message, "scanning current helpful auras", 1, true) then
        sawScanDebug = true
        break
    end
end
assert(sawScanDebug, "debug output should explain the no-incremental-data fallback")

print("Forever full-scan spell-family tests passed")
