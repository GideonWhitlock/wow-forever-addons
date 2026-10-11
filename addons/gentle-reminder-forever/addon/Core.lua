local addonName, addon = ...
local L = addon.L

addon.VERSION = "1.0.1"
addon.SCHEMA = 2
addon.MIN_INTERVAL = 5
addon.MAX_INTERVAL = 360
addon.MAX_TEXT = 240
addon.MAX_ONE_OFFS = 20

local floor, max, min = math.floor, math.max, math.min
local tinsert, tremove, sort = table.insert, table.remove, table.sort

local function deepCopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local copy = {}
    seen[value] = copy
    for key, child in pairs(value) do copy[deepCopy(key, seen)] = deepCopy(child, seen) end
    return copy
end
addon.DeepCopy = deepCopy

local DEFAULTS = {
    schema = 2,
    enabled = true,
    bedtimeBasis = "local",
    weekday = {
        enabled = true,
        intervalMinutes = 60,
        message = L.DEFAULT_MESSAGE,
        bedtime = "",
        bedtimeMessage = L.DEFAULT_BEDTIME_MESSAGE,
    },
    weekend = {
        enabled = true,
        intervalMinutes = 75,
        message = L.DEFAULT_MESSAGE,
        bedtime = "",
        bedtimeMessage = L.DEFAULT_BEDTIME_MESSAGE,
    },
    delivery = { visual = true, sound = false, speech = false },
    snoozeChoices = { 5, 10, 20 },
    minimap = { shown = true, angle = 220 },
    panel = { point = "CENTER", x = 0, y = 40 },
    oneOffs = {},
    daily = {},
    recurringDueAt = nil,
    recurringRemaining = nil,
    lastBedtimeDate = nil,
}
addon.DEFAULTS = DEFAULTS

local function mergeDefaults(target, defaults)
    if type(target) ~= "table" then target = {} end
    for key, value in pairs(defaults) do
        if type(value) == "table" then
            target[key] = mergeDefaults(target[key], value)
        elseif target[key] == nil then
            target[key] = value
        end
    end
    return target
end

local function trim(text)
    text = tostring(text or "")
    return text:match("^%s*(.-)%s*$") or ""
end

local function clampNumber(value, low, high, fallback)
    value = tonumber(value)
    if not value then return fallback end
    return min(high, max(low, floor(value + 0.5)))
end

function addon.SanitizeText(text, fallback)
    text = trim(text):gsub("[%c]", " "):gsub("%s+", " ")
    if text == "" then text = fallback or "" end
    if #text > addon.MAX_TEXT then text = text:sub(1, addon.MAX_TEXT) end
    return text
end

function addon.ParseDuration(text)
    text = trim(text):lower()
    if text == "" then return nil end
    if text:match("^%d+$") then
        local minutes = tonumber(text)
        if minutes and minutes > 0 then return minutes * 60 end
        return nil
    end
    local total, matched = 0, 0
    for amountText, unit in text:gmatch("(%d+)%s*([hms])") do
        local amount = tonumber(amountText)
        if unit == "h" then total = total + amount * 3600
        elseif unit == "m" then total = total + amount * 60
        else total = total + amount end
        matched = matched + 1
    end
    if matched == 0 or total <= 0 then return nil end
    return min(total, 7 * 24 * 3600)
end

function addon.ParseClock(text)
    text = trim(text)
    if text == "" then return "" end
    local hour, minute = text:match("^(%d%d?):(%d%d)$")
    hour, minute = tonumber(hour), tonumber(minute)
    if not hour or not minute or hour > 23 or minute > 59 then return nil end
    return string.format("%02d:%02d", hour, minute)
end

