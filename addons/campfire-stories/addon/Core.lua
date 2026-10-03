-- Pure Lua 5.1 logic. Only Engine:SendNext can invoke the injected chat API.
local _, ns = ...
local C = {}; ns.Core = C
C.VERSION = "3.0.2"
C.SCHEMA = 3
C.CHAT_BYTES = 255
C.DEFAULTS = { mode="dynamic", fixed=5, preparation=1, rate=12, minimum=2, maximum=20, scale=1 }
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<1e15 end
local function integer(n) return finite(n) and n==math.floor(n) end
local function copy(v, seen)
    if type(v)~="table" then return v end
    seen=seen or {}; if seen[v] then return seen[v] end
    local r={}; seen[v]=r; for k,x in pairs(v) do r[k]=copy(x,seen) end; return r
end
C.Copy=copy; C.Finite=finite

-- Counts Unicode scalar values, not bytes or grapheme clusters. Rejects malformed
-- UTF-8, overlong sequences, surrogate code points and invisible format controls.
function C.Characters(s)
    if type(s)~="string" then return nil,"Text is required." end
    local i,n=1,0
    while i<=#s do
        local b=s:byte(i); local count,cp,low
        if b<128 then count,cp,low=1,b,0
        elseif b>=194 and b<=223 then count,cp,low=2,b-192,128
        elseif b>=224 and b<=239 then count,cp,low=3,b-224,2048
        elseif b>=240 and b<=244 then count,cp,low=4,b-240,65536
        else return nil,"Invalid UTF-8 encoding." end
        for j=1,count-1 do
            local x=s:byte(i+j); if not x or x<128 or x>191 then return nil,"Invalid UTF-8 encoding." end
            cp=cp*64+x-128
        end
        if cp<low or cp>1114111 or (cp>=55296 and cp<=57343) then return nil,"Invalid UTF-8 encoding." end
        if cp<32 or (cp>=127 and cp<=159) or cp==173 or cp==1564 or cp==6158
            or (cp>=8203 and cp<=8207) or (cp>=8232 and cp<=8238)
            or (cp>=8288 and cp<=8303) or cp==65279
            or (cp>=65529 and cp<=65535) or (cp>=917504 and cp<=917631) then
            return nil,"Control and hidden formatting characters are not allowed."
        end
        n=n+1; i=i+count
    end
    return n
end

function C.Text(s,limit,allowEmpty,template)
    local n,err=C.Characters(s); if not n then return nil,err end
    if not allowEmpty and not s:find("%S") then return nil,"Text must not be empty." end
    if #s>(limit or C.CHAT_BYTES) then return nil,"Text exceeds "..(limit or C.CHAT_BYTES).." UTF-8 bytes; shorten it." end
    if s:find("|",1,true) or s:find("^%s*/") then return nil,"Use plain text without chat formatting or slash commands." end
    local rest=s
    if template then rest=rest:gsub("{title}",""):gsub("{premise}","") end
    if rest:find("[{}]") then return nil,"Only {title} and {premise} placeholders are supported in openings." end
    return true
end

function C.Pace(p)
    if type(p)~="table" or (p.mode~="dynamic" and p.mode~="fixed") then return nil,"Choose Dynamic or Fixed." end
    for _,k in ipairs({"fixed","preparation","rate","minimum","maximum","scale"}) do
        if not finite(p[k]) then return nil,"Enter a valid number for "..k.."." end
    end
    if not integer(p.fixed) or not integer(p.minimum) or not integer(p.maximum)
        or p.rate<=0 or p.preparation<0 or p.minimum<2 or p.maximum<p.minimum
        or p.fixed<2 or p.maximum>300 or p.fixed>300 or p.preparation>300
        or p.scale<0.25 or p.scale>4 then
        return nil,"Rate must be positive; preparation 0–300; whole-second gaps: minimum at least 2, maximum between minimum and 300, Fixed 2–300; multiplier 0.25–4."
    end
    return true
end

function C.Delay(text,p)
    local chars,err=C.Characters(text); if not chars then return nil,err end
    if p.mode=="fixed" then return math.max(2,math.ceil(p.fixed)) end
    return math.max(2,math.ceil(math.min(p.maximum,math.max(p.minimum,(p.preparation+chars/p.rate)*p.scale))))
end

