local ADDON_NAME = ...

local MIN_DELAY_SECONDS = 3
local MAX_DELAY_SECONDS = 10
local CASTER_COOLDOWN_SECONDS = 10 * 60
local CAST_MATCH_WINDOW_SECONDS = 2.5
local CAST_CORRELATION_DELAY_SECONDS = 0.5
local WORLD_ENTRY_BASELINE_DELAY_SECONDS = 2

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

-- Confirmed player-owned or system-owned auras that can appear without a
-- usable source. They must never enter external-caster correlation.
local IGNORED_AURA_SPELL_IDS = {
    [1784] = true,    -- Stealth
    [2383] = true,    -- Find Herbs
    [2479] = true,    -- Honorless Target (zone/hearth system state)
    [8072] = true,    -- Stoneskin Totem
    [1229741] = true, -- observed internal/secondary player aura
}

local frame = CreateFrame("Frame")
local pendingByCaster = {}
local lastThankedByCaster = {}
local lastMessageIndexByCaster = {}
local recentCastsBySpellID = {}
local recentTargetedCasts = {}
local sentCastTargetsByGUID = {}
local pendingAnonymousAuraBySpellID = {}
local knownHelpfulAuras = {}
local auraSnapshotInitialized = false
local auraDetectionArmed = false
local worldEntryBaselineToken
local playerGUID
local debugEnabled = false

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
    if debugEnabled then
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

local function IsForeverClient()
    if WOW_PROJECT_FOREVER and WOW_PROJECT_ID == WOW_PROJECT_FOREVER then
        return true
    end

    -- WoW Forever currently reports interface 1.60.x but does not expose the
    -- WOW_PROJECT_FOREVER constant on every beta build.
    local interfaceVersion = GetBuildInfo and select(4, GetBuildInfo())
    return interfaceVersion and interfaceVersion >= 16000 and interfaceVersion < 17000
end

local function IsModernRestrictedClient()
    return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE or IsForeverClient()
end

local function SendWhisper(message, target)
    if C_ChatInfo and C_ChatInfo.SendChatMessage then
        C_ChatInfo.SendChatMessage(message, "WHISPER", nil, target)
    else
        SendChatMessage(message, "WHISPER", nil, target)
    end
end

local function GroupUnitMatchesCaster(unit, casterKey, targetName)
    if not UnitExists then
        return false
    end

    local unitExists = UnitExists(unit)
    if IsSecret(unitExists) or not unitExists then
        return false
    end

    local unitGUID = UnitGUID and UnitGUID(unit)
    if unitGUID and not IsSecret(unitGUID) and casterKey and unitGUID == casterKey then
        return true
    end

    if not UnitFullName or not targetName or IsSecret(targetName) then
        return false
    end

    local name, realm = UnitFullName(unit)
    if not name or IsSecret(name) or IsSecret(realm) then
        return false
    end

    return targetName == name or (realm and realm ~= "" and targetName == name .. "-" .. realm)
end

local function IsCasterInPlayersGroup(casterKey, targetName)
    if not IsGrouped() then
        return false
    end

    for index = 1, 4 do
        if GroupUnitMatchesCaster("party" .. index, casterKey, targetName) then
            return true
        end
    end

    for index = 1, 40 do
        if GroupUnitMatchesCaster("raid" .. index, casterKey, targetName) then
            return true
        end
    end

    return false
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

