local ADDON_NAME, NS = ...

NS.name = ADDON_NAME
NS.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "dev"
NS.interface = select(4, GetBuildInfo())
NS.rows = {}
NS.findings = {}
NS.staged = {}

local defaults = {
    schema = 1,
    minimap = { angle = 220, hidden = false },
    window = { x = 0, y = 0 },
    snapshots = {},
    lastScan = 0,
    stagedOriginal = {},
}

local function copyDefaults(source, destination)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(destination[key]) ~= "table" then destination[key] = {} end
            copyDefaults(value, destination[key])
        elseif destination[key] == nil then
            destination[key] = value
        end
    end
end

function NS:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffd8b45aAddon Health:|r " .. tostring(message))
end

function NS:InitializeDatabase()
    if type(AddonHealthManagerForeverDB) ~= "table" then
        AddonHealthManagerForeverDB = {}
    end
    copyDefaults(defaults, AddonHealthManagerForeverDB)
    self.db = AddonHealthManagerForeverDB
end

function NS:SaveWindowPosition()
    if not self.frame then return end
    local cx, cy = self.frame:GetCenter()
    local ux, uy = UIParent:GetCenter()
    if cx and ux then
        self.db.window.x = math.floor(cx - ux + 0.5)
        self.db.window.y = math.floor(cy - uy + 0.5)
    end
end

function NS:ResetSettings()
    AddonHealthManagerForeverDB = nil
    self:InitializeDatabase()
    if self.frame then
        self.frame:ClearAllPoints()
        self.frame:SetPoint("CENTER")
    end
    if self.UpdateMinimapPosition then self:UpdateMinimapPosition() end
    self:Scan()
    self:Print("Settings, history, and staged recovery changes were reset.")
end

function NS:Toggle()
    if not self.frame then self:CreateUI() end
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
        self:Scan()
    end
end

function NS:GetCharacterScope()
    -- The GUID is used transiently to match Blizzard's in-game per-character
    -- AddOn List. It is never stored or included in a report.
    return UnitGUID and UnitGUID("player") or nil
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("ADDON_ACTION_FORBIDDEN")
events:RegisterEvent("LUA_WARNING")
events:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" and ... == ADDON_NAME then
        NS:InitializeDatabase()
        NS:RegisterSlashCommands()
        NS:CreateMinimapButton()
    elseif event == "PLAYER_LOGIN" then
        NS:Scan()
    elseif event == "ADDON_ACTION_FORBIDDEN" then
        local culprit = ...
        NS.sessionBlockedActions = NS.sessionBlockedActions or {}
        NS.sessionBlockedActions[culprit or "Unknown"] = (NS.sessionBlockedActions[culprit or "Unknown"] or 0) + 1
    elseif event == "LUA_WARNING" and NS.RecordLuaWarning then
        NS:RecordLuaWarning(...)
    end
end)

function NS:RegisterSlashCommands()
    SLASH_ADDONHEALTHMANAGERFOREVER1 = "/ahm"
    SLASH_ADDONHEALTHMANAGERFOREVER2 = "/addonhealth"
    SlashCmdList.ADDONHEALTHMANAGERFOREVER = function(input)
        local command = strlower(strtrim(input or ""))
        if command == "scan" then
            self:Scan()
            self:Print("Scan complete.")
        elseif command == "report" then
            self:ShowReport()
        elseif command == "show" then
            self.db.minimap.hidden = false
            if self.minimapButton then self.minimapButton:Show() end
        elseif command == "hide" then
            self.db.minimap.hidden = true
            if self.minimapButton then self.minimapButton:Hide() end
        elseif command == "undo" then
            self:UndoStagedChanges()
        elseif command == "reset" then
            self:ResetSettings()
        elseif command == "help" then
            self:Print("/ahm — open; scan; report; show; hide; undo; reset")
        else
            self:Toggle()
        end
    end
end
