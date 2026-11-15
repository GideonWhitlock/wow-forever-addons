WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local eventHandler
local optionsPanel
local phraseEditor
local buttons = {}
local openedCategory

DEFAULT_CHAT_FRAME = { AddMessage = function() end }
SlashCmdList = {}
C_ChatInfo = {}

local Widget = {}
Widget.__index = Widget

local function NewWidget(kind)
    local widget = setmetatable({ kind = kind, scripts = {}, text = "", checked = true }, Widget)
    widget.Text = setmetatable({ scripts = {}, text = "" }, Widget)
    return widget
end

function Widget:RegisterEvent() end
function Widget:RegisterUnitEvent() end
function Widget:SetScript(event, callback)
    self.scripts[event] = callback
    if self.kind == "event" and event == "OnEvent" then
        eventHandler = callback
    end
end
function Widget:CreateFontString() return NewWidget("font") end
function Widget:CreateTexture() return NewWidget("texture") end
function Widget:SetPoint() end
function Widget:SetSize() end
function Widget:SetWidth() end
function Widget:SetHeight() end
function Widget:SetTextInsets() end
function Widget:SetAutoFocus() end
function Widget:SetFontObject() end
function Widget:SetJustifyH() end
function Widget:SetColorTexture() end
function Widget:SetScrollChild(child) self.scrollChild = child end
function Widget:SetCursorPosition() end
function Widget:ClearFocus() end
function Widget:SetTextColor() end
function Widget:SetChecked(value) self.checked = value end
function Widget:GetChecked() return self.checked end
function Widget:GetStringHeight() return 20 end
function Widget:SetMultiLine(value)
    self.multiLine = value
    if value then phraseEditor = self end
end
function Widget:SetText(value)
    self.text = value
    if self.kind == "button" then buttons[value] = self end
    if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self) end
end
function Widget:GetText() return self.text end

local firstFrame = true
function CreateFrame(kind, name)
    local widget = NewWidget(firstFrame and "event" or (kind == "Button" and "button" or kind))
    firstFrame = false
    if name == "ThanksForTheBuffForeverOptionsPanel" then optionsPanel = widget end
    return widget
end

Settings = {
    RegisterCanvasLayoutCategory = function(panel, name)
        assert(panel == optionsPanel and name == "Thanks for Buffing: Forever", "settings category should use the addon panel and name")
        return { GetID = function() return 919 end }
    end,
    RegisterAddOnCategory = function() end,
    OpenToCategory = function(categoryID) openedCategory = categoryID end,
}

function GetBuildInfo() return "1.60.1", "build", "date", 16001 end
function wipe(tableValue)
    for key in pairs(tableValue) do tableValue[key] = nil end
end

local chunk = assert(loadfile("work/ThanksForTheBuffForever/ThanksForTheBuffForever.lua"))
chunk("ThanksForTheBuffForever")
eventHandler(nil, "ADDON_LOADED", "ThanksForTheBuffForever")

assert(optionsPanel, "Options > AddOns panel should be registered at addon load")
assert(phraseEditor, "options panel should contain a multiline phrase editor")
assert(buttons["Save phrases"], "options panel should contain a Save phrases button")
assert(buttons["Restore defaults"], "options panel should contain a Restore defaults button")

optionsPanel.scripts.OnShow()
assert(string.find(phraseEditor:GetText(), "thanks!", 1, true), "opening options should load saved phrases")

phraseEditor:SetText("First custom phrase\nSecond custom phrase\n")
buttons["Save phrases"].scripts.OnClick()
assert(#ThanksForTheBuffForeverDB.messages == 2, "Save phrases should replace the saved list")
assert(ThanksForTheBuffForeverDB.messages[1] == "First custom phrase", "saved phrase order should be preserved")

phraseEditor:SetText("Duplicate\nduplicate")
buttons["Save phrases"].scripts.OnClick()
assert(#ThanksForTheBuffForeverDB.messages == 2, "duplicate validation should leave the previous saved list intact")

buttons["Restore defaults"].scripts.OnClick()
assert(#ThanksForTheBuffForeverDB.messages == 15, "Restore defaults should restore all default phrases")

SlashCmdList.THANKSFORTHEBUFFFOREVER("options")
assert(openedCategory == 919, "/tftbf options should open the registered settings category")

print("Options phrase editor tests passed")