function addon.ParseSnoozes(text)
    local values, seen = {}, {}
    for piece in tostring(text or ""):gmatch("[^,]+") do
        local value = tonumber(trim(piece))
        if not value or value < 1 or value > 120 then return nil end
        value = floor(value + 0.5)
        if value and not seen[value] then
            seen[value] = true
            values[#values + 1] = value
        end
    end
    sort(values)
    if #values < 1 or #values > 5 then return nil end
    return values
end

local function sanitizeProfile(profile, defaults)
    profile.enabled = profile.enabled ~= false
    profile.intervalMinutes = clampNumber(profile.intervalMinutes, addon.MIN_INTERVAL, addon.MAX_INTERVAL, defaults.intervalMinutes)
    profile.message = addon.SanitizeText(profile.message, defaults.message)
    local bedtime = addon.ParseClock(profile.bedtime)
    profile.bedtime = bedtime or ""
    profile.bedtimeMessage = addon.SanitizeText(profile.bedtimeMessage, defaults.bedtimeMessage)
end

function addon.SanitizeDB(db)
    local previousSchema = type(db) == "table" and tonumber(db.schema) or 0
    local previousBasis = type(db) == "table" and db.bedtimeBasis or nil
    db = mergeDefaults(type(db) == "table" and db or {}, deepCopy(DEFAULTS))
    db.schema = addon.SCHEMA
    -- Schema 1 times were evaluated against the computer's local clock.
    -- Preserve the wall-clock text and make that old meaning explicit.
    if previousSchema < 2 and previousBasis == nil then db.bedtimeBasis = "local" end
    if db.bedtimeBasis ~= "server" then db.bedtimeBasis = "local" end
    db.enabled = db.enabled ~= false
    sanitizeProfile(db.weekday, DEFAULTS.weekday)
    sanitizeProfile(db.weekend, DEFAULTS.weekend)
    db.delivery.visual = db.delivery.visual ~= false
    db.delivery.sound = db.delivery.sound == true
    db.delivery.speech = db.delivery.speech == true
    if type(db.snoozeChoices) ~= "table" or #db.snoozeChoices < 1 then
        db.snoozeChoices = deepCopy(DEFAULTS.snoozeChoices)
    else
        local cleaned = addon.ParseSnoozes(table.concat(db.snoozeChoices, ","))
        db.snoozeChoices = cleaned or deepCopy(DEFAULTS.snoozeChoices)
    end
    db.minimap.shown = db.minimap.shown ~= false
    db.minimap.angle = tonumber(db.minimap.angle) or DEFAULTS.minimap.angle
    db.panel.point = type(db.panel.point) == "string" and db.panel.point or "CENTER"
    db.panel.x = tonumber(db.panel.x) or 0
    db.panel.y = tonumber(db.panel.y) or 40
    db.oneOffs = type(db.oneOffs) == "table" and db.oneOffs or {}
    for index = #db.oneOffs, 1, -1 do
        local item = db.oneOffs[index]
        if type(item) ~= "table" or type(item.dueAt) ~= "number" or type(item.text) ~= "string" then
            tremove(db.oneOffs, index)
        else
            item.text = addon.SanitizeText(item.text, L.TITLE_ONE_OFF)
        end
    end
    while #db.oneOffs > addon.MAX_ONE_OFFS do tremove(db.oneOffs, 1) end
    db.daily = type(db.daily) == "table" and db.daily or {}
    db.recurringDueAt = nil -- GetTime() values are not portable across client launches.
    db.recurringRemaining = tonumber(db.recurringRemaining)
    if db.recurringRemaining then db.recurringRemaining = max(1, min(db.recurringRemaining, addon.MAX_INTERVAL * 60)) end
    return db
end

function addon.GetDateKey(epoch)
    return date("%Y-%m-%d", epoch or time())
end

local function normalizeClockOffset(minutes)
    while minutes > 720 do minutes = minutes - 1440 end
    while minutes < -720 do minutes = minutes + 1440 end
    return minutes
end

function addon.GetClockSnapshot(basis, overrides)
    basis = basis == "server" and "server" or "local"
    overrides = overrides or {}
    local now = overrides.epoch or time()
    local localParts = overrides.localParts or date("*t", now)
    local localHour = overrides.localHour or localParts.hour or tonumber(date("%H", now)) or 0
    local localMinute = overrides.localMinute or localParts.min or tonumber(date("%M", now)) or 0
    local localSecond = overrides.localSecond or localParts.sec or tonumber(date("%S", now)) or 0
    local snapshot = {
        basis = basis,
        epoch = now,
        hour = localHour,
        minute = localMinute,
        second = localSecond,
        year = localParts.year,
        month = localParts.month,
        monthDay = localParts.day,
        dateKey = overrides.localDateKey or date("%Y-%m-%d", now),
        weekday = overrides.localWeekday or tonumber(date("%w", now)) or 1,
        offsetMinutes = 0,
    }
    snapshot.isWeekend = snapshot.weekday == 0 or snapshot.weekday == 6
    if basis == "local" then return snapshot end

    local serverHour, serverMinute
    if overrides.serverHour ~= nil then
        serverHour, serverMinute = overrides.serverHour, overrides.serverMinute
    elseif GetGameTime then
        serverHour, serverMinute = GetGameTime()
    end
    serverHour, serverMinute = tonumber(serverHour), tonumber(serverMinute)
    if not serverHour or not serverMinute then return snapshot end

    local calendar = overrides.serverCalendar
    if not calendar and C_DateAndTime and C_DateAndTime.GetCurrentCalendarTime then
        local ok, result = pcall(C_DateAndTime.GetCurrentCalendarTime)
        if ok and type(result) == "table" then calendar = result end
    end
    snapshot.hour, snapshot.minute = serverHour, serverMinute
    if calendar and calendar.year and calendar.month and calendar.monthDay then
        snapshot.year, snapshot.month, snapshot.monthDay = calendar.year, calendar.month, calendar.monthDay
        snapshot.dateKey = string.format("%04d-%02d-%02d", calendar.year, calendar.month, calendar.monthDay)
        snapshot.weekday = tonumber(calendar.weekday) or snapshot.weekday
        snapshot.isWeekend = snapshot.weekday == 1 or snapshot.weekday == 7
        if time and localParts.year then
            local serverAsLocal = time({ year = calendar.year, month = calendar.month, day = calendar.monthDay,
                hour = serverHour, min = serverMinute, sec = localSecond, isdst = nil })
            if serverAsLocal then snapshot.offsetMinutes = floor((serverAsLocal - now) / 60 + 0.5) end
        end
    else
        snapshot.offsetMinutes = normalizeClockOffset(serverHour * 60 + serverMinute - (localHour * 60 + localMinute))
        local shifted = date("*t", now + snapshot.offsetMinutes * 60)
        if type(shifted) == "table" then
            snapshot.year, snapshot.month, snapshot.monthDay = shifted.year, shifted.month, shifted.day
            snapshot.dateKey = string.format("%04d-%02d-%02d", shifted.year, shifted.month, shifted.day)
            snapshot.weekday = shifted.wday and shifted.wday - 1 or snapshot.weekday
            snapshot.isWeekend = snapshot.weekday == 0 or snapshot.weekday == 6
        end
    end
    return snapshot
end

function addon.GetClockSummary()
    local localClock = addon.GetClockSnapshot("local")
    local serverClock = addon.GetClockSnapshot("server")
    local offset = serverClock.offsetMinutes or 0
    local sign = offset >= 0 and "+" or "−"
    local absolute = math.abs(offset)
    local offsetText = absolute == 0 and "same time" or string.format("server %s%d:%02d", sign, floor(absolute / 60), absolute % 60)
    return string.format("Local %02d:%02d • Server %02d:%02d • %s",
        localClock.hour, localClock.minute, serverClock.hour, serverClock.minute, offsetText)
end

function addon.SetBedtimeBasis(basis)
    if basis ~= "local" and basis ~= "server" then return false end
    addon.db.bedtimeBasis = basis
    return true
end

function addon.GetProfile(epoch, basis, snapshot)
    if basis == "server" then
        snapshot = snapshot or addon.GetClockSnapshot("server")
        if snapshot.isWeekend then return addon.db.weekend, "weekend" end
        return addon.db.weekday, "weekday"
    end
    local weekday = tonumber(date("%w", epoch or time())) or 1
    if weekday == 0 or weekday == 6 then return addon.db.weekend, "weekend" end
    return addon.db.weekday, "weekday"
end

function addon.GetBedtimeContext()
    local basis = addon.db.bedtimeBasis == "server" and "server" or "local"
    local clock = addon.GetClockSnapshot(basis)
    local profile, profileName = addon.GetProfile(nil, basis, clock)
    return profile, profileName, clock, basis
end

function addon.GetNextBedtimeSeconds(profile, basis, snapshot)
    if not profile or profile.bedtime == "" then return nil end
    local hour, minute = profile.bedtime:match("^(%d%d):(%d%d)$")
    if not hour then return nil end
    hour, minute = tonumber(hour), tonumber(minute)
    basis = basis == "server" and "server" or "local"
    snapshot = snapshot or addon.GetClockSnapshot(basis)
    local alreadyDelivered = addon.db.lastBedtimeDate == snapshot.dateKey
    if basis == "local" and snapshot.year and snapshot.month and snapshot.monthDay then
        local target = time({ year = snapshot.year, month = snapshot.month, day = snapshot.monthDay,
            hour = hour, min = minute, sec = 0, isdst = nil })
        if not target then return nil end
        if not alreadyDelivered and snapshot.hour == hour and snapshot.minute == minute then return 0 end
        if alreadyDelivered or target <= snapshot.epoch then
            local localNoon = time({ year = snapshot.year, month = snapshot.month, day = snapshot.monthDay,
                hour = 12, min = 0, sec = 0, isdst = nil })
            local tomorrow = date("*t", localNoon + 24 * 3600)
            target = time({ year = tomorrow.year, month = tomorrow.month, day = tomorrow.day,
                hour = hour, min = minute, sec = 0, isdst = nil })
        end
        return max(0, target - snapshot.epoch)
    end
    local deltaMinutes = hour * 60 + minute - (snapshot.hour * 60 + snapshot.minute)
    if not alreadyDelivered and deltaMinutes == 0 then return 0 end
    if alreadyDelivered or deltaMinutes <= 0 then deltaMinutes = deltaMinutes + 1440 end
    return max(0, deltaMinutes * 60 - (snapshot.second or 0))
end

function addon.FormatDuration(seconds)
    seconds = max(0, floor(tonumber(seconds) or 0))
    local hours = floor(seconds / 3600)
    local minutes = floor((seconds % 3600) / 60)
    if hours > 0 then return string.format("%dh %02dm", hours, minutes) end
    if minutes > 0 then return string.format("%dm", minutes) end
    return string.format("%ds", seconds)
end

function addon.GetSessionSeconds()
    if not addon.sessionStartedAt then return 0 end
    return max(0, GetTime() - addon.sessionStartedAt)
end

function addon.GetTodaySeconds()
    local key = addon.GetDateKey()
    local saved = tonumber(addon.db.daily[key]) or 0
    if key == addon.activeDateKey and addon.lastTickAt then
        saved = saved + max(0, GetTime() - addon.lastTickAt)
    end
    return saved
end

local function pruneDaily()
    local keys = {}
    for key in pairs(addon.db.daily) do keys[#keys + 1] = key end
    sort(keys)
    while #keys > 35 do
        addon.db.daily[keys[1]] = nil
        tremove(keys, 1)
    end
end

function addon.CommitPlaytime()
    if not addon.db or not addon.lastTickAt then return end
    local now = GetTime()
    local elapsed = max(0, min(300, now - addon.lastTickAt))
    local dateKey = addon.GetDateKey()
    if addon.activeDateKey ~= dateKey then
        addon.activeDateKey = dateKey
        pruneDaily()
    end
    addon.db.daily[dateKey] = (tonumber(addon.db.daily[dateKey]) or 0) + elapsed
    addon.lastTickAt = now
end

function addon.IsQuietState()
    if InCombatLockdown and InCombatLockdown() then return false, "combat" end
    if C_Cinematic and C_Cinematic.InCinematic and C_Cinematic.InCinematic() then return false, "cinematic" end
    return true
end

function addon.NextRecurring(fromNow)
    local profile = addon.GetProfile()
    addon.db.recurringDueAt = GetTime() + profile.intervalMinutes * 60 + (fromNow or 0)
    addon.db.recurringRemaining = nil
end

function addon.GetNextReminderSeconds()
    local nextAt
    if addon.db.enabled then
        local profile = addon.GetProfile()
        if profile.enabled and addon.db.recurringDueAt then nextAt = addon.db.recurringDueAt end
    end
    local nowEpoch = time()
    local nowMono = GetTime()
    local bedtimeProfile, _, bedtimeClock, bedtimeBasis = addon.GetBedtimeContext()
    if addon.db.enabled and bedtimeProfile.enabled then
        local bedtimeSeconds = addon.GetNextBedtimeSeconds(bedtimeProfile, bedtimeBasis, bedtimeClock)
        if bedtimeSeconds and (not nextAt or nowMono + bedtimeSeconds < nextAt) then nextAt = nowMono + bedtimeSeconds end
    end
    for _, item in ipairs(addon.db.oneOffs) do
        local mono = nowMono + (item.dueAt - nowEpoch)
        if not nextAt or mono < nextAt then nextAt = mono end
    end
    if not nextAt then return nil end
    return max(0, nextAt - nowMono)
end

function addon.AddOneOff(duration, text)
    if #addon.db.oneOffs >= addon.MAX_ONE_OFFS then return false, "You already have the maximum of 20 one-off reminders." end
    duration = tonumber(duration)
    if not duration or duration < 1 then return false, "Choose a future time." end
    text = addon.SanitizeText(text, L.TITLE_ONE_OFF)
    local item = { id = tostring(time()) .. "-" .. tostring(math.random(1000, 9999)), dueAt = time() + duration, text = text }
    tinsert(addon.db.oneOffs, item)
    sort(addon.db.oneOffs, function(a, b) return a.dueAt < b.dueAt end)
    if addon.RefreshUI then addon.RefreshUI() end
    return true, item
end

function addon.RemoveOneOff(id)
    for index, item in ipairs(addon.db.oneOffs) do
        if item.id == id then tremove(addon.db.oneOffs, index); return true end
    end
    return false
end

function addon.QueueReminder(kind, text, source)
    addon.pending = addon.pending or {}
    addon.pending[#addon.pending + 1] = {
        kind = kind,
        text = addon.SanitizeText(text, L.DEFAULT_MESSAGE),
        source = source,
        queuedAt = time(),
    }
    addon.TryDeliver()
end

local function speak(text)
    if not addon.db.delivery.speech then return end
    if not C_VoiceChat or not C_VoiceChat.SpeakText or not C_VoiceChat.GetTtsVoices then return end
    local ok, voices = pcall(C_VoiceChat.GetTtsVoices)
    if not ok or type(voices) ~= "table" or not voices[1] then return end
    local voiceID = voices[1].voiceID or voices[1].id
    if not voiceID then return end
    pcall(C_VoiceChat.SpeakText, voiceID, addon.SanitizeText(text, L.DEFAULT_MESSAGE), 0, 80, false)
end

function addon.Deliver(reminder)
    addon.currentReminder = reminder
    if addon.db.delivery.sound and PlaySound then
        pcall(PlaySound, SOUNDKIT and SOUNDKIT.READY_CHECK or 8960, "SFX")
    end
    speak(reminder.text)
    if addon.db.delivery.visual and addon.ShowReminder then
        addon.ShowReminder(reminder)
    else
        -- Sound-only and speech-only delivery must not leave the queue blocked.
        -- Reminder text is never copied into chat as a fallback.
        addon.currentReminder = nil
        addon.TryDeliver()
    end
end

function addon.TryDeliver()
    if not addon.pending or #addon.pending == 0 or addon.currentReminder then return end
    local quiet = addon.IsQuietState()
    if not quiet then
        addon.deferred = true
        if addon.RefreshUI then addon.RefreshUI() end
        return
    end
    addon.deferred = false
    addon.Deliver(tremove(addon.pending, 1))
end

function addon.DismissCurrent()
    addon.currentReminder = nil
    if addon.HideReminder then addon.HideReminder() end
    addon.TryDeliver()
end

function addon.SnoozeCurrent(minutes)
    local reminder = addon.currentReminder
    if not reminder then return end
    minutes = clampNumber(minutes, 1, 120, 5)
    local ok, message = addon.AddOneOff(minutes * 60, reminder.text)
    if not ok then addon.Print(message); return end
    addon.currentReminder = nil
    if addon.HideReminder then addon.HideReminder() end
    addon.TryDeliver()
end

local function checkBedtime()
    local profile, _, clock, basis = addon.GetBedtimeContext()
    if not addon.db.enabled or not profile.enabled or profile.bedtime == "" then return end
    if addon.db.lastBedtimeDate == clock.dateKey then return end
    local seconds = addon.GetNextBedtimeSeconds(profile, basis, clock)
    if seconds ~= nil and seconds <= 0 then
        addon.db.lastBedtimeDate = clock.dateKey
        addon.QueueReminder("bedtime", profile.bedtimeMessage)
    end
end

function addon.Tick()
    addon.CommitPlaytime()
    local nowMono, nowEpoch = GetTime(), time()
    local profile = addon.GetProfile()
    if addon.db.enabled and profile.enabled then
        if not addon.db.recurringDueAt then addon.NextRecurring() end
        if nowMono >= addon.db.recurringDueAt then
            addon.NextRecurring()
            addon.QueueReminder("recurring", profile.message)
        end
    else
        addon.db.recurringDueAt = nil
    end
    checkBedtime()
    for index = #addon.db.oneOffs, 1, -1 do
        local item = addon.db.oneOffs[index]
        if nowEpoch >= item.dueAt then
            tremove(addon.db.oneOffs, index)
            addon.QueueReminder("oneoff", item.text, item.id)
        end
    end
    addon.TryDeliver()
    if addon.RefreshUI then addon.RefreshUI() end
end

function addon.Print(message)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffd6b35a" .. L.TAG .. ":|r " .. tostring(message)) end
end

local function commandHelp()
    addon.Print("/grf — open settings")
    addon.Print("/grf remind 20m Take the laundry out — add a private one-off reminder")
    addon.Print("/grf on | off | status | test | hide | show")
    addon.Print("/grf interval 60 — set the current day profile")
    addon.Print("/grf bedtime 22:30 | off — set the current day profile")
    addon.Print("/grf bedtimebasis local | server — choose which clock bedtime uses")
    addon.Print("/grf snoozes 5,10,20 — set button choices")
    addon.Print("/grf reset — restore defaults; /grf recover — restore the last backup")
end

function addon.Status()
    local profile, name = addon.GetProfile()
    local bedtimeProfile, bedtimeName, _, bedtimeBasis = addon.GetBedtimeContext()
    addon.Print(string.format("%s profile: recurring %s every %d minutes; %s bedtime %s (%s time).",
        name, addon.db.enabled and profile.enabled and "on" or "off", profile.intervalMinutes, bedtimeName,
        bedtimeProfile.bedtime ~= "" and bedtimeProfile.bedtime or "off", bedtimeBasis))
    addon.Print(addon.GetClockSummary() .. ".")
    addon.Print(string.format("Session %s; today %s; %d one-off reminder(s).",
        addon.FormatDuration(addon.GetSessionSeconds()), addon.FormatDuration(addon.GetTodaySeconds()), #addon.db.oneOffs))
    local nextSeconds = addon.GetNextReminderSeconds()
    addon.Print(nextSeconds and ("Next reminder in " .. addon.FormatDuration(nextSeconds) .. ".") or L.NO_REMINDER .. ".")
end

function addon.ResetDB()
    GentleReminderForeverBackupDB = { kind = "manual", data = deepCopy(addon.db) }
    GentleReminderForeverDB = deepCopy(DEFAULTS)
    addon.db = addon.SanitizeDB(GentleReminderForeverDB)
    addon.NextRecurring()
    addon.Print("Defaults restored. Your previous settings are available with /grf recover.")
    if addon.ApplyAllSettings then addon.ApplyAllSettings() end
end

function addon.RecoverDB()
    if type(GentleReminderForeverBackupDB) ~= "table" then addon.Print("No backup is available."); return end
    local current = deepCopy(addon.db)
    local backup = GentleReminderForeverBackupDB.data or GentleReminderForeverBackupDB
    GentleReminderForeverDB = addon.SanitizeDB(deepCopy(backup))
    addon.db = GentleReminderForeverDB
    GentleReminderForeverBackupDB = { kind = "manual", data = current }
    addon.Print("Backup recovered. The settings you just replaced are now the backup.")
    if addon.ApplyAllSettings then addon.ApplyAllSettings() end
end

function addon.HandleSlash(input)
    input = trim(input)
    if input == "" then if addon.TogglePanel then addon.TogglePanel() end; return end
    local command, rest = input:match("^(%S+)%s*(.-)$")
    command = command and command:lower() or ""
    if command == "help" then commandHelp()
    elseif command == "on" then addon.db.enabled = true; addon.NextRecurring(); addon.Print("Recurring reminders resumed.")
    elseif command == "off" then addon.db.enabled = false; addon.db.recurringDueAt = nil; addon.Print("Recurring reminders paused. One-off reminders stay active.")
    elseif command == "status" then addon.Status()
    elseif command == "test" then addon.QueueReminder("preview", "This is a private preview. Take your time.")
    elseif command == "show" then addon.db.minimap.shown = true; if addon.ApplyMinimapVisibility then addon.ApplyMinimapVisibility() end
    elseif command == "hide" then addon.db.minimap.shown = false; if addon.ApplyMinimapVisibility then addon.ApplyMinimapVisibility() end
    elseif command == "reset" then addon.ResetDB()
    elseif command == "recover" then addon.RecoverDB()
    elseif command == "interval" then
        local value = tonumber(rest)
        if not value or value < addon.MIN_INTERVAL or value > addon.MAX_INTERVAL then addon.Print("Use a number from 5 to 360 minutes."); return end
        value = floor(value + 0.5)
        local profile = addon.GetProfile(); profile.intervalMinutes = value; addon.NextRecurring()
        addon.Print("This profile will remind you every " .. value .. " minutes.")
    elseif command == "bedtime" then
        local profile = addon.GetProfile()
        if rest:lower() == "off" or rest == "" then profile.bedtime = ""; addon.Print("Bedtime reminder disabled for this profile.")
        else
            local value = addon.ParseClock(rest)
            if not value then addon.Print("Use 24-hour time such as 22:30, or 'off'."); return end
            profile.bedtime = value; addon.Print("Bedtime reminder set to " .. value .. " for this profile.")
        end
    elseif command == "bedtimebasis" or command == "clock" then
        rest = rest:lower()
        if rest ~= "local" and rest ~= "server" then addon.Print("Choose /grf bedtimebasis local or /grf bedtimebasis server."); return end
        addon.SetBedtimeBasis(rest)
        addon.Print("Bedtime reminders now use " .. rest .. " time. " .. addon.GetClockSummary() .. ".")
    elseif command == "snoozes" then
        local values = addon.ParseSnoozes(rest)
        if not values then addon.Print("Choose one to five comma-separated values from 1 to 120 minutes."); return end
        addon.db.snoozeChoices = values; addon.Print("Snooze choices saved.")
    elseif command == "remind" then
        local durationText, message = rest:match("^(%S+)%s+(.+)$")
        local seconds = addon.ParseDuration(durationText)
        if not seconds then addon.Print("Try /grf remind 20m Take the laundry out"); return end
        local ok, result = addon.AddOneOff(seconds, message)
        if ok then addon.Print("I’ll remind you in " .. addon.FormatDuration(seconds) .. ".") else addon.Print(result) end
    else commandHelp() end
    if addon.RefreshUI then addon.RefreshUI() end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_LOGOUT")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("CINEMATIC_START")
events:RegisterEvent("CINEMATIC_STOP")
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then
        if type(GentleReminderForeverDB) == "table" and
                not (type(GentleReminderForeverBackupDB) == "table" and GentleReminderForeverBackupDB.kind == "manual") then
            GentleReminderForeverBackupDB = { kind = "startup", data = deepCopy(GentleReminderForeverDB) }
        end
        GentleReminderForeverDB = addon.SanitizeDB(GentleReminderForeverDB)
        addon.db = GentleReminderForeverDB
        SLASH_GENTLEREMINDERFOREVER1 = "/grf"
        SLASH_GENTLEREMINDERFOREVER2 = "/gentlereminder"
        SlashCmdList.GENTLEREMINDERFOREVER = addon.HandleSlash
    elseif event == "PLAYER_LOGIN" then
        addon.sessionStartedAt = GetTime()
        addon.lastTickAt = GetTime()
        addon.activeDateKey = addon.GetDateKey()
        if addon.db.enabled and not addon.db.recurringDueAt then
            if addon.db.recurringRemaining then
                addon.db.recurringDueAt = GetTime() + addon.db.recurringRemaining
                addon.db.recurringRemaining = nil
            else
                addon.NextRecurring()
            end
        end
        if addon.BuildUI then addon.BuildUI() end
        addon.ticker = C_Timer.NewTicker(1, addon.Tick)
        addon.Print(L.STATUS_READY .. " Type /grf for settings.")
    elseif event == "PLAYER_LOGOUT" then
        addon.CommitPlaytime()
        if addon.db.recurringDueAt then
            addon.db.recurringRemaining = max(1, addon.db.recurringDueAt - GetTime())
            addon.db.recurringDueAt = nil
        end
    elseif event == "PLAYER_REGEN_DISABLED" or event == "CINEMATIC_START" then
        if addon.currentReminder then
            addon.pending = addon.pending or {}
            tinsert(addon.pending, 1, addon.currentReminder)
            addon.currentReminder = nil
            addon.deferred = true
            if addon.HideReminder then addon.HideReminder() end
        end
    elseif event == "PLAYER_REGEN_ENABLED" or event == "CINEMATIC_STOP" then
        C_Timer.After(0.5, addon.TryDeliver)
    end
end)

