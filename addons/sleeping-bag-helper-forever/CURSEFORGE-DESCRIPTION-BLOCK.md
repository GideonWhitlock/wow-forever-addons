# Sleeping Bag Helper: Forever

Help nearby and grouped players understand and share your Cozy Sleeping Bag without repeatedly typing instructions.

## What it does

- **Solo:** when you cast the sleeping bag, shows a button that prepares a friendly `/say` invitation for nearby players to ask for a group invite.
- **Grouped:** prepares one concise `/party` message explaining that players should stand still on the bag and that the XP bonus gains 1% each minute, stacking up to 3%.
- You click the visible button and then press Enter to send the prepared message. This keeps the workflow within Forever's protected-action rules.
- Detects only your own `Unroll Bag` cast.
- Prevents duplicate messages from the cast-start and cast-success events.
- Includes saved toggles for all, solo and party announcements.
- Includes `/sbf test` so the message-preparation workflow can be checked while the bag is on cooldown.
- Does not automate protected chat, item-use or raid-marker actions.

## Commands

- `/sbf on` / `/sbf off`
- `/sbf solo on|off`
- `/sbf party on|off`
- `/sbf status`
- `/sbf test`
- `/sbf debug`
- `/sbf reset`

Built specifically for World of Warcraft: Forever. No libraries, telemetry, advertising or protected gameplay automation.

## Links

- [Report an issue](https://github.com/GideonWhitlock/wow-forever-addons/issues/new)
- [Source](https://github.com/GideonWhitlock/wow-forever-addons/tree/main/addons/sleeping-bag-helper-forever)
- [Changelog](https://github.com/GideonWhitlock/wow-forever-addons/blob/main/addons/sleeping-bag-helper-forever/CHANGELOG.md)
