-- Campfire Stories: Forever — supported client adapters and shared actions.
local ADDON,ns=...
local C,U=ns.Core,ns.UI
local engine,loadingError
local lastNotice=-1000
local function notice(text)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage('|cffffc46bCampfire Stories: Forever:|r '..tostring(text)) end
end
local function result(ok,message)
    U.message=message or (ok and 'Saved.' or 'Unable to complete that action.')
    U:Refresh()
    if not ok and GetTime()-lastNotice>=1 then notice(U.message); lastNotice=GetTime() end
    return ok
end
local function api()
    if C_ChatInfo and type(C_ChatInfo.SendChatMessage)=='function' then return C_ChatInfo.SendChatMessage,'C_ChatInfo.SendChatMessage' end
    if type(SendChatMessage)=='function' then return SendChatMessage,'SendChatMessage' end
    return nil,'unavailable'
end
local function restriction(channel)
    if InCombatLockdown and InCombatLockdown() then return 'Sending is unavailable in combat.' end
    if C_ChatInfo and C_ChatInfo.InChatMessagingLockdown then
        local ok,locked=pcall(C_ChatInfo.InChatMessagingLockdown)
        if not ok or locked then return 'The client is restricting addon chat.' end
    end
    if channel=='PARTY' then
        if not IsInGroup or not IsInGroup() then return 'Party only needs a normal invited party.' end
        if IsInRaid and IsInRaid() then return 'Party only is unavailable in a raid.' end
        if LE_PARTY_CATEGORY_INSTANCE and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
            and (not LE_PARTY_CATEGORY_HOME or not IsInGroup(LE_PARTY_CATEGORY_HOME)) then return 'Party only is unavailable in an instance-only group.' end
    end
end
ns.CommandReference=[[/campfire or next -> Tell a story: Start story / Next line
/campfire ui -> minimap left-click; Close
/campfire preview or status -> Help: Show next message
/campfire reset -> Tell a story: Reset story (beside Start story / Next line)
/campfire back -> More options: Back one message
/campfire goto N -> More options: Story line + Preview this line
/campfire action or intro -> More options: Preview opening action / introduction
/campfire pause or stop; resume -> More options: Pause / Resume; main Resume story button
/campfire channel say or party -> More options: Nearby players / Your party only
/campfire pace N -> Settings: Fixed gap, Fixed
/campfire pace dynamic -> Settings: Dynamic
/campfire pace -> Settings
/campfire shuffle -> More options: Choose another opening
/campfire library -> Tell a story
/campfire editor -> Write a story
/campfire settings -> Settings; minimap right-click
/campfire import -> Write a story: Import
/campfire export -> More options: Export this story; editor Export draft
/campfire backup -> Settings: Export all / backup
/campfire restore -> Settings: Restore backup
/campfire minimap show or hide -> Settings: Show/Hide minimap button
/campfire debug -> Help: Client diagnostics
/campfire help -> Help
Preview, library and editing controls never share a chat message.]]
ns.FormatHelp=[[Full-story format (plain UTF-8 text):
CAMPFIRE-STORY:1
title:Your story title
premise:
mode:none
L:Your first story line.
L:Your second story line.
END

Use mode:emote for the standard opening action followed directly by the story, without E/I rows. Use mode:none for story text only, without E/I rows. Older mode:shared imports also start at the first story line. Optional mode:custom requires compatible E:group:text and I:group:text records containing your own opening action and introduction. Multiple records make random alternatives; one compatible pair is fixed. Groups match by name; * matches any group. Colons after the group are ordinary text. Titles, premises and main lines cannot contain placeholders. Custom emotes and introductions support {title} and {premise}.

Each L: record is one main message, with 1–30 records. Newlines separate records. Blank main lines, invalid UTF-8, overlong messages, slash-command prefixes, pipes, unknown placeholders and hidden control characters are rejected. There is no Lua evaluation, remote upload or silent truncation.

For simple pasting, use Editor → Main lines and paste one line per message. For backup of all personal stories, chosen opening, performance and settings use Settings → Export all / backup. Save the copied text outside the game; the addon cannot write arbitrary text files. Restore merges personal stories as new copies, preserves existing work, and pauses sending.]]
ns.Diagnostics=function()
    local version,build,date,interface=GetBuildInfo(); local _,name=api()
    return string.format('Campfire Stories: Forever %s\nClient: %s\nBuild: %s\nBuild date: %s\nInterface: %s\nChat API: %s\nLoaded saved account data: %s\nPrevious session marker restored: %s\nCurrent marker: %s\nSchema: %s\n\nCopy these details for a bug report. No information is uploaded. A restored marker is evidence of a load, not a complete persistence test.',C.VERSION,tostring(version),tostring(build),tostring(date),tostring(interface),name,tostring(ns.hadSavedData),tostring(ns.previousMarker),tostring(engine and engine.db.sessionMarker),tostring(engine and engine.db.schema))
