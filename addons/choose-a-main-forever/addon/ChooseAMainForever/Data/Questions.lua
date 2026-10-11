local _, NS = ...

-- Effects are preference observations, not class points. Each observation is
-- averaged into a 0..5 player profile and carries an explicit evidence weight.
-- This keeps question wording separate from patch-sensitive class data.
local function E(values, weight)
    return { values = values, weight = weight or 1 }
end

NS.sections = {
    { id = "habits", name = "Playing habits" },
    { id = "roles", name = "Group role and responsibility" },
    { id = "combat", name = "Combat personality" },
    { id = "resources", name = "Resources and companions" },
    { id = "identity", name = "Fantasy and character identity" },
    { id = "longterm", name = "Long-term satisfaction" },
}

NS.questions = {
    { id=1, section="habits", text="You have an entire evening free to play WoW. What sounds most satisfying?", choices={
        {text="Exploring, questing and getting absorbed in the world", effect=E({solo=5, journey=5, identity=4},1.1)},
        {text="Overcoming difficult enemies and improving my character", effect=E({mastery=5, power=4, complexity=4})},
        {text="Running dungeons with other players", effect=E({group=5, utility=3, journey=2})},
        {text="Battlegrounds or fighting other players in the world", effect=E({pvp=5, control=4, burst=4})},
        {text="Raiding and working towards group achievements", effect=E({group=5, endgame=5, sustain=4})},
        {text="A relaxed mixture of whatever takes my fancy", effect=E({flexibility=5, complexity=2, sessionEase=4})},
    }},
    { id=2, section="habits", text="How do you realistically spend most of your time in WoW?", choices={
        {text="Almost entirely alone", effect=E({solo=5, group=0},1.3)},
        {text="Mostly solo, with occasional group activities", effect=E({solo=4, group=2},1.3)},
        {text="Roughly half solo and half with others", effect=E({solo=3, group=3},1.3)},
        {text="Mostly in organised groups or with friends", effect=E({solo=1, group=5},1.3)},
        {text="It varies hugely depending on my mood", effect=E({solo=3, group=3, flexibility=5})},
    }},
    { id=3, section="habits", text="How much time do you realistically expect to play most weeks?", choices={
        {text="Under five hours", effect=E({sessionEase=5, maintenance=0, journey=3})},
        {text="Five to ten hours", effect=E({sessionEase=4, maintenance=1, journey=4})},
        {text="Ten to twenty hours", effect=E({sessionEase=3, maintenance=3})},
        {text="Twenty to thirty hours", effect=E({sessionEase=2, maintenance=4, mastery=4})},
        {text="More than thirty hours", effect=E({sessionEase=1, maintenance=5, mastery=5})},
        {text="Highly unpredictable", effect=E({sessionEase=5, flexibility=4})},
    }},
    { id=4, section="habits", text="What do you most want to get out of WoW Forever?", choices={
        {text="The immersive, slow journey to level 60", effect=E({journey=5, endgame=1, identity=4},1.2)},
        {text="A character I can keep developing for years", effect=E({attachment=5, mastery=4, endgame=4},1.2)},
        {text="A great endgame dungeon or raiding experience", effect=E({endgame=5, group=5},1.2)},
        {text="A world where PvP encounters are exciting", effect=E({pvp=5, control=4},1.2)},
        {text="The freedom to explore many different activities", effect=E({flexibility=5, solo=3, group=3},1.2)},
        {text="A character that feels like an extension of me", effect=E({identity=5, attachment=5},1.2)},
    }},
    { id=5, section="habits", text="Imagine your favourite class is only average on damage rankings. What do you do?", choices={
        {text="Keep playing it happily because I love the class", effect=E({identity=5, attachment=5, power=1},1.2)},
        {text="Stay unless it makes playing with others difficult", effect=E({attachment=4, group=4, power=3},1.2)},
        {text="Consider switching talents to stay competitive", effect=E({flexibility=5, power=4, mastery=3},1.2)},
        {text="Probably switch to something stronger", effect=E({power=5, attachment=1},1.2)},
        {text="I genuinely don't know", effect=E({},0.25)},
    }},
    { id=6, section="roles", text="Which combat role would be most satisfying as your main identity?", choices={
        {text="Damage dealer, concentrating on defeating enemies", effect=E({roleDamage=5, roleTank=0, roleHeal=0},1.8)},
        {text="Tank, controlling enemies and protecting the group", effect=E({roleDamage=1, roleTank=5, roleHeal=0, survivability=5},1.8)},
        {text="Healer, keeping everyone alive", effect=E({roleDamage=0, roleTank=0, roleHeal=5, recovery=5},1.8)},
        {text="A versatile character able to change roles", effect=E({roleDamage=3, roleTank=3, roleHeal=3, roleFlex=5},1.8)},
        {text="I haven't developed a preference", effect=E({roleDamage=3, roleTank=3, roleHeal=3},0.35)},
    }},
    { id=7, section="roles", text="You're in a challenging dungeon. Which achievement would make you proudest?", choices={
        {text="Delivering exceptional damage", effect=E({roleDamage=5, power=5, sustain=4},1.2)},
        {text="Leading a smooth run and managing the enemies", effect=E({roleTank=5, control=5, group=5},1.2)},
        {text="Saving the group from what looked like certain death", effect=E({roleHeal=5, recovery=5, reactive=5},1.2)},
        {text="Using a clever ability at exactly the right moment", effect=E({utility=5, tactical=5, complexity=4},1.2)},
        {text="Providing useful support that makes everybody stronger", effect=E({utility=5, group=5, roleFlex=4},1.2)},
        {text="Being the dependable, consistent member of the group", effect=E({sustain=5, group=4, survivability=4},1.2)},
    }},
    { id=8, section="combat", text="Where does combat feel most natural to you?", choices={
        {text="At long range with a bow, gun or similar weapon", effect=E({rangePhysical=5, rangeSpell=1, melee=0},1.5)},
        {text="At long range casting spells", effect=E({rangePhysical=0, rangeSpell=5, melee=0},1.5)},
        {text="Face-to-face with melee weapons", effect=E({rangePhysical=0, rangeSpell=0, melee=5},1.5)},
        {text="Moving between close and long range", effect=E({rangePhysical=3, rangeSpell=2, melee=4, flexibility=5},1.5)},
        {text="Distance makes no real difference to me", effect=E({rangePhysical=3, rangeSpell=3, melee=3},0.4)},
    }},
    { id=9, section="combat", text="Which style of defeating an enemy is most satisfying?", choices={
        {text="One enormous, devastating attack", effect=E({burst=5, sustain=1, slowRhythm=5})},
        {text="A constant stream of aggressive attacks", effect=E({burst=3, sustain=5, fastRhythm=5})},
        {text="Gradually wearing them down through damage over time", effect=E({sustain=5, tactical=4, burst=1})},
        {text="Controlling and outmanoeuvring them until they lose", effect=E({control=5, tactical=5, mobility=4})},
        {text="Carefully setting up a devastating combination", effect=E({burst=5, tactical=5, complexity=4})},
        {text="Outlasting them through defence and recovery", effect=E({survivability=5, recovery=5, sustain=4})},
    }},
    { id=10, section="combat", text="You can keep only ONE combat advantage. Which is it?", choices={
        {text="Mobility: reposition and escape quickly", effect=E({mobility=5},2)},
        {text="Control: disable and dictate enemy behaviour", effect=E({control=5},2)},
        {text="Survivability: withstand punishment", effect=E({survivability=5},2)},
        {text="Burst: deliver explosive damage when needed", effect=E({burst=5},2)},
        {text="Utility: abilities that solve unusual problems", effect=E({utility=5},2)},
        {text="Sustained output: remain consistently effective", effect=E({sustain=5},2)},
    }},
    { id=11, section="combat", text="Now the opposite: which combat advantage could you most easily sacrifice?", choices={
        {text="Mobility", effect=E({mobility=0},1.6)},
        {text="Control", effect=E({control=0},1.6)},
        {text="Survivability", effect=E({survivability=0},1.6)},
        {text="Burst damage", effect=E({burst=0},1.6)},
        {text="Utility", effect=E({utility=0},1.6)},
        {text="Sustained output", effect=E({sustain=0},1.6)},
    }},
    { id=12, section="combat", text="You accidentally attract several dangerous enemies. What response would feel best?", choices={
        {text="Stand my ground and fight through them", effect=E({survivability=5, multiTarget=5, melee=4})},
        {text="Escape, regroup and try again", effect=E({mobility=5, survivability=2})},
        {text="Use crowd control and turn the situation around", effect=E({control=5, tactical=5, multiTarget=4})},
        {text="Survive through healing, shields or defensive abilities", effect=E({recovery=5, survivability=5})},
        {text="Let a companion occupy them whilst I attack", effect=E({pet=5, solo=5, rangePhysical=4})},
        {text="I would prefer a class that makes such situations uncommon", effect=E({rangePhysical=4, rangeSpell=3, control=3, survivability=3})},
    }},
    { id=13, section="combat", text="What combat rhythm holds your attention best?", choices={
        {text="Slow, deliberate and powerful", effect=E({slowRhythm=5, fastRhythm=0, burst=4})},
        {text="Smooth and consistent without much fuss", effect=E({slowRhythm=3, fastRhythm=2, sustain=5, complexity=1})},
        {text="Fast, aggressive and responsive", effect=E({fastRhythm=5, slowRhythm=0, reactive=4})},
        {text="Tactical, with plenty of preparation", effect=E({tactical=5, maintenance=4, complexity=4})},
        {text="Reactive, changing my approach moment by moment", effect=E({reactive=5, complexity=4, flexibility=4})},
        {text="A mixture of calm moments and intense bursts", effect=E({slowRhythm=3, fastRhythm=3, burst=5})},
    }},
    { id=14, section="combat", text="What is the ideal learning curve?", choices={
        {text="Straightforward and comfortable from the beginning", effect=E({complexity=0, journey=5},1.3)},
        {text="Easy to learn, but with meaningful depth", effect=E({complexity=2, mastery=4},1.3)},
        {text="Moderately complex and rewarding to improve", effect=E({complexity=3, mastery=4},1.3)},
        {text="Difficult to master, with lots of hidden depth", effect=E({complexity=5, mastery=5},1.3)},
        {text="Complexity isn't important as long as it's enjoyable", effect=E({complexity=3},0.3)},
    }},
    { id=15, section="combat", text="How important is movement whilst fighting?", choices={
        {text="Extremely: I dislike feeling rooted in place", effect=E({mobility=5, stationaryTolerance=0},1.8)},
        {text="Quite important: I want repositioning options", effect=E({mobility=4, stationaryTolerance=1},1.8)},
        {text="Somewhat: useful, but not central", effect=E({mobility=3, stationaryTolerance=3},1.5)},
        {text="Not important: I enjoy standing and executing abilities", effect=E({mobility=1, stationaryTolerance=5},1.8)},
        {text="Depends on the encounter", effect=E({mobility=3, stationaryTolerance=3, flexibility=4},0.7)},
    }},
    { id=16, section="resources", text="How do you feel about managing resources, consumables, pets and preparation?", choices={
        {text="I enjoy these immersive RPG mechanics", effect=E({maintenance=5, tactical=5, identity=4},1.4)},
        {text="I'm happy with them when they add meaningful choices", effect=E({maintenance=4, tactical=4},1.4)},
        {text="Some management is fine, but I want smooth gameplay", effect=E({maintenance=2, sessionEase=4},1.4)},
        {text="I prefer as little maintenance as possible", effect=E({maintenance=0, sessionEase=5},1.4)},
    }},
    { id=17, section="resources", text="What is your relationship with pets or summoned companions?", choices={
        {text="I love having a permanent companion beside me", effect=E({pet=5, identity=4},1.8)},
        {text="I like companions when they add gameplay choices", effect=E({pet=4, tactical=4},1.8)},
        {text="They're fine, but I don't particularly need one", effect=E({pet=3},0.8)},
        {text="I'd much rather fight entirely by myself", effect=E({pet=0},1.8)},
        {text="I like the idea but dislike managing them", effect=E({pet=3, maintenance=0},1.8)},
    }},
    { id=18, section="identity", text="Which visual fighting style appeals most?", choices={
        {text="A bow or firearm and practical adventuring equipment", effect=E({rangePhysical=5, fantasyHunter=5},1.2)},
        {text="Two weapons, precision and quick movements", effect=E({melee=5, fastRhythm=5, fantasyRogue=4},1.2)},
        {text="A huge two-handed weapon and heavy armour", effect=E({melee=5, slowRhythm=5, fantasyWarrior=5},1.2)},
        {text="A shield and the ability to hold the line", effect=E({roleTank=5, survivability=5, fantasyHoly=3},1.2)},
        {text="A staff or magical focus, wielding powerful spells", effect=E({rangeSpell=5, fantasyCaster=5},1.2)},
        {text="Changing into different animal forms", effect=E({fantasyNature=5, roleFlex=5},1.2)},
        {text="I care much more about gameplay than equipment", effect=E({identity=1},0.7)},
    }},
    { id=19, section="identity", text="Which fantasy would you most enjoy inhabiting for years?", choices={
        {text="A solitary ranger, tracker or beastmaster", effect=E({fantasyHunter=5, identity=5, solo=4},1.8)},
        {text="A subtle infiltrator, duellist or assassin", effect=E({fantasyRogue=5, identity=5, control=4},1.8)},
        {text="A battle-hardened warrior", effect=E({fantasyWarrior=5, identity=5, melee=4},1.8)},
        {text="A righteous knight or sacred protector", effect=E({fantasyHoly=5, identity=5, survivability=4},1.8)},
        {text="A scholar wielding arcane, fire or frost magic", effect=E({fantasyCaster=5, identity=5, rangeSpell=4},1.8)},
        {text="A wielder of forbidden magic and dark powers", effect=E({fantasyDark=5, identity=5, rangeSpell=4},1.8)},
        {text="A protector of nature who can change forms", effect=E({fantasyNature=5, identity=5, roleFlex=4},1.8)},
        {text="A spiritual champion of storms and elements", effect=E({fantasyElements=5, identity=5, roleFlex=3},1.8)},
        {text="A devoted healer or wielder of holy and shadow powers", effect=E({fantasyPriest=5, identity=5, roleHeal=4},1.8)},
        {text="Class fantasy isn't especially important to me", effect=E({identity=0},1.2)},
    }},
    { id=20, section="identity", text="How important is your character's identity, appearance and lore?", choices={
        {text="Essential: I need to genuinely believe in the character", effect=E({identity=5, attachment=5},1.7)},
        {text="Very important, but gameplay still matters", effect=E({identity=4, attachment=4},1.7)},
        {text="A balance between theme and practical enjoyment", effect=E({identity=3, attachment=3},1.5)},
        {text="Nice to have, but gameplay wins", effect=E({identity=2, attachment=2},1.5)},
        {text="Almost irrelevant; I play for mechanics", effect=E({identity=0, attachment=1},1.7)},
    }},
    { id=21, section="longterm", text="Suppose a class is frustrating at lower levels but becomes much more rewarding later. Your reaction?", choices={
        {text="I'm happy to persevere for a substantial payoff", effect=E({journey=1, endgame=5, mastery=5})},
        {text="I can accept some struggle, but not endless frustration", effect=E({journey=3, endgame=4})},
        {text="I prefer an enjoyable journey from the beginning", effect=E({journey=5, endgame=2, sessionEase=4})},
        {text="It depends on how much I love the fantasy", effect=E({identity=5, attachment=4, journey=3})},
        {text="I'm more interested in the journey than the endgame", effect=E({journey=5, endgame=0})},
    }},
    { id=22, section="longterm", text="How much do you enjoy PvP?", choices={
        {text="I actively avoid it", effect=E({pvp=0},1.6)},
        {text="I like being able to defend myself whilst questing", effect=E({pvp=2, survivability=4},1.6)},
        {text="Occasional battlegrounds or world encounters sound fun", effect=E({pvp=3},1.6)},
        {text="I want to become genuinely good at PvP", effect=E({pvp=4, mastery=5, control=4},1.6)},
        {text="PvP will be one of my main activities", effect=E({pvp=5, control=4, burst=4},1.6)},
    }},
    { id=23, section="longterm", text="A year from now, what would make you happiest with your character?", choices={
        {text="Being deeply attached to one iconic character", effect=E({attachment=5, identity=5},1.5)},
        {text="Mastering a demanding combat style", effect=E({mastery=5, complexity=5},1.5)},
        {text="Being sought-after and valuable to groups", effect=E({group=5, utility=5},1.5)},
        {text="Having multiple meaningful specialisation options", effect=E({roleFlex=5, flexibility=5},1.5)},
        {text="Being able to adventure independently and comfortably", effect=E({solo=5, survivability=4, sessionEase=4},1.5)},
        {text="Having a character that remains fun regardless of balance changes", effect=E({attachment=5, power=1, flexibility=4},1.5)},
    }},
    { id=24, section="longterm", text="Which outcome are you most afraid of after choosing your main?", choices={
        {text="Getting bored with the combat", effect=E({complexity=4, mastery=5},1.3)},
        {text="Feeling weak or ineffective", effect=E({power=5, survivability=4},1.3)},
        {text="Losing interest during levelling", effect=E({journey=5, sessionEase=4},1.3)},
        {text="Discovering I dislike the endgame role", effect=E({roleFlex=4, endgame=5},1.3)},
        {text="Lacking an ability or type of gameplay I love", effect=E({utility=5, flexibility=4},1.3)},
        {text="Feeling trapped in one playstyle", effect=E({roleFlex=5, flexibility=5},1.3)},
        {text="Regretting the choice and wanting to reroll", effect=E({attachment=5, journey=4},1.3)},
        {text="Never feeling attached to the character", effect=E({identity=5, attachment=5},1.3)},
    }},
}

function NS:GetQuestion(id)
    return self.questions[tonumber(id)]
end

function NS:ValidateAnswers(answers)
    local clean = {}
    for index, question in ipairs(self.questions) do
        local selected = tonumber(answers and answers[question.id])
        if selected and question.choices[selected] then clean[question.id] = selected end
    end
    return clean
end
