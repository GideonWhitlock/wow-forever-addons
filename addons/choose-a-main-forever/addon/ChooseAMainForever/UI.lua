local _, NS = ...

local COLORS = {
    parchment={0.12,0.095,0.055,0.98}, panel={0.075,0.065,0.045,0.98}, border={0.50,0.36,0.14,1},
    gold={0.92,0.72,0.31}, cream={0.93,0.86,0.67}, muted={0.66,0.61,0.49}, selected={0.22,0.18,0.08,1}, teal={0.25,0.68,0.63}, red={0.84,0.30,0.25},
}

local function backdrop(frame, fill, border)
    frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1})
    frame:SetBackdropColor(unpack(fill or COLORS.panel)); frame:SetBackdropBorderColor(unpack(border or COLORS.border))
end
local function text(parent, template, value, size)
    local label=parent:CreateFontString(nil,"ARTWORK",template or "GameFontHighlight")
    label:SetText(value or "")
    if size then local path,_,flags=label:GetFont(); label:SetFont(path,size,flags) end
    return label
end
local function button(parent, value, width, height)
    local control=CreateFrame("Button",nil,parent,"UIPanelButtonTemplate"); control:SetSize(width or 110,height or 24); control:SetText(value or ""); return control
end
local function stateButton(parent, value, width, height)
    local control=CreateFrame("Button",nil,parent,"BackdropTemplate"); control:SetSize(width or 110,height or 24)
    control.label=text(control,"GameFontNormal",value or "",11); control.label:SetPoint("CENTER",0,0)
    return control
end
local function setStateButton(control, selected)
    control.selectedVisual=not not selected
    if selected then
        backdrop(control,{0.07,0.30,0.12,.98},{.88,.66,.20,1}); control.label:SetTextColor(.98,.78,.24)
    else
        backdrop(control,{0.42,0.035,0.025,.98},{.56,.38,.10,1}); control.label:SetTextColor(1,.86,.15)
    end
end
local function checkButton(parent, value, width)
    local control=CreateFrame("Button",nil,parent,"BackdropTemplate"); control:SetSize(width or 120,24); backdrop(control,{0.09,0.075,0.045,.95},{.30,.23,.10,1})
    control.mark=text(control,"GameFontNormal","",13); control.mark:SetPoint("LEFT",8,0); control.label=text(control,"GameFontHighlightSmall",value,11); control.label:SetPoint("LEFT",control.mark,"RIGHT",7,0)
    return control
end
local function setCheck(control, checked)
    control.checked=not not checked; control.mark:SetText(checked and "|cff55d6c7x|r" or " "); control:SetBackdropColor(unpack(checked and COLORS.selected or {0.09,0.075,0.045,.95}))
end

