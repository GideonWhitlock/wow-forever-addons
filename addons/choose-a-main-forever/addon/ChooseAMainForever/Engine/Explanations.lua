local _, NS = ...

local function topContributions(score, positive, limit)
    local selected = {}
    if positive then
        for _, item in ipairs(score.contributions) do
            if item.impact > 0 then selected[#selected + 1] = item end
            if #selected == limit then break end
        end
    else
        for index = #score.contributions, 1, -1 do
            local item = score.contributions[index]
            if item.impact < 0 then selected[#selected + 1] = item end
            if #selected == limit then break end
        end
    end
    return selected
end

local function joinLabels(items)
    local labels = {}
    for _, item in ipairs(items) do labels[#labels + 1] = item.label end
    if #labels == 0 then return "your overall pattern of answers" end
    if #labels == 1 then return labels[1] end
    if #labels == 2 then return labels[1] .. " and " .. labels[2] end
    return labels[1] .. ", " .. labels[2] .. " and " .. labels[3]
end

function NS:BuildArchetype(player)
    local v = player.values
    local first = (v.solo or 0) >= 4 and "Independent" or (v.group or 0) >= 4 and "Group-minded" or (v.mobility or 0) >= 4 and "Mobile" or "Adaptable"
    local second = (v.tactical or 0) >= 4 and "Tactician" or (v.mastery or 0) >= 4 and "Specialist" or (v.identity or 0) >= 4 and "Hero" or (v.utility or 0) >= 4 and "Problem-solver" or "Adventurer"
    return "The " .. first .. " " .. second
end

function NS:ExplainMode(modeResult, player, otherMode)
    local winner = modeResult.winner
    if not winner then return end
    local positives = topContributions(winner, true, 3)
    local negatives = topContributions(winner, false, 2)
    local alternatives = {}
    for index = 2, math.min(3, #modeResult.headline) do
        local item = modeResult.headline[index]
        alternatives[#alternatives + 1] = item.profile.spec .. " " .. item.profile.className .. " preserves " .. joinLabels(topContributions(item, true, 2)) .. "."
    end
    local differences
    if otherMode and otherMode.winner and otherMode.winner.profile.id ~= winner.profile.id then
        differences = "This differs from the other result because this view gives more weight to " .. (modeResult.mode == "gameplay" and "combat rhythm, role and moment-to-moment mechanics." or "identity, history, levelling comfort and durable flexibility.")
    else
        differences = "Gameplay fit and long-term appeal point to the same talent path, which strengthens the recommendation without making it a guarantee."
    end
    local changes = {}
    if player.answered < player.total then changes[#changes + 1] = tostring(player.total - player.answered) .. " unanswered main questions could alter close rankings." end
    if #player.contradictions > 0 then changes[#changes + 1] = player.contradictions[1] end
    if #winner.interactions > 0 then changes[#changes + 1] = winner.interactions[1].text end
    if #changes == 0 then changes[1] = "Explicit class, race, role or stationary-casting restrictions could materially change the eligible field." end
    local sameSpec = modeResult.sameClass[1]
    return {
        archetype=self:BuildArchetype(player),
        whyClass=winner.profile.className .. " aligns especially well with " .. joinLabels(positives) .. ". " .. winner.profile.summary,
        whySpec=winner.profile.spec .. " is the strongest path within that class for this answer pattern. Its model score is " .. string.format("%.1f", winner.score) .. "/100; this is a transparent compatibility score, not a probability of enjoyment.",
        frustrations=(#negatives > 0 and "The weaker matches are " .. joinLabels(negatives) .. ". " or "No large single mismatch dominates. ") .. winner.profile.frustrations,
        alternatives=table.concat(alternatives, "\n\n"),
        gameplayVsAttachment=differences,
        mayChange=table.concat(changes, "\n\n"),
        notableSameClass=sameSpec and (sameSpec.profile.spec .. " is the next notable path within " .. winner.profile.className .. ".") or nil,
    }
end

function NS:BuildExplanations(result)
    result.archetype = self:BuildArchetype(result.player)
    result.gameplay.explanation = self:ExplainMode(result.gameplay, result.player, result.longterm)
    result.longterm.explanation = self:ExplainMode(result.longterm, result.player, result.gameplay)
end
