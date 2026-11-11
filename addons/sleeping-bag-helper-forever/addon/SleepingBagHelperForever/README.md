# Sleeping Bag Helper: Forever

Sleeping Bag Helper politely explains how to share and use the Cozy Sleeping Bag whenever its owner casts **Unroll Bag**.

- When the bag is detected, a safe message-preparation button appears because Forever blocks automatic add-on chat.
- Clicking it while solo prepares: `Using my sleeping bag - invite me if you want the XP buff too.`
- Clicking it while grouped prepares: `Sleeping bag is down: stand on it and stay still. The XP buff gains 1% each minute, stacking up to 3%.`
- Press Enter to send the prepared message.
- It never sends both messages for one cast.
- A 30-second duplicate guard prevents the cast-start and cast-success events from producing repeated messages.
- It does not announce when another player casts a sleeping bag.
- In a party, a successful cast can play a local confirmation sound without attempting a protected raid marker.
- It detects the sleeping bag from bag clicks, action-bar clicks and the client's cast events.

## Commands

- `/sbf` — show commands
- `/sbf on` or `/sbf off` — enable or disable all announcements
- `/sbf solo on|off` — toggle the solo `/say` invitation
- `/sbf party on|off` — toggle the grouped instructions
- `/sbf marker on|off` — toggle the party-only Moon marker
- `/sbf sound on|off` — toggle the sound played when the marker is applied
- `/sbf status` — show the current settings
- `/sbf test` — display the message-preparation button without using the bag
- `/sbf debug` — show the resolved bag spell and current settings
- `/sbf reset` — restore the defaults

Settings are saved in `SleepingBagHelperForeverDB`. WoW may refuse the marker if the character does not have permission to apply raid targets; the chat message still works.