function NS:CreateUI()
    if self.frame then return end
    local frame=CreateFrame("Frame","ChooseAMainForeverFrame",UIParent,"BackdropTemplate")
    frame:SetSize(820,620); frame:SetPoint("CENTER",UIParent,"CENTER",self.db.window.x,self.db.window.y); frame:SetScale(self.db.window.scale)
    frame:SetFrameStrata("DIALOG"); frame:SetClampedToScreen(true); frame:SetMovable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart",frame.StartMoving); frame:SetScript("OnDragStop",function(f) f:StopMovingOrSizing(); local _,_,_,x,y=f:GetPoint(); NS.db.window.x=x or 0; NS.db.window.y=y or 0 end)
    backdrop(frame,COLORS.parchment,COLORS.border); frame:Hide(); self.frame=frame
    if UISpecialFrames then UISpecialFrames[#UISpecialFrames+1]="ChooseAMainForeverFrame" end

    local header=CreateFrame("Frame",nil,frame,"BackdropTemplate"); header:SetPoint("TOPLEFT",1,-1); header:SetPoint("TOPRIGHT",-1,-1); header:SetHeight(68); backdrop(header,{0.085,0.07,0.04,1},COLORS.border)
    local icon=header:CreateTexture(nil,"ARTWORK"); icon:SetSize(48,48); icon:SetPoint("LEFT",12,0); icon:SetTexture("Interface\\AddOns\\ChooseAMainForever\\Media\\ChooseAMainForeverIcon.tga"); icon:SetTexCoord(.04,.96,.04,.96)
    local title=text(header,"GameFontNormalLarge",self.title,20); title:SetPoint("TOPLEFT",icon,"TOPRIGHT",12,-4); title:SetTextColor(unpack(COLORS.gold))
    local subtitle=text(header,"GameFontHighlightSmall","A private, explainable class consultation for WoW: Forever",11); subtitle:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,-5); subtitle:SetTextColor(unpack(COLORS.muted))
    local close=CreateFrame("Button",nil,header,"UIPanelCloseButton"); close:SetPoint("TOPRIGHT",-5,-5); close:SetScript("OnClick",function() frame:Hide() end)
    local plus=button(header,"+",28,22); plus:SetPoint("RIGHT",close,"LEFT",-5,0); plus:SetScript("OnClick",function() NS:SetScale(NS.db.window.scale+.05) end)
    local minus=button(header,"-",28,22); minus:SetPoint("RIGHT",plus,"LEFT",-3,0); minus:SetScript("OnClick",function() NS:SetScale(NS.db.window.scale-.05) end)

    local content=CreateFrame("Frame",nil,frame); content:SetPoint("TOPLEFT",12,-80); content:SetPoint("BOTTOMRIGHT",-12,12); self.content=content; self.pages={}
    self:CreateWelcomePage(content); self:CreateQuestionPage(content); self:CreateOptionalPage(content); self:CreateResultsPage(content)
    self:ShowWelcome()
end

function NS:SetScale(scale)
    scale=self:Clamp(scale,.75,1.35); self.db.window.scale=scale; self.frame:SetScale(scale)
    self:FitResultCharacterModel()
end
function NS:ShowPage(name)
    for key,page in pairs(self.pages) do page:SetShown(key==name) end
    self.activePage=name
end
function NS:Toggle() if self.frame:IsShown() then self.frame:Hide() else self.frame:Show(); if self.db.assessment.complete and self.db.lastResult then self:ShowResults(self.db.lastResult) else self:ShowWelcome() end end end

function NS:CreateWelcomePage(parent)
    local page=CreateFrame("Frame",nil,parent); page:SetAllPoints(); self.pages.welcome=page
    local heading=text(page,"GameFontNormalLarge","Find the character you will still love a year from now",24); heading:SetPoint("TOP",0,-30); heading:SetTextColor(unpack(COLORS.gold))
    local body=text(page,"GameFontHighlight",[[Twenty-four questions compare how you actually play with every Forever class and talent path. The result separates moment-to-moment gameplay fit from long-term attachment, shows credible alternatives, and names the trade-offs.

This is a deterministic decision aid—not a tier list and not a scientific prediction. Everything runs locally. No answers, notes or character details leave your computer.]],14)
    body:SetPoint("TOP",heading,"BOTTOM",0,-25); body:SetWidth(660); body:SetJustifyH("LEFT"); body:SetSpacing(6); body:SetTextColor(unpack(COLORS.cream))
    local status=text(page,"GameFontHighlightSmall","",11); status:SetPoint("TOP",body,"BOTTOM",0,-24); status:SetWidth(620); status:SetTextColor(unpack(COLORS.muted)); self.welcomeStatus=status
    local start=button(page,"Begin the assessment",190,32); start:SetPoint("BOTTOM",0,66); start:SetScript("OnClick",function() NS:ShowQuestion(NS.db.assessment.currentQuestion or 1) end)
    local previous=button(page,"View previous result",170,28); previous:SetPoint("TOP",start,"BOTTOM",0,-10); previous:SetScript("OnClick",function() if NS.db.lastResult then NS:ShowResults(NS.db.lastResult) end end); self.previousResultButton=previous
