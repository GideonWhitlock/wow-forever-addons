# Changelog

## 1.0.1 — 2026-10-11

- Made the active Weekdays or Weekends profile use the same green selected state as the Local/Server time selector.
- Kept the inactive profile red and both profile buttons fully clickable.

## 1.0.0 — 2026-10-11

- Promoted the owner-accepted `0.1.3-alpha` candidate to the first public release without changing its behaviour.
- Supports WoW: Forever `1.60.1.70338`, interface `16001`.
- Includes weekday/weekend recurring reminders, one-off timers, bedtime reminders, neutral session/daily totals and configurable snoozes.
- Includes combat/cinematic deferral and visual, sound and opt-in spoken delivery.
- Includes the explicit Local time / Server time bedtime selector, persisted clock basis, live clock/offset display, midnight rollover and local daylight-saving handling.
- Includes the circular transparent pocket-watch-and-leaf icon with the accepted thick gold collector border.
- Keeps all reminder text and activity data local; no telemetry, group communication, advertising, forced logout or moralising.
- Includes reset/recovery, migration, public documentation, MIT licence and privacy-conscious GitHub issue routing.

## 0.1.3-alpha — 2026-10-11

- Replaced the ambiguous disabled-looking bedtime selector state with explicit colour states.
- The clock source actually used by scheduling is now always green; the other available choice is red.
- Added distinct normal, hover, pressed and genuinely disabled styles while keeping both choices clickable.
- Centralised bedtime-basis selection and scheduling context so the visual state, SavedVariables and calculation cannot choose different sources.
- Added a regression test that selects both bases, simulates a reload and confirms scheduling uses the saved green selection.
- Reinforced the circular icon with a brighter, substantially thicker two-tone gold rim matching neighbouring launcher edge weight without reducing the watch-and-leaf subject.
- Added an automated nine-pixel annulus coverage check and an actual 30-pixel collector-bar comparison.

## 0.1.2-alpha — 2026-10-11

- Added an explicit Local time or Server time basis for bedtime reminders, defaulting migrated and new settings to Local time.
- Added a live local/server clock comparison and offset to settings, status output and the minimap tooltip.
- Added rollover-aware bedtime scheduling; local scheduling constructs each calendar occurrence so daylight-saving changes are respected.
- Changed offline bedtime handling to schedule the next occurrence instead of firing an hours-late reminder after login.
- Rebuilt the generated emblem as a circular RGBA texture with transparent corners and removed the launcher's square backdrop.
- Added automated migration, deliberate +05:30 offset, midnight rollover, daylight-saving and icon-alpha checks.

## 0.1.1-alpha — 2026-10-11

- Added the original pocket-watch-and-leaf artwork as a WoW-compatible 128×128 TGA texture.
- Applied the emblem consistently to add-on metadata, the minimap button, settings header and reminder card.
- Added minimap-size preview assets and live checks for visibility, clipping and texture loading.

## 0.1.0-alpha — 2026-10-11

- Added weekday and weekend recurring reminder profiles.
- Added private one-off “remind me in” timers and a quick-add dialog.
- Added optional bedtime reminders, custom personal text, and neutral session/today totals.
- Added configurable snooze choices and visual, sound, and opt-in spoken delivery.
- Added combat and cinematic deferral, including re-queuing a visible reminder when either begins.
- Added a movable minimap button, slash commands, safe defaults, reset, and backup recovery.
- Added local-only storage, retention-limited daily totals, input validation, localisation-ready strings, and privacy-focused issue routing.
- Marked all live-client scenarios unverified pending owner acceptance and a full Forever test pass.

