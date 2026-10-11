# Implementation plan

## Phase 1 — evidence-led alpha (implemented)

- Modern `C_AddOns` inventory and dependency graph.
- Client/interface/load-error classification.
- Blizzard profiler and memory context.
- Optional read-only Blizzard error-store attribution.
- Conservative UI-overlap hints.
- Local scan snapshots and change context.
- Movable minimap control and slash commands.
- Staged enable/disable recovery with undo.
- Privacy-clean selectable report.
- Static validation and deterministic scanner/report tests.

## Phase 2 — owner live-test gate

- Install on the exact Forever build and verify login with Lua errors enabled.
- Test clean install, populated install, missing dependency, disabled dependency, mismatched interface, load-on-demand module, staged toggle, undo, reload, minimap movement, and SavedVariables recovery.
- Verify secret/taint behaviour around ScriptErrorsFrame on real errors.
- Review wording, visual density, colours, minimap art, and window size with the owner.
- Record every scenario that could not be reproduced.

## Phase 3 — accepted release candidate

- Address live-test findings and freeze strings.
- Capture genuine in-game screenshots at a representative UI scale.
- Finalise restrained gold-and-green CurseForge assets and copy.
- Build a clean Forever-only zip and verify folder structure from extraction.
- Push public source to `GideonWhitlock/wow-forever-addons`, verify README, changelog, MIT licence, and issue links.
- Publish only after owner acceptance; verify Source, Changelog, and Report an issue links from the public listing.
- Register with the shared maintenance process used by the accepted sibling add-ons.

## Phase 4 — public demonstration

Only after the file is genuinely downloadable: record real gameplay and prepare the full demonstration plus a purpose-built Short, first-person Gideon narration, captions, disclosures, thumbnails, playlists, links, and an analytics follow-up checkpoint.
