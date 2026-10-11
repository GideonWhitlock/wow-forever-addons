# Changelog

## 1.0.0 — 2026-10-11

- Fixed Blizzard `LUA_WARNING` entries being discarded while ordinary Lua errors were counted.
- Added explicit available, limited and unavailable session-error visibility states.
- Prevented the summary and report from implying a clean error scan when Blizzard's session list cannot be read.
- Added privacy-safe transient observation of `LUA_WARNING` events as a limited fallback; raw warning text is not persisted or exported.
- Added separate Lua-error and Lua/XML-warning occurrence wording and targeted regression coverage.
- Promoted the owner-accepted Forever `1.60.1.70338` candidate to the first public release.
- Included the verified circular 32-bit TGA launcher icon and corrected visible-rim minimap geometry.
- Included status, dependency, interface, load-error, performance, recent-change and cautious error-path evidence.
- Included reversible staged enable/disable recovery, SavedVariables reset paths and the privacy-clean support report.
- Finalised public documentation, MIT licensing, issue routing and CurseForge release copy.

## 0.1.1-alpha — 2026-10-11

- Rebuilt the custom launcher artwork as a circular medallion with transparent corners and a safer small-icon inset.
- Replaced the PNG runtime texture, which rendered as a black disc in the Forever client, with a verified uncompressed 32-bit BGRA TGA at 128×128.
- Kept the corrected visible-rim orbit geometry and automatic size/scale reflow.
- Preserved existing SavedVariables and minimap angle; this update changes no user settings.

## 0.1.0-alpha — 2026-10-11

- Added a purpose-built gold-and-green shield, pulse, and inspection-lens icon so Addon Health Manager is immediately distinguishable from Gideon's other minimap buttons.
- Corrected minimap-button geometry for Forever's modern minimap artwork: the orbit now removes the frame's transparent rim padding, scales from the live map dimensions, and uses Blizzard-style icon/background/border anchors. Existing saved angles migrate automatically because radius is no longer stored.
- Added Forever 1.60.x add-on inventory and plain-language health classification.
- Added required-dependency, interface-version, load-state, and load-error evidence.
- Added modern Blizzard profiler metrics and memory context.
- Added optional read-only attribution from Blizzard’s current-session error list.
- Added conservative possible-overlap hints and recent local scan changes.
- Added a movable minimap button, slash commands, reset path, staged state changes, and undo.
- Added a privacy-clean copyable support report.
- Added research, product boundary, test gate, validation, and package documentation.

This alpha has not completed the required live in-game acceptance pass and must not be presented as a finished public release.
