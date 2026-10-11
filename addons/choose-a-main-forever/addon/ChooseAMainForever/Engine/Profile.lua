local _, NS = ...

local DIMENSION_LABELS = {
    solo="independent play", group="group play", journey="the levelling journey", endgame="endgame",
    sessionEase="short-session convenience", mastery="long-term mastery", power="competitive power",
    flexibility="activity flexibility", attachment="lasting attachment", identity="class identity",
    roleDamage="dealing damage", roleTank="tanking", roleHeal="healing", roleFlex="role flexibility",
    rangePhysical="physical ranged combat", rangeSpell="spellcasting", melee="melee combat",
    mobility="mobility", stationaryTolerance="stationary casting", control="control",
    survivability="durability", recovery="self-healing and recovery", burst="burst damage",
    sustain="sustained effectiveness", utility="utility", multiTarget="multi-enemy capability",
    slowRhythm="deliberate combat", fastRhythm="fast combat", tactical="tactical preparation",
    reactive="reactive play", complexity="combat complexity", maintenance="resource and preparation upkeep",
    pet="companion gameplay", pvp="PvP", fantasyHunter="ranger fantasy", fantasyRogue="rogue fantasy",
    fantasyWarrior="warrior fantasy", fantasyHoly="sacred knight fantasy", fantasyCaster="arcane fantasy",
    fantasyDark="dark magic fantasy", fantasyNature="nature fantasy", fantasyElements="elemental fantasy",
    fantasyPriest="priestly fantasy",
}
NS.dimensionLabels = DIMENSION_LABELS

function NS:BuildPlayerProfile(answers)
    local clean = self:ValidateAnswers(answers)
    local totals, weights, sources = {}, {}, {}
    local answered = 0
    for _, question in ipairs(self.questions) do
        local selected = clean[question.id]
        if selected then
            answered = answered + 1
            local effect = question.choices[selected].effect
            for dimension, value in pairs(effect.values or {}) do
                totals[dimension] = (totals[dimension] or 0) + value * effect.weight
                weights[dimension] = (weights[dimension] or 0) + effect.weight
                sources[dimension] = sources[dimension] or {}
                sources[dimension][#sources[dimension] + 1] = question.id
            end
        end
    end
    local values = {}
    for dimension, total in pairs(totals) do values[dimension] = total / weights[dimension] end
    local contradictions = {}
    local function contradiction(a, b, text)
        if values[a] and values[b] and values[a] >= 4 and values[b] >= 4 then contradictions[#contradictions + 1] = text end
    end
    contradiction("mobility", "stationaryTolerance", "You value movement but also enjoy deliberate stationary execution.")
    contradiction("complexity", "sessionEase", "You want depth while also valuing short, frictionless sessions.")
    contradiction("solo", "group", "You place substantial value on both independence and organised group play.")
    contradiction("maintenance", "sessionEase", "You enjoy preparation, but also want a character that is easy to resume in short sessions.")
    return { values=values, weights=weights, sources=sources, answered=answered, total=#self.questions, contradictions=contradictions }
end

function NS:ProfileCompleteness(profile)
    return profile.total > 0 and profile.answered / profile.total or 0
end
