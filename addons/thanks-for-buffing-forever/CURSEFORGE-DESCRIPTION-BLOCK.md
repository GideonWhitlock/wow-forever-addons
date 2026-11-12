# Thanks For The Buff: Forever

Bring a little friendliness back to buffing.

When another player gives you a helpful buff, **Thanks For The Buff: Forever** waits a random **3–10 seconds** and sends that player one short, natural thank-you by **private whisper**.

## What it does

- Chooses from 15 natural replies such as “thanks!”, “cheers!”, and “much appreciated!”
- Lets you view and edit the saved phrase list with `/tftbf phrases`
- Waits a random 3–10 seconds so replies do not feel instant or robotic
- Uses whisper only — never party, raid, say, or public chat
- Groups several buffs from the same player into one reply
- Uses a 60-second per-player cooldown to prevent spam
- Works immediately with no setup

## Commands

- `/tftbf` or `/tftbf status` — show status
- `/tftbf on` — enable
- `/tftbf off` — disable
- `/tftbf phrases` — list the numbered thank-you phrases
- `/tftbf phrases add <text>` — add a phrase
- `/tftbf phrases remove <number>` — remove a phrase
- `/tftbf phrases reset` — restore the defaults

## Compatibility

Built first for **WoW Forever 1.60.1**, with additional TOCs for current Retail, Mists Classic, Burning Crusade Classic, and Classic Era.

On WoW Forever and modern Retail, Blizzard protects combat and aura-source data. The addon safely detects buffs when the game exposes an accessible caster outside protected combat contexts. If Blizzard hides the caster, the addon simply does nothing. Classic clients provide wider detection through the combat log.

No libraries or other addons are required.