local function ScheduleThanks(casterKey, targetName, buffDetectedAt)
    if not IsEnabled() or not casterKey or not targetName or targetName == "" then
        return false
    end

    if casterKey == playerGUID then
        return false
    end

    -- Being grouped does not make every nearby player a group member. Suppress
    -- only the caster who is actually represented by a party or raid unit.
    if IsCasterInPlayersGroup(casterKey, targetName) then
        return false
    end

    -- Forever can expose a different transient GUID route for separate auras
    -- from the same visible player. The normalized whisper recipient is the
    -- stable per-realm identity used for coalescing and cooldowns.
    local responseKey = targetName
    if pendingByCaster[responseKey] then
        return false
    end

    local now = GetTime()
    local lastThanked = lastThankedByCaster[responseKey]
    if lastThanked and now - lastThanked < CASTER_COOLDOWN_SECONDS then
        return false
    end

    local token = {}
    pendingByCaster[responseKey] = token

    local totalDelay = math.random(MIN_DELAY_SECONDS * 10, MAX_DELAY_SECONDS * 10) / 10
    local elapsed = buffDetectedAt and math.max(0, now - buffDetectedAt) or 0
    local delay = math.max(0, totalDelay - elapsed)
    C_Timer.After(delay, function()
        if pendingByCaster[responseKey] ~= token then
            return
        end

        pendingByCaster[responseKey] = nil

        if not IsEnabled() then
            return
        end

        -- Forever and modern Retail restrict aura and chat data during combat.
        -- Dropping the whisper is safer than causing a protected-action error.
        if (IsModernRestrictedClient() and InCombatLockdown()) or IsChatMessagingLockedDown() then
            return
        end

        if IsCasterInPlayersGroup(casterKey, targetName) then
            return
        end

        SendWhisper(PickMessage(responseKey), targetName)
        Debug("Submitted a thank-you whisper to " .. targetName .. ".")
        lastThankedByCaster[responseKey] = GetTime()
    end)

    return true
end

local function GetWhisperTargetName(name, realm)
    if not name or IsSecret(name) or IsSecret(realm) or type(name) ~= "string" or name == "" then
        return nil
    end

    -- Forever chat rejects realm-qualified player targets even when its unit
    -- APIs expose a realm label. Always use the bare display name there.
    if IsForeverClient() then
        return name
    end

    -- Other modern branches retain the conventional cross-realm suffix.
    local _, playerRealm = UnitFullName("player")
    if IsSecret(playerRealm) then
        return nil
    end

    if not realm or realm == "" or not playerRealm or playerRealm == "" or realm == playerRealm then
        return name
    end

    return name .. "-" .. realm
end

local function GetFullUnitName(unit)
    local name, realm = UnitFullName(unit)
    return GetWhisperTargetName(name, realm)
end

local function GetCasterFromUnit(unit)
    if not unit or IsSecret(unit) or not UnitExists(unit) then
        return nil, nil, false
    end

    local casterGUID = UnitGUID(unit)
    if casterGUID and not IsSecret(casterGUID) and casterGUID == playerGUID then
        return nil, nil, true
    end

    local isPlayer = UnitIsPlayer(unit)
    if IsSecret(isPlayer) then
        return nil, nil, false
    end

    if not isPlayer then
        return nil, nil, true
    end

    if not casterGUID or IsSecret(casterGUID) then
        return nil, nil, false
    end

    local targetName = GetFullUnitName(unit)
    if not targetName then
        return nil, nil, true
    end

    return casterGUID, targetName, true
end

local function GetVisiblePlayerNameByGUID(casterGUID)
    if not casterGUID or IsSecret(casterGUID) or not UnitExists or not UnitGUID then
        return nil
    end

    local function MatchUnit(unit)
        local unitExists = UnitExists(unit)
        if IsSecret(unitExists) or not unitExists then
            return nil
        end

        local unitGUID = UnitGUID(unit)
        if not unitGUID or IsSecret(unitGUID) or unitGUID ~= casterGUID then
            return nil
        end

        return GetFullUnitName(unit)
    end

    for _, unit in ipairs({ "target", "focus", "mouseover", "softfriend", "softinteract" }) do
        local targetName = MatchUnit(unit)
        if targetName then
            return targetName
        end
    end

    for index = 1, 4 do
        local targetName = MatchUnit("party" .. index)
        if targetName then
            return targetName
        end
    end

    for index = 1, 40 do
        local targetName = MatchUnit("raid" .. index)
        if targetName then
            return targetName
        end
    end

    for index = 1, 40 do
        local targetName = MatchUnit("nameplate" .. index)
        if targetName then
            return targetName
        end
    end

    return nil
