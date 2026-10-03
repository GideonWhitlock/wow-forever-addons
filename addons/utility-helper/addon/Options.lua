local _, U = ...
local function text(parent, label, x, y, template)
    local f = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    f:SetPoint("TOPLEFT", x, y); f:SetText(label); f:SetJustifyH("LEFT")
    return f
end
local function button(parent, label, x, y, width, fn)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetPoint("TOPLEFT", x, y); b:SetSize(width, 23); b:SetText(label)
    b:SetScript("OnClick", function() if not InCombatLockdown() then fn(b) end end)
    return b
end
local function edit(parent, x, y, width, hint)
    local b = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    b:SetPoint("TOPLEFT", x, y); b:SetSize(width, 24); b:SetAutoFocus(false)
    b:SetMaxLetters(60); b:SetScript("OnEscapePressed", b.ClearFocus)
    text(parent, hint, x, y + 15)
    return b
end
function U.RefreshOptions()
    local p = U.options
    if not p then return end
    p.refreshing = true
    for key, c in pairs(p.checks) do c:SetChecked(U.db[key]) end
    for key, slider in pairs(p.sliders) do
        local value = math.floor(U.db[key] * slider.scale + 0.5)
        local automatic = key == "columns" and U.db.compact
        if automatic then value = U.LayoutColumns() end
        slider:SetValue(value); slider.caption:SetText((automatic and "Grid columns (automatic)" or slider.label) .. ": " .. value)
        slider:EnableMouse(not automatic); slider:SetAlpha(automatic and 0.5 or 1)
    end
    p.layout:SetText(U.db.compact and "Layout: Compact grid" or "Layout: Free layout")
    p.arrangeHint:SetText(U.db.compact and "Arrange: drag any icon or the handle to move the grid; wheel changes size."
        or "Arrange: drag the bar or each icon; wheel changes size. Casting is disabled.")
    local available = U.availableEntries or {}
    p.page = math.max(1, math.min(p.page or 1, math.max(1, math.ceil(#available / 7))))
    p.pageText:SetText("Page " .. p.page .. " / " .. math.max(1, math.ceil(#available / 7)))
    for i, row in ipairs(p.rows) do
        local e = available[(p.page - 1) * 7 + i]
        row.entry = e
        row:SetShown(e ~= nil)
        if e then
            row.enabled:SetChecked(not U.db.hidden[e.key])
            row.icon:SetTexture(e.icon or 134400)
            row.label:SetText(e.label)
            local reminder = e.bandage and U.Low("player", false, U.db.health) == nil
            row.rule:SetText(reminder and "Low health outside combat  |  Reminder; use your action bar"
                or (U.ruleLabels[e.rule] .. "  |  " .. e.target))
            row.bind:SetText(reminder and "Use action bar" or (U.db.bindings[e.key] or "Bind key"))
            row.bind:SetEnabled(not reminder)
        end
    end
    p.refreshing = false
end
function U.CaptureBinding(e)
    local p = U.options
    if e.bandage and U.Low("player", false, U.db.health) == nil then
        p.message:SetText("Bandage is a low-health reminder on this client. Use a keybind on your normal action bar.")
        return
    end
    p.capture, p.pendingKey = e, nil
    p.message:SetText("Press a key for " .. e.label .. ". Escape cancels; Delete clears.")
    p:EnableKeyboard(true); p:SetPropagateKeyboardInput(false)
end
function U.StopCapture()
    local p = U.options
    if not p then return end
    p.capture = nil; p:EnableKeyboard(false); p:SetPropagateKeyboardInput(true)
end

local function pickerSpell(button)
    local api = _G.ClassicUIForeverAPI
    local id = api and api.SpellOnButton and U.Public(api.SpellOnButton, button)
    if type(id) == "number" then return id end
    local ok, direct = pcall(function() return button.spellID or button.spellId end)
    if ok and type(direct) == "number" and not U.Secret(direct) then return direct end
    local okSlot, slot, bank = pcall(function()
        local value = button.slot or button.spellBookItemSlot
        local name = button.GetName and button:GetName()
        if not value and type(name) == "string" and name:find("SpellButton", 1, true) then value = button:GetID() end
        return value, button.bank or 0
    end)
    if okSlot and type(slot) == "number" and C_SpellBook then
        local info = U.Public(C_SpellBook.GetSpellBookItemInfo, slot, bank)
        if type(info) == "table" and not U.Secret(info.spellID) then return info.spellID end
    end
end

function U.StopSpellPicker(message)
    local p = U.options
    if not p then return end
    p.pickingSpell, p.hoverSpellID = nil, nil
    if p.findSpell then p.findSpell:SetText("Find Spell ID") end
    for _, overlay in pairs(U.pickerOverlays or {}) do overlay:Hide() end
    if message then p.message:SetText(message) end
end

function U.SelectPickedSpell(id)
    local p = U.options
    if not p or not p.pickingSpell or type(id) ~= "number" or U.Secret(id) then return false end
    U.BuildSpellIndex()
    local learned = U.ResolveSpell(id, false)
    if not learned then
        p.message:SetText("That icon is not a learned player spell. Choose another spell.")
        return false
    end
    p.customID:SetText(tostring(learned.id))
    U.StopSpellPicker("Selected " .. learned.name .. " (spell ID " .. learned.id .. "). Choose its rule and recipient, then Add utility.")
    if p:IsShown() then p:Show() end
    return true
end

local function pickerOverlay(button, id)
    U.pickerOverlays = U.pickerOverlays or {}
    local overlay = U.pickerOverlays[button]
    if not overlay then
        overlay = CreateFrame("Button", nil, UIParent)
        overlay:SetFrameStrata("TOOLTIP"); overlay:EnableMouse(true)
        overlay:SetScript("OnEnter", function(self)
            local spellID = self.spellID
            if not spellID then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetSpellByID(spellID); GameTooltip:Show()
            local p = U.options
            if p and p.pickingSpell then
                p.hoverSpellID = spellID
                p.findSpell:SetText("Select " .. (U.SpellName(spellID) or "spell"))
            end
        end)
        overlay:SetScript("OnLeave", function() GameTooltip:Hide() end)
        overlay:SetScript("OnClick", function(self) U.SelectPickedSpell(self.spellID) end)
        U.pickerOverlays[button] = overlay
    end
    overlay.spellID = id
    overlay:ClearAllPoints(); overlay:SetAllPoints(button); overlay:Show()
end

local function scanPickerFrame(frame, seen, depth)
    if not frame or seen[frame] or depth > 7 then return end
    seen[frame] = true
    local id = pickerSpell(frame)
    if id and U.ResolveSpell(id, false) then pickerOverlay(frame, id) end
    local ok, children = pcall(function() return {frame:GetChildren()} end)
    if ok then for _, child in ipairs(children) do scanPickerFrame(child, seen, depth + 1) end end
end

function U.UpdateSpellPicker()
    local p = U.options
    if not p or not p.pickingSpell or InCombatLockdown() then return end
    for _, overlay in pairs(U.pickerOverlays or {}) do overlay:Hide() end
    local seen = {}
    scanPickerFrame(_G.ForeverClassicUISpellBook, seen, 0)
    scanPickerFrame(_G.PlayerSpellsFrame, seen, 0)
    scanPickerFrame(_G.SpellBookFrame, seen, 0)
    for i = 1, 24 do
        local button = _G["ForeverClassicUISpellButton" .. i] or _G["SpellButton" .. i]
        if button then
            local id = pickerSpell(button)
            if id and U.ResolveSpell(id, false) then pickerOverlay(button, id) end
        end
    end
end

function U.StartSpellPicker()
    local p = U.options
    if not p or InCombatLockdown() then return end
    if p.pickingSpell then
        if p.hoverSpellID then U.SelectPickedSpell(p.hoverSpellID)
        else U.StopSpellPicker("Spell finder cancelled.") end
        return
    end
    U.BuildSpellIndex()
    p.pickingSpell = true
    p.findSpell:SetText("Cancel finder")
    p.message:SetText("Open the spellbook, hover a learned spell and click it. Click this button again to use the last hovered spell.")
    local api = _G.ClassicUIForeverAPI
    if api and api.Open then U.Call(api.Open, "spellBook")
    elseif _G.ToggleSpellBook then U.Call(ToggleSpellBook, "spell")
    elseif _G.TogglePlayerSpellsFrame then U.Call(TogglePlayerSpellsFrame, 1) end
    U.UpdateSpellPicker()
end

function U.ToggleOptions()
    if InCombatLockdown() then U.Print("Open settings after combat."); return end
    if not U.options then U.BuildOptions() end
    U.options:SetShown(not U.options:IsShown()); U.RefreshOptions()
end
function U.BuildOptions()
    local p = CreateFrame("Frame", "UtilityHelperOptions", UIParent, "BackdropTemplate")
    U.options = p; p.rows, p.sliders, p.checks = {}, {}, {}
    if not U.pickerTooltipHook and GameTooltip and GameTooltip.HookScript then
        local ok = pcall(GameTooltip.HookScript, GameTooltip, "OnTooltipSetSpell", function(tip)
            if not U.options or not U.options.pickingSpell or not tip.GetSpell then return end
            local _, id = tip:GetSpell()
            if type(id) == "number" and not U.Secret(id) and U.ResolveSpell(id, false) then
                U.options.hoverSpellID = id
                U.options.findSpell:SetText("Select " .. (U.SpellName(id) or "spell"))
            end
        end)
        U.pickerTooltipHook = ok
    end
    p:SetSize(720, 724); p:SetPoint("CENTER"); p:SetFrameStrata("DIALOG")
    p:SetClampedToScreen(true); p:EnableMouse(true); p:SetMovable(true); p:RegisterForDrag("LeftButton")
    p:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14})
    p:SetBackdropColor(0.035, 0.047, 0.067, 0.98); p:SetBackdropBorderColor(0.75, 0.57, 0.23)
    p:SetScript("OnDragStart", p.StartMoving); p:SetScript("OnDragStop", p.StopMovingOrSizing)
    local close = CreateFrame("Button", nil, p, "UIPanelCloseButton"); close:SetPoint("TOPRIGHT", -3, -3)
    text(p, U.TITLE, 22, -20, "GameFontNormalLarge")
    text(p, "Useful actions together. Your choice, your keybinds.", 23, -44)
    button(p, "Arrange buttons", 23, -68, 145, function() U.SetEditing(not U.editing) end)
    button(p, "Reset positions", 179, -68, 130, function() U.db.positions = {}; U.db.x, U.db.y = 0, -130; U.ApplyLayout() end)
    button(p, "Restore all abilities", 320, -68, 150, function() U.db.hidden = {}; U.Rebuild() end)
    p.arrangeHint = text(p, "", 23, -98)
    local function slider(key, label, x, y, lo, hi, scale)
        local s = CreateFrame("Slider", nil, p, "BackdropTemplate")
        s.scale = scale or 1
        s:SetPoint("TOPLEFT", x, y); s:SetSize(205, 14); s:SetOrientation("HORIZONTAL")
        s:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); s:SetBackdropColor(0.15, 0.19, 0.25)
        local thumb = s:CreateTexture(nil, "ARTWORK"); thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal"); thumb:SetSize(24, 24)
        s:SetThumbTexture(thumb); s:SetMinMaxValues(lo, hi); s:SetValueStep(1); s:SetObeyStepOnDrag(true)
        s.caption = text(p, label, x, y + 19); s.label = label
        s:SetScript("OnValueChanged", function(_, value)
            if p.refreshing or InCombatLockdown() or (key == "columns" and U.db.compact) then return end
            value = math.max(lo, math.min(hi, math.floor(value + 0.5)))
            U.db[key] = value / s.scale; s.caption:SetText(label .. ": " .. value)
            U.curves = {}; U.ApplyLayout(); U.Refresh()
        end)
        p.sliders[key] = s
    end
    slider("size", "Button size", 25, -143, 28, 100)
    slider("columns", "Buttons per row", 257, -143, 1, 16)
    slider("health", "Health alert %", 489, -143, 5, 95)
    slider("mana", "Mana alert %", 25, -190, 5, 95)
    slider("pethealth", "Pet health alert %", 257, -190, 5, 95)
    slider("idle", "Inactive visibility %", 489, -190, 0, 100, 100)
    p.layout = button(p, "", 25, -216, 205, function()
        U.db.compact = not U.db.compact; U.ApplyLayout(); U.RefreshOptions()
    end)
    text(p, "Each ability keeps its own clickable position during combat.", 257, -222)
    local function check(key, label, x, y, rebuild)
        local c = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
        c:SetPoint("TOPLEFT", x, y); c:SetSize(24, 24); c.Text:SetText(label)
        c:SetScript("OnClick", function()
            if InCombatLockdown() then return end
            U.db[key] = c:GetChecked() and true or false
            if rebuild then U.Rebuild() else U.Refresh() end
        end)
        p.checks[key] = c
    end
    check("flash", "Animated proc border", 486, -68)
    check("party", "Extra party dispel buttons", 20, -250, true)
    check("incidental", "Utility with incidental damage", 254, -250, true)
    check("showManual", "Show manual utilities", 486, -250, true)
    text(p, "ABILITIES & KEYBINDS", 24, -289, "GameFontNormal")
    p.pageText = text(p, "", 480, -292)
    button(p, "<", 611, -285, 32, function() p.page = (p.page or 1) - 1; U.RefreshOptions() end)
    button(p, ">", 652, -285, 32, function() p.page = (p.page or 1) + 1; U.RefreshOptions() end)
    for i = 1, 7 do
        local row = CreateFrame("Frame", nil, p)
        row:SetSize(670, 35); row:SetPoint("TOPLEFT", 22, -315 - (i - 1) * 36)
        row.enabled = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        row.enabled:SetPoint("LEFT"); row.enabled:SetSize(24, 24)
        row.enabled:SetScript("OnClick", function()
            if InCombatLockdown() or not row.entry then return end
            U.db.hidden[row.entry.key] = not row.enabled:GetChecked(); U.Rebuild()
        end)
        row.icon = row:CreateTexture(nil, "ARTWORK"); row.icon:SetSize(27, 27); row.icon:SetPoint("LEFT", 29, 0)
        row.label = text(row, "", 65, -1); row.label:SetWidth(340)
        row.rule = text(row, "", 65, -17); row.rule:SetTextColor(0.55, 0.68, 0.78)
        row.bind = button(row, "", 464, -4, 130, function() U.CaptureBinding(row.entry) end)
        button(row, "Clear", 604, -4, 60, function() U.SetBinding(row.entry.key, nil); U.RefreshOptions() end)
        p.rows[i] = row
    end
    p.message = text(p, "Select an ability's Bind key button, then press your preferred key.", 25, -578)
    p.message:SetWidth(548); p.message:SetHeight(33)
    p.replace = button(p, "Replace", 608, -575, 77, function()
        if p.pendingKey and p.pendingEntry then
            local _, message = U.SetBinding(p.pendingEntry.key, p.pendingKey, true)
            p.message:SetText(message); p.pendingKey = nil; U.RefreshOptions()
        end
    end)
    p:SetScript("OnKeyDown", function(_, key)
        if not p.capture or InCombatLockdown() then U.StopCapture(); return end
        if key == "ESCAPE" then p.message:SetText("Binding cancelled."); U.StopCapture(); return end
        if key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" then return end
        local e = p.capture
        if key == "DELETE" then U.SetBinding(e.key, nil); p.message:SetText("Binding cleared.")
        else
            key = (IsControlKeyDown() and "CTRL-" or "") .. (IsAltKeyDown() and "ALT-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "") .. key
            local ok, message = U.SetBinding(e.key, key)
            p.message:SetText(message)
            if not ok then p.pendingKey, p.pendingEntry = key, e end
        end
        U.StopCapture(); U.RefreshOptions()
    end)
    p:SetScript("OnHide", function()
        U.StopCapture()
        U.StopSpellPicker()
        if U.editing and not InCombatLockdown() then U.SetEditing(false) end
    end)
    p.customID = edit(p, 165, -635, 92, "Extra spell ID")
    local rules = {"manual", "health", "mana", "manahealth", "pethealth", "interrupt", "dispel", "purge", "control", "buff"}
    local targets = {"player", "friendly", "target", "pet", "party1", "party2", "party3", "party4", "focus"}
    p.customRule, p.customTarget = 1, 1
    p.findSpell = button(p, "Find Spell ID", 25, -635, 125, function() U.StartSpellPicker() end)
    button(p, "Rule: Manual utility", 274, -635, 190, function(b)
        p.customRule = p.customRule % #rules + 1; b:SetText("Rule: " .. U.ruleLabels[rules[p.customRule]])
    end)
    button(p, "Recipient: player", 479, -635, 125, function(b)
        p.customTarget = p.customTarget % #targets + 1; b:SetText("Recipient: " .. targets[p.customTarget])
    end)
    button(p, "Add", 614, -635, 70, function()
        local id = tonumber(p.customID:GetText())
        local ok, message = U.AddCustom(id, rules[p.customRule], targets[p.customTarget])
        p.message:SetText(message)
        if ok then p.customID:SetText(""); p.customID:ClearFocus(); U.Rebuild() end
    end)
    local note = text(p, "Find Spell ID lets you click a learned spell in the spellbook. Low mana + safe health uses the mana and health sliders.\nIn combat, 0% fades inactive icons but keeps fixed click areas. Arrange cannot cast.", 24, -675)
    note:SetWidth(668); note:SetTextColor(0.62, 0.7, 0.8)
    tinsert(UISpecialFrames, "UtilityHelperOptions")
    p:Hide()
end

function U.UpdateMinimap()
    if not U.minimap or not Minimap or InCombatLockdown() then return end
    local b = U.minimap
    local angle = math.rad(U.db.minimapAngle)
    local scale = Minimap:GetEffectiveScale() / b:GetEffectiveScale()
    b:ClearAllPoints()
    b:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * (Minimap:GetWidth() * scale / 2 + 6),
        math.sin(angle) * (Minimap:GetHeight() * scale / 2 + 6))
end
function U.StopMinimapDrag()
    if not U.minimap then return end
    U.minimap:SetScript("OnUpdate", nil)
    U.minimap.ignoreClickUntil = GetTime() + 0.2
end
function U.BuildMinimap()
    if U.minimap or not Minimap or InCombatLockdown() then return end
    local b = CreateFrame("Button", "UtilityHelperMinimap", Minimap:GetParent() or UIParent)
    U.minimap = b -- Publish before any native setup that might deliver an event.
    b:SetSize(32, 32); b:SetFrameStrata("MEDIUM"); b:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp"); b:RegisterForDrag("LeftButton")
    local icon = b:CreateTexture(nil, "ARTWORK"); icon:SetSize(20, 20); icon:SetPoint("TOPLEFT", 7, -5); icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    local edge = b:CreateTexture(nil, "OVERLAY"); edge:SetSize(54, 54); edge:SetPoint("TOPLEFT"); edge:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    b:SetScript("OnClick", function(_, which)
        if GetTime() < (b.ignoreClickUntil or 0) then return end
        if which == "RightButton" then U.SetEditing(not U.editing) else U.ToggleOptions() end
    end)
    b:SetScript("OnDragStart", function()
        if InCombatLockdown() then return end
        GameTooltip:Hide()
        b:SetScript("OnUpdate", function()
            if InCombatLockdown() then U.StopMinimapDrag(); return end
            local x, y = GetCursorPosition()
            local cx, cy = Minimap:GetCenter()
            if not cx or not cy then return end
            local scale = Minimap:GetEffectiveScale()
            U.db.minimapAngle = math.deg(math.atan2(y / scale - cy, x / scale - cx)) % 360
            U.UpdateMinimap()
        end)
    end)
    b:SetScript("OnDragStop", U.StopMinimapDrag)
    b:SetScript("OnHide", U.StopMinimapDrag)
    b:SetScript("OnEnter", function()
        GameTooltip:SetOwner(b, "ANCHOR_LEFT"); GameTooltip:SetText(U.TITLE)
        GameTooltip:AddLine("Left-click: settings\nRight-click: arrange buttons\nDrag: move around the minimap", 1, 1, 1); GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    U.UpdateMinimap()
end
function U.AddCustom(id, rule, target, dispels)
    if InCombatLockdown() then return false, "Add utilities after combat." end
    if type(id) ~= "number" or id < 1 or id % 1 ~= 0 or not U.ruleLabels[rule] then return false, "Enter a valid learned spell ID and rule." end
    local targets = {player = true, friendly = true, target = true, pet = true, deadfriendly = true, focus = true}
    for i = 1, 4 do targets["party" .. i] = true end
    for i = 1, 40 do targets["raid" .. i] = true end
    if not targets[target] then return false, "Choose a supported recipient." end
    U.BuildSpellIndex()
    local learned = U.ResolveSpell(id, false)
    if not learned then return false, "That spell is not currently learned by this character." end
    local key = "CUSTOM:" .. id .. ":" .. rule .. ":" .. target
    for _, e in ipairs(U.db.custom) do if e.key == key then return false, "This custom utility already exists." end end
    local types = {}; for kind in string.gmatch(dispels or "Magic", "[^,]+") do types[kind] = true end
    U.db.custom[#U.db.custom + 1] = {key = key, id = id, class = "ALL", rule = rule, target = target,
        label = learned.name .. " (custom)", dispels = types, missingAura = rule == "buff"}
    return true, "Added " .. learned.name
end
