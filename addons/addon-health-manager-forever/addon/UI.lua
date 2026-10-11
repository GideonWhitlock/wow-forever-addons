local ADDON_NAME, NS = ...
local L = NS.L

local COLORS = {
    error = { 0.92, 0.28, 0.23 },
    warning = { 0.95, 0.67, 0.18 },
    info = { 0.36, 0.72, 0.46 },
    healthy = { 0.52, 0.70, 0.52 },
    muted = { 0.63, 0.61, 0.55 },
    gold = { 0.85, 0.67, 0.30 },
}

local function setBackdrop(frame, color, border)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(color or { 0.055, 0.065, 0.055, 0.97 }))
    frame:SetBackdropBorderColor(unpack(border or { 0.35, 0.31, 0.18, 1 }))
end

local function createText(parent, template, text, size)
    local font = parent:CreateFontString(nil, "ARTWORK", template or "GameFontNormal")
    font:SetText(text or "")
    if size then
        local path, _, flags = font:GetFont()
        font:SetFont(path, size, flags)
    end
    return font
end

local function createButton(parent, text, width)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 100, 24)
    button:SetText(text)
    return button
end

function NS:CreateUI()
    if self.frame then return end
    local frame = CreateFrame("Frame", "AddonHealthManagerForeverFrame", UIParent, "BackdropTemplate")
    frame:SetSize(760, 540)
    frame:SetPoint("CENTER", UIParent, "CENTER", self.db.window.x or 0, self.db.window.y or 0)
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(f) f:StopMovingOrSizing(); NS:SaveWindowPosition() end)
    frame:SetScript("OnShow", function() NS:RefreshUI() end)
    setBackdrop(frame)
    self.frame = frame

    local top = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    top:SetPoint("TOPLEFT", 1, -1)
    top:SetPoint("TOPRIGHT", -1, -1)
    top:SetHeight(58)
    setBackdrop(top, { 0.075, 0.09, 0.07, 1 }, { 0.44, 0.36, 0.16, 1 })

    local icon = top:CreateTexture(nil, "ARTWORK")
    icon:SetSize(38, 38)
    icon:SetPoint("LEFT", 14, 0)
    icon:SetTexture("Interface\\AddOns\\AddonHealthManagerForever\\Media\\AddonHealthManagerIcon.tga")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local title = createText(top, "GameFontNormalLarge", L.ADDON_TITLE, 18)
    title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 11, -2)
    title:SetTextColor(unpack(COLORS.gold))
    local subtitle = createText(top, "GameFontHighlightSmall", "Evidence-led diagnostics for WoW: Forever", 11)
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetTextColor(unpack(COLORS.muted))

    local close = CreateFrame("Button", nil, top, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetScript("OnClick", function() frame:Hide() end)

    local scan = createButton(top, L.SCAN, 92)
    scan:SetPoint("RIGHT", close, "LEFT", -10, 0)
    scan:SetScript("OnClick", function() NS:Scan() end)

    local tabBar = CreateFrame("Frame", nil, frame)
    tabBar:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 12, -8)
    tabBar:SetPoint("TOPRIGHT", top, "BOTTOMRIGHT", -12, -8)
    tabBar:SetHeight(28)
    self.tabs = {}
    local prior
    for _, definition in ipairs({ { "summary", L.SUMMARY }, { "addons", L.ADDONS }, { "report", L.REPORT } }) do
        local button = createButton(tabBar, definition[2], 112)
        if prior then button:SetPoint("LEFT", prior, "RIGHT", 6, 0) else button:SetPoint("LEFT") end
        button:SetScript("OnClick", function() NS:SelectTab(definition[1]) end)
        self.tabs[definition[1]] = button
        prior = button
    end

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", tabBar, "BOTTOMLEFT", 0, -7)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12)
    self.content = content
    self.pages = {}
    self:CreateSummaryPage(content)
    self:CreateAddonsPage(content)
    self:CreateReportPage(content)
    self:SelectTab("summary")
end

