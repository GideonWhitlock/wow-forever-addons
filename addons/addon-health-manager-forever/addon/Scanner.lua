local ADDON_NAME, NS = ...

local SEVERITY = { healthy = 1, info = 2, warning = 3, error = 4 }

local reasonText = {
    DISABLED = "Disabled for this character",
    MISSING = "A required dependency is missing",
    DEP_MISSING = "A required dependency is missing",
    DEP_DISABLED = "A required dependency is disabled",
    INTERFACE_VERSION = "Built for a different interface version",
    INCOMPATIBLE = "Marked incompatible by the client",
    CORRUPT = "Files appear incomplete or unreadable",
    BANNED = "Blocked by the client",
    DEMAND_LOADED = "Loads only when another feature requests it",
}

local overlapTerms = {
    { label = "bags", words = { "bag", "inventory" } },
    { label = "unit frames", words = { "unit frame", "raid frame", "party frame" } },
    { label = "nameplates", words = { "nameplate" } },
    { label = "action bars", words = { "action bar", "actionbar" } },
    { label = "minimap", words = { "minimap" } },
    { label = "quest guidance", words = { "quest", "leveling guide" } },
    { label = "tooltips", words = { "tooltip" } },
    { label = "damage meters", words = { "damage meter", "combat meter" } },
}

local function enabledState(name)
    local state = C_AddOns.GetAddOnEnableState(name, NS:GetCharacterScope())
    return state and state > 0, state
end