end

local function GetFullPlayerNameFromGUID(casterGUID)
    if not casterGUID or IsSecret(casterGUID) or casterGUID == playerGUID then
        return nil
    end

    -- Forever's GUID-only lookup can shorten multi-word character names even
    -- though a visible unit token exposes the complete whisper recipient.
    local visibleName = GetVisiblePlayerNameByGUID(casterGUID)
    if visibleName then
        return visibleName
    end

    if not GetPlayerInfoByGUID then
        return nil
    end

    local _, _, _, _, _, name, realm = GetPlayerInfoByGUID(casterGUID)
    return GetWhisperTargetName(name, realm)
end

local function GetCasterFromAuraInstance(auraInstanceID)
    if IsSecret(auraInstanceID) or type(auraInstanceID) ~= "number"
        or not C_UnitAuras or not C_UnitAuras.GetAuraCasterGUID
    then
        return nil, nil, false
    end

    local casterGUID = C_UnitAuras.GetAuraCasterGUID("player", auraInstanceID)
    if not casterGUID or IsSecret(casterGUID) then
        return nil, nil, false
    end

    if casterGUID == playerGUID then
        return nil, nil, true
    end

    if C_PlayerInfo and C_PlayerInfo.GUIDIsPlayer then
        local isPlayer = C_PlayerInfo.GUIDIsPlayer(casterGUID)
        if IsSecret(isPlayer) then
            return nil, nil, false
        end
        if not isPlayer then
            return nil, nil, true
        end
    elseif type(casterGUID) == "string" and not string.find(casterGUID, "^Player%-") then
        return nil, nil, true
    end

    local targetName = GetFullPlayerNameFromGUID(casterGUID)
    if not targetName then
        return nil, nil, false
    end

    return casterGUID, targetName, true
end

local function TargetNameIsPlayer(targetName)
    if not targetName or IsSecret(targetName) or type(targetName) ~= "string" then
        return false
    end

    local playerName, playerRealm = UnitFullName("player")
    if not playerName or IsSecret(playerName) or IsSecret(playerRealm) then
        return false
    end

    if targetName == playerName then
        return true
    end

    return playerRealm and playerRealm ~= "" and targetName == playerName .. "-" .. playerRealm
end

local function UnitTargetsPlayer(unit)
    if not UnitIsUnit or not unit or IsSecret(unit) or type(unit) ~= "string" then
        return false
    end

    local targetsPlayer = UnitIsUnit(unit .. "target", "player")
    return not IsSecret(targetsPlayer) and targetsPlayer == true
end

local function RememberSentCast(unit, targetName, castGUID)
    if not auraDetectionArmed or InCombatLockdown() or not castGUID or IsSecret(castGUID) then
        return
    end

    local casterGUID = GetCasterFromUnit(unit)
    if not casterGUID then
        return
    end

    if TargetNameIsPlayer(targetName) or UnitTargetsPlayer(unit) then
        sentCastTargetsByGUID[castGUID] = {
            casterKey = casterGUID,
            time = GetTime(),
        }
    end
end

local function RememberSuccessfulCast(unit, castGUID, spellID)
    if not auraDetectionArmed or InCombatLockdown() or IsSecret(spellID) or type(spellID) ~= "number" then
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

    local sentTarget = castGUID and not IsSecret(castGUID) and sentCastTargetsByGUID[castGUID]
    if castGUID and not IsSecret(castGUID) then
        sentCastTargetsByGUID[castGUID] = nil
    end

    local targetedPlayer = UnitTargetsPlayer(unit)
        or (sentTarget and sentTarget.casterKey == casterGUID and now - sentTarget.time <= CAST_MATCH_WINDOW_SECONDS)

    if targetedPlayer then
        for index = #recentTargetedCasts, 1, -1 do
            local cast = recentTargetedCasts[index]
            if now - cast.time > CAST_MATCH_WINDOW_SECONDS or cast.casterKey == casterGUID then
                table.remove(recentTargetedCasts, index)
            end
        end

        recentTargetedCasts[#recentTargetedCasts + 1] = {
            casterKey = casterGUID,
            targetName = targetName,
            time = now,
        }

        Debug("Saw " .. targetName .. " finish a spell while targeting you.")
    end
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

