local root=...
local function widget(kind)
    local w={kind=kind,shown=true,scripts={},width=140,height=30,text=""}
    local noop=function() end
    function w:SetSize(a,b) self.width=a; self.height=b end
    function w:SetWidth(a) self.width=a end
    function w:SetHeight(a) self.height=a end
    function w:GetWidth() return self.width end
    function w:GetHeight() return self.height end
    function w:GetEffectiveScale() return 1 end
    function w:GetFrameLevel() return 1 end
    function w:GetParent() return UIParent end
    function w:SetScript(name,fn) self.scripts[name]=fn end
    function w:SetShown(value) self.shown=value end
    function w:IsShown() return self.shown end
    function w:Show() self.shown=true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
    function w:Hide() self.shown=false end
    function w:SetText(value) self.text=value or "" end
    function w:GetText() return self.text end
    function w:SetEnabled(value) self.enabled=value end
    function w:IsEnabled() return self.enabled~=false end
    function w:GetFont() return "font",12,"" end
    function w:GetPoint() return "CENTER",UIParent,"CENTER",0,0 end
    function w:GetCenter() return 400,300 end
    function w:GetFrameStrata() return "MEDIUM" end
    function w:CreateFontString() return widget("FontString") end
    function w:CreateTexture() return widget("Texture") end
    function w:HasFocus() return false end
    setmetatable(w,{__index=function() return noop end})
    return w
end
UIParent=widget("UIParent"); Minimap=widget("Minimap"); Minimap.width=180; Minimap.height=180
UISpecialFrames={}; StaticPopupDialogs={}; SlashCmdList={}; DEFAULT_CHAT_FRAME={AddMessage=function() end}
GameTooltip=widget("GameTooltip"); ChatFontNormal={}; time=function() return 1 end; GetCursorPosition=function() return 400,300 end
unpack=table.unpack
CreateFrame=function(kind) return widget(kind) end; StaticPopup_Show=function() end

local NS={}
for _,f in ipairs({"Bootstrap.lua","Data/Questions.lua","Data/Classes.lua","Data/NaxxramasSets.lua","Engine/Profile.lua","Engine/Restrictions.lua","Engine/Scoring.lua","Engine/Explanations.lua","Storage.lua","UI.lua","Minimap.lua"}) do local c=assert(loadfile(root.."/"..f)); c("ChooseAMainForever",NS) end
ChooseAMainForeverDB=nil; NS:LoadDatabase(); NS:CreateUI(); NS.frame:Show(); NS:ShowQuestion(19); NS:SelectAnswer(2); assert(NS.currentQuestion==20,"answering must advance to the next question"); NS:ShowQuestion(24); NS:SelectAnswer(1); assert(NS.activePage=="optional","answering the final question must open preferences")
assert(NS.optionalPanel=="history" and NS.optionalProgress.text:find("25 of 26"),"class experience must be step 25")
assert(NS.nextRestrictionsButton:IsShown() and not NS.recommendButton:IsShown(),"class experience must have its own navigation")
assert(not NS.experienceButtons.DRUID.max:IsEnabled(),"dependent history choices must start disabled")
NS.experienceButtons.DRUID.played.scripts.OnClick(NS.experienceButtons.DRUID.played)
assert(NS.experienceButtons.DRUID.max:IsEnabled(),"played before must enable dependent history choices")
NS.experienceButtons.DRUID.max.scripts.OnClick(NS.experienceButtons.DRUID.max)
NS.experienceButtons.DRUID.played.scripts.OnClick(NS.experienceButtons.DRUID.played)
assert(not NS.db.preferences.experience.DRUID.max and not NS.experienceButtons.DRUID.max:IsEnabled(),"clearing played before must clear and disable dependent history")
NS:ShowOptional("restrictions")
assert(NS.optionalProgress.text:find("26 of 26"),"hard restrictions must be step 26")
assert(NS.backExperienceButton:IsShown() and NS.recommendButton:IsShown(),"hard restrictions must have its own final navigation")
for id=1,24 do NS.db.answers[id]=1 end
local result=NS:Recommend(NS.db.answers,NS.db.preferences); NS:SaveResult(result); NS:ShowResults(result); assert(NS.resultModeButtons.gameplay.selectedVisual and not NS.resultModeButtons.longterm.selectedVisual,"gameplay result must have a clear selected state"); NS:SelectResultMode("longterm"); NS:SelectResultSection("frustrations"); assert(NS.resultModeButtons.longterm.selectedVisual and NS.resultSectionButtons.frustrations.selectedVisual,"selected result tabs must use the selected style"); NS:CreateMinimapButton(); NS:UpdateMinimapPosition(); NS:ShowResetConfirmation()
assert(NS.frame and NS.minimapButton and NS.currentResult and NS.resultBody.text~="" and NS.resultCharacterModelLabel.text:find("armour"))
assert(NS.resultCharacterModel.shown,"recommended class model must be visible")
print("UI SMOKE PASS")
