local _, U = ...
U.buttons, U.byKey, U.curves = {}, {}, {}
local function paint(texture, r, g, b, a)
    texture:SetColorTexture(r, g, b, a)
end
local function border(parent, width, color)
    local edges = {}
    for _, side in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
        local t = parent:CreateTexture(nil, "OVERLAY")
        if side == "TOP" or side == "BOTTOM" then
            t:SetPoint(side .. "LEFT"); t:SetPoint(side .. "RIGHT"); t:SetHeight(width)
        else
            t:SetPoint("TOP" .. side); t:SetPoint("BOTTOM" .. side); t:SetWidth(width)
        end
        paint(t, unpack(color)); edges[#edges + 1] = t
    end
    return edges
end
local function font(parent, size)
    local f = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    f:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
    return f
end
local function createProcGlow(b)
    -- Use the client's own proc artwork. All construction happens outside combat.
    -- Keep it under glow: native secret threshold opacity belongs to that parent.
    if type(ActionButtonSpellAlertMixin) == "table" then
        local ok, proc = pcall(CreateFrame, "Frame", nil, b.glow, "ActionButtonSpellAlertTemplate")
        if ok and proc.ProcStartAnim and proc.ProcLoop and proc.ProcStartFlipbook and proc.ProcLoopFlipbook then
            b.procAlert = proc
            proc:EnableMouse(false); proc:SetPoint("CENTER", b, "CENTER")
            proc:SetScript("OnShow", nil)
            proc:SetScript("OnHide", function()
                proc.ProcStartAnim:Stop(); proc.ProcLoop:Stop()
                b.animating = false
                for _, edge in ipairs(b.glowEdges) do edge:SetAlpha(1) end
            end)
            proc.ProcStartAnim:SetScript("OnFinished", function()
                if b.animating then proc.ProcLoop:Play() end
            end)
            proc:Hide()
            return
        elseif ok then proc:Hide() end
    end
    -- Older/missing templates retain the lightweight pulsing border.
    b.pulses = {}
    for _, edge in ipairs(b.glowEdges) do
        local group = edge:CreateAnimationGroup()
        local fade = group:CreateAnimation("Alpha")
        fade:SetFromAlpha(0.35); fade:SetToAlpha(1); fade:SetDuration(0.6); fade:SetSmoothing("IN_OUT")
        group:SetLooping("BOUNCE"); b.pulses[#b.pulses + 1] = group
    end
end
function U.SetProcGlow(b, animate, skipBurst)
    if b.animating == animate then return end
    b.animating = animate
    if b.procAlert then
        for _, edge in ipairs(b.glowEdges) do edge:SetAlpha(animate and 0 or 1) end
        if animate then
            b.procAlert.ProcStartFlipbook:SetAlpha(1); b.procAlert.ProcLoopFlipbook:SetAlpha(0)
            b.procAlert:Show()
            -- Display-only conditions can cross a secret threshold at any time.
            -- Let the continuous native loop appear through its parent's alpha.
            if skipBurst then b.procAlert.ProcLoop:Play()
            else b.procAlert.ProcStartAnim:Play() end
        else
            b.procAlert.ProcStartAnim:Stop(); b.procAlert.ProcLoop:Stop()
            b.procAlert:Hide()
        end
    else
        for i, group in ipairs(b.pulses) do
            if animate then group:Play() else group:Stop(); b.glowEdges[i]:SetAlpha(1) end
        end
    end
end
function U.LayoutColumns()
    return U.db.compact and math.max(1, math.ceil(math.sqrt(#(U.entries or {})))) or U.db.columns
end
function U.ApplyLayout()
    if InCombatLockdown() or not U.root then return end
    local size, gap, columns = U.db.size, U.db.gap, U.LayoutColumns()
    local n = #U.entries
    local width = math.max(size, math.min(n, columns) * (size + gap) - gap)
    local height = math.max(size, math.ceil(n / columns) * (size + gap + 15) - gap)
    U.root:SetSize(width, height)
    U.root:ClearAllPoints(); U.root:SetPoint("CENTER", UIParent, "CENTER", U.db.x, U.db.y)
    for i, e in ipairs(U.entries) do
        local b = U.byKey[e.key]
        b:SetSize(size, size); b:ClearAllPoints()
        if b.procAlert then
            b.procAlert:SetSize(size * 1.4, size * 1.4)
            b.procAlert.ProcStartFlipbook:SetSize(size * 2.4, size * 2.4)
        end
        local saved = not U.db.compact and U.db.positions[e.key]
        if type(saved) == "table" and type(saved.x) == "number" and type(saved.y) == "number" then
            b:SetPoint("CENTER", UIParent, "CENTER", saved.x, saved.y)
        else
            b:SetPoint("TOPLEFT", U.root, "TOPLEFT", ((i - 1) % columns) * (size + gap), -math.floor((i - 1) / columns) * (size + gap + 15))
        end
        b.label:SetWidth(size + gap)
        b.number:SetText(i)
    end
    U.handle:SetSize(width, 24)
end
function U.SavePosition(frame)
    local x, y = frame:GetCenter()
    local px, py = UIParent:GetCenter()
    return x - px, y - py
end
function U.Tooltip(b)
    local e = b.entry
    if not e then return end
    U.hoveredButton = b
    local tip = U.tooltip
    if not tip then return end
    if not b.tooltipVisible or (not InCombatLockdown() and not U.editing and not b.restInput) then tip:Hide(); return end
    U.tooltipFor = b
    tip:SetOwner(b, "ANCHOR_RIGHT")
    if e.itemID then tip:SetItemByID(e.itemID)
    elseif e.spellID then tip:SetSpellByID(e.spellID)
    else tip:SetText(e.label) end
    tip:AddLine(" ")
    tip:AddLine(e.label, 1, 0.8, 0.35)
    tip:AddLine(b.reason or U.ruleLabels[e.rule], 0.85, 0.85, 0.85, true)
    local recipient = e.targetedBuff and "Selected living friendly player or pet"
        or e.target == "friendly" and "Selected living ally; otherwise you"
        or e.target == "deadfriendly" and "Selected dead ally" or e.target
    tip:AddLine("Recipient: " .. recipient, 0.6, 0.85, 1, true)
    if e.note then tip:AddLine(e.note, 1, 0.7, 0.3, true) end
    if e.incidentalDamage then tip:AddLine("Utility spell with incidental damage", 1, 0.6, 0.35) end
    tip:AddLine("Key: " .. (U.db.bindings[e.key] or "Unassigned"), 1, 1, 1)
    tip:AddLine(e.selfBuff and "Learned self-buffs appear outside combat when their buff family is missing."
        or e.tracking and "Learned resource trackers appear outside combat when no supported resource tracker is active."
        or e.restOnly and "Bandages appear only outside combat at the health threshold. Private-health alerts are reminders; use your normal action bar."
        or "This button and its keybind work in combat. Bright borders indicate a relevant utility.", 0.7, 0.7, 0.7, true)
    tip:Show()
    -- Apply after native population/OnShow; native alpha may be secret.
    tip:SetAlpha(b.tooltipAlpha)
end
function U.HideTooltip(b)
    if U.hoveredButton ~= b then return end
    U.hoveredButton, U.tooltipFor = nil, nil
    if U.tooltip then U.tooltip:Hide() end
end
function U.RefreshTooltip(b)
    if U.hoveredButton ~= b then return end
    if not b.tooltipVisible then U.tooltip:Hide()
    elseif not U.tooltip:IsShown() or U.tooltipFor ~= b then U.Tooltip(b)
    else U.tooltip:SetAlpha(b.tooltipAlpha) end
end
function U.CreateButton(e)
    local b = CreateFrame("Button", "UtilityHelperAction" .. (#U.buttons + 1), e.restOnly and U.restRoot or U.root, "SecureActionButtonTemplate")
    U.buttons[#U.buttons + 1] = b
    U.byKey[e.key] = b
    b:SetClampedToScreen(true); b:SetMovable(true)
    b:RegisterForClicks("AnyUp", "AnyDown"); b:SetAttribute("useOnKeyDown", false)
    b:SetFrameStrata("MEDIUM")
    -- A pre-registered secure state driver enables input only in combat.
    -- Situational alerts only change artwork, never protected actions or input.
    b.art = CreateFrame("Frame", nil, b)
    b.art:SetAllPoints(); b.art:EnableMouse(false)
    local bg = b.art:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); paint(bg, 0.035, 0.045, 0.06, 1)
    b.icon = b.art:CreateTexture(nil, "ARTWORK")
    b.icon:SetPoint("TOPLEFT", 3, -3); b.icon:SetPoint("BOTTOMRIGHT", -3, 3)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    border(b.art, 1, {0.42, 0.45, 0.52, 1})
    b.cooldown = CreateFrame("Cooldown", nil, b.art, "CooldownFrameTemplate")
    b.cooldown:SetAllPoints(b.icon); b.cooldown:SetDrawEdge(false); b.cooldown:SetHideCountdownNumbers(false)
    b.glow = CreateFrame("Frame", nil, b)
    b.glow:SetPoint("TOPLEFT", -2, 2); b.glow:SetPoint("BOTTOMRIGHT", 2, -2)
    b.glow:EnableMouse(false)
    b.glowEdges = border(b.glow, 3, {1, 0.72, 0.18, 1})
    createProcGlow(b)
    b.keyText = font(b.art, 10); b.keyText:SetPoint("TOPRIGHT", -2, -2)
    b.label = font(b.art, 9); b.label:SetPoint("TOP", b, "BOTTOM", 0, -3); b.label:SetMaxLines(1)
    b.status = font(b.art, 9); b.status:SetPoint("BOTTOMLEFT", 4, 4)
    b.number = font(b.art, 11); b.number:SetPoint("CENTER"); b.number:SetAlpha(0)
    -- Keep hover artwork under the same alpha as the icon, label and cooldown.
    b.hover = b.art:CreateTexture(nil, "OVERLAY"); b.hover:SetAllPoints()
    b.hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square"); b.hover:SetBlendMode("ADD"); b.hover:Hide()
    b:SetScript("OnEnter", function() b.hover:Show(); U.Tooltip(b) end)
    b:SetScript("OnLeave", function() b.hover:Hide(); U.HideTooltip(b) end)
    b:SetScript("OnHide", function() b.hover:Hide(); U.HideTooltip(b); U.SetProcGlow(b, false) end)
    b:SetScript("PostClick", function() U.dirty = true end)
    -- Arrangement reveals disabled buttons; this cover handles dragging only.
    b.editor = CreateFrame("Button", nil, UIParent)
    b.editor:SetAllPoints(b); b.editor:SetFrameStrata("DIALOG")
    b.editor:RegisterForDrag("LeftButton"); b.editor:EnableMouseWheel(true); b.editor:Hide()
    b.editor:SetScript("OnDragStart", function()
        if InCombatLockdown() then return end
        U.dragging = U.db.compact and U.root or b; U.dragging:StartMoving()
    end)
    b.editor:SetScript("OnDragStop", function()
        if InCombatLockdown() then return end
        local moving = U.dragging
        if not moving then return end
        moving:StopMovingOrSizing(); U.dragging = nil
        local x, y = U.SavePosition(moving)
        if moving == U.root then U.db.x, U.db.y = x, y
        else U.db.positions[b.entry.key] = {x = x, y = y} end
        U.ApplyLayout()
    end)
    b.editor:SetScript("OnMouseWheel", function(_, delta)
        if not InCombatLockdown() then U.db.size = math.max(28, math.min(100, U.db.size + 2 * delta)); U.ApplyLayout() end
    end)
    b.editor:SetScript("OnEnter", function() U.Tooltip(b) end)
    b.editor:SetScript("OnLeave", function() U.HideTooltip(b) end)
    b.editor:SetScript("OnHide", function() U.HideTooltip(b) end)
    return b
end
function U.ConfigureAction(b, e)
    assert(not InCombatLockdown(), "Protected action change in combat")
    b.entry = e
    b:SetAttribute("*type1", nil); b:SetAttribute("*type2", nil)
    b:SetAttribute("spell", nil); b:SetAttribute("item", nil); b:SetAttribute("macrotext", nil)
    b:SetAttribute("unit", nil)
    if e.items then
        if e.itemID then
            if e.bandage then
                b:SetAttribute("*type1", "macro")
                b:SetAttribute("macrotext", "/stopmacro [combat][channeling]\n/use [@player] item:" .. e.itemID)
            else
                b:SetAttribute("*type1", "item"); b:SetAttribute("item", "item:" .. e.itemID)
                b:SetAttribute("unit", e.targetedBuff and "target" or "player")
            end
        end
    elseif e.rule == "pethealth" and not e.petSpell then
        -- Native macro condition prevents restarting the same player channel,
        -- even before the next display update or when cast details are secret.
        b:SetAttribute("*type1", "macro")
        b:SetAttribute("macrotext", "/stopmacro [channeling:" .. e.name .. "]\n/cast [@pet] " .. e.name)
    elseif e.target == "friendly" or e.target == "deadfriendly" then
        local condition = e.targetedBuff and "[help,nodead]"
            or e.target == "friendly" and "[help,nodead][@player]" or "[help,dead]"
        b:SetAttribute("*type1", "macro")
        b:SetAttribute("macrotext", "/cast " .. condition .. " " .. e.name)
    else
        b:SetAttribute("*type1", "spell"); b:SetAttribute("spell", e.name)
        b:SetAttribute("unit", e.selfCast and "player" or e.target)
        b:SetAttribute("checkselfcast", false); b:SetAttribute("checkfocuscast", false)
    end
    b.icon:SetTexture(e.icon or 134400)
    b.label:SetText(e.label)
    b:Show()
end
function U.ApplyBindings()
    if InCombatLockdown() then U.pending = true; return end
    ClearOverrideBindings(U.root)
    ClearOverrideBindings(U.restRoot)
    local combatCount, restCount = 0, 0
    for i, e in ipairs(U.entries) do
        local b = U.byKey[e.key]
        local key = U.db.bindings[e.key]
        b.keyText:SetText(key or "")
        b:SetAttribute("utility-key", key)
        if e.restOnly then
            restCount = restCount + 1; U.restRoot:SetFrameRef("action" .. restCount, b)
            b.restInput, b.restBinding = nil, nil
        else
            combatCount = combatCount + 1; U.root:SetFrameRef("action" .. combatCount, b)
        end
    end
    U.root:SetAttribute("button-count", combatCount)
    U.restRoot:SetAttribute("button-count", restCount)
    U.root:SetAttribute("arranging", U.editing or false)
    -- Force the same state to reapply after configuration/binding changes.
    U.root:SetAttribute("state-utility", nil)
    local driver = "hide"
    if U.db.enabled then
        driver = "[dead][mounted][flying][vehicleui] hide; [combat] combat; " .. (U.editing and "arrange" or "hide")
    end
    RegisterStateDriver(U.root, "utility", driver)
    U.restRoot:SetAttribute("state-utility", nil)
    RegisterStateDriver(U.restRoot, "utility", U.db.enabled and "[dead][mounted][flying][vehicleui][combat] hide; rest" or "hide")
end
function U.SyncRestButton(b, state)
    if InCombatLockdown() then return end
    local available = U.restRoot:GetAttribute("state-utility") == "rest"
    -- Only a publicly confirmed condition may enable protected input. Private
    -- health controls bandage reminder artwork only, with input disabled.
    local active = available and not U.editing and state == "active" or false
    local reminder = available and not U.editing and state == "display" or false
    if b.restInput ~= active then
        b.restInput = active
        if active then b:Enable(); b:EnableMouse(true)
        else b:Disable(); b:EnableMouse(false) end
    end
    if not active then b.hover:Hide(); U.HideTooltip(b) end
    b:SetShown(available and (active or reminder or U.editing) or false)
    b.keyText:SetText(reminder and "" or (U.db.bindings[b.entry.key] or ""))
    local key = active and U.db.bindings[b.entry.key] or nil
    if b.restBinding ~= key then b.restBinding = key; U.restBindingsDirty = true end
end
function U.SetBinding(keyID, key, replace)
    if InCombatLockdown() then return false, "Change keybinds after combat." end
    if key and keyID == "ITEM:bandage" and U.Low("player", false, U.db.health) == nil then
        return false, "Bandage is a low-health reminder on this client. Bind it on your normal action bar."
    end
    if key then
        key = string.upper(key)
        for id, other in pairs(U.db.bindings) do
            if id ~= keyID and other == key then return false, "This key is already assigned to another utility." end
        end
        local existing = GetBindingAction(key)
        if existing and existing ~= "" and not replace then return false, "Already assigned to " .. existing .. ". Choose another key, or use Replace." end
    end
    U.db.bindings[keyID] = key; U.ApplyBindings()
    return true, key and ("Assigned " .. key) or "Binding cleared"
end
function U.SetEditing(value)
    if InCombatLockdown() then U.Print("Arrange buttons after combat."); return end
    if not U.root then U.Print("The utility bar is still loading. Try again in a moment."); return end
    value = value and U.db.enabled or false
    U.editing = value
    U.handle:SetShown(value)
    U.ApplyBindings(); U.Refresh()
    for _, b in ipairs(U.buttons) do
        b.editor:SetShown(value and b:IsShown())
        b.number:SetAlpha(value and 1 or 0)
    end
end
function U.BuildUI()
    assert(not InCombatLockdown())
    -- Own tooltip prevents native alpha on an alert from affecting other game tooltips.
    U.tooltip = CreateFrame("GameTooltip", "UtilityHelperTooltip", UIParent, "GameTooltipTemplate")
    U.tooltip:SetFrameStrata("TOOLTIP"); U.tooltip:EnableMouse(false); U.tooltip:Hide()
    U.root = CreateFrame("Frame", "UtilityHelperRoot", UIParent, "SecureHandlerStateTemplate")
    U.root:SetMovable(true); U.root:SetClampedToScreen(true)
    U.root:SetAttribute("_onstate-utility", [[
        self:ClearBindings()
        if newstate == "combat" then self:SetAttribute("arranging", false) end
        for i = 1, self:GetAttribute("button-count") or 0 do
            local b = self:GetFrameRef("action" .. i)
            if b then
                if newstate == "combat" then
                    b:Enable(); b:EnableMouse(true)
                    local key = b:GetAttribute("utility-key")
                    if key then self:SetBindingClick(true, key, b:GetName(), "LeftButton") end
                else
                    b:Disable(); b:EnableMouse(false)
                end
            end
        end
        if newstate == "combat" or (newstate == "arrange" and self:GetAttribute("arranging")) then
            self:Show()
        else self:Hide() end
    ]])
    U.root:SetScript("OnHide", function()
        if U.hoveredButton then U.HideTooltip(U.hoveredButton) end
        for _, b in ipairs(U.buttons) do U.SetProcGlow(b, false) end
    end)
    U.root:SetScript("OnShow", function() U.dirty = true end)
    -- Separate owner for outside-combat self-buffs, bandages and resource trackers.
    -- Its secure transition disables input and releases keys immediately in combat.
    U.restRoot = CreateFrame("Frame", "UtilityHelperRestRoot", UIParent, "SecureHandlerStateTemplate")
    U.restRoot:EnableMouse(false)
    U.restRoot:SetAttribute("_onstate-utility", [[
        self:ClearBindings()
        for i = 1, self:GetAttribute("button-count") or 0 do
            local b = self:GetFrameRef("action" .. i)
            if b then b:Disable(); b:EnableMouse(false); b:Hide() end
        end
        if newstate == "rest" then self:Show() else self:Hide() end
    ]])
    U.restRoot:SetScript("OnHide", function()
        for _, b in ipairs(U.buttons) do
            if b.entry and b.entry.restOnly then
                b.restInput, b.restBinding = nil, nil
                U.HideTooltip(b); U.SetProcGlow(b, false)
            end
        end
    end)
    U.restRoot:SetScript("OnShow", function() U.dirty = true end)
    U.handle = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
    U.handle:SetPoint("BOTTOMLEFT", U.root, "TOPLEFT", 0, 6); U.handle:SetFrameStrata("DIALOG")
    U.handle:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8"}); U.handle:SetBackdropColor(0.08, 0.12, 0.19, 0.95)
    local caption = font(U.handle, 12); caption:SetPoint("CENTER"); caption:SetText("UTILITY HELPER: FOREVER  |  Drag bar  |  Wheel: size")
    U.handle:RegisterForDrag("LeftButton"); U.handle:EnableMouseWheel(true); U.handle:Hide()
    U.handle:SetScript("OnDragStart", function() if not InCombatLockdown() then U.dragging = U.root; U.root:StartMoving() end end)
    U.handle:SetScript("OnDragStop", function()
        if InCombatLockdown() then return end
        U.root:StopMovingOrSizing(); U.dragging = nil
        U.db.x, U.db.y = U.SavePosition(U.root); U.ApplyLayout()
    end)
    U.handle:SetScript("OnMouseWheel", function(_, delta)
        if not InCombatLockdown() then U.db.size = math.max(28, math.min(100, U.db.size + delta * 2)); U.ApplyLayout() end
    end)
end
local function rebuild()
    if not U.root then U.BuildUI() end
    U.entries = U.BuildEntries()
    U.gcdOnly = {}
    for _, b in ipairs(U.buttons) do b:Hide(); b.editor:Hide() end
    for _, e in ipairs(U.entries) do U.ConfigureAction(U.byKey[e.key] or U.CreateButton(e), e) end
    U.curves = {}
    U.ApplyLayout(); U.SetEditing(U.editing or false)
    if U.RefreshOptions then U.RefreshOptions() end
end
function U.Rebuild()
    if InCombatLockdown() then U.QueueRebuild(); return end
    if U.rebuilding then return end
    U.rebuilding = true
    -- Consume the current request BEFORE calling native APIs, which can emit
    -- synchronous completion events. A new request must survive this rebuild.
    U.pending, U.rebuildAt = false, nil
    U.nextRebuildAt = GetTime() + 1
    U.stats.rebuilds = U.stats.rebuilds + 1
    local ok, err = pcall(rebuild)
    U.rebuilding = nil
    if not ok then U.pausedForError = true; error(err, 0) end
end
function U.UpdateCooldown(b)
    local e = b.entry
    if e.itemID then
        local ok, start, duration = U.Call(C_Item.GetItemCooldown, e.itemID)
        if ok then U.Call(b.cooldown.SetCooldown, b.cooldown, start, duration) end
    elseif e.spellID then
        local cd = U.Public(C_Spell.GetSpellCooldown, e.spellID)
        if cd then U.Call(b.cooldown.SetCooldown, b.cooldown, cd.startTime, cd.duration, cd.modRate) end
    else b.cooldown:Clear() end
end
function U.Render(b, state, reason, unit, visual)
    b.reason, b.lastState = reason, state
    b:SetAlpha(1)
    if InCombatLockdown() then b.combatState, b.combatReason = state, reason end
    b.status:SetText(state == "unknown" and "?" or b.entry.target:match("^party") or "")
    if b.entry.target:match("^party") then b.status:SetText(b.entry.target:gsub("party", "P")) end
    -- Rest-only recovery must stay absent above the threshold at every idle setting.
    local idle = b.entry.restOnly and 0 or U.db.idle
    local alpha, glow = idle, 0
    if U.editing or U.preview then alpha, glow = 1, 1
    elseif state == "active" then alpha, glow = 1, 1
    elseif state == "display" and visual and visual.dual then
        local okDual, manaAlpha, manaGlow, healthGate = U.DualVisualValues(visual, idle)
        if okDual then
            -- Effective opacity is the product of the protected button's health
            -- gate and its child's mana gate. Secret values are never inspected.
            b:SetAlpha(healthGate); b.art:SetAlpha(manaAlpha); b.glow:SetAlpha(manaGlow)
            b.tooltipVisible, b.tooltipAlpha = false, 0
            alpha = nil
        else b.status:SetText("?") end
    elseif state == "display" and visual then
        local threshold = visual.threshold or 50
        local key = tostring(threshold) .. ":" .. tostring(idle)
        if not U.curves[key] then U.curves[key] = {U.MakeCurve(threshold, 1, idle), U.MakeCurve(threshold, 1, 0)} end
        local curves = U.curves[key]
        local okA, nativeAlpha = U.VisualValue(visual, curves[1], 1, idle)
        local okG, nativeGlow = U.VisualValue(visual, curves[2], 1, 0)
        if okA and okG then
            -- Native results may be secret. Pass directly to presentation, never inspect them.
            b.art:SetAlpha(nativeAlpha); b.glow:SetAlpha(nativeGlow)
            b.tooltipAlpha = idle > 0 and 1 or nativeGlow
            b.tooltipVisible = not b.entry.restOnly -- Rest reminders never accept hover input.
            if b.entry.restOnly then b.status:SetText("Reminder") end
            alpha = nil
        else b.status:SetText("?") end
    end
    if alpha then
        b.art:SetAlpha(alpha); b.glow:SetAlpha(glow)
        b.tooltipVisible = alpha > 0
        b.tooltipAlpha = b.tooltipVisible and 1 or 0
    end
    U.RefreshTooltip(b)
    -- Start only on transitions, without per-frame animation work or allocations.
    -- The decision uses public state, never an alpha/secret display-curve result.
    local parentShown = b.entry.restOnly and U.restRoot:IsShown() or (not b.entry.restOnly and U.root:IsShown())
    local animate = U.db.flash and parentShown and b:IsShown()
        and (U.editing or U.preview or state == "active" or state == "display") or false
    U.SetProcGlow(b, animate, state == "display" and not U.editing and not U.preview)
    U.UpdateCooldown(b)
end
function U.Refresh()
    if not U.root or not U.entries or not U.db.enabled or U.refreshing then return end
    U.refreshing = true
    U.dirty = false
    U.stats.refreshes = U.stats.refreshes + 1
    U.auraCache = {}
    U.resourceTrackingChecked, U.resourceTrackingActive = nil, nil
    for _, e in ipairs(U.entries) do
        local b = U.byKey[e.key]
        local state, reason, unit, visual = U.Evaluate(e)
        if e.restOnly then U.SyncRestButton(b, state) end
        U.Render(b, state, reason, unit, visual)
    end
    if not InCombatLockdown() and U.restBindingsDirty then
        U.restBindingsDirty = nil; ClearOverrideBindings(U.restRoot)
        for _, e in ipairs(U.entries) do
            local b = U.byKey[e.key]
            if e.restOnly and b.restBinding then SetOverrideBindingClick(U.restRoot, true, b.restBinding, b:GetName(), "LeftButton") end
        end
    end
    U.refreshing = nil
end
