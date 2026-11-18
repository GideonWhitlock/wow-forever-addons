local U = {}
assert(loadfile("addons/utility-helper/addon/Core.lua"))("UtilityHelper", U)

UnitExists = function() return true end
UnitIsDeadOrGhost = function() return false end
UnitOnTaxi = function() return false end
IsMounted = function() return false end

local controlType = "ROOT"
C_LossOfControl = {
    GetNumEvents = function() return controlType and 1 or 0 end,
    GetEventInfo = function()
        return {locType = controlType, spellID = 999999}
    end,
}
GetNumShapeshiftForms = function() return 2 end
local activeSpellID = 768
GetShapeshiftFormInfo = function(index)
    if index == 1 then return nil, activeSpellID == 768, true, 768 end
    return nil, activeSpellID == 5487, true, 5487
end

local cat = {rule = "shapeshiftbreak", id = 768, formSpellIDs = {768}}
local bear = {rule = "shapeshiftbreak", id = 5487, formSpellIDs = {5487, 9634}}

local catState = U.Condition(cat, "player")
local bearState = U.Condition(bear, "player")
assert(catState == false, "the currently active form should not be suggested")
assert(bearState == true, "a different learned form should be suggested while controlled")

activeSpellID = 5487
assert(U.Condition(cat, "player") == true, "Cat Form should be suggested from Bear Form")
assert(U.Condition(bear, "player") == false, "Bear Form should not suggest itself")

controlType = "POLYMORPH"
assert(U.Condition(cat, "player") == true, "Polymorph should be detected by its effect category")

controlType = "SNARE"
assert(U.Condition(cat, "player") == true, "movement slows removable by shifting should be detected")

controlType = "STUN"
assert(U.Condition(cat, "player") == false, "a stun should not be described as breakable by shifting")

controlType = nil
assert(U.Condition(cat, "player") == false, "forms should stay hidden without a recognised control effect")

print("Utility Helper Druid shapeshift-break tests passed")
