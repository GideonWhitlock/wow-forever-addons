WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local SECRET = {}
local registered = {}
local scheduled = {}
local whispers = {}
local eventHandler

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
        SetScript = function(_, _, callback) eventHandler = callback end,
    }
end

function GetTime() return 100 end
function GetBuildInfo() return "1.60.1.70450", "70450", "Oct 2026", 16001 end
function InCombatLockdown() return false end
function IsInGroup() return false end
function issecretvalue(value) return value == SECRET end
function UnitExists(unit) return unit == "player" or unit == "target" end
function UnitIsPlayer() return true end
function UnitGUID(unit) return unit == "player" and "Player-Self" or "Player-Yserael" end
function UnitFullName(unit)
    if unit == "player" then return "Kio", "Zanim" end
    return "Yserael", "Dawnwhisper"
end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")

eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")
eventHandler(nil, "PLAYER_LOGIN")
eventHandler(nil, "PLAYER_ENTERING_WORLD")

assert(not registered.COMBAT_LOG_EVENT_UNFILTERED, "Forever must not register the protected combat log")

eventHandler(nil, "UNIT_AURA", "player", {
    isFullUpdate = false,
    addedAuras = {
        {
            isHelpful = true,
            isFromPlayerOrPlayerPet = SECRET,
            spellId = SECRET,
            sourceUnit = "target",
        },
    },
})

assert(#scheduled == 1, "readable exact caster data should survive protected ownership and spell fields")
scheduled[1].callback()
assert(#whispers == 1, "the readable target caster should receive a thank-you")
assert(whispers[1].target == "Yserael Dawnwhisper", "Forever should retain both parts of the target's name")

print("Forever protected-field regression tests passed")
