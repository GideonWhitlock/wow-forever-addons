local addonName, Q = ...

Q.ADDON_NAME = addonName
Q.TITLE = "LFG Messenger: Forever"
Q.VERSION = "1.0.3"
Q.BLIZZARD_ADDON = "Blizzard_GroupFinder_VanillaStyle"
Q.ICON = "Interface\\Icons\\INV_Letter_15"
Q.DEFAULTS = {
    template = "{class} {role} here",
    suggestionTemplate = "Please invite {target} - {class} {role}.",
    minimap = { hidden = false, angle = 215 },
}

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = copy(child) end
    return result
end

local function merge(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = copy(value)
        elseif type(value) == "table" and type(target[key]) == "table" then
            merge(target[key], value)
        end
    end
    return target
end

function Q.Print(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd45cLFG Messenger:|r " .. tostring(message))
    end
end

function Q.IsSecret(value)
    if type(issecretvalue) ~= "function" then return false end
    local ok, secret = pcall(issecretvalue, value)
    return ok and secret or false
end

function Q.InitializeDB()
    if type(LFGMessengerForeverDB) ~= "table" then
        LFGMessengerForeverDB = type(LFGQuickWhisperForeverDB) == "table"
            and copy(LFGQuickWhisperForeverDB) or {}
    end
    LFGQuickWhisperForeverDB = nil
    Q.db = merge(LFGMessengerForeverDB, Q.DEFAULTS)
    if type(Q.db.template) ~= "string" or Q.db.template == "" then
        Q.db.template = Q.DEFAULTS.template
    end
    Q.db.template = Q.db.template:sub(1, 120)
    if type(Q.db.suggestionTemplate) ~= "string" or Q.db.suggestionTemplate == "" then
        Q.db.suggestionTemplate = Q.DEFAULTS.suggestionTemplate
    end
    Q.db.suggestionTemplate = Q.db.suggestionTemplate:sub(1, 160)
    Q.db.minimap.angle = tonumber(Q.db.minimap.angle) or Q.DEFAULTS.minimap.angle
    Q.db.minimap.hidden = Q.db.minimap.hidden and true or false
end

local function roleTextFromFlags(flags)
    if type(flags) ~= "table" then return "DPS" end
    local roles = {}
    if flags.TANK or flags.tank then roles[#roles + 1] = "Tank" end
    if flags.HEALER or flags.healer then roles[#roles + 1] = "Healer" end
    if flags.DAMAGER or flags.DPS or flags.dps then roles[#roles + 1] = "DPS" end
    return #roles > 0 and table.concat(roles, "/") or "DPS"
end

local function className()
    local localized, token = UnitClass("player")
    if Q.IsSecret(localized) then return "Player" end
    if type(localized) == "string" and localized ~= "" then return localized end
    if token and LOCALIZED_CLASS_NAMES_MALE then return LOCALIZED_CLASS_NAMES_MALE[token] or token end
    return "Player"
end

local function selectedRoleTokens()
    local roles = {}
    if type(GetLFGRoles) == "function" then
        local ok, _, tank, healer, damage = pcall(GetLFGRoles)
        if ok then
            if tank then roles[#roles + 1] = "Tank" end
            if healer then roles[#roles + 1] = "Healer" end
            if damage then roles[#roles + 1] = "DPS" end
        end
    end
    if #roles == 0 and type(UnitGroupRolesAssigned) == "function" then
        local ok, assigned = pcall(UnitGroupRolesAssigned, "player")
        if ok and not Q.IsSecret(assigned) then
            if assigned == "TANK" then roles[1] = "Tank"
            elseif assigned == "HEALER" then roles[1] = "Healer"
            elseif assigned == "DAMAGER" then roles[1] = "DPS" end
        end
    end
    if #roles == 0 then roles[1] = "DPS" end
    return roles
end

function Q.GetRoleText()
    return table.concat(selectedRoleTokens(), "/")
end

function Q.BuildMessage(template)
    template = type(template) == "string" and template or (Q.db and Q.db.template) or Q.DEFAULTS.template
    local playerName = UnitName("player")
    local level = UnitLevel("player")
    if Q.IsSecret(playerName) then playerName = "" end
    if Q.IsSecret(level) then level = "" end
    local values = {
        class = className(),
        role = Q.GetRoleText(),
        name = type(playerName) == "string" and playerName or "",
        level = tostring(type(level) == "number" and level or ""),
    }
    local message = template:gsub("{(%w+)}", function(key)
        return values[key] or ("{" .. key .. "}")
    end)
    message = message:gsub("[\r\n]+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if message == "" then message = values.class .. " " .. values.role .. " here" end
    return message:sub(1, 255)
end

function Q.GetSelectedResultID()
    local frame = _G.LFGBrowseFrame
    local behavior = frame and frame.selectionBehavior
    if not behavior or type(behavior.HasSelection) ~= "function"
        or type(behavior.GetSelectedElementData) ~= "function" then
        return nil, "Select a group first"
    end
    local okHas, hasSelection = pcall(behavior.HasSelection, behavior)
    if not okHas or not hasSelection then return nil, "Select a group first" end
    local okData, data = pcall(behavior.GetSelectedElementData, behavior)
    local element = okData and type(data) == "table" and data[1]
    local resultID = element and element.data and element.data.resultID
    if Q.IsSecret(resultID) or type(resultID) ~= "number" then
        return nil, "Selected group is unavailable"
    end
    return resultID
end

function Q.GetSelectedTarget()
    local resultID, reason = Q.GetSelectedResultID()
    if not resultID then return nil, reason end
    if not (C_LFGList and type(C_LFGList.GetSearchResultInfo) == "function") then
        return nil, "Group Finder information is unavailable"
    end
    local ok, info = pcall(C_LFGList.GetSearchResultInfo, resultID)
    if not ok or type(info) ~= "table" or info.isDelisted then
        return nil, "That listing is no longer available"
    end
    local target = info.leaderName
    if Q.IsSecret(target) then return nil, "Messaging is unavailable during this combat" end
    if type(target) ~= "string" or target == "" then return nil, "Group leader is unavailable" end
    return target, nil, resultID
end

function Q.GetResultPlayer(resultID)
    if not (C_LFGList and type(C_LFGList.GetSearchResultInfo) == "function") then
        return nil, "Group Finder information is unavailable"
    end
    local ok, info = pcall(C_LFGList.GetSearchResultInfo, resultID)
    if not ok or type(info) ~= "table" or info.isDelisted then
        return nil, "That listing is no longer available"
    end
    if info.hasSelf then return nil, "That is your own listing" end
    if tonumber(info.numMembers) ~= 1 then return nil, "Suggest Invite is for individual player listings" end
    local target = info.leaderName
    if Q.IsSecret(target) then return nil, "Player information is unavailable during this combat" end
    if type(target) ~= "string" or target == "" then return nil, "Player name is unavailable" end
    local member
    if type(C_LFGList.GetSearchResultPlayerInfo) == "function" then
        local okMember, value = pcall(C_LFGList.GetSearchResultPlayerInfo, resultID, 1)
        if okMember and type(value) == "table" then member = value end
    end
    local classToken = member and member.classFilename
    local class = classToken and LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classToken]
    if type(class) ~= "string" or class == "" then class = classToken or "Player" end
    local role = roleTextFromFlags(member and member.lfgRoles)
    return { name = target, class = class, role = role, resultID = resultID }
end

function Q.BuildSuggestion(player, template)
    if type(player) ~= "table" then return "" end
    template = type(template) == "string" and template or (Q.db and Q.db.suggestionTemplate)
        or Q.DEFAULTS.suggestionTemplate
    local values = { target = player.name or "", class = player.class or "Player", role = player.role or "DPS" }
    local message = template:gsub("{(%w+)}", function(key)
        return values[key] or ("{" .. key .. "}")
    end)
    message = message:gsub("[\r\n]+", " "):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return message:sub(1, 255)
end

function Q.GetPartyLeader()
    if not IsInGroup or not IsInGroup() then return nil, false, "Join a party first" end
    if UnitIsGroupLeader and UnitIsGroupLeader("player") then
        return UnitName("player"), true
    end
    local count = type(GetNumSubgroupMembers) == "function" and GetNumSubgroupMembers() or 4
    for index = 1, count do
        local unit = "party" .. index
        if UnitExists(unit) and UnitIsGroupLeader(unit) then
            local name = UnitName(unit)
            if Q.IsSecret(name) then return nil, false, "Party leader is unavailable during this combat" end
            if type(name) == "string" and name ~= "" then return name, false end
        end
    end
    return nil, false, "Party leader could not be identified"
end

function Q.ChatLocked()
    if C_ChatInfo and type(C_ChatInfo.InChatMessagingLockdown) == "function" then
        local ok, locked = pcall(C_ChatInfo.InChatMessagingLockdown)
        if ok and locked then return true end
    end
    return false
end

local function sendResultSucceeded(result)
    if result == nil or result == true or result == 0 then return true end
    local enum = Enum and Enum.SendChatMessageResult
    return enum and enum.Success ~= nil and result == enum.Success
end

function Q.OpenPreparedWhisper(target, message)
    if ChatFrameUtil and type(ChatFrameUtil.SendTellWithMessage) == "function" then
        ChatFrameUtil.SendTellWithMessage(target, message)
        return true
    end
    if type(ChatFrame_SendTell) == "function" then
        ChatFrame_SendTell(target)
        local editBox = type(ChatEdit_GetActiveWindow) == "function" and ChatEdit_GetActiveWindow()
        if editBox and type(editBox.SetText) == "function" then editBox:SetText(message) end
        return true
    end
    return false
end

function Q.SendSelected()
    local target, reason = Q.GetSelectedTarget()
    if not target then Q.Print(reason); return false end
    local message = Q.BuildMessage()
    local now = GetTime()
    if Q.lastTarget == target and now - (Q.lastSentAt or 0) < 3 then
        Q.Print("Already sent to " .. target .. ".")
        return false
    end
    if Q.ChatLocked() then
        Q.OpenPreparedWhisper(target, message)
        Q.Print("Chat is restricted here; the message is ready for you to send.")
        return false
    end
    local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    if type(send) == "function" then
        local ok, result = pcall(send, message, "WHISPER", nil, target)
        if ok and sendResultSucceeded(result) then
            Q.lastTarget, Q.lastSentAt = target, now
            local short = Ambiguate and Ambiguate(target, "short") or target
            Q.Print("Sent to " .. short .. ": " .. message)
            if Q.UpdateLFGButton then Q.UpdateLFGButton() end
            return true
        end
    end
    Q.OpenPreparedWhisper(target, message)
    Q.Print("The direct send was unavailable; the message is ready in chat.")
    return false
end

function Q.SuggestInvite(resultID)
    local player, reason = Q.GetResultPlayer(resultID)
    if not player then Q.Print(reason); return false end
    local leader, leaderIsPlayer, leaderReason = Q.GetPartyLeader()
    if not leader then Q.Print(leaderReason); return false end
    if Q.ChatLocked() then Q.Print("Messaging is restricted during this combat."); return false end
    local now = GetTime()
    if Q.lastSuggestedResult == resultID and now - (Q.lastSuggestedAt or 0) < 3 then
        Q.Print("That invite was already suggested.")
        return false
    end
    local message = Q.BuildSuggestion(player)
    local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    if type(send) ~= "function" then Q.Print("Chat sending is unavailable."); return false end
    local partyOK, partyResult = pcall(send, message, "PARTY")
    local whisperOK = true
    local whisperResult
    if not leaderIsPlayer then
        whisperOK, whisperResult = pcall(send, message, "WHISPER", nil, leader)
    end
    if partyOK and sendResultSucceeded(partyResult)
        and whisperOK and (leaderIsPlayer or sendResultSucceeded(whisperResult)) then
        Q.lastSuggestedResult, Q.lastSuggestedAt = resultID, now
        Q.Print("Suggested " .. player.name .. " to your party leader.")
        return true
    end
    Q.Print("The invite suggestion could not be sent.")
    return false
end

function Q.ResetSettings()
    LFGMessengerForeverDB = copy(Q.DEFAULTS)
    Q.db = LFGMessengerForeverDB
    if Q.UpdateMinimap then Q.UpdateMinimap(true) end
    if Q.UpdateOptions then Q.UpdateOptions() end
    if Q.UpdateLFGButton then Q.UpdateLFGButton() end
end
