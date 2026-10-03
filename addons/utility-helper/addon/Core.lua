local _, U = ...
U.defaults = {size = 46, columns = 8, gap = 9, x = 0, y = -130, health = 50, mana = 50,
    pethealth = 50, idle = 0, compact = true, flash = true, party = false, incidental = true,
    showManual = true, enabled = true, minimapAngle = 160, hidden = {}, bindings = {}, positions = {}, custom = {}}
U.UNKNOWN = "unknown"
U.spellNames, U.itemInfo = {}, {}
U.waitingSpells, U.waitingItems = {}, {}
U.requestedSpells, U.requestedItems = {}, {}
U.stats = {rebuilds = 0, refreshes = 0}
U.gcdOnly = {}

function U.Print(text) DEFAULT_CHAT_FRAME:AddMessage("|cffffcb66" .. U.TITLE .. ":|r " .. text) end
function U.Secret(value) return issecretvalue and issecretvalue(value) or false end
function U.Call(fn, ...)
    if type(fn) ~= "function" then return false end
    return pcall(fn, ...)
end
-- Metadata callbacks are synchronous on Forever. Cache successful reads and
-- track only our own pending IDs; never rebuild directly from a data callback.
function U.SpellName(id)
    if U.spellNames[id] then return U.spellNames[id] end
    U.waitingSpells[id] = true
    local name = U.Public(C_Spell and C_Spell.GetSpellName, id)
    if name then
        U.spellNames[id], U.waitingSpells[id] = name, nil
    elseif not U.requestedSpells[id] then
        U.requestedSpells[id] = true
        U.Call(C_Spell and C_Spell.RequestLoadSpellData, id)
    end
    return name
end
function U.ItemMetadata(id)
    if U.itemInfo[id] then return U.itemInfo[id] end
    U.waitingItems[id] = true
    local ok, name, _, _, _, level = U.Call(C_Item and C_Item.GetItemInfo, id)
    if ok and not U.Secret(name) and name and not U.Secret(level) then
        local info = {name = name, level = level or 0}
        U.itemInfo[id], U.waitingItems[id] = info, nil
        return info
    end
    if not U.requestedItems[id] then
        U.requestedItems[id] = true
        U.Call(C_Item and C_Item.RequestLoadItemDataByID, id)
    end
end
function U.Public(fn, ...)
    local ok, value = U.Call(fn, ...)
    if ok and not U.Secret(value) then return value end
end
local function clamp(v, lo, hi, default)
    if type(v) ~= "number" or v ~= v then return default end
    return math.max(lo, math.min(hi, v))
end
function U.LoadSettings()
    if type(UtilityHelperDB) ~= "table" then UtilityHelperDB = {} end
    U.db = UtilityHelperDB
    for k, v in pairs(U.defaults) do
        if type(U.db[k]) ~= type(v) then U.db[k] = type(v) == "table" and {} or v end
    end
    for _, spec in ipairs({{"size", 28, 100}, {"columns", 1, 16}, {"gap", 4, 30},
        {"health", 5, 95}, {"mana", 5, 95}, {"pethealth", 5, 95}, {"idle", 0, 1},
        {"x", -4000, 4000}, {"y", -4000, 4000}, {"minimapAngle", 0, 360}}) do
        local k = spec[1]; U.db[k] = clamp(U.db[k], spec[2], spec[3], U.defaults[k])
    end
    U.db.columns = math.floor(U.db.columns)
    U.class = select(2, UnitClass("player"))
end
function U.Alive(unit)
    if U.Public(UnitExists, unit) ~= true then return false end
    return U.Public(UnitIsDeadOrGhost, unit) == false
end
function U.FriendlyUnit()
    if U.Alive("target") and U.Public(UnitCanAssist, "player", "target") == true then return "target" end
    return "player"
end
function U.UnitFor(e)
    if e.target == "friendly" then return U.FriendlyUnit() end
    if e.target == "deadfriendly" then return "target" end
    return e.target
end