function NS:CreateSummaryPage(parent)
    local page = CreateFrame("Frame", nil, parent)
    page:SetAllPoints()
    self.pages.summary = page

    local headline = createText(page, "GameFontNormalLarge", "", 20)
    headline:SetPoint("TOPLEFT", 8, -10)
    self.summaryHeadline = headline
    local detail = createText(page, "GameFontHighlight", "", 13)
    detail:SetPoint("TOPLEFT", headline, "BOTTOMLEFT", 0, -9)
    detail:SetWidth(700)
    detail:SetJustifyH("LEFT")
    self.summaryDetail = detail

    self.summaryCards = {}
    local cardDefs = {
        { "attention", "Needs attention" },
        { "review", "Review" },
        { "loaded", "Loaded" },
        { "disabled", "Disabled" },
    }
    local prior
    for _, definition in ipairs(cardDefs) do
        local card = CreateFrame("Frame", nil, page, "BackdropTemplate")
        card:SetSize(166, 76)
        if prior then card:SetPoint("LEFT", prior, "RIGHT", 10, 0) else card:SetPoint("TOPLEFT", detail, "BOTTOMLEFT", 0, -22) end
        setBackdrop(card, { 0.085, 0.10, 0.08, 0.95 }, { 0.27, 0.29, 0.22, 1 })
        card.value = createText(card, "GameFontNormalLarge", "0", 24)
        card.value:SetPoint("TOPLEFT", 13, -11)
        card.label = createText(card, "GameFontHighlightSmall", definition[2], 11)
        card.label:SetPoint("BOTTOMLEFT", 13, 11)
        card.label:SetTextColor(unpack(COLORS.muted))
        self.summaryCards[definition[1]] = card
        prior = card
    end

    local heading = createText(page, "GameFontNormal", "What this scan can and cannot tell you", 14)
    heading:SetPoint("TOPLEFT", self.summaryCards.attention, "BOTTOMLEFT", 0, -28)
    heading:SetTextColor(unpack(COLORS.gold))
    local explanation = createText(page, "GameFontHighlight", [[Addon Health reads status, dependencies, interface metadata, Blizzard's profiler, and—when available—the current session's Blizzard error list.

It cannot prove that two add-ons conflict, prove the root cause of an error, see when an add-on was installed before its first scan, or promise that disabling something will repair a problem. Possible overlaps are troubleshooting leads only.]], 12)
    explanation:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -10)
    explanation:SetWidth(700)
    explanation:SetJustifyH("LEFT")
    explanation:SetJustifyV("TOP")
    explanation:SetSpacing(4)

    local open = createButton(page, "Review add-ons", 130)
    open:SetPoint("BOTTOMLEFT", 8, 4)
    open:SetScript("OnClick", function() NS:SelectTab("addons") end)
    local report = createButton(page, L.COPY_REPORT, 130)
    report:SetPoint("LEFT", open, "RIGHT", 8, 0)
    report:SetScript("OnClick", function() NS:SelectTab("report") end)
end

