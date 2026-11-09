local _, Q = ...

local function createCheckbox(parent, label, x, y)
    local box = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    box:SetPoint("TOPLEFT", x, y)
    box:SetSize(26, 26)
    local text = box:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", box, "RIGHT", 4, 0)
    text:SetText(label)
    return box
end

function Q.UpdateOptions()
    local panel = Q.optionsPanel
    if not panel or not Q.db then return end
    panel.template:SetText(Q.db.template)
    panel.minimap:SetChecked(not Q.db.minimap.hidden)
    panel.preview:SetText("Preview: " .. Q.BuildMessage())
end

function Q.CreateOptions()
    if Q.optionsPanel then return end
    local panel = CreateFrame("Frame", "LFGMessengerForeverOptions", UIParent, "BackdropTemplate")
    Q.optionsPanel = panel
    panel:SetSize(440, 285)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
    panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 28,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -22)
    title:SetText(Q.TITLE)
    local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() panel:Hide() end)
    local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 28, -62)
    label:SetText("Whisper template")
    local edit = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    panel.template = edit
    edit:SetSize(375, 28)
    edit:SetPoint("TOPLEFT", 30, -84)
    edit:SetAutoFocus(false)
    edit:SetMaxLetters(120)
    edit:SetScript("OnEnterPressed", function(self)
        Q.db.template = self:GetText()
        self:ClearFocus()
        Q.UpdateOptions()
        Q.UpdateLFGButton()
    end)
    edit:SetScript("OnEscapePressed", function(self) self:SetText(Q.db.template); self:ClearFocus() end)
    edit:SetScript("OnTextChanged", function(self, userInput)
        if userInput and panel.preview then panel.preview:SetText("Preview: " .. Q.BuildMessage(self:GetText())) end
    end)
    local help = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    help:SetPoint("TOPLEFT", 30, -118)
    help:SetWidth(375)
    help:SetJustifyH("LEFT")
    help:SetText("Available: {class}, {role}, {name}, {level}. Press Enter to save.")
    local preview = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    panel.preview = preview
    preview:SetPoint("TOPLEFT", 30, -151)
    preview:SetWidth(375)
    preview:SetJustifyH("LEFT")
    local minimap = createCheckbox(panel, "Show the minimap button", 26, -181)
    panel.minimap = minimap
    minimap:SetScript("OnClick", function(self)
        Q.db.minimap.hidden = not self:GetChecked()
        Q.UpdateMinimap()
    end)
    local reset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    reset:SetSize(130, 24)
    reset:SetPoint("BOTTOMLEFT", 28, 24)
    reset:SetText("Restore defaults")
    reset:SetScript("OnClick", Q.ResetSettings)
    local test = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    test:SetSize(130, 24)
    test:SetPoint("BOTTOMRIGHT", -28, 24)
    test:SetText("Print preview")
    test:SetScript("OnClick", function() Q.Print("Preview: " .. Q.BuildMessage(panel.template:GetText())) end)
    panel:Hide()
    if UISpecialFrames then UISpecialFrames[#UISpecialFrames + 1] = "LFGMessengerForeverOptions" end
end

function Q.ToggleOptions()
    Q.CreateOptions()
    Q.UpdateOptions()
    Q.optionsPanel:SetShown(not Q.optionsPanel:IsShown())
end
