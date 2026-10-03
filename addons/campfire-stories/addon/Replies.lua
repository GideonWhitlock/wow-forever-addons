-- Narrow, session-scoped source replies. Storytelling itself remains manual.
local _,ns=...
local C=ns.Core
local R={}; R.__index=R; ns.Replies=R
local URL="https://www.curseforge.com/wow/addons/campfire-stories"

function R.MentionsAI(text)
    if type(text)~="string" or #text>2000 then return false end
    local t=text:lower():gsub("a%.i%.?","ai")
    for _,word in ipairs({"ai","chatgpt","gpt","llm","openai"}) do
        if t:find("%f[%w]"..word.."%f[%W]") then return true end
    end
    for _,phrase in ipairs({"chat gpt","artificial intelligence","large language model","machine-generated","machine generated","bot-written","bot written"}) do
        if t:find(phrase,1,true) then return true end
    end
    local context=t:find("writ") or t:find("wrote") or t:find("generat") or t:find("story") or t:find("stories") or t:find("tale") or t:find("slop")
    if context then
        for _,word in ipairs({"claude","gemini","grok","deepseek","copilot"}) do
            if t:find("%f[%w]"..word.."%f[%W]") then return true end
        end
    end
    return false
end

function R.New(engine,env)
    return setmetatable({engine=engine,env=env,seen={},last=-math.huge,count=0},R)
end

function R:ManualSend()
    local p=self.engine.db.performance
    if self.performance~=p then self.performance=p; self.count=0; self.pending=nil end
    -- An opening action is addon flavour, not a sourced narrative. Wait until
    -- a manual story-line attempt before making a human-source claim.
    self.storyAt=p.step>=4 and self.env.now() or nil
end

function R:Active()
    local e,p=self.engine,self.engine.db.performance
    if self.disabled or e.db.autoSourceReplies==false or not self.storyAt
        or self.env.now()-self.storyAt>90 or p~=self.performance or not p.started
        or e.db.paused or p.step<4 or p.step>#p.story.lines+2 or not self.env.visible()
        or self.env.restricted() then return false end
    -- Only an unchanged current included tale can support the authorship claim.
    if not ns.StoryCredits[p.story.id] then return false end
    local source=e:Story(p.story.id)
    if not source or C.ExportStory(source)~=C.ExportStory(p.story) then return false end
    return true
end

function R:OnChat(event,text,sender,guid)
    if not self:Active() or self.pending or self.count>=3 then return end
    local channel=self.engine.db.channel
    if (channel=="SAY" and event~="CHAT_MSG_SAY") or
        (channel=="PARTY" and event~="CHAT_MSG_PARTY" and event~="CHAT_MSG_PARTY_LEADER") then return end
    if type(guid)~="string" or not guid:match("^Player%-%d+%-%x+$") or guid==self.env.playerGUID()
        or type(sender)~="string" or not C.Text(sender,100) or sender:find("%s") then return end
    if self.seen[guid] or not R.MentionsAI(text) then return end
    if not self.env.after then return end
    local item={sender=sender,guid=guid,performance=self.performance,channel=channel}
    self.pending=item
    self:Deliver(item)
end

function R:Deliver(item)
    if self.pending~=item then return end
    if not self:Active() or item.performance~=self.performance or item.channel~=self.engine.db.channel then self.pending=nil; return end
    local e,now=self.engine,self.env.now()
    -- Let the last story attempt's error-correlation window close, and honour
    -- existing chat pacing. One pending recipient, never a broadcast/retry queue.
    local due=math.max(e.untilTime or 0,(e.last or -math.huge)+11,self.last+30)
    if due>now then self.env.after(due-now+0.05,function() self:Deliver(item) end); return end
    self.pending=nil
    local credit=ns.StoryCredits[self.performance.story.id]:gsub("; WoW place names","")
    local text="Campfire Stories: Forever - human-written public-domain tales, not AI-generated. This tale: "..credit..". Some place names changed for WoW. "..URL
    if not C.Text(text) then return end
    self.seen[item.guid]=true; self.last=now; self.count=self.count+1
    -- Do not let an automatic whisper failure rewind a manually sent story line.
    e.pending=nil
    e.last=now; e.untilTime=math.max(e.untilTime,now+11)
    e.db.cooldown={lastEpoch=e.env.epoch()+1,gap=11}
    self.sending=true
    local ok,value=pcall(self.env.whisper,text,item.sender)
    self.sending=false
    e:Preview()
    if not ok or value==false then self.disabled=true; self.env.notice("Automatic source reply was blocked. Replies are off for this login; no retry was sent.") end
end

function R:ChatFailure()
    -- Called for a client restriction while no manual attempt is pending.
    if self.last~= -math.huge and self.env.now()-self.last<=10 then
        self.disabled=true; self.pending=nil
        self.env.notice("The client restricted an automatic source reply. Replies are off for this login.")
        return true
    end
end
