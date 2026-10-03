# Feed Pet: Forever

Feed Pet: Forever is a hunter pet-feeding reminder for **WoW: Forever**. When a living, summoned hunter pet is unhappy or content, the addon displays a flashing Feed Pet icon. One left-click feeds suitable food from the character's carried bags. If the pet needs food and no suitable item is available, an optional red **NO FOOD** warning appears instead.

The addon asks the game client's pet-food API whether the current pet can eat each item. It does not maintain its own pet-family or food whitelist.

## Current release

- Addon version: **1.0.2**
- Release channel: **Release**
- Game flavour: **WoW: Forever 1.60.1**
- Interface version: **16001**
- Static compatibility reviewed through client build **1.60.1.70205**

Versions 1.0.1 and 1.0.2 changed the displayed title only. Feeding behavior in 1.0.2 is unchanged from the owner-accepted 1.0.0 release.

## Features

- Secure one-click feeding from carried bags.
- Uses the client's current pet-food eligibility result.
- Shows the selected food in a tooltip and the available suitable-food count on the icon.
- Optional no-food warning and optional flashing.
- Hides during combat, death, flight paths, mounting, vehicles, an active feeding effect, and other states where feeding is unavailable.
- Movable and resizable alert with per-character settings.
- Draggable minimap button for settings and layout preview.
- No external libraries or companion addons.

## Installation

1. Download and extract the release ZIP.
2. Copy the `FeedPetForever` folder into the Forever client's `Interface/AddOns` folder.
3. Confirm that the final path ends with `Interface/AddOns/FeedPetForever/FeedPetForever.toc`.
4. Restart the game if it was already running.
5. Enable **Feed Pet: Forever** in the character-selection AddOns list.

The package targets WoW: Forever. It is not released for Retail, Classic Era, or other World of Warcraft clients.

## Controls and settings

### Feeding alert

- **Left-click:** feed the selected food.
- **Right-click:** open settings.
- **Shift-drag:** move the alert.
- **Shift-mousewheel:** resize the alert.

### Minimap button

- **Left-click:** open or close settings.
- **Right-click:** toggle the nonfeeding layout preview.
- **Drag:** move the button around the minimap.

### Slash commands

| Command | Action |
| --- | --- |
| `/fpf` | Open settings. |
| `/fpf unlock` | Show a nonfeeding layout preview for moving and resizing. |
| `/fpf lock` | End the preview and restore normal alert conditions. |
| `/fpf size 80` | Set the alert size from 24 to 160 UI units. |
| `/fpf reset` | Return the alert to the centre and reset its size to 64. |
| `/fpf test nofood` | Preview the no-food appearance. |
| `/fpf nofood on` or `/fpf nofood off` | Show or hide the no-food warning. |
| `/fpf flash on` or `/fpf flash off` | Enable or disable flashing. |
| `/fpf minimap on` or `/fpf minimap off` | Show or hide the minimap button. |
| `/fpf status` | Print addon, client, alert, and selected-food information for troubleshooting. |

Position, size, alert preferences, and minimap settings are saved separately for each character. Settings cannot be changed during combat, and layout preview ends on entering combat.

## Known limitations

- A hunter must know Feed Pet and have a living hunter pet summoned.
- Food is selected from carried bags only. Bank and warband-bank items are not used.
- The client may accept cooked, raw, or buff food. The addon does not reserve food intended for the player.
- Feeding requires a real left-click. The addon cannot feed automatically in the background.
- Normal spell range, cooldown, protected-action, and game-client restrictions still apply.
- Automated tests cover addon behavior but cannot reproduce every native secure-action, rendering, event-delivery, or server-side feeding detail.

When reporting a problem, include the output of `/fpf status` and remove character, account, installation-path, or other private information from errors and screenshots.

## Changelog and licence

See [CHANGELOG.md](CHANGELOG.md) for released changes.

Feed Pet: Forever is available under the MIT License. Copyright © 2026 Gideon. World of Warcraft UI textures are supplied by the game client and are not included in this project.
