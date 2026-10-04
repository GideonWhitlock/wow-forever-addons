# Thanks for Buffing: Forever

Thanks for Buffing: Forever is a lightweight World of Warcraft addon that privately thanks another player after they give you a helpful buff.

It waits a random 3–10 seconds, chooses one of 15 short replies, and sends the response as a whisper. Several buffs from the same player are combined into one thank-you, and the same player will not receive another for 10 minutes.

## Features

- Sends thank-you messages by whisper only
- Uses 15 short, natural replies
- Waits a random 3–10 seconds before replying
- Combines several buffs from one player into one response
- Limits each caster to one thank-you every 10 minutes
- Remains silent while you are in a party, dungeon group, or raid
- Avoids protected combat and chat operations on modern clients
- Supports WoW Forever 1.60.1 and the other packaged WoW flavours

## Commands

- `/tftbf` or `/tftbf status` — show whether the addon is enabled
- `/tftbf on` — enable the addon
- `/tftbf off` — disable the addon
- `/tftbf debug` — toggle local detection messages for troubleshooting

## Installation

1. Download the release ZIP.
2. Extract the `ThanksForTheBuffForever` folder into the appropriate `World of Warcraft/<client>/Interface/AddOns` directory.
3. Restart the game or type `/reload`.

## Supported clients

Version 1.0.1 includes TOCs for:

| Client | Interface |
| --- | ---: |
| WoW Forever 1.60.1 | 16001 |
| Retail | 120100 |
| Mists of Pandaria Classic | 50504 |
| Burning Crusade Classic | 20506 |
| Classic Era | 11509 |

The Forever compatibility path has also been reviewed against installed build `1.60.1.70205`.

## How detection works

On WoW Forever and modern Retail, Blizzard restricts combat-log and chat data. The addon listens for newly added helpful auras outside combat. It uses the aura's caster when Blizzard supplies one; when the caster is omitted, it can correlate the aura with the same spell just cast by one visible nearby player.

The addon deliberately skips a buff when Blizzard hides the information needed to identify its caster, when the player is in combat, when chat messaging is locked, or when more than one possible caster would make attribution unsafe. This avoids protected-action errors and accidental whispers to the wrong player.

Classic clients use the combat log, which provides broader caster attribution.

## Important behaviour

- The 10-minute caster cooldown is held in memory and resets after logout or `/reload`.
- WoW's chat service can occasionally delay delivery after the addon has submitted a whisper.
- A buff is never thanked while you are grouped, including normal parties, dungeon groups, and raids.
- Debug messages are local and do not send extra chat messages.

## Privacy

The addon stores only its enabled/disabled and debug settings in `ThanksForTheBuffForeverDB`. It does not collect analytics or transmit data outside the one in-game whisper it sends.

## Repository layout

- `addon/ThanksForTheBuffForever/` — the exact addon source and TOCs included in release 1.0.1
- `tests/` — standalone Lua behaviour tests for Forever and Classic detection paths
- `.github/ISSUE_TEMPLATE/` — the project-specific public bug-report form

The tests use a small mocked WoW API surface and do not replace in-game verification. They cover the 3–10 second delay, whisper-only delivery, ten-minute duplicate suppression, group/combat/chat-lock cancellation, secret-value handling, ambiguous caster rejection, SavedVariables preservation, and the Forever 1.60.1.70205 interface path.

## Support

Please use the repository's bug-report form. Include the WoW client, full build number, whether you were grouped or in combat, and the output shown after enabling `/tftbf debug`. Do not post account details, private chat, or other sensitive information.

## License

All Rights Reserved. See [LICENSE.md](LICENSE.md).
