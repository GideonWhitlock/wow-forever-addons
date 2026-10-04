local ADDON_NAME = ...

local MIN_DELAY_SECONDS = 3
local MAX_DELAY_SECONDS = 10
local CASTER_COOLDOWN_SECONDS = 10 * 60
local CAST_MATCH_WINDOW_SECONDS = 2.5

local THANK_YOU_MESSAGES = {
    "thanks!",
    "ty!",
    "cheers!",
    "thank you!",
    "thx!",
    "tyvm!",
    "thanks :)",
    "ty :)",
    "nice one!",
    "ta!",
    "legend!",
    "appreciate it!",
    "thanks mate!",
    "cheers mate!",
    "much appreciated!",
}

local frame = CreateFrame("Frame")
local pendingByCaster = {}
local lastThankedByCaster = {}
local lastMessageIndexByCaster = {}
local recentCastsBySpellID = {}
local playerGUID

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff7dd3fcThanks for Buffing: Forever|r " .. message)
end

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function IsEnabled()
    return ThanksForTheBuffForeverDB and ThanksForTheBuffForeverDB.enabled ~= false
end

local function Debug(message)
    if ThanksForTheBuffForeverDB and ThanksForTheBuffForeverDB.debug then
        Print("Debug: " .. message)
    end
end

local function IsGrouped()
    return IsInGroup and IsInGroup()
end

local function IsChatMessagingLockedDown()
    if not C_ChatInfo or not C_ChatInfo.InChatMessagingLockdown then
        return false
    end

    local locked = C_ChatInfo.InChatMessagingLockdown()
    return IsSecret(locked) or locked == true
end

local function IsModernRestrictedClient()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return true
    end

    if WOW_PROJECT_FOREVER and WOW_PROJECT_ID == WOW_PROJECT_FOREVER then
        return true
    end

    -- WoW Forever currently reports interface 1.60.x but does not expose the
    -- WOW_PROJECT_FOREVER constant on every beta build.
    local interfaceVersion = GetBuildInfo and select(4, GetBuildInfo())
    return interfaceVersion and interfaceVersion >= 16000 and interfaceVersion < 17000
end

local function SendWhisper(message, target)
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        C_ChatInfo.SendChatMessage(message, "WHISPER", nil, target)
    else
        SendChatMessage(message, "WHISPER", nil, target)
    end
end

