# Thanks for Buffing: Forever

Thanks for Buffing: Forever notices when another player gives you a helpful buff, waits a random 3–10 seconds, and sends that player one natural-sounding thank-you by whisper.

## Features

- 15 short, natural thank-you messages selected at random
- A genuinely random 3–10 second delay
- Whispers only — never party, raid, say, or public chat
- Coalesces several buffs from the same player into one thank-you
- One reply per player every 10 minutes to avoid spam
- Stays silent while you are in a party, dungeon group, or raid
- Enabled by default, with simple slash commands
- Native support for WoW Forever 1.60.1
- Also packaged for current Retail, Mists Classic, Burning Crusade Classic, and Classic Era

## Commands

- `/tftbf` or `/tftbf status` — show status
- `/tftbf on` — enable the addon
- `/tftbf off` — disable the addon
- `/tftbf debug` — show or hide local detection messages for testing

## Installation

Extract the `ThanksForTheBuffForever` folder into your game client's `Interface/AddOns` folder, then restart the game or type `/reload`.

## Modern client note

WoW Forever and modern Retail use Blizzard's protected addon API. The addon detects newly added helpful auras outside protected combat contexts. When Blizzard omits the caster from an aura, it can safely match that aura to the same spell just cast by a visible nearby player. Blizzard may still hide all identifying information or temporarily lock addon chat; those buffs are safely ignored instead of attempting a protected action. Classic clients expose broader combat-log information and therefore provide wider detection.

Forever beta builds are identified by their 1.60.x interface number as well as by Blizzard's project constants, because some beta builds do not expose a dedicated Forever project constant.

## Privacy and chat

The addon stores only its enabled/disabled and optional debug settings. It does not collect or transmit data beyond the single in-game whisper it sends to the player who buffed you.

## License

All Rights Reserved.
