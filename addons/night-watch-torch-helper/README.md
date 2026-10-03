# Night Watch Torch Helper

Night Watch Torch Helper offers a movable **Light torch** button when Night Watchman's Torch can be used safely. The add-on appears as **Night Watch Torch** in WoW's AddOns list.

The reminder appears only when:

- Night Watchman's Torch is in a carried bag and is ready to use.
- The torch buff is not already active.
- The character is alive, out of combat and stationary for at least 0.75 seconds.
- The character is not mounted, on a flight path, flying, in a vehicle, falling or swimming.
- The character is not casting or channeling, and the merchant window is closed.
- WoW reports night-time or active non-clear weather, or the temporary manual dim-area option is enabled.

A real click or keypress is always required. WoW does not allow the add-on to use the item automatically.

## Compatibility

| Item | Value |
| --- | --- |
| Current release | 1.0.2 |
| Game flavour | WoW: Forever |
| Game version | 1.60.1 |
| Interface | 16001 |
| Dependencies | None |
| License | All Rights Reserved |

The released source, package and installed files were last checked against Forever build 1.60.1.70205. This is a compatibility record, not a promise that undocumented beta changes cannot affect the add-on.

## Installation

### CurseForge

Install **Night Watch Torch Helper** for the WoW: Forever game flavour. Enable **Night Watch Torch** in the character-selection AddOns list.

### Manual installation

1. Download the release ZIP.
2. Extract the `NightWatchTorch` folder into the Forever client's `Interface/AddOns` folder.
3. Confirm the file is located at `Interface/AddOns/NightWatchTorch/NightWatchTorch.toc` with no extra nested folder.
4. Restart WoW if this is a new installation, then enable **Night Watch Torch** in the character-selection AddOns list.

For an update installed while WoW is running, type `/reload` after replacing the add-on files.

## Controls and settings

- Click **Light torch** to use the carried torch when every condition is met.
- Minimap torch icon, left-click: open or close settings.
- Minimap torch icon, right-click: move or lock the torch button.
- Drag the minimap icon to reposition it.
- Shift-drag the visible torch button to move it.
- Optional keybinding: **Options > Keybindings > Night Watch Torch > Use torch when eligible**.

| Command | Purpose |
| --- | --- |
| `/nwt` | Show command help. |
| `/nwt options` | Open or close settings. |
| `/nwt status` | Show the first reason the button is waiting, plus reported day and weather values. |
| `/nwt on` / `/nwt off` | Enable or disable torch reminders. |
| `/nwt unlock` / `/nwt lock` | Show a safe positioning preview or return to normal behavior. |
| `/nwt size 64` | Set the button size from 32 to 100. |
| `/nwt minimap show` / `/nwt minimap hide` | Show or hide the minimap settings icon. |
| `/nwt dim on` / `/nwt dim off` | Temporarily treat the current area as dim or restore automatic detection. |
| `/nwt reset` | Restore the default position, size and enabled state. |

Settings are saved per character. The temporary dim-area option clears on a zone or subzone change, loading screen or reload.

## Known limitations

- Item use cannot be fully automatic; a click or assigned keypress is required.
- The torch must be in the backpack or another carried bag. Bank and account-bank copies do not qualify.
- Night-time and weather depend on WoW: Forever's reported data. Rain, snow, sandstorms and miscellaneous non-clear weather qualify when the reported intensity is greater than zero.
- The weather API has no separate fog or mist category and no ambient-light measurement. Visual fog, caves, shade and permanently dark areas may require `/nwt dim on`.
- The button is intentionally hidden during combat, movement, travel, casting, item cooldowns and an existing torch buff.
- WoW: Forever is a beta game flavour. Undocumented client changes can affect item records, protected actions, events or APIs before documentation is available.

## Support and source

- [Report an issue]({{NIGHT_WATCH_TORCH_ISSUE_URL}})
- [Source]({{NIGHT_WATCH_TORCH_SOURCE_URL}})
- [Changelog]({{NIGHT_WATCH_TORCH_CHANGELOG_URL}})

When reporting an issue, remove account details, access tokens, private chat, personal file paths and any other information you do not want published.

