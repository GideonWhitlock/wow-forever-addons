# Objective Hider for RestedXP — Forever

Objective Hider for RestedXP — Forever is a focused WoW: Forever 1.60.x utility that keeps Blizzard's **All Objectives** tracker out of the screen space used by a RestedXP guide window. It does not replace, modify or redistribute RestedXP.

> Independent compatibility utility. Not affiliated with, endorsed by, or supported by RestedXP.

## What it does

- Hides only Blizzard's `ObjectiveTrackerFrame` while leaving RestedXP's guide, arrow, target controls and guide engine alone.
- Offers **Only while RestedXP is active** and **Always hide it** modes.
- Re-applies the requested state when Blizzard shows the tracker after quest, tracking, reload or zone activity.
- Defers tracker changes during combat and applies only the latest requested state afterward.
- Remembers whether Blizzard's tracker was shown before this utility took control and restores that state when hiding is disabled.
- Provides `/rxpoh`, a native AddOns settings page, and a draggable circular minimap button.
- Detects RestedXP and Questie without requiring either one and reports when Forever's tracker internals are unavailable.

The minimap button is intentionally functional: left-click toggles the core behavior, right-click opens settings, and dragging stores an angle rather than fragile screen coordinates. Its centre is recalculated from the live minimap dimensions after reload, resolution changes and UI-scale changes. Button collectors may reparent and lay it out without the add-on fighting them.

## Commands

`/rxpoh` or `/rxpoh toggle` · `/rxpoh on` · `/rxpoh off` · `/rxpoh mode rxp` · `/rxpoh mode always` · `/rxpoh status` · `/rxpoh settings` · `/rxpoh reset` · `/rxpoh recover`

Keybinding is unavailable because Forever rejected both the XML and tested runtime binding paths. Use the minimap button or `/rxpoh`.

## Install

Copy the `RXPObjectiveHiderForever` folder from `addon/` into `_classic_beta_/Interface/AddOns/`, then reload the UI. The ZIP has the same one-folder layout expected by add-on managers.

Version `1.0.0` completed owner live acceptance on 11 October 2026. It creates no keyboard-enabled frames and installs no binding or binding override. Its one-time defensive cleanup can only release input state owned by this add-on's exact withdrawn legacy frame names. The regression matrix is in [`addon/RXPObjectiveHiderForever/TESTING.md`](addon/RXPObjectiveHiderForever/TESTING.md).

## Compatibility boundary

The utility uses Blizzard's named `ObjectiveTrackerFrame` and the named RestedXP `RXPFrame` only for optional visibility detection. It never reads guide data, paid content, route data or RestedXP SavedVariables. It never changes Questie's tracker. If Blizzard renames or removes its tracker frame, hiding stops and `/rxpoh status` reports a compatibility warning rather than guessing at unrelated frames.

Public source: [GideonWhitlock/wow-forever-addons](https://github.com/GideonWhitlock/wow-forever-addons/tree/main/addons/objective-hider-for-restedxp-forever). Report issues through the repository's dedicated Objective Hider issue form.

## Licence

Code is MIT licensed. The original generated emblem is supplied for this project; its generation and processing record is in [`ARTWORK.md`](ARTWORK.md).
