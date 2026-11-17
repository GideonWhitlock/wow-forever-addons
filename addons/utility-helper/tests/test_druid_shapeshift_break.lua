local U = {}
assert(loadfile("addons/utility-helper/addon/Core.lua"))("UtilityHelper", U)

UnitExists = function() return true end
UnitIsDeadOrGhost = function() return false end
UnitOnTaxi = function() return false end
IsMounted = function() return false end

local controlled = true
U.HasAura = function() return controlled end
GetNumShapeshiftForms = function() return 2 end
local activeSpellID = 768
GetShapeshiftFormInfo = function(index)
    if index == 1 then return nil, activeSpellID == 768, true, 768 end
    return nil, activeSpellID == 5487, true, 5487
end

local cat = {rule = "shapeshiftbreak", id = 768, formSpellIDs = {768}, breakAuras = {118, 339}}
local bear = {rule = "shapeshiftbreak", id = 5487, formSpellIDs = {5487, 9634}, breakAuras = {118, 339}}

local catState = U.Condition(cat, "player")
local bearState = U.Condition(bear, "player")
assert(catState == false, "the currently active form should not be suggested")
assert(bearState == true, "a different learned form should be suggested while controlled")

activeSpellID = 5487
assert(U.Condition(cat, "player") == true, "Cat Form should be suggested from Bear Form")
assert(U.Condition(bear, "player") == false, "Bear Form should not suggest itself")

controlled = false
assert(U.Condition(cat, "player") == false, "forms should stay hidden without a recognised control effect")

print("Utility Helper Druid shapeshift-break tests passed")
