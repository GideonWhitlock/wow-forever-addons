local root = (... and ... ~= "") and ... or "."
local NS = {}
local files = {
    "Bootstrap.lua", "Data/Questions.lua", "Data/Classes.lua", "Engine/Profile.lua",
    "Engine/Restrictions.lua", "Engine/Scoring.lua", "Engine/Explanations.lua",
}
for _, relative in ipairs(files) do
    local chunk, errorMessage = loadfile(root .. "/" .. relative)
    assert(chunk, errorMessage)
    chunk("ChooseAMainForever", NS)
end

local passed, failed = 0, 0
local function test(name, callback)
    local ok, message = pcall(callback)
    if ok then passed = passed + 1; print("PASS  " .. name)
    else failed = failed + 1; print("FAIL  " .. name .. "\n      " .. tostring(message)) end
end
local function equal(actual, expected, message)
    assert(actual == expected, (message or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function contains(haystack, needle) assert(type(haystack)=="string" and haystack:find(needle,1,true), "missing text: "..needle) end
local function defaultPreferences() return {faction="either",experience={},allowedRaces={},allowedRacesEnabled=false,unwantedRoles={},unwillingClasses={}} end
local function profile(overrides)
    local answers={}
    for id,value in pairs(overrides or {}) do answers[id]=value end
    return answers
end

test("all 24 questions and choices validate", function()
    equal(#NS.questions,24)
    for id,question in ipairs(NS.questions) do equal(question.id,id); assert(#question.choices>=4,"too few choices for Q"..id); for _,choice in ipairs(question.choices) do assert(choice.text and choice.effect) end end
end)

test("all nine classes and 27 talent paths are assessed", function()
    equal(#NS.classOrder,9); equal(#NS.profiles,27)
    local result=NS:Recommend(profile({[1]=6,[2]=3,[6]=5,[8]=5,[10]=6,[14]=5,[20]=3,[23]=6}),defaultPreferences())
    equal(#result.gameplay.ranked,27); equal(#result.longterm.ranked,27)
end)

test("identical input is deterministic", function()
    local answers=profile({[1]=1,[2]=2,[3]=2,[4]=2,[5]=1,[6]=1,[7]=6,[8]=4,[9]=4,[10]=2,[11]=4,[12]=3,[13]=4,[14]=4,[15]=1,[16]=1,[17]=2,[18]=7,[19]=10,[20]=4,[21]=2,[22]=3,[23]=1,[24]=1})
    local a=NS:Recommend(answers,defaultPreferences()); local b=NS:Recommend(answers,defaultPreferences())
    equal(a.gameplay.winner.profile.id,b.gameplay.winner.profile.id); equal(a.gameplay.winner.score,b.gameplay.winner.score); equal(a.longterm.winner.profile.id,b.longterm.winner.profile.id); equal(a.longterm.winner.score,b.longterm.winner.score)
end)

test("hard stationary-casting exclusion is respected", function()
    local prefs=defaultPreferences(); prefs.rejectStationaryCasting=true
    local result=NS:Recommend(profile({[8]=2,[10]=4,[13]=1,[15]=4,[19]=5,[20]=5}),prefs)
    for _,item in ipairs(result.gameplay.ranked) do assert(item.profile.ratings.stationaryTolerance<4,item.profile.id.." violated stationary exclusion") end
end)

test("class and role exclusions are respected", function()
    local prefs=defaultPreferences(); prefs.unwillingClasses.MAGE=true; prefs.unwantedRoles.healer=true
    local result=NS:Recommend(profile({[6]=3,[7]=3,[8]=2,[19]=5}),prefs)
    for _,item in ipairs(result.longterm.ranked) do assert(item.profile.class~="MAGE"); assert(item.profile.role~="healer") end
end)

test("faction and race restrictions use the verified matrix", function()
    local prefs=defaultPreferences(); prefs.faction="alliance"; prefs.allowedRacesEnabled=true; prefs.allowedRaces.nightelf=true
    local result=NS:Recommend(profile({[2]=1,[4]=6,[20]=5}),prefs)
    for _,item in ipairs(result.gameplay.ranked) do
        assert(#item.eligibleRaces>0)
        for _,race in ipairs(item.eligibleRaces) do equal(race.id,"nightelf") end
        assert(item.profile.class=="DRUID" or item.profile.class=="HUNTER" or item.profile.class=="PRIEST" or item.profile.class=="ROGUE" or item.profile.class=="WARRIOR")
    end
end)

test("impossible restrictions produce an explicit conflict", function()
    local prefs=defaultPreferences(); for _,class in ipairs(NS.classOrder) do prefs.unwillingClasses[class]=true end
    local result=NS:Recommend(profile({[1]=1}),prefs); assert(result.gameplay.conflict); equal(#result.gameplay.ranked,0)
end)

test("missing answers cannot claim high confidence", function()
    local result=NS:Recommend(profile({[1]=1,[6]=1}),defaultPreferences()); equal(result.gameplay.confidence,"Insufficient information")
end)

test("role preference materially changes the field", function()
    local shared={[1]=3,[2]=4,[3]=4,[4]=3,[7]=6,[8]=5,[10]=6,[13]=2,[14]=3,[16]=3,[20]=4,[21]=2,[23]=3}
    local tankAnswers=NS:CopyTable(shared); tankAnswers[6]=2; tankAnswers[7]=2; tankAnswers[12]=1; tankAnswers[18]=4
    local healAnswers=NS:CopyTable(shared); healAnswers[6]=3; healAnswers[7]=3; healAnswers[12]=4; healAnswers[19]=9
    local tank=NS:Recommend(tankAnswers,defaultPreferences()); local heal=NS:Recommend(healAnswers,defaultPreferences())
    assert(tank.gameplay.winner.profile.role=="tank",tank.gameplay.winner.profile.id.." is not a tank")
    assert(heal.gameplay.winner.profile.role=="healer",heal.gameplay.winner.profile.id.." is not a healer")
    assert(tank.gameplay.winner.profile.id~=heal.gameplay.winner.profile.id)
end)

test("explanations name the actual winner and trade-offs", function()
    local answers=profile({[1]=1,[2]=1,[3]=2,[4]=1,[5]=1,[6]=1,[7]=4,[8]=1,[9]=4,[10]=2,[11]=4,[12]=5,[13]=4,[14]=3,[15]=1,[16]=1,[17]=1,[18]=1,[19]=1,[20]=5,[21]=5,[22]=3,[23]=5,[24]=3})
    local result=NS:Recommend(answers,defaultPreferences()); local explanation=result.gameplay.explanation
    contains(explanation.whyClass,result.gameplay.winner.profile.className); contains(explanation.whySpec,result.gameplay.winner.profile.spec); assert(#explanation.frustrations>30); assert(#explanation.alternatives>20)
end)

test("every answer choice runs without error", function()
    for _,question in ipairs(NS.questions) do
        for choice=1,#question.choices do local result=NS:Recommend({[question.id]=choice},defaultPreferences()); assert(result.gameplay.winner) end
    end
end)

test("headline alternatives use different classes", function()
    local result=NS:Recommend(profile({[1]=6,[2]=5,[3]=6,[4]=5,[5]=3,[6]=4,[7]=4,[8]=5,[9]=4,[10]=5,[11]=4,[12]=3,[13]=5,[14]=5,[15]=5,[16]=2,[17]=3,[18]=7,[19]=10,[20]=3,[21]=2,[22]=3,[23]=4,[24]=6}),defaultPreferences())
    local seen={}; for _,item in ipairs(result.gameplay.headline) do assert(not seen[item.profile.class]); seen[item.profile.class]=true end; equal(#result.gameplay.headline,3)
end)

test("structured history influences long-term more than gameplay", function()
    local answers=profile({[1]=6,[2]=3,[4]=2,[5]=1,[6]=5,[8]=5,[10]=5,[13]=5,[14]=5,[20]=5,[23]=1})
    local base=NS:Recommend(answers,defaultPreferences()); local prefs=defaultPreferences(); prefs.experience.WARLOCK={disliked=true}; local changed=NS:Recommend(answers,prefs)
    local function warlockScore(result,mode) for _,item in ipairs(result[mode].ranked) do if item.profile.class=="WARLOCK" then return item.score end end end
    local gameplayDrop=warlockScore(base,"gameplay")-warlockScore(changed,"gameplay"); local longtermDrop=warlockScore(base,"longterm")-warlockScore(changed,"longterm"); assert(longtermDrop>gameplayDrop)
end)

test("seeded broad sampling shows no unexplained universal winner", function()
    local counts, state, samples = {}, 9173, 720
    for _=1,samples do
        local answers={}
        for _,question in ipairs(NS.questions) do
            state=(state*48271)%2147483647
            answers[question.id]=(state%#question.choices)+1
        end
        local winner=NS:Recommend(answers,defaultPreferences()).gameplay.winner.profile.class
        counts[winner]=(counts[winner] or 0)+1
    end
    local represented,maximum=0,0
    for _,class in ipairs(NS.classOrder) do local count=counts[class] or 0; if count>0 then represented=represented+1 end; maximum=math.max(maximum,count); print("SAMPLE "..class.."="..count) end
    assert(represented>=7,"only "..represented.." classes won in broad sampling")
    assert(maximum/samples<0.45,"one class won too large a share of broad sampling")
end)

-- Qualitative calibration case from the product brief. This prints rather than
-- hard-codes a winner; reviewers inspect whether the outcome is defensible.
local calibrationAnswers=profile({[1]=1,[2]=2,[3]=2,[4]=2,[5]=1,[6]=1,[7]=6,[8]=4,[9]=4,[10]=2,[11]=4,[12]=1,[13]=4,[14]=4,[15]=1,[16]=1,[17]=2,[18]=7,[19]=10,[20]=4,[21]=2,[22]=3,[23]=1,[24]=1})
local calibrationPrefs=defaultPreferences(); calibrationPrefs.faction="alliance"; calibrationPrefs.rejectStationaryCasting=true; calibrationPrefs.unwillingClasses.MAGE=true
calibrationPrefs.experience.HUNTER={played=true,retry=true}; calibrationPrefs.experience.WARLOCK={played=true,retry=true}; calibrationPrefs.experience.WARRIOR={played=true,retry=true}; calibrationPrefs.experience.ROGUE={played=true,retry=true}; calibrationPrefs.experience.PALADIN={played=true,retry=true}
local calibration=NS:Recommend(calibrationAnswers,calibrationPrefs)
print("CALIBRATION gameplay="..calibration.gameplay.winner.profile.spec.." "..calibration.gameplay.winner.profile.className.." longterm="..calibration.longterm.winner.profile.spec.." "..calibration.longterm.winner.profile.className)
print(string.format("SUMMARY %d passed, %d failed",passed,failed))
if failed>0 then os.exit(1) end
