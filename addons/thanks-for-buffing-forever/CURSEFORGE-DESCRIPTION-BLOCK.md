# Thanks for Buffing: Forever

Bring a little friendliness back to buffing.

When another player gives you a helpful buff, **Thanks for Buffing: Forever** waits a random **3–10 seconds** and sends that player one short, natural thank-you by **private whisper**.

## What it does

- Chooses from 15 natural replies such as “thanks!”, “cheers!”, and “much appreciated!”
- Waits a random 3–10 seconds so replies do not feel instant or robotic
- Uses whisper only — never party, raid, say, or public chat
- Groups several buffs from the same player into one reply
- Sends at most one reply to the same player every 10 minutes
- Stays silent while you are in a party, dungeon group, or raid
- Works immediately with no setup

## Commands

- `/tftbf` or `/tftbf status` — show status
- `/tftbf on` — enable
- `/tftbf off` — disable
- `/tftbf debug` — toggle session-only diagnostics; always off after login or `/reload`

## Compatibility

Built first for **WoW Forever 1.60.1**, with additional TOCs for current Retail, Mists Classic, Burning Crusade Classic, and Classic Era.

Version 1.0.10 was live verified on WoW Forever build 1.60.1.70205.

On WoW Forever and modern Retail, Blizzard protects combat, chat, and aura-source data. The addon safely detects buffs when the game exposes an accessible, non-secret caster outside protected contexts. If Blizzard hides the caster or locks addon chat, the addon simply does nothing instead of attempting a protected action. Classic clients provide wider detection through the combat log.

No libraries or other addons are required.

## Support and source

- [Report an issue](https://github.com/GideonWhitlock/wow-forever-addons/issues/new/choose)
- [Source](https://github.com/GideonWhitlock/wow-forever-addons/tree/main/addons/thanks-for-buffing-forever/addon)
- [Changelog](https://github.com/GideonWhitlock/wow-forever-addons/blob/main/addons/thanks-for-buffing-forever/CHANGELOG.md)
