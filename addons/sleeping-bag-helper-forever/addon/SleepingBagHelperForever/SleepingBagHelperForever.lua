local addonName, S = ...

S = S or {}

local TITLE = "Sleeping Bag Helper: Forever"
local VERSION = "0.1.5"
local COZY_SLEEPING_BAG_ITEM_ID = 211527
local UNROLL_BAG_SPELL_ID = 429961
local DUPLICATE_WINDOW = 30
local PARTY_MARKER = 5 -- Moon
local PARTY_MARKER_DURATION = 180

local DEFAULTS = {
    enabled = true,
    soloAnnouncements = true,
    partyInstructions = true,
    partyMarker = true,
    markerSound = true,
}

local SOLO_MESSAGE = "Using my sleeping bag - invite me if you want the XP buff too."
local PARTY_MESSAGE = "Sleeping bag is down: stand on it and stay still. The XP buff gains 1% each minute, stacking up to 3%."

local function printMessage(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd45cSleeping Bag Helper:|r " .. tostring(message))
    end
end

local function copyDefaults()
    return {
        enabled = DEFAULTS.enabled,
        soloAnnouncements = DEFAULTS.soloAnnouncements,
        partyInstructions = DEFAULTS.partyInstructions,
        partyMarker = DEFAULTS.partyMarker,
        markerSound = DEFAULTS.markerSound,
    }
end

local function initializeDatabase()
    if type(SleepingBagHelperForeverDB) ~= "table" then
        SleepingBagHelperForeverDB = copyDefaults()
    end
    for key, value in pairs(DEFAULTS) do
        if type(SleepingBagHelperForeverDB[key]) ~= "boolean" then
            SleepingBagHelperForeverDB[key] = value
        end
    end
    S.db = SleepingBagHelperForeverDB
end

local function isGrouped()
    if type(IsInGroup) ~= "function" then return false end
    local ok, grouped = pcall(IsInGroup)
    return ok and grouped and true or false
end

local function createAnnouncementButton()
    if S.announceButton then return S.announceButton end

    local button = CreateFrame("Button", "SleepingBagHelperForeverAnnounceButton", UIParent,
        "UIPanelButtonTemplate")
    button:SetSize(240, 34)
    button:SetPoint("CENTER", UIParent, "CENTER", 0, -170)
    button:SetText("Prepare Sleeping Bag Message")
    button:SetFrameStrata("DIALOG")
    button:SetClampedToScreen(true)
    button:SetScript("OnClick", function(self)
        if type(ChatFrame_OpenChat) == "function" and self.pendingText then
            ChatFrame_OpenChat(self.pendingText)
            printMessage("Message prepared. Press Enter to send it.")
        else
            printMessage("The chat box could not be opened.")
        end
        self:Hide()
    end)
    button:Hide()
    S.announceButton = button
    return button
end

local function prepareAnnouncement(grouped)
    local button = createAnnouncementButton()
    local channel = grouped and "/p " or "/say "
    local message = grouped and PARTY_MESSAGE or SOLO_MESSAGE
    button.pendingText = channel .. message
    button:Show()
    printMessage("Click Prepare Sleeping Bag Message, then press Enter to send it.")
    return true
end

local function resolveBagSpell()
    local spellName, spellID
    if C_Item and type(C_Item.GetItemSpell) == "function" then
        local ok, name, id = pcall(C_Item.GetItemSpell, COZY_SLEEPING_BAG_ITEM_ID)
        if ok then spellName, spellID = name, id end
    elseif type(GetItemSpell) == "function" then
        local ok, name, id = pcall(GetItemSpell, COZY_SLEEPING_BAG_ITEM_ID)
        if ok then spellName, spellID = name, id end
    end
    if tonumber(spellID) then
        S.bagSpellID = tonumber(spellID)
        S.bagSpellName = spellName
    end
    return S.bagSpellID, S.bagSpellName
end

local function isBagSpell(spellID)
    spellID = tonumber(spellID)
    if not spellID then return false end
    return spellID == UNROLL_BAG_SPELL_ID or spellID == tonumber(S.bagSpellID)
end

local function bagCooldownStart()
    local getCooldown = C_Container and C_Container.GetItemCooldown or GetItemCooldown
    if type(getCooldown) ~= "function" then return 0 end
    local ok, startTime = pcall(getCooldown, COZY_SLEEPING_BAG_ITEM_ID)
    return ok and tonumber(startTime) or 0
end

local function playMarkerSound()
    if not S.db.markerSound or type(PlaySound) ~= "function" then return end
    local sound = SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959
    pcall(PlaySound, sound, "Master")
end

function S.MarkPlayer()
    if not S.db or not S.db.enabled or not S.db.partyMarker or not isGrouped() then return false end
    playMarkerSound()
    return true
end

function S.Announce(now)
    if not S.db or not S.db.enabled then return false end

    now = tonumber(now) or (type(GetTime) == "function" and GetTime()) or 0
    if S.lastAnnouncementAt and now - S.lastAnnouncementAt < DUPLICATE_WINDOW then
        return false
    end

    local grouped = isGrouped()
    if grouped and not S.db.partyInstructions then return false end
    if not grouped and not S.db.soloAnnouncements then return false end

    local prepared = prepareAnnouncement(grouped)
    if prepared then S.lastAnnouncementAt = now end
    return prepared
end

function S.HandleSpellcast(unit, spellID)
    if unit ~= "player" or not isBagSpell(spellID) then return false end
    return S.Announce()
end

local function onOff(value)
    value = string.lower(tostring(value or ""))
    if value == "on" or value == "1" or value == "true" then return true end
    if value == "off" or value == "0" or value == "false" then return false end
    return nil
end

local function enabledText(value)
    return value and "on" or "off"
end

local function showStatus()
    printMessage("Version " .. VERSION .. ". Add-on " .. enabledText(S.db.enabled)
        .. "; solo /say " .. enabledText(S.db.soloAnnouncements)
        .. "; party instructions " .. enabledText(S.db.partyInstructions)
        .. "; party Moon marker " .. enabledText(S.db.partyMarker)
        .. "; marker sound " .. enabledText(S.db.markerSound) .. ".")
end

local function handleSlash(message)
    local command, value = string.match(message or "", "^%s*(%S*)%s*(.-)%s*$")
    command = string.lower(command or "")

    if command == "on" then
        S.db.enabled = true
        printMessage("Announcements enabled.")
    elseif command == "off" then
        S.db.enabled = false
        printMessage("Announcements disabled.")
    elseif command == "solo" or command == "party" or command == "marker" or command == "sound" then
        local state = onOff(value)
        if state == nil then
            printMessage("Use /sbf " .. command .. " on or /sbf " .. command .. " off.")
            return
        end
        local key = command == "solo" and "soloAnnouncements"
            or command == "party" and "partyInstructions"
            or command == "marker" and "partyMarker"
            or "markerSound"
        S.db[key] = state
        local label = command == "solo" and "Solo /say announcements "
            or command == "party" and "Party instructions "
            or command == "marker" and "Party Moon marker "
            or "Marker sound "
        printMessage(label
            .. enabledText(state) .. ".")
    elseif command == "reset" then
        SleepingBagHelperForeverDB = copyDefaults()
        S.db = SleepingBagHelperForeverDB
        printMessage("Settings reset to defaults.")
        showStatus()
    elseif command == "test" then
        S.lastAnnouncementAt = nil
        if S.Announce() then printMessage("Test button prepared.") end
    elseif command == "debug" then
        resolveBagSpell()
        printMessage("Cozy Sleeping Bag item " .. COZY_SLEEPING_BAG_ITEM_ID
            .. "; resolved spell " .. tostring(S.bagSpellID or "not cached")
            .. (S.bagSpellName and (" (" .. S.bagSpellName .. ")") or "") .. ".")
        printMessage("Last player spell event: " .. tostring(S.lastSpellEvent or "none")
            .. "; spell ID " .. tostring(S.lastSpellID or "none") .. ".")
        showStatus()
    elseif command == "status" then
        showStatus()
    else
        printMessage("Commands: /sbf on | off | status | test | debug | solo on/off | party on/off | marker on/off | sound on/off | reset")
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_SENT")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedName = ...
        if loadedName ~= addonName then return end
        initializeDatabase()
        SLASH_SLEEPINGBAGHELPERFOREVER1 = "/sbf"
        SLASH_SLEEPINGBAGHELPERFOREVER2 = "/sleepingbag"
        SlashCmdList.SLEEPINGBAGHELPERFOREVER = handleSlash
        createAnnouncementButton()
        printMessage("Loaded safe build 0.1.5. Sleeping-bag casts prepare a message for you to send.")
        return
    end


    local unit, spellID
    if event == "UNIT_SPELLCAST_SENT" then
        unit, _, _, spellID = ...
    else
        unit, _, spellID = ...
    end
    if unit ~= "player" then return end

    S.lastSpellEvent = event
    S.lastSpellID = tonumber(spellID)
    S.HandleSpellcast(unit, spellID)
end)

S.TITLE = TITLE
S.VERSION = VERSION
S.COZY_SLEEPING_BAG_ITEM_ID = COZY_SLEEPING_BAG_ITEM_ID
S.UNROLL_BAG_SPELL_ID = UNROLL_BAG_SPELL_ID
S.SOLO_MESSAGE = SOLO_MESSAGE
S.PARTY_MESSAGE = PARTY_MESSAGE
S.PARTY_MARKER = PARTY_MARKER
S.PARTY_MARKER_DURATION = PARTY_MARKER_DURATION
