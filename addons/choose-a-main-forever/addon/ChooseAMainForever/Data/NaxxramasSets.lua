local _, NS = ...

-- Original Classic Naxxramas class sets. The results model uses the client's
-- own item appearances; no Blizzard artwork is bundled with the add-on.
NS.naxxramasSets = {
    WARRIOR = {22418,22419,22416,22423,22421,22422,22417,22420}, -- Dreadnaught
    PALADIN = {22427,22428,22425,22424,22430,22431,22426,22429}, -- Redemption
    HUNTER = {22438,22439,22436,22443,22441,22442,22437,22440}, -- Cryptstalker
    ROGUE = {22478,22479,22476,22483,22481,22482,22477,22480}, -- Bonescythe
    PRIEST = {22514,22515,22512,22519,22517,22518,22513,22516}, -- Faith
    SHAMAN = {22466,22467,22464,22471,22469,22470,22465,22468}, -- Earthshatterer
    MAGE = {22498,22499,22496,22503,22501,22502,22497,22500}, -- Frostfire
    WARLOCK = {22506,22507,22504,22511,22509,22510,22505,22508}, -- Plagueheart
    DRUID = {22490,22491,22488,22495,22493,22494,22489,22492}, -- Dreamwalker
}

NS.naxxramasSetNames = {
    WARRIOR="Dreadnaught", PALADIN="Redemption", HUNTER="Cryptstalker",
    ROGUE="Bonescythe", PRIEST="Faith", SHAMAN="Earthshatterer",
    MAGE="Frostfire", WARLOCK="Plagueheart", DRUID="Dreamwalker",
}
