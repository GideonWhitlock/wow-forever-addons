local ADDON_NAME, NS = ...

NS.name = ADDON_NAME or "ChooseAMainForever"
NS.title = "Choose a Main: Forever"
NS.version = "1.0.1"
NS.schemaVersion = 2
NS.scoringVersion = "1.0.0-beta.1"
NS.profileVersion = "forever-1.60.1.70338-beta-2026-10-11"
NS.interfaceVersion = 16001
NS.modules = NS.modules or {}

function NS:Print(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cffd9ad4aChoose a Main: Forever|r: " .. tostring(message))
    end
end

function NS:Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

function NS:CopyTable(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[self:CopyTable(key)] = self:CopyTable(child) end
    return copy
end

function NS:SortedKeys(tbl)
    local keys = {}
    for key in pairs(tbl or {}) do keys[#keys + 1] = key end
    table.sort(keys)
    return keys
end
