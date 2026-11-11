# Keep or Toss: Forever — known-purpose tooltip data

Prepared 11 November 2026 for the Keep or Toss: Forever developer.

## Suggested implementation

Add a small item-ID override table for Forever-only items whose purpose is known but cannot be inferred reliably from ordinary quest/reagent flags. Suggested fields:

- `verdict`: `KEEP`, `USE`, or `UNSOLVED`
- `purpose`: one concise sentence
- `where`: zone and coordinates when the player must travel somewhere to use or turn in the item
- `next`: resulting item or follow-on use
- `source`: evidence URL and date checked

The tooltip should prioritise what the player must do **now**. Acquisition coordinates are useful secondary text, but use/turn-in coordinates matter most once the item is already in the bag.

## Confirmed special-purpose items

| Item | ID | Suggested tooltip text |
|---|---:|---|
| Black Tome | 276561 | **KEEP — secret boss chain.** Use beside the blue Ambermill Leyline Focus inside Ambermill Town Hall, Silverpine Forest **63.4, 64.3**, to create the Tome of Dalaran. |
| Tome of Dalaran | 275989 | **KEEP — reusable secret-boss summoner.** In the City of Dalaran dungeon, defeat Atrexis, continue straight instead of taking the right-hand ramp, and use this at the purple rune to summon **Lyn the Ignored**. Not consumed; 3-minute cooldown. |
| Ancient Heirloom | — | **KEEP/EQUIP — Dawn Waker secret.** Equip it to reveal the Highborne Spirit at Zoram Strand **15.68, 19.33**, the Ancient Hilt at Zephras **58.13, 24.06**, and later Feralas vault switches. Replacement ring: Zephras **41.7, 23.4**. |
| Ancient Hilt | — | **KEEP — Dawn Waker secret.** Take it to Ealaane Nimbuswalker on Zephras Isle **65.94, 74.37**; it is also required later with the Cleansed Water Globe. |
| Eluvi'ana | 276188 | **KEEP — Dawn Waker secret.** Carry it with the Ancient Hilt, Narassin's Tome and Befouled Water Globe to Mordent Evenshade in Shen'dralar **35.05, 46.49**. |
| Befouled Water Globe | 16408 | **KEEP — Dawn Waker secret.** With Ancient Heirloom equipped, speak to the Highborne Spirit at Zoram Strand **15.68, 19.33**. Later cleanse this at Hyjal **72.7, 37.2** using Star of Elune, Abyssal Mote and 20 Tears of Anguish. |
| Azsharan Key | 282406 | **USE — Dawn Waker secret.** Opens Narassin's Strongbox behind Athrikus Narassin at the Tower of Althalaxx, Darkshore **56.4, 26.5**, yielding Narassin's Tome. |
| Narassin's Tome | 282404 | **KEEP — Dawn Waker secret, not a library-collection book.** Return first to the Highborne Spirit at Zoram Strand **15.68, 19.33**, then carry it to Mordent Evenshade in Shen'dralar **35.05, 46.49**. |
| Star of Elune | — | **KEEP — cleansing reagent.** One of three items needed with the Befouled Water Globe at Hyjal **72.7, 37.2**. Found in the Shen'dralar Vault, Feralas **58.5, 71.6**, after four switches are activated together. |
| Abyssal Mote | — | **KEEP — cleansing reagent.** One of three items needed with the Befouled Water Globe at Hyjal **72.7, 37.2**. Loot from the underwater Abyssal Chest in Azshara **66.0, 54.1** after the Kirith-to-Azsharite chain. |
| Tears of Anguish | — | **KEEP 20 — cleansing reagent.** Twenty are needed with Star of Elune, Abyssal Mote and the Befouled Water Globe at Hyjal **72.7, 37.2**. Farm Highborne around Winterspring **53.6, 43.2** after speaking to Mordent Evenshade. |
| Cleansed Water Globe | 282699 | **KEEP — Dawn Waker secret.** Return it to Mordent Evenshade, Shen'dralar **35.05, 46.49**, then follow his lead to Prince Tortheldrin in Dire Maul. It is later used with the Ancient Hilt and Arcanum of Binding. |
| Monogrammed Silver Hair Clip | — | **TURN IN.** Bring it from the Loch Modan lake toolbox **45.6, 43.4** to Khara Deepwater on the shore **39.5, 39.2** for the Silver of the Waves secret. |
| Cozy Sleeping Bag | 211527 | **KEEP/USE.** Unroll outdoors to provide a shared Well-Rested XP bonus: 1% per minute, stacking to 3%; one-hour cooldown. |
| Student Fodder | — | **USE when rested.** Restores lost rest time while on the trail; it is a limited reward from the Cozy Sleeping Bag chain, not vendor trash. |

## Known partial purpose but still unsolved

These should not be labelled as vendor trash or as a normal unknown quest item. The honest tooltip is “keep; unresolved secret.”

| Item | Suggested tooltip text |
|---|---|
| Keystone Fragment | **KEEP — unresolved Forever secret.** The Undercity sewer fragment is used at the hidden bag outside Blackrock Spire to obtain the Stone Key. Later fragments/uses remain unsolved. |
| Stone Key | **KEEP — unresolved Forever secret.** Obtained from the hidden bag outside Blackrock Spire by carrying the Keystone Fragment. What it opens is not yet confirmed. |
| Bloody Map | **KEEP — unresolved Horde secret.** Earned through the Arathi/Wetlands chain beginning with Zaruk at **74.4, 35.6**; the destination shown by the map is not yet confirmed. |

