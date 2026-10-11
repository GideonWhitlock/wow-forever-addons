local _, NS = ...

local DEFAULTS = {
    schemaVersion=3,
    answers={},
    preferences={faction="either",experience={},allowedRaces={},allowedRacesEnabled=false,unwantedRoles={},unwillingClasses={},rejectStationaryCasting=false,sex="either",notes=""},
    assessment={complete=false,currentQuestion=1},
    window={x=0,y=0,scale=1},
    minimap={hidden=false,angle=220},
    lastResult=nil,
    scoringVersion=nil,
    profileVersion=nil,
}

local function mergeDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            target[key] = type(value) == "table" and NS:CopyTable(value) or value
        elseif type(value) == "table" and type(target[key]) == "table" then
            mergeDefaults(target[key], value)
        elseif type(target[key]) ~= type(value) then
            target[key] = type(value) == "table" and NS:CopyTable(value) or value
        end
    end
end

function NS:MigrateDatabase(db)
    if type(db) ~= "table" then db = {} end
    local version = tonumber(db.schemaVersion) or 0
    if version < 1 then
        if type(db.questionnaire) == "table" and type(db.answers) ~= "table" then db.answers = db.questionnaire end
        db.questionnaire = nil
        version = 1
    end
    if version < 2 then
        db.preferences = type(db.preferences) == "table" and db.preferences or {}
        db.preferences.experience = type(db.preferences.experience) == "table" and db.preferences.experience or {}
        db.preferences.allowedRaces = type(db.preferences.allowedRaces) == "table" and db.preferences.allowedRaces or {}
        version = 2
    end
    if version < 3 then
        local experience = db.preferences and db.preferences.experience
        if type(experience) == "table" then
            for _, record in pairs(experience) do
                if type(record) == "table" and not record.played then
                    record.max, record.enjoyed, record.disliked, record.retry = nil, nil, nil, nil
                end
            end
        end
        version = 3
    end
    db.schemaVersion = version
    mergeDefaults(db, DEFAULTS)
    db.answers = self:ValidateAnswers(db.answers)
    db.window.scale = self:Clamp(tonumber(db.window.scale) or 1, 0.75, 1.35)
    db.assessment.currentQuestion = self:Clamp(tonumber(db.assessment.currentQuestion) or 1, 1, #self.questions)
    return db
end

function NS:LoadDatabase()
    ChooseAMainForeverDB = self:MigrateDatabase(ChooseAMainForeverDB)
    self.db = ChooseAMainForeverDB
end

function NS:SaveResult(result)
    self.db.lastResult = result
    self.db.assessment.complete = not result.gameplay.conflict
    self.db.scoringVersion = self.scoringVersion
    self.db.profileVersion = self.profileVersion
end

function NS:ResetAssessment()
    local window, minimap = self:CopyTable(self.db.window), self:CopyTable(self.db.minimap)
    ChooseAMainForeverDB = self:CopyTable(DEFAULTS)
    ChooseAMainForeverDB.window, ChooseAMainForeverDB.minimap = window, minimap
    self.db = ChooseAMainForeverDB
end