local function PickMessage(casterKey)
    local previousIndex = lastMessageIndexByCaster[casterKey]
    local index = math.random(1, #THANK_YOU_MESSAGES)

    if #THANK_YOU_MESSAGES > 1 and index == previousIndex then
        index = (index % #THANK_YOU_MESSAGES) + 1
    end

    lastMessageIndexByCaster[casterKey] = index
    return THANK_YOU_MESSAGES[index]
end

local function ScheduleThanks(casterKey, targetName)
    if not IsEnabled() or IsGrouped() or not casterKey or not targetName or targetName == "" then
        return
    end

    if casterKey == playerGUID or pendingByCaster[casterKey] then
        return
    end

    local now = GetTime()
    local lastThanked = lastThankedByCaster[casterKey]
    if lastThanked and now - lastThanked < CASTER_COOLDOWN_SECONDS then
        return
    end

    local token = {}
    pendingByCaster[casterKey] = token

    local delay = math.random(MIN_DELAY_SECONDS * 10, MAX_DELAY_SECONDS * 10) / 10
    C_Timer.After(delay, function()
        if pendingByCaster[casterKey] ~= token then
            return
        end

        pendingByCaster[casterKey] = nil

        if not IsEnabled() or IsGrouped() then
            return
        end

        -- Forever and modern Retail restrict aura and chat data during combat.
        -- Dropping the whisper is safer than causing a protected-action error.
        if (IsModernRestrictedClient() and InCombatLockdown()) or IsChatMessagingLockedDown() then
            return
        end

        SendWhisper(PickMessage(casterKey), targetName)
        lastThankedByCaster[casterKey] = GetTime()
    end)
end

local function GetFullUnitName(unit)
    local name, realm = UnitFullName(unit)
    if not name or IsSecret(name) or IsSecret(realm) then
        return nil
    end

    if realm and realm ~= "" then
        return name .. "-" .. realm
    end

    return name
end

local function GetCasterFromUnit(unit)
    if not unit or IsSecret(unit) or not UnitExists(unit) or not UnitIsPlayer(unit) then
        return nil, nil
    end

    local casterGUID = UnitGUID(unit)
    if not casterGUID or IsSecret(casterGUID) or casterGUID == playerGUID then
        return nil, nil
    end

    return casterGUID, GetFullUnitName(unit)
end

local function RememberSuccessfulCast(unit, spellID)
    if IsGrouped() or InCombatLockdown() or IsSecret(spellID) or type(spellID) ~= "number" then
        return
    end

    local casterGUID, targetName = GetCasterFromUnit(unit)
    if not casterGUID or not targetName then
        return
    end

    local casts = recentCastsBySpellID[spellID] or {}
    local now = GetTime()

    for index = #casts, 1, -1 do
        if now - casts[index].time > CAST_MATCH_WINDOW_SECONDS then
            table.remove(casts, index)
        elseif casts[index].casterKey == casterGUID then
            table.remove(casts, index)
        end
    end

    casts[#casts + 1] = {
        casterKey = casterGUID,
        targetName = targetName,
        time = now,
    }
    recentCastsBySpellID[spellID] = casts
end

local function FindRecentCaster(spellID)
    if IsSecret(spellID) or type(spellID) ~= "number" then
        return nil, nil
    end

    local casts = recentCastsBySpellID[spellID]
    if not casts then
        return nil, nil
    end

    local now = GetTime()
    local match
    for index = #casts, 1, -1 do
        local cast = casts[index]
        if now - cast.time > CAST_MATCH_WINDOW_SECONDS then
            table.remove(casts, index)
        elseif not match then
            match = cast
        elseif match.casterKey ~= cast.casterKey then
            return nil, nil
        end
    end

    recentCastsBySpellID[spellID] = nil
    if match then
        return match.casterKey, match.targetName
    end

    return nil, nil
end

local function HandleAura(aura)
    if not aura then
        return
    end

    local isHelpful = aura.isHelpful
    local sourceUnit = aura.sourceUnit
    local spellID = aura.spellId

    if IsSecret(isHelpful) or IsSecret(sourceUnit) or IsSecret(spellID) then
        return
    end

    if not isHelpful then
        return
    end

    local casterGUID, targetName = GetCasterFromUnit(sourceUnit)
    if not casterGUID then
        -- Forever sometimes omits sourceUnit for a player outside your group.
        -- Correlate the new aura with a spell we just saw a nearby player cast.
        casterGUID, targetName = FindRecentCaster(spellID)
    end

    if not casterGUID or not targetName then
        Debug("A new helpful aura arrived, but WoW did not expose its caster.")
        return
    end

    Debug("Detected a buff from " .. targetName .. ".")
    ScheduleThanks(casterGUID, targetName)
end

local function HandleUnitAura(updateInfo)
    -- UNIT_AURA payloads become restricted in combat on Forever and Retail.
    if InCombatLockdown() or not updateInfo or IsSecret(updateInfo) or updateInfo.isFullUpdate then
        return
    end

    local addedAuras = updateInfo.addedAuras
    if IsSecret(addedAuras) or not addedAuras then
        return
    end

    for _, aura in ipairs(addedAuras) do
        HandleAura(aura)
    end
end

local function HandleCombatLogEvent()
    local _, subevent, _, sourceGUID, sourceName, sourceFlags, _, destinationGUID, _, _, _, _, _, _, auraType =
        CombatLogGetCurrentEventInfo()

    if (subevent ~= "SPELL_AURA_APPLIED" and subevent ~= "SPELL_AURA_REFRESH")
        or auraType ~= "BUFF"
        or destinationGUID ~= playerGUID
        or sourceGUID == playerGUID
        or not sourceName
    then
        return
    end

    if bit.band(sourceFlags or 0, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 then
        return
    end

    ScheduleThanks(sourceGUID, sourceName)
end

local function ConfigureDetection()
    if IsModernRestrictedClient() then
        frame:RegisterUnitEvent("UNIT_AURA", "player")
        frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    else
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        ThanksForTheBuffForeverDB = ThanksForTheBuffForeverDB or {}
        if ThanksForTheBuffForeverDB.enabled == nil then
            ThanksForTheBuffForeverDB.enabled = true
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        playerGUID = UnitGUID("player")
        ConfigureDetection()
        return
    end

    if event == "UNIT_AURA" then
        HandleUnitAura(arg2)
        return
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        RememberSuccessfulCast(arg1, arg3)
        return
    end

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        HandleCombatLogEvent()
    end
end)

SLASH_THANKSFORTHEBUFFFOREVER1 = "/tftbf"
SLASH_THANKSFORTHEBUFFFOREVER2 = "/thanksbuff"
SlashCmdList.THANKSFORTHEBUFFFOREVER = function(input)
    local command = string.lower((input or ""):match("^%s*(.-)%s*$"))

    if command == "on" or command == "enable" then
        ThanksForTheBuffForeverDB.enabled = true
        Print("is now enabled.")
    elseif command == "off" or command == "disable" then
        ThanksForTheBuffForeverDB.enabled = false
        wipe(pendingByCaster)
        Print("is now disabled.")
    elseif command == "status" or command == "" then
        Print(IsEnabled() and "is enabled." or "is disabled.")
        Print("Use /tftbf on, /tftbf off, or /tftbf debug.")
    elseif command == "debug" then
        ThanksForTheBuffForeverDB.debug = not ThanksForTheBuffForeverDB.debug
        Print(ThanksForTheBuffForeverDB.debug and "debug messages are now on." or "debug messages are now off.")
    else
        Print("Commands: /tftbf on, /tftbf off, /tftbf status, /tftbf debug")
    end
end
