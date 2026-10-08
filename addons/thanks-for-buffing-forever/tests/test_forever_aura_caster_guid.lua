WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local registered = {}
local scheduled = {}
local whispers = {}
local printed = {}
local eventHandler
local now = 2100

local casterByAuraInstanceID = {}
local helpfulAuras = {}
local playersByGUID = {
    ["Player-Mage"] = { name = "Magebuffer", realm = "TestRealm" },
    ["Player-Paladin"] = { name = "Paladinbuffer", realm = "TestRealm" },
    ["Player-Priest"] = { name = "Priestbuffer", realm = "TestRealm" },
    ["Player-Druid"] = { name = "Druidbuffer", realm = "TestRealm" },
    ["Player-Shaman"] = { name = "Shamanbuffer", realm = "TestRealm" },
    ["Player-Warlock"] = { name = "Warlockbuffer", realm = "TestRealm" },
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
    GetAuraCasterGUID = function(unit, auraInstanceID)
        assert(unit == "player", "the direct caster lookup must query the player's aura")
        return casterByAuraInstanceID[auraInstanceID]
    end,
    GetAuraDataByIndex = function(unit, index, filter)
        assert(unit == "player" and filter == "HELPFUL", "the fallback should scan player helpful auras")
        return helpfulAuras[index]
    end,
    GetAuraDataByAuraInstanceID = function() return nil end,
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
function UnitExists(unit) return unit == "player" or unit == "pet" end
function UnitIsPlayer(unit) return unit == "player" end
function UnitGUID(unit)
    if unit == "player" then return "Player-Self" end
    if unit == "pet" then return "Creature-Totem" end
end
function UnitFullName(unit) return unit == "player" and "Self" or nil, "TestRealm" end
function GetPlayerInfoByGUID(guid)
    local player = playersByGUID[guid]
    if not player then return nil end
    return "Class", "CLASS", "Race", "Race", 2, player.name, player.realm
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")

local families = {
    { label = "Mage Arcane Intellect", auraSpellID = 1283389, casterGUID = "Player-Mage" },
    { label = "Paladin Blessing of Might", auraSpellID = 1283391, casterGUID = "Player-Paladin" },
    { label = "Priest Power Word: Fortitude", auraSpellID = 1283392, casterGUID = "Player-Priest" },
    { label = "Druid Mark of the Wild", auraSpellID = 1283393, casterGUID = "Player-Druid" },
    { label = "Shaman Water Breathing", auraSpellID = 1283394, casterGUID = "Player-Shaman" },
    { label = "Warlock Unending Breath", auraSpellID = 1283395, casterGUID = "Player-Warlock" },
}

for index, family in ipairs(families) do
    local auraInstanceID = 4000 + index
    casterByAuraInstanceID[auraInstanceID] = family.casterGUID
    helpfulAuras[#helpfulAuras + 1] = {
        auraInstanceID = auraInstanceID,
        spellId = family.auraSpellID,
        isHelpful = true,
        isFromPlayerOrPlayerPet = true,
        sourceUnit = nil,
    }

    local updateInfo = index % 2 == 0 and { isFullUpdate = true } or nil
    eventHandler(nil, "UNIT_AURA", "player", updateInfo)

    assert(#scheduled == index, family.label .. " should schedule directly from the aura caster GUID without spellcast events")
    assert(scheduled[index].delay >= 3 and scheduled[index].delay <= 10, family.label .. " should retain the 3-10 second delay")
    scheduled[index].callback()

    assert(#whispers == index, family.label .. " should send exactly one whisper")
    assert(whispers[index].target == playersByGUID[family.casterGUID].name, family.label .. " should whisper the same-realm GUID-resolved caster without a realm suffix")
    assert(whispers[index].chatType == "WHISPER", family.label .. " must remain private")
    now = now + 1
end

assert(#printed == 0, "legacy saved debug=true must not print detection or submission lines for any supported external buff family")
SlashCmdList.THANKSFORTHEBUFFFOREVER("debug")
assert(#printed == 1 and string.find(printed[1], "debug messages are now on for this session", 1, true), "diagnostics should remain deliberately available through the slash command")

casterByAuraInstanceID[4998] = "Player-Self"
helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 4998,
    spellId = 19834,
    isHelpful = true,
    isFromPlayerOrPlayerPet = true,
    sourceUnit = nil,
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 6 and #whispers == 6, "a true player-or-pet flag with the player's caster GUID must be classified as self-cast")

helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 4997,
    spellId = 19835,
    isHelpful = true,
    isFromPlayerOrPlayerPet = true,
    sourceUnit = "player",
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 6 and #whispers == 6, "a true player-or-pet flag with sourceUnit player must be classified as self-cast")

casterByAuraInstanceID[4999] = "Player-Self"
helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 4999,
    spellId = 2383,
    isHelpful = true,
    isFromPlayerOrPlayerPet = true,
    sourceUnit = nil,
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 6 and #whispers == 6, "a self-cast aura must be ignored without entering anonymous correlation")

helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 5000,
    spellId = 1229741,
    isHelpful = true,
    isFromPlayerOrPlayerPet = true,
    sourceUnit = "player",
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 6 and #whispers == 6, "a player-owned secondary aura must be ignored without entering anonymous correlation")

helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 5001,
    spellId = 1784,
    isHelpful = true,
    isFromPlayerOrPlayerPet = true,
    sourceUnit = nil,
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 6 and #whispers == 6, "the player's Stealth aura must be ignored before caster correlation")
for _, message in ipairs(printed) do
    assert(not string.find(message, "Waiting briefly to identify the caster of buff spell 1784", 1, true), "Stealth must not be described as a prospective external buff")
end

local printedBeforeSystemAura = #printed
helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 5002,
    spellId = 2479,
    isHelpful = true,
    sourceUnit = nil,
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 6 and #whispers == 6, "Honorless Target must be ignored before caster correlation")
assert(#printed == printedBeforeSystemAura, "system aura 2479 must produce no caster-resolution or scan debug")

local printedBeforePaladinState = #printed
helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 5003,
    spellId = 2183391,
    isHelpful = true,
    sourceUnit = "player",
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 6 and #whispers == 6, "player-owned Paladin state 2183391 must remain a negative case")
assert(#printed == printedBeforePaladinState + 1, "2183391 may emit only its explicit ignored-owner debug line")
assert(string.find(printed[#printed], "Ignored buff spell 2183391", 1, true), "2183391 should retain the confirmed ignored-owner classification")

helpfulAuras[#helpfulAuras + 1] = {
    auraInstanceID = 5004,
    spellId = 8072,
    isHelpful = true,
    sourceUnit = "pet",
}
eventHandler(nil, "UNIT_AURA", "player", nil)
assert(#scheduled == 6 and #whispers == 6, "a totem-owned aura must be ignored without entering anonymous correlation")

print("Forever direct aura caster GUID tests passed")