function C.Resolve(text,story)
    -- A missing premise becomes a grammatical noun phrase, even in custom templates.
    local premise=story.premise~="" and story.premise or ('the tale called "'..story.title..'"')
    return (text:gsub("{title}",function() return story.title end):gsub("{premise}",function() return premise end))
end

function C.Pairs(story)
    if story.openingMode=="emote" then
        local actions={}
        for _,e in ipairs(ns.Emotes or {}) do actions[#actions+1]={emote=e.text} end
        return actions
    end
    if story.openingMode~="custom" then return {} end
    local es,is=story.emotes,story.introductions
    local pairs={}
    for _,e in ipairs(es or {}) do for _,intro in ipairs(is or {}) do
        if e.group==intro.group or e.group=="*" or intro.group=="*" then
            pairs[#pairs+1]={emote=C.Resolve(e.text,story),intro=C.Resolve(intro.text,story)}
        end
    end end
    return pairs
end

function C.FirstStep(story) return (story.openingMode=="custom" or story.openingMode=="emote") and 1 or 3 end
function C.ValidStep(story,step)
    return integer(step) and step>=C.FirstStep(story) and step<=#story.lines+3
        and not (story.openingMode=="emote" and step==2)
end
function C.NextStep(story,step) return story.openingMode=="emote" and step==1 and 3 or step+1 end
function C.PreviousStep(story,step)
    return story.openingMode=="emote" and step==3 and 1 or math.max(C.FirstStep(story),step-1)
end

function C.ValidateStory(s)
    if type(s)~="table" then return nil,"A story record is required." end
    local ok,err=C.Text(s.title,100); if not ok then return nil,"Title: "..err end
    ok,err=C.Text(s.premise,150,true); if not ok then return nil,"Premise: "..err end
    if type(s.lines)~="table" or #s.lines<1 or #s.lines>30 then return nil,"Use 1–30 main lines." end
    for k in pairs(s.lines) do if not integer(k) or k<1 or k>#s.lines then return nil,"Main lines must be a continuous numbered list." end end
    for i,line in ipairs(s.lines) do ok,err=C.Text(line); if not ok then return nil,"Line "..i..": "..err end end
    if s.openingMode~="none" and s.openingMode~="shared" and s.openingMode~="custom" and s.openingMode~="emote" then return nil,"Choose story text only, opening emote or custom openings." end
    for _,field in ipairs({"emotes","introductions"}) do
        if type(s[field])~="table" or #s[field]>30 then return nil,"Use at most 30 "..field.."." end
        for _,item in ipairs(s[field]) do
            if type(item)~="table" or type(item.group)~="string" or not item.group:match("^[%w_*-]+$") or #item.group>32 then return nil,"Opening groups use 1–32 letters, numbers, _, - or *." end
            ok,err=C.Text(item.text,255,false,true); if not ok then return nil,field..": "..err end
        end
    end
    local pairs=C.Pairs(s); if s.openingMode=="custom" and #pairs==0 then return nil,"Custom openings need at least one compatible emote and introduction." end
    for _,pair in ipairs(pairs) do
        ok,err=C.Text(pair.emote); if not ok then return nil,"Completed emote: "..err end
        ok,err=C.Text("[Action] "..pair.emote); if not ok then return nil,"Party action: "..err end
        if s.openingMode=="custom" then
            ok,err=C.Text(pair.intro); if not ok then return nil,"Completed introduction: "..err end
        end
    end
    return true
end

function C.ExportStory(s)
    local ok,err=C.ValidateStory(s); if not ok then return nil,err end
    local out={"CAMPFIRE-STORY:1","title:"..s.title,"premise:"..s.premise,"mode:"..s.openingMode}
    for _,e in ipairs(s.emotes) do out[#out+1]="E:"..e.group..":"..e.text end
    for _,i in ipairs(s.introductions) do out[#out+1]="I:"..i.group..":"..i.text end
    for _,line in ipairs(s.lines) do out[#out+1]="L:"..line end
    out[#out+1]="END"; return table.concat(out,"\n")
end

function C.ImportStory(text)
    if type(text)~="string" or #text>40000 then return nil,"Import is missing or exceeds 40,000 bytes." end
    text=text:gsub("\r\n","\n")
    local rows={}; for row in (text.."\n"):gmatch("(.-)\n") do rows[#rows+1]=row end
    if rows[#rows]=="" then table.remove(rows) end
    if rows[1]~="CAMPFIRE-STORY:1" or rows[#rows]~="END" then return nil,"Expected CAMPFIRE-STORY:1 and a final END line. Use Main lines for plain story pasting." end
    local s={lines={},emotes={},introductions={}}; local seen={}
    for n=2,#rows-1 do
        local key,value=rows[n]:match("^([^:]+):(.*)$")
        if key=="title" or key=="premise" or key=="mode" then
            if seen[key] then return nil,"Duplicate "..key.." field." end
            seen[key]=true; s[key=="mode" and "openingMode" or key]=value
        elseif key=="L" then s.lines[#s.lines+1]=value
        elseif key=="E" or key=="I" then
            local group,body=value:match("^([^:]+):(.*)$"); if not group then return nil,"Opening needs group:text at row "..n.."." end
            local field=key=="E" and "emotes" or "introductions"; s[field][#s[field]+1]={group=group,text=body}
        else return nil,"Unknown field at row "..n.."." end
    end
    local ok,err=C.ValidateStory(s); if not ok then return nil,err end
    return s
end

local Engine={}; Engine.__index=Engine; C.Engine=Engine
function C.New(saved,legacy,env)
    local self=setmetatable({env=env,serial=0,notice="",last=nil,untilTime=0},Engine)
    local db=type(saved)=="table" and copy(saved) or {}
    if db.schema and db.schema~=C.SCHEMA then
        if not integer(db.schema) or db.schema>C.SCHEMA then return nil,"Saved data has an unsupported schema. Export/restore the matching addon version; data was not overwritten." end
    end
    db.recovery=type(db.recovery)=="table" and db.recovery or {}
    if not C.Pace(db.pacing) then
        if db.pacing then db.recovery.pacing=copy(db.pacing) end
        db.pacing=copy(C.DEFAULTS)
        if type(legacy)=="table" and finite(legacy.pace) and legacy.pace>=2 and legacy.pace<=300 then db.pacing.fixed=legacy.pace end
    end
    local oldStories=db.stories; db.stories={}
    if type(oldStories)=="table" then for id,s in pairs(oldStories) do
        if type(id)=="string" and id:match("^personal_[%w_%-]+$") and C.ValidateStory(s) then
            s.id=id; db.stories[id]=s
        else db.recovery.stories=db.recovery.stories or {}; db.recovery.stories[id]=s end
    end elseif oldStories~=nil then db.recovery.stories=oldStories end
    db.channel=db.channel=="PARTY" and "PARTY" or "SAY"
    db.paused=db.paused==true
    db.minimap=type(db.minimap)=="table" and db.minimap or {}
    db.minimap.angle=finite(db.minimap.angle) and db.minimap.angle%360 or 225
    db.minimap.hidden=db.minimap.hidden==true
    db.window=type(db.window)=="table" and db.window or {x=0,y=0}
    for _,k in ipairs({"x","y"}) do if not finite(db.window[k]) or math.abs(db.window[k])>10000 then db.window[k]=0 end end
    db.nextID=integer(db.nextID) and math.max(1,db.nextID) or 1
    db.lastOpening=type(db.lastOpening)=="table" and db.lastOpening or {}
    self.db=db
    if type(db.cooldown)=="table" and finite(db.cooldown.lastEpoch) and finite(db.cooldown.gap) and db.cooldown.gap>=2 and db.cooldown.gap<=301 then
        local age=math.max(0,env.epoch()-db.cooldown.lastEpoch)
        self.last=env.now()-age
        self.untilTime=self.last+db.cooldown.gap
    elseif db.cooldown~=nil then
        db.recovery.cooldown=copy(db.cooldown); self.last=env.now(); self.untilTime=self.last+300
        db.cooldown={lastEpoch=env.epoch(),gap=300}
    end
    local p=db.performance
    -- Removed bundled fiction must not survive through an active/recovery snapshot.
    -- Personal library records remain the player's property and are left intact.
    local function retired(record)
        return type(record)=="table" and type(record.story)=="table"
            and ns.RetiredStoryIds and ns.RetiredStoryIds[record.story.id]
    end
    if retired(db.recovery.performance) then db.recovery.performance=nil end
    if type(db.recovery.beforeRestore)=="table" and retired(db.recovery.beforeRestore.performance) then db.recovery.beforeRestore.performance=nil end
    if retired(p) then
        p=nil; db.performance=nil; db.lastOpening={}; db.paused=false
        self.notice="The old included collection has been replaced with human-written tales. Choose a story to begin."
    end
    -- Add the restored action to an untouched 3.0.0 preview. An ongoing or
    -- finished telling keeps its exact source line and outstanding wait.
    if type(p)=="table" and type(p.story)=="table" and p.story.openingMode=="none"
        and C.ValidateStory(p.story) then
        local current=self:Story(p.story.id)
        if current and ns.StoryCredits[p.story.id] and current.openingMode=="emote" then
            p.story.openingMode="emote"; p.opening=self:ChooseOpening(p.story)
            if p.step==3 and not p.started then p.step=1 end
        end
    end
    if type(p)=="table" and type(p.story)=="table" and C.ValidateStory(p.story)
        and C.FirstStep(p.story)==3 then
        if integer(p.step) and p.step>=1 and p.step<3 then p.step=3; p.started=false end
        p.opening={}; db.lastOpening={}
    end
    local valid=type(p)=="table" and type(p.story)=="table" and C.ValidateStory(p.story)
        and C.ValidStep(p.story,p.step)
        and type(p.opening)=="table" and (C.FirstStep(p.story)==3 or
            (C.Text(p.opening.emote) and C.Text("[Action] "..p.opening.emote)
                and (p.story.openingMode=="emote" or C.Text(p.opening.intro))))
    if not valid then
        if p then db.recovery.performance=copy(p) end
        db.performance=nil
        self:Select(ns.Stories[1].id)
        if not saved and type(legacy)=="table" then
            db.legacySnapshot=copy(legacy)
            db.channel=legacy.channel=="PARTY" and "PARTY" or "SAY"; db.paused=legacy.paused==true
            if ns.RetiredStoryIds and ns.RetiredStoryIds[legacy.storyId] then
                db.paused=false; self.notice="The old included collection has been replaced. Choose a story to begin."
            end
        end
    else p.started=p.started==true or p.step>C.FirstStep(p.story); p.story=copy(p.story) end
    db.schema=C.SCHEMA
    self:Preview()
    return self
end

function Engine:Story(id)
    if self.db.stories[id] then return self.db.stories[id] end
    for _,s in ipairs(ns.Stories) do if s.id==id then return s end end
end
function Engine:ChooseOpening(story)
    if C.FirstStep(story)==3 then self.db.lastOpening={}; return {} end
    local pairs=C.Pairs(story); local last=self.db.lastOpening
    local candidates={}
    for _,p in ipairs(pairs) do if p.emote~=last.emote and p.intro~=last.intro then candidates[#candidates+1]=p end end
    if #candidates==0 then for _,p in ipairs(pairs) do if p.emote~=last.emote or p.intro~=last.intro then candidates[#candidates+1]=p end end end
    if #candidates==0 then candidates=pairs end
    local pair=copy(candidates[self.env.random(#candidates)])
    self.db.lastOpening=copy(pair); return pair
end
function Engine:Select(id)
    local story=self:Story(id); if not story then return nil,"Story not found." end
    local ok,err=C.ValidateStory(story); if not ok then return nil,err end
    self.db.performance={story=copy(story),step=C.FirstStep(story),opening=self:ChooseOpening(story),started=false}
    self.serial=self.serial+1; self.pending=nil; self:Preview(); return true
end
function Engine:Shuffle()
    local p=self.db.performance; if p.started then return nil,"Shuffle is available before the first attempt of a new performance." end
    if C.FirstStep(p.story)==3 then return nil,"This story starts with its original text and has no added opening." end
    p.opening=self:ChooseOpening(p.story); self:Preview(); return true
end
function Engine:Restart()
    local p=self.db.performance
    if self:Story(p.story.id) then return self:Select(p.story.id) end
    -- A deleted library entry can still be restarted from its retained snapshot.
    self.db.performance={story=copy(p.story),step=C.FirstStep(p.story),opening=self:ChooseOpening(p.story),started=false}
    self.serial=self.serial+1; self.pending=nil; self:Preview(); return true
end
function Engine:Navigate(step)
    local p=self.db.performance
    if not C.ValidStep(p.story,step) then return nil,"Choose a valid stage or main line." end
    p.step=step; self.serial=self.serial+1; self.pending=nil; self:Preview(); return true
end
function Engine:SetPacing(p)
    local ok,err=C.Pace(p); if not ok then return nil,err end
    self.db.pacing=copy(p); self:Preview(); return true
end
function Engine:SetChannel(channel)
    if channel~="SAY" and channel~="PARTY" then return nil,"Choose Local or Party only." end
    self.db.channel=channel; self:Preview(); return true
end
function Engine:Preview()
    local p=self.db.performance; if not p then return {error="No performance."} end
    local step,text,stage=p.step
    if step==1 then text=p.opening.emote; stage="Opening action"
    elseif step==2 then text=p.opening.intro; stage="Spoken introduction"
    elseif step<=#p.story.lines+2 then text=p.story.lines[step-2]; stage="Main line "..(step-2).." of "..#p.story.lines
    else return {finished=true,title=p.story.title,stage="Finished",remaining=math.max(0,self.untilTime-self.env.now()),step=step} end
    local channel=self.db.channel=="PARTY" and "PARTY" or (step==1 and "EMOTE" or "SAY")
    if channel=="PARTY" and step==1 then text="[Action] "..text end
    local delay,err=C.Delay(text,self.db.pacing); local ok,problem=C.Text(text)
    if not ok or not delay then return {error=problem or err,title=p.story.title,stage=stage} end
    if self.last then
        self.untilTime=math.max(self.untilTime,self.last+delay)
        if self.db.cooldown then self.db.cooldown.gap=math.max(self.db.cooldown.gap,self.untilTime-self.last) end
    end
    return {text=text,title=p.story.title,stage=stage,channel=channel,delay=delay,
        remaining=math.max(0,self.untilTime-self.env.now()),chars=C.Characters(text),bytes=#text,step=step}
end
function Engine:SendNext()
    local v=self:Preview()
    if v.error then return nil,v.error end
    if self.db.paused then return nil,"Your story is paused. Click Resume story first." end
    if v.finished then return nil,"Finished. Restart explicitly to tell this story again." end
    if v.remaining>0 then return nil,string.format("Wait %.1fs, then press again. Nothing is queued.",v.remaining) end
    local restriction=self.env.restriction(v.channel); if restriction then return nil,restriction end
    if not self.env.send then return nil,"No supported chat API is available." end
    local p=self.db.performance
    self.serial=self.serial+1
    self.pending={performance=p,step=p.step,serial=self.serial,at=self.env.now()}
    self.last=self.env.now(); self.untilTime=self.last+2
    -- Server time is integral: store the upper bound of this second. Reload may
    -- conservatively add <1 second, but cannot shorten the outstanding interval.
    self.db.cooldown={lastEpoch=self.env.epoch()+1,gap=2}
    p.started=true
    -- Exactly one outgoing API attempt. Failure never falls back to another API.
    local ok,result=pcall(self.env.send,v.text,v.channel)
    if not ok or result==false then
        self.pending=nil; self:Preview(); return nil,"The API attempt failed. The message remains selected; wait, then retry manually."
    end
    -- A synchronous failure event may have marked the pending attempt already.
    if self.pending and not self.pending.failed then p.step=C.NextStep(p.story,p.step) end
    self:Preview()
    if self.pending and self.pending.failed then return nil,"The client reported a chat restriction; the message remains selected." end
    return true,"Attempted once; delivery is not confirmed. Back or Retry previous selects it privately."
end
function Engine:Failure(reason)
    local a=self.pending
    if not a or self.env.now()-a.at>10 or a.serial~=self.serial or a.performance~=self.db.performance then return end
    -- Conservative correlation only for explicit chat failures, never an invented ACK.
    a.failed=true; a.performance.step=a.step
    self.untilTime=math.max(self.untilTime,self.last+math.max(5,self.db.pacing.minimum))
    self:Preview(); self.notice=reason.." Message kept for manual retry."
    return true
end
function Engine:SaveStory(story,id)
    local ok,err=C.ValidateStory(story); if not ok then return nil,err end
    if id and not self.db.stories[id] then return nil,"Bundled stories are protected. Duplicate into a personal story." end
    if not id then
        repeat id="personal_"..self.env.epoch().."_"..self.db.nextID; self.db.nextID=self.db.nextID+1 until not self.db.stories[id]
    end
    local s=copy(story); s.id=id; self.db.stories[id]=s
    -- The active performance is a snapshot. Editing cannot change a message mid-tale.
    self:Preview(); return id
end
function Engine:DeleteStory(id)
    if not self.db.stories[id] then return nil,"Only personal stories can be deleted." end
    self.db.stories[id]=nil; return true
end
