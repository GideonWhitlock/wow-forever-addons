# Thanks for Buffing: Forever

Thanks for Buffing: Forever notices when another player gives you a helpful buff, waits a random 3–10 seconds, and sends that player one natural-sounding thank-you by whisper.

## Features

- 15 short, natural thank-you messages selected at random
- A genuinely random 3–10 second delay
- Whispers only — never party, raid, say, or public chat
- Coalesces several buffs from the same player into one thank-you
- One reply per player every 10 minutes to avoid spam
- Uses a settling baseline to ignore pre-existing auras restored just after login, reloads and world transitions
- Ignores self-cast and non-player-owned effects such as tracking auras and totems
- Silently excludes confirmed system/zone state auras such as Honorless Target
- Never thanks party or raid members, but still thanks an external player who buffs you while you are grouped
- Enabled by default, with simple slash commands
- Native support for WoW Forever 1.60.1
- Also packaged for current Retail, Mists Classic, Burning Crusade Classic, and Classic Era

## Commands

- `/tftbf` or `/tftbf status` — show status
- `/tftbf on` — enable the addon
- `/tftbf off` — disable the addon
- `/tftbf debug` — enable or disable local diagnostics for the current session; diagnostics always start off after login or `/reload`

## Installation

Extract the `ThanksForTheBuffForever` folder into your game client's `Interface/AddOns` folder, then restart the game or type `/reload`.

## Modern client note

WoW Forever and modern Retail use Blizzard's protected addon API. Forever can restore long-lived auras after `PLAYER_ENTERING_WORLD`, so the addon waits two seconds and establishes a second settling baseline before arming detection. Aura updates during that window are treated as existing state and can never schedule a thank-you. It then listens for global aura changes and filters them to the player. It uses incremental aura data when Blizzard provides it; otherwise it compares complete helpful-aura snapshots to find newly added buffs. The `isFromPlayerOrPlayerPet` field means the aura came from any player or player pet, not necessarily your own character, so the addon resolves the actual caster before deciding whether the buff is external. Known self-cast and non-player-owned effects are discarded by caster identity, with a small verified exclusion set for source-less internal auras such as Stealth. When the ordinary aura record omits `sourceUnit`, it asks WoW for the authoritative caster GUID of that exact aura instance and resolves the player's whisper name from that GUID. Forever whisper targets always use the bare display name because this branch rejects realm-qualified targets even when its unit APIs expose a realm label. The normalized recipient name also coalesces multiple aura records from that player into one pending response and one ten-minute cooldown. Direct aura refresh and visible-cast correlation remain conservative fallbacks. Blizzard may still hide all identifying information or temporarily lock addon chat; those buffs are safely ignored instead of guessing or attempting a protected action. Classic clients expose broader combat-log information and therefore provide wider detection.

Forever beta builds are identified by their 1.60.x interface number as well as by Blizzard's project constants, because some beta builds do not expose a dedicated Forever project constant.

## Privacy and chat

The addon stores only its enabled/disabled setting. Diagnostic mode is session-only, starts off on every load, and is never saved. The addon does not collect or transmit data beyond the single in-game whisper it sends to the player who buffed you.

## License

All Rights Reserved.
