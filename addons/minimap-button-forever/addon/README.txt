MINIMAP BUTTON: FOREVER - 1.0.14
For WoW: Forever 1.60.1 (interface 16001).

GET STARTED
Extract the ZIP into your Forever client's Interface\AddOns folder.
The resulting file must be:
Interface\AddOns\MinimapButtonForever\MinimapButtonForever.toc

Restart WoW fully if it was running when the add-on was installed, then enable
"Minimap Button: Forever" in the character-selection AddOns list.

WHAT IT DOES
Minimap Button: Forever finds add-on buttons attached to the minimap and places
them beside one gold controller icon. The bar can run horizontally or vertically.
It opens inward from the nearest screen edge so collected icons stay visible.
It collects buttons created by installed add-ons while leaving Blizzard controls,
quest markers, resource nodes and other map-location pins on the minimap.

CONTROLS
Left-click gold icon   Show or hide the collected minimap icons.
Right-click gold icon  Open or close the add-on settings.
Alt-drag gold icon     Move the gold controller around the screen.
/mbf                   Open or close settings.
/mbf horizontal        Use a horizontal bar.
/mbf vertical          Use a vertical bar.
/mbf size 40           Set the icon size from 20 to 64.
/mbf spacing 4         Set the gap between icons from 0 to 16.
/mbf scan              Look for newly loaded minimap buttons.
/mbf reset             Restore the default layout and settings.
/mbf status            Show the current version and layout.

SETTINGS
The settings window can enable or release collected buttons, change orientation,
show or hide the bar background, adjust icon size and spacing, scan again, or
reset the layout. Size is changed in settings, not by left-clicking the icon.
Settings, open/closed state and position save separately for each character.

The prepared button bar can be opened and closed in combat. Minimap buttons are
only collected, released, resized, or rearranged outside combat. Their normal
click actions and tooltips remain owned by their add-ons.
No third-party library is required.

VALIDATION
The manifest, package layout, and Lua source were checked before packaging.
Button discovery, unusual minimap replacements, and protected buttons still need
a live in-game check. See TEST_NOTES.txt for a short checklist.
