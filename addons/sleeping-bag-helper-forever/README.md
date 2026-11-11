# Sleeping Bag Helper: Forever

![Sleeping Bag Helper: Forever icon](artwork/project-icon-safe-1024.png)

A small World of Warcraft: Forever add-on that helps players share and understand the Cozy Sleeping Bag XP buff.

## Features

- Detects the player's `Unroll Bag` cast and the Cozy Sleeping Bag item when used from a bag or action bar.
- Resolves the bag's current spell ID from the Forever client instead of relying only on a fixed ID.
- Shows a safe message-preparation button when the bag is used.
- Clicking the button fills the correct `/say` or `/party` message into chat; press Enter to send it.
- Explains that players must stand still on the bag and that the XP bonus gains 1% per minute, stacking to 3%.
- Includes saved solo, party and master toggles.
- Handles Forever chat lockdown safely and suppresses duplicate cast events.
- Has no libraries, networking, telemetry, advertising or protected gameplay actions.

## Install for testing

Copy the `SleepingBagHelperForever` folder from `addon/` into the Forever client's `Interface/AddOns/` folder, then reload the interface.

## Commands

`/sbf on`, `/sbf off`, `/sbf status`, `/sbf test`, `/sbf debug`, `/sbf solo on|off`, `/sbf party on|off`, `/sbf reset`

`/sbf test` displays the message-preparation button without using the bag, so the workflow can be checked while the bag is on cooldown.

## Compatibility

Prepared for WoW: Forever 1.60.1, interface 16001.
