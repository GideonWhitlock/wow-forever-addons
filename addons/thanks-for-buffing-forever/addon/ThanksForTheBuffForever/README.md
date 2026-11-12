# Thanks for Buffing: Forever

Thanks for Buffing: Forever notices when another player gives you a helpful buff, waits a random 3–10 seconds, and sends that player one natural-sounding thank-you by whisper.

## Features

- 15 short, natural thank-you messages selected at random
- A persistent editable phrase list: view, add, remove or restore phrases in game
- A genuinely random 3–10 second delay
- Whispers only — never party, raid, say, or public chat
- Coalesces several buffs from the same player into one thank-you
- One reply per player every 10 minutes and one reply per continuous aura application
- Uses a settling baseline to ignore pre-existing auras restored just after login, reloads and world transitions
- Detects newly added buffs and accepts updated aura instances only when their expiry proves a genuine reapplication
- Ignores self-cast and non-player-owned effects such as tracking auras and totems
- Silently excludes confirmed system/zone state auras such as Honorless Target
- Never thanks party or raid members and remembers that suppression so an old dungeon buff cannot replay after leaving
- Always uses the complete Forever first name and surname for whisper recipients
- Enabled by default, with simple slash commands
- Native support for WoW Forever 1.60.1
- Also packaged for current Retail, Mists Classic, Burning Crusade Classic, and Classic Era

## Commands

- `/tftbf` or `/tftbf status` — show status
- `/tftbf on` — enable the addon
- `/tftbf off` — disable the addon
- `/tftbf debug` — enable or disable local diagnostics for the current session; diagnostics always start off after login or `/reload`
- `/tftbf phrases` — show the numbered thank-you phrase list
- `/tftbf phrases add <text>` — add a new phrase
- `/tftbf phrases remove <number>` — remove a phrase by its displayed number
- `/tftbf phrases reset` — restore the 15 default phrases

## Installation

Extract the `ThanksForTheBuffForever` folder into your game client's `Interface/AddOns` folder, then restart the game or type `/reload`.

## Modern client note

WoW Forever and modern Retail use Blizzard's protected addon API. Forever can restore long-lived auras after `PLAYER_ENTERING_WORLD`, so the addon waits two seconds and establishes a second settling baseline before arming detection. Aura updates during that window are treated as existing state and can never schedule a thank-you. It then listens for global aura changes and filters them to the player. It uses incremental aura data when Blizzard provides it; otherwise it compares complete helpful-aura snapshots to find newly added buffs. The `isFromPlayerOrPlayerPet` field means the aura came from any player or player pet, not necessarily your own character, so the addon resolves the actual caster before deciding whether the buff is external. Known self-cast and non-player-owned effects are discarded by caster identity, with a small verified exclusion set for source-less internal auras such as Stealth. When the ordinary aura record omits `sourceUnit`, it asks WoW for the authoritative caster GUID of that exact aura instance and resolves the player's whisper name from that GUID. Readable exact source data remains usable when unrelated aura ownership or spell fields are protected. Forever whisper targets combine the first-name and surname values returned by this branch, which rejects incomplete one-word recipients. The exact caster and spell application is remembered even if it is suppressed for being grouped or inside the cooldown, and an updated instance is accepted as a new application only when its readable expiry moves forward. Recent nearby chat supplies another exact GUID-matched full-name source. Anonymous aura correlation requires the same spell and never guesses from a merely recent targeted caster. During combat, readable exact caster records are retained and their thank-you is deferred until combat and chat lockdown end; a post-combat snapshot also recovers lasting buffs that were hidden during combat. Blizzard may still hide all identifying information; those buffs are safely ignored instead of guessing. Classic clients expose broader combat-log information and therefore provide wider detection.

Forever beta builds are identified by their 1.60.x interface number as well as by Blizzard's project constants, because some beta builds do not expose a dedicated Forever project constant.

## Privacy and chat

The addon stores its enabled/disabled setting and local thank-you phrase list. Diagnostic mode is session-only, starts off on every load, and is never saved. The addon does not collect or transmit data beyond the single in-game whisper it sends to the player who buffed you.

## License

All Rights Reserved.