end
local A={}; ns.Actions=A
A.send=function()
    if not U:HasVisiblePreview() then
        if U.transfer and U.transfer:IsShown() then U.transfer:Hide() end
        if U.modal and U.modal:IsShown() then notice('Finish or cancel the open confirmation before sending.'); return end
        if U.smallWindow then U:ShowCompact() else U:ShowPage('performance') end
        result(true,'Read the message shown, then click Start story or Next line when ready.')
        return
    end
    local ok,message=engine:SendNext()
    if ok then
        message='' -- The main preview and button already explain the next step.
        if ns.replies then ns.replies:ManualSend() end
    end
    result(ok,message)
end
A.preview=function()
    U:ShowPage('performance')
    result(true,'Read the message shown. Click the main button when you want to share it.')
end
A.pause=function(value) engine.db.paused=value; result(true,value and 'Your story is paused. Click Resume story to continue.' or 'Your place is ready. Click the main button to share the message shown.') end
A.navigate=function(step)
    local ok,err=engine:Navigate(step)
    if ok then U:ShowPage('performance') end
    result(ok,err or 'This message is ready to preview. Click the main button when you want to share it.')
end
A.back=function() A.navigate(C.PreviousStep(engine.db.performance.story,engine.db.performance.step)) end
A.reset=function()
    local ok,err=engine:Restart()
    if ok then
        engine.db.paused=false; U.selectedID=engine.db.performance.story.id
        if U.smallWindow then U:ShowCompact() else U:ShowPage('performance') end
    end
    result(ok,err or 'Back at the beginning. Click Start story when ready.')
end
A.gotoLine=function(n)
    if not n or n~=math.floor(n) or n<1 or n>#engine.db.performance.story.lines then result(nil,'Choose a whole main-line number from 1 to '..#engine.db.performance.story.lines..'.'); return end
    A.navigate(n+2)
end
A.channel=function(value)
    local ok,err=engine:SetChannel(value)
    result(ok,err or (value=='PARTY' and 'Your whole story will go to your party only.' or 'Nearby players will hear your story.'))
end
A.shuffle=function()
    local ok,err=engine:Shuffle(); result(ok,err or 'A different opening is ready to preview. Click Start story when you are ready.')
end
A.minimap=function(hidden) engine.db.minimap.hidden=hidden; U:UpdateMinimap(); result(true,hidden and 'Minimap button hidden. Restore it from addon settings or /campfire ui.' or 'Minimap button shown.') end
A.pace=function(value)
    if value=='' then U:ShowPage('settings'); return end
    local p=C.Copy(engine.db.pacing)
    if value=='dynamic' then p.mode='dynamic'
    elseif tonumber(value) then p.mode='fixed'; p.fixed=tonumber(value)
    else result(nil,'Use pace dynamic or a Fixed gap from 2 to 300 seconds.'); return end
    local ok,err=engine:SetPacing(p); result(ok,err or (p.mode=='dynamic' and 'Pacing adjusts to the length of each message.' or ('Pacing set to '..p.fixed..' seconds between messages.')))
end
SLASH_CAMPFIRESTORY1='/campfire'
SlashCmdList.CAMPFIRESTORY=function(message)
    if not engine then notice(loadingError or 'Wait until character login.'); return end
    local command,arg=(message or ''):match('^%s*(%S*)%s*(.-)%s*$'); command=(command or ''):lower(); arg=arg or ''
    if command=='' or command=='next' then A.send()
    elseif command=='ui' then U:Toggle()
    elseif command=='preview' or command=='status' then A.preview()
    elseif command=='reset' then A.reset()
    elseif command=='back' then A.back()
    elseif command=='goto' then A.gotoLine(tonumber(arg))
    elseif command=='action' then A.navigate(1)
    elseif command=='intro' then A.navigate(2)
    elseif command=='pause' or command=='stop' then A.pause(true)
    elseif command=='resume' then A.pause(false)
    elseif command=='channel' then A.channel(arg:upper())
    elseif command=='pace' then A.pace(arg:lower())
    elseif command=='shuffle' then A.shuffle()
    elseif command=='library' then U:ShowPage('performance')
    elseif command=='editor' or command=='settings' then U:ShowPage(command)
    elseif command=='import' or command=='restore' then U:Transfer('Import a story or restore an account backup','')
    elseif command=='export' then U:Transfer('Selected story export',C.ExportStory(U:ChosenStory()))
    elseif command=='backup' then U:Transfer('Account backup',C.ExportAccount(engine.db))
    elseif command=='minimap' then
        if arg=='show' then A.minimap(false) elseif arg=='hide' then A.minimap(true) else U:ShowPage('settings') end
    elseif command=='debug' then U:Transfer('Local diagnostics',ns.Diagnostics())
    else U:ShowPage('help') end
