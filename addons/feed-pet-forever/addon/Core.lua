local _, F = ...
F.VERSION = "1.0.2"
F.FEED_SPELL = 6991
F.FEED_EFFECT = 1539
F.DEFAULT_SIZE = 64
F.MIN_SIZE, F.MAX_SIZE = 24, 160

local function public(value)
    return not issecretvalue or not issecretvalue(value)
end
F.IsPublic = public

function F.Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffffcc66Feed Pet: Forever:|r " .. message)
end

function F.LoadSettings()
    if type(FeedPetForeverDB) ~= "table" then FeedPetForeverDB = {} end
    F.db = FeedPetForeverDB
    local db = F.db
    local function finite(n) return type(n) == "number" and n == n and math.abs(n) < 100000 end
    db.size = finite(db.size) and math.max(F.MIN_SIZE, math.min(F.MAX_SIZE, db.size)) or F.DEFAULT_SIZE
    db.x, db.y = finite(db.x) and db.x or 0, finite(db.y) and db.y or 0
    if type(db.showNoFood) ~= "boolean" then db.showNoFood = true end
    if type(db.flash) ~= "boolean" then db.flash = true end
    db.minimapAngle = finite(db.minimapAngle) and db.minimapAngle % 360 or 225
    if type(db.minimapHidden) ~= "boolean" then db.minimapHidden = false end
    F.unlocked = false -- Layout mode never survives a reload.
    F.bagsDirty = true
end

function F.CheckAPIs()
    if not (C_PetInfo and C_PetInfo.CanPetEatItem and C_PetInfo.GetPetHappiness
        and C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerNumSlots
        and C_Item and C_Item.GetItemInfo and C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellName
        and C_SpellBook and C_SpellBook.IsSpellKnown
        and C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName) then
        return false
    end
    return true
end

-- Check lockdown FIRST. Forever can return restricted information in combat.
-- The secure visibility driver handles hiding without insecure frame writes.
function F.GetState()
    if InCombatLockdown() then return "hidden", "Combat" end
    if not F.supported then return "hidden", "Required Forever APIs unavailable" end
    local _, class = UnitClass("player")
    if class ~= "HUNTER" then return "hidden", "Hunter only" end
    if UnitIsDeadOrGhost("player") then return "hidden", "You are dead or a ghost" end
    if UnitOnTaxi("player") then return "hidden", "Flight path" end
    if IsMounted() then return "hidden", "Mounted" end
    if UnitInVehicle and UnitInVehicle("player") then return "hidden", "In a vehicle" end
    if not UnitExists("pet") then return "hidden", "No pet" end
    if UnitIsDeadOrGhost("pet") then return "hidden", "Pet is dead" end
    local _, hunterPet = HasPetUI()
    if not hunterPet then return "hidden", "No hunter pet" end
    local playerCombat, petCombat = UnitAffectingCombat("player"), UnitAffectingCombat("pet")
    if not public(playerCombat) or not public(petCombat) or playerCombat or petCombat then
        return "hidden", "You or your pet are in combat"
    end
    if not C_SpellBook.IsSpellKnown(F.FEED_SPELL) then return "hidden", "Learn Feed Pet first" end
    local happiness = C_PetInfo.GetPetHappiness()
    if not public(happiness) then return "hidden", "Pet happiness unavailable" end
    if happiness ~= 1 and happiness ~= 2 then
        return "hidden", happiness == 3 and "Pet is happy" or "Pet happiness unavailable"
    end
    local effectName = C_Spell.GetSpellName(F.FEED_EFFECT)
    if effectName then
        local aura = C_UnitAuras.GetAuraDataBySpellName("pet", effectName, "HELPFUL")
        if not public(aura) then return "hidden", "Feeding status unavailable" end
        if aura then return "hidden", "Pet is already being fed" end
    end
    if GetTime() < (F.waitUntil or 0) then return "hidden", "Waiting for feeding response" end
    if C_Spell.GetSpellCooldown then
        local cooldown = C_Spell.GetSpellCooldown(F.FEED_SPELL)
        if cooldown then
            if not public(cooldown.startTime) or not public(cooldown.duration) then
                return "hidden", "Spell cooldown unavailable"
            end
            if cooldown.startTime and cooldown.duration and cooldown.duration > 0
                and cooldown.startTime + cooldown.duration > GetTime() then
                return "hidden", "Feed Pet is on cooldown"
            end
        end
    end
    return "hungry", happiness == 1 and "Unhappy" or "Content"
end

-- Use the client's native diet/eligibility check; no English tooltip parsing
-- or incomplete item-ID whitelist. Only carried bags are scanned, never banks.
function F.FindFood()
    local best, count, pending, locked = nil, 0, false, false
    for bag = 0, (NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4) do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item and public(item.itemID) and item.itemID and item.stackCount > 0 then
                local name, link, quality, level = C_Item.GetItemInfo(item.itemID)
                if not name then
                    pending = true -- GetItemInfo requests uncached data; retry on its event.
                elseif C_PetInfo.CanPetEatItem(item.itemID) then
                    if item.isLocked then
                        locked = true
                    else
                        count = count + item.stackCount
                        local food = {bag = bag, slot = slot, id = item.itemID, name = name,
                            link = link, level = level or 0, count = item.stackCount}
                        -- Higher-level food first, then finish a smaller stack.
                        if not best or food.level > best.level
                            or (food.level == best.level and food.count < best.count) then
                            best = food
                        end
                    end
                end
            end
        end
    end
    F.food, F.foodCount = best, count
    F.pendingItems, F.lockedFood, F.bagsDirty = pending, locked, false
    return best