local function FindRecentTargetedCaster()
    local now = GetTime()
    local match

    for index = #recentTargetedCasts, 1, -1 do
        local cast = recentTargetedCasts[index]
        if now - cast.time > CAST_MATCH_WINDOW_SECONDS then
            table.remove(recentTargetedCasts, index)
        elseif not match then
            match = cast
        elseif match.casterKey ~= cast.casterKey then
            return nil, nil
        end
    end

    wipe(recentTargetedCasts)
    if match then
        return match.casterKey, match.targetName
    end

    return nil, nil
end

local function GetRefreshedAuraCaster(auraInstanceID)
    if IsSecret(auraInstanceID) or type(auraInstanceID) ~= "number"
        or not C_UnitAuras or not C_UnitAuras.GetAuraDataByAuraInstanceID
    then
        return nil, nil, false
    end

    local casterGUID, targetName, casterKnown = GetCasterFromAuraInstance(auraInstanceID)
    if casterKnown then
        return casterGUID, targetName, true
    end

    local refreshedAura = C_UnitAuras.GetAuraDataByAuraInstanceID("player", auraInstanceID)
    if not refreshedAura or IsSecret(refreshedAura) then
        return nil, nil, false
    end

    local refreshedSourceUnit = refreshedAura.sourceUnit
    if IsSecret(refreshedSourceUnit) then
        return nil, nil, false
    end

    return GetCasterFromUnit(refreshedSourceUnit)
end

local function QueueAnonymousAuraMatch(spellID, auraInstanceID)
    if IsSecret(spellID) or type(spellID) ~= "number" then
        Debug("A new helpful aura arrived, but WoW did not expose its caster or spell.")
        return
    end

    local token = {}
    local detectedAt = GetTime()
    pendingAnonymousAuraBySpellID[spellID] = token

    Debug("Waiting briefly to identify the caster of buff spell " .. spellID .. ".")

    C_Timer.After(CAST_CORRELATION_DELAY_SECONDS, function()
        if pendingAnonymousAuraBySpellID[spellID] ~= token then
            return
        end

        pendingAnonymousAuraBySpellID[spellID] = nil

        if not IsEnabled() or InCombatLockdown() then
            return
        end

        local casterGUID, targetName, casterKnown = GetRefreshedAuraCaster(auraInstanceID)
        if casterKnown and not casterGUID then
            Debug("Ignored buff spell " .. spellID .. " because its caster is you or a non-player unit.")
            return
        end
        if not casterGUID then
            casterGUID, targetName = FindRecentCaster(spellID)
        end
        if not casterGUID then
            casterGUID, targetName = FindRecentTargetedCaster()
        end
        if not casterGUID or not targetName then
            Debug("WoW did not expose one unambiguous caster for buff spell " .. spellID .. ".")
            return
        end

        if ScheduleThanks(casterGUID, targetName, detectedAt) then
            Debug("Matched buff spell " .. spellID .. " to " .. targetName .. ".")
        end
    end)
end

