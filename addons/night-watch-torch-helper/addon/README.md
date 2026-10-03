# Night Watch Torch

For WoW Forever 1.60.1 (Interface 16001).

A small, movable torch button appears when you can use Night Watchman's Torch.
Click it once, or use its optional keybinding, to apply the buff. WoW requires a
real click or keypress for item use; this add-on cannot apply it automatically.

## Conditions

- Nighttime according to the game's day/night API, OR active non-clear weather.
- Night Watchman's Torch (item 280612) is in your backpack or a carried bag.
  Copies in your bank or account bank do not qualify.
- Both known torch buffs (spells 1309410 and 1321139) are absent. Active helpful
  buffs are also checked by the torch's name, including localized names.
- You are alive, out of combat, and stationary for at least 0.75 seconds.
- You are not mounted, on a flight path, flying, in a vehicle, falling or swimming.
- You are not casting or channeling, and the item is unlocked and off cooldown.
- The merchant window is closed so clicking cannot accidentally sell the torch.

The checks run when relevant game events arrive and every 0.2 seconds. They run
again at the actual click, with a fresh carried-bag scan. Running and walking both
block the button, and a stationary mount still blocks it. It does not cancel a
torch buff you already have when you move or when the weather clears.

## Darkness and mist

Uses `C_DateAndTime.IsDayTime()` and `C_Weather.GetCurrentWeather()`.
Rain, snow, sandstorm and miscellaneous weather qualify when intensity is greater
than zero. The weather API has no separate fog/mist category and no ambient-light
measurement. Purely visual fog, caves, shade and permanently dark areas may not
register. In such a place, `/nwt dim on` temporarily marks the area as dim while
keeping every other condition. It clears on zone/subzone changes, loading screens
or reload; `/nwt dim off` clears it immediately. The add-on does not pretend to
detect fog that the game does not report.

## Installation

Copy the entire `NightWatchTorch` folder into your Forever client's
`Interface/AddOns` folder. The file must be at
`Interface/AddOns/NightWatchTorch/NightWatchTorch.toc`, with no extra nested folder.
Restart WoW if this is a newly installed add-on. Enable **Night Watch Torch** in
the character-selection AddOns list.

## Controls

- Minimap torch icon: left-click for settings; right-click to move/lock the torch
  button. Drag the minimap icon to reposition it. Its position is saved.
- Settings include enable/disable, temporary dim-area mode, size and arrangement.
- `/nwt options` — open settings.
- `/nwt minimap show` or `/nwt minimap hide` — restore or hide the minimap icon.
- `/nwt` — command help.
- `/nwt status` — why the button is waiting, plus reported day/weather values.
- `/nwt unlock` — show a draggable preview; preview cannot use the item.
- `/nwt lock` — return to normal behavior.
- Shift-drag the visible button — move it without using the item.
- `/nwt size 64` — change size (32–100).
- `/nwt on` or `/nwt off` — enable or disable.
- `/nwt dim on` or `/nwt dim off` — temporary manual dim-area setting.
- `/nwt reset` — restore default position, size and enabled state.

Optional keyboard shortcut: open Options > Keybindings, find **Night Watch Torch**,
then bind **Use torch when eligible**. No key is assigned or replaced automatically.
The key uses the same eligibility checks as the button.

## Verification and limits

Source was checked against the Forever client UI/API branch and the locally
installed client's interface version. Lua 5.1 simulation tests cover eligibility,
bag-only ownership, buff suppression, movement, combat, weather, cooldowns,
click-time rechecks and secure-state disarming. These tests do not run the WoW
client's protected-action engine. Actual item use and fog classification still
need an in-game check on this beta build.

To check in-game: stand still at night with the item in your bags and without its
buff. Click the button once and confirm that the buff appears and the button
hides. Check that walking, running, a stationary mount, a flight path and combat
prevent another prompt. Banking the torch must also prevent it. `/nwt status`
reports the first unmet condition.

## References

- [Forever weather API source](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/WeatherScriptDocumentation.lua)
- [Forever weather categories](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/WeatherConstantsDocumentation.lua)
- [Forever day/night API source](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/DateAndTimeDocumentation.lua)
- [Blizzard's secure action button implementation](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_FrameXML/SecureTemplates.lua)
- [Torch item data](https://www.wowhead.com/forever/item=280612/night-watchmans-torch)
- [Torch buff data](https://www.wowhead.com/forever/spell=1309410/night-watchmans-torch)
- [Torch illumination buff data](https://www.wowhead.com/forever/spell=1321139/night-watchmans-torch)