function NS:CreateAddonsPage(parent)
    local page = CreateFrame("Frame", nil, parent)
    page:SetAllPoints()
    self.pages.addons = page

    local list = CreateFrame("Frame", nil, page, "BackdropTemplate")
    list:SetPoint("TOPLEFT")
    list:SetPoint("BOTTOMLEFT")
    list:SetWidth(315)
    setBackdrop(list, { 0.045, 0.052, 0.045, 0.98 }, { 0.22, 0.24, 0.18, 1 })
    list:EnableMouseWheel(true)
    list:SetScript("OnMouseWheel", function(_, delta)
        NS.listOffset = math.max(0, math.min(math.max(0, #NS.rows - #NS.rowButtons), (NS.listOffset or 0) - delta * 3))
        NS:RefreshAddonList()
    end)
    self.listOffset = 0
    self.rowButtons = {}
    for index = 1, 15 do
        local row = CreateFrame("Button", nil, list, "BackdropTemplate")
        row:SetHeight(27)
        row:SetPoint("LEFT", 5, 0)
        row:SetPoint("RIGHT", -5, 0)
        if index == 1 then row:SetPoint("TOP", 0, -5) else row:SetPoint("TOP", self.rowButtons[index - 1], "BOTTOM", 0, -2) end
        setBackdrop(row, { 0.075, 0.082, 0.07, 0.6 }, { 0.12, 0.13, 0.10, 0 })
        row.dot = row:CreateTexture(nil, "ARTWORK")
        row.dot:SetSize(8, 8)
        row.dot:SetPoint("LEFT", 9, 0)
        row.dot:SetTexture("Interface\\Buttons\\WHITE8X8")
        row.nameText = createText(row, "GameFontHighlightSmall", "", 11)
        row.nameText:SetPoint("LEFT", row.dot, "RIGHT", 8, 0)
        row.nameText:SetWidth(205)
        row.nameText:SetJustifyH("LEFT")
        row.statusText = createText(row, "GameFontDisableSmall", "", 10)
        row.statusText:SetPoint("RIGHT", -7, 0)
        row:SetScript("OnClick", function(button) NS:SelectAddon(button.data) end)
        row:SetScript("OnEnter", function(button) button:SetBackdropColor(0.13, 0.15, 0.11, 0.9) end)
        row:SetScript("OnLeave", function(button) button:SetBackdropColor(0.075, 0.082, 0.07, 0.6) end)
        self.rowButtons[index] = row
    end

    local detail = CreateFrame("Frame", nil, page, "BackdropTemplate")
    detail:SetPoint("TOPLEFT", list, "TOPRIGHT", 10, 0)
    detail:SetPoint("BOTTOMRIGHT")
    setBackdrop(detail, { 0.065, 0.074, 0.06, 0.96 }, { 0.25, 0.27, 0.19, 1 })
    self.detailTitle = createText(detail, "GameFontNormalLarge", "Choose an add-on", 18)
    self.detailTitle:SetPoint("TOPLEFT", 16, -15)
    self.detailTitle:SetPoint("RIGHT", -16, 0)
    self.detailTitle:SetJustifyH("LEFT")
    self.detailMeta = createText(detail, "GameFontDisableSmall", "", 10)
    self.detailMeta:SetPoint("TOPLEFT", self.detailTitle, "BOTTOMLEFT", 0, -6)
    self.detailBody = createText(detail, "GameFontHighlight", "", 12)
    self.detailBody:SetPoint("TOPLEFT", self.detailMeta, "BOTTOMLEFT", 0, -16)
    self.detailBody:SetPoint("RIGHT", -16, 0)
    self.detailBody:SetJustifyH("LEFT")
    self.detailBody:SetJustifyV("TOP")
    self.detailBody:SetSpacing(4)
    self.toggleButton = createButton(detail, "Stage change", 155)
    self.toggleButton:SetPoint("BOTTOMLEFT", 16, 15)
    self.toggleButton:SetScript("OnClick", function() NS:StageToggle(NS.selectedRow) end)
    self.undoButton = createButton(detail, L.RESTORE, 170)
    self.undoButton:SetPoint("LEFT", self.toggleButton, "RIGHT", 8, 0)
    self.undoButton:SetScript("OnClick", function() NS:UndoStagedChanges() end)
end

function NS:CreateReportPage(parent)
    local page = CreateFrame("Frame", nil, parent)
    page:SetAllPoints()
    self.pages.report = page
    local help = createText(page, "GameFontHighlightSmall", "Select all (Ctrl+A), then copy (Ctrl+C). The report omits character, realm, account, guild, chat, coordinates, and SavedVariables.", 11)
    help:SetPoint("TOPLEFT", 4, -2)
    help:SetPoint("RIGHT", -4, 0)
    help:SetJustifyH("LEFT")

    local scroll = CreateFrame("ScrollFrame", nil, page, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", help, "BOTTOMLEFT", 0, -10)
    scroll:SetPoint("BOTTOMRIGHT", -26, 38)
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(680)
    edit:SetTextInsets(8, 8, 8, 8)
    edit:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
    edit:SetScript("OnTextChanged", function() scroll:UpdateScrollChildRect() end)
    scroll:SetScrollChild(edit)
    self.reportEdit = edit
    local selectAll = createButton(page, "Select all", 110)
    selectAll:SetPoint("BOTTOMLEFT", 4, 4)
    selectAll:SetScript("OnClick", function() edit:SetFocus(); edit:HighlightText() end)
end

function NS:SelectTab(name)
    self.activeTab = name
    for key, page in pairs(self.pages) do page:SetShown(key == name) end
    for key, button in pairs(self.tabs) do button:SetEnabled(key ~= name) end
    if name == "report" and self.reportEdit then
        self.reportEdit:SetText(self:BuildReport())
        self.reportEdit:SetCursorPosition(0)
        self.reportEdit:ClearFocus()
    elseif name == "addons" then
        self:RefreshAddonList()
        if not self.selectedRow and self.rows[1] then self:SelectAddon(self.rows[1]) end
    end
end

function NS:RefreshUI()
    if not self.frame then return end
    local counts = self:GetCounts()
    local headline, detail, color
    if counts.error > 0 then
        headline, detail, color = "Some add-ons need attention", string.format("%d high-confidence issue(s) found. Start with the red entries.", counts.error), COLORS.error
    elseif counts.warning > 0 then
        headline, detail, color = "A few things are worth reviewing", string.format("%d warning(s) found, but no definite broken dependency or load failure.", counts.warning), COLORS.warning
    else
        headline, detail, color = "No definite problems found", L.NO_FINDINGS, COLORS.healthy
    end
    local visibility = self.errorEvidence and self.errorEvidence.visibility or "unavailable"
    if visibility == "available" then
        detail = detail .. string.format(" Error visibility: available (%d error, %d warning occurrence(s)).", self.errorEvidence.errors or 0, self.errorEvidence.warnings or 0)
    elseif visibility == "partial" then
        detail = detail .. " Error visibility: limited to warnings observed after Addon Health Manager loaded."
    else
        detail = detail .. " Error visibility: unavailable; this is not a clean error scan."
    end
    if self.globalFindings and self.globalFindings[1] then detail = detail .. " " .. self.globalFindings[1].text end
    self.summaryHeadline:SetText(headline)
    self.summaryHeadline:SetTextColor(unpack(color))
    self.summaryDetail:SetText(detail)
    self.summaryCards.attention.value:SetText(counts.error)
    self.summaryCards.review.value:SetText(counts.warning)
    self.summaryCards.loaded.value:SetText(counts.loaded)
    self.summaryCards.disabled.value:SetText(counts.disabled)
    self.summaryCards.attention.value:SetTextColor(unpack(COLORS.error))
    self.summaryCards.review.value:SetTextColor(unpack(COLORS.warning))
    self.summaryCards.loaded.value:SetTextColor(unpack(COLORS.healthy))
    self.summaryCards.disabled.value:SetTextColor(unpack(COLORS.muted))
    self:RefreshAddonList()
    if self.activeTab == "report" and self.reportEdit then self.reportEdit:SetText(self:BuildReport()) end
end

function NS:RefreshAddonList()
    if not self.rowButtons then return end
    local offset = self.listOffset or 0
    for index, button in ipairs(self.rowButtons) do
        local row = self.rows[offset + index]
        button.data = row
        button:SetShown(row ~= nil)
        if row then
            button.nameText:SetText(row.title)
            local color = COLORS[row.severity]
            button.dot:SetVertexColor(unpack(color))
            button.statusText:SetText(row.loaded and "Loaded" or (row.enabled and "Enabled" or "Disabled"))
        end
    end
end

function NS:SelectAddon(row)
    if not row then return end
    self.selectedRow = row
    self.detailTitle:SetText(row.title)
    self.detailTitle:SetTextColor(unpack(COLORS[row.severity]))
    local moduleText = row.partOf ~= "" and ("  •  module of " .. row.partOf) or ""
    self.detailMeta:SetText(string.format("%s  •  version %s  •  interface %s%s", row.name, row.version, row.interfaceVersion, moduleText))
    local lines = {
        string.format("Status: %s • %s • %s", row.enabled and "enabled" or "disabled", row.loaded and "loaded" or "not loaded", row.loadable and "loadable" or "not loadable"),
        "",
    }
    if #row.findings == 0 then
        lines[#lines + 1] = "No definite problem found in the status WoW exposes."
    else
        for _, finding in ipairs(row.findings) do lines[#lines + 1] = "• " .. finding.text end
    end
    if row.loaded and row.recentMs then
        lines[#lines + 1] = ""
        lines[#lines + 1] = string.format("Blizzard profiler: recent %.3f ms • session %.3f ms • peak %.3f ms", row.recentMs or 0, row.sessionMs or 0, row.peakMs or 0)
        if row.recentRank then lines[#lines + 1] = string.format("Relative snapshot rank: #%d by recent execution time. This is not a root-cause diagnosis.", row.recentRank) end
        lines[#lines + 1] = string.format("Memory snapshot: %.1f KB. Memory alone does not measure frame-rate impact.", row.memoryKB or 0)
    end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "Guidance: change one add-on at a time, reload, and repeat the same action that caused the problem. A successful retest is stronger evidence than a name or category match."
    self.detailBody:SetText(table.concat(lines, "\n"))
    self.toggleButton:SetEnabled(row.name ~= ADDON_NAME)
    self.toggleButton:SetText(row.enabled and "Disable after reload" or "Enable after reload")
end
