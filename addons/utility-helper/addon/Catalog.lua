local _, U = ...
U.VERSION = "0.1.22"
U.TITLE = "Utility Helper: Forever"
U.catalog = {}
-- IDs identify spell families. The spellbook supplies the learned rank and localized name.
-- This is a utility catalogue, not a rotation or an assertion of encounter vulnerability.
local function add(class, id, label, rule, target, extra)
    local e = { key = class .. ":" .. id, class = class, id = id, label = label,
        rule = rule, target = target or "player" }
    for k, v in pairs(extra or {}) do e[k] = v end
    U.catalog[#U.catalog + 1] = e
end
local function a(class, id, label, rule, target, extra) add(class, id, label, rule, target, extra) end

a("HUNTER", 1513, "Scare Beast", "creature", "target", {types = {1}, missingDebuff = true})
a("HUNTER", 136, "Mend Pet", "pethealth", "pet", {missingAura = true})
a("HUNTER", 982, "Revive Pet", "petdead", "pet", {dualState = true})
a("HUNTER", 883, "Call Pet", "petmissing", "player", {outOfCombat = true, restOnly = true})
a("HUNTER", 19801, "Tranquilizing Shot", "purge", "target", {dispels = {Enrage = true}})
a("HUNTER", 1499, "Freezing Trap", "combat", "player", {note = "Places a trap at your feet; position the enemy yourself."})
a("HUNTER", 13809, "Frost Trap", "combat", "player")
a("HUNTER", 19386, "Wyvern Sting", "creature", "target", {types = {1, 2, 7}, incidentalDamage = true})
a("HUNTER", 19503, "Scatter Shot", "control", "target", {incidentalDamage = true})
a("HUNTER", 5116, "Concussive Shot", "control", "target")
a("HUNTER", 5384, "Feign Death", "defensive", "player")
a("HUNTER", 19263, "Deterrence", "defensive", "player")
a("HUNTER", 781, "Disengage", "manual", "player", {note = "Use when you need distance or threat relief; behaviour depends on the learned version."})
local hunterAspects = {13163, 13165, 5118, 13159, 20043, 13161, 34074, 61846}
a("HUNTER", 13163, "Aspect of the Monkey", "buff", "player", {choiceBuffs = hunterAspects})
a("HUNTER", 13165, "Aspect of the Hawk", "buff", "player", {choiceBuffs = hunterAspects})
a("HUNTER", 5118, "Aspect of the Cheetah", "buff", "player", {choiceBuffs = hunterAspects})
a("HUNTER", 13159, "Aspect of the Pack", "buff", "player", {choiceBuffs = hunterAspects})
a("HUNTER", 20043, "Aspect of the Wild", "buff", "player", {choiceBuffs = hunterAspects})
a("HUNTER", 13161, "Aspect of the Beast", "buff", "player", {choiceBuffs = hunterAspects})
a("HUNTER", 34074, "Aspect of the Viper", "buff", "player", {choiceBuffs = hunterAspects})
a("HUNTER", 61846, "Aspect of the Dragonhawk", "buff", "player", {choiceBuffs = hunterAspects})

a("PRIEST", 527, "Dispel Magic", "dispel", "friendly", {dispels = {Magic = true}, party = true})
a("PRIEST", 527, "Dispel Magic (enemy)", "purge", "target", {dispels = {Magic = true}, key = "PRIEST:527:enemy"})
a("PRIEST", 528, "Cure Disease", "dispel", "friendly", {dispels = {Disease = true}, party = true, replacedBy = 552})
a("PRIEST", 552, "Abolish Disease", "dispel", "friendly", {dispels = {Disease = true}, party = true, missingAura = true})
a("PRIEST", 139, "Renew", "health", "friendly", {missingAura = true})
-- Forever allows an existing shield to be overwritten once Weakened Soul is absent.
a("PRIEST", 17, "Power Word: Shield", "health", "friendly", {blockedAuras = {6788}})
a("PRIEST", 19236, "Desperate Prayer", "health", "player")
a("PRIEST", 15487, "Silence", "interrupt", "target")
a("PRIEST", 8122, "Psychic Scream", "combat", "player")
a("PRIEST", 9484, "Shackle Undead", "creature", "target", {types = {6}})
a("PRIEST", 605, "Mind Control", "creature", "target", {types = {7}})
a("PRIEST", 586, "Fade", "defensive", "player")
a("PRIEST", 14751, "Inner Focus", "mana", "player", {note = "Preparation ability; does not restore mana itself."})
a("PRIEST", 6346, "Fear Ward", "buff", "friendly", {missingAura = true, outOfCombat = true})
a("PRIEST", 1243, "Power Word: Fortitude", "buff", "friendly", {missingAura = true, outOfCombat = true})
a("PRIEST", 588, "Inner Fire", "buff", "player", {missingAura = true, outOfCombat = true})
a("PRIEST", 21562, "Prayer of Fortitude", "manual", "friendly", {outOfCombat = true})
a("PRIEST", 1706, "Levitate", "falling", "friendly")
a("PRIEST", 2006, "Resurrection", "resurrect", "deadfriendly", {outOfCombat = true})

a("DRUID", 774, "Rejuvenation", "health", "friendly", {missingAura = true})
a("DRUID", 18562, "Swiftmend", "health", "friendly", {requiredAuras = {774, 8936}})
a("DRUID", 17116, "Nature's Swiftness", "health", "player", {note = "Preparation ability; follow with a healing spell."})
a("DRUID", 29166, "Innervate", "mana", "friendly")
a("DRUID", 2782, "Remove Curse", "dispel", "friendly", {dispels = {Curse = true}, party = true})
a("DRUID", 8946, "Cure Poison", "dispel", "friendly", {dispels = {Poison = true}, party = true, replacedBy = 2893})
a("DRUID", 2893, "Abolish Poison", "dispel", "friendly", {dispels = {Poison = true}, party = true, missingAura = true})
a("DRUID", 2637, "Hibernate", "creature", "target", {types = {1, 2}})
a("DRUID", 339, "Entangling Roots", "control", "target", {incidentalDamage = true})
a("DRUID", 5211, "Bash", "interrupt", "target", {incidentalDamage = true, stun = true})
a("DRUID", 16979, "Feral Charge", "interrupt", "target")
a("DRUID", 22812, "Barkskin", "defensive", "player")
a("DRUID", 22842, "Frenzied Regeneration", "health", "player")
a("DRUID", 1850, "Dash", "manual", "player")
a("DRUID", 20484, "Rebirth", "resurrect", "deadfriendly")
a("DRUID", 1126, "Mark of the Wild", "buff", "friendly", {missingAura = true, outOfCombat = true})

a("MAGE", 2139, "Counterspell", "interrupt", "target")
a("MAGE", 475, "Remove Lesser Curse", "dispel", "friendly", {dispels = {Curse = true}, party = true})
a("MAGE", 118, "Polymorph", "creature", "target", {types = {1, 7, 8}})
a("MAGE", 122, "Frost Nova", "combat", "player", {incidentalDamage = true})
a("MAGE", 12051, "Evocation", "mana", "player")
a("MAGE", 11426, "Ice Barrier", "health", "player", {missingAura = true})
a("MAGE", 45438, "Ice Block", "defensive", "player")
a("MAGE", 1953, "Blink", "manual", "player")
a("MAGE", 130, "Slow Fall", "falling", "player", {missingAura = true})
a("MAGE", 1459, "Arcane Intellect", "buff", "friendly", {missingAura = true, outOfCombat = true})
a("MAGE", 168, "Frost Armor", "buff", "player", {missingAura = true, outOfCombat = true, replacedBy = 7302})
a("MAGE", 7302, "Ice Armor", "buff", "player", {missingAura = true, outOfCombat = true})
a("MAGE", 6117, "Mage Armor", "buff", "player")
a("MAGE", 30482, "Molten Armor", "buff", "player")

a("PALADIN", 498, "Divine Protection", "defensive", "player", {blockedAuras = {25771}, replacedBy = 642})
a("PALADIN", 642, "Divine Shield", "defensive", "player", {blockedAuras = {25771}})
a("PALADIN", 633, "Lay on Hands", "health", "friendly")
a("PALADIN", 20473, "Holy Shock (heal)", "health", "friendly", {note = "Friendly targets only; this button cannot choose its damage mode."})
a("PALADIN", 1152, "Purify", "dispel", "friendly", {dispels = {Poison = true, Disease = true}, party = true, replacedBy = 4987})
a("PALADIN", 4987, "Cleanse", "dispel", "friendly", {dispels = {Poison = true, Disease = true, Magic = true}, party = true})
a("PALADIN", 853, "Hammer of Justice", "interrupt", "target", {stun = true})
a("PALADIN", 20066, "Repentance", "creature", "target", {types = {7}})
a("PALADIN", 2878, "Turn Undead", "creature", "target", {types = {6}})
a("PALADIN", 1022, "Blessing of Protection", "health", "friendly", {blockedAuras = {25771}, note = "Physical protection; can prevent the ally's physical attacks. Use with care on tanks."})
a("PALADIN", 1044, "Blessing of Freedom", "manual", "friendly")
a("PALADIN", 6940, "Blessing of Sacrifice", "manual", "friendly")
a("PALADIN", 19740, "Blessing of Might", "buff", "friendly")
a("PALADIN", 19742, "Blessing of Wisdom", "buff", "friendly")
a("PALADIN", 20217, "Blessing of Kings", "buff", "friendly")
a("PALADIN", 7328, "Redemption", "resurrect", "deadfriendly", {outOfCombat = true})
local paladinAuras = {465, 7294, 19746, 19891, 19888, 19876, 20218, 32223}
a("PALADIN", 465, "Devotion Aura", "buff", "player", {choiceBuffs = paladinAuras})
a("PALADIN", 7294, "Retribution Aura", "buff", "player", {choiceBuffs = paladinAuras, incidentalDamage = true})
a("PALADIN", 19746, "Concentration Aura", "buff", "player", {choiceBuffs = paladinAuras})
a("PALADIN", 19891, "Fire Resistance Aura", "buff", "player", {choiceBuffs = paladinAuras})
a("PALADIN", 19888, "Frost Resistance Aura", "buff", "player", {choiceBuffs = paladinAuras})
a("PALADIN", 19876, "Shadow Resistance Aura", "buff", "player", {choiceBuffs = paladinAuras})
a("PALADIN", 20218, "Sanctity Aura", "buff", "player", {choiceBuffs = paladinAuras})
a("PALADIN", 32223, "Crusader Aura", "buff", "player", {choiceBuffs = paladinAuras})

a("ROGUE", 1766, "Kick", "interrupt", "target", {incidentalDamage = true})
a("ROGUE", 2094, "Blind", "control", "target")
a("ROGUE", 1776, "Gouge", "interrupt", "target", {incidentalDamage = true, stun = true, note = "Requires suitable facing; damage breaks Gouge."})
a("ROGUE", 408, "Kidney Shot", "interrupt", "target", {stun = true})
a("ROGUE", 5277, "Evasion", "defensive", "player")
a("ROGUE", 1856, "Vanish", "defensive", "player")
a("ROGUE", 2983, "Sprint", "manual", "player")

a("SHAMAN", 57994, "Wind Shear", "interrupt", "target")
a("SHAMAN", 8042, "Earth Shock (interrupt)", "interrupt", "target", {incidentalDamage = true, replacedBy = 57994, note = "Only suggested against a cast; Earth Shock deals damage."})
a("SHAMAN", 370, "Purge", "purge", "target", {dispels = {Magic = true}})
a("SHAMAN", 526, "Cure Poison", "dispel", "friendly", {dispels = {Poison = true}, party = true})
a("SHAMAN", 2870, "Cure Disease", "dispel", "friendly", {dispels = {Disease = true}, party = true})
a("SHAMAN", 16188, "Nature's Swiftness", "health", "player", {note = "Preparation ability; follow with a healing spell."})
a("SHAMAN", 16190, "Mana Tide Totem", "mana", "player")
a("SHAMAN", 5394, "Healing Stream Totem", "health", "player", {totem = true})
a("SHAMAN", 8177, "Grounding Totem", "interrupt", "target", {totem = true, selfCast = true, note = "Intercepts eligible spells; it does not directly interrupt a cast."})
a("SHAMAN", 8143, "Tremor Totem", "manual", "player", {totem = true})
a("SHAMAN", 2484, "Earthbind Totem", "combat", "player", {totem = true})
a("SHAMAN", 8166, "Poison Cleansing Totem", "dispel", "player", {dispels = {Poison = true}, totem = true})
a("SHAMAN", 8170, "Disease Cleansing Totem", "dispel", "player", {dispels = {Disease = true}, totem = true})
a("SHAMAN", 131, "Water Breathing", "swimming", "friendly", {missingAura = true})
a("SHAMAN", 546, "Water Walking", "manual", "friendly")
a("SHAMAN", 2008, "Ancestral Spirit", "resurrect", "deadfriendly", {outOfCombat = true})
local shamanShields = {324, 974, 52127}
a("SHAMAN", 324, "Lightning Shield", "buff", "player", {choiceBuffs = shamanShields, incidentalDamage = true})
a("SHAMAN", 974, "Earth Shield", "buff", "friendly", {choiceBuffs = shamanShields})
a("SHAMAN", 52127, "Water Shield", "buff", "player", {choiceBuffs = shamanShields})

a("WARLOCK", 755, "Health Funnel", "pethealth", "pet", {note = "Channels your own health into the pet. Watch your health while using it."})
a("WARLOCK", 5782, "Fear", "control", "target", {excludeTypes = {6, 9}})
a("WARLOCK", 5484, "Howl of Terror", "combat", "player")
a("WARLOCK", 710, "Banish", "creature", "target", {types = {3, 4}})
a("WARLOCK", 1098, "Enslave Demon", "creature", "target", {types = {3}, noPet = true})
a("WARLOCK", 19244, "Spell Lock", "interrupt", "target", {petSpell = true})
a("WARLOCK", 19505, "Devour Magic", "dispel", "friendly", {dispels = {Magic = true}, petSpell = true, party = true})
a("WARLOCK", 19505, "Devour Magic (enemy)", "purge", "target", {dispels = {Magic = true}, petSpell = true, key = "WARLOCK:19505:enemy"})
a("WARLOCK", 6358, "Seduction", "creature", "target", {types = {7}, petSpell = true})
a("WARLOCK", 7812, "Sacrifice", "health", "player", {petSpell = true, note = "Sacrifices the Voidwalker to shield you."})
a("WARLOCK", 5697, "Unending Breath", "swimming", "friendly", {missingAura = true})
a("WARLOCK", 687, "Demon Skin", "buff", "player", {missingAura = true, outOfCombat = true, replacedBy = 706})
a("WARLOCK", 706, "Demon Armor", "buff", "player", {missingAura = true, outOfCombat = true})
a("WARLOCK", 28176, "Fel Armor", "buff", "player")
a("WARLOCK", 1454, "Life Tap", "manahealth", "player",
    {note = "Use when mana is at or below the mana threshold and health is above the health threshold."})
local healthstoneItems = {19013, 19012, 9421, 19011, 19010, 5510, 19009, 19008, 5509, 19007, 19006, 5511, 19005, 19004, 5512}
local soulstoneItems = {16896, 16895, 16893, 16892, 5232}
a("WARLOCK", 6201, "Create Healthstone", "missingitem", "player",
    {outOfCombat = true, restOnly = true, missingItems = healthstoneItems,
    note = "Shown outside combat when you do not have a Healthstone."})
a("WARLOCK", 693, "Create Soulstone", "missingitem", "player",
    {outOfCombat = true, restOnly = true, missingItems = soulstoneItems,
    note = "Shown outside combat when you do not have a Soulstone."})
a("WARLOCK", 698, "Ritual of Summoning", "manual", "player", {outOfCombat = true})

a("WARRIOR", 6552, "Pummel", "interrupt", "target", {incidentalDamage = true})
a("WARRIOR", 72, "Shield Bash", "interrupt", "target", {incidentalDamage = true})
a("WARRIOR", 676, "Disarm", "manual", "target", {note = "Choose an armed opponent susceptible to disarm."})
a("WARRIOR", 5246, "Intimidating Shout", "control", "target")
a("WARRIOR", 871, "Shield Wall", "defensive", "player")
a("WARRIOR", 12975, "Last Stand", "defensive", "player")
a("WARRIOR", 18499, "Berserker Rage", "manual", "player")
local warriorShouts = {6673, 469}
a("WARRIOR", 6673, "Battle Shout", "buff", "player", {choiceBuffs = warriorShouts})
a("WARRIOR", 469, "Commanding Shout", "buff", "player", {choiceBuffs = warriorShouts})

-- Explicit self-heals: fixed self recipient, never redirected by an enemy target.
a("PRIEST", 2050, "Lesser Heal (self)", "health", "player")
a("PRIEST", 2054, "Heal (self)", "health", "player")
a("PRIEST", 2060, "Greater Heal (self)", "health", "player")
a("PRIEST", 2061, "Flash Heal (self)", "health", "player")
a("DRUID", 5185, "Healing Touch (self)", "health", "player")
a("DRUID", 8936, "Regrowth (self)", "health", "player", {missingAura = true})
a("PALADIN", 635, "Holy Light (self)", "health", "player")
a("PALADIN", 19750, "Flash of Light (self)", "health", "player")
a("SHAMAN", 331, "Healing Wave (self)", "health", "player")
a("SHAMAN", 8004, "Lesser Healing Wave (self)", "health", "player")

-- Targeted friendly buffs, including learned group versions. Equivalent auras
-- suppress both versions; the player chooses which missing buff to provide.
a("PRIEST", 976, "Shadow Protection", "buff", "friendly")
a("PRIEST", 14752, "Divine Spirit", "buff", "friendly")
a("PRIEST", 27681, "Prayer of Spirit", "buff", "friendly")
a("PRIEST", 27683, "Prayer of Shadow Protection", "buff", "friendly")
a("DRUID", 21849, "Gift of the Wild", "buff", "friendly")
a("DRUID", 467, "Thorns", "buff", "friendly", {incidentalDamage = true})
a("MAGE", 23028, "Arcane Brilliance", "buff", "friendly")
a("MAGE", 604, "Dampen Magic", "buff", "friendly", {buffAuras = {604, 1008}, note = "Reduces magic damage and healing received; choose for the situation."})
a("MAGE", 1008, "Amplify Magic", "buff", "friendly", {buffAuras = {604, 1008}, note = "Increases magic damage and healing received; choose for the situation."})
a("PALADIN", 20911, "Blessing of Sanctuary", "buff", "friendly", {incidentalDamage = true})
a("PALADIN", 1038, "Blessing of Salvation", "buff", "friendly", {note = "Reduces the ally's threat; choose carefully for tanks."})
a("PALADIN", 19977, "Blessing of Light", "buff", "friendly")
a("PALADIN", 25782, "Greater Blessing of Might", "buff", "friendly")
a("PALADIN", 25894, "Greater Blessing of Wisdom", "buff", "friendly")
a("PALADIN", 25898, "Greater Blessing of Kings", "buff", "friendly")
a("PALADIN", 25899, "Greater Blessing of Sanctuary", "buff", "friendly", {incidentalDamage = true})
a("PALADIN", 25895, "Greater Blessing of Salvation", "buff", "friendly", {note = "Reduces threat for the target's class; choose carefully for tanks."})
a("PALADIN", 25890, "Greater Blessing of Light", "buff", "friendly")
local buffFamilies = {{1243, 21562}, {976, 27683}, {14752, 27681}, {1126, 21849}, {1459, 23028},
    {168, 7302, 6117, 30482}, {687, 706, 28176},
    {19740, 25782}, {19742, 25894}, {20217, 25898}, {20911, 25899}, {1038, 25895}, {19977, 25890}}
local blessingChoices = {19740, 25782, 19742, 25894, 20217, 25898, 20911, 25899, 1038, 25895, 19977, 25890}
for _, e in ipairs(U.catalog) do
    for _, family in ipairs(buffFamilies) do
        if e.id == family[1] or e.id == family[2] then
            e.rule, e.buffAuras = "buff", family
            if e.class == "PALADIN" then e.choiceBuffs, e.choiceOwnOnly = blessingChoices, true end
        end
    end
    if e.rule == "buff" and e.target == "player" then
        -- Maintenance actions keep one fixed secure button for both states:
        -- public missing-aura data controls out-of-combat input, while the
        -- combat state driver enables the already-configured action in combat.
        e.missingAura, e.outOfCombat, e.restOnly, e.selfBuff, e.maintenance = true, nil, nil, true, true
    end
    if e.rule == "buff" and e.target == "friendly" then
        e.targetedBuff, e.missingAura, e.outOfCombat = true, true, nil
    end
    if e.id == 19742 or e.id == 25894 then e.requiresMana = true end
end

-- Keep ally buff buttons available in combat, and add independent self versions
-- that can maintain the player both outside combat and during combat.
local originalCount = #U.catalog
for index = 1, originalCount do
    local source = U.catalog[index]
    if source.rule == "buff" and source.target == "friendly" then
        local e = {}; for k, v in pairs(source) do e[k] = v end
        e.key, e.label, e.target = source.key .. ":self", source.label .. " (self)", "player"
        e.targetedBuff, e.party, e.playerOnly = nil, nil, nil
        e.missingAura, e.outOfCombat, e.restOnly, e.selfBuff, e.maintenance = true, nil, nil, true, true
        U.catalog[#U.catalog + 1] = e
    end
end

-- Racial utilities: only learned spells survive the spellbook filter.
a("ALL", 20594, "Stoneform", "dispel", "player", {dispels = {Poison = true, Disease = true, Bleed = true}})
a("ALL", 20549, "War Stomp", "combat", "player")
a("ALL", 7744, "Will of the Forsaken", "manual", "player")
a("ALL", 20589, "Escape Artist", "manual", "player")
a("ALL", 58984, "Shadowmeld", "manual", "player")
a("ALL", 20580, "Shadowmeld", "manual", "player", {replacedBy = 58984})
a("ALL", 20577, "Cannibalize", "manual", "player", {outOfCombat = true})

-- Resource trackers only. Hunter creature tracking is intentionally excluded.
-- If none is active, every learned option appears so the player can choose one.
a("ALL", 2383, "Find Herbs", "tracking", "player", {tracking = true, restOnly = true, outOfCombat = true})
a("ALL", 2580, "Find Minerals", "tracking", "player", {tracking = true, restOnly = true, outOfCombat = true})
a("ALL", 43308, "Find Fish", "tracking", "player", {tracking = true, restOnly = true, outOfCombat = true})
a("ALL", 2481, "Find Treasure", "tracking", "player", {tracking = true, restOnly = true, outOfCombat = true})

U.itemGroups = {
    {key = "ITEM:healing", label = "Healing potion", rule = "health", target = "player", icon = 134831,
        -- Strongest classic potion in bags that the character can use.
        items = {13446, 3928, 1710, 929, 858, 118}},
    {key = "ITEM:mana", label = "Mana potion", rule = "mana", target = "player", icon = "Interface\\Icons\\INV_Potion_70",
        items = {13444, 6149, 3827, 3385, 2455}},
    {key = "ITEM:healthstone", label = "Healthstone", rule = "health", target = "player", icon = 135230,
        items = healthstoneItems},
    {key = "ITEM:soulstone", class = "WARLOCK", label = "Soulstone", rule = "buff", target = "friendly",
        targetedBuff = true, playerOnly = true, missingAura = true, icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
        buffAuras = {20707, 20762, 20763, 20764, 20765}, items = soulstoneItems,
        note = "Apply to a living friendly player before death; this stores their resurrection. Create a Soulstone first."},
    {key = "ITEM:soulstone:self", class = "WARLOCK", label = "Soulstone (self)", rule = "buff", target = "player",
        missingAura = true, restOnly = true, outOfCombat = true, icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
        buffAuras = {20707, 20762, 20763, 20764, 20765}, items = soulstoneItems,
        note = "Apply before combat to store your own resurrection. After death, WoW presents the Soulstone resurrection choice."},
    {key = "ITEM:bandage", label = "Bandage (self)", rule = "health", target = "player",
        restOnly = true, outOfCombat = true, bandage = true, usableSelection = true,
        icon = "Interface\\Icons\\INV_Misc_Bandage_12", blockedAuras = {11196},
        items = {14530, 14529, 8545, 8544, 6451, 6450, 3531, 3530, 2581, 1251},
        note = "Only at the health threshold outside combat. When health is private this is a reminder: use the bandage from your normal action bar."},
}
U.ruleLabels = {
    health = "Low health", pethealth = "Pet low health", mana = "Low mana",
    manahealth = "Low mana + safe health", defensive = "Low health in combat",
    interrupt = "Enemy casting", dispel = "Friendly debuff", purge = "Enemy removable buff",
    creature = "Suitable creature type", control = "Crowd control", combat = "In combat",
    buff = "Missing buff", resurrect = "Dead ally", petdead = "Dead pet", petmissing = "Missing pet",
    falling = "Falling", swimming = "Swimming", tracking = "No resource tracker active",
    missingitem = "Missing conjured item", manual = "Manual utility",
}
