# Changelog

This file records public release versions and verified changes only.

## 1.1.5 — 2026-11-11

- Removed Misspelled's pre-hook from Blizzard's protected Enter handler, fixing the remaining `/target` blocked-action fault.
- Replaced injected inline colour codes in the default chat edit box with a non-mutating `ABC?` spelling indicator.
- Preserved plain-text checking and right-click corrections without altering slash-command text.

## 1.1.3 — 2026-11-11

- Fixed messages containing highlighted misspellings sometimes disappearing when Enter was pressed.
- Moved highlight cleanup to run before WoW's chat-send handler without replacing the protected chat API.

## 1.1.2 — 2026-11-11

- Stopped replacing WoW's protected chat-send function.
- Preserved spelling-highlight cleanup in the chat edit box before manually typed messages are sent.
- Prevented Misspelled from blocking automatic announcements made by unrelated add-ons.

## 1.1.1 — 2026-10-11

- Fixed the minimap button sitting inside the minimap instead of on its border.
- Replaced the fixed placement radius with size- and scale-aware minimap-ring geometry.
- Preserved saved button angles, dragging, visibility controls and position reset behavior.

## 1.1.0 — 2026-10-03

- First CurseForge release submission for WoW: Forever 1.60.1.
- Added live spelling checks for completed words in Blizzard chat edit boxes.
- Added light-blue misspelling highlighting with configurable colour.
- Added right-click correction suggestions, Ignore All and Add to Dictionary actions.
- Added a personal dictionary editor with persistent saved words.
- Added automatic locale selection and seven bundled language dictionaries.
- Added WIM integration support and automatic acceptance of available friend and guild names.
- Added safe removal of highlight colour markers before chat messages are sent.
- Added a draggable minimap button with saved visibility and position.
- Added settings, personal-dictionary, minimap visibility and minimap reset commands.
- Bundled the required Ace3 libraries for standalone installation.
