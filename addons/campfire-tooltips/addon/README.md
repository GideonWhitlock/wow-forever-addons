# Campfire Tooltips

Adds short, separated benefit lines to the normal tooltip when you hover over a recognised camping object. The original name, game information and tooltip position are preserved. This is a standalone addon; it does not require Feed Pet, CampfireStory or Tweaks Forever.

## Use

Hover over the object in the world. No click or target is needed.

Open **Options → AddOns → Campfire Tooltips** to enable/disable descriptions or the optional current-buff timer. `/camptooltips` opens the same page. Changes apply on the next hover.

“At your level” is the predicted benefit from the checked game data. “Your buff” is the remaining time of your exact corresponding active buff, regardless of where you received it. The tent's “Ready again” line is its repeat cooldown.

Camp benefits require an associated campfire. A description explains what an object provides; it does not confirm that its campfire is still present.

For the one-minute campfire buffs, you can sit, use a chair, sleep, lie down or kneel. Casting and crafting are allowed during the wait. The tent has its own acquisition instructions and cooldown.

## Install or remove

Extract the ZIP's `CampfireTooltips` folder into your active client's `Interface/AddOns` folder. The layout must be `Interface/AddOns/CampfireTooltips/CampfireTooltips.toc`. Restart the game if installing for the first time. Existing installations can reload the interface after an update.

Verified installation: `World of Warcraft/_classic_beta_/Interface/AddOns/CampfireTooltips`.

To remove, exit the game and remove only that folder. Preferences are stored separately in the account's `SavedVariables/CampfireTooltips.lua` file. Removing the addon does not remove preferences.

## Scope and limits

Checked against **WoW: Forever 1.60.1, build 70009, Interface 16001**, English client, 27 September 2026. The mapping covers 39 researched placements, including profession upgrades and three camp service creatures. See **SUPPORTED.md** for the full list and **TESTING.md** for the distinction between data verification and actual in-game tests.

Version **1.0.1** updates the campfire instructions for the September 24 eligibility changes reported in the maintenance audit. Local checks were run on 28 September; the last actual in-game checks remain those for 1.0.0 on 27 September. The newly described poses have not been tested in-game by this project.

Object IDs take priority. There are 27 distinctive exact English name fallbacks, used only for world-object tooltips without a readable GUID. This client exposed no object IDs in the observed real hovers. Entries marked “ID only” in SUPPORTED.md therefore cannot be recognised in those tooltips. Generic names such as “Chair” or “Anvil” alone are insufficient and are left unchanged. Most profession upgrade names still need a live check. Unrecognised objects and unrelated items, spells, players and creatures are left unchanged.

Numerical predictions are shown only on the checked build and with a readable level from 1–60. After a client update, general descriptions remain available but need rechecking against that build. Hotfixes can also change data. Restricted or unavailable active-buff information is omitted; it is never treated as “not active”. Timers refresh on the next tooltip refresh or hover.

The campfire describes its function and capacity; it does not scan the campsite or promise that every possible buff is present.

## Optional checks

The settings page has clickable **Start hover checks**, **Refresh report** and **Reload interface** buttons. Recording stops on reload. Up to 25 readable world-object/camp-service observations and a local report are saved. Player names and unrelated creature names are not recorded. Nothing is uploaded. Cached spell descriptions may need a second refresh to appear.

## Maintenance

`Data.lua` holds effects, level brackets, spell IDs and placement IDs. `Names.lua` holds exact language-specific fallback names. Both are generated from `tools/build_data.py` and checked research records; update the generator as well as any hand edits. `Core.lua` handles safe identification and tooltip additions; `Settings.lua` provides the native settings page. The source bundle includes the generator, reduced research records and simulated tests. No Python, external library or executable is needed in-game.

The display name stays **Campfire Tooltips** in every update. Version numbers belong in metadata, not the name.

Licence: GPL-3.0-or-later. See LICENSE, NOTICE.md and SOURCES.md.
