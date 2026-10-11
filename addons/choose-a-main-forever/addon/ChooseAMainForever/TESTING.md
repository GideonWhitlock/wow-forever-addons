# Testing

## Automated run

The portable Lua suite is `Tests/run.lua`. It loads only the data and engine modules, so recommendation logic can be exercised without the WoW UI.

With a Lua 5.1-compatible interpreter:

```text
lua Tests/run.lua <absolute path to ChooseAMainForever>
```

The prepared development run used Fengari and passed 14/14 engine assertions plus a mocked UI construction/navigation smoke test on 11 October 2026. See `TEST-REPORT.md`.

## Required contrasting profiles

Before a public release, review at least:

1. solo explorer
2. dedicated healer
3. group tank
4. competitive PvP player
5. mobile melee specialist
6. stationary spellcaster enthusiast
7. pet-focused adventurer
8. utility-first tactician
9. casual player with limited time
10. flexible multi-role player
11. strong roleplay and lore enthusiast
12. control-over-damage player
13. high-complexity player
14. contradictory preferences
15. restrictive race/faction case

The suite already covers determinism, all 27 paths, every answer choice, class/role/race/stationary exclusions, impossible restrictions, incomplete confidence, material role changes, different-class headlines, history weighting and explanation consistency.

## In-game acceptance

Follow `IN-GAME-CHECKLIST.md`. Automated tests do not prove UI rendering, SavedVariables persistence or live client compatibility.
