# Changelog

## 1.0.2 — 2026-10-16

- Fixed Blizzard's objective tracker reappearing when combat starts.
- Re-applies the hidden state immediately if Blizzard shows the tracker during combat.
- Continues to defer any action that could restore or show the tracker until combat ends.

## 1.0.1 — 2026-10-11

- Standardised the public and in-game title to **Objective Hider for RestedXP: Forever**.
- No gameplay behaviour or SavedVariables changed.

## 1.0.0 — 2026-10-11

- Promoted the owner-accepted Forever 1.60.1 build to the first public release.
- Confirmed normal keyboard control after a full client restart with the corrected no-keybinding build.
- Kept the scoped legacy-input cleanup, combat deferral, RestedXP-aware/always-hide modes, state restoration and single-layer circular minimap control.
- Completed automated syntax, boundary, behavior, packaging, artwork, minimap-geometry and legacy-cleanup validation.

## 0.1.4-alpha — 2026-10-11

- Added defensive startup recovery for the withdrawn 0.1.1 keyboard experiment.
- Clears override bindings only from the exact legacy `RXPObjectiveHiderForeverBindingOwner` frame, when that frame exists.
- Disables keyboard capture, restores propagation and removes key scripts only from the exact legacy settings frame.
- Clears focus only when the focused frame name begins with `RXPObjectiveHiderForever`.
- Removes obsolete `toggleKey` data from the active and backup profiles.
- Creates no binding owner, binding button, keyboard-enabled frame or override binding.
- Added isolation acceptance: enable only Objective Hider first and verify all movement/chat/menu input.

## 0.1.3-alpha — 2026-10-11

- Rebuilt from a clean folder after the unsafe keyboard-capture regression report.
- Added automated rejection of keyboard-enabled frames, keyboard event interception, binding mutation and binding overrides.
- Confirmed the add-on contains no binding XML, binding Lua module, binding globals or keyboard propagation calls.
- Preserved only minimap-click and slash-command controls.
- Retained the single-layer circular minimap artwork fix.
- Requires a full client exit and relaunch to destroy frames created by the unsafe prior session.

## 0.1.2-alpha — 2026-10-11

- Removed the unverified runtime keybinding implementation after Forever exposed no callable binding-owner method.
- Removed every add-on manifest and Lua reference to `Bindings.xml` and `KeyBinding.lua`.
- Kept the minimap left-click and `/rxpoh` toggles as the supported controls.
- Retained the single-layer circular minimap artwork fix from 0.1.1.
- Requires one full client exit and relaunch after upgrading from 0.1.0/0.1.1 because the running process cached the old TOC manifest.

## 0.1.1-alpha — 2026-10-11

- Removed `Bindings.xml`, which Forever 1.60.1 rejected with `Unrecognized XML: Binding`.
- Tried an in-settings runtime key capture; removed in 0.1.2 after live Forever rejection.
- Removed the minimap status glyph and duplicate highlight texture that could render beside the circular icon.
- Kept one centred RGBA texture layer; ON remains full-colour, OFF remains desaturated, and the tooltip names the state.
- Preserved the SavedVariables schema and existing mode, enabled state and minimap angle.
- Added regression checks for forbidden binding XML and extra launcher texture/font layers.

## 0.1.0-alpha — 2026-10-11

- Built the first local Forever 1.60.1 test version.
- Added RestedXP-aware and always-hide modes.
- Added conservative Blizzard tracker suppression, `OnShow` re-hide and combat deferral.
- Added captured-state restoration, reset and backup recovery.
- Added slash commands, key binding and native AddOns settings page.
- Added a draggable circular minimap toggle with angle-based rim anchoring and ON/OFF visuals.
- Added RestedXP, Questie and tracker diagnostics.
- Added automated source, package, texture, geometry and behavior validation.
- Marked live in-game verification and owner acceptance as required before publication.