end

function F.Disarm()
    if not F.button or InCombatLockdown() then return end
    F.button:SetAttribute("type1", nil)
    F.button:SetAttribute("spell1", nil)
    F.button:SetAttribute("target-bag1", nil)
    F.button:SetAttribute("target-slot1", nil)
end

function F.Refresh(forceScan)
    if not F.button or InCombatLockdown() or F.clickInProgress then return end
    local state, reason = F.GetState()
    F.reason = reason
    F.Disarm()
    if F.unlocked then
        F.Render(F.previewNoFood and "preview-nofood" or "preview")
        return
    end
    if state ~= "hungry" then F.Render("hidden"); return end
    if forceScan or F.bagsDirty then F.FindFood() end
    if F.food then
        local b = F.button
        b:SetAttribute("spell1", F.FEED_SPELL)
        b:SetAttribute("target-bag1", F.food.bag)
        b:SetAttribute("target-slot1", F.food.slot)
        b:SetAttribute("type1", "spell")
        F.Render("food")
    elseif F.pendingItems or F.lockedFood then
        -- Loading or temporarily locked items are not evidence of having no food.
        F.Render("hidden")
    else
        F.Render(F.db.showNoFood and "nofood" or "hidden")
    end
end

function F.PreClick(_, mouseButton)
    if InCombatLockdown() then return end
    -- Re-read the bags immediately before the protected click. A bag sort, trade,
    -- sold stack or different pet must never leave the old slot armed.
    F.Refresh(true)
    if mouseButton ~= "LeftButton" or IsShiftKeyDown() or F.dragging
        or GetTime() < (F.dragStoppedAt or -1) + 0.2
        or (SpellIsTargeting and SpellIsTargeting())
        or (GetCursorInfo and GetCursorInfo()) then
        F.Disarm()
    end
    -- Synchronous spell/bag events can run inside the protected click. Keep its
    -- item-target attributes intact until Blizzard finishes the whole action.
    F.clickInProgress = true
end

function F.PostClick(_, mouseButton)
    F.clickInProgress = false
    if InCombatLockdown() then return end
    F.Refresh()
    if mouseButton == "RightButton" then F.ToggleOptions() end
end

function F.SetLayout(enabled, noFood)
    if InCombatLockdown() then F.Print("Wait until combat ends to adjust the icon."); return end
    F.unlocked, F.previewNoFood = enabled, noFood
    F.Refresh(true)
end

function F.SetSize(size)
    if InCombatLockdown() then return end
    F.db.size = math.floor(math.max(F.MIN_SIZE, math.min(F.MAX_SIZE, size)) + 0.5)
    F.ApplyLayout()
end

function F.Command(message)
    local cmd, arg = (message or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = cmd:lower()
    if InCombatLockdown() then F.Print("Wait until combat ends to change settings."); return end
    if cmd == "unlock" or cmd == "test" then
        F.SetLayout(true, arg == "nofood")
        F.Print("Layout preview: drag to move; mouse wheel to resize. /fpf lock when finished.")
    elseif cmd == "lock" then F.SetLayout(false); F.Print("Icon locked; normal alerts restored.")
    elseif cmd == "size" and tonumber(arg) then F.SetSize(tonumber(arg))
    elseif cmd == "reset" then
        F.db.x, F.db.y, F.db.size = 0, 0, F.DEFAULT_SIZE
        F.ApplyLayout(); F.Refresh()
        F.Print("Icon centred and size reset to 64.")
    elseif cmd == "nofood" and (arg == "on" or arg == "off") then
        F.db.showNoFood = arg == "on"; F.Refresh()
    elseif cmd == "flash" and (arg == "on" or arg == "off") then
        F.db.flash = arg == "on"; F.Refresh()
    elseif cmd == "minimap" and (arg == "on" or arg == "off") then
        F.db.minimapHidden = arg == "off"; F.UpdateMinimap(true)
    elseif cmd == "status" then
        F.Refresh(true)
        local version, build, _, interface = GetBuildInfo()
        F.Print(F.VERSION .. "; client " .. version .. " (" .. build .. "), interface " .. interface)
        F.Print("State: " .. (F.mode or "hidden") .. "; " .. (F.reason or "Waiting"))
        if F.food then F.Print("Selected: " .. F.food.name .. "; bag " .. F.food.bag .. ", slot " .. F.food.slot) end
    elseif cmd == "" or cmd == "options" then F.ToggleOptions()
    else
        F.Print("/fpf opens settings. Commands: unlock, lock, size 24-160, reset, test nofood, nofood on/off, flash on/off, minimap on/off, status.")
    end
end