local function HandleAura(aura)
    if not aura or IsSecret(aura) then
        return false
    end

    local isHelpful = aura.isHelpful
    local isFromPlayerOrPlayerPet = aura.isFromPlayerOrPlayerPet
    local sourceUnit = aura.sourceUnit
    local spellID = aura.spellId
    local auraInstanceID = aura.auraInstanceID

    if IsSecret(isHelpful) or IsSecret(isFromPlayerOrPlayerPet) or IsSecret(spellID) then
        return false
    end

    if IsSecret(sourceUnit) then
        sourceUnit = nil
    end

    if IsSecret(auraInstanceID) then
        auraInstanceID = nil
    end

    if not isHelpful then
        return false
    end

    if type(spellID) == "number" and IGNORED_AURA_SPELL_IDS[spellID] then
        return false
    end

    local casterGUID, targetName, casterKnown = GetCasterFromUnit(sourceUnit)
    if not casterKnown then
        casterGUID, targetName, casterKnown = GetCasterFromAuraInstance(auraInstanceID)
    end
    if casterKnown and not casterGUID then
        Debug("Ignored buff spell " .. (spellID or "unknown") .. " because its caster is you or a non-player unit.")
        return false
    end
    if not casterGUID and isFromPlayerOrPlayerPet == false then
        Debug("Ignored buff spell " .. (spellID or "unknown") .. " because WoW marked it as non-player-owned.")
        return false
    end
    if not casterGUID then
        -- isFromPlayerOrPlayerPet means any player, not specifically the local
        -- player. Forever sometimes reports UNIT_AURA before the nearby
        -- caster's UNIT_SPELLCAST_SUCCEEDED event, so wait briefly for an
        -- otherwise unidentified player-owned aura.
        QueueAnonymousAuraMatch(spellID, auraInstanceID)
        return true
    end

    if not casterGUID or not targetName then
        Debug("A new helpful aura arrived, but WoW did not expose its caster.")
        return false
    end

    if ScheduleThanks(casterGUID, targetName) then
        Debug("Detected a buff from " .. targetName .. ".")
        return true
    end

    return false
end

local function GetAuraSnapshotKey(aura)
    if not aura or IsSecret(aura) then
        return nil
    end

    local auraInstanceID = aura.auraInstanceID
    if not IsSecret(auraInstanceID) and (type(auraInstanceID) == "number" or type(auraInstanceID) == "string") then
        return "instance:" .. auraInstanceID
    end

    local spellID = aura.spellId
    if not IsSecret(spellID) and type(spellID) == "number" then
        return "spell:" .. spellID
    end

    return nil
end

local function ForEachHelpfulAura(callback)
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
        for index = 1, 255 do
            local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HELPFUL")
            if IsSecret(aura) then
                return false
            end

            if not aura then
                return true
            end

            callback(aura)
        end

        return true
    end

    if AuraUtil and AuraUtil.ForEachAura then
        AuraUtil.ForEachAura("player", "HELPFUL", nil, function(aura)
            if aura and not IsSecret(aura) then
                callback(aura)
            end
            return false
        end, true)
        return true
    end

    return false
end

