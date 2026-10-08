WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local registered = {}
local scheduled = {}
local whispers = {}
local eventHandler
local now = 1500
local grouped = false
local targetingPlayer = {}

local units = {
    nameplate1 = { guid = "Player-Mage", name = "Magebuffer" },
    nameplate2 = { guid = "Player-Paladin", name = "Paladinbuffer" },
    nameplate3 = { guid = "Player-Priest", name = "Priestbuffer" },
    nameplate4 = { guid = "Player-Druid", name = "Druidbuffer" },
    nameplate5 = { guid = "Player-Shaman", name = "Shamanbuffer" },
    nameplate6 = { guid = "Player-Warlock", name = "Warlockbuffer" },
    nameplate7 = { guid = "Player-Other", name = "Otherbuffer" },
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
function GetBuildInfo() return "1.60.1.70205", "70205", "Oct 2026", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return grouped end
function issecretvalue() return false end
function UnitExists(unit) return unit == "player" or units[unit] ~= nil end
function UnitIsPlayer(unit) return UnitExists(unit) end
function UnitIsUnit(left, right)
    if right ~= "player" then return false end
    local unit = string.match(left or "", "^(.-)target$")
    return unit and targetingPlayer[unit] == true or false
end
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
eventHandler(nil, "PLAYER_ENTERING_WORLD")

assert(registered.UNIT_SPELLCAST_SENT, "Forever should register targeted cast metadata")
assert(registered.UNIT_SPELLCAST_SUCCEEDED, "Forever should register completed visible casts")

local families = {
    { label = "Mage Arcane Intellect", castSpellID = 1459, auraSpellID = 1283389, unit = "nameplate1" },
    { label = "Paladin Blessing of Might", castSpellID = 19740, auraSpellID = 1283391, unit = "nameplate2" },
    { label = "Priest Power Word: Fortitude", castSpellID = 1243, auraSpellID = 1283392, unit = "nameplate3" },
    { label = "Druid Mark of the Wild", castSpellID = 1126, auraSpellID = 1283393, unit = "nameplate4" },
    { label = "Shaman Water Breathing", castSpellID = 131, auraSpellID = 1283394, unit = "nameplate5" },
    { label = "Warlock Unending Breath", castSpellID = 5697, auraSpellID = 1283395, unit = "nameplate6", useSentTarget = true },
}

for index, family in ipairs(families) do
    local castGUID = "Cast-" .. index
    targetingPlayer[family.unit] = not family.useSentTarget

    if family.useSentTarget then
        eventHandler(nil, "UNIT_SPELLCAST_SENT", family.unit, "Self", castGUID, family.castSpellID)
    end

    local auraUpdate = {
        isFullUpdate = false,
        addedAuras = {
            {
                auraInstanceID = 2000 + index,
                spellId = family.auraSpellID,
                isHelpful = true,
                sourceUnit = nil,
            },
        },
    }

    if index % 2 == 1 then
        eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", family.unit, castGUID, family.castSpellID)
        eventHandler(nil, "UNIT_AURA", "player", auraUpdate)
    else
        eventHandler(nil, "UNIT_AURA", "player", auraUpdate)
        eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", family.unit, castGUID, family.castSpellID)
    end

    local correlationIndex = (index - 1) * 2 + 1
    assert(#scheduled == correlationIndex, family.label .. " should queue one correlation timer")
    now = now + 0.5
    scheduled[correlationIndex].callback()

    local thanksIndex = correlationIndex + 1
    assert(#scheduled == thanksIndex, family.label .. " should match one targeted caster despite mismatched spell IDs")
    assert(scheduled[thanksIndex].delay >= 2.5 and scheduled[thanksIndex].delay <= 9.5, family.label .. " should preserve the total 3-10 second delay")
    scheduled[thanksIndex].callback()

    assert(#whispers == index, family.label .. " should send exactly one whisper")
    assert(whispers[index].target == units[family.unit].name, family.label .. " should whisper the targeted same-realm caster")
    assert(whispers[index].chatType == "WHISPER", family.label .. " must remain private")
    now = now + 3
end

grouped = true
targetingPlayer.nameplate7 = true
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        { auraInstanceID = 2999, spellId = 1283998, isHelpful = true, sourceUnit = nil },
    },
})
eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate7", "Cast-Grouped-External", 10000)
assert(#scheduled == 13, "a grouped external caster should still queue its correlation timer")
now = now + 0.5
scheduled[13].callback()
assert(#scheduled == 14, "a grouped external caster should still schedule a thank-you after correlation")
scheduled[14].callback()
assert(#whispers == 7 and whispers[7].target == "Otherbuffer", "a grouped external correlated caster should receive one whisper")
grouped = false

targetingPlayer.nameplate1 = true
targetingPlayer.nameplate7 = true
eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate1", "Cast-Ambiguous-1", 10001)
eventHandler(nil, "UNIT_SPELLCAST_SUCCEEDED", "nameplate7", "Cast-Ambiguous-2", 10002)
eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        { auraInstanceID = 3001, spellId = 1283999, isHelpful = true, sourceUnit = nil },
    },
})

assert(#scheduled == 15, "an ambiguous targeted-caster case should queue only its correlation timer")
now = now + 0.5
scheduled[15].callback()
assert(#scheduled == 15, "two different targeted casters must be rejected")
assert(#whispers == 7, "ambiguity must not send a whisper")

print("Forever targeted cast spell-family tests passed")
