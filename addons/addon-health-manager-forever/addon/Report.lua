local ADDON_NAME, NS = ...

local function clean(value)
    value = tostring(value or "")
    value = value:gsub("[\r\n\t]+", " "):gsub("%s+", " ")
    value = value:gsub("[Cc]:\\[Uu]sers\\[^\\]+", "<user-folder>")
    value = value:gsub("/[Hh]ome/[^/]+", "/home/<user>")
    return strtrim(value)
end

local function bool(value) return value and "yes" or "no" end

function NS:BuildReport()
    local version, build, buildDate, interface = GetBuildInfo()
    local counts = self:GetCounts()
    local lines = {
        "Addon Health Manager: Forever diagnostic report",
        "Generated: " .. date("%Y-%m-%d %H:%M:%S"),
        "Manager: " .. self.version,
        string.format("Client: %s build %s / interface %s", clean(version), clean(build), clean(interface)),
        string.format("Inventory: %d installed, %d loaded, %d disabled", counts.total, counts.loaded, counts.disabled),
        string.format("Findings: %d attention, %d review, %d informational", counts.error, counts.warning, counts.info),
        "",
        "Privacy: character, realm, account, chat, guild, coordinates, and SavedVariables are intentionally omitted.",
        "Interpretation: overlap and path attribution are clues, not verified root-cause diagnoses.",
        "",
        "SESSION ERROR VISIBILITY",
    }

    local evidence = self.errorEvidence or { visibility = "unavailable", errors = 0, warnings = 0 }
    if evidence.visibility == "available" then
        lines[#lines + 1] = string.format("- Available: %d Lua error and %d Lua/XML warning occurrence(s) visible in Blizzard's current-session list.", evidence.errors or 0, evidence.warnings or 0)
    elseif evidence.visibility == "partial" then
        lines[#lines + 1] = "- Limited: Blizzard's full list was unavailable; only warnings observed after Addon Health Manager loaded were checked."
    else
        lines[#lines + 1] = "- Unavailable: Lua errors and warnings could not be checked. This report does not claim a clean error scan."
    end
    for _, finding in ipairs(self.globalFindings or {}) do lines[#lines + 1] = "- " .. clean(finding.text) end
    lines[#lines + 1] = ""
    lines[#lines + 1] = "ADD-ON FINDINGS"

    local included = 0
    for _, row in ipairs(self.rows) do
        if row.severity ~= "healthy" then
            included = included + 1
            lines[#lines + 1] = string.format("- [%s] %s (%s), version %s", strupper(row.severity), clean(row.title), clean(row.name), clean(row.version))
            lines[#lines + 1] = string.format("  enabled=%s loaded=%s loadable=%s interface=%s", bool(row.enabled), bool(row.loaded), bool(row.loadable), clean(row.interfaceVersion))
            if row.partOf ~= "" then lines[#lines + 1] = "  declared module of: " .. clean(row.partOf) end
            for _, finding in ipairs(row.findings) do
                lines[#lines + 1] = "  • " .. clean(finding.text)
            end
            if row.loaded and row.recentMs then
                lines[#lines + 1] = string.format("  profiler: recent %.3f ms, session %.3f ms, peak %.3f ms, memory %.1f KB", row.recentMs or 0, row.sessionMs or 0, row.peakMs or 0, row.memoryKB or 0)
            end
        end
    end
    if included == 0 and #(self.globalFindings or {}) == 0 then lines[#lines + 1] = "- No definite problem found in the data WoW exposes." end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "LOADED ADD-ONS"
    local loaded = {}
    for _, row in ipairs(self.rows) do
        if row.loaded then loaded[#loaded + 1] = clean(row.name) .. "@" .. clean(row.version) end
    end
    table.sort(loaded)
    lines[#lines + 1] = table.concat(loaded, ", ")
    lines[#lines + 1] = ""
    lines[#lines + 1] = "NOT DETERMINABLE BY WOW"
    lines[#lines + 1] = "- Which add-on is the true root cause of a Lua error"
    lines[#lines + 1] = "- Whether two add-ons genuinely conflict"
    lines[#lines + 1] = "- Installation/update time before this manager's first scan"
    lines[#lines + 1] = "- Whether disabling an add-on will repair the issue without a controlled retest"
    return table.concat(lines, "\n")
end

function NS:ShowReport()
    if not self.frame then self:CreateUI() end
    self.frame:Show()
    self:SelectTab("report")
end

function NS:StageToggle(row)
    if not row or row.name == ADDON_NAME then
        self:Print("Addon Health cannot stage disabling itself.")
        return
    end
    if self.db.stagedOriginal[row.name] == nil then
        self.db.stagedOriginal[row.name] = row.enabled
    end
    if row.enabled then
        C_AddOns.DisableAddOn(row.name, self:GetCharacterScope())
        self:Print(row.title .. " will be disabled after reload. Use /ahm undo to reverse it.")
    else
        C_AddOns.EnableAddOn(row.name, self:GetCharacterScope())
        self:Print(row.title .. " will be enabled after reload. Use /ahm undo to reverse it.")
    end
    C_AddOns.SaveAddOns()
    self:Scan()
end

function NS:UndoStagedChanges()
    local changed = 0
    for name, wasEnabled in pairs(self.db.stagedOriginal) do
        if C_AddOns.DoesAddOnExist(name) then
            if wasEnabled then C_AddOns.EnableAddOn(name, self:GetCharacterScope()) else C_AddOns.DisableAddOn(name, self:GetCharacterScope()) end
            changed = changed + 1
        end
    end
    wipe(self.db.stagedOriginal)
    C_AddOns.SaveAddOns()
    self:Scan()
    self:Print(changed > 0 and ("Reversed " .. changed .. " staged change(s). Reload to apply.") or "There were no staged changes to undo.")
end
