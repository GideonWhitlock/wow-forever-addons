local _, NS = ...

local GAMEPLAY_WEIGHTS = {
    roleDamage=2.2,roleTank=2.4,roleHeal=2.4,roleFlex=1.4,rangePhysical=1.7,rangeSpell=1.7,melee=1.7,
    mobility=1.8,stationaryTolerance=1.8,control=1.5,survivability=1.5,recovery=1.1,burst=1.1,
    sustain=1.1,utility=1.5,multiTarget=0.9,slowRhythm=1.1,fastRhythm=1.1,tactical=1.3,
    reactive=1.0,complexity=1.4,maintenance=1.3,pet=1.7,pvp=1.1,solo=1.3,group=1.0,
    sessionEase=0.8,journey=0.7,endgame=0.7,flexibility=0.8,power=0.7,mastery=0.8,
}
local LONGTERM_WEIGHTS = {
    roleDamage=1.2,roleTank=1.4,roleHeal=1.4,roleFlex=1.5,rangePhysical=1.0,rangeSpell=1.0,melee=1.0,
    mobility=1.1,stationaryTolerance=1.1,control=0.9,survivability=1.2,recovery=0.9,burst=0.6,
    sustain=1.1,utility=1.1,multiTarget=0.5,slowRhythm=0.7,fastRhythm=0.7,tactical=0.9,
    reactive=0.7,complexity=1.0,maintenance=1.1,pet=1.2,pvp=0.8,solo=1.4,group=1.2,
    sessionEase=1.4,journey=1.5,endgame=1.3,flexibility=1.4,power=0.5,mastery=1.3,
    identity=1.8,attachment=1.8,fantasyHunter=2.1,fantasyRogue=2.1,fantasyWarrior=2.1,
    fantasyHoly=2.1,fantasyCaster=2.1,fantasyDark=2.1,fantasyNature=2.1,fantasyElements=2.1,fantasyPriest=2.1,
}

local function similarity(preferred, actual)
    return 1 - math.abs(preferred - actual) / 5
end

