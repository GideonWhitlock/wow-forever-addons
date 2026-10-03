local _,ns=...
local C=ns.Core
local U={page="performance",libraryPage=1,filter="Bundled",widgets={}}; ns.UI=U
local function label(p,text,x,y,w,h,font)
    local f=p:CreateFontString(nil,"OVERLAY",font or "GameFontHighlight")
    f:SetPoint("TOPLEFT",p,"TOPLEFT",x,y); f:SetSize(w,h or 24); f:SetJustifyH("LEFT"); f:SetJustifyV("TOP"); f:SetWordWrap(true); f:SetText(text); return f
end
local function button(p,text,x,y,w,fn)
    local b=CreateFrame("Button",nil,p,"UIPanelButtonTemplate")
    b:SetPoint("TOPLEFT",p,"TOPLEFT",x,y); b:SetSize(w,26); b:SetText(text); b:RegisterForClicks("LeftButtonUp"); b:SetScript("OnClick",fn)
    U.widgets[#U.widgets+1]=b; return b
end
local function background(f,r,g,b)
    local t=f:CreateTexture(nil,"BACKGROUND"); t:SetAllPoints(f); t:SetColorTexture(r,g,b,0.97)
end
local function edit(p,x,y,w,h,multiline,changed)
    local box=CreateFrame("Frame",nil,p); box:SetPoint("TOPLEFT",p,"TOPLEFT",x,y); box:SetSize(w,h); background(box,0.10,0.085,0.07)
    local scroll
    if multiline then
        scroll=CreateFrame("ScrollFrame",nil,box,"UIPanelScrollFrameTemplate"); scroll:SetPoint("TOPLEFT",box,"TOPLEFT",6,-5); scroll:SetPoint("BOTTOMRIGHT",box,"BOTTOMRIGHT",-27,5)
    end
    local e=CreateFrame("EditBox",nil,scroll or box); e:SetSize(w-(multiline and 40 or 12),h-10); e:SetMultiLine(multiline==true); e:SetAutoFocus(false); e:SetFontObject("ChatFontNormal"); e:SetMaxLetters(0)
    if not multiline then e:SetPoint("TOPLEFT",box,"TOPLEFT",6,-5); e:SetScript("OnEnterPressed",function(self) self:ClearFocus() end) end
    e:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
    e:SetScript("OnTextChanged",function(self,user)
        if multiline then
            local _,fontHeight=self:GetFont()
            self:SetHeight(math.max(h-10,self:GetNumLines()*((fontHeight or 14)+self:GetSpacing())+12))
        end
        if changed and not U.filling then changed(self,user) end
    end)
    if scroll then e:SetScript("OnCursorChanged",function(self,_,cy,_,ch)
        local offset=scroll:GetVerticalScroll(); local height=scroll:GetHeight()
        if -cy<offset then scroll:SetVerticalScroll(-cy)
        elseif -cy+ch>offset+height then scroll:SetVerticalScroll(-cy+ch-height) end
    end); scroll:SetScrollChild(e) end
    e.box=box; e.scroll=scroll; return e
end
local function lines(text)
    local result={}; text=text:gsub("\r\n","\n")
    for line in (text.."\n"):gmatch("(.-)\n") do result[#result+1]=line end
    if result[#result]=="" then table.remove(result) end
    return result
end
local function report(ok,err)
    U.message=err or (ok and "Saved." or "Unable to complete this action.")
    if U.status then U.status:SetText(U.message) end
    return ok
end
function U:Confirm(message,fn)
    local modal=self.modal
    if not modal then
        modal=CreateFrame("Frame",nil,self.frame); modal:SetAllPoints(self.frame); modal:SetFrameLevel(self.frame:GetFrameLevel()+20); modal:EnableMouse(true); background(modal,0.035,0.025,0.02)
        modal.text=label(modal,"",120,-220,660,100,"GameFontNormalLarge")
        button(modal,"Confirm",285,-340,150,function() local action=modal.action; modal.action=nil; modal:Hide(); if action then action() end end)
        button(modal,"Cancel",455,-340,150,function() modal.action=nil; modal:Hide() end)
        self.modal=modal
    end
    modal.text:SetText(message); modal.action=fn; modal:Show()
end
function U:Guard(fn)
    if self.dirty then self:Confirm("Discard the unsaved editor draft? Your saved stories will remain available.",function()
        local saved=self.editID and self.engine.db.stories[self.editID]
        self:FillDraft(saved or {},saved and self.editID or nil); fn()
    end) else fn() end
end
function U:ShowPage(page)
    self:Build()
    self:Guard(function()
        if self.compact then self.compact:Hide() end
        self.smallWindow=false
        self.page=page; self.frame:Show()
        if page=="performance" then self.selectedID=self.engine.db.performance.story.id end
        for k,p in pairs(self.pages) do p:SetShown(k==page) end
        if page=="settings" then self:FillSettings() end
        self:RefreshLibrary(); self:Refresh()
    end)
end
function U:Toggle()
    self:Build()
    if self.compact and self.compact:IsShown() then self.compact:Hide()
    elseif self.frame:IsShown() then self:Guard(function() self.frame:Hide() end)
    elseif self.smallWindow then self:ShowCompact()
    else self.frame:Show(); self:Refresh() end
end
function U:HasVisiblePreview()
    if (self.modal and self.modal:IsShown()) or (self.transfer and self.transfer:IsShown()) then return false end
    return (self.compact and self.compact:IsShown()) or (self.frame and self.frame:IsShown() and self.page=="performance")
end
function U:ChosenStory() return self.engine:Story(self.selectedID) or self.engine.db.performance.story end
function U:SelectStory(id,onSelected)
    local e=self.engine; local p=e.db.performance
    local latest=e:Story(id)
    if id==p.story.id and not e:Preview().finished and (not latest or C.ExportStory(latest)==C.ExportStory(p.story)) then
        self.selectedID=id; if onSelected then onSelected() end; self:RefreshLibrary(); self:Refresh(); return
    end
    local choose=function()
        local ok,err=e:Select(id)
        if not ok then report(nil,err); return end
        self.selectedID=id; e.db.paused=false
        if onSelected then onSelected() end
        self.randomSeen=self.randomSeen or {}; self.randomSeen[id]=true
        self.message=""
        self:RefreshLibrary(); self:Refresh()
    end
    if p.started and not e:Preview().finished then
        self:Confirm("Switch stories? This will leave your current telling. Your saved stories are kept.",choose)
    else choose() end
end
function U:MatchingStories()
    local query=string.lower(self.search:GetText() or ""); local list={}
    local source=self.filter=="Bundled" and ns.Stories or self.engine.db.stories
    for _,s in pairs(source) do
        if query=="" or string.find(string.lower(s.title.." "..s.premise),query,1,true) then list[#list+1]=s end
    end
    table.sort(list,function(a,b) return a.title<b.title end)
    return list,query
end
function U:PickStory()
    local list=self:MatchingStories(); if #list==0 then return end
    local current=self.engine.db.performance.story.id
    local seen=self.randomSeen or {}; local candidates={}
    for _,s in ipairs(list) do if s.id~=current and not seen[s.id] then candidates[#candidates+1]=s end end
    local newRound=#candidates==0
    if newRound then for _,s in ipairs(list) do if s.id~=current or #list==1 then candidates[#candidates+1]=s end end end
    local selected=candidates[self.engine.env.random(1,#candidates)]
    self:SelectStory(selected.id,function()
        -- Commit history only after the user accepts leaving an unfinished tale.
        self.randomSeen=self.randomSeen or {}
        if newRound then for _,s in ipairs(list) do self.randomSeen[s.id]=nil end
        else self.randomSeen[current]=true end
        self.randomSeen[selected.id]=true
    end)
end
function U:RefreshLibrary()
    if not self.search then return end
    local list,query=self:MatchingStories()
    local maxPage=math.max(1,math.ceil(#list/11)); self.libraryPage=math.min(self.libraryPage,maxPage)
    for i,row in ipairs(self.rows) do
        local s=list[(self.libraryPage-1)*11+i]; row.story=s
        row:SetShown(s~=nil)
        if s then row:SetText((s.id==self.selectedID and "> " or "")..s.title) end
    end
    self.libraryCount:SetText(#list.." stories · Page "..self.libraryPage.." of "..maxPage)
    self.emptyLibrary:SetText(query~="" and "No stories match your search." or "Your own tales will appear here. Use Write a story to create one.")
    self.emptyLibrary:SetShown(#list==0)
    self.libraryMax=maxPage
    self.pick:SetEnabled(#list>0)
end
function U:Refresh()
    if not self.engine or not self.frame then return end
    local e=self.engine; local p=e.db.performance; local v=e:Preview()
    self.title:SetText(v.title or "Campfire Stories: Forever")
    local credit=ns.StoryCredits and ns.StoryCredits[p.story.id]
    self.premise:SetText(credit or p.story.premise)
    self.progress:SetText(v.finished and "The end" or ("Next: "..(v.stage or "message")))
    self.preview:SetText(v.error or v.text or "You have reached the end of this story. Choose another tale from the list, or tell this one again.")
    self.destination:SetText(v.channel and ((v.channel=="PARTY" and "Your party only" or "Nearby players").."  ·  /"..v.channel:lower()) or "Nothing more will be shared.")
    local restriction=v.channel and e.env.restriction(v.channel)
    local state=v.finished and "Story finished" or (e.db.paused and "Paused — your place is saved" or (v.error or restriction or (v.remaining>0 and ("Next message in "..math.ceil(v.remaining).." seconds") or "Ready when you are")))
    self.readiness:SetText(state)
    local start=p.step==C.FirstStep(p.story) and not p.started
    self.send:SetText(v.finished and "Story finished" or (e.db.paused and "Resume story" or (start and "Start story" or "Next line")))
    self.send:SetEnabled(not v.finished and not v.error and (e.db.paused or (not restriction and v.remaining==0)))
    self.hint:SetText(v.finished and "Choose another story, or click Reset story to tell this one again." or (e.db.paused and "Resume first, then click again when you want to share the next message." or (start and "Start story shares the message shown. Keep clicking Next line to tell the tale." or "Click Next line when ready. Nothing is shared until you click.")))
    self.pause:SetText(e.db.paused and "Resume" or "Pause")
    local custom=p.story.openingMode=="custom"
    for _,control in ipairs({self.shuffle,self.previewAction,self.previewIntro,self.viewOpenings}) do control:SetShown(custom) end
    self.shuffle:SetEnabled(custom and not p.started)
    self.audience:SetText("Selected: "..(e.db.channel=="PARTY" and "Your party only" or "Nearby players (/say)"))
    self.details:SetText(v.delay and (v.chars.." characters · "..v.bytes.."/255 bytes · "..v.delay.."s calculated wait") or "Story finished")
    self.status:SetText(self.message or (e.notice~="" and e.notice) or "Choose a story on the left to begin.")
    if self.compact then
        local f=self.compact
        f.title:SetText(self.title:GetText()); f.progress:SetText(self.progress:GetText())
        f.preview:SetText(self.preview:GetText()); f.destination:SetText(self.destination:GetText())
        f.readiness:SetText(state); f.send:SetText(self.send:GetText())
        f.send:SetEnabled(not v.finished and not v.error and (e.db.paused or (not restriction and v.remaining==0)))
        f.message:SetText(self.message~="" and self.message or (v.finished and "Choose Library for another tale, or Reset story to begin again." or "One click shares one message. Drag this window to move it."))
    end
end
function U:ShowCompact()
    self:Build()
    self:Guard(function()
        if (self.modal and self.modal:IsShown()) or (self.transfer and self.transfer:IsShown()) then return end
        if not self.compact then
            local f=CreateFrame("Frame","CampfireStorySmallPanel",UIParent); self.compact=f
            f:SetSize(540,390); f:SetPoint("CENTER",UIParent,"CENTER",0,-100)
            f:SetClampedToScreen(true); f:SetFrameStrata("DIALOG"); f:EnableMouse(true); f:SetMovable(true); f:RegisterForDrag("LeftButton")
            local scale=math.min(1,(UIParent:GetWidth()-30)/540,(UIParent:GetHeight()-30)/390); if scale>0 then f:SetScale(scale) end
            background(f,0.055,0.045,0.035)
            f:SetScript("OnDragStart",function(s) s:StartMoving() end)
            f:SetScript("OnDragStop",function(s) s:StopMovingOrSizing() end)
            f.title=label(f,"",20,-16,416,45,"GameFontNormalLarge")
            button(f,"Close",448,-12,72,function() f:Hide() end)
            f.progress=label(f,"",20,-67,500,24,"GameFontNormal")
            f.preview=label(f,"",20,-101,500,120,"GameFontHighlight")
            f.destination=label(f,"",20,-230,500,22,"GameFontHighlightSmall")
            f.readiness=label(f,"",20,-264,500,26,"GameFontNormal")
            f.send=button(f,"Start story",20,-300,220,function() if self.engine.db.paused then ns.Actions.pause(false) else ns.Actions.send() end end); f.send:SetHeight(38)
            button(f,"Reset story",250,-300,150,function() ns.Actions.reset() end):SetHeight(38)
            button(f,"Library",410,-300,110,function() self:ShowPage("performance") end):SetHeight(38)
            f.message=label(f,"",20,-349,500,34,"GameFontHighlightSmall")
            local elapsed=0
            f:SetScript("OnUpdate",function(_,dt) elapsed=elapsed+dt; if elapsed>=0.1 then elapsed=0; self:Refresh() end end)
        end
        self.smallWindow=true; self.frame:Hide(); self.compact:Show(); self:Refresh()
    end)
end
function U:Draft()
    local function openings(text)
        local out={}
        if text=="" then return out end
        for _,row in ipairs(lines(text)) do
            local group,body=row:match("^([^:]+):(.*)$")
            out[#out+1]={group=group or "*",text=body or row}
        end
        return out
    end
    return {title=self.edTitle:GetText(),premise=self.edPremise:GetText(),lines=lines(self.edLines:GetText()),
        openingMode=self.draftMode or "none",emotes=openings(self.edEmotes:GetText()),introductions=openings(self.edIntros:GetText())}
end
function U:LoadDraft(story,id)
    self:ShowPage("editor"); self:FillDraft(story,id)
end
function U:FillDraft(story,id)
    self.filling=true; self.editID=id
    self.edTitle:SetText(story.title or ""); self.edPremise:SetText(story.premise or ""); self.edLines:SetText(table.concat(story.lines or {},"\n"))
    local function text(items) local out={}; for _,x in ipairs(items or {}) do out[#out+1]=x.group..":"..x.text end; return table.concat(out,"\n") end
    self.edEmotes:SetText(text(story.emotes)); self.edIntros:SetText(text(story.introductions)); self.draftMode=(story.openingMode=="custom" or story.openingMode=="emote") and story.openingMode or "none"
    self.openingMode:SetText(self.draftMode=="custom" and "Custom openings" or (self.draftMode=="emote" and "Opening emote" or "Story text only"))
    self.filling=false; self.dirty=false; self.editMessage:SetText(id and "Editing personal story. Save also applies a changed title." or "New personal story. Enter a title and 1–30 lines.")
end
function U:EditSelected(duplicate)
    self:Guard(function()
        local s=self:ChosenStory(); local id=self.engine.db.stories[s.id] and s.id or nil
        if not duplicate and not id then report(nil,"This is an included story. Choose Copy to my stories to make an editable copy."); return end
        s=C.Copy(s); if duplicate then s.title=s.title.." (copy)"; id=nil end
        self:LoadDraft(s,id)
    end)
end
function U:EditorSection(section)
    self.editSection=section
    for name,p in pairs(self.editPages) do p:SetShown(name==section) end
end
function U:EditLine(action)
    local rows=lines(self.edLines:GetText()); local n=tonumber(self.lineNumber:GetText())
    if not n or n~=math.floor(n) or n<1 or n>#rows+(action=="insert" and 1 or 0) then self.editMessage:SetText("Enter a valid main-line number."); return end
    if action=="load" then self.lineText:SetText(rows[n]); return end
    if action=="replace" then rows[n]=self.lineText:GetText()
    elseif action=="insert" then if #rows>=30 then self.editMessage:SetText("Maximum 30 main lines."); return end; table.insert(rows,n,self.lineText:GetText())
    elseif action=="delete" then self:Confirm("Delete main line "..n.." from this unsaved draft?",function() table.remove(rows,n); self.edLines:SetText(table.concat(rows,"\n")); self.dirty=true end); return
    elseif action=="up" and n>1 then rows[n-1],rows[n]=rows[n],rows[n-1]; self.lineNumber:SetText(tostring(n-1))
    elseif action=="down" and n<#rows then rows[n+1],rows[n]=rows[n],rows[n+1]; self.lineNumber:SetText(tostring(n+1)) end
    self.edLines:SetText(table.concat(rows,"\n")); self.dirty=true
end
function U:ValidateDraft()
    local s=self:Draft(); local ok,err=C.ValidateStory(s)
    if not ok then self.editMessage:SetText(err); return end
    local sum,min,max=0,300,0
    for _,line in ipairs(s.lines) do local d=C.Delay(line,self.engine.db.pacing); sum=sum+d; min=math.min(min,d); max=math.max(max,d) end
    local pair=C.Pairs(s)[1]
    self.editMessage:SetText(#s.lines.." valid main lines · waits "..min.."–"..max.."s · main-line estimate "..sum.."s (manual pauses can be longer).")
    local opening=pair and ("Opening action (/emote, or labelled /party action):\n"..pair.emote.."\n\n"..(pair.intro and ("Introduction:\n"..pair.intro.."\n\n") or "")) or ""
    self:Transfer("Private draft preview",opening..table.concat(s.lines,"\n\n"))
end
function U:Transfer(title,text)
    self:Build()
    if self.compact then self.compact:Hide() end
    self.smallWindow=false
    self.frame:Show()
    if self.transfer and self.transfer.dirty then
        self:Confirm("Replace the unsaved text in the import/export box? Copy it elsewhere first if you need it.",function() self.transfer.dirty=false; self:Transfer(title,text) end)
        return
    end
    if not self.transfer then
        local f=CreateFrame("Frame",nil,self.frame); f:SetAllPoints(self.frame); f:SetFrameLevel(self.frame:GetFrameLevel()+10); f:EnableMouse(true); background(f,0.06,0.045,0.03)
        f.title=label(f,"",24,-20,810,30,"GameFontNormalLarge")
        label(f,"Copy text with Ctrl+A, Ctrl+C. Paste with Ctrl+V. Imports are data only; nothing is broadcast.",24,-58,830,30)
        f.text=edit(f,24,-100,840,400,true,function(_,user) if user then f.dirty=true end end)
        button(f,"Select all",24,-520,110,function() f.text:SetFocus(); f.text:HighlightText() end)
        button(f,"Import story",145,-520,135,function()
            local s,err=C.ImportStory(f.text:GetText()); if not s then f.message:SetText(err); return end
            self:Guard(function() f.dirty=false; f:Hide(); self:LoadDraft(s); self.dirty=true end)
        end)
        button(f,"Restore backup",290,-520,150,function()
            local data,err=C.ImportAccount(f.text:GetText()); if not data then f.message:SetText(err); return end
            self:Confirm("Merge this backup as new personal copies and restore its settings and performance? Existing stories are kept. Sending will be paused.",function()
                local ok,msg=self.engine:RestoreAccount(f.text:GetText()); f.message:SetText(msg); if ok then f.dirty=false; self:UpdateMinimap(); self:RefreshLibrary(); self:Refresh() end
            end)
        end)
        button(f,"Close",744,-520,120,function() f:Hide() end)
        f.message=label(f,"",24,-562,840,55); self.transfer=f
    end
    self.transfer.title:SetText(title); self.transfer.text:SetText(text or ""); self.transfer.dirty=false; self.transfer.message:SetText("Exports are not files until you copy and save them outside the game."); self.transfer:Show()
end
function U:FillSettings()
    for k,e in pairs(self.paceFields) do e:SetText(tostring(self.engine.db.pacing[k])) end
    self.settingsMode:SetText(self.engine.db.pacing.mode=="dynamic" and "Dynamic selected" or "Fixed selected")
    self.minimapVisibility:SetText(self.engine.db.minimap.hidden and "Show minimap button" or "Hide minimap button")
    self.sourceReplies:SetText(self.engine.db.autoSourceReplies==false and "Source replies: Off" or "Source replies: On")
end
function U:ApplySettings(mode)
    local p=C.Copy(self.engine.db.pacing)
    for k,e in pairs(self.paceFields) do p[k]=tonumber(e:GetText()) end
    if mode then p.mode=mode end
    report(self.engine:SetPacing(p)); self:FillSettings(); self:Refresh()
end
function U:Build()
    if self.frame then return end
    local e=self.engine
    local f=CreateFrame("Frame","CampfireStoryPanel",UIParent); self.frame=f
    f:SetSize(900,650); f:SetPoint("CENTER",UIParent,"CENTER",e.db.window.x,e.db.window.y); f:SetClampedToScreen(true); f:SetFrameStrata("DIALOG")
    local scale=math.min(1,(UIParent:GetWidth()-30)/900,(UIParent:GetHeight()-30)/650); if scale>0 then f:SetScale(scale) end
    f:EnableMouse(true); f:SetMovable(true); f:RegisterForDrag("LeftButton"); background(f,0.055,0.045,0.035)
    f:SetScript("OnDragStart",function(s) s:StartMoving() end)
    f:SetScript("OnDragStop",function(s) s:StopMovingOrSizing(); local x,y=s:GetCenter(); local px,py=UIParent:GetCenter(); e.db.window={x=x-px,y=y-py} end)
    label(f,"Campfire Stories: Forever",20,-16,640,28,"GameFontNormalLarge")
    button(f,"Close",810,-12,72,function() self:Guard(function() f:Hide() end) end)
    local tabs={{"performance","Tell a story"},{"editor","Write a story"},{"settings","Settings"},{"help","Help"}}
    for i,t in ipairs(tabs) do local key=t[1]; button(f,t[2],20+(i-1)*215,-51,205,function() self:ShowPage(key) end) end
    self.pages={}
    for _,t in ipairs(tabs) do local p=CreateFrame("Frame",nil,f); p:SetPoint("TOPLEFT",f,"TOPLEFT",20,-94); p:SetSize(860,492); self.pages[t[1]]=p; p:Hide() end
    local options=CreateFrame("Frame",nil,f); options:SetPoint("TOPLEFT",f,"TOPLEFT",20,-94); options:SetSize(860,492); options:Hide(); self.pages.options=options
    self.status=label(f,"",20,-602,860,40,"GameFontHighlightSmall")
    local p=self.pages.performance
    self.search=edit(p,0,-22,280,32,false,function() self.libraryPage=1; self:RefreshLibrary() end)
    label(p,"Search stories",0,0,275,20,"GameFontNormal")
    button(p,"Included stories",0,-64,134,function() self.filter="Bundled"; self.libraryPage=1; self:RefreshLibrary() end)
    button(p,"My stories",144,-64,134,function() self.filter="Personal"; self.libraryPage=1; self:RefreshLibrary() end)
    self.rows={}
    for i=1,11 do local row; row=button(p,"",0,-102-(i-1)*28,280,function() self:SelectStory(row.story.id) end); self.rows[i]=row end
    self.emptyLibrary=label(p,"",0,-118,280,88)
    button(p,"Previous",0,-416,87,function() self.libraryPage=math.max(1,self.libraryPage-1); self:RefreshLibrary() end)
    button(p,"Next page",183,-416,97,function() self.libraryPage=math.min(self.libraryMax,self.libraryPage+1); self:RefreshLibrary() end)
    self.libraryCount=label(p,"",0,-449,280,20,"GameFontHighlightSmall")
    self.pick=button(p,"Pick for me",0,-475,280,function() self:PickStory() end)
    self.title=label(p,"",306,0,550,30,"GameFontNormalLarge")
    self.premise=label(p,"",306,-40,545,50)
    local card=CreateFrame("Frame",nil,p); card:SetPoint("TOPLEFT",p,"TOPLEFT",306,-105); card:SetSize(550,183); background(card,0.10,0.08,0.055)
    self.progress=label(card,"",16,-12,513,24,"GameFontNormal")
    self.preview=label(card,"",16,-49,515,92,"GameFontHighlightLarge")
    self.destination=label(card,"",16,-154,515,22,"GameFontHighlightSmall")
    self.readiness=label(p,"",306,-311,545,32,"GameFontNormalLarge")
    self.send=button(p,"Start story",306,-354,350,function() if e.db.paused then ns.Actions.pause(false) else ns.Actions.send() end end); self.send:SetHeight(42)
    self.reset=button(p,"Reset story",674,-354,182,function() ns.Actions.reset() end); self.reset:SetHeight(42)
    self.more=button(p,"More options",306,-465,182,function() self:ShowPage("options") end)
    button(p,"Small window",674,-465,182,function() self:ShowCompact() end)
    self.hint=label(p,"",306,-411,545,45)
    self.selectedID=e.db.performance.story.id
    self:BuildOptions(); self:BuildEditor(); self:BuildSettings(); self:BuildHelp()
    local elapsed=0
    f:SetScript("OnUpdate",function(_,dt) elapsed=elapsed+dt; if elapsed>=0.1 then elapsed=0; self:Refresh() end end) -- display only
    f:Hide(); self.pages.performance:Show(); self:RefreshLibrary(); self:Refresh()
end
function U:BuildOptions()
    local p=self.pages.options; local e=self.engine
    button(p,"Back to story",0,0,180,function() self:ShowPage("performance") end)
    label(p,"More options",210,0,600,28,"GameFontNormalLarge")
    label(p,"Who hears your story?",0,-52,820,24,"GameFontNormal")
    button(p,"Nearby players",0,-86,185,function() ns.Actions.channel("SAY") end)
    button(p,"Your party only",198,-86,185,function() ns.Actions.channel("PARTY") end)
    self.audience=label(p,"",403,-88,445,46,"GameFontHighlightSmall")
    label(p,"Change your place in this story",0,-144,820,24,"GameFontNormal")
    self.pause=button(p,"Pause",0,-181,135,function() ns.Actions.pause(not e.db.paused); self:ShowPage("performance") end)
    button(p,"Back one message",147,-181,191,function() ns.Actions.back() end)
    self.shuffle=button(p,"Choose another opening",350,-181,300,function() ns.Actions.shuffle(); self:ShowPage("performance") end)
    label(p,"Story line",0,-231,90,24); self.goLine=edit(p,95,-225,67,32,false); self.goLine:SetText("1")
    button(p,"Preview this line",175,-226,185,function() ns.Actions.gotoLine(tonumber(self.goLine:GetText())) end)
    self.previewAction=button(p,"Preview opening action",372,-226,230,function() ns.Actions.navigate(1) end)
    self.previewIntro=button(p,"Preview introduction",614,-226,236,function() ns.Actions.navigate(2) end)
    label(p,"Previewing changes only the text shown. Use the main button when you want to share it.",0,-269,850,24,"GameFontHighlightSmall")
    label(p,"Story tools",0,-315,820,24,"GameFontNormal")
    button(p,"Edit my story",0,-350,171,function() self:EditSelected(false) end)
    button(p,"Copy to my stories",183,-350,210,function() self:EditSelected(true) end)
    button(p,"Export this story",405,-350,207,function() self:Transfer("Story export",C.ExportStory(self:ChosenStory())) end)
    self.viewOpenings=button(p,"View both openings",624,-350,226,function() self:Transfer("Opening preview",(e.db.performance.opening.emote or "").."\n\n"..(e.db.performance.opening.intro or "")) end)
    button(p,"Pacing settings",0,-407,210,function() self:ShowPage("settings") end)
    self.details=label(p,"",230,-413,620,25,"GameFontHighlightSmall")
end
function U:BuildEditor()
    local p=self.pages.editor
    local changed=function() self.dirty=true end
    label(p,"Title",0,0,100,20); self.edTitle=edit(p,0,-23,415,33,false,changed)
    label(p,"Premise (optional; a noun phrase, without an ending spoiler)",435,0,425,20); self.edPremise=edit(p,435,-23,425,33,false,changed)
    button(p,"Main lines",0,-69,150,function() self:EditorSection("lines") end)
    button(p,"Opening actions & introductions",160,-69,284,function() self:EditorSection("openings") end)
    self.editPages={}
    for _,key in ipairs({"lines","openings"}) do local f=CreateFrame("Frame",nil,p); f:SetSize(860,292); f:SetPoint("TOPLEFT",p,"TOPLEFT",0,-111); self.editPages[key]=f end
    local l=self.editPages.lines
    label(l,"Paste one chat message per line. Blank lines are errors; nothing is silently trimmed.",0,0,850,20,"GameFontHighlightSmall")
    self.edLines=edit(l,0,-26,540,264,true,changed)
    label(l,"Numbered line tools",560,0,280,23,"GameFontNormal")
    self.lineNumber=edit(l,560,-28,69,32,false); self.lineNumber:SetText("1")
    button(l,"Load line",640,-29,110,function() self:EditLine("load") end)
    self.lineText=edit(l,560,-74,300,96,true)
    button(l,"Replace",560,-181,92,function() self:EditLine("replace") end)
    button(l,"Insert before",660,-181,125,function() self:EditLine("insert") end)
    button(l,"Delete",560,-219,92,function() self:EditLine("delete") end)
    button(l,"Up",660,-219,60,function() self:EditLine("up") end)
    button(l,"Down",730,-219,65,function() self:EditLine("down") end)
    local o=self.editPages.openings
    self.openingMode=button(o,"Story text only",0,0,190,function()
        self.draftMode=self.draftMode=="none" and "emote" or (self.draftMode=="emote" and "custom" or "none")
        self.openingMode:SetText(self.draftMode=="custom" and "Custom openings" or (self.draftMode=="emote" and "Opening emote" or "Story text only")); self.dirty=true
    end)
    label(o,"Custom: one alternative per row, group:text. Matching groups pair together; * matches any. One pair gives fixed openings.",212,0,640,44,"GameFontHighlightSmall")
    label(o,"Emotes: action only, no character name or /e",0,-51,415,22,"GameFontNormal")
    label(o,"Introductions: {title} and {premise} are supported",435,-51,425,22,"GameFontNormal")
    self.edEmotes=edit(o,0,-80,415,158,true,changed); self.edIntros=edit(o,435,-80,425,158,true,changed)
    label(o,"Example emote: book:opens a worn journal.\nExample introduction: book:This journal tells of {premise}.\nMissing premise falls back to a title-based phrase. All compatible combinations must fit the chat limit.",0,-249,850,50,"GameFontHighlightSmall")
    self:EditorSection("lines")
    button(p,"New",0,-418,75,function() self:Guard(function() self:LoadDraft({}) end) end)
    button(p,"Save / rename",85,-418,139,function()
        local id,err=self.engine:SaveStory(self:Draft(),self.editID)
        if id then self.editID=id; self.selectedID=id; self.dirty=false; self.editMessage:SetText("Saved. Find this tale under Tell a story > My stories, then choose its title to tell it."); self:RefreshLibrary() else self.editMessage:SetText(err) end
    end)
    button(p,"Preview & validate",234,-418,173,function() self:ValidateDraft() end)
    button(p,"Delete saved",417,-418,130,function()
        if not self.editID then self.editMessage:SetText("Load a personal story to delete it."); return end
        self:Confirm("Delete this saved personal story? Export it first if you may want it back. An active performance snapshot will remain.",function() report(self.engine:DeleteStory(self.editID)); self.dirty=false; self:LoadDraft({}); self:RefreshLibrary() end)
    end)
    button(p,"Import",557,-418,95,function() self:Transfer("Import a story or account backup","") end)
    button(p,"Export draft",662,-418,130,function() local text,err=C.ExportStory(self:Draft()); if text then self:Transfer("Full-story export",text) else self.editMessage:SetText(err) end end)
    self.editMessage=label(p,"Create a personal story, or duplicate one from the library.",0,-459,858,43,"GameFontHighlightSmall")
    self.draftMode="none"; self.filling=true; for _,b in ipairs({self.edTitle,self.edPremise,self.edLines,self.edEmotes,self.edIntros}) do b:SetText("") end; self.filling=false
end
function U:BuildSettings()
    local p=self.pages.settings
    label(p,"Story pacing enables your next manual press; story lines never send automatically.",0,0,840,28,"GameFontNormal")
    self.settingsMode=label(p,"",0,-39,320,28)
    button(p,"Dynamic",340,-34,126,function() self:ApplySettings("dynamic") end)
    button(p,"Fixed",478,-34,126,function() self:ApplySettings("fixed") end)
    self.paceFields={}
    local fields={{"fixed","Fixed gap (seconds)"},{"preparation","Preparation (seconds)"},{"rate","Characters per second"},{"minimum","Minimum gap (seconds)"},{"maximum","Maximum gap (seconds)"},{"scale","Dynamic delay multiplier"}}
    for i,v in ipairs(fields) do local x=(i-1)%2*440; local y=-86-math.floor((i-1)/2)*64
        label(p,v[2],x,y,270,24); self.paceFields[v[1]]=edit(p,x+285,y+5,130,33,false)
    end
    button(p,"Faster",0,-292,120,function() local v=tonumber(self.paceFields.scale:GetText()) or 1; self.paceFields.scale:SetText(tostring(math.max(0.25,v-0.25))); self:ApplySettings("dynamic") end)
    button(p,"Slower",132,-292,120,function() local v=tonumber(self.paceFields.scale:GetText()) or 1; self.paceFields.scale:SetText(tostring(math.min(4,v+0.25))); self:ApplySettings("dynamic") end)
    button(p,"Apply",264,-292,120,function() self:ApplySettings() end)
    button(p,"Restore Defaults",396,-292,165,function() report(self.engine:SetPacing(C.Copy(C.DEFAULTS))); self:FillSettings(); self:Refresh() end)
    button(p,"Preview wait",575,-292,145,function() local v=self.engine:Preview(); self:Transfer("Current pacing preview",(v.text or "Finished").."\n\n"..(v.delay and (v.chars.." characters; "..v.delay.." seconds.\nOutstanding wait: "..string.format("%.1f",v.remaining).." seconds.") or "No next message.")) end)
    label(p,"Default: ceil(1 + characters / 12), limited to 2–20 seconds. Faster/slower scales the dynamic calculation within those limits. Applying settings cannot shorten an outstanding wait.",0,-335,845,52,"GameFontHighlightSmall")
    self.minimapVisibility=button(p,"",0,-405,215,function() ns.Actions.minimap(not self.engine.db.minimap.hidden); self:FillSettings() end)
    button(p,"Reset minimap position",228,-405,220,function() self.engine.db.minimap.angle=225; self:UpdateMinimap() end)
    button(p,"Export all / backup",461,-405,190,function() local text,err=C.ExportAccount(self.engine.db); if text then self:Transfer("Personal library and settings backup",text) else report(nil,err) end end)
    button(p,"Restore backup",664,-405,188,function() self:Transfer("Restore account backup","") end)
    self.sourceReplies=button(p,"Source replies: On",0,-453,215,function()
        self.engine.db.autoSourceReplies=self.engine.db.autoSourceReplies==false
        if ns.replies then ns.replies.pending=nil end
        self:FillSettings()
    end)
    label(p,"Private source reply when an audience member mentions AI during an active included story. Once per person per login; no replies while paused, closed or idle.",235,-453,610,48,"GameFontHighlightSmall")
end
function U:BuildHelp()
    local p=self.pages.help
    label(p,"Choose a tale. Tell it at your own pace.",0,0,840,32,"GameFontNormalLarge")
    label(p,"1. Choose a story, or use Pick for me. Its opening appears straight away. Small window opens a compact telling panel; Library brings you back.\n\n2. Start story shares the opening emote. Wait until the button is ready, then click Next line to begin the original story and continue each line. Story lines never send automatically.\n\n3. Reset story, beside the main button, returns to the beginning without sharing anything. Use it whenever you want to start again.\n\nNearby players see the opening action in /emote and hear the story in /say. Personal stories can use their own openings or start directly with their text. More options lets you choose Your party only instead; every message then stays in a normal invited party.\n\nNeed to pause, go back or choose a particular line? Open More options. Preview controls only change what is shown. The main button shares it when you choose.\n\nIf a message does not appear in chat, check for a game error. Use More options > Back one message to select it again, then retry with Next line when ready. An accepted send request does not prove delivery.\n\nWrite a story lets you save your own tales or import text. Use More options > Copy to my stories to edit an included tale. Settings holds pacing and library backup controls. Keep an external backup of your personal stories.",0,-47,840,333)
    button(p,"Show next message",0,-403,170,function() ns.Actions.preview() end)
    button(p,"Client diagnostics",185,-403,195,function() self:Transfer("Local diagnostics",ns.Diagnostics()) end)
    button(p,"Command reference",395,-403,195,function() self:Transfer("Commands and clickable equivalents",ns.CommandReference) end)
    button(p,"Import / export help",605,-403,240,function() self:Transfer("Story format",ns.FormatHelp) end)
    label(p,"Original campfire fiction for WoW: Forever. Test build: actual-client validation is ongoing. No adverts, telemetry, online service or companion addon is required.",0,-455,850,40,"GameFontHighlightSmall")
end
function U:UpdateMinimap()
    if not self.minimap then return end
    local b=self.minimap; local m=self.engine.db.minimap; local a=math.rad(m.angle)
    -- Measure the real map, including its scale; do not assume an 80px radius.
    -- Overlap the rim slightly, like the neighbouring minimap controls.
    local scale=Minimap:GetEffectiveScale()/b:GetEffectiveScale()
    local rx=Minimap:GetWidth()*scale/2+4
    local ry=Minimap:GetHeight()*scale/2+4
    b:ClearAllPoints(); b:SetPoint("CENTER",Minimap,"CENTER",math.cos(a)*rx,math.sin(a)*ry); b:SetShown(not m.hidden)
    b.mapWidth=Minimap:GetWidth(); b.mapHeight=Minimap:GetHeight(); b.mapScale=scale
end
function U:Init(engine)
    self.engine=engine
    if Minimap then
        local b=CreateFrame("Button","CampfireStoryMinimapButton",Minimap:GetParent() or UIParent); self.minimap=b; b:SetSize(28,28); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(Minimap:GetFrameLevel()+5)
        b:SetNormalTexture("Interface\\AddOns\\CampfireStory\\Media\\CampfireHomer"); b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        b:RegisterForClicks("LeftButtonUp","RightButtonUp"); b:RegisterForDrag("LeftButton")
        b:SetScript("OnClick",function(_,which) if b.dragged then b.dragged=false; return end; if which=="RightButton" then self:ShowPage("settings") else self:Toggle() end end)
        b:SetScript("OnEnter",function() if GameTooltip then GameTooltip:SetOwner(b,"ANCHOR_LEFT"); GameTooltip:AddLine("Campfire Stories: Forever"); GameTooltip:AddLine("Left-click: open or close",1,1,1); GameTooltip:AddLine("Right-click: settings",1,1,1); GameTooltip:AddLine("Drag: reposition",1,1,1); GameTooltip:Show() end end)
        b:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
        b:SetScript("OnDragStart",function() b.dragged=true; b.dragging=true end)
        b:SetScript("OnUpdate",function()
            if b.dragging then
                local x,y=GetCursorPosition(); local scale=Minimap:GetEffectiveScale(); local cx,cy=Minimap:GetCenter()
                self.engine.db.minimap.angle=math.deg(math.atan2(y/scale-cy,x/scale-cx)); self:UpdateMinimap()
            elseif b.mapWidth~=Minimap:GetWidth() or b.mapHeight~=Minimap:GetHeight() or b.mapScale~=Minimap:GetEffectiveScale()/b:GetEffectiveScale() then self:UpdateMinimap() end
        end)
        b:SetScript("OnDragStop",function() b.dragging=false end)
        self:UpdateMinimap()
    end
    local panel=CreateFrame("Frame"); panel.name="Campfire Stories: Forever"
    label(panel,"Campfire Stories: Forever",20,-20,500,35,"GameFontNormalLarge")
    button(panel,"Open settings",20,-70,220,function() self:ShowPage("settings") end)
    button(panel,"Show minimap button",20,-112,220,function() ns.Actions.minimap(false) end)
    label(panel,"Manual storytelling, personal stories and backup controls are available in the Campfire Stories: Forever window.",20,-160,520,60)
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category=Settings.RegisterCanvasLayoutCategory(panel,"Campfire Stories: Forever"); Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then InterfaceOptions_AddCategory(panel) end
end
