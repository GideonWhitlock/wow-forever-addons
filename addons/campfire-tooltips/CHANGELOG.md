# Changelog

This file records released Campfire Tooltips: Forever versions and verified changes only. Versions 1.0.0 and 1.0.1 were originally released under the public name **Campfire Tooltips**; the public project was renamed afterward without changing those package contents.

## 1.0.2 — Release

- Added the owner-confirmed `Chair` title so the Camp Chair description appears when the client supplies no readable object ID.
- Added faction-aware `Faction Banner` recognition for Alliance and Horde players.
- Kept readable object IDs authoritative and left similar or unrelated objects unchanged.
- Audited all 39 mapped placements/services and retained their benefit, utility, duration and exclusion descriptions.
- Updated the in-game display name to **Campfire Tooltips: Forever**.
- Passed Lua 5.1 syntax checks, 241 simulated behavior assertions and all 39 placement/service ID checks.

## 1.0.1 — Release

- Expanded the one-minute campfire-buff instructions to include chair use, sleeping, lying down and kneeling alongside sitting.
- Clarified that casting and crafting are allowed during the wait.
- Kept the acquisition details on three short, separate tooltip lines.
- Preserved benefit amounts, durations, object recognition, optional buff timers and the tent's separate rested-experience instructions.

## 1.0.0 — Release

- First public release for WoW: Forever 1.60.1.
- Added concise world-object tooltip explanations for 39 researched camp placements and services.
- Added character-level benefits, acquisition requirements, durations, class-buff exclusions and profession-upgrade utilities.
- Added optional matching active-buff timers when readable.
- Added native settings and local hover diagnostics, with `/camptooltips` as a shortcut.
- Added exact English Lodestone fallback support after its world tooltip name was verified in-game.
- Left ambiguous names and unsupported identities unchanged rather than guessing.