local function interactionAdjust(player, candidate)
    local v, c = player.values, candidate.ratings
    local adjustments = {}
    local function add(id, amount, text)
        adjustments[#adjustments + 1] = { id=id, amount=amount, text=text }
    end
    if (v.control or 0) >= 4 and (v.survivability or 0) >= 4 then
        add("control_durability", ((c.control + c.survivability) / 2 - 2.5) * 0.65, "Your combined preference for control and durability favours reliable tactical survival.")
    end
    if (v.solo or 0) >= 4 and (v.sessionEase or 0) >= 4 then
        add("independent_sessions", ((c.solo + c.sessionEase) / 2 - 2.5) * 0.65, "Solo play and limited or irregular time reward practical independence.")
    end
    if (v.utility or 0) >= 4 and v.maintenance and v.maintenance <= 2 then
        add("low_upkeep_utility", ((c.utility - c.maintenance) / 5) * 1.4, "You want useful tools without excessive upkeep.")
    end
    if (v.pet or 0) >= 4 and (v.melee or 0) >= 4 then
        local fit = math.min(c.pet, 5) * 0.5 + math.min(c.melee, 5) * 0.5
        add("pet_direct_combat", (fit - 2.5) * 0.55, "You combine companion interest with a desire to fight directly.")
    end
    if (v.mobility or 0) >= 4 and v.stationaryTolerance and v.stationaryTolerance <= 1 then
        add("mobile_no_casting", (c.mobility - c.stationaryTolerance) * 0.9, "High mobility and low tolerance for stationary casting reinforce one another.")
    end
    if (v.roleFlex or 0) >= 4 and (v.flexibility or 0) >= 4 then
        add("flexible_identity", (c.roleFlex - 2.5) * 0.75, "You want meaningful room to change roles or approaches over time.")
    end
    local total = 0
    for _, adjustment in ipairs(adjustments) do total = total + adjustment.amount end
    total = math.max(-8, math.min(8, total))
    return total, adjustments
end

local function historyAdjust(candidate, preferences, mode)
    local status = preferences.experience and preferences.experience[candidate.class]
    if not status then return 0, nil end
    local values = mode == "longterm" and {played=0.5,max=1.5,enjoyed=5,disliked=-7,retry=3} or {played=0,max=0.5,enjoyed=1.5,disliked=-2,retry=0.5}
    local labels = {played="previously played",max="previously taken to maximum level",enjoyed="previously enjoyed",disliked="previously disliked",retry="interested in trying again"}
    if type(status) == "table" then
        local amount, parts = 0, {}
        for _, key in ipairs({"played","max","enjoyed","disliked","retry"}) do
            if status[key] then amount = amount + (values[key] or 0); parts[#parts + 1] = labels[key] end
        end
        amount = math.max(-7, math.min(6, amount))
        return amount, #parts > 0 and table.concat(parts, ", ") or nil
    end
    local amount = values[status] or 0
    return amount, labels[status]
end

function NS:ScoreCandidate(player, candidate, preferences, mode)
    local modeWeights = mode == "longterm" and LONGTERM_WEIGHTS or GAMEPLAY_WEIGHTS
    local weighted, totalWeight, contributions = 0, 0, {}
    for dimension, preferred in pairs(player.values) do
        local modeWeight = modeWeights[dimension]
        local actual = candidate.ratings[dimension]
        if modeWeight and actual ~= nil then
            local evidenceWeight = math.min(2.5, player.weights[dimension] or 1)
            local weight = modeWeight * evidenceWeight
            local match = similarity(preferred, actual)
            local points = match * weight
            weighted, totalWeight = weighted + points, totalWeight + weight
            contributions[#contributions + 1] = {
                dimension=dimension, label=NS.dimensionLabels[dimension] or dimension,
                preferred=preferred, actual=actual, weight=weight, match=match,
                impact=(match - 0.5) * weight,
            }
        end
    end
    local base = totalWeight > 0 and (weighted / totalWeight) * 100 or 50
    local interactions, interactionDetails = interactionAdjust(player, candidate)
    local history, historyLabel = historyAdjust(candidate, preferences or {}, mode)
    table.sort(contributions, function(a,b)
        if a.impact == b.impact then return a.dimension < b.dimension end
        return a.impact > b.impact
    end)
    return {
        profile=candidate, score=NS:Clamp(base + interactions + history, 0, 100), base=base,
        contributions=contributions, interactionAdjustment=interactions,
        interactions=interactionDetails, historyAdjustment=history, historyLabel=historyLabel,
    }
end

local function sortScores(a, b)
    if math.abs(a.score - b.score) < 0.000001 then return a.profile.id < b.profile.id end
    return a.score > b.score
end

function NS:ConfidenceLabel(ranked, completeness)
    if completeness < 0.45 then return "Insufficient information" end
    if not ranked[2] then return "Plausible match" end
    local margin = ranked[1].score - ranked[2].score
    if margin < 1.5 then return "Close decision" end
    if completeness >= 0.85 and margin >= 6 then return "Strong match" end
    if margin >= 3 then return "Good match" end
    return "Plausible alternative"
end

function NS:RankMode(player, preferences, mode)
    local eligible, excluded = self:FilterCandidates(preferences)
    if #eligible == 0 then return { mode=mode, ranked={}, excluded=excluded, conflict=true, confidence="No eligible candidates" } end
    local ranked = {}
    for _, entry in ipairs(eligible) do
        local scored = self:ScoreCandidate(player, entry.profile, preferences, mode)
        scored.eligibleRaces = entry.eligibleRaces
        ranked[#ranked + 1] = scored
    end
    table.sort(ranked, sortScores)
    local headline, seen = {}, {}
    for _, item in ipairs(ranked) do
        if not seen[item.profile.class] then
            headline[#headline + 1] = item
            seen[item.profile.class] = true
            if #headline == 3 then break end
        end
    end
    local sameClass = {}
    for _, item in ipairs(ranked) do
        if item.profile.class == ranked[1].profile.class and item.profile.id ~= ranked[1].profile.id then sameClass[#sameClass + 1] = item end
    end
    return {mode=mode,ranked=ranked,headline=headline,winner=ranked[1],sameClass=sameClass,excluded=excluded,confidence=self:ConfidenceLabel(ranked,self:ProfileCompleteness(player))}
end

function NS:Recommend(answers, preferences)
    local player = self:BuildPlayerProfile(answers or {})
    preferences = preferences or {}
    local result = {
        scoringVersion=self.scoringVersion, profileVersion=self.profileVersion,
        generatedAt=time and time() or 0, player=player,
        gameplay=self:RankMode(player, preferences, "gameplay"),
        longterm=self:RankMode(player, preferences, "longterm"),
    }
    if not result.gameplay.conflict then self:BuildExplanations(result, preferences) end
    return result
end