end
local loader=CreateFrame('Frame'); ns.Loader=loader
loader:RegisterEvent('ADDON_LOADED'); loader:RegisterEvent('PLAYER_LOGIN'); loader:RegisterEvent('PLAYER_LOGOUT')
local failureEvents={'CHAT_MSG_RESTRICTED','CHAT_MSG_SYSTEM','UI_ERROR_MESSAGE','ADDON_ACTION_BLOCKED','ADDON_ACTION_FORBIDDEN'}
for _,event in ipairs(failureEvents) do pcall(loader.RegisterEvent,loader,event) end
for _,event in ipairs({'CHAT_MSG_SAY','CHAT_MSG_PARTY','CHAT_MSG_PARTY_LEADER'}) do loader:RegisterEvent(event) end
local errorKeys={'ERR_CHAT_THROTTLED','ERR_CHAT_RESTRICTED','ERR_CHAT_PLAYER_NOT_FOUND_S','ERR_NOT_IN_GROUP','ERR_NOT_IN_RAID','ERR_CHAT_SILENCED','ERR_CHAT_MUTED','ERR_CHAT_WHILE_DEAD','ERR_CHAT_MESSAGE_SQUELCHED','ERR_CHAT_WRONG_FACTION','ERR_CHAT_PLAYER_NOT_IN_PARTY'}
loader:SetScript('OnEvent',function(_,event,...)
    local a,b=...
    if event=='ADDON_LOADED' and a==ADDON then
        ns.hadSavedData=type(CampfireStoryLibraryDB)=='table'; ns.previousMarker=ns.hadSavedData and CampfireStoryLibraryDB.sessionMarker or 'none'
        local send=api()
        for _,s in ipairs(ns.Stories) do local ok,err=C.ValidateStory(s); if not ok then loadingError='Bundled story '..tostring(s.id)..': '..err; return end end
        engine,loadingError=C.New(CampfireStoryLibraryDB,CampfireStoryDB,{now=GetTime,epoch=GetServerTime or time,random=math.random,restriction=restriction,send=send})
        if engine then
            CampfireStoryLibraryDB=engine.db; ns.engine=engine
            engine.db.sessionMarker=tostring((GetServerTime or time)())..'-'..tostring(math.random(1000,9999))
            U:Init(engine)
            ns.replies=ns.Replies.New(engine,{now=GetTime,playerGUID=function() return UnitGUID and UnitGUID('player') end,
                visible=function() return U:HasVisiblePreview() end,restricted=function() return restriction('WHISPER') end,
                after=C_Timer and C_Timer.After,notice=notice,
                whisper=function(text,target) local sender=api(); if not sender then return false end; return sender(text,'WHISPER',nil,target) end})
        end
    elseif event=='PLAYER_LOGIN' then
        if engine then notice('v'..C.VERSION..' ready. Click the campfire minimap button for a private preview.'); if engine.notice~='' then notice(engine.notice) end
        else notice(loadingError or 'Unable to initialise.') end
    elseif event=='PLAYER_LOGOUT' then if engine then engine:Preview() end
    elseif engine and (event=='CHAT_MSG_SAY' or event=='CHAT_MSG_PARTY' or event=='CHAT_MSG_PARTY_LEADER') then
        local guid=select(12,...)
        if not issecretvalue or (not issecretvalue(a) and not issecretvalue(b) and not issecretvalue(guid)) then
            ns.replies:OnChat(event,a,b,guid)
        end
    elseif engine then
        local failure
        if event=='CHAT_MSG_RESTRICTED' then failure='The client reported restricted chat.'
        elseif (event=='ADDON_ACTION_BLOCKED' or event=='ADDON_ACTION_FORBIDDEN') and a==ADDON then failure='The client blocked this addon action.'
        elseif event=='CHAT_MSG_SYSTEM' or event=='UI_ERROR_MESSAGE' then
            local text=event=='CHAT_MSG_SYSTEM' and a or b
            if type(text)=='string' then for _,key in ipairs(errorKeys) do if type(_G[key])=='string' and text==_G[key] then failure=text; break end end end
        end
        if failure then
            if not engine.pending and ns.replies:ChatFailure() then U:Refresh()
            elseif engine:Failure(failure) then U.message=engine.notice; notice(engine.notice); U:Refresh() end
        end
    end
end)