## Library collection — shared purpose

All 40 entries below should use one shared purpose override:

> **KEEP — library collection.** Turn in one at a time to **Garion Wendell**, Stormwind Mage Tower **49.1, 86.2** (Alliance), or **Owen Thadd**, Undercity Magic Quarter **74.0, 33.0** (Horde). Each different book counts toward rewards at **10, 20 and 25** books. Rumi has two spawn locations but counts only once.

The following source coordinates are useful secondary information:

| # | Book | Source location |
|---:|---|---|
| 1 | Everyday Etiquette | Azshara 20.7, 62.0 |
| 2 | Nar'thalas Almanac, Vol. 74 | Darkshore 59.6, 22.2 |
| 3 | Demons and You | Desolace 55.1, 26.2 |
| 4 | RwlRwlRwlRwl! | Dustwallow Marsh 57.2, 20.8 |
| 5 | Northern Kalimdor — A Comprehensive Guide | Felwood 65.2, 3.3 |
| 6 | The Liminal and the Arcane | Feralas 50.6, 15.7 |
| 7 | The Lessons of Ta'zo | Orgrimmar 38.7, 78.4 |
| 8 | Fury of the Land | Stonetalon Mountains 74.4, 85.7 |
| 9 | Legends of the Tidesages | Tanaris 72.7, 47.8 |
| 10 | Arcanic Systems Manual | The Barrens 56.3, 8.8 |
| 11 | Baxtan: On Destructive Magics | The Barrens 62.7, 36.3 |
| 12 | Secrets of the Dreamers | The Barrens 46.0, 36.5; interior 52.83, 54.70 |
| 13 | Geomancy: The Stone-Cold Truth | Thousand Needles 34.4, 40.1 |
| 14 | Ka-Boom! | Winterspring 60.7, 37.7 |
| 15 | Defensive Magics 101 | Alterac Mountains 48.4, 57.6 |
| 16 | A Web of Lies: Debunking Myths and Legends | Arathi Highlands 73.6, 65.2 |
| 17 | Mummies: A Guide to the Unsavory Undead | Badlands 56.7, 39.9 |
| 18 | Conjurer's Codex | Blasted Lands 55.4, 32.2 |
| 19 | Stonewrought Design | Blackrock Mountain/Burning Steppes 29.0, 28.9 |
| 20 | Magma or Lava? | Blackrock Mountain/Burning Steppes 29.6, 28.2 |
| 21 | Crimes Against Anatomy | Duskwood 16.6, 28.5 |
| 22 | A Study of the Light | Eastern Plaguelands 71.8, 48.2 |
| 23 | Scourge: Undead Menace or Misunderstood? | Eastern Plaguelands 31.3, 21.0 |
| 24 | The Knight and the Lady | Eastern Plaguelands 47.3, 42.3 |
| 25 | Archmage Theocritus' Research Journal | Elwynn Forest 65.4, 70.1 |
| 26 | Venomous Journeys | The Hinterlands 36.0, 72.8 |
| 27 | Archmage Antonidas: The Unabridged Autobiography | Ironforge 75.7, 10.5 |
| 28 | Rumi of Gnomeregan: The Collected Works | Westfall 52.7, 53.8 or Loch Modan 35.6, 48.9; counts once |
| 29 | Runes of the Sorcerer-Kings | Loch Modan 77.4, 14.0 |
| 30 | A Mind of Metal | Searing Gorge 37.8, 49.3 |
| 31 | Ataeric: On Arcane Curiosities | Silverpine Forest 43.4, 41.2 |
| 32 | The Dalaran Digest, Vol. 23 | Silverpine Forest 63.5, 63.1 |
| 33 | Basilisks: Should Petrification be Feared? | Stranglethorn Vale 41.4, 50.9 |
| 34 | A Luddite's Guide to Caring for Your Demonic Pet | Swamp of Sorrows 61.4, 22.4 |
| 35 | Sanguine Sorcery | Swamp of Sorrows 70.0, 51.0 |
| 36 | The Apothecary's Metaphysical Primer | Tirisfal Glades 59.4, 52.3 |
| 37 | Necromancy 101 | Western Plaguelands 69.4, 72.8 |
| 38 | Undead Potatoes | Western Plaguelands 38.3, 54.6 |
| 39 | Bewitchments and Glamours | Westfall 45.4, 70.5 |
| 40 | Goaz Scrolls | Wetlands 33.6, 47.9 |

## Evidence checked

- Wowhead, Black Tome: https://www.wowhead.com/forever/item=276561/black-tome
- Warcraft Tavern, Tome of Dalaran/Lyn route: https://www.warcrafttavern.com/forever/news/tome-of-dalaran-mystery-solved-in-wow-forever/
- Wowhead, Dawn Waker walkthrough: https://www.wowhead.com/forever/guide/dawn-waker-secret-walkthrough
- Warcraft Wiki, Befouled Water Globe chain: https://warcraft.wiki.gg/wiki/Befouled_Water_Globe_(Forever)
- Wowhead, library book names and coordinates: https://www.wowhead.com/forever/quest=78142/bewitchments-and-glamours
- Method, library locations and rewards: https://www.method.gg/wow-forever/wow-forever-all-library-books-locations-and-rewards
- ForeverDB, special quest summaries: https://foreverdb.net/special-quests

This is the complete **currently documented special-purpose set covered by the cited guides**, not a claim that every one of Forever's thousands of new item records has been solved. Unconfirmed secrets are deliberately labelled unresolved rather than assigned an invented destination.
