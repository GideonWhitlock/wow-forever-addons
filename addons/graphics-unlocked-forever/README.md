# Graphics Unlocked: Forever

Graphics Unlocked: Forever exposes useful WoW: Forever graphics controls that are not available in the standard graphics panel. It presents them as clear sliders and toggles with plain-language explanations, five hardware profiles and safe restoration of the player's original values.

The public release is version **1.0.1** for WoW: Forever **1.60.1** (interface **16001**). Install the `GraphicsUnlockedForever` folder in `_classic_beta_/Interface/AddOns/`, enable the add-on, and use `/guf` or its minimap button to open the controls.

## Features

- 22 individual controls for ground detail, distant objects, terrain, fog, sharpening, render scale, ambient occlusion, HDR, shadows, camera distance, weather and reflections.
- Potato, Low, Medium, High and UFO whole-system profiles.
- P/L/M/H/UFO shortcuts for each applicable individual setting.
- Captures each original value before the first change and can restore settings individually or together.
- Optional reapplication on login and zone changes; disabled until the player enables it.
- A movable 32-pixel minimap button, AddOn Compartment entry and native Options → AddOns category.
- No required libraries or companion add-ons.

The five profiles deliberately leave HDR and camera distance untouched because those choices depend on the display and player preference. Unsupported CVars are shown as unavailable instead of pretending a change succeeded.

## Commands

- `/guf` — open or close the graphics controls.
- `/guf preset potato|low|medium|high|ufo` — apply a whole-system profile.
- `/guf list` — list controls and their CVar names.
- `/guf set <id> <value>` — change one control.
- `/guf reset <id|all>` — restore captured original values.
- `/guf minimap` — hide or show the minimap button.
- `/guf status` — show the add-on version and control count.

See the installable source in [addon](addon/) and released changes in [CHANGELOG.md](CHANGELOG.md).
