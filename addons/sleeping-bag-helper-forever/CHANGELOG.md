# Changelog

## 0.1.5 — 2026-11-11

- Restore only ordinary player spellcast start, sent and success listeners after the minimal build loaded safely.
- Keep all protected chat, item-use, raid-marker, secure-button, cooldown and combat-log paths disabled.
- Record the most recent player spell event and ID for `/sbf debug` diagnostics.

## 0.1.4 — 2026-11-11

- Temporarily reduce the add-on to settings, `/sbf test` and the ordinary message-preparation button.
- Confirm the preparation button can fill and send the correct party message without a protected-action warning.

## 0.1.3 — 2026-11-11

- Remove all secure-action, protected item-use and automatic raid-marker calls after Forever rejected them.
- Use ordinary cast and cooldown events to detect the bag.
- Show a normal button that prepares the correct chat message; the player presses Enter to send it.
- Retain the optional local confirmation sound without attempting a protected party marker.

## 0.1.2 — 2026-11-11

- Replace blocked automatic chat calls with a Blizzard-compliant secure announcement button.
- Show the button when the sleeping bag is detected and send the appropriate `/say` or `/party` message only after a real player click.
- Prevent the add-on from triggering the Blizzard protected-action warning.

## 0.1.1 — 2026-11-11

- Detect the Cozy Sleeping Bag directly when used from a bag or action bar.
- Resolve the bag's current spell ID from the Forever client instead of relying only on a fixed ID.
- Cover sent, started, channelled, succeeded and combat-log cast events.
- Add `/sbf test` for an immediate announcement check without consuming the bag cooldown.
- Add `/sbf debug` to report the resolved item spell and current settings.

## 0.1.0 — 2026-11-11

- Added player-only detection for the `Unroll Bag` cast.
- Added a solo `/say` invitation for players who want the XP buff.
- Added a grouped `/party` explanation covering staying still and the 1%/2%/3% stacking XP bonus.
- Added a 30-second duplicate guard for cast-start and cast-success events.
- Added saved master, solo and party toggles plus status and reset commands.
- Added safe handling for unavailable or restricted chat messaging.
- Added a party-only Moon marker to the sleeping-bag owner after a successful cast.
- Added an optional confirmation sound, existing-marker protection and automatic Moon removal after three minutes.