function U.BuildSpellIndex()
    U.spells = {[0] = {}, [1] = {}}
    local B = C_SpellBook
    if not B then return end
    local function scan(slot, bank)
        local info = U.Public(B.GetSpellBookItemInfo, slot, bank)
        if not info or U.Secret(info) then return end
        local kind = info.itemType
        if U.Secret(kind) or (kind ~= 1 and kind ~= 3) or info.isPassive or info.isOffSpec then return end
        local id, name = info.spellID, info.name
        if U.Secret(id) or U.Secret(name) or not id or not name then return end
        local learned = U.Public(C_Spell.GetSpellLevelLearned, id) or 0
        local old = U.spells[bank][name]
        if not old or learned >= old.level then
            U.spells[bank][name] = {id = id, name = name, icon = info.iconID, level = learned, slot = slot, bank = bank}
        end
    end
    for line = 1, U.Public(B.GetNumSpellBookSkillLines) or 0 do
        local info = U.Public(B.GetSpellBookSkillLineInfo, line)
        if info then
            for slot = info.itemIndexOffset + 1, info.itemIndexOffset + info.numSpellBookItems do scan(slot, 0) end
        end
    end
    for slot = 1, U.Public(B.HasPetSpells) or 0 do scan(slot, 1) end
end
function U.ResolveSpell(id, pet)
    local bank = pet and 1 or 0
    local name = U.SpellName(id)
    if not name then return end
    local match = U.spells[bank][name]
    if match then return match end
    if C_SpellBook and U.Public(C_SpellBook.IsSpellKnown, id, bank) == true then
        return {id = id, name = name, icon = U.Public(C_Spell.GetSpellTexture, id)}
    end
end
function U.ItemCount(id) return U.Public(C_Item and C_Item.GetItemCount, id, false, false, false) or 0 end
function U.SelectItem(group)
    -- Selection changes only out of combat. The same item identity remains bound during a fight.
    local fallbackID, fallbackName
    for _, id in ipairs(group.items) do
        if U.ItemCount(id) > 0 then
            local info = U.ItemMetadata(id)
            if info and info.level <= UnitLevel("player") then
                if not group.usableSelection or U.Public(C_Item.IsUsableItem, id) == true then return id, info.name end
                -- Keep a candidate when all tiers are temporarily unavailable;
                -- readiness can recover without waiting for another bag event.
                if not fallbackID then fallbackID, fallbackName = id, info.name end
            end
        end
    end
    return fallbackID, fallbackName