local function listDependencies(name, optional)
    local values
    if optional then
        values = { C_AddOns.GetAddOnOptionalDependencies(name) }
    else
        values = { C_AddOns.GetAddOnDependencies(name) }
    end
    local result = {}
    for _, dep in ipairs(values) do
        if dep and dep ~= "" then result[#result + 1] = dep end
    end
    return result
end

local function profilerMetric(name, metric)
    if not C_AddOnProfiler or not C_AddOnProfiler.IsEnabled or not C_AddOnProfiler.IsEnabled() then return nil end
    local ok, value = pcall(C_AddOnProfiler.GetAddOnMetric, name, metric)
    if ok then return value end
end

local function detectArea(title, notes, category)
    local haystack = strlower(table.concat({ title or "", notes or "", category or "" }, " "))
    for _, group in ipairs(overlapTerms) do
        for _, word in ipairs(group.words) do
            if string.find(haystack, word, 1, true) then return group.label end
        end
    end
end

local function addFinding(row, severity, code, text, evidence)
    row.findings[#row.findings + 1] = {
        severity = severity,
        code = code,
        text = text,
        evidence = evidence,
    }
    if SEVERITY[severity] > SEVERITY[row.severity] then row.severity = severity end
end

local function findAddonInText(text, rowsByName)
    local lower = strlower(text or "")
    local best
    for name in pairs(rowsByName) do
        local token = strlower(name)
        if string.find(lower, "addons\\" .. token .. "\\", 1, true)
            or string.find(lower, "addons/" .. token .. "/", 1, true) then
            if not best or #name > #best then best = name end
        end
    end
    return best
end

function NS:RecordLuaWarning(message)
    if message == nil or (issecretvalue and issecretvalue(message)) then return end
    local names = self.rowsByName or {}
    if not next(names) then
        for index = 1, C_AddOns.GetNumAddOns() do
            local name = C_AddOns.GetAddOnName(index)
            if name then names[name] = true end
        end
    end
    self.liveWarningEvidence = self.liveWarningEvidence or { total = 0, unattributed = 0, attributed = {} }
    local evidence = self.liveWarningEvidence
    evidence.total = evidence.total + 1
    local name = findAddonInText(tostring(message), names)
    if name then
        evidence.attributed[name] = (evidence.attributed[name] or 0) + 1
    else
        evidence.unattributed = evidence.unattributed + 1
    end
end

function NS:CollectErrors(rowsByName)
    local result = {
        available = false,
        visibility = "unavailable",
        total = 0,
        errors = 0,
        warnings = 0,
        unattributed = 0,
        secretSkipped = 0,
        attributed = {},
    }
    if not ScriptErrorsFrame or type(ScriptErrorsFrame.GetCount) ~= "function" or type(ScriptErrorsFrame.GetErrorData) ~= "function" then
        local live = self.liveWarningEvidence
        if live and live.total > 0 then
            result.visibility = "partial"
            result.total = live.total
            result.warnings = live.total
            result.unattributed = live.unattributed
            for name, occurrences in pairs(live.attributed) do
                result.attributed[name] = { count = occurrences, distinct = occurrences, errors = 0, warnings = occurrences }
            end
        end
        return result
    end
    local countOK, count = pcall(ScriptErrorsFrame.GetCount, ScriptErrorsFrame)
    if not countOK then return result end
    result.available = true
    result.visibility = "available"
    count = count or 0
    for index = 1, count do
        local dataOK, data = pcall(ScriptErrorsFrame.GetErrorData, ScriptErrorsFrame, index)
        if dataOK and data and (data.messageType == 0 or data.messageType == 1) then
            local occurrences = tonumber(data.count) or 1
            local message, stack = data.message or "", data.stack or ""
            local secret = issecretvalue and (issecretvalue(message) or issecretvalue(stack))
            if secret then
                result.secretSkipped = result.secretSkipped + occurrences
            else
                local text = tostring(message) .. "\n" .. tostring(stack)
                local best = findAddonInText(text, rowsByName)
                result.total = result.total + occurrences
                if data.messageType == 0 then result.errors = result.errors + occurrences else result.warnings = result.warnings + occurrences end
                if best then
                    local entry = result.attributed[best] or { count = 0, distinct = 0, errors = 0, warnings = 0 }
                    entry.count = entry.count + occurrences
                    entry.distinct = entry.distinct + 1
                    if data.messageType == 0 then entry.errors = entry.errors + occurrences else entry.warnings = entry.warnings + occurrences end
                    result.attributed[best] = entry
                else
                    result.unattributed = result.unattributed + occurrences
                end
            end
        end
    end
    return result
end

function NS:Scan()
    if not self.db then return end
    local rows, byName = {}, {}
    local currentInterface = select(4, GetBuildInfo()) or 0
    local numAddOns = C_AddOns.GetNumAddOns()
    if UpdateAddOnMemoryUsage then pcall(UpdateAddOnMemoryUsage) end

    for index = 1, numAddOns do
        local name, title, notes, _, _, security = C_AddOns.GetAddOnInfo(index)
        if name then
            local loadable, reason = C_AddOns.IsAddOnLoadable(name, self:GetCharacterScope())
            local enabled, enableState = enabledState(name)
            local loadedOrLoading, loaded = C_AddOns.IsAddOnLoaded(name)
            local interfaceVersion = C_AddOns.GetAddOnInterfaceVersion(name)
            local row = {
                index = index,
                name = name,
                title = title or name,
                notes = notes or "",
                version = C_AddOns.GetAddOnMetadata(name, "Version") or "unknown",
                category = C_AddOns.GetAddOnMetadata(name, "X-Category") or "",
                partOf = C_AddOns.GetAddOnMetadata(name, "X-Part-Of") or C_AddOns.GetAddOnMetadata(name, "X-Parent") or "",
                interfaceVersion = tonumber(interfaceVersion) or 0,
                currentInterface = currentInterface,
                enabled = enabled,
                enableState = enableState,
                loaded = loaded == true,
                loadedOrLoading = loadedOrLoading == true,
                loadable = loadable == true,
                reason = reason or "",
                security = security or "",
                loadOnDemand = C_AddOns.IsAddOnLoadOnDemand(name),
                hadLoadError = C_AddOns.DoesAddOnHaveLoadError(name),
                dependencies = listDependencies(name, false),
                optionalDependencies = listDependencies(name, true),
                findings = {},
                severity = "healthy",
            }
            row.area = detectArea(row.title, row.notes, row.category)
            if row.loaded then
                row.recentMs = profilerMetric(name, Enum.AddOnProfilerMetric.RecentAverageTime)
                row.sessionMs = profilerMetric(name, Enum.AddOnProfilerMetric.SessionAverageTime)
                row.peakMs = profilerMetric(name, Enum.AddOnProfilerMetric.PeakTime)
                local ok, memory = pcall(GetAddOnMemoryUsage, name)
                if ok then row.memoryKB = memory end
            end
            rows[#rows + 1] = row
            byName[name] = row
        end
    end

    self.errorEvidence = self:CollectErrors(byName)
    self.globalFindings = {}
    if not self.errorEvidence.available then
        if self.errorEvidence.visibility == "partial" then
            self.globalFindings[#self.globalFindings + 1] = {
                severity = "warning",
                text = "Blizzard's full session error list is unavailable. Only Lua warnings observed after Addon Health Manager loaded could be checked; a clean error scan cannot be claimed.",
            }
        else
            self.globalFindings[#self.globalFindings + 1] = {
                severity = "warning",
                text = "Blizzard's session error list is unavailable, so Lua errors and warnings could not be checked. Other status and dependency checks still ran.",
            }
        end
    end
    if self.errorEvidence.secretSkipped > 0 then
        self.globalFindings[#self.globalFindings + 1] = {
            severity = "warning",
            text = string.format("%d protected error occurrence(s) could not be inspected safely.", self.errorEvidence.secretSkipped),
        }
    end
    if self.errorEvidence.unattributed > 0 then
        self.globalFindings[#self.globalFindings + 1] = {
            severity = "warning",
            text = string.format("Blizzard's session list contains %d error or warning occurrence(s) without an identifiable installed add-on path.", self.errorEvidence.unattributed),
        }
    end
    local recentRanks = {}
    if C_AddOnProfiler and C_AddOnProfiler.IsEnabled and C_AddOnProfiler.IsEnabled() then
        local ok, results = pcall(C_AddOnProfiler.GetTopKAddOnsForMetric, Enum.AddOnProfilerMetric.RecentAverageTime, 5)
        if ok and type(results) == "table" then
            local rank = 0
            for _, result in ipairs(results) do
                if result.addOnName ~= ADDON_NAME and (result.metricValue or 0) > 0 and rank < 3 then
                    rank = rank + 1
                    recentRanks[result.addOnName] = rank
                end
            end
        end
    end
    local overlaps = {}
    for _, row in ipairs(rows) do
        if row.enabled and row.area then
            overlaps[row.area] = overlaps[row.area] or {}
            overlaps[row.area][#overlaps[row.area] + 1] = row
        end
    end

    for _, row in ipairs(rows) do
        local demandLoaded = row.reason == "DEMAND_LOADED" or row.reason == "DEP_DEMAND_LOADED"
        if row.enabled and not row.loadable and not row.loadOnDemand and not demandLoaded then
            addFinding(row, "error", "not_loadable", reasonText[row.reason] or ("The client says it cannot load (" .. (row.reason ~= "" and row.reason or "reason unavailable") .. ")."), row.reason)
        elseif row.enabled and row.hadLoadError then
            addFinding(row, "error", "load_error", "WoW recorded an error while loading this add-on.", "C_AddOns.DoesAddOnHaveLoadError")
        elseif not row.enabled then
            addFinding(row, "info", "disabled", "Disabled; this can be intentional.", "Enable state: " .. tostring(row.enableState))
        elseif (row.loadOnDemand or demandLoaded) and not row.loaded then
            addFinding(row, "info", "on_demand", "Available on demand; not loading yet is normal.", "LoadOnDemand")
        elseif row.enabled and not row.loaded then
            addFinding(row, "warning", "not_loaded", "Enabled but not currently loaded. A reload may be needed.", "Enabled=true, Loaded=false")
        end

        if row.interfaceVersion > 0 and currentInterface > 0 and row.interfaceVersion ~= currentInterface then
            local severity = row.loadable and "warning" or "error"
            addFinding(row, severity, "interface", "Targets interface " .. row.interfaceVersion .. "; this client is " .. currentInterface .. ".", "TOC/client interface mismatch")
        end

        for _, dep in ipairs(row.dependencies) do
            local dependency = byName[dep]
            if not dependency then
                addFinding(row, "error", "missing_dependency", "Required dependency " .. dep .. " is not installed.", dep)
            elseif not dependency.enabled then
                addFinding(row, "error", "disabled_dependency", "Required dependency " .. (dependency.title or dep) .. " is disabled.", dep)
            end
        end

        local error = self.errorEvidence.attributed[row.name]
        if error then
            local severity = error.errors >= 3 and "error" or "warning"
            local kinds = {}
            if error.errors > 0 then kinds[#kinds + 1] = string.format("%d Lua error occurrence(s)", error.errors) end
            if error.warnings > 0 then kinds[#kinds + 1] = string.format("%d Lua/XML warning occurrence(s)", error.warnings) end
            addFinding(row, severity, "lua_error", "This session's Blizzard error list contains " .. table.concat(kinds, " and ") .. " whose path points to this add-on.", "Best-effort path attribution; not proof of root cause")
            row.luaErrors = error.count
            row.luaWarnings = error.warnings
        end

        local blocked = self.sessionBlockedActions and self.sessionBlockedActions[row.name]
        if blocked then
            addFinding(row, "warning", "blocked_action", string.format("WoW blocked %d protected action(s) initiated under this add-on's name this session.", blocked), "ADDON_ACTION_FORBIDDEN; may involve taint propagated from another add-on")
        end

        if recentRanks[row.name] then
            row.recentRank = recentRanks[row.name]
            addFinding(row, "info", "relative_activity", string.format("Ranked #%d among the highest recent add-on execution-time values in this snapshot. Activity varies by scene and does not prove a performance problem.", row.recentRank), "C_AddOnProfiler RecentAverageTime relative ranking")
        end

        if row.enabled and row.area and overlaps[row.area] and #overlaps[row.area] > 1 then
            local others = {}
            for _, peer in ipairs(overlaps[row.area]) do
                if peer.name ~= row.name then others[#others + 1] = peer.title end
            end
            addFinding(row, "info", "overlap", "Possible shared UI area (" .. row.area .. ") with " .. table.concat(others, ", ") .. ". This is not proof of a conflict.", "Keyword match in title/notes/category")
        end

        local previous = self.db.snapshots[row.name]
        if previous then
            local changes = {}
            if previous.version ~= row.version then changes[#changes + 1] = "version " .. tostring(previous.version) .. " → " .. row.version end
            if previous.enabled ~= row.enabled then changes[#changes + 1] = row.enabled and "enabled" or "disabled" end
            if previous.interfaceVersion ~= row.interfaceVersion then changes[#changes + 1] = "interface metadata changed" end
            if #changes > 0 then
                row.recentChanges = changes
                addFinding(row, "info", "changed", "Changed since Addon Health's last saved scan: " .. table.concat(changes, ", ") .. ".", "Local snapshot comparison")
            end
        end
    end

    table.sort(rows, function(a, b)
        if SEVERITY[a.severity] ~= SEVERITY[b.severity] then return SEVERITY[a.severity] > SEVERITY[b.severity] end
        return strlower(a.title) < strlower(b.title)
    end)
    self.rows, self.rowsByName = rows, byName
    self.db.lastScan = GetServerTime and GetServerTime() or time()
    for _, row in ipairs(rows) do
        self.db.snapshots[row.name] = {
            version = row.version,
            enabled = row.enabled,
            interfaceVersion = row.interfaceVersion,
            seen = self.db.lastScan,
        }
    end
    if self.RefreshUI then self:RefreshUI() end
end

function NS:GetCounts()
    local counts = { total = #self.rows, loaded = 0, disabled = 0, error = 0, warning = 0, info = 0, healthy = 0 }
    for _, row in ipairs(self.rows) do
        if row.loaded then counts.loaded = counts.loaded + 1 end
        if not row.enabled then counts.disabled = counts.disabled + 1 end
        counts[row.severity] = (counts[row.severity] or 0) + 1
    end
    for _, finding in ipairs(self.globalFindings or {}) do
        counts[finding.severity] = (counts[finding.severity] or 0) + 1
    end
    return counts
end