local function RefreshHelpfulAuraSnapshot(processNewAuras)
    if InCombatLockdown() then
        return false
    end

    local currentAuras = {}
    local newlyAdded = {}
    local scanned = ForEachHelpfulAura(function(aura)
        local key = GetAuraSnapshotKey(aura)
        if key then
            currentAuras[key] = true
            if processNewAuras and auraSnapshotInitialized and not knownHelpfulAuras[key] then
                newlyAdded[#newlyAdded + 1] = aura
            end
        end
    end)

    if not scanned then
        Debug("WoW did not expose a readable helpful-aura scan.")
        return false
    end

    knownHelpfulAuras = currentAuras
    local hadSnapshot = auraSnapshotInitialized
    auraSnapshotInitialized = true

    local processedNewAuras = 0
    if processNewAuras and hadSnapshot then
        for _, aura in ipairs(newlyAdded) do
            if HandleAura(aura) then
                processedNewAuras = processedNewAuras + 1
            end
        end
    end

    return true, #newlyAdded, processedNewAuras
end

local function HandleUnitAura(updateInfo)
    -- Forever may omit the modern incremental payload entirely. Prefer it
    -- when usable, otherwise diff a complete helpful-aura snapshot.
    if InCombatLockdown() then
        return
    end

    if not auraDetectionArmed then
        -- Aura events replay the character's existing buffs while login and
        -- world entry are still settling. Keep the baseline current, but do
        -- not treat any of those auras as a genuinely new application.
        RefreshHelpfulAuraSnapshot(false)
        return
    end

    local usedIncrementalUpdate = false
    if updateInfo and not IsSecret(updateInfo) then
        local isFullUpdate = updateInfo.isFullUpdate
        if not IsSecret(isFullUpdate) and not isFullUpdate then
            local addedAuras = updateInfo.addedAuras
            if not IsSecret(addedAuras) and type(addedAuras) == "table" then
                usedIncrementalUpdate = true
                for _, aura in ipairs(addedAuras) do
                    HandleAura(aura)
                end
            end
        end
    end

    if usedIncrementalUpdate then
        RefreshHelpfulAuraSnapshot(false)
    else
        local scanned, _, processedNewAuras = RefreshHelpfulAuraSnapshot(true)
        if scanned and processedNewAuras and processedNewAuras > 0 then
            Debug("UNIT_AURA supplied no incremental data; scanning current helpful auras.")
        end
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
        frame:RegisterEvent("UNIT_AURA")
        frame:RegisterEvent("UNIT_SPELLCAST_SENT")
        frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    else
        frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
end

local function ResetTransientDetectionState()
    worldEntryBaselineToken = nil
    auraDetectionArmed = false
    auraSnapshotInitialized = false
    knownHelpfulAuras = {}
    wipe(pendingByCaster)
    wipe(recentCastsBySpellID)
    wipe(recentTargetedCasts)
    wipe(sentCastTargetsByGUID)
    wipe(pendingAnonymousAuraBySpellID)
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        ThanksForTheBuffForeverDB = ThanksForTheBuffForeverDB or {}
        if ThanksForTheBuffForeverDB.enabled == nil then
            ThanksForTheBuffForeverDB.enabled = true
        end

        -- Diagnostics are deliberately session-only. Clear the legacy saved
        -- flag so upgrades from a test build cannot spam ordinary gameplay.
        ThanksForTheBuffForeverDB.debug = nil
        debugEnabled = false
        return
    end

    if event == "PLAYER_LOGIN" then
        playerGUID = UnitGUID("player")
        ResetTransientDetectionState()
        ConfigureDetection()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        ResetTransientDetectionState()
        RefreshHelpfulAuraSnapshot(false)

        -- Forever can restore long-lived auras after PLAYER_ENTERING_WORLD.
        -- Absorb those late login/reload updates into a second baseline before
        -- arming detection, so an old buff can never schedule a whisper.
        local token = {}
        worldEntryBaselineToken = token
        C_Timer.After(WORLD_ENTRY_BASELINE_DELAY_SECONDS, function()
            if worldEntryBaselineToken ~= token then
                return
            end

            auraDetectionArmed = RefreshHelpfulAuraSnapshot(false)
            if auraDetectionArmed then
                worldEntryBaselineToken = nil
            end
        end)
        return
    end

    if event == "UNIT_AURA" then
        if arg1 == "player" then
            HandleUnitAura(arg2)
        end
        return
    end

    if event == "UNIT_SPELLCAST_SENT" then
        RememberSentCast(arg1, arg2, arg3)
        return
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        RememberSuccessfulCast(arg1, arg2, arg3)
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
        wipe(pendingAnonymousAuraBySpellID)
        Print("is now disabled.")
    elseif command == "status" or command == "" then
        Print(IsEnabled() and "is enabled." or "is disabled.")
        Print("Use /tftbf on, /tftbf off, or /tftbf debug.")
    elseif command == "debug" then
        debugEnabled = not debugEnabled
        Print(debugEnabled and "debug messages are now on for this session." or "debug messages are now off.")
    else
        Print("Commands: /tftbf on, /tftbf off, /tftbf status, /tftbf debug")
    end
end
