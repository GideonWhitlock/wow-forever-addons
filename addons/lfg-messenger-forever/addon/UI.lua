local _, Q = ...

local elapsed = 0

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
            local leader = Q.GetPartyLeader()
            MenuUtil.CreateContextMenu(LFGBrowseFrame.SearchEntryDropDown, function(owner, root)
                local info = C_LFGList.GetSearchResultInfo(resultID)
                if not info then return end
                root:CreateTitle(info.leaderName or "Group Finder")
                local messageButton = root:CreateButton(SEND_MESSAGE or "Send Message", function()
                    if ChatFrameUtil and ChatFrameUtil.SendTell then ChatFrameUtil.SendTell(info.leaderName) end
                end)
                messageButton:SetEnabled(info.leaderName ~= nil)
                local inviteText, inviteFunc = LFGBrowseUtil_GetInviteActionForResult(resultID)
                local inviteButton = root:CreateButton(inviteText, inviteFunc)
                inviteButton:SetEnabled(inviteFunc ~= nil)
                root:CreateDivider()
                local suggest = root:CreateButton("Suggest invite to party leader", function()
                    Q.SuggestInvite(resultID)
                end)
                suggest:SetEnabled(player ~= nil and leader ~= nil and not Q.ChatLocked())
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
