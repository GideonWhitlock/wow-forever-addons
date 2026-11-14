local _, Q = ...

local elapsed = 0

local function getResultID(row)
    if not row then return nil end
    local data = row.elementData or row.data
    if type(data) ~= "table" and type(row.GetElementData) == "function" then
        local ok, value = pcall(row.GetElementData, row)
        if ok then data = value end
    end
    local resultID = row.resultID or row.searchResultID or (type(data) == "table" and data.resultID)
    return type(resultID) == "number" and resultID or nil
end

local function configureInviteButton(row)
    local resultID = getResultID(row)
    if not resultID then
        if row.LFGMessengerForeverInvite then row.LFGMessengerForeverInvite:Hide() end
        return
    end

    local player = Q.GetResultPlayer(resultID)
    local inviteText, inviteAction
    if player and type(LFGBrowseUtil_GetInviteActionForResult) == "function" then
        local ok, text, action = pcall(LFGBrowseUtil_GetInviteActionForResult, resultID)
        if ok then inviteText, inviteAction = text, action end
    end

    local button = row.LFGMessengerForeverInvite
    if not player or type(inviteAction) ~= "function" then
        if button then button:Hide() end
        return
    end

    if not button then
        button = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.LFGMessengerForeverInvite = button
        button:SetSize(66, 20)
        button:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        button:SetFrameLevel(row:GetFrameLevel() + 5)
        button:SetScript("OnClick", function(self)
            local id = self.resultID
            if not id then return end
            local _, action = LFGBrowseUtil_GetInviteActionForResult(id)
            if type(action) == "function" then Q.InviteResult(id, action) end
        end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(self.inviteText or "Invite", 1, 0.82, 0)
            GameTooltip:AddLine("Invite this player without selecting the listing first.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    button.resultID = resultID
    button.inviteText = inviteText or (GROUP_INVITE or "Group Invite")
    button:SetText(INVITE or "Invite")
    button:Show()
end

function Q.UpdateResultInviteButtons()
    local frame = _G.LFGBrowseFrame
    if not frame then return end
    local scrollBox = frame.ScrollBox or frame.ScrollFrame
    if scrollBox and type(scrollBox.ForEachFrame) == "function" then
        scrollBox:ForEachFrame(configureInviteButton)
        return
    end
    local buttons = (scrollBox and scrollBox.buttons) or frame.buttons
    if type(buttons) == "table" then
        for _, row in ipairs(buttons) do configureInviteButton(row) end
    end
end

function Q.UpdateLFGButton()
    local button = Q.lfgButton
    if not button then return end
    local target, reason = Q.GetSelectedTarget()
    local locked = Q.ChatLocked()
    local message = Q.BuildMessage()
    local short = target and (Ambiguate and Ambiguate(target, "short") or target)
    local recentlySent = target and Q.lastTarget == target and GetTime() - (Q.lastSentAt or 0) < 3
    button:SetEnabled(target ~= nil and not locked and not recentlySent)
    if recentlySent then
        button:SetText("Sent to " .. short)
    elseif target then
        button:SetText("Whisper: " .. message)
    else
        button:SetText("Quick Whisper")
    end
    button.target = target
    button.reason = locked and "Messaging is restricted during this combat" or reason
end

function Q.AttachToGroupFinder()
    if Q.lfgButton or not LFGBrowseFrame then return end
    local button = CreateFrame("Button", "LFGMessengerForeverButton", LFGBrowseFrame, "UIPanelButtonTemplate")
    Q.lfgButton = button
    -- Leave a clear visual gap from Blizzard's Send Message and Group Invite
    -- buttons on either side of the footer.
    button:SetSize(180, 24)
    button:SetPoint("BOTTOM", LFGBrowseFrame, "BOTTOM", 0, 16)
    button:SetText("Quick Whisper")
    button:SetScript("OnClick", function() Q.SendSelected() end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(Q.TITLE, 1, 0.82, 0)
        local target = self.target
        if target then
            GameTooltip:AddLine("Send to " .. target .. ":", 1, 1, 1)
            GameTooltip:AddLine(Q.BuildMessage(), 0.85, 0.85, 0.85, true)
        else
            GameTooltip:AddLine(self.reason or "Select a group first", 0.9, 0.35, 0.25, true)
        end
        GameTooltip:AddLine("One click sends one whisper. Repeated clicks are briefly blocked.", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    button:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        if elapsed >= 0.2 then elapsed = 0; Q.UpdateLFGButton() end
    end)
    LFGBrowseFrame:HookScript("OnShow", Q.UpdateLFGButton)
    local roleFilter = CreateFrame("DropdownButton", "LFGMessengerForeverRoleFilter", LFGBrowseFrame,
        "WowStyle1DropdownTemplate")
    Q.roleFilter = roleFilter
    -- Span the same width as Category plus Activity so this reads as a
    -- deliberate results-order row rather than a misplaced third dropdown.
    roleFilter:SetSize(349, 24)
    roleFilter:SetPoint("TOPLEFT", LFGBrowseFrame, "TOPLEFT", 70, -76)
    local orderLabels = { ALL = "All roles", TANK = "Tanks first", HEALER = "Healers first", DAMAGER = "DPS first" }
    local function setupRoleFilter()
        local selected = (Q.db and Q.db.roleFilter) or "ALL"
        roleFilter:SetDefaultText("Role order: " .. (orderLabels[selected] or orderLabels.ALL))
        roleFilter:SetupMenu(function(_, root)
            local function isSelected(value) return Q.db.roleFilter == value end
            local function setSelected(value)
                Q.db.roleFilter = value
                setupRoleFilter()
                LFGBrowseFrame:UpdateResultList()
            end
            root:CreateRadio(orderLabels.ALL, isSelected, setSelected, "ALL")
            root:CreateRadio(orderLabels.TANK, isSelected, setSelected, "TANK")
            root:CreateRadio(orderLabels.HEALER, isSelected, setSelected, "HEALER")
            root:CreateRadio(orderLabels.DAMAGER, isSelected, setSelected, "DAMAGER")
        end)
    end
    setupRoleFilter()
    -- Blizzard's footer invite button is outside our menu. Post-hook it so a
    -- normal Group Invite click gets the same activity-and-role whisper.
    if not Q.footerInviteHooked then
        local footerInvite = LFGBrowseFrame.InviteButton or LFGBrowseFrame.GroupInviteButton
            or _G.LFGBrowseFrameInviteButton
        if not footerInvite and type(LFGBrowseFrame.GetChildren) == "function" then
            for _, child in ipairs({ LFGBrowseFrame:GetChildren() }) do
                if type(child.GetText) == "function" then
                    local ok, text = pcall(child.GetText, child)
                    if ok and (text == (GROUP_INVITE or "Group Invite") or text == "Group Invite") then
                        footerInvite = child
                        break
                    end
                end
            end
        end
        if footerInvite and type(footerInvite.HookScript) == "function" then
            Q.footerInviteHooked = true
            footerInvite:HookScript("OnClick", function()
                local resultID = Q.GetSelectedResultID()
                if resultID then Q.WhisperForResult(resultID) end
            end)
        end
    end
    if type(hooksecurefunc) == "function" and type(LFGBrowseFrame.UpdateResultList) == "function" then
        hooksecurefunc(LFGBrowseFrame, "UpdateResultList", function(frame)
            local ordered = Q.PrioritizeResultsByRole(frame.results)
            if ordered ~= frame.results then
                frame.results = ordered
                frame.totalResults = #ordered
                frame:UpdateResults()
            end
        end)
    end
    if type(hooksecurefunc) == "function" and type(LFGBrowseFrame.UpdateResults) == "function" then
        hooksecurefunc(LFGBrowseFrame, "UpdateResults", function()
            if C_Timer and type(C_Timer.After) == "function" then
                C_Timer.After(0, Q.UpdateResultInviteButtons)
            else
                Q.UpdateResultInviteButtons()
            end
        end)
    end
    -- The mixin's methods have already been copied onto the live frame by the
    -- time this load-on-demand UI exists. Hook the frame method itself so the
    -- post-hook runs when a result row is right-clicked.
    if not Q.contextHooked and type(LFGBrowseFrame.CreateSearchEntryMenu) == "function"
        and type(hooksecurefunc) == "function" then
        Q.contextHooked = true
        hooksecurefunc(LFGBrowseFrame, "CreateSearchEntryMenu", function(_, searchEntry)
            if not searchEntry or type(searchEntry.resultID) ~= "number" or not MenuUtil then return end
            local resultID = searchEntry.resultID
            local player = Q.GetResultPlayer(resultID)
            MenuUtil.CreateContextMenu(LFGBrowseFrame.SearchEntryDropDown, function(owner, root)
                local info = C_LFGList.GetSearchResultInfo(resultID)
                if not info then return end
                root:CreateTitle(info.leaderName or "Group Finder")
                local messageButton = root:CreateButton(SEND_MESSAGE or "Send Message", function()
                    if ChatFrameUtil and ChatFrameUtil.SendTell then ChatFrameUtil.SendTell(info.leaderName) end
                end)
                messageButton:SetEnabled(info.leaderName ~= nil)
                local inviteText, inviteFunc = LFGBrowseUtil_GetInviteActionForResult(resultID)
                local inviteButton = root:CreateButton(inviteText, function()
                    Q.InviteResult(resultID, inviteFunc)
                end)
                inviteButton:SetEnabled(inviteFunc ~= nil)
                root:CreateDivider()
                local suggest = root:CreateButton("Suggest invite to party leader", function()
                    Q.SuggestInvite(resultID)
                end)
                suggest:SetEnabled(player ~= nil and type((C_PartyInfo and C_PartyInfo.InviteUnit) or InviteUnit) == "function")
                root:CreateDivider()
                root:CreateButton(LFG_LIST_REPORT_GROUP_FOR or "Report Group", function()
                    if LFGBrowseUtil_ReportListing then LFGBrowseUtil_ReportListing(resultID, info.leaderName) end
                end)
                root:CreateButton(REPORT_GROUP_FINDER_ADVERTISEMENT or "Report Advertisement", function()
                    if LFGBrowseUtil_ReportAdvertisement then
                        LFGBrowseUtil_ReportAdvertisement(resultID, info.leaderName)
                    end
                end)
            end)
        end)
    end
    Q.UpdateResultInviteButtons()
    Q.UpdateLFGButton()
end

function Q.TryAttachToGroupFinder()
    if Q.lfgButton then return true end
    if LFGBrowseFrame then
        local ok, err = pcall(Q.AttachToGroupFinder)
        if not ok then Q.Print("Could not attach to Group Finder: " .. tostring(err)) end
        return ok and Q.lfgButton ~= nil
    end
    return false
end
