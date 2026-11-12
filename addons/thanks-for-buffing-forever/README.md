# Thanks for Buffing: Forever

Thanks for Buffing: Forever is a lightweight World of Warcraft addon that privately thanks another player after they give you a helpful buff.

It waits a random 3–10 seconds, chooses from a player-editable list of 15 default replies, and sends the response as a whisper. Several buffs from the same player are combined into one thank-you, and one continuous buff can never be replayed as another thank-you.

## Features

- Sends thank-you messages by whisper only
- Lets players list, add, remove and reset saved thank-you phrases in game
- Uses 15 short, natural replies
- Waits a random 3–10 seconds before replying
- Combines several buffs from one player into one response
- Limits each caster to one thank-you every 10 minutes and one thank-you per continuous aura application
- Never thanks party or raid members, but still thanks an external player who buffs you while you are grouped
- Avoids protected combat and chat operations on modern clients
- Supports WoW Forever 1.60.1 and the other packaged WoW flavours

## Commands

- `/tftbf` or `/tftbf status` — show whether the addon is enabled
- `/tftbf on` — enable the addon
- `/tftbf off` — disable the addon
- `/tftbf debug` — toggle diagnostics for the current session; always off after login or `/reload`
- `/tftbf phrases` — show the numbered thank-you phrase list
- `/tftbf phrases add <text>` — add a new phrase
- `/tftbf phrases remove <number>` — remove a phrase by its displayed number
- `/tftbf phrases reset` — restore the 15 defaults

## Installation

1. Download the release ZIP.
2. Extract the `ThanksForTheBuffForever` folder into the appropriate `World of Warcraft/<client>/Interface/AddOns` directory.
3. Restart the game or type `/reload`.

## Supported clients

The prepared version 1.0.18 includes TOCs for:

| Client | Interface |
| --- | ---: |
| WoW Forever 1.60.1 | 16001 |
| Retail | 120100 |
| Mists of Pandaria Classic | 50504 |
| Burning Crusade Classic | 20506 |
| Classic Era | 11509 |

Only the Forever path is currently claimed for release targeting. Version 1.0.18 retains the exact caster/spell safeguards from 1.0.17 and adds a persistent player-editable phrase list. Live testing previously confirmed that Forever blocks combat-log registration, so that API remains disabled on this branch. The other manifests remain source-visible but are not live-verified release targets.

The 1.0.18 source passes fourteen automated behaviour suites, including phrase editing, the observed multi-word recipient failures, protected aura fields, the Dax grouped-buff replay and the unsafe unrelated-recipient fallback.

## How detection works

On WoW Forever and modern Retail, Blizzard restricts combat-log and chat data. The addon absorbs late-restored login and reload auras into a two-second settling baseline before arming detection. It then listens for newly added and updated helpful auras outside combat. Blizzard's `isFromPlayerOrPlayerPet` field describes any player or player pet, so the addon resolves the actual caster identity instead of treating that field as a self-cast marker. It uses the aura's source unit when supplied, even when unrelated ownership or spell fields are protected. If `sourceUnit` is omitted, it queries the caster GUID attached to that exact aura instance and resolves the player's whisper name from the GUID. Forever combines the first name and surname returned separately by its APIs. The exact caster and spell application is remembered even when it is suppressed for being grouped or inside the cooldown. A same-instance update is only accepted as a genuine reapplication when its readable expiration time moves forward. Recent nearby chat remains an exact GUID-matched name source, while anonymous aura correlation now requires the same spell; a merely recent targeted caster is never guessed. The protected combat log is not registered on Forever.

The addon deliberately skips a buff when Blizzard hides the information needed to identify its caster, when the player is in combat, when chat messaging is locked, or when more than one possible caster would make attribution unsafe. This avoids protected-action errors and accidental whispers to the wrong player.

Classic clients use the combat log, which provides broader caster attribution.

## Important behaviour

- The 10-minute caster cooldown is held in memory and resets after logout or `/reload`.
- The same continuous aura is not thanked again after leaving a group, changing zones or reaching the end of the cooldown.
- WoW's chat service can occasionally delay delivery after the addon has submitted a whisper.
- A party or raid member is never thanked. An external player remains eligible even while you are grouped.
- Debug messages are local and do not send extra chat messages.

## Privacy

The addon stores its enabled/disabled setting and local phrase list in `ThanksForTheBuffForeverDB`. Diagnostic mode is session-only, starts off on every login or `/reload`, and is never saved. It does not collect analytics or transmit data outside the one in-game whisper it sends.

## Repository layout

- `addon/ThanksForTheBuffForever/` — the prepared version 1.0.18 source and TOCs
- `tests/` — standalone Lua behaviour tests for Forever and Classic detection paths
- `.github/ISSUE_TEMPLATE/` — the project-specific public bug-report form

The tests use a small mocked WoW API surface and do not replace in-game verification. They cover the 3–10 second delay, whisper-only delivery, ten-minute duplicate suppression, group/combat/chat-lock cancellation, secret-value handling, ambiguous caster rejection, complete Forever names, refreshed auras, SavedVariables preservation, and the current Forever 1.60.1 API model.

## Support

Please use the repository's bug-report form. Include the WoW client, full build number, whether you were grouped or in combat, and the output shown after enabling `/tftbf debug`. Do not post account details, private chat, or other sensitive information.

- [Report an issue](https://github.com/GideonWhitlock/wow-forever-addons/issues/new/choose)
- [Source](https://github.com/GideonWhitlock/wow-forever-addons/tree/main/addons/thanks-for-buffing-forever/addon)
- [Changelog](https://github.com/GideonWhitlock/wow-forever-addons/blob/main/addons/thanks-for-buffing-forever/CHANGELOG.md)

## License

All Rights Reserved. See [LICENSE.md](LICENSE.md).