end
function NS:ShowWelcome()
    self:ShowPage("welcome"); local count=0; for _ in pairs(self.db.answers) do count=count+1 end
    self.welcomeStatus:SetText(count>0 and (count.." of 24 answers are saved. You can continue or revise them.") or "Your answers are saved as you go.")
    self.previousResultButton:SetEnabled(self.db.lastResult~=nil)
end

function NS:CreateQuestionPage(parent)
    local page=CreateFrame("Frame",nil,parent); page:SetAllPoints(); self.pages.question=page
    local progress=text(page,"GameFontHighlightSmall","",11); progress:SetPoint("TOPLEFT",12,-3); progress:SetTextColor(unpack(COLORS.teal)); self.questionProgress=progress
    local heading=text(page,"GameFontNormalLarge","",19); heading:SetPoint("TOPLEFT",12,-28); heading:SetWidth(760); heading:SetJustifyH("LEFT"); heading:SetTextColor(unpack(COLORS.gold)); self.questionHeading=heading
    self.answerButtons={}
    for index=1,10 do
        local choice=CreateFrame("Button",nil,page,"BackdropTemplate"); choice:SetHeight(34); choice:SetPoint("LEFT",16,0); choice:SetPoint("RIGHT",-16,0)
        if index==1 then choice:SetPoint("TOP",heading,"BOTTOM",0,-20) else choice:SetPoint("TOP",self.answerButtons[index-1],"BOTTOM",0,-5) end
        backdrop(choice,{.08,.068,.045,.92},{.28,.21,.10,1}); choice.number=text(choice,"GameFontNormal",tostring(index),12); choice.number:SetPoint("LEFT",11,0); choice.number:SetTextColor(unpack(COLORS.gold)); choice.label=text(choice,"GameFontHighlightSmall","",12); choice.label:SetPoint("LEFT",choice.number,"RIGHT",12,0); choice.label:SetPoint("RIGHT",-10,0); choice.label:SetJustifyH("LEFT")
        choice:SetScript("OnClick",function(btn) NS:SelectAnswer(btn.choiceIndex) end); choice:SetScript("OnEnter",function(btn) if not btn.selected then btn:SetBackdropColor(.15,.12,.06,1) end end); choice:SetScript("OnLeave",function(btn) if not btn.selected then btn:SetBackdropColor(.08,.068,.045,.92) end end); self.answerButtons[index]=choice
    end
    local previous=button(page,"Previous",105,28); previous:SetPoint("BOTTOMLEFT",12,3); previous:SetScript("OnClick",function() NS:ShowQuestion(NS.currentQuestion-1) end); self.previousQuestion=previous
    local review=button(page,"Welcome",100,28); review:SetPoint("LEFT",previous,"RIGHT",8,0); review:SetScript("OnClick",function() NS:ShowWelcome() end)
    local next=button(page,"Next",105,28); next:SetPoint("BOTTOMRIGHT",-12,3); next:SetScript("OnClick",function() if NS.currentQuestion<#NS.questions then NS:ShowQuestion(NS.currentQuestion+1) else NS:ShowOptional("history") end end); self.nextQuestion=next
end
function NS:ShowQuestion(index)
    index=self:Clamp(index,1,#self.questions); self.currentQuestion=index; self.db.assessment.currentQuestion=index; self:ShowPage("question")
    local question=self.questions[index]; self.questionProgress:SetText(string.format("%s  •  Question %d of %d",question.section:gsub("^%l",string.upper),index,#self.questions)); self.questionHeading:SetText(question.text)
    local selected=self.db.answers[question.id]
    for buttonIndex,control in ipairs(self.answerButtons) do
        local choice=question.choices[buttonIndex]; control:SetShown(choice~=nil); control.choiceIndex=buttonIndex; control.selected=selected==buttonIndex
        if choice then control.label:SetText(choice.text); control:SetBackdropColor(unpack(control.selected and COLORS.selected or {.08,.068,.045,.92})); control:SetBackdropBorderColor(unpack(control.selected and COLORS.gold or {.28,.21,.10,1})) end
    end
    self.previousQuestion:SetEnabled(index>1); self.nextQuestion:SetText(index==#self.questions and "Preferences" or "Next")
end
function NS:SelectAnswer(choiceIndex)
    self.db.answers[self.currentQuestion]=choiceIndex
    if self.currentQuestion < #self.questions then self:ShowQuestion(self.currentQuestion+1) else self:ShowOptional("history") end
end

function NS:CreateOptionalPage(parent)
    local page=CreateFrame("Frame",nil,parent); page:SetAllPoints(); self.pages.optional=page
    local progress=text(page,"GameFontHighlightSmall","",11); progress:SetPoint("TOPLEFT",12,-3); progress:SetTextColor(unpack(COLORS.teal)); self.optionalProgress=progress
    local heading=text(page,"GameFontNormalLarge","Optional personalisation",20); heading:SetPoint("TOPLEFT",progress,"BOTTOMLEFT",0,-7); heading:SetTextColor(unpack(COLORS.gold))
    local note=text(page,"GameFontHighlightSmall","Missing, neutral and explicitly excluded are kept distinct. Free-text notes are stored for you but are never scored.",11); note:SetPoint("TOPLEFT",heading,"BOTTOMLEFT",0,-5); note:SetTextColor(unpack(COLORS.muted))
    self.optionalPanels={}

    local history=CreateFrame("Frame",nil,page); history:SetPoint("TOPLEFT",note,"BOTTOMLEFT",0,-18); history:SetPoint("BOTTOMRIGHT",-4,46); self.optionalPanels.history=history
    local historyHeading=text(history,"GameFontNormal","Class experience",14); historyHeading:SetPoint("TOPLEFT",12,0); historyHeading:SetTextColor(unpack(COLORS.gold))
    local columns={"Played before","Max level","Enjoyed","Disliked","Would play again"}; local keys={"played","max","enjoyed","disliked","retry"}
    for index,label in ipairs(columns) do local h=text(history,"GameFontNormalSmall",label,10); h:SetPoint("TOPLEFT",220+(index-1)*104,-1); h:SetWidth(94); h:SetJustifyH("CENTER"); h:SetTextColor(unpack(COLORS.gold)) end
    self.experienceButtons={}
    for row,class in ipairs(self.classOrder) do
        local y=-34-(row-1)*39; local name=text(history,"GameFontHighlight",self.classNames[class],12); name:SetPoint("TOPLEFT",12,y-6); name:SetWidth(180); name:SetJustifyH("LEFT"); self.experienceButtons[class]={}
        for column,key in ipairs(keys) do
            local control=checkButton(history,"",88); control:SetPoint("TOPLEFT",223+(column-1)*104,y); control.key=key; control.class=class; control:SetScript("OnClick",function(btn)
                NS.db.preferences.experience[btn.class]=NS.db.preferences.experience[btn.class] or {}; local record=NS.db.preferences.experience[btn.class]
                if btn.key=="played" then
                    record.played=not record.played
                    if not record.played then record.max=nil; record.enjoyed=nil; record.disliked=nil; record.retry=nil end
                elseif record.played then
                    record[btn.key]=not record[btn.key]
                    if btn.key=="enjoyed" and record[btn.key] then record.disliked=false end
                    if btn.key=="disliked" and record[btn.key] then record.enjoyed=false end
                end
                NS:RefreshOptional()
            end); self.experienceButtons[class][key]=control
        end
    end

    local restrictions=CreateFrame("Frame",nil,page); restrictions:SetPoint("TOPLEFT",note,"BOTTOMLEFT",0,-18); restrictions:SetPoint("BOTTOMRIGHT",-4,46); self.optionalPanels.restrictions=restrictions
    local restrictionsHeading=text(restrictions,"GameFontNormal","Hard restrictions",14); restrictionsHeading:SetPoint("TOPLEFT",10,0); restrictionsHeading:SetTextColor(unpack(COLORS.gold))
    self.factionButton=button(restrictions,"",200,26); self.factionButton:SetPoint("TOPLEFT",10,-28); self.factionButton:SetScript("OnClick",function() local order={either="alliance",alliance="horde",horde="either"}; NS.db.preferences.faction=order[NS.db.preferences.faction] or "either"; NS:RefreshOptional() end)
    self.sexButton=button(restrictions,"",180,26); self.sexButton:SetPoint("LEFT",self.factionButton,"RIGHT",8,0); self.sexButton:SetScript("OnClick",function() local order={either="male",male="female",female="either"}; NS.db.preferences.sex=order[NS.db.preferences.sex] or "either"; NS:RefreshOptional() end)
    self.stationaryButton=checkButton(restrictions,"Reject stationary casting",210); self.stationaryButton:SetPoint("LEFT",self.sexButton,"RIGHT",8,0); self.stationaryButton:SetScript("OnClick",function() NS.db.preferences.rejectStationaryCasting=not NS.db.preferences.rejectStationaryCasting; NS:RefreshOptional() end)
    self.raceEnable=checkButton(restrictions,"Limit to selected races",200); self.raceEnable:SetPoint("TOPLEFT",10,-68); self.raceEnable:SetScript("OnClick",function() NS.db.preferences.allowedRacesEnabled=not NS.db.preferences.allowedRacesEnabled; NS:RefreshOptional() end)
    self.raceButtons={}
    for index,race in ipairs(self.races) do
        local control=checkButton(restrictions,race.name,180); local column=(index-1)%4; local row=math.floor((index-1)/4); control:SetPoint("TOPLEFT",10+column*188,-101-row*31); control.raceID=race.id; control:SetScript("OnClick",function(btn) local selected=NS.db.preferences.allowedRaces; selected[btn.raceID]=not selected[btn.raceID]; NS:RefreshOptional() end); self.raceButtons[race.id]=control
    end
    local roleLabel=text(restrictions,"GameFontNormal","Unwanted primary roles",12); roleLabel:SetPoint("TOPLEFT",10,-188); roleLabel:SetTextColor(unpack(COLORS.gold)); self.roleButtons={}
    for index,role in ipairs({"damage","tank","healer"}) do local c=checkButton(restrictions,role:gsub("^%l",string.upper),130); c:SetPoint("TOPLEFT",10+(index-1)*140,-211); c.role=role; c:SetScript("OnClick",function(btn) local t=NS.db.preferences.unwantedRoles; t[btn.role]=not t[btn.role]; NS:RefreshOptional() end); self.roleButtons[role]=c end
    local classLabel=text(restrictions,"GameFontNormal","Classes you are unwilling to play",12); classLabel:SetPoint("TOPLEFT",10,-249); classLabel:SetTextColor(unpack(COLORS.gold)); self.unwillingButtons={}
    for index,class in ipairs(self.classOrder) do local c=checkButton(restrictions,self.classNames[class],150); local col=(index-1)%4; local row=math.floor((index-1)/4); c:SetPoint("TOPLEFT",10+col*160,-273-row*27); c.class=class; c:SetScript("OnClick",function(btn) local t=NS.db.preferences.unwillingClasses; t[btn.class]=not t[btn.class]; NS:RefreshOptional() end); self.unwillingButtons[class]=c end
    local notes=CreateFrame("EditBox",nil,restrictions,"InputBoxTemplate"); notes:SetHeight(28); notes:SetPoint("BOTTOMLEFT",10,10); notes:SetPoint("BOTTOMRIGHT",-12,10); notes:SetAutoFocus(false); notes:SetMaxLetters(500); notes:SetScript("OnEscapePressed",function(box) box:ClearFocus() end); notes:SetScript("OnTextChanged",function(box,user) if user then NS.db.preferences.notes=box:GetText() end end); self.notesEdit=notes
    local notesLabel=text(restrictions,"GameFontNormal","Personal notes (not interpreted)",12); notesLabel:SetPoint("BOTTOMLEFT",notes,"TOPLEFT",0,7); notesLabel:SetTextColor(unpack(COLORS.gold))
    local backQuestions=button(page,"Back to question 24",150,28); backQuestions:SetPoint("BOTTOMLEFT",12,3); backQuestions:SetScript("OnClick",function() NS:ShowQuestion(#NS.questions) end); self.backQuestionsButton=backQuestions
    local nextRestrictions=button(page,"Next: hard restrictions",175,28); nextRestrictions:SetPoint("BOTTOMRIGHT",-12,3); nextRestrictions:SetScript("OnClick",function() NS:ShowOptional("restrictions") end); self.nextRestrictionsButton=nextRestrictions
    local backExperience=button(page,"Back: class experience",175,28); backExperience:SetPoint("BOTTOMLEFT",12,3); backExperience:SetScript("OnClick",function() NS:ShowOptional("history") end); self.backExperienceButton=backExperience
    local recommend=button(page,"Show my recommendations",200,30); recommend:SetPoint("BOTTOMRIGHT",-12,3); recommend:SetScript("OnClick",function() local result=NS:Recommend(NS.db.answers,NS.db.preferences); NS:SaveResult(result); NS:ShowResults(result) end); self.recommendButton=recommend
end
function NS:ShowOptional(panel) self:ShowPage("optional"); self.optionalPanel=panel or "history"; self:RefreshOptional() end
function NS:RefreshOptional()
    for key,panel in pairs(self.optionalPanels) do panel:SetShown(key==self.optionalPanel) end
    local onHistory=self.optionalPanel=="history"
    self.optionalProgress:SetText(onHistory and "Personalisation  •  Step 25 of 26" or "Personalisation  •  Step 26 of 26")
    self.backQuestionsButton:SetShown(onHistory); self.nextRestrictionsButton:SetShown(onHistory)
    self.backExperienceButton:SetShown(not onHistory); self.recommendButton:SetShown(not onHistory)
    for class,buttons in pairs(self.experienceButtons) do
        local record=self.db.preferences.experience[class] or {}
        for key,control in pairs(buttons) do
            setCheck(control,record[key])
            control:SetEnabled(key=="played" or record.played==true)
            if control.label then control.label:SetAlpha((key=="played" or record.played==true) and 1 or .35) end
            if control.mark then control.mark:SetAlpha((key=="played" or record.played==true) and 1 or .35) end
        end
    end
    local faction=self.db.preferences.faction or "either"; self.factionButton:SetText("Faction: "..(faction=="either" and "Either" or faction:gsub("^%l",string.upper)))
    local sex=self.db.preferences.sex or "either"; self.sexButton:SetText("Sex: "..sex:gsub("^%l",string.upper)); setCheck(self.stationaryButton,self.db.preferences.rejectStationaryCasting); setCheck(self.raceEnable,self.db.preferences.allowedRacesEnabled)
    for id,control in pairs(self.raceButtons) do setCheck(control,self.db.preferences.allowedRaces[id]); control:SetEnabled(self.db.preferences.allowedRacesEnabled) end
    for role,control in pairs(self.roleButtons) do setCheck(control,self.db.preferences.unwantedRoles[role]) end
    for class,control in pairs(self.unwillingButtons) do setCheck(control,self.db.preferences.unwillingClasses[class]) end
    if not self.notesEdit:HasFocus() then self.notesEdit:SetText(self.db.preferences.notes or "") end
end

function NS:CreateResultsPage(parent)
    local page=CreateFrame("Frame",nil,parent); page:SetAllPoints(); self.pages.results=page
    local archetype=text(page,"GameFontNormalLarge","",20); archetype:SetPoint("TOPLEFT",12,-3); archetype:SetTextColor(unpack(COLORS.gold)); self.resultArchetype=archetype
    local model=text(page,"GameFontHighlightSmall","",10); model:SetPoint("TOPRIGHT",-12,-8); model:SetTextColor(unpack(COLORS.muted)); self.resultModel=model
    local gameplay=stateButton(page,"Best Gameplay Match",175,27); gameplay:SetPoint("TOPLEFT",12,-40); gameplay:SetScript("OnClick",function() NS:SelectResultMode("gameplay") end)
    local longterm=stateButton(page,"Best Long-Term Main",175,27); longterm:SetPoint("LEFT",gameplay,"RIGHT",8,0); longterm:SetScript("OnClick",function() NS:SelectResultMode("longterm") end); self.resultModeButtons={gameplay=gameplay,longterm=longterm}
    local winner=text(page,"GameFontNormalLarge","",22); winner:SetPoint("TOPLEFT",12,-82); winner:SetWidth(510); winner:SetJustifyH("LEFT"); winner:SetTextColor(unpack(COLORS.teal)); self.resultWinner=winner
    local confidence=text(page,"GameFontHighlight","",12); confidence:SetPoint("TOPRIGHT",-12,-88); confidence:SetWidth(220); confidence:SetJustifyH("RIGHT"); self.resultConfidence=confidence
    local ranking=text(page,"GameFontHighlightSmall","",11); ranking:SetPoint("TOPLEFT",12,-122); ranking:SetWidth(760); ranking:SetJustifyH("LEFT"); ranking:SetTextColor(unpack(COLORS.cream)); self.resultRanking=ranking
    local sectionNames={{"whyClass","Why this class"},{"whySpec","Why this path"},{"frustrations","Frustrations"},{"alternatives","Alternatives"},{"gameplayVsAttachment","Two views"},{"mayChange","What may change"}}; self.resultSectionButtons={}; local prior
    for _,definition in ipairs(sectionNames) do local c=stateButton(page,definition[2],118,25); if prior then c:SetPoint("LEFT",prior,"RIGHT",6,0) else c:SetPoint("TOPLEFT",12,-162) end; c.section=definition[1]; c:SetScript("OnClick",function(btn) NS:SelectResultSection(btn.section) end); self.resultSectionButtons[definition[1]]=c; prior=c end
    local bodyFrame=CreateFrame("Frame",nil,page,"BackdropTemplate"); bodyFrame:SetPoint("TOPLEFT",12,-198); bodyFrame:SetPoint("BOTTOMRIGHT",-232,50); backdrop(bodyFrame,{.065,.055,.038,.96},{.28,.21,.10,1})
    local body=text(bodyFrame,"GameFontHighlight","",13); body:SetPoint("TOPLEFT",15,-15); body:SetPoint("RIGHT",-15,0); body:SetJustifyH("LEFT"); body:SetJustifyV("TOP"); body:SetSpacing(6); body:SetTextColor(unpack(COLORS.cream)); self.resultBody=body
    local modelFrame=CreateFrame("Frame",nil,page,"BackdropTemplate"); modelFrame:SetPoint("TOPRIGHT",-12,-198); modelFrame:SetPoint("BOTTOMLEFT",bodyFrame,"BOTTOMRIGHT",8,0); backdrop(modelFrame,{.035,.03,.02,.98},{.50,.36,.14,1})
    modelFrame:SetScript("OnSizeChanged",function() NS:FitResultCharacterModel() end)
    local model=CreateFrame("DressUpModel",nil,modelFrame); model:SetPoint("TOPLEFT",4,-4); model:SetPoint("BOTTOMRIGHT",-4,28); model:SetKeepModelOnHide(true); model:SetPortraitZoom(0); model:SetRotation(.15,false); self.resultCharacterModel=model
    local modelLabel=text(modelFrame,"GameFontHighlightSmall","",10); modelLabel:SetPoint("BOTTOM",0,9); modelLabel:SetWidth(200); modelLabel:SetJustifyH("CENTER"); modelLabel:SetTextColor(unpack(COLORS.gold)); self.resultCharacterModelLabel=modelLabel
    local retake=button(page,"Review answers",125,28); retake:SetPoint("BOTTOMLEFT",12,3); retake:SetScript("OnClick",function() NS:ShowQuestion(1) end)
    local prefs=button(page,"Preferences",110,28); prefs:SetPoint("LEFT",retake,"RIGHT",7,0); prefs:SetScript("OnClick",function() NS:ShowOptional("history") end)
    local reset=button(page,"Reset",90,28); reset:SetPoint("BOTTOMRIGHT",-12,3); reset:SetScript("OnClick",function() NS:ShowResetConfirmation() end)
end
function NS:FitResultCharacterModel()
    local model=self.resultCharacterModel
    if not model or not model:IsShown() then return end
    if model.RefreshCamera then pcall(model.RefreshCamera,model) end
    if model.SetPortraitZoom then pcall(model.SetPortraitZoom,model,0) end
    if model.SetCamDistanceScale then pcall(model.SetCamDistanceScale,model,1.22) end
end
function NS:ShowResults(result)
    self.currentResult=result; self:ShowPage("results")
    if result.gameplay.conflict then self.resultArchetype:SetText("Restrictions conflict"); self.resultWinner:SetText("No eligible class remains"); self.resultConfidence:SetText(""); self.resultRanking:SetText("Revise faction, race, class, role or stationary-casting exclusions."); self.resultBody:SetText("Hard restrictions are never silently overridden. Open Preferences and relax at least one exclusion, then calculate again."); return end
    self.resultArchetype:SetText(result.archetype or self:BuildArchetype(result.player)); self.resultModel:SetText("Scoring "..self.scoringVersion.."  •  Profiles "..self.profileVersion); self:SelectResultMode("gameplay")
end
function NS:SelectResultMode(mode)
    self.resultMode=mode; for key,c in pairs(self.resultModeButtons) do setStateButton(c,key==mode) end
    local data=self.currentResult[mode]; local winner=data.winner.profile; self.resultWinner:SetText(winner.spec.." "..winner.className); self.resultConfidence:SetText(data.confidence.."  •  "..string.format("%.1f",data.winner.score).." model score"); self:UpdateResultCharacterModel(winner.class)
    local ranks={}; for index,item in ipairs(data.headline or {}) do ranks[#ranks+1]=index..". "..item.profile.spec.." "..item.profile.className.." ("..string.format("%.1f",item.score)..")" end; self.resultRanking:SetText(table.concat(ranks,"     "))
    self:SelectResultSection("whyClass")
end
function NS:UpdateResultCharacterModel(class)
    local model=self.resultCharacterModel; if not model then return end
    local set=self.naxxramasSets and self.naxxramasSets[class]
    model:Undress()
    local ok=pcall(model.SetUnit,model,"player",false)
    if ok then model:Undress() end
    if model.SetSheathed then pcall(model.SetSheathed,model,true,true) end
    local dressed=0
    if type(set)=="table" then
        for _,itemID in ipairs(set) do if pcall(model.TryOn,model,"item:"..itemID) then dressed=dressed+1 end end
    end
    local setName=self.naxxramasSetNames and self.naxxramasSetNames[class] or "Naxxramas"
    self.resultCharacterModelLabel:SetText((self.classNames[class] or class).." • "..setName.." armour")
    model:SetShown(ok and dressed>0)
    self:FitResultCharacterModel()
end
function NS:SelectResultSection(section)
    self.resultSection=section; for key,c in pairs(self.resultSectionButtons) do setStateButton(c,key==section) end
    local explanation=self.currentResult[self.resultMode].explanation; local value=explanation and explanation[section] or "No explanation is available for this saved scoring version. Retake the assessment to refresh it."
    if section=="whyClass" and explanation and explanation.notableSameClass then value=value.."\n\n"..explanation.notableSameClass end
    self.resultBody:SetText(value or "No additional note.")
end

function NS:ShowResetConfirmation()
    StaticPopupDialogs.CHOOSE_A_MAIN_FOREVER_RESET={text="Reset all Choose a Main: Forever answers, preferences, notes and results? Window and minimap positions will be kept.",button1="Reset",button2="Cancel",OnAccept=function() NS:ResetAssessment(); NS:ShowWelcome(); NS:Print("Assessment reset.") end,timeout=0,whileDead=true,hideOnEscape=true,preferredIndex=3}
    StaticPopup_Show("CHOOSE_A_MAIN_FOREVER_RESET")
end
