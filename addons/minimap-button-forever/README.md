# Minimap Button: Forever

**Repository identifier:** `minimap-button-forever`  
**Issue label:** `addon:minimap-button-forever`  
**Current release:** 1.0.14  
**Game flavour:** WoW: Forever 1.60.1, interface 16001

Minimap Button: Forever gathers eligible add-on minimap buttons into one movable,
collapsible bar. The gold controller stays visible while the collected buttons can
be shown or hidden. The bar can run horizontally or vertically and expands inward
from the nearest screen edge.

It is deliberately limited to buttons created by installed add-ons. Blizzard
controls, protected buttons, quest markers, resource nodes and other map-location
pins remain untouched.

## Installation

1. Download the current release ZIP.
2. Extract the `MinimapButtonForever` folder into the WoW: Forever
   `Interface/AddOns` directory.
3. Confirm that the resulting file is
   `Interface/AddOns/MinimapButtonForever/MinimapButtonForever.toc`.
4. Restart the game if it was running, then enable **Minimap Button: Forever** in
   the character-selection AddOns list.

The add-on is packaged specifically for **WoW: Forever 1.60.1** and interface
**16001**. It is not tagged for Retail, Classic Era or other clients.

## Controls and settings

| Action | Result |
| --- | --- |
| Left-click the gold controller | Show or hide collected buttons, including during combat |
| Right-click the gold controller | Open or close settings outside combat |
| Alt-drag the gold controller | Move the controller outside combat |
| `/mbf` | Open or close settings |
| `/mbf horizontal` | Use a horizontal bar |
| `/mbf vertical` | Use a vertical bar |
| `/mbf size 40` | Set icon size from 20 to 64 |
| `/mbf spacing 4` | Set spacing from 0 to 16 |
| `/mbf scan` | Scan for newly loaded buttons |
| `/mbf reset` | Restore the default layout and settings |
| `/mbf status` | Print the current version and layout |

The settings window can enable or release collected buttons, select horizontal or
vertical layout, show or hide the bar background, change icon size and spacing,
rescan, and reset the layout. Position and preferences are saved per character.

## Known limitations

- Collection, release, resizing, reparenting and layout changes are deferred until
  combat ends. Only the visibility of the prepared bar can change during combat.
- Settings and Alt-drag movement are unavailable during combat.
- Protected buttons and Blizzard minimap controls are intentionally excluded.
- Discovery targets button frames attached to the minimap, its wrapper hierarchy,
  or the UI root. Unusual minimap replacements or non-button launchers may require
  a manual `/mbf scan` or may not be compatible.
- Collected buttons keep the click actions and tooltips supplied by their owning
  add-ons. Compatibility can therefore vary when another add-on repeatedly changes
  its own button's parent, visibility or artwork.

No third-party library is required.

## Support

When reporting a problem, use the `addon:minimap-button-forever` label and include
the requested environment and reproduction details. Remove character names,
account identifiers, server addresses and other private information from errors or
screenshots before posting.

## Licence

The add-on source is available under the MIT License. Copyright © 2026 Gideon.

