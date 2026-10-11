local root=(... and ...~="") and ... or "."
local files={"Bootstrap.lua","Data/Questions.lua","Data/Classes.lua","Data/NaxxramasSets.lua","Engine/Profile.lua","Engine/Restrictions.lua","Engine/Scoring.lua","Engine/Explanations.lua","Storage.lua","UI.lua","Minimap.lua","Main.lua","Tests/run.lua","Tests/ui_smoke.lua"}
for _,relative in ipairs(files) do local chunk,message=loadfile(root.."/"..relative); assert(chunk,relative..": "..tostring(message)); print("SYNTAX "..relative) end
print("SYNTAX SUMMARY "..#files.." files passed")
