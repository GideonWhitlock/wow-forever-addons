# Test notes — 1.0.1

## Release acceptance

The owner explicitly accepted the installed `0.1.3-alpha` behaviour for launch on 11 October 2026. Version `1.0.1` adds matching green selected/red unselected styling to the Weekdays and Weekends selector; reminder logic, Local/Server behaviour and the circular gold icon remain unchanged. The installed client was WoW: Forever `1.60.1.70338`, interface `16001`.

Unchecked scenarios below remain useful regression coverage and are not silently represented as observed.

## Automated checks

- Lua syntax parsing for every packaged `.lua` file.
- TOC interface, version, SavedVariables and file-order checks.
- Installable folder and ZIP-root structure checks.
- Static privacy/safety check for chat-send, add-on communications, HTTP/network, protected-action and forced-logout surfaces.
- Behavioural checks for duration, clock and snooze input boundaries.
- Documentation checks that public links point to the intended repository paths.

Run `tests/validate.py` with Python and `luaparser` available.

## Required live Forever pass

Not yet performed. Record the client version/build and result for every line.

- [ ] Clean install opens without Lua errors.
- [ ] Minimap button appears, moves, persists and can be restored with `/grf show`.
- [ ] The pocket-watch-and-leaf emblem loads in the AddOns list, settings header, reminder card and minimap button without a green texture error.
- [ ] At the minimap button's 30 px display size, the pale watch face and green leaf remain distinguishable at 100%, 125% and 150% UI scale.
- [ ] The emblem's circular gold rim is not clipped, all four corners are transparent, and no square tile appears in Minimap Button: Forever or another collector.
- [ ] The circular hover highlight follows the icon rather than drawing a square.
- [ ] On the normal minimap, compare at native size: the icon's outer diameter, inset and two-tone gold edge look consistent with Blizzard launcher icons without obscuring the watch or leaf.
- [ ] In Minimap Button: Forever, compare directly with neighbouring collected icons: the gold rim should read at roughly the same apparent thickness, with no return of the square tile.
- [ ] Settings remain usable at 100%, 125% and 150% UI scale and at 1920×1080 or smaller.
- [ ] Weekday/weekend interval and text changes persist across `/reload` and a full client restart.
- [ ] An existing `0.1.1-alpha` bedtime such as `21:30` migrates unchanged and explicitly selects Local time.
- [ ] Local selected: Local time is green, Server time is red, the hint says Local time, and a reminder fires only on the local clock.
- [ ] Server selected: Server time is green, Local time is red, the hint says Server time, and a reminder fires only on the server clock.
- [ ] Switch Local → Server, run `/reload`, and confirm Server remains green and is the clock used; then switch Server → Local, reload again, and confirm Local remains green and is used.
- [ ] Hover and press both options: labels remain readable, the colours brighten/darken without swapping meaning, and neither selected option appears disabled or grey.
- [ ] The displayed local clock, server clock and offset agree with the game clock and operating-system clock; repeat with a deliberately different offset if the realm currently matches local time.
- [ ] With Local time selected, a reminder fires in its configured local minute and the next occurrence remains correct across the spring-forward and fall-back daylight-saving boundaries.
- [ ] With Server time selected, a reminder fires in its configured server minute and uses the server calendar day for weekday/weekend selection.
- [ ] A server bedtime just after midnight is scheduled on the next server day when the current server time is just before midnight.
- [ ] Logging in well after a missed bedtime schedules the next occurrence instead of showing a stale reminder immediately.
- [ ] `/grf remind 20s Test` fires once; cancellation removes it; an overdue reminder after login behaves acceptably.
- [ ] Recurring countdown preserves remaining logged-in time across `/reload` and a client restart.
- [ ] Reminder due during combat remains hidden, then appears after `PLAYER_REGEN_ENABLED`.
- [ ] A visible reminder is hidden/re-queued when combat starts.
- [ ] Reminder due during a cinematic remains hidden, then appears after `CINEMATIC_STOP`.
- [ ] A visible reminder is hidden/re-queued when a cinematic starts.
- [ ] Visual-off mode falls back to a local chat line only; no public or group chat is produced.
- [ ] Sound is gentle and obeys the expected SFX channel.
- [ ] Speech is off by default; when enabled it uses a local installed voice, does not overlap, and fails silently if unavailable.
- [ ] Midnight date rollover separates daily totals correctly.
- [ ] `/grf reset` and `/grf recover` preserve the documented rollback behaviour.
- [ ] Disable/re-enable, logout/login, character switch and other add-on coexistence produce no errors.
- [ ] Default wording is accepted by the owner as warm, non-patronising and non-medical.

## Known unverified areas

All live-client behaviour above, the exact Forever sound-kit result, TTS voice availability, cinematic event coverage for every scene type, and visual fit with third-party UI replacements remain unverified. Do not publish a release file or compatibility claim until the required pass is accepted.

