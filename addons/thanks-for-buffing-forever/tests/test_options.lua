WOW_PROJECT_ID = 42
WOW_PROJECT_MAINLINE = 1

local eventHandler
local optionsPanel
local phraseEditor
local buttons = {}
local openedCategory
local latestTexture

DEFAULT_CHAT_FRAME = { AddMessage = function() end }
SlashCmdList = {}
C_ChatInfo = {}
function UnitFullName() return "Gideon", "ForeverRealm" end
function GetRealmName() return "ForeverRealm" end
function GetCursorPosition() return 125, 795 end

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
function Widget:HookScript(event, callback)
    local previous = self.scripts[event]
    self.scripts[event] = function(...)
        if previous then previous(...) end
        callback(...)
    end
end
function Widget:CreateFontString() return NewWidget("font") end
function Widget:CreateTexture()
    latestTexture = NewWidget("texture")
    return latestTexture
end
function Widget:SetPoint() end
function Widget:ClearAllPoints() end
function Widget:SetSize() end
function Widget:SetAllPoints() end
function Widget:SetAlpha(value) self.alpha = value end
function Widget:SetWidth() end
function Widget:SetHeight(value) self.height = value end
function Widget:SetTextInsets() end
function Widget:SetAutoFocus() end
function Widget:EnableMouse(value) self.mouseEnabled = value end
function Widget:EnableKeyboard(value) self.keyboardEnabled = value end
function Widget:SetFocus() self.focused = true end
function Widget:HasFocus() return self.focused == true end
function Widget:GetEffectiveScale() return 1 end
function Widget:GetLeft() return 100 end
function Widget:GetTop() return 800 end
function Widget:SetFontObject() end
function Widget:SetTextColor(...) self.textColor = { ... } end
function Widget:SetJustifyH() end
function Widget:SetColorTexture() end
function Widget:Show() self.shown = true end
function Widget:Hide() self.shown = false end
function Widget:IsShown() return self.shown == true end
function Widget:SetScrollChild(child) self.scrollChild = child end
function Widget:GetScrollChild() return self.scrollChild end
function Widget:GetVerticalScroll() return 0 end
function Widget:SetCursorPosition(value) self.cursorPosition = value end
function Widget:GetCursorPosition() return self.cursorPosition or 0 end
function Widget:ClearFocus() end
function Widget:SetChecked(value) self.checked = value end
function Widget:GetChecked() return self.checked end
function Widget:GetFont() return "Fonts\\FRIZQT__.TTF", 14 end
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
function Widget:GetStringWidth() return #(self.text or "") * 7 end

local firstFrame = true
function CreateFrame(kind, name, parent, template)
    local widget = NewWidget(firstFrame and "event" or (kind == "Button" and "button" or kind))
    firstFrame = false
    if template == "InputScrollFrameTemplate" then
        widget.EditBox = NewWidget("EditBox")
        widget:SetScrollChild(widget.EditBox)
    end
    if name == "ThanksForTheBuffForeverOptionsPanel" then optionsPanel = widget end
    return widget
end

function InputScrollFrame_OnLoad(frame) frame.inputScrollLoaded = true end

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
local function messages()
    return ThanksForTheBuffForeverDB.characterMessages["Gideon-ForeverRealm"]
end

assert(optionsPanel, "Options > AddOns panel should be registered at addon load")
assert(phraseEditor, "options panel should contain a multiline phrase editor")
assert(phraseEditor.mouseEnabled and phraseEditor.keyboardEnabled, "phrase editor should explicitly accept mouse and keyboard input")
assert(phraseEditor.textColor and phraseEditor.textColor[4] == 1, "phrase editor text and native caret should be fully visible")
phraseEditor:SetText("thanks!\nty!")
phraseEditor.scripts.OnMouseDown(phraseEditor, "LeftButton")
assert(phraseEditor:GetCursorPosition() == 3, "clicking within a line should place the caret at the nearest rendered character")
phraseEditor.focused = true
phraseEditor.scripts.OnEditFocusGained(phraseEditor)
phraseEditor.scripts.OnCursorChanged(phraseEditor, 20, -14, 1, 14)
assert(latestTexture and latestTexture:IsShown(), "phrase editor should draw a visible fallback caret at the cursor position")
phraseEditor.scripts.OnEditFocusLost(phraseEditor)
assert(not latestTexture:IsShown(), "fallback caret should hide when the editor loses focus")
assert(buttons["Save phrases"], "options panel should contain a Save phrases button")
assert(buttons["Restore defaults"], "options panel should contain a Restore defaults button")

optionsPanel.scripts.OnShow()
assert(string.find(phraseEditor:GetText(), "thanks!", 1, true), "opening options should load saved phrases")

phraseEditor:SetText("First custom phrase\nSecond custom phrase\n")
assert(phraseEditor.height == 252, "Forever editor sizing should not require GetStringHeight")
buttons["Save phrases"].scripts.OnClick()
assert(#messages() == 2, "Save phrases should replace this character's saved list")
assert(messages()[1] == "First custom phrase", "saved phrase order should be preserved")

phraseEditor:SetText("Duplicate\nduplicate")
buttons["Save phrases"].scripts.OnClick()
assert(#messages() == 2, "duplicate validation should leave the previous saved list intact")

buttons["Restore defaults"].scripts.OnClick()
assert(#messages() == 15, "Restore defaults should restore all defaults for this character")

SlashCmdList.THANKSFORTHEBUFFFOREVER("options")
assert(openedCategory == 919, "/tftbf options should open the registered settings category")

print("Options phrase editor tests passed")
