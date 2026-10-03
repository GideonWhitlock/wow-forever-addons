local addonName, U = ...
local f = CreateFrame("Frame")
U.loader = f
U.skippedEvents = {}
function U.RegisterEvent(name)
    -- Forever's event surface differs from Classic. Check the running client,
    -- then retain a guarded fallback for builds without the validation API.
    local valid = U.Public(C_EventUtils and C_EventUtils.IsEventValid, name)
    if valid == false then U.skippedEvents[name] = true; return false end
    local ok = pcall(f.RegisterEvent, f, name)
    if not ok then U.skippedEvents[name] = true; return false end
    return true
end
U.RegisterEvent("ADDON_LOADED")
local rebuildEvents = {PLAYER_LOGIN = true, PLAYER_ENTERING_WORLD = true, SPELLS_CHANGED = true, SKILL_LINES_CHANGED = true,
    UNIT_PET = true, PET_BAR_UPDATE = true, BAG_UPDATE_DELAYED = true}
function U.QueueRebuild()
    if not U.pending or not U.rebuildAt then
        U.rebuildAt = math.max(GetTime() + 0.15, U.nextRebuildAt or 0)
    end
    U.pending = true
end
function U.Command(message)
    local args = {}; for word in string.gmatch(message or "", "%S+") do args[#args + 1] = word end
    local cmd = string.lower(args[1] or "")
    if cmd == "status" then
        local version, build, _, interface = GetBuildInfo()
        U.Print("v" .. U.VERSION .. "; client " .. version .. " / " .. build .. "; interface " .. interface)
        U.Print((U.entries and #U.entries or 0) .. " buttons; native health curves " .. (UnitHealthPercent and C_CurveUtil and "available" or "unavailable") .. "; in-game behaviour still needs verification.")
        U.Print("This session: " .. U.stats.rebuilds .. " catalogue rebuilds, " .. U.stats.refreshes .. " display refreshes; " .. (U.pausedForError and "updates paused after an error" or "updates running") .. ".")
        local skipped = {}; for name in pairs(U.skippedEvents) do skipped[#skipped + 1] = name end
        if #skipped > 0 then table.sort(skipped); U.Print("Events unavailable in this client: " .. table.concat(skipped, ", ")) end
        return
    end
    if not U.root then U.Print("Waiting for the client to load outside combat."); return end
    if cmd == "why" then
        local driver = U.Public(U.root.GetAttribute, U.root, "state-utility") or "not set"
        U.Print("v" .. U.VERSION .. "; combat display: " .. driver .. ". Most recent combat checks:")
        local selected = tonumber(args[2])
        for i, e in ipairs(U.entries) do
            if not selected or i == selected then
                local b = U.byKey[e.key]
                U.Print(i .. ": " .. e.label .. " - " .. (b.combatState or "not checked") .. "; " .. (b.combatReason or "No combat check recorded since loading."))
            end
        end
        return
    end
    if cmd == "help" then
        U.Print("/uh settings | unlock | lock | size 46 | idle 0..100 | health 50 | mana 50 | pethealth 50 | list | status | why [number]")
        U.Print("/uh bind <button number> <KEY> [replace] | unbind <number> | hide <number> | restore | enable | disable")
        U.Print("/uh add <spellID> <rule> <recipient> [Magic,Curse,Poison,Disease] | remove <spellID>")
        U.Print("Rules: health, mana, pethealth, interrupt, dispel, purge, control, buff, manual. Recipients: player, friendly, target, pet, focus, party1..4, raid1..40.")
        return
    end
    if InCombatLockdown() then U.Print("Change settings after combat."); return end
    if cmd == "" or cmd == "settings" then U.ToggleOptions()
    elseif cmd == "unlock" then U.SetEditing(true)
    elseif cmd == "lock" then U.SetEditing(false)
    elseif cmd == "list" then
        for i, e in ipairs(U.entries) do U.Print(i .. ": " .. e.label .. " -> " .. e.target .. "  [" .. (U.db.bindings[e.key] or "unbound") .. "]") end
    elseif cmd == "enable" or cmd == "disable" then U.db.enabled = cmd == "enable"; U.pausedForError = nil; U.Rebuild()
    elseif cmd == "restore" then U.db.hidden = {}; U.Rebuild()
    elseif cmd == "size" or cmd == "health" or cmd == "mana" or cmd == "pethealth" or cmd == "idle" then
        local n = tonumber(args[2]); local lo, hi = 5, 95
        if cmd == "size" then lo, hi = 28, 100 end
        if cmd == "idle" then lo, hi = 0, 100 end
        if n and n >= lo and n <= hi then U.db[cmd] = math.floor(n) / (cmd == "idle" and 100 or 1); U.curves = {}; U.ApplyLayout(); U.RefreshOptions(); U.Refresh()
        else U.Print("Choose a value between " .. lo .. " and " .. hi .. ".") end
    elseif cmd == "bind" or cmd == "unbind" or cmd == "hide" then
        local e = U.entries[tonumber(args[2]) or 0]
        if not e then U.Print("Use /uh list to find the button number."); return end
        if cmd == "hide" then U.db.hidden[e.key] = true; U.Rebuild()
        elseif cmd == "bind" and not args[3] then U.Print("Specify the key to bind, for example CTRL-F.")
        else local _, result = U.SetBinding(e.key, cmd == "bind" and args[3] or nil, args[4] == "replace"); U.Print(result); U.RefreshOptions() end
    elseif cmd == "add" then
        local ok, result = U.AddCustom(tonumber(args[2]), args[3], args[4], args[5]); U.Print(result)
        if ok then U.Rebuild() end
    elseif cmd == "remove" then
        local id = tonumber(args[2]); local removed = 0
        for i = #U.db.custom, 1, -1 do
            if U.db.custom[i].id == id then
                local key = U.db.custom[i].key
                U.db.bindings[key], U.db.positions[key], U.db.hidden[key] = nil, nil, nil
                table.remove(U.db.custom, i); removed = removed + 1
            end
        end
        U.Rebuild(); U.Print("Removed " .. removed .. " custom rules.")
    else U.Print("Use /uh help for commands.") end
end
local function start()
    if U.started or U.starting or InCombatLockdown() then return end
    if not C_Spell or not C_SpellBook or not C_Item then
        U.Print("Required Forever APIs are missing. No action buttons were created."); U.pausedForError = true; return
    end
    U.starting = true
    U.Rebuild(); U.started = true; U.starting = nil
    U.Print("Loaded for " .. U.class .. ". /uh opens settings. Utilities work in combat; learned self-buffs, bandages and resource trackers can alert outside combat.")
end
local elapsed, lastRefresh = 0, 0
function U.Tick(_, dt)
    elapsed = elapsed + dt
    if elapsed < 0.10 then return end
    elapsed = 0
    if not U.db or U.pausedForError then return end
    local now = GetTime()
    if not InCombatLockdown() then
        if not U.minimap then U.BuildMinimap() end
        if U.pending and now >= (U.rebuildAt or 0) then
            if not U.started then start() else U.Rebuild() end
            lastRefresh = now
            return -- Keep rebuilding and polling in separate update ticks.
        end
        if U.layoutDirty and U.root then
            U.layoutDirty = nil
            if U.dragging then U.dragging:StopMovingOrSizing(); U.dragging = nil end
            U.ApplyLayout(); U.UpdateMinimap()
        end
    end
    if U.started and U.db.enabled and (U.root:IsShown() or U.restRoot:IsShown()) and (U.dirty or now - lastRefresh >= 0.5) then
        lastRefresh = now
        U.Refresh()
    end
end
f:SetScript("OnEvent", function(_, event, arg1, arg2)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end
        f:UnregisterEvent("ADDON_LOADED"); U.LoadSettings()
        SLASH_UTILITYHELPER1, SLASH_UTILITYHELPER2 = "/uh", "/utilityhelper"
        SlashCmdList.UTILITYHELPER = U.Command
        for _, name in ipairs({"PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
            "SPELLS_CHANGED", "SKILL_LINES_CHANGED", "SPELL_TEXT_UPDATE", "SPELL_DATA_LOAD_RESULT", "UNIT_PET", "PET_BAR_UPDATE", "BAG_UPDATE_DELAYED", "GET_ITEM_INFO_RECEIVED",
            "UNIT_HEALTH", "UNIT_POWER_UPDATE", "UNIT_AURA", "PLAYER_TARGET_CHANGED", "PLAYER_FOCUS_CHANGED", "GROUP_ROSTER_UPDATE", "SPELL_UPDATE_COOLDOWN",
            "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP",
            "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED", "UNIT_SPELLCAST_DELAYED", "UNIT_SPELLCAST_CHANNEL_UPDATE",
            "UNIT_SPELLCAST_INTERRUPTIBLE", "UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "MINIMAP_UPDATE_TRACKING", "UI_SCALE_CHANGED"}) do
            U.RegisterEvent(name)
        end
        f:SetScript("OnUpdate", U.Tick)
        -- This small, independent control appears even while the bar is queued.
        if not InCombatLockdown() then U.BuildMinimap() end
        return
    end
    if not U.db then return end
    if event == "GET_ITEM_INFO_RECEIVED" or event == "SPELL_TEXT_UPDATE" or event == "SPELL_DATA_LOAD_RESULT" then
        if U.Secret(arg1) or U.Secret(arg2) then return end
        local waiting = event == "GET_ITEM_INFO_RECEIVED" and U.waitingItems or U.waitingSpells
        if not arg1 or not waiting[arg1] then return end
        waiting[arg1] = nil -- Consume before scheduling; unrelated/global data events are ignored.
        if arg2 ~= false then U.QueueRebuild() end
        return
    end
    if event == "UNIT_PET" and (U.Secret(arg1) or arg1 ~= "player") then return end
    if event:match("^UNIT_") and event ~= "UNIT_PET" then
        if U.Secret(arg1) or not (U.trackedUnits and U.trackedUnits[arg1]) then return end
    end
    if event == "SPELL_UPDATE_COOLDOWN" then U.CaptureCooldownEvent() end
    if event == "PLAYER_REGEN_DISABLED" then
        -- Unprotected editing overlays can close. Protected geometry/actions wait for combat end.
        U.editing, U.preview = false, false
        if U.handle then U.handle:Hide() end
        if U.options then U.options:Hide() end
        for _, b in ipairs(U.buttons) do b.editor:Hide(); b.number:SetAlpha(0) end
        if U.StopMinimapDrag then U.StopMinimapDrag() end
    end
    if rebuildEvents[event] then U.QueueRebuild() end
    if event == "PLAYER_REGEN_ENABLED" then
        if U.pending or not U.started then U.QueueRebuild() end
        if U.dragging then U.layoutDirty = true end
    end
    if event == "UI_SCALE_CHANGED" then U.layoutDirty = true end
    U.dirty = true
end)