end
function U.BuildEntries()
    assert(not InCombatLockdown(), "Utility catalogue cannot be rebuilt in combat")
    U.BuildSpellIndex()
    local entries, available = {}, {}
    local function prepare(source)
        if source.class ~= "ALL" and source.class ~= U.class then return end
        if source.incidentalDamage and not U.db.incidental then return end
        if source.rule == "manual" and not U.db.showManual then return end
        local learned = U.ResolveSpell(source.id, source.petSpell)
        if not learned or (source.replacedBy and U.ResolveSpell(source.replacedBy, source.petSpell)) then return end
        local e = {}; for k, v in pairs(source) do e[k] = v end
        e.spellID, e.name, e.icon, e.slot, e.bank = learned.id, learned.name, learned.icon, learned.slot, learned.bank
        available[#available + 1] = e
        if not U.db.hidden[e.key] then entries[#entries + 1] = e end
        if e.party and U.db.party then
            for i = 1, 4 do
                local p = {}; for k, v in pairs(e) do p[k] = v end
                p.target, p.key, p.party = "party" .. i, e.key .. ":party" .. i, nil
                p.label = e.label .. " (party " .. i .. ")"
                available[#available + 1] = p
                if not U.db.hidden[p.key] then entries[#entries + 1] = p end
            end
        end
    end
    for _, e in ipairs(U.catalog) do prepare(e) end
    for _, e in ipairs(U.db.custom) do
        if type(e) == "table" and type(e.id) == "number" and U.ruleLabels[e.rule] then prepare(e) end
    end
    for _, group in ipairs(U.itemGroups) do
        if (not group.class or group.class == U.class)
            and (group.rule ~= "mana" or (U.class ~= "WARRIOR" and U.class ~= "ROGUE")) then
            local e = {}; for k, v in pairs(group) do e[k] = v end
            e.itemID, e.name = U.SelectItem(group)
            if e.itemID then e.icon = U.Public(C_Item and C_Item.GetItemIconByID, e.itemID) or e.icon end
            -- Empty recovery slots stay stable, so acquiring an item later does not move other buttons.
            e.name = e.name or e.label
            available[#available + 1] = e
            if not U.db.hidden[e.key] then entries[#entries + 1] = e end
        end
    end
    U.availableEntries = available
    U.trackedUnits = {player = true, target = true, pet = true}
    for _, e in ipairs(entries) do
        if e.target ~= "friendly" and e.target ~= "deadfriendly" then U.trackedUnits[e.target] = true end
    end
    return entries
end

function U.Auras(unit, filter)
    U.auraCache = U.auraCache or {}
    local key = unit .. ":" .. filter
    if U.auraCache[key] then return unpack(U.auraCache[key]) end
    local result, readable = {}, true
    local api = C_UnitAuras
    local ok, list = U.Call(api and api.GetUnitAuras, unit, filter, 128)
    if ok and not U.Secret(list) and type(list) == "table" then
        for _, aura in ipairs(list) do
            if U.Secret(aura) then readable = false else result[#result + 1] = aura end
        end
    elseif api and api.GetAuraDataByIndex then
        for i = 1, 128 do
            local success, aura = U.Call(api.GetAuraDataByIndex, unit, i, filter)
            if not success or U.Secret(aura) then readable = false; break end
            if not aura then break end
            result[#result + 1] = aura
        end
    else readable = false end
    U.auraCache[key] = {result, readable}
    return result, readable
end
function U.HasAura(unit, ids, filter, ownOnly)
    local names = {}
    for _, id in ipairs(ids) do
        local name = U.SpellName(id)
        if name then names[name] = true end
    end
    local auras, readable = U.Auras(unit, filter or "HELPFUL")
    for _, aura in ipairs(auras) do
        if U.Secret(aura.spellId) or U.Secret(aura.name) or (ownOnly and U.Secret(aura.sourceUnit)) then readable = false
        elseif not ownOnly or aura.sourceUnit == "player" then
            for _, id in ipairs(ids) do if aura.spellId == id then return true end end
            if aura.name and names[aura.name] then return true end
        end
    end
    if readable then return false end
end
function U.Dispellable(unit, types, hostile)
    local auras, readable = U.Auras(unit, hostile and "HELPFUL" or "HARMFUL")
    for _, aura in ipairs(auras) do
        local kind = aura.dispelName
        if U.Secret(kind) then readable = false
        elseif kind and (types[kind] or (kind == "" and types.Enrage)) then return true end
    end
    if readable then return false end
end
local function contains(list, value)
    for _, item in ipairs(list or {}) do if value == item then return true end end
    return false
end
function U.CreatureEligible(e, unit)
    local ok, _, id = U.Call(UnitCreatureType, unit)
    if not ok or U.Secret(id) or type(id) ~= "number" then return nil end
    if e.types and not contains(e.types, id) then return false end
    if e.excludeTypes and contains(e.excludeTypes, id) then return false end
    return true
end
function U.Low(unit, mana, threshold)
    local current = U.Public(mana and UnitPower or UnitHealth, unit, mana and 0 or nil)
    local maximum = U.Public(mana and UnitPowerMax or UnitHealthMax, unit, mana and 0 or nil)
    if type(current) ~= "number" or type(maximum) ~= "number" then return nil end
    return maximum > 0 and current / maximum * 100 <= threshold
end
function U.Cast(unit)
    local ok, name, _, _, _, _, _, _, blocked = U.Call(UnitCastingInfo, unit)
    -- Secret values are never compared, concatenated, indexed or used as Lua conditions.
    if not ok then return nil end
    if not U.Secret(name) and not name then
        ok, name, _, _, _, _, _, blocked = U.Call(UnitChannelInfo, unit)
    end
    if not ok then return nil end
    if U.Secret(name) then
        if U.Secret(blocked) and C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean then
            return "display", {boolean = blocked}
        end
        return nil
    end
    if not name then return false end
    if U.Secret(blocked) then return "display", {boolean = blocked} end
    if blocked == nil then return nil end
    return blocked == false
end
function U.CastingEntry(e)
    if not e.spellID then return false end
    local unit = e.petSpell and "pet" or "player"
    local restricted = false
    for _, api in ipairs({"UnitCastingInfo", "UnitChannelInfo"}) do
        local ok, name = U.Call(_G[api], unit)
        if not ok or U.Secret(name) then restricted = true
        -- Localized family names also match a different learned rank.
        elseif name == e.name then return true end
    end
    if restricted then return nil end
    return false
end
function U.TotemActive(e)
    local readable = true
    for i = 1, 4 do
        local ok, have, name = U.Call(GetTotemInfo, i)
        if not ok or U.Secret(have) or U.Secret(name) then readable = false
        elseif have and name == e.name then return true end
    end
    if readable then return false end
end

-- Returns true/false/nil or "display" plus a strictly visual descriptor.
function U.Condition(e, unit)
    if not U.Alive("player") or U.Public(UnitOnTaxi, "player") == true or U.Public(IsMounted) == true then return false, "Unavailable while dead, mounted or travelling" end
    if e.outOfCombat and InCombatLockdown() then return false, "Outside combat only" end
    if e.bandage then
        -- Both channel suppression and the debuff are explicit for First Aid.
        -- Unknown values cannot enable a protected out-of-combat button.
        for _, api in ipairs({"UnitCastingInfo", "UnitChannelInfo"}) do
            local ok, name = U.Call(_G[api], "player")
            if not ok or U.Secret(name) then return nil, "Current cast information restricted" end
            if name then return false, "Already casting or channeling" end
        end
        local recent = U.HasAura("player", {11196}, "HARMFUL")
        if recent == true then return false, "Recently Bandaged" end
        if recent == nil then return nil, "Bandage restriction unavailable" end
    end
    if e.petSpell and not U.Alive("pet") then return false, "No living pet" end
    if e.petSpell and C_SpellBook and U.Public(C_SpellBook.IsSpellKnown, e.spellID, 1) == false then return false, "This pet no longer knows the spell" end
    if e.noPet and U.Public(UnitExists, "pet") == true then return false, "Dismiss the current pet first" end
    if e.stealth and U.Public(IsStealthed) ~= true then return false, "Requires stealth" end
    if e.targetOutOfCombat and U.Public(UnitAffectingCombat, unit) ~= false then return false, "Target must be out of combat" end
    if e.targetedBuff then
        if unit ~= "target" or (U.Public(UnitIsPlayer, unit) ~= true
            and U.Public(UnitIsOtherPlayersPet, unit) ~= true and U.Public(UnitIsUnit, unit, "pet") ~= true) then
            return false, "Select a living friendly player or pet to buff"
        end
        if e.requiresMana and U.Public(UnitPowerMax, unit, 0) == 0 then return false, "This buff requires a mana user" end
        if e.playerOnly and U.Public(UnitIsPlayer, unit) ~= true then return false, "Select a friendly player" end
        if e.choiceBuffs and U.HasAura(unit, e.choiceBuffs, "HELPFUL", true) == true then
            return false, "Your blessing is already active; alternatives would replace it"
        end
    end
    if e.rule == "petmissing" then return U.Public(UnitExists, "pet") == false, "Call your pet" end
    if e.rule == "petdead" then return U.Public(UnitExists, "pet") == true and U.Public(UnitIsDead, "pet") == true, "Revive your pet" end
    if e.rule == "resurrect" then
        return U.Public(UnitExists, unit) == true and U.Public(UnitCanAssist, "player", unit) == true
            and U.Public(UnitIsPlayer, unit) == true and U.Public(UnitIsDead, unit) == true
            and U.Public(UnitIsGhost, unit) == false, "Resurrect selected ally"
    end
    if not U.Alive(unit) then return false, "No living recipient" end
    local hostile = e.rule == "interrupt" or e.rule == "purge" or e.rule == "creature" or e.rule == "control"
        or (e.rule == "manual" and (e.target == "target" or e.target == "focus"))
    if hostile and U.Public(UnitCanAttack, "player", unit) ~= true then return false, "Select an enemy" end
    if not hostile and unit ~= "player" and unit ~= "pet" and U.Public(UnitCanAssist, "player", unit) ~= true then return false, "Select an ally" end
    if e.types or e.excludeTypes then
        local eligible = U.CreatureEligible(e, unit)
        if eligible ~= true then return eligible, "Creature type unavailable or unsuitable" end
    end
    if e.missingAura and U.HasAura(unit, e.buffAuras or {e.id}, "HELPFUL") == true then return false, "Already active" end
    if e.missingDebuff and U.HasAura(unit, {e.id}, "HARMFUL") == true then return false, "Already affecting this target" end
    if e.blockedAuras then
        local blocked = U.HasAura(unit, e.blockedAuras, "HARMFUL")
        if blocked == true then return false, "Blocked by an existing debuff" end
        if blocked == nil then return nil, "Blocking debuff information restricted" end
    end
    if e.requiredAuras then
        local found = U.HasAura(unit, e.requiredAuras, "HELPFUL")
        if found ~= true then return found, "Requires the appropriate healing effect" end
    end
    if e.totem and U.TotemActive(e) == true then return false, "Totem already active" end
    local rule = e.rule
    if rule == "health" or rule == "defensive" or rule == "pethealth" or rule == "mana" then
        if rule == "defensive" and not InCombatLockdown() then return false, "Defensive for combat" end
        local mana, threshold = rule == "mana", U.db[rule == "defensive" and "health" or rule]
        if mana and (U.Public(UnitPowerMax, unit, 0) == 0) then return false, "Recipient has no mana" end
        local low = U.Low(unit, mana, threshold)
        local label = (mana and "Mana" or "Health") .. " at or below " .. threshold .. "%"
        if low ~= nil then return low, label end
        if C_CurveUtil and C_CurveUtil.CreateCurve and (mana and UnitPowerPercent or UnitHealthPercent) then
            return "display", label, {unit = unit, mana = mana, threshold = threshold}
        end
        return nil, "The game is not exposing the health or mana needed for this alert"
    end
    if rule == "interrupt" then
        local state, visual = U.Cast(unit)
        return state, e.stun and "Cast control: target must be susceptible to stun" or "Enemy interruptible cast", visual
    end
    if rule == "dispel" or rule == "purge" then return U.Dispellable(unit, e.dispels or {Magic = true}, rule == "purge"), "Removable effect" end
    if rule == "buff" then
        local active = U.HasAura(unit, e.buffAuras or {e.id}, "HELPFUL")
        if active == nil then return nil, "Buff information restricted" end
        return not active, "Missing buff"
    end
    if rule == "falling" then return U.Public(IsFalling), "Falling: prevent fall damage" end
    if rule == "swimming" then return U.Public(IsSwimming), "Swimming: underwater utility" end
    if rule == "combat" then return InCombatLockdown() and U.Alive("target") and U.Public(UnitCanAttack, "player", "target") == true, "Combat utility; choose timing yourself" end
    if rule == "manual" then return false, "Manual utility: choose timing yourself" end
    return true, "Suitable target type; immunity and diminishing returns are not guaranteed"
end

function U.CaptureCooldownEvent()
    -- isOnGCD is public, but the client only guarantees it inside this event.
    -- Snapshot only our current spells; polling must not reread that field.
    local flags, seen = {}, {}
    for _, e in ipairs(U.entries or {}) do
        local id = e.spellID
        if id and not seen[id] then
            seen[id] = true
            local cd = U.Public(C_Spell.GetSpellCooldown, id)
            if cd and not U.Secret(cd.isOnGCD) and type(cd.isOnGCD) == "boolean" then
                flags[id] = cd.isOnGCD
            end
        end
    end
    U.gcdOnly = flags
end
function U.Readiness(e, unit)
    if e.items then
        if not e.itemID or U.ItemCount(e.itemID) == 0 then return false, "No selected item in bags; selection refreshes after combat" end
        local usable = U.Public(C_Item.IsUsableItem, e.itemID)
        if usable == false then return false, "Item unusable" end
        if e.bandage and usable ~= true then return nil, "Bandage usability unavailable" end
        local ok, start, duration, enabled = U.Call(C_Item.GetItemCooldown, e.itemID)
        if not ok or U.Secret(start) or U.Secret(duration) or U.Secret(enabled) then return nil, "Check item cooldown" end
        if enabled == false or enabled == 0 then return false, "Item unavailable" end
        return duration == 0 or start + duration <= GetTime(), "Item cooldown"
    end
    local casting = U.CastingEntry(e)
    if casting == true then return false, "Already casting or channeling this ability" end
    if casting == nil then return nil, "Current cast information restricted" end
    local usable
    if e.petSpell and e.slot and C_SpellBook.IsSpellBookItemUsable then
        usable = U.Public(C_SpellBook.IsSpellBookItemUsable, e.slot, e.bank)
    else usable = U.Public(C_Spell.IsSpellUsable, e.spellID) end
    if usable == false then return false, "Not usable: check resources, form, equipment or reagents" end
    local rangeUnit = e.selfCast and "player" or unit
    if rangeUnit ~= "player" then
        local range
        if e.petSpell and e.slot and C_SpellBook.IsSpellBookItemInRange then
            range = U.Public(C_SpellBook.IsSpellBookItemInRange, e.slot, e.bank, rangeUnit)
        else range = U.Public(C_Spell.IsSpellInRange, e.spellID, rangeUnit) end
        if range == false then return false, "Out of range" end
    end
    local cd = U.Public(C_Spell.GetSpellCooldown, e.spellID)
    if not cd then return nil, "Cooldown information unavailable" end
    -- Forever documents isEnabled/isActive as NeverSecret. Numeric timers can
    -- still be secret even when ready; do not discard the public readiness flag.
    if not U.Secret(cd.isEnabled) and cd.isEnabled == false then return false, "Spell unavailable" end
    if not U.Secret(cd.isEnabled) and cd.isEnabled == true and U.gcdOnly[e.spellID] == true then
        return usable, "Global cooldown only; utility remains relevant"
    end
    if not U.Secret(cd.isEnabled) and cd.isEnabled == true and not U.Secret(cd.isActive)
        and type(cd.isActive) == "boolean" then
        if cd.isActive then return false, "On cooldown" end
        return usable, "Ready"
    end
    -- Compatibility fallback for clients without the public active flag.
    if U.Secret(cd.startTime) or U.Secret(cd.duration) or U.Secret(cd.isEnabled)
        or type(cd.startTime) ~= "number" or type(cd.duration) ~= "number" then return nil, "Check displayed cooldown" end
    if cd.duration == 0 or cd.startTime + cd.duration <= GetTime() then return usable, "Ready" end
    return false, "On cooldown"
end
function U.Evaluate(e)
    local unit = U.UnitFor(e)
    local condition, reason, visual = U.Condition(e, unit)
    if condition == false then return "idle", reason, unit end
    local ready, readyReason = U.Readiness(e, unit)
    if ready == false then return "idle", readyReason, unit end
    if condition == nil then return "unknown", "Situation data restricted; use this button manually", unit end
    if ready == nil then return "unknown", readyReason .. "; readiness is not confirmed", unit end
    return condition == "display" and "display" or "active", reason, unit, visual
end

function U.MakeCurve(threshold, low, high)
    if not C_CurveUtil or not C_CurveUtil.CreateCurve then return end
    local curve = C_CurveUtil.CreateCurve()
    curve:SetType(Enum.LuaCurveType.Step)
    curve:AddPoint(0, low)
    curve:AddPoint(threshold / 100, low)
    curve:AddPoint(threshold / 100 + 0.000001, high)
    curve:AddPoint(1, high)
    return curve
end
function U.VisualValue(visual, curve, low, high)
    if U.Secret(visual.boolean) or visual.boolean ~= nil then
        return U.Call(C_CurveUtil and C_CurveUtil.EvaluateColorValueFromBoolean, visual.boolean, high, low)
    elseif visual.mana then return U.Call(UnitPowerPercent, visual.unit, 0, false, curve)
    else return U.Call(UnitHealthPercent, visual.unit, false, curve) end
end
