local addonName, Q = ...

Q.ADDON_NAME = addonName
Q.TITLE = "Looking for Group: Forever"
Q.VERSION = "1.0.6"
Q.BLIZZARD_ADDON = "Blizzard_GroupFinder_VanillaStyle"
Q.ICON = "Interface\\Icons\\INV_Letter_15"
Q.DEFAULTS = {
    template = "{class} {role} here",
    roleFilter = "ALL",
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
        DEFAULT_CHAT_FRAME:AddMessage("|cffffd45cLooking for Group:|r " .. tostring(message))
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
    if Q.db.roleFilter ~= "TANK" and Q.db.roleFilter ~= "HEALER"
        and Q.db.roleFilter ~= "DAMAGER" then
        Q.db.roleFilter = "ALL"
    end
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

local sendResultSucceeded

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
    return { name = target, class = class, role = role, resultID = resultID, info = info }
end

local function cleanActivityName(value)
    if Q.IsSecret(value) or type(value) ~= "string" then return nil end
    value = value:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        :gsub("^%s+", ""):gsub("%s+$", "")
    if value == "" or value == "Filter by activity" or value == "All activities" then return nil end
    return value
end

function Q.GetResultActivity(resultID, info)
    info = info or (C_LFGList and C_LFGList.GetSearchResultInfo
        and C_LFGList.GetSearchResultInfo(resultID))

    -- The browse dropdown identifies the activity the inviter is currently
    -- viewing. Prefer it when a player has queued for several activities.
    local frame = _G.LFGBrowseFrame
    local dropdown = frame and (frame.ActivityDropdown or frame.activityDropdown)
    if dropdown then
        local text
        if type(dropdown.GetText) == "function" then
            local ok, value = pcall(dropdown.GetText, dropdown)
            if ok then text = value end
        end
        if not text and dropdown.Text and type(dropdown.Text.GetText) == "function" then
            local ok, value = pcall(dropdown.Text.GetText, dropdown.Text)
            if ok then text = value end
        end
        text = cleanActivityName(text)
        if text then return text end
    end

    if type(info) ~= "table" then return "your selected activity" end
    local activityID = info.activityID
    if type(info.activityIDs) == "table" and #info.activityIDs == 1 then
        activityID = info.activityIDs[1]
    end
    if type(activityID) == "number" and C_LFGList then
        if type(C_LFGList.GetActivityInfoTable) == "function" then
            local ok, activity = pcall(C_LFGList.GetActivityInfoTable, activityID)
            if ok and type(activity) == "table" then
                local name = cleanActivityName(activity.fullName or activity.name or activity.shortName)
                if name then return name end
            end
        elseif type(C_LFGList.GetActivityInfo) == "function" then
            local ok, name = pcall(C_LFGList.GetActivityInfo, activityID)
            name = ok and cleanActivityName(name)
            if name then return name end
        end
    end
    return "your selected activity"
end

function Q.GetInviteRole()
    local role = Q.db and Q.db.roleFilter or "ALL"
    if role == "TANK" then return "Tank" end
    if role == "HEALER" then return "Healer" end
    if role == "DAMAGER" then return "DPS" end
    return nil
end

function Q.SendInviteWhisper(target, activity, role, suggested)
    if type(target) ~= "string" or target == "" then return false end
    activity = cleanActivityName(activity) or "your selected activity"
    local purpose = activity .. (role and (" as " .. role) or "")
    local message = suggested
        and ("Hi, I've suggested you for " .. purpose .. ". Please wait for the party leader's invite.")
        or ("Hi, I've invited you for " .. purpose .. ".")
    message = message:sub(1, 255)
    local key = target .. "\031" .. purpose .. "\031" .. tostring(suggested and true or false)
    local now = GetTime()
    if Q.lastInviteWhisperKey == key and now - (Q.lastInviteWhisperAt or 0) < 3 then
        return false
    end
    if Q.ChatLocked() then
        Q.OpenPreparedWhisper(target, message)
        Q.Print("Chat is restricted here; the activity message is ready for you to send.")
        return false
    end
    local send = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage
    if type(send) == "function" then
        local ok, result = pcall(send, message, "WHISPER", nil, target)
        if ok and sendResultSucceeded(result) then
            Q.lastInviteWhisperKey, Q.lastInviteWhisperAt = key, now
            return true
        end
    end
    Q.OpenPreparedWhisper(target, message)
    Q.Print("The invite was sent, but the activity whisper is ready in chat for you to send.")
    return false
end

function Q.InviteResult(resultID, inviteAction)
    local player, reason = Q.GetResultPlayer(resultID)
    if not player then Q.Print(reason); return false end
    local invite = inviteAction or (C_PartyInfo and C_PartyInfo.InviteUnit) or InviteUnit
    if type(invite) ~= "function" then Q.Print("Inviting is unavailable."); return false end
    local wasInGroup = IsInGroup and IsInGroup()
    local wasLeader = not wasInGroup or (UnitIsGroupLeader and UnitIsGroupLeader("player"))
    local ok, result = pcall(invite, player.name)
    if not ok or result == false then Q.Print("The invite request could not be sent."); return false end
    local activity = Q.GetResultActivity(resultID, player.info)
    local role = Q.GetInviteRole()
    Q.SendInviteWhisper(player.name, activity, role, not wasLeader)
    Q.Print((wasLeader and "Invited " or "Sent an invite suggestion for ")
        .. player.name .. " for " .. activity .. (role and (" as " .. role) or "") .. ".")
    return true
end

function Q.WhisperForResult(resultID)
    local player = Q.GetResultPlayer(resultID)
    if not player then return false end
    local isLeader = not IsInGroup or not IsInGroup()
        or (UnitIsGroupLeader and UnitIsGroupLeader("player"))
    return Q.SendInviteWhisper(player.name, Q.GetResultActivity(resultID, player.info),
        Q.GetInviteRole(), not isLeader)
end

local function hasRole(flags, role)
    if type(flags) ~= "table" then return false end
    if role == "TANK" then return flags.TANK or flags.tank end
    if role == "HEALER" then return flags.HEALER or flags.healer end
    if role == "DAMAGER" then return flags.DAMAGER or flags.DPS or flags.dps end
    return true
end

function Q.ResultMatchesRole(resultID, role)
    if role == nil or role == "ALL" then return true end
    if not (C_LFGList and type(C_LFGList.GetSearchResultInfo) == "function"
        and type(C_LFGList.GetSearchResultPlayerInfo) == "function") then
        return true
    end
    local okInfo, info = pcall(C_LFGList.GetSearchResultInfo, resultID)
    if not okInfo or type(info) ~= "table" or Q.IsSecret(info.numMembers) then return true end
    local count = tonumber(info.numMembers) or 1
    for index = 1, count do
        local okPlayer, player = pcall(C_LFGList.GetSearchResultPlayerInfo, resultID, index)
        if not okPlayer or Q.IsSecret(player) then return true end
        if type(player) == "table" and hasRole(player.lfgRoles, role) then return true end
    end
    return false
end

function Q.FilterResultsByRole(results, role)
    role = role or (Q.db and Q.db.roleFilter) or "ALL"
    if type(results) ~= "table" or role == "ALL" then return results or {} end
    local filtered = {}
    for _, resultID in ipairs(results) do
        if Q.ResultMatchesRole(resultID, role) then filtered[#filtered + 1] = resultID end
    end
    return filtered
end

function Q.ChatLocked()
    if C_ChatInfo and type(C_ChatInfo.InChatMessagingLockdown) == "function" then
        local ok, locked = pcall(C_ChatInfo.InChatMessagingLockdown)
        if ok and locked then return true end
    end
    return false
end

sendResultSucceeded = function(result)
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
    local now = GetTime()
    if Q.lastSuggestedResult == resultID and now - (Q.lastSuggestedAt or 0) < 3 then
        Q.Print("That invite was already suggested.")
        return false
    end
    if Q.InviteResult(resultID) then
        Q.lastSuggestedResult, Q.lastSuggestedAt = resultID, now
        return true
    end
    return false
end

function Q.ResetSettings()
    LFGMessengerForeverDB = copy(Q.DEFAULTS)
    Q.db = LFGMessengerForeverDB
    if Q.UpdateMinimap then Q.UpdateMinimap(true) end
    if Q.UpdateOptions then Q.UpdateOptions() end
    if Q.UpdateLFGButton then Q.UpdateLFGButton() end
end
