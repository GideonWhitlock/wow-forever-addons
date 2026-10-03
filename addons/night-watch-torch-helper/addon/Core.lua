local _, N = ...

N.ITEM_ID = 280612
N.BUFF_ID = 1309410
N.BUFF_IDS = { 1309410, 1321139 } -- Holding torch and its illumination aura.
N.STILL_DELAY = 0.75
N.DEFAULTS = { enabled = true, x = 0, y = -150, size = 52, minimapAngle = 160, minimapHidden = false }

local function readable(value)
    return not (issecretvalue and issecretvalue(value))
end

function N.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffc75fNight Watch Torch:|r " .. message)
end

function N.InitializeDB()
    if type(NightWatchTorchDB) ~= "table" then NightWatchTorchDB = {} end
    N.db = NightWatchTorchDB
    for key, value in pairs(N.DEFAULTS) do
        if type(N.db[key]) ~= type(value) then N.db[key] = value end
    end
    N.db.size = math.max(32, math.min(100, N.db.size))
    N.bagsDirty = true
end

function N.FindTorch(force)
    local C = C_Container
    if not (C and C.GetContainerNumSlots and C.GetContainerItemID) then
        return nil, "Bag information unavailable"
    end
    if not force and not N.bagsDirty and N.bag ~= nil then
        if C.GetContainerItemID(N.bag, N.slot) == N.ITEM_ID then
            return N.bag, N.slot
        end
    elseif not force and not N.bagsDirty then
        return nil, "Torch is not in your bags"
    end
    N.bag, N.slot, N.bagsDirty = nil, nil, false
    local bags = { 0, 1, 2, 3, 4 }
    local reagentBag = Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag
    if reagentBag and reagentBag > 4 then bags[#bags + 1] = reagentBag end
    -- Scan carried bags only. Bank, account-bank and equipped slots never count.
    for _, bag in ipairs(bags) do
        for slot = 1, C.GetContainerNumSlots(bag) do
            if C.GetContainerItemID(bag, slot) == N.ITEM_ID then
                N.bag, N.slot = bag, slot
                return bag, slot
            end
        end
    end
    return nil, "Torch is not in your bags"
end

function N.EnvironmentReason()
    if N.dimArea then return "Dim area (manual)" end
    if C_DateAndTime and C_DateAndTime.IsDayTime then
        local day = C_DateAndTime.IsDayTime()
        if readable(day) and day == false then return "Night-time" end
    end
    if C_Weather and C_Weather.GetCurrentWeather then
        local info = C_Weather.GetCurrentWeather()
        if info and readable(info.type) and readable(info.intensity)
            and type(info.type) == "number" and type(info.intensity) == "number"
            and info.type ~= 0 and info.intensity > 0 then
            local names = { [1] = "Rain", [2] = "Snow", [3] = "Sandstorm", [4] = "Other weather" }
            return names[info.type] or "Bad weather"
        end
    end
    return nil
end

function N.HasTorchBuff()
    N.lastBuffID = nil
    local A = C_UnitAuras
    if not A then return nil end
    if A.GetPlayerAuraBySpellID then
        for _, spellID in ipairs(N.BUFF_IDS) do
            local aura = A.GetPlayerAuraBySpellID(spellID)
            if not readable(aura) then return nil end
            if aura then N.lastBuffID = spellID; return true end
        end
    end

    -- Beta item spells and the aura they apply can have different IDs. Match
    -- the actual helpful aura as well, regardless of who supplied the light.
    local names = { ["Night Watchman's Torch"] = true }
    local function addName(name)
        if readable(name) and type(name) == "string" and name ~= "" then names[name] = true end
    end
    if C_Item and C_Item.GetItemNameByID then addName(C_Item.GetItemNameByID(N.ITEM_ID)) end
    if C_Item and C_Item.GetItemSpell then addName(C_Item.GetItemSpell(N.ITEM_ID)) end
    if C_Spell and C_Spell.GetSpellName then
        for _, spellID in ipairs(N.BUFF_IDS) do addName(C_Spell.GetSpellName(spellID)) end
    end
    if A.GetAuraDataByIndex then
        local unknown = false
        for index = 1, 255 do
            local aura = A.GetAuraDataByIndex("player", index, "HELPFUL")
            if not readable(aura) then return nil end
            if not aura then
                if unknown then return nil end
                return false
            end
            local idReadable, nameReadable = readable(aura.spellId), readable(aura.name)
            if (idReadable and (aura.spellId == 1309410 or aura.spellId == 1321139))
                or (nameReadable and aura.name and names[aura.name]) then
                N.lastBuffID = idReadable and aura.spellId or nil
                return true
            end
            if not idReadable or not nameReadable then unknown = true end
        end
        return nil -- An incomplete scan must never be treated as no buff.
    end
    if A.GetAuraDataBySpellName then
        for name in pairs(names) do
            local aura = A.GetAuraDataBySpellName("player", name, "HELPFUL")
            if not readable(aura) then return nil end
            if aura then return true end
        end
        return false
    end
    return nil
end

local function evaluate(forceBags)
    if not N.db or not N.db.enabled then return false, "Disabled" end
    if N.preview then return false, "Layout preview" end
    if N.dragging then return false, "Moving the button" end
    if N.worldReady == false then N.stillSince = nil; return false, "Loading" end
    -- Stop before reading restricted movement or aura data during combat.
    if InCombatLockdown() or UnitAffectingCombat("player") then
        N.stillSince = nil
        return false, "In combat"
    end
    if UnitIsDeadOrGhost("player") then N.stillSince = nil; return false, "Dead or ghost" end
    if UnitOnTaxi("player") then N.stillSince = nil; return false, "On a flight path" end
    if IsMounted() then N.stillSince = nil; return false, "Mounted" end
    if IsFlying() then N.stillSince = nil; return false, "Flying" end
    if UnitInVehicle and UnitInVehicle("player") then N.stillSince = nil; return false, "In a vehicle" end
    if IsFalling() or IsSwimming() then N.stillSince = nil; return false, "Jumping, falling or swimming" end
    local speed = GetUnitSpeed("player")
    if not readable(speed) or type(speed) ~= "number" then
        N.stillSince = nil
        return false, "Movement information unavailable"
    end
    if speed > 0 or N.movementActive then N.stillSince = nil; return false, "Moving" end
    local now = GetTime()
    N.stillSince = N.stillSince or now
    if now - N.stillSince < N.STILL_DELAY then return false, "Waiting for you to stop" end
    if UnitCastingInfo("player") or UnitChannelInfo("player") then return false, "Casting or channeling" end
    if now < (N.retryAfter or 0) then return false, "Waiting for torch use" end
    if MerchantFrame and MerchantFrame:IsShown() then return false, "Merchant window open" end

    local bag, slot = N.FindTorch(forceBags)
    if bag == nil then return false, slot end
    local hasBuff = N.HasTorchBuff()
    if hasBuff == nil then return false, "Buff information unavailable" end
    if hasBuff then return false, "Torch buff already active" end

    local reason = N.EnvironmentReason()
    if not reason then return false, "No reported darkness or bad weather" end
    local item = C_Container.GetContainerItemInfo(bag, slot)
    if not item or item.itemID ~= N.ITEM_ID then N.bagsDirty = true; return false, "Bag contents updating" end
    if item.isLocked then return false, "Torch is locked" end
    local start, duration, enabled = C_Container.GetContainerItemCooldown(bag, slot)
    if not readable(start) or not readable(duration) or not readable(enabled)
        or type(start) ~= "number" or type(duration) ~= "number"
        or (enabled ~= 1 and enabled ~= true) then
        return false, "Torch is not ready"
    end
    if duration > 0 and start + duration > now then return false, "Torch is on cooldown" end
    return true, reason
end

function N.Evaluate(forceBags)
    local ok, ready, reason = pcall(evaluate, forceBags)
    if not ok then
        N.lastError = tostring(ready)
        return false, "Game information unavailable; /nwt status for details"
    end
    N.lastError = nil
    return ready, reason
end
