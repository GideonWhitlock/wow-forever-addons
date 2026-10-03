# Changelog

All released versions of Night Watch Torch Helper: Forever are listed here. The in-game add-on name is **Night Watch Torch**.

## [1.0.2] — 2026-09-27

### Fixed

- Prevented the reminder from reappearing while the Night Watchman's Torch illumination buff is already active.
- Added checks for both known torch aura IDs and matching active helpful-buff names.
- Added localized item and spell names to buff matching.
- Suppressed the reminder when aura information is unavailable or restricted.

### Changed

- Recognized an existing matching illumination buff regardless of which player supplied it.
- Changed the tooltip reason to **Night-time** for readability.
- Added regression coverage for stopping while buffed, buff removal, alternate or localized buff names, and click or key attempts while the buff is active.

## [1.0.1] — 2026-09-27

### Added

- Added a draggable minimap torch icon with saved positioning.
- Added a settings panel for reminders, temporary dim areas, button size and button arrangement.
- Added `/nwt options` and `/nwt minimap show|hide` commands.
- Added right-click arrangement control to the minimap icon.

### Preserved

- Kept the existing torch eligibility, secure click, bag, weather and travel rules.

## [1.0.0] — 2026-09-27

### Added

- Released the initial WoW: Forever version.
- Added a movable and resizable click-to-use torch button and optional keybinding.
- Added carried-bag ownership, item readiness, cooldown and click-time inventory checks.
- Added game-reported night-time and non-clear weather detection.
- Added a temporary manual dim-area option for visual fog or darkness not reported by the game.
- Added movement, combat, mount, taxi, vehicle, falling, swimming, casting and channeling gates.
- Added secure combat hiding and disarming without automatic item use.
