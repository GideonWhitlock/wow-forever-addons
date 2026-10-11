local _, NS = ...

function NS:EligibleRaces(class, preferences)
    local eligible = {}
    local faction = preferences.faction or "either"
    for _, race in ipairs(self.races) do
        local factionOK = faction == "either" or faction == race.faction
        local raceOK = not preferences.allowedRacesEnabled or (preferences.allowedRaces and preferences.allowedRaces[race.id])
        if factionOK and raceOK and race.classes[class] then eligible[#eligible + 1] = race end
    end
    return eligible
end

function NS:CheckRestrictions(candidate, preferences)
    preferences = preferences or {}
    local reasons = {}
    local experience = preferences.experience or {}
    if preferences.unwillingClasses and preferences.unwillingClasses[candidate.class] then
        reasons[#reasons + 1] = "class explicitly excluded"
    elseif experience[candidate.class] == "unwilling" then
        reasons[#reasons + 1] = "class marked unwilling to play"
    end
    if preferences.rejectStationaryCasting and candidate.ratings.stationaryTolerance >= 4 then
        reasons[#reasons + 1] = "stationary casting explicitly rejected"
    end
    if preferences.unwantedRoles and preferences.unwantedRoles[candidate.role] then
        reasons[#reasons + 1] = candidate.role .. " role explicitly rejected"
    end
    local races = self:EligibleRaces(candidate.class, preferences)
    if #races == 0 then reasons[#reasons + 1] = "no allowed race and faction combination can play this class" end
    return #reasons == 0, reasons, races
end

function NS:FilterCandidates(preferences)
    local eligible, excluded = {}, {}
    for _, candidate in ipairs(self.profiles) do
        local ok, reasons, races = self:CheckRestrictions(candidate, preferences)
        if ok then
            eligible[#eligible + 1] = { profile=candidate, eligibleRaces=races }
        else
            excluded[candidate.id] = reasons
        end
    end
    return eligible, excluded
end
